#' Start hotwater engine
#'
#' @description
#' Start a hotwater engine, which launches a plumber API that is restarted whenever
#' the plumber API's folder is modified.
#'
#' Extra directories can be specified to refresh the API when directories other than the plumber folder are modified.
#'
#' If a plumber endpoint returns an html response, when hotwater refreshes the API, hotwater will also order
#' a refresh of any webpage that is using the API.
#'
#' @param path path to plumber file
#' @param dirs extra directories to watch
#' @param port port to launch API on, defaults to `httpuv::randomPort()`
#' @param host host to launch API on, defaults to "127.0.0.1"
#' @param ignore vector of files or file extensions to ignore (globs)
#'
#' @examples
#' if (interactive()) {
#'  hotwater::run(system.file("examples", "plumber.R", package = "hotwater"))
#' }
#'
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
