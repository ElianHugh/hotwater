test_that("engine reuse", {
    engine <- new_engine(
        new_config(
            path = "./foo/bar.R",
            dirs = "./R",
            host = "127.0.0.1"
        )
    )
    expect_true(
        should_reuse_engine(
            old = engine$config,
            new_config(
                dirs = engine$config$dirs,
                path = engine$config$entry_path,
                port = engine$config$port,
                host = engine$config$host,
                ignore = engine$config$ignore
            )
        )
    )
    cleanup_test_engine(engine)
})

test_that("can kill engine", {
    engine <- new_test_engine()
    new_runner(engine)
    expect_true(is_runner_alive(engine))
    kill_engine(engine)
    expect_false(is_runner_alive(engine))
    cleanup_test_engine(engine)
})
