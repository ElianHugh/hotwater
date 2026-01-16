# Handle all hotwater config here to pass to engine (see engine.R)
# Includes defaults, config files, etc

new_config <- function(...) {
    dots <- list(...)

    host <- dots$host %||%
        plumber::get_option_or_env("plumber.host") %||%
        "127.0.0.1"
    port <- dots$port %||%
        plumber::get_option_or_env("plumber.port") %||%
        new_port(host = host)
    ignore <- dots$ignore %||%
        utils::glob2rx(
            paste(
                c(
                    # dbs
                    "*.sqlite",
                    "*.sqlite3",
                    "*.db",
                    "*.db-journal",
                    "*.db-wal",
                    "*.db-shm",

                    #os
                    ".DS_Store",
                    "Thumbs.db",

                    # git
                    "*.git*",
                    ".git/*",
                    ".gitignore",
                    ".gitmodules",

                    # R

                    ".Rhistory",
                    ".RData",
                    ".Ruserdata",
                    ".Rproj.user/*",

                    "*/.*"
                ),
                collapse = "|"
            )
        )

    structure(
        list(
            entry_path = dots$path,
            entry_dir = dirname(dots$path),
            dirs = dots$dirs,
            host = host,
            port = port,
            socket_port = new_port(
                used = port,
                host = host
            ),
            ignore = ignore,
            runner_compute = "hotwater_runner"
        ),
        class = c("hotwater_config", "list")
    )
}

validate_config <- function(config) {
    stopifnot(is_config(config))

    if (length(config$entry_path) > 1L) {
        error_invalid_path_length(config$entry_path)
    }

    if (!file.exists(config$entry_path) || dir.exists(config$entry_path)) {
        error_invalid_path(config$entry_path)
    }

    if (!is.null(config$dirs) && !all(dir.exists(config$dirs))) {
        invalid <- config$dirs[!dir.exists(config$dirs)]
        error_invalid_dir(invalid)
    }

    if (!is.numeric(config$port)) {
        error_invalid_port(config$port)
    }

    if (is.numeric(config$host)) {
        error_invalid_host(config$host)
    }
}

#' it's possible to duplicate the port when it isn't immediately used
#' this just makes sure we end up with a different number...
#' @noRd
new_port <- function(used, host = "127.0.0.1") {
    out <- NULL
    if (missing(used)) {
        out <- httpuv::randomPort(host = host, n = 100L)
    } else {
        repeat {
            out <- httpuv::randomPort(host = host, n = 100L)
            if (out != used) break
        }
    }
    out
}

is_config <- function(x) {
    inherits(x, "hotwater_config")
}


