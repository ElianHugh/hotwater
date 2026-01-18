# Handle all hotwater config here to pass to engine (see engine.R)
# Includes defaults, config files, etc

new_config <- function(...) {
    dots <- list(...)

    yml_host <- NULL
    yml_port <- NULL
    yml_engine_type <- NULL

    if (is_server_yml(dots$path)) {

        yml <- yaml::read_yaml(dots$path)

        yml_host <- yml$options$host
        yml_port <- yml$options$port
        yml_engine_type <- yml$engine

        if (yml_engine_type == "plumber") {
            # plumber only supports single entry file anyway
            dir <- dirname(dots$path)
            dots$path <- file.path(dir, yml$routes[[1L]])
        }
    }

    engine_type <- yml_engine_type %||%
        "plumber"

    host <- dots$host %||%
        yml_host %||%
        (if(engine_type == "plumber") {
            plumber::get_option_or_env("plumber.host")
         } else {
            NULL
        }) %||%
        "127.0.0.1"

    port <- dots$port %||%
        yml_port %||%
        (if (engine_type == "plumber") {
            plumber::get_option_or_env("plumber.port")
        } else {
            NULL
        }) %||%
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
            runner_compute = "hotwater_runner",
            type = engine_type
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

    if (!is.numeric(config$port) &&length(config$port) != 1L) {
        error_invalid_port(config$port)
    }

    if (is.numeric(config$host && length(config$host) != 1L)) {
        error_invalid_host(config$host)
    }

    if (
        is.null(config$type) ||
            !is.character(config$type) ||
            !nzchar(config$type) ||
            length(config$type) > 1L
    ) {
        error_invalid_engine_type(config$type)
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

is_server_yml <- function(path) {
    !is.null(path) &&
       length(path) >= 1L &&
        any(grepl(
            utils::glob2rx("*_server.ya?ml"),
            basename(path)
        ))
}