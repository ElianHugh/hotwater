# this file contains the construction, destruction, and running of the engine.
# "engine" refers to the superclass that contains the configuration, runner,
# and publisher for the given hotwater. also, it's amusing to call it a "hotwater engine".

new_engine <- function(config) {
    stopifnot(is_config(config))
    structure(
        list2env(
            list(
                runner = NULL,
                config = config,
                publisher = nanonext::socket(
                    protocol = "pub",
                    listen = sprintf(
                        "ws://%s:%s",
                        config$host,
                        config$socket_port
                    ),
                    autostart = FALSE
                )
            )
        ),
        class = c("hotwater_engine", "environment")
    )
}

run_engine <- function(engine) {
    callback <- function(changes) {
        cli_file_changed(changes)
        teardown_engine(engine)
        buildup_engine(engine)
    }
    on.exit({ teardown_engine(engine) }) # nolint: brace_linter.

    cli_welcome()
    buildup_engine(engine)

    current_state <- directory_state(
        c(
            engine$config$entry_dir,
            engine$config$dirs
        ),
        engine$config$ignore
    )

    repeat {
        Sys.sleep(0.05) # todo, allow this to be configured at some point
        current_state <- watch_directory(
            engine,
            current_state,
            callback
        )
    }
}

kill_engine <- function(engine) {
    stopifnot(is_engine(engine))
    kill_runner(engine)
}

buildup_engine <- function(engine) {
    stopifnot(is_engine(engine))

    cli_server_start_progress(engine)
    res <- new_runner(engine)

    if (engine$publisher$listener[[1L]][["state"]] != "started") {
        start(engine$publisher$listener[[1L]])
    }

    if (!res) {
        cli::cli_progress_done(result = "failed")
    } else {
        publish_browser_reload(engine)
        cli::cli_progress_done()
    }

    cli_watching_directory(engine)
}

teardown_engine <- function(engine) {
    stopifnot(is_engine(engine))

    cli_server_stop_progress()
    resp <- kill_engine(engine)

    if (isTRUE(resp)) {
        cli::cli_process_done()
    } else {
        cli::cli_progress_done(result = "failed")
    }
}

is_engine <- function(x) {
    inherits(x, "hotwater_engine")
}