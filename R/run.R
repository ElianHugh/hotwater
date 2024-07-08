#' Start a hotwater engine
#'
#' @description
#'
#' Start the hotwater engine, launching a plumber API
#' that is restarted whenever a file in the plumber API's folder is modified.
#'
#' Extra directories can be specified to refresh the API when
#' directories other than the plumber folder are modified.
#'
#' If a plumber endpoint returns an HTML response, when hotwater
#' refreshes the API, \{hotwater\} will also order a refresh of any
#' webpage that is using the API.
#'
#' @details
#'
#' To refresh the browser, a postserialize [plumber::pr_hook] is used to
#' inject a websocket into the HTML client that listens for the
#' plumber server refresh.
#'
#' @param path path to plumber API file.
#'
#' @param dirs (optional) a character vector of extra directories
#' to watch for file changes. Paths are resolved from the current working
#' directory, not the directory of the plumber API file.
#'
#' @param port \[default [httpuv::randomPort()]] port to launch API on.
#'
#' port can either be set explicitly, or it defaults to the
#' `plumber.port` option. If the plumber option is undefined, the fallback
#' value of [httpuv::randomPort()] is used.
#'
#' @param host \[default "127.0.0.1"] host to launch API on.
#'
#' host can either be set explicitly, or it defaults to the
#' `plumber.host` option. If the plumber option is undefined, the fallback
#' value of "127.0.0.1" is used.
#'
#' @param ignore \[default `c("*.sqlite", "*.git*")`] vector of file globs
#' to ignore.
#'
#' @seealso [plumber::options_plumber],
#' [plumber::get_option_or_env], [plumber::serializer_html]
#'
#' @examplesIf interactive()
#'  # start a hotwater session on port 9999
#'  hotwater::run(
#'    path = system.file("examples", "plumber.R", package = "hotwater"),
#'    port = 9999L
#'  )
#'
#' @return NULL
#' @export
run <- function(path, dirs = NULL, port = NULL, host = NULL, ignore = NULL) {
    config <- new_config(
        path = path,
        dirs = dirs,
        port = port,
        host = host,
        ignore = ignore
    )
    validate_config(config)
    old <- hotwater$engine
    if (!should_reuse_engine(old$config, config)) {
        hotwater$engine <- new_engine(config)
    }
    run_engine(hotwater$engine)
}

should_reuse_engine <- function(old_config, config) {
    old_exists <- !is.null(old_config)
    same_path <- identical(old_config$entry_path, config$entry_path)
    same_dirs <- identical(old_config$dirs, config$dirs)
    same_port <- identical(old_config$port, config$port) || is.null(config$port)
    same_host <- identical(old_config$host, config$host) || is.null(config$host)
    same_ignore <- identical(old_config$ignore, config$ignore) || is.null(config$ignore)
    old_exists && same_path && same_port && same_dirs && same_host && same_ignore
}
