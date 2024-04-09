common_install_paths <- list(
    unix = c(
        "~/.local/bin/",
        "~/bin/",
        "/usr/bin/",
        "/usr/local/bin/",
        "/bin/"
    ),
    windows = c() # does windows even work with this?
)

#' WORK IN PROGRESS
#' @param install_folder folder (in PATH) to install hotwater
#' @export
install_hotwater <- function(install_folder = "~/.local/bin/") {
    p <- file.path(install_folder, "hotwater")

    if (file.exists(p)) {
        error_already_installed(p)
    }

    success <- file.symlink(
        from = system.file("exec", "hotwater", package = "hotwater"),
        to = p
    )

    if (success) {
        cli::cli_alert_success("Successfully installed {.pkg hotwater}!")
    } else {
        error_cannot_uninstall(install_folder)
    }
}

#' WORK IN PROGRESS
#' @param install_folder folder (in PATH) to uninstall hotwater
#' @export
uninstall_hotwater <- function(install_folder = "~/.local/bin/") {
    p <- file.path(install_folder, "hotwater")
    if (file.exists(p)) {
        success <- file.remove(p)
        if (success) {
            cli::cli_alert_success("Successfully uninstalled {.pkg hotwater}")
        } else {
            error_cannot_uninstall(install_folder)
        }
    } else {
        warning_not_installed(install_folder)
    }
}

#' Check suggested packages for CLI usage
#'
#' The {docopt} and {remotes} packages are required to run hotwater from the command line.
#'
#' @noRd
check_suggests <- function() {
    suggests <- c("docopt")
    for (suggestion in suggests) {
        if (!requireNamespace(suggestion, quietly = TRUE)) {
            cli::cli_abort(
                c(
                    "Running {.pkg hotwater} from the command-line requires the {.pkg {suggestion}} package",
                    "*" = "Try running {.code install.packages('{suggestion}')}"
                ),
                call = globalenv()
            )
        }
    }
}

#' Run hotwater as a bash script
#' @noRd
run_cli <- function() {
    doc <- "hotwater

    Usage:
        hotwater --file=FILE [--dirs=DIRS] [--port=PORT] [--host=SERVER]
        hotwater -h | --help
        hotwater -v | --version

    Options:
        -h --help                   show help text
        -v --version                show hotwater version
        -f FILE --file=FILE         plumber path (required)
        -d DIRS --dirs=DIRS         extra directories
        -p PORT --port=PORT         plumber port
        -s SERVER --server=SERVER   plumber host
    "

    args <- docopt::docopt(
        doc,
        version = as.character(utils::packageVersion("hotwater"))
    )

    run(
        path = args$file,
        dirs = args$dirs,
        port = if (is.null(args$port)) NULL else as.numeric(args$port),
        host = args$server
    )
}
