# 🌡️💧 hotwater

> \[!NOTE\] This package is under active development and its
> functionality may change over time.

- autoreload for plumber
- auto-refresh the browser when a change is made
- run hotwater from the commandline via included bash script

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
