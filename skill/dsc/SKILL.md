---
name: dsc
description: Manage Discourse forums from the command line — create and manage topics, posts, and categories using the dsc CLI. Use when working with a Discourse forum, creating posts or topics, managing categories, or any Discourse content task.
---

# dsc — Discourse CLI

`dsc` wraps the Discourse API. Install: `gem install discourse_cli_tool`

## Setup

```bash
dsc config set --site mysite --host https://forum.example.com --api-key KEY --api-username admin
dsc config list
```

Config precedence: CLI flags > `DISCOURSE_HOST` / `DISCOURSE_API_KEY` / `DISCOURSE_API_USERNAME` env vars > `~/.config/dsc/config.yml`

## Global flags

| Flag | Description |
|---|---|
| `--site NAME` | Use a named site from config |
| `--host URL` | Override host |
| `--api-key KEY` | Override API key |
| `--api-username USER` | Override API username |
| `--json` | Output raw JSON (pipe to jq) |
| `--quiet` | Suppress output, exit code only |

## Raw content (topics and posts)

Commands that accept `--raw` resolve content in this order:
1. `--raw "inline content"` — use directly
2. No flag, stdin is piped — read from stdin
3. No flag, interactive terminal — open `$EDITOR`

```bash
dsc topics create --title "Hello" --raw "Content"      # inline
echo "Content" | dsc topics create --title "Hello"     # stdin
dsc topics create --title "Hello"                      # opens $EDITOR
```

## Command reference

- **[references/categories.md](references/categories.md)** — list, show, create, update, delete categories
- **[references/topics.md](references/topics.md)** — list, show, create, update, delete topics
- **[references/posts.md](references/posts.md)** — list, show, create, update, delete posts
