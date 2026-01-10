watch_directory <- function(engine, current_state, callback) {
    paths <- c(
        engine$config$entry_dir,
        engine$config$dirs
    )
    next_state <- directory_state(paths, engine$config$ignore)
    changed_files <- get_changed_files(current_state, next_state)


    if (did_files_change(unique(unlist(changed_files)))) {
        callback(changed_files)
        return(next_state)
    }
    current_state
}

get_changed_files <- function(current_state, next_state) {
    new <- names(next_state[names(next_state) %nin% names(current_state)])
    removed <- names(current_state[names(current_state) %nin% names(next_state)])
    modified <- names(next_state[next_state %nin% current_state])
    list(new = new, removed = removed, modified = modified)
}

did_files_change <- function(...) {
    length(as.list(...)) > 0L
}

directory_state <- function(paths, ignore_pattern) {
    res <- file.info(
        list.files(paths, full.names = TRUE, recursive = TRUE, all.files = TRUE),
        extra_cols = FALSE
    )
    res <- res[grep(pattern = ignore_pattern, x = row.names(res), invert = TRUE), ]
    res <- res[res$size > 0L, ]
    stats::setNames(res$mtime, row.names(res))
}
