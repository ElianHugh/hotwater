

<!-- @format -->

# 🌡️💧 hotwater

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![hotwater status
badge](https://elianhugh.r-universe.dev/badges/hotwater.png)](https://elianhugh.r-universe.dev/hotwater)
[![Codecov test
coverage](https://codecov.io/gh/ElianHugh/hotwater/branch/main/graph/badge.svg)](https://app.codecov.io/gh/ElianHugh/hotwater?branch=main)
[![R-CMD-check](https://github.com/ElianHugh/hotwater/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ElianHugh/hotwater/actions/workflows/R-CMD-check.yaml)

<!-- badges: end -->

-   autoreload for plumber
-   auto-refresh the browser when a change is made
-   run from the commandline with the `/exec/hotwater` bash script

## Installation

You can install the development version of hotwater from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ElianHugh/hotwater")
```

## Example

Hotwater can be run via an R session:

``` r
hotwater::run(
    system.file("examples", "plumber.R", package = "hotwater"),
    port = 9999L
)
```

``` r
✔ Server running on <127.0.0.1:9999> [17ms]
→ Watching ./path/to/ for changes...
```

or a terminal using the bash script:

``` sh
hotwater -f my/plumber/api.R -p 9999
```

``` r
✔ Server running on <127.0.0.1:9999> [17ms]
→ Watching ./path/to/ for changes...
```
