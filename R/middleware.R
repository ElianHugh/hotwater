injection <- function(engine) {
    system.file("middleware", "injection.html", package = "hotwater", mustWork = TRUE) |>
        readLines() |>
        paste0(collapse = "\n") |>
        sprintf(engine$publisher$listener[[1L]]$url)
}

middleware <- function(engine) {
    js <- injection(engine)
    hook <- postserialise_hotwater(js)
    function(pr) {
        pr |>
            # remove hotwater from the api spec
            plumber::pr_set_api_spec(function(spec) {
                spec$paths[["/__hotwater__"]] <- NULL
                spec
            }) |>
            # the dummy path is needed for pinging the server from hotwater
            plumber::pr_get(
                "/__hotwater__", function() "running",
                serializer = plumber::serializer_text(),
                preempt = "__first__"
            ) |>
            plumber::pr_hook("postserialize", hook)
    }
}

postserialise_hotwater <- function(js) {
    function(value) {
        if (length(value$error) > 0L) {
            return(value)
        }
        if (grepl("text/html", value$headers[["Content-Type"]])) {
            value$headers[["Cache-Control"]] <- "no-cache"
            value$body <- c(value$body, js) |>
                paste0(collapse = "\n")
        }
        value
    }
}

publish_browser_reload <- function(engine) {
    # at the moment, the message itself is largely meaningless because we're faking the
    # protocol on the javascript side of things
    # may be worth getting a minimal protocol working down the line on the JS side so we can send
    # specific messages to the browser
    nanonext::send(engine$publisher, "start")
}

is_plumber_running <- function(engine) {
    tryCatch(
        expr = {
            url <- sprintf(
                "%s:%s/__hotwater__",
                engine$config$host,
                engine$config$port
            )
            res <- httr2::request(url) |>
                httr2::req_perform() |>
                httr2::resp_status()
            res == 200L
        },
        error = function(e) {
            FALSE
        }
    )
}
