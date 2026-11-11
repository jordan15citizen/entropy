import std/[os, parseopt, strformat, strutils, options]
import modules/[gamemode, questions, userdata]

func versionFromNimble(manifest: string): string =
  for line in manifest.splitLines():
    let versionLine = line.strip()
    if versionLine.startsWith("version = "):
      let parts = versionLine.split('"')
      if parts.len >= 3:
        return parts[1]
  raise newException(ValueError, "Could not find version in entropy.nimble")

const Version = versionFromNimble(staticRead("entropy.nimble"))

type
  Command = enum
    noCommand
    showHelp
    showInfo
    showUserData
    startGame

proc printHelp() =
  echo "Entropy " & Version
  echo "Usage: entropy <command> [options]"
  echo ""
  echo "Commands:"
  echo "  -i, --info                 Show application information"
  echo "  -h, --help                 Show this help"
  echo "  -s, --start                Start a game"
  echo "      --userdata, --data     Show saved user statistics"
  echo ""
  echo "Game options:"
  echo "  -g, --gamemode <mode>      Select regular, endless, or sudden-death"
  echo "  -d, -diff, --difficulty <level> Select easy, medium, or hard"
  echo ""
  echo "Examples:"
  echo "  entropy --start"
  echo "  entropy --start --gamemode=sudden-death"
  echo "  entropy -s -diff hard"

proc printInfo() =
  echo "Entropy " & Version
  echo "A console-based question-and-answer game."
  echo "Licensed under the GNU General Public License version 3."

proc printUserData() =
  let data = loadUserData()
  echo "Saved user statistics:"
  echo fmt"  High score: {data.highScore}"
  echo fmt"  Games played: {data.gamesPlayed}"
  echo fmt"  Questions answered: {data.questionsAnswered}"
  echo fmt"  Correct answers: {data.correctAnswers}"
  echo fmt"  Incorrect answers: {data.incorrectAnswers}"

proc main() =
  var
    command = noCommand
    selectedMode = interactiveMode
    selectedDifficulty = none(Difficulty)
    hasSelectedMode = false
    hasSelectedDifficulty = false
    modeValue = ""
    difficultyValue = ""
    arguments = commandLineParams()

  for i in 0 ..< arguments.len:
    if arguments[i] == "-diff":
      arguments[i] = "--difficulty"
    elif arguments[i].startsWith("-diff="):
      arguments[i] = "--difficulty=" & arguments[i][6 .. ^1]

  for kind, key, value in getopt(
      arguments,
      shortNoVal = {'h', 'i', 's'},
      longNoVal = @["help", "info", "start", "userdata", "data"],
      mode = GnuMode):
    case kind
    of cmdArgument:
      raise newException(ValueError, "Unexpected argument: " & key)
    of cmdShortOption, cmdLongOption:
      case key
      of "h", "help":
        if command != noCommand:
          raise newException(ValueError, "Choose only one command.")
        command = showHelp
      of "i", "info":
        if command != noCommand:
          raise newException(ValueError, "Choose only one command.")
        command = showInfo
      of "s", "start":
        if command != noCommand:
          raise newException(ValueError, "Choose only one command.")
        command = startGame
      of "userdata", "data":
        if command != noCommand:
          raise newException(ValueError, "Choose only one command.")
        command = showUserData
      of "d", "g", "gamemode":
        var parsedValue = value
        if kind == cmdShortOption and parsedValue.startsWith("="):
          parsedValue = parsedValue[1 .. ^1]
        if parsedValue.len == 0:
          let optionName = if key == "d": "--difficulty" else: "--gamemode"
          raise newException(ValueError, "The " & optionName & " option requires a value.")
        if key == "d":
          if hasSelectedDifficulty:
            raise newException(ValueError, "Specify the difficulty only once.")
          difficultyValue = parsedValue
          hasSelectedDifficulty = true
          continue
        if hasSelectedMode:
          raise newException(ValueError, "Specify the game mode only once.")
        modeValue = parsedValue
        hasSelectedMode = true
      of "difficulty":
        if value.len == 0:
          raise newException(ValueError, "The --difficulty option requires a value.")
        if hasSelectedDifficulty:
          raise newException(ValueError, "Specify the difficulty only once.")
        difficultyValue = value
        hasSelectedDifficulty = true
      else:
        raise newException(ValueError, "Unknown option: " & key)
    of cmdEnd:
      discard

  if hasSelectedMode:
    if command != startGame:
      raise newException(ValueError, "--gamemode can only be used with --start.")
    selectedMode = parseGameMode(modeValue)

  if hasSelectedDifficulty:
    if command != startGame:
      raise newException(ValueError, "--difficulty can only be used with --start.")
    selectedDifficulty = some(parseDifficulty(difficultyValue))

  case command
  of noCommand, showHelp:
    printHelp()
  of showInfo:
    printInfo()
  of showUserData:
    printUserData()
  of startGame:
    runGame(loadQuestions(), selectedMode, selectedDifficulty)

try:
  main()
except ValueError as error:
  stderr.writeLine("Error: " & error.msg)
  stderr.writeLine("Use 'entropy --help' for usage.")
  quit(2)
except IOError as error:
  stderr.writeLine("Input error: " & error.msg)
  quit(1)
