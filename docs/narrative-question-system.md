# Narrative Question System

Документ описывает систему нарративных проверок, которая заменила математические примеры в `QuestPanel`.

## Назначение

Система показывает игроку вопрос и три варианта ответа после клика на персонажа через лупу.

Текущий игровой поток:

1. Игрок включает лупу.
2. Игрок кликает по персонажу на карте.
3. Открывается левое окно с информацией о персонаже.
4. Открывается `CanvasLayer/UIRoot/QuestPanel`.
5. Для выбранного персонажа берётся случайный вопрос из его конфига.
6. Игрок выбирает один из трёх ответов.
7. Правильный ответ увеличивает `Good` на `+1` и открывает `TeleportPanel`.
8. Неправильный ответ увеличивает `Evil` на `+1` и закрывает проверку.

## Основные файлы

Сцена:

- `scenes/main_scene.tscn`

Логика проверки:

- `src/game_logic/puzzle/main_quest_logic.gd`

Клики персонажей:

- `src/game_logic/characters/gnome_gome_left_menu.gd`
- `src/game_logic/characters/valentin_petrovich_left_menu.gd`

Ресурсы системы вопросов:

- `src/resources/narrative_question.gd`
- `src/resources/character_questions.gd`

Ресурсы персонажей:

- `resources/characters/gnome_gome.tres`
- `resources/characters/valentin_petrovich.tres`

Конфиги вопросов:

- `resources/questions/gnome_questions.tres`
- `resources/questions/valentin_questions.tres`

Счётчики:

- `src/resources/counters.gd`
- `src/counter/counter_logic.gd`
- `resources/counter.tres`

## Структура UI

Вопросы отображаются в:

```text
CanvasLayer/UIRoot/QuestPanel
```

Важные дочерние узлы:

```text
QuestPanel
|- QuestLogic
|- Panel
|  |- MarginContainer
|     |- VBoxContainer
|        |- TitleLabel
|        |- ProblemLabel
|        |- ResultLabel
|- Panel2
|  |- AnswerButton1
|- Panel3
|  |- AnswerButton2
|- Panel4
   |- AnswerButton3
```

`Panel2`, `Panel3`, `Panel4` расположены вертикально. Они не переименованы, потому что `main_quest_logic.gd` использует существующие пути:

```gdscript
$"../Panel2/AnswerButton1"
$"../Panel3/AnswerButton2"
$"../Panel4/AnswerButton3"
```

Если меняешь структуру `QuestPanel`, не переименовывай эти узлы без обновления путей в `main_quest_logic.gd`.

## Формат одного вопроса

Один вопрос описывается ресурсом `NarrativeQuestion`.

Файл:

```text
src/resources/narrative_question.gd
```

Поля:

```gdscript
@export_multiline var question_text: String = ""
@export var answers: Array[String] = []
@export_range(0, 2) var correct_answer_index: int = 0
```

Правила:

- `question_text` - текст вопроса.
- `answers` - список из трёх ответов.
- `correct_answer_index` - индекс правильного ответа.
- Индексы начинаются с нуля: `0`, `1`, `2`.

Пример:

```text
question_text = "A mirror shows three reflections. Which one is safe?"
answers = ["The reflection that blinks first", "The reflection holding the same map", "The reflection without a shadow"]
correct_answer_index = 1
```

В этом примере правильный ответ - второй вариант.

## Формат конфига персонажа

Набор вопросов персонажа описывается ресурсом `CharacterQuestions`.

Файл:

```text
src/resources/character_questions.gd
```

Поля:

```gdscript
@export var questions: Array[Resource] = []
```

В `questions` нужно добавить несколько `NarrativeQuestion`.

Текущие конфиги:

```text
resources/questions/gnome_questions.tres
resources/questions/valentin_questions.tres
```

## Связь персонажа с вопросами

Ресурс персонажа описывается `CharacterStats`.

Файл:

```text
src/resources/character.gd
```

В него добавлено поле:

```gdscript
@export var questions: CharacterQuestions
```

Каждый персонаж должен ссылаться на свой конфиг вопросов:

```text
resources/characters/gnome_gome.tres -> resources/questions/gnome_questions.tres
resources/characters/valentin_petrovich.tres -> resources/questions/valentin_questions.tres
```

## Как запускается вопрос

Скрипт персонажа при клике вызывает:

```gdscript
quest_logic.start_puzzle(CHARACTER.name, CHARACTER.questions)
```

Пример для Gnome Gome:

```gdscript
quest_logic.start_puzzle(GNOME_GOME.name, GNOME_GOME.questions)
```

`main_quest_logic.gd` получает имя персонажа и его конфиг вопросов, затем:

1. Проверяет, что конфиг существует.
2. Отбирает только валидные вопросы.
3. Случайно выбирает один вопрос.
4. Записывает текст вопроса в `ProblemLabel`.
5. Записывает ответы в `AnswerButton1`, `AnswerButton2`, `AnswerButton3`.
6. Сохраняет индекс ответа в `button.set_meta("answer_index", i)`.

## Проверка ответа

При нажатии на кнопку ответа:

```gdscript
var chosen_answer_index := int(button.get_meta("answer_index", -1))
var is_correct := chosen_answer_index == correct_answer_index
```

Если ответ правильный:

- вызывается таймерная награда;
- `counter.good += 1`;
- `QuestPanel` закрывается;
- `TeleportPanel` открывается.

Если ответ неправильный:

- `counter.evil += 1`;
- `QuestPanel` закрывается;
- `TeleportPanel` не открывается.

Отображение счётчиков уже реализовано в:

```text
src/counter/counter_logic.gd
```

Этот скрипт каждый кадр читает значения из `resources/counter.tres` и обновляет `Good` / `Evil` в UI.

## Валидация вопросов

Вопрос считается валидным, если:

- ресурс существует;
- `question_text` не пустой;
- в `answers` ровно 3 варианта;
- `correct_answer_index` находится в диапазоне ответов.

Если у персонажа нет валидных вопросов, `QuestPanel` покажет сообщение:

```text
No narrative question is configured for this character.
```

В консоль будет отправлен warning:

```text
main_quest_logic.gd: no valid questions for <character name>.
```

## Как добавить нового персонажа

1. Создай ресурс вопросов:

```text
resources/questions/new_character_questions.tres
```

2. Добавь в него несколько `NarrativeQuestion`.

Каждый вопрос должен иметь:

- текст вопроса;
- 3 варианта ответа;
- индекс правильного ответа `0`, `1` или `2`.

3. Открой ресурс персонажа:

```text
resources/characters/new_character.tres
```

4. В поле `questions` назначь:

```text
resources/questions/new_character_questions.tres
```

5. В скрипте клика персонажа вызови:

```gdscript
quest_logic.start_puzzle(NEW_CHARACTER.name, NEW_CHARACTER.questions)
```

После этого новый персонаж будет работать через ту же систему без изменений в `main_quest_logic.gd`.

## Что не нужно менять

Для добавления новых вопросов не нужно менять:

- `main_quest_logic.gd`;
- `counter_logic.gd`;
- `Counters`;
- `QuestPanel`, если хватает текущего UI;
- `TeleportPanel`.

Менять нужно только `.tres` ресурс вопросов и ссылку на него в `.tres` ресурсе персонажа.

## Частые ошибки

### Вопрос не появляется

Проверь:

- у персонажа заполнено поле `questions`;
- в конфиге есть хотя бы один вопрос;
- у вопроса заполнен `question_text`;
- в `answers` ровно 3 строки.

### Правильный ответ считается неправильным

Проверь `correct_answer_index`.

Индексация начинается с нуля:

```text
0 = первый ответ
1 = второй ответ
2 = третий ответ
```

### Кнопки не нажимаются

Проверь, что узлы ответов всё ещё находятся по путям:

```text
CanvasLayer/UIRoot/QuestPanel/Panel2/AnswerButton1
CanvasLayer/UIRoot/QuestPanel/Panel3/AnswerButton2
CanvasLayer/UIRoot/QuestPanel/Panel4/AnswerButton3
```

### Счётчики не меняются

Проверь:

- `resources/counter.tres` использует `src/resources/counters.gd`;
- `CanvasLayer/UIRoot/Counters` использует `src/counter/counter_logic.gd`;
- в `main_quest_logic.gd` используется тот же ресурс счётчика.
