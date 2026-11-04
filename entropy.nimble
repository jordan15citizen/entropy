version = "0.1.0"
description = "A console-based question-and-answer game"
license = "UNLICENSED"
srcDir = "."
binDir = "build"
bin = @["main"]
installFiles = @["modules/json/questions.json", "modules/json/userdata.json"]

requires "nim >= 1.6.0"
