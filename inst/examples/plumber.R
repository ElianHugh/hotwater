#' @get /
#' @serializer html
function() {
    print("got here?")
    "Hello, world!"
    stop("oh no")
}

print('/foo')

warning("bar")

stop('oh no')