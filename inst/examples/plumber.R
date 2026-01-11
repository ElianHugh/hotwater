#' @assets ./www /
list()

#' @get /
#' @serializer html
function() {
    '
    <html>
    <head>
        <link rel="stylesheet" href="./main.css"/>
    </head>
    <body>
        <p>Hello, world!</p>
    </body>
    </html>
    '
}
