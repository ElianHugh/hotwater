#' @assets ./www /
list()

#' @get /
#' @serializer html
function() {
    '
    <!DOCTYPE html>
    <html lang="en-AU">
    <head>
        <link rel="stylesheet" href="./main.css"/>
    </head>
    <body>
        <p>Hello, world!</p>
    </body>
    </html>
    '
}
