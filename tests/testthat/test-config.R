test_that("config is validated", {
    bad <- new_config(path = ".")
    bad2 <- new_config(
        path = c(
            system.file("examples", "plumber.R", package = "hotwater"),
            system.file("examples", "plumber.R", package = "hotwater")
        )
    )
    bad3 <- new_config(
        path = system.file("examples", "plumber.R", package = "hotwater"),
        dirs = system.file("examples", "plumber.R", package = "hotwater")
    )
    bad4 <- new_config(
        path = system.file("examples", "plumber.R", package = "hotwater"),
        port = "not a port"
    )
    expect_error(
        validate_config(bad),
        class = new_hotwater_error("invalid_path")
    )
    expect_error(
        validate_config(bad2),
        class = new_hotwater_error("invalid_path_length")
    )
    expect_error(
        validate_config(bad3),
        class = new_hotwater_error("invalid_dir")
    )
    expect_error(
        validate_config(bad4),
        class = new_hotwater_error("invalid_port")
    )
})
