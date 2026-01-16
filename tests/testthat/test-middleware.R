test_that("middleware injection works", {
    dummy_engine <- list(
        publisher = list(
            listener = list(
                list(url = 1234L)
            )
        )
    )
    class(dummy_engine) <- "plumber_engine"
    expect_snapshot(injection(dummy_engine))
    fn <- middleware(dummy_engine)
    router <- fn(plumber::pr())
    expect_s3_class(router$routes$`__hotwater__`, "PlumberEndpoint")

    expect_identical(
        router$`.__enclos_env__`$private$hooks$postserialize[[1L]],
        postserialise_hotwater(
            '<script src="/__hotwater__/client.js"></script>'
        )
    )
})

test_that("middleware injection works with filters", {
    engine <- new_test_engine()
    runner <- mirai::mirai(
        {
            plumber::pr(config$entry_path) |>
                plumber::pr_filter("foo", function(req, res) {
                    stop("I break things")
                }) |>
                middleware_filter() |>
                plumber::pr_run(port = config$port)
        },
        config = engine$config,
        middleware_filter = middleware(engine),
        .compute = engine$config$runner_compute
    )

    i <- 1L
    while (i < 20L && !is_api_running(engine)) {
        i <- i + 1L
        Sys.sleep(0.5)
    }

    resp <- httr2::request(sprintf("localhost:%s/__hotwater__", engine$config$port)) |>
        httr2::req_perform() |>
        httr2::resp_status()

    expect_identical(resp, 200L)
    cleanup_test_engine(engine)
})

test_that("is_api_running works", {
    engine <- new_test_engine()
    pid <- Sys.getpid()
    router <- mirai::mirai(
        {
            plumber::pr(config$entry_path) |>
                plumber::pr_get(
                    "/__hotwater__",
                    function() pid,
                    serializer = plumber::serializer_text()
                ) |>
                plumber::pr_run(port = config$port)
        },
        config = engine$config,
        pid = pid,
        .compute = engine$config$runner_compute
    )
    i <- 1L
    while (i < 20L && !is_api_running(engine)) {
        i <- i + 1L
        Sys.sleep(0.5)
    }
    kill_runner(engine)
    expect_lt(i, 20L, label = "loop iterations")
    cleanup_test_engine(engine)
})

test_that("autoreloader is attached", {
    engine <- new_test_engine()
    new_runner(engine)

    i <- 1L
    while (i < 20L && !is_api_running(engine)) {
        i <- i + 1L
        Sys.sleep(0.5)
    }

    resp <- sprintf("%s:%s", engine$config$host, engine$config$port) |>
        httr2::request() |>
        httr2::req_perform()

    expect_no_error(
        httr2::resp_check_content_type(
            resp,
            valid_types = "text/html"
        )
    )
    expect_true(
        grepl(
            httr2::resp_body_string(resp),
            pattern = '<script src="/__hotwater__/client.js"></script>'
        )
    )
    cleanup_test_engine(engine)
})
