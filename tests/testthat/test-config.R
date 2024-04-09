test_that("config is validated", {
    bad <- new_config(
        path = "."
    )
    expect_error(validate_config(bad))
})
