% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/run.R
\name{run}
\alias{run}
\title{Start a hotwater engine}
\usage{
run(path, dirs = NULL, port = NULL, host = NULL, ignore = NULL)
}
\arguments{
\item{path}{path to plumber API file.}

\item{dirs}{(optional) a character vector of extra directories
to watch for file changes. Paths are resolved from the current working
directory, not the directory of the plumber API file.}

\item{port}{[default \code{\link[httpuv:randomPort]{httpuv::randomPort()}}] port to launch API on.

port can either be set explicitly, or it defaults to the
\code{plumber.port} option. If the plumber option is undefined, the fallback
value of \code{\link[httpuv:randomPort]{httpuv::randomPort()}} is used.}

\item{host}{[default "127.0.0.1"] host to launch API on.

host can either be set explicitly, or it defaults to the
\code{plumber.host} option. If the plumber option is undefined, the fallback
value of "127.0.0.1" is used.}

\item{ignore}{[default \code{c("*.sqlite", "*.git*")}] vector of file globs
to ignore.}
}
\description{
Start the hotwater engine, launching a plumber API
that is restarted whenever a file in the plumber API's folder is modified.

Extra directories can be specified to refresh the API when
directories other than the plumber folder are modified.

If a plumber endpoint returns an HTML response, when hotwater
refreshes the API, \{hotwater\} will also order a refresh of any
webpage that is using the API.
}
\details{
To refresh the browser, a postserialize \link[plumber:pr_hook]{plumber::pr_hook} is used to
inject a websocket into the HTML client that listens for the
plumber server refresh.
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
 # start a hotwater session on port 9999
 hotwater::run(
   path = system.file("examples", "plumber.R", package = "hotwater"),
   port = 9999L
 )
\dontshow{\}) # examplesIf}
}
\seealso{
\link[plumber:options_plumber]{plumber::options_plumber},
\link[plumber:options_plumber]{plumber::get_option_or_env}, \link[plumber:serializers]{plumber::serializer_html}
}
