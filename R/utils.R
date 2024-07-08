`%nin%` <- Negate(`%in%`)

if (!exists("%||%", baseenv())) {
    `%||%` <- function(x, y) {
        if (is.null(x)) y else x
    }
}

`%|NA|%` <- function(x, y) { # nolint: object_name_linter.
    if (is.na(x)) y else x
}
