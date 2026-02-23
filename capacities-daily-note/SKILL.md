---
name: capacities-daily-note
description: >
  Append notes, tasks, logs, meeting notes, action items, or ideas to today's
  Capacities daily note. Use when the user wants to add to their daily note,
  log something to Capacities, capture tasks or todos, or says things like
  "log this", "add a task", "note this down" in the context of Capacities.
user-invocable: true
context: fork
allowed-tools: Bash, Read
argument-hint: "[note or tasks to add]"
---

# Capacities Daily Note Writer

Append content to today's daily note in Capacities via their REST API.

## Your task

Take the user's input from `$ARGUMENTS` and:

1. Determine the content type (note, tasks, or mixed)
2. Format it as markdown following the rules below
3. Call the save script to POST it to the API

## Parsing `$ARGUMENTS`

Detect intent from the input:

- **Tasks** — words like "task", "todo", "to-do", "action item", "checklist", or comma/newline-separated items that look like actionable work.
- **Notes** — words like "note", "log", "jot down", "remember", or prose paragraphs.
- **Mixed** — contains both prose and actionable items (e.g. meeting notes with action items).

If the intent is ambiguous, default to a plain note.

## Formatting rules

- **Tasks:** One `- [ ] Task text` per line. Convert comma-separated lists into individual checkboxes.
- **Notes:** Regular markdown paragraphs.
- **Tags:** Use Capacities wikilink syntax `[[Tag Name]]` when the user explicitly mentions tags.
- **Sections:** Use `## Heading` to separate logical blocks when there are distinct sections (e.g. meeting notes + action items).
- **Mixed content:** Put prose first, then a `## Action items` section with checkboxes.

### Examples

Tasks input: `buy groceries, call dentist, review PR #42`
```
- [ ] Buy groceries
- [ ] Call dentist
- [ ] Review PR #42
```

Mixed input: `Meeting with Alex about Q3 budget. Action items: follow up on budget numbers, send proposal by Friday`
```
Meeting with Alex about Q3 budget.

## Action items

- [ ] Follow up on budget numbers
- [ ] Send proposal by Friday
```

## Calling the script

Once you have formatted the markdown, run:

```bash
bash capacities-daily-note/scripts/save_to_daily_note.sh "YOUR_FORMATTED_MARKDOWN"
```

Pass the entire formatted markdown as a single quoted argument. The script handles authentication and the API call.

If the script exits non-zero, relay the error message to the user.

## Limitations

- **Append-only** — cannot edit or delete existing content in the daily note.
- **Today only** — always targets today's daily note; cannot write to past or future dates.
- **No read-back** — cannot confirm what was written or show current daily note content.
- **No real Task objects** — checkboxes render interactively in Capacities but do not appear in its Task Management system.
- **Rate limit** — 5 requests per 60 seconds. Avoid rapid repeated calls.
