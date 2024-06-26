#' @title Run hotwater from the command line
#'
#' @description
#' Following [hotwater::install_hotwater()], the `hotwater` command can be used
#' to run a hotwater engine straight from the terminal. See
#' [hotwater::run()] for further details on default values.
#'
#' `hotwater -v` will provide the current version of hotwater.
#' `hotwater -h` will provide help text.
#'
#' @param -f plumber file
#' @param -d extra directories
#' @param -p plumber port
#' @param -h show help
#' @param --host plumber host
#' @seealso [hotwater::run()]
#' @examples
#' # ```sh
#' # hotwater -f path/to/app.R -p 9999
#' # ```
#' @rdname cli
#' @name cli
NULL

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

#' Install global hotwater script
#'
#' If hotwater is installed, users may run `hotwater` from the command line
#' rather than from an R terminal.
#'
#' @param install_folder \[default "~/.local/bin/"] folder to install hotwater
#' script into. To run as expected, make sure that the folder supplied is on your
#' `PATH` envar.
#' @seealso [hotwater::uninstall_hotwater]
#' @examples
#' if (interactive()) {
#'  hotwater::install_hotwater()
#' }
#' @return NULL
#'
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

#' Uninstall global hotwater script
#'
#' @param install_folder \[default "~/.local/bin/"] folder to uninstall hotwater
#' from.
#' @examples
#' if (interactive()) {
#'     hotwater::uninstall_hotwater()
#' }
#' @seealso [hotwater::install_hotwater]
#' @return NULL
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
#' The {docopt} package is required to run hotwater from the command line.
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

run_cli <- function() {
    doc <- "hotwater

    Usage:
        hotwater --file=FILE [--dirs=DIRS] [--port=PORT] [--host=HOST]
        hotwater -h | --help
        hotwater -v | --version

    Options:
        -h --help                   show help text
        -v --version                show hotwater version
        -f FILE --file=FILE         plumber path (required)
        -d DIRS --dirs=DIRS         extra directories
        -p PORT --port=PORT         plumber port
        --host=HOST                 plumber host
    "

    args <- docopt::docopt(
        doc,
        version = as.character(utils::packageVersion("hotwater"))
    )

    run(
        path = args$file,
        dirs = args$dirs,
        port = if (is.null(args$port)) NULL else as.numeric(args$port),
        host = args$host
    )
}
