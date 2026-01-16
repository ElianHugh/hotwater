# middleware for the engine, ensures that we can tell if the API is up and running,
# and that we can embed some javascript to autoreload local web pages using the API.

injection <- function(engine) {
    injection_lines <- readLines(
        system.file(
            "middleware",
            "hotwater-client.js",
            package = "hotwater",
            mustWork = TRUE
        )
    )
    sprintf(
        paste(injection_lines, collapse = "\n"),
        engine$publisher$listener[[1L]]$url
    )
}

publish_browser_reload <- function(engine) {
    json <- jsonlite::toJSON(
        list(type = "HW::page"),
        auto_unbox = TRUE
    )
    nanonext::send(engine$publisher, json, mode = "raw")
}

is_api_running <- function(engine) {
    tryCatch(
        expr = {
            url <- sprintf(
                "%s:%s/__hotwater__",
                engine$config$host,
                engine$config$port
            )

            req <- httr2::request(url)
            resp <- httr2::req_perform(req)
            status <- httr2::resp_status(resp)
            content <- httr2::resp_body_string(resp) |>
                as.integer()

            status == 200L && !is.na(content) && content == Sys.getpid()

        },
        error = function(e) {
            FALSE
        }
    )
}

postserialise_hotwater <- function(js) {
    function(value) {
        if (length(value$error) > 0L) {
            return(value)
        }
        if (grepl("text/html", value$headers[["Content-Type"]])) {
            # nolint: nonportable_path_linter.
            value$headers[["Cache-Control"]] <- "no-cache"
            value$body <- paste(c(value$body, js), collapse = "\n")
        }
        value
    }
}

middleware <- function(engine, ...) {
    UseMethod("middleware")
}

#' @exportS3Method
middleware.default <- function(engine, ...) {
    stop("Unsupported engine type")
}

#' @exportS3Method
middleware.plumber_engine <- function(engine, ...) {
    pid <- Sys.getpid()
    js <- '<script src="/__hotwater__/client.js"></script>'
    js_path <- injection(engine)

    hook <- postserialise_hotwater(js)

    function(pr) {
        # remove hotwater from the api spec
        plumber::pr_set_api_spec(pr, function(spec) {
            spec$paths[["/__hotwater__"]] <- NULL
            spec$paths[["/__hotwater__/client.js"]] <- NULL
            spec
        })
        # the dummy path is needed for pinging the server from hotwater
        plumber::pr_get(
            pr,
            "/__hotwater__",
            function() pid,
            serializer = plumber::serializer_text(),
            preempt = "__first__"
        )
        plumber::pr_get(
            pr,
            "/__hotwater__/client.js",
            function(req, res) {
                res$setHeader("Cache-Control", "no-store")
                js_path
            },
            serializer = plumber::serializer_content_type(
                "application/javascript",
                function(val) {
                    as.character(val)
                }
            )
        )
        plumber::pr_hook(
            pr,
            "postserialize",
            hook
        )
    }
}

#' @exportS3Method
middleware.plumber2_engine <- function(engine, ...) {
    pid <- Sys.getpid()
    js <- '<script src="/__hotwater__/client.js"></script>'
    js_path <- injection(engine)

    plumber_html_serialiser <- plumber2::get_serializers("html")[[1L]]

    function(api) {
        plumber2::register_serializer(
            "html",
            function(...) {
                function(x) {
                    x <- plumber_html_serialiser(x)
                    paste(as.character(unlist(c(x, js))), collapse = "\n")
                }
            },
            mime_type = "text/html",
            default = TRUE
        )

        plumber2::register_serializer(
            name = "javascript",
            function(...) {
                function(x) {
                    paste(as.character(unlist(x)), collapse = "\n")
                }
            },
            mime_type = "application/javascript"
        )

        api <- plumber2::api_add_route(
            api,
            "__hotwater__",
            after = 0L,
            root = ""
        )

        api <- plumber2::api_get(
            api,
            path = "/__hotwater__",
            handler = function(req, res) pid,
            serializer = plumber2::get_serializers("text"),
            route = "__hotwater__",
            use_strict_serializer = FALSE
        )
        api <- plumber2::api_get(
            api,
            path = "/__hotwater__/client.js",
            handler = function(response) {
                response$set_header("Cache-Control", "no-store")
                js_path
            },
            route = "__hotwater__",
            serializer = plumber2::get_serializers("javascript")
        )

        api
    }
}
