import std/[json, os]

type
  UserData* = object
    highScore*: int
    gamesPlayed*: int

proc userDataPath(): string =
  currentSourcePath().parentDir / "json" / "userdata.json"

proc loadUserData*(): UserData =
  let path = userDataPath()
  if not fileExists(path):
    return UserData(highScore: 0, gamesPlayed: 0)

  let data = parseFile(path)
  result.highScore = data["highScore"].getInt()
  result.gamesPlayed = data["gamesPlayed"].getInt()

proc saveUserData*(data: UserData) =
  let jsonData = %*{
    "highScore": data.highScore,
    "gamesPlayed": data.gamesPlayed
  }
  writeFile(userDataPath(), jsonData.pretty() & "\n")
