directory_state_new <- function() {
    structure(
        c(
            `./R/cli.R` = 1713351338.43533,
            `./R/engine.R` = 1714355698.118,
            `./R/middleware.R` = 1714442271.41379,
            `./R/run.R` = 1714442886.78582,
            `./R/runner.R` = 1714442666.70149,
            `./R/utils.R` = 1712727597.68699,
            `./R/watcher.R` = 1714087706.17955,
            `./R/zzz.R` = 1714105127.99432,
            # new
            `./R/new.R` = 1714105127.99432
        ),
        class = c("POSIXct", "POSIXt")
    )
}

directory_state_old <- function() {
    structure(
        c(
            `./R/cli.R` = 1713351338.43533,
            `./R/engine.R` = 1714355698.118,
            `./R/middleware.R` = 1714442271.41379,
            # modified
            `./R/run.R` = 1714442722.35905,
            `./R/runner.R` = 1714442666.70149,
            `./R/utils.R` = 1712727597.68699,
            `./R/watcher.R` = 1714087706.17955,
            `./R/zzz.R` = 1714105127.99432,
            # deleted
            `./R/deleted.R` = 1714105127.99432
        ),
        class = c("POSIXct", "POSIXt")
    )
}

test_that("file watcher works", {
    changes <- get_changed_files(directory_state_old(), directory_state_new())
    expect_true(did_files_change(changes))
    expect_identical(
        sort(c("./R/run.R", "./R/deleted.R", "./R/new.R")),
        sort(changes)
    )
})

# todo, might be worth thinking about if its even worth testing the
# implementation details here
test_that("directory_state returns expected file state", {
    local({
        watcher_dir <<- withr::local_tempdir("testdir")
        writeLines("Hello world", file.path(watcher_dir, "hello.R"))
        writeLines("Bye world", file.path(watcher_dir, "bye.R"))
        file.create(file.path(watcher_dir, "empty.R"))
        state <- directory_state(watcher_dir, "*.gitignore")
        expect_length(state, 2L)
        expect_length(names(state), 2L)
        expect_s3_class(state, c("POSIXct", "POSIXt"))
    })
})
