# middleware injection works

    Code
      injection(dummy_engine)
    Output
      [1] "<script>\n    (function() {\n        if (!document.getElementById('hotwater-reloader')) {\n            document.currentScript.id = \"hotwater-reloader\"\n            document.body.appendChild(document.currentScript)\n            var ws = new WebSocket('1234', ['pub.sp.nanomsg.org']);\n            ws.onmessage = () => {\n                window.location.reload();\n            };\n        } else {\n            var checker = document.currentScript;\n            checker.parentNode.removeChild(checker);\n        }\n    })();\n</script>"

