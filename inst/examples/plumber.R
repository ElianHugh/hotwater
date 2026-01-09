#' @get /
#' @serializer html
function() {
    print("got here?")
    "Hello, world!"
    stop("oh no")
}

print('/foo')

message("foo")

rlang::abort("foo")
stop('oh no')