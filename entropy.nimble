version = "1.1.0"
description = "A console-based question-and-answer game"
license = "GPL-3.0"
srcDir = "."
binDir = "build"
bin = @["entropy"]
installFiles = @["modules/json/questions.json", "modules/json/userdata.json"]

requires "nim >= 1.6.0"
