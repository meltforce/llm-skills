# Skill Spec: Capacities Daily Note Writer

## Purpose

A Claude Skill that appends notes and tasks to today's daily note in Capacities via their REST API. Credentials are pulled from 1Password CLI (`op`).

## API Endpoint

**`POST https://api.capacities.io/save-to-daily-note`**

```json
{
  "spaceId": "<uuid>",
  "mdText": "- [ ] My task\n\nSome notes here",
  "origin": "commandPalette",
  "noTimeStamp": false
}
```

- **Auth:** `Authorization: Bearer <token>`
- **Rate limit:** 5 requests per 60 seconds
- **Max mdText length:** 200,000 chars
- **Markdown supported:** full (headings, bold, links, checkboxes, wikilinks like `[[Tag]]`)

## Credential Handling

Pull from 1Password CLI at runtime:

```bash
op read "op://Vault/Capacities API/token"
op read "op://Vault/Capacities API/space_id"
```

The exact vault and item names need to be configured by the user. The skill should document which 1Password fields are expected and let the user adjust the `op://` references.

## Skill Behavior

The skill should support the following use cases via natural language:

### 1. Append a note
User says something like: "Add to my daily note: Had a great idea about X..."
→ Sends markdown text to the daily note.

### 2. Create tasks
User says something like: "Add tasks to Capacities: buy groceries, call dentist, review PR #42"
→ Converts each item to `- [ ] item` and sends as a single request.

### 3. Mixed content
User says something like: "Log this to my daily note: Meeting with Alex. Action items: follow up on budget, send proposal"
→ Formats as a heading + prose + task checkboxes.

## Formatting Rules

- Tasks: `- [ ] Task text` (one per line)
- Notes: Regular markdown paragraphs
- Tags: Use Capacities wikilink syntax `[[Tag Name]]` when the user mentions tags
- Sections: Use `## Heading` to separate logical blocks
- Timestamp: Include by default (`noTimeStamp: false`), but allow user to opt out

## Implementation Details

- **Language:** Bash script (curl) or Python — keep it minimal, no heavy dependencies
- **Error handling:** Surface HTTP errors clearly (401 = bad token, 429 = rate limit, etc.)
- **No batching needed:** Single API call per user request (the endpoint is append-only)
- **Idempotency:** Not possible — the API is append-only with no dedup. The skill should warn if a request looks like a duplicate within the same conversation.

## Skill Triggering

Should trigger when the user wants to:
- Add notes, tasks, or logs to Capacities
- Write to their daily note
- Capture action items or todos in Capacities
- Log meeting notes or ideas to Capacities

Should NOT trigger for:
- General note-taking without mentioning Capacities
- Searching or reading from Capacities (not supported by API)
- Creating full Capacities objects (pages, weblinks, etc.)

## Limitations to Document

- **Append-only** — no editing or deleting existing content
- **Today's daily note only** — cannot target past or future dates
- **No real Task objects** — checkboxes render interactively in Capacities but don't appear in the Task Management system
- **No read-back** — cannot confirm what was written or check current daily note content
- **Rate limit** — 5 req/min, relevant if the user is doing bulk operations

## File Structure

```
capacities-daily-note/
├── SKILL.md          # Instructions + triggering description
└── scripts/
    └── save_to_daily_note.sh   # Curl-based script that handles op + API call
```

Keep it simple — one script, one skill file.
