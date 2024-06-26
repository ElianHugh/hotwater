new_test_engine <- function() {
    config <- new_config(
        path = system.file("examples", "plumber.R", package = "hotwater")
    )
    new_engine(config)
}

cleanup_test_engine <- function(engine) {
    kill_engine(engine)
    close(engine$publisher)
    Sys.sleep(0.5)
}
