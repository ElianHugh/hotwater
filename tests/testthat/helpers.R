new_test_engine <- function() {
    new_engine(
        new_config(
            path = system.file("examples", "plumber.R", package = "hotwater")
        )
    )
}

cleanup_test_engine <- function(engine) {
    kill_engine(engine)
    close(engine$publisher)
}
