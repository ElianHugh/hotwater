test_that("hotwater install/uninstall works", {
    skip_on_os("windows")
    local({
        hw_install_folder <- withr::local_tempdir("install_path")
        # should work first time
        expect_no_error(install_hotwater(hw_install_folder))
        # error because file already exists
        expect_error(
            install_hotwater(hw_install_folder),
            class = new_hotwater_error("install")
        )

        # work first time
        expect_no_error(uninstall_hotwater(hw_install_folder))
        # warning because no file exists
        expect_warning(
            uninstall_hotwater(hw_install_folder),
            class = new_hotwater_warning("not_installed")
        )
    })
})
