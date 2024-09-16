# this file contains the runner of the hotwater engine.
# the "runner" is the subprocess that spawns the plumber API.

new_runner <- function(engine) {
    stopifnot(is_engine(engine))

    mirai::daemons(
        n = 1L,
        dispatcher = FALSE,
        resilience = FALSE,
        autoexit = get_kill_signal(),
        output = TRUE,
        .compute = engine$config$runner_compute
    )

    port <- engine$config$port
    path <- engine$config$entry_path
    mdware <- middleware(engine)
    mod <- file.path(getwd(), engine$config$entry_path)
    host <- engine$config$host

    engine$runner <- mirai::mirai(
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
        .args = list(
            port = port,
            path = path,
            host = host,
            mdware = mdware,
            mod = mod
        ),
        .compute = engine$config$runner_compute
    )

    i <- 0L
    timeout <- 1000L

    while (i < timeout && is_runner_alive(engine) && !is_plumber_running(engine)) {
        i <- i + 1L
        try(
            cli::cli_progress_update(.envir = parent.frame(n = 1L)),
            silent = TRUE
        )
        Sys.sleep(0.1)
    }

    if (i == timeout && !is_plumber_running(engine)) {
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
