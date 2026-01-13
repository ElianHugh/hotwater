cli_welcome <- function() {
    v <- utils::packageVersion("hotwater") # nolint: object_usage_linter.
    cli::cli_h1("{.pkg hotwater} v{v}")
}

cli_goodbye <- function() {
    cli::cli_h2("{.pkg hotwater} turned off")
}

cli_watching_directory <- function(engine) {
    dirs <- c(engine$config$entry_dir, engine$config$dirs) # nolint: object_usage_linter.
    cli::cli_inform("Watching {.file {dirs}} for changes...")
}

cli_file_changed <- function(changes) {
    cli::cli_alert("{.file {changes}} changed!")
}

cli_hot_swapped <- function(changes) {
    n <- length(changes)
    cli::cli_inform("Hot swapped assets ({n} file{?s}): {.file {changes}}")
}

cli_server_start_progress <- function(engine) {
    cli::cli_progress_step(
        msg = "Starting plumber server on {.url {engine$config$host}:{engine$config$port}}",
        msg_done = "Server running on {.url {engine$config$host}:{engine$config$port}}",
        msg_failed = "Unable to start server on {.url {engine$config$host}:{engine$config$port}}",
        spinner = TRUE,
        .envir = parent.frame(n = 1L)
    )
}

cli_server_stop_progress <- function() {
    cli::cli_progress_step(
        msg = "Awaiting runner stop...",
        msg_done = "Stopped runner",
        msg_failed = "Unable to stop runner",
        spinner = TRUE,
        .envir = parent.frame(n = 1L)
    )
}
