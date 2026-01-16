# this file contains the runner of the hotwater engine.
# the "runner" is the subprocess that spawns the plumber API.

new_runner <- function(engine) {
    stopifnot(is_engine(engine))

    spec <- runner_spec(engine)

    mirai::daemons(
        n = 1L,
        dispatcher = FALSE,
        resilience = FALSE,
        autoexit = get_kill_signal(),
        output = FALSE,
        .compute = spec$compute
    )

    engine$runner <- spawn_runner(engine, spec)

    i <- 0L
    timeout <- 1000L

    repeat {
        i <- i + 1L
        try(
            cli::cli_progress_update(.envir = parent.frame(n = 1L)),
            silent = TRUE
        )

        if (
            i >= timeout || !is_runner_alive(engine) || is_api_running(engine)
        ) {
            break
        }

        Sys.sleep(0.1)
    }

    if (!is_runner_alive(engine) || !is_api_running(engine)) {
        return(FALSE)
    }

    TRUE
}

kill_runner <- function(engine) {
    stopifnot(is_engine(engine))
    mirai::daemons(0L, .compute = engine$config$runner_compute)
    !is_runner_alive(engine)
}

is_runner_alive <- function(engine) {
    stopifnot(is_engine(engine))
    mirai::unresolved(engine$runner)
}

get_kill_signal <- function() {
    tools::SIGKILL %|NA|%
        tools::SIGTERM %|NA|%
        tools::SIGINT
}

runner_spec <- function(engine) {
  list(
    port = engine$config$port,
    path = engine$config$entry_path,
    host = engine$config$host,
    mdware = middleware(engine),
    mod = file.path(getwd(), engine$config$entry_path),
    logpath = engine$logpath,
    compute = engine$config$runner_compute
  )
}

spawn_runner <- function(engine, spec, ...) {
    UseMethod("spawn_runner")
}

#' @exportS3Method
spawn_runner.plumber_engine <- function(engine, spec, ...) {
    mirai::mirai(
        {
            con <- file(logpath, open = "at")
            sink(con)
            sink(con, type = "message")

            on.exit(
                {
                    try(sink(type = "message"), silent = TRUE)
                    try(sink(), silent = TRUE)
                    try(close(con), silent = TRUE)
                },
                add = TRUE
            )

            withCallingHandlers(
                tryCatch(
                    {
                        if (requireNamespace("box", quietly = TRUE)) {
                            box::set_script_path(mod)
                        }
                        plumber::pr_run(
                            mdware(plumber::pr(path)),
                            port = port,
                            host = host,
                            quiet = TRUE,
                            debug = TRUE
                        )
                    },
                    error = function(e) {
                        cat("=== HOTWATER_ERROR_BEGIN ===\n", file = con)
                        cat(conditionMessage(e), "\n", file = con)
                        cat("=== HOTWATER_ERROR_END ===\n", file = con)
                        flush(con)
                        stop(e)
                    }
                ),
                warning = function(w) {
                    cat("=== HOTWATER_WARNING_BEGIN ===\n", file = con)
                    cat(conditionMessage(w), "\n", file = con)
                    cat("=== HOTWATER_WARNING_END ===\n", file = con)
                    flush(con)
                    invokeRestart("muffleWarning")
                }
            )
        },
        .args = list(
            port = spec$port,
            path = spec$path,
            host = spec$host,
            mdware = spec$mdware,
            mod = spec$mod,
            logpath = spec$logpath
        ),
        .compute = spec$compute
    )
}

#' @exportS3Method
spawn_runner.plumber2_engine <- function(engine, spec, ...) {
    mirai::mirai(
        {
            con <- file(logpath, open = "at")
            sink(con)
            sink(con, type = "message")

            on.exit(
                {
                    try(sink(type = "message"), silent = TRUE)
                    try(sink(), silent = TRUE)
                    try(close(con), silent = TRUE)
                },
                add = TRUE
            )

            withCallingHandlers(
                tryCatch(
                    {
                        if (requireNamespace("box", quietly = TRUE)) {
                            box::set_script_path(mod)
                        }
                        plumber2::api_run(
                            mdware(plumber2::api(path)),
                            port = port,
                            host = host,
                            block = TRUE,
                            showcase = FALSE,
                            silent = TRUE
                        )
                    },
                    error = function(e) {
                        cat("=== HOTWATER_ERROR_BEGIN ===\n", file = con)
                        cat(conditionMessage(e), "\n", file = con)
                        cat("=== HOTWATER_ERROR_END ===\n", file = con)
                        flush(con)
                        stop(e)
                    }
                ),
                warning = function(w) {
                    cat("=== HOTWATER_WARNING_BEGIN ===\n", file = con)
                    cat(conditionMessage(w), "\n", file = con)
                    cat("=== HOTWATER_WARNING_END ===\n", file = con)
                    flush(con)
                    invokeRestart("muffleWarning")
                }
            )
        },
        .args = list(
            port = spec$port,
            path = spec$path,
            host = spec$host,
            mdware = spec$mdware,
            mod = spec$mod,
            logpath = spec$logpath
        ),
        .compute = spec$compute
    )
}