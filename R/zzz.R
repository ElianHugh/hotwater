.onLoad <- function(...) {
    ns <- asNamespace("hotwater")
    if (is.null(ns[["hotwater"]])) {
        ns[["hotwater"]] <- new.env(parent = ns)
    }
}
