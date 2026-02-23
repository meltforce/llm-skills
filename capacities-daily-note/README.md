# Capacities Daily Note

A Claude Code skill that appends notes, tasks, and mixed content to today's daily note in [Capacities](https://capacities.io) via their API.

## Setup

### 1. Get a Capacities API token

Open Capacities > Settings > API and generate a token. You'll also need your **Space ID** (visible Space settings, uper left corner of the app).

### 2. Install the skill

Copy the `capacities-daily-note` folder into your Claude Code skills directory:

```bash
cp -r capacities-daily-note/ ~/.claude/skills/capacities-daily-note/
```

### 3. Configure credentials

The script resolves credentials in two tiers, trying each in order.

#### Option A: 1Password CLI (recommended)

Using [1Password CLI](https://developer.1password.com/docs/cli/get-started/) keeps secrets out of your shell environment and works across machines. The script calls `op read` at runtime — no plaintext secrets touch disk.

1. Install the `op` CLI: https://developer.1password.com/docs/cli/get-started/
2. Create a 1Password item (e.g. "Capacities API" in a vault called "Vault") with two fields:
   - `token` — your API token
   - `space_id` — your space UUID
3. If the vault or item names differ from the defaults, edit the references at the top of `scripts/save_to_daily_note.sh`:
   ```bash
   OP_TOKEN_REF="op://YourVault/YourItem/token"
   OP_SPACE_REF="op://YourVault/YourItem/space_id"
   ```

For headless / CI use, set up a [1Password Service Account](https://developer.1password.com/docs/service-accounts/get-started/) and export `OP_SERVICE_ACCOUNT_TOKEN` — no interactive sign-in required.

#### Option B: Environment variables

If you don't use 1Password, export these in your shell profile:

```bash
export CAPACITIES_API_TOKEN="your-api-token"
export CAPACITIES_SPACE_ID="your-space-id"
```

This works but means secrets live in your shell environment. Prefer 1Password if possible.

## Usage

```
/capacities-daily-note buy groceries, call dentist, review PR #42
/capacities-daily-note Meeting with Alex about Q3 budget. Action items: follow up on numbers, send proposal
/capacities-daily-note Just a quick note: the deploy went smoothly today
```

The skill auto-detects whether input is tasks, prose, or a mix, and formats accordingly (checkboxes, headings, paragraphs).

### Tagging

Every note is automatically appended with `#claude` so you can tell which daily note entries were created by the skill. To change the tag, edit the `TAG` variable at the top of `scripts/save_to_daily_note.sh`:

```bash
TAG="my-agent"   # appends #my-agent
TAG=""            # disables tagging
```

## Dependencies

- `curl` and `jq` (standard on most systems)
- `op` (1Password CLI) — optional, for credential resolution

## Limitations

- **Append-only** — cannot edit or delete existing daily note content
- **Today only** — always writes to today's daily note
- **No read-back** — cannot show what's currently in the daily note
- **No Task objects** — checkboxes render in Capacities but don't appear in Task Management
- **Rate limit** — 5 requests per 60 seconds
