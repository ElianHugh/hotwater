# middleware for the engine, ensures that we can tell if the API is up and running,
# and that we can embed some javascript to autoreload local web pages using the API.

injection <- function(engine) {
    injection_lines <- readLines(
        system.file("middleware", "injection.html", package = "hotwater", mustWork = TRUE)
    )

    sprintf(
        paste(injection_lines, collapse = "\n"),
        engine$publisher$listener[[1L]]$url
    )
}

middleware <- function(engine) {
    js <- injection(engine)
    hook <- postserialise_hotwater(js)
    function(pr) {
        # remove hotwater from the api spec
        plumber::pr_set_api_spec(pr, function(spec) {
            spec$paths[["/__hotwater__"]] <- NULL
            spec
        })
        # the dummy path is needed for pinging the server from hotwater
        plumber::pr_get(
            pr,
            "/__hotwater__",
            function() "running",
            serializer = plumber::serializer_text(),
            preempt = "__first__"
        )
        plumber::pr_hook(
            pr,
            "postserialize",
            hook
        )
    }
}

postserialise_hotwater <- function(js) {
    function(value) {
        if (length(value$error) > 0L) {
            return(value)
        }
        if (grepl("text/html", value$headers[["Content-Type"]])) { # nolint: nonportable_path_linter.
            value$headers[["Cache-Control"]] <- "no-cache"
            value$body <- paste(c(value$body, js), collapse = "\n")
        }
        value
    }
}

publish_browser_reload <- function(engine) {
    # at the moment, the message itself is largely meaningless because we're faking the
    # protocol on the javascript side of things
    # may be worth getting a minimal protocol working down the line on the JS side so we can send
    # specific messages to the browser
    nanonext::send(engine$publisher, "HW::start")
}

is_plumber_running <- function(engine) {
    tryCatch(
        expr = {
            url <- sprintf(
                "%s:%s/__hotwater__",
                engine$config$host,
                engine$config$port
            )
            res <- httr2::resp_status(
                httr2::req_perform(httr2::request(url))
            )
            res == 200L
        },
        error = function(e) {
            FALSE
        }
    )
}
