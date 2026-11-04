import std/[json, os]

type
  Question* = object
    text*: string
    answers*: seq[string]
    correctAnswer*: string

proc loadQuestions*(): seq[Question] =
  let questionsPath = currentSourcePath().parentDir / "json" / "questions.json"
  let questionData = parseFile(questionsPath)

  for item in questionData["questions"].getElems():
    var question = Question(
      text: item["question"].getStr(),
      correctAnswer: item["correctAnswer"].getStr()
    )
    for answer in item["answers"].getElems():
      question.answers.add(answer.getStr())
    result.add(question)
