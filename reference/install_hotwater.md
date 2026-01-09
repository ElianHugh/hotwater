# Install global hotwater script

If hotwater is installed, users may run `hotwater` from the command line
rather than from an R terminal.

## Usage

``` r
install_hotwater(install_folder)
```

## Arguments

- install_folder:

  folder to install hotwater script into. To run as expected, make sure
  that the folder supplied is on your `PATH` envar.

## See also

[uninstall_hotwater](https://elianhugh.github.io/hotwater/reference/uninstall_hotwater.md)

## Examples

``` r
if (FALSE) { # interactive()
 hotwater::install_hotwater()
}
```
