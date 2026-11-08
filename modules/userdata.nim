import std/[json, os]

type
  UserData* = object
    highScore*: int
    gamesPlayed*: int
    questionsAnswered*: int
    correctAnswers*: int
    incorrectAnswers*: int

proc userDataPath(): string =
  currentSourcePath().parentDir / "json" / "userdata.json"

proc loadUserData*(): UserData =
  let path = userDataPath()
  if not fileExists(path):
    return UserData()

  let data = parseFile(path)
  if data.hasKey("highScore"):
    result.highScore = data["highScore"].getInt()
  if data.hasKey("gamesPlayed"):
    result.gamesPlayed = data["gamesPlayed"].getInt()
  if data.hasKey("questionsAnswered"):
    result.questionsAnswered = data["questionsAnswered"].getInt()
  if data.hasKey("correctAnswers"):
    result.correctAnswers = data["correctAnswers"].getInt()
  if data.hasKey("incorrectAnswers"):
    result.incorrectAnswers = data["incorrectAnswers"].getInt()

proc saveUserData*(data: UserData) =
  let jsonData = %*{
    "highScore": data.highScore,
    "gamesPlayed": data.gamesPlayed,
    "questionsAnswered": data.questionsAnswered,
    "correctAnswers": data.correctAnswers,
    "incorrectAnswers": data.incorrectAnswers
  }
  writeFile(userDataPath(), jsonData.pretty() & "\n")
