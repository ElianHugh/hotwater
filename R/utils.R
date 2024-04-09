`%nin%` <- Negate(`%in%`)

`%||%` <- function(x, y) {
    if (is.null(x)) y else x
}

`%|NA|%` <- function(x, y) {
    if (is.na(x)) y else x
}