% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/script.R
\name{uninstall_hotwater}
\alias{uninstall_hotwater}
\title{Uninstall global hotwater script}
\usage{
uninstall_hotwater(install_folder = "~/.local/bin/")
}
\arguments{
\item{install_folder}{[default "~/.local/bin/"] folder to uninstall hotwater
from.}
}
\description{
Uninstall global hotwater script
}
\examples{
if (interactive()) {
    hotwater::uninstall_hotwater()
}
}
\seealso{
\link{install_hotwater}
}
