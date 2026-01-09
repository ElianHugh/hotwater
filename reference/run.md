# Start a hotwater engine

Start the hotwater engine, launching a plumber API that is restarted
whenever a file in the plumber API's folder is modified.

Extra directories can be specified to refresh the API when directories
other than the plumber folder are modified.

If a plumber endpoint returns an HTML response, when hotwater refreshes
the API, {hotwater} will also order a refresh of any webpage that is
using the API.

## Usage

``` r
run(path, dirs = NULL, port = NULL, host = NULL, ignore = NULL)
```

## Arguments

- path:

  path to plumber API file.

- dirs:

  **(optional)** a character vector of extra directories to watch for
  file changes. Paths are resolved from the current working directory,
  not the directory of the plumber API file.

- port:

  port to launch API on.

  If NULL, defaults to the `plumber.port` option. If the plumber option
  is undefined, the fallback value of
  [`httpuv::randomPort()`](https://rdrr.io/pkg/httpuv/man/randomPort.html)
  is used.

- host:

  host to launch API on.

  If NULL, defaults to the `plumber.host` option. If the plumber option
  is undefined, the fallback value of "127.0.0.1" is used.

- ignore:

  vector of file globs to ignore.

  If NULL, defaults to `c("*.sqlite", "*.git")`

## Details

To refresh the browser, a postserialize
[plumber::pr_hook](https://www.rplumber.io/reference/pr_hook.html) is
used to inject a websocket into the HTML client that listens for the
plumber server refresh.

## See also

[plumber::options_plumber](https://www.rplumber.io/reference/options_plumber.html),
[plumber::get_option_or_env](https://www.rplumber.io/reference/options_plumber.html),
plumber::serializer_html

## Examples

``` r
if (FALSE) { # interactive()
 # start a hotwater session on port 9999
 hotwater::run(
   path = system.file("examples", "plumber.R", package = "hotwater"),
   port = 9999L
 )
}
```
