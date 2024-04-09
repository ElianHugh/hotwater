test_that("startup/teardown messages don't error", {
    engine <- new_test_engine()
    expect_no_error(suppressMessages(buildup_engine(engine)))
    expect_no_error(suppressMessages(teardown_engine(engine)))
    cleanup_test_engine(engine)
})
