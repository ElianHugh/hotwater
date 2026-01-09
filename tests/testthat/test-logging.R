# mock the nanonext fn to test if we are
# handling the sink properly
capture_write_stdout <- function(code) {
    out <- character()
    old <- nanonext::write_stdout
    assignInNamespace(
        "write_stdout",
        function(x) out <<- c(out, x),
        ns = "nanonext"
    )
    on.exit(assignInNamespace("write_stdout", old, ns = "nanonext"), add = TRUE)
    code()
    out
}

test_that('log files are created/removed', {
    engine <- new_test_engine()
    logpath <- engine$logpath
    new_runner(engine)
    expect_true(file.exists(logpath))
    kill_engine(engine)
    cleanup_test_engine(engine)
    rm(engine)
    gc()
    expect_false(file.exists(logpath))
})

test_that("stdout drain forwards log contents", {
    engine <- new_test_engine()
    logpath <- engine$logpath

    cat("Hello World!\n", file = logpath)

    out <- capture_write_stdout(function() {
    drain_runner_log(engine)
    })

    expect_true(any(grepl("Hello World!", out)))


    cleanup_test_engine(engine)
    rm(engine)
    gc()
})

test_that("markers are removed", {
    engine <- new_test_engine()
    logpath <- engine$logpath
    cat(
        "=== HOTWATER_ERROR_BEGIN ===\nfoo\n=== HOTWATER_ERROR_END ===\n",
        file = logpath
    )

    out <- capture_write_stdout(function() drain_runner_log(engine))
    txt <- paste(out, collapse = "")

    expect_true(grepl("foo", txt))
    expect_false(grepl("HOTWATER_ERROR_BEGIN", txt))
    expect_false(grepl("HOTWATER_ERROR_END", txt))


    cleanup_test_engine(engine)
    rm(engine)
    gc()
})


test_that("engine doesn't reprint old content", {
    engine <- new_test_engine()
    logpath <- engine$logpath
    cat("A\n", file = logpath)

    out1 <- capture_write_stdout(function() drain_runner_log(engine))
    out2 <- capture_write_stdout(function() drain_runner_log(engine))

    expect_true(any(grepl("A", out1)))
    expect_false(any(grepl("A", out2)))

    cleanup_test_engine(engine)
    rm(engine)
    gc()
})