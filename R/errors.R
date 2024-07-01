new_hotwater_error <- function(type) {
    sprintf("hotwater_%s_error", type)
}

new_hotwater_warning <- function(type) {
    sprintf("hotwater_%s_warning", type)
}

error_invalid_path <- function(path) {
    cli::cli_abort(
        c(
            "Invalid path: {.file {path}}",
            x = "{.file {path}} not a valid path to a file"
        ),
        class = new_hotwater_error("invalid_path")
    )
}

error_invalid_path_length <- function(path) {
    cli::cli_abort(
        c(
            "Invalid path: {.file {path}}",
            x = "{.file {path}} must be length 1L"
        ),
        class = new_hotwater_error("invalid_path_length")
    )
}

error_invalid_dir <- function(dir) {
    cli::cli_abort(
        "Invalid directory: {.file {dir}}",
        class = new_hotwater_error("invalid_dir")
    )
}

error_invalid_port <- function(port) {
    cli::cli_abort(
        "Invalid port: {port}",
        class = new_hotwater_error("invalid_port")
    )
}

error_invalid_host <- function(host) {
    cli::cli_abort(
        "Invalid host: {.url {host}}",
        class = new_hotwater_error("invalid_host")
    )
}

error_already_installed <- function(path) {
    cli::cli_abort(
        "{.pkg hotwater} already exists at {.file {path}}",
        class = new_hotwater_error("install")
    )
}

error_cannot_uninstall <- function(path) {
    cli::cli_abort(
        c(
            "Could not uninstall {.pkg hotwater}.",
            "*" = "Check that R has permissions to remove {.pkg hotwater} from {.path {path}}"
        ),
        class = new_hotwater_error("uninstall")
    )
}

warning_not_installed <- function(path) {
    cli::cli_warn(
        "{.pkg hotwater} is not installed at {.path {path}}",
        class = new_hotwater_warning("not_installed")
    )
}
