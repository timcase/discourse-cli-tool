# discourse_cli_tool

Command-line interface for [Discourse](https://discourse.org), built on the [`discourse_api`](https://github.com/discourse/discourse_api) gem. Manage categories, topics, and posts from the terminal.

## Installation

```bash
gem install discourse_cli_tool
```

Or add to your Gemfile:

```ruby
gem "discourse_cli_tool"
```

## Configuration

### Quick setup

```bash
dsc config set --site mysite --host https://forum.example.com --api-key YOUR_KEY --api-username YOUR_USERNAME
```

This saves credentials to `~/.config/dsc/config.yml`. The first site added becomes the default.

### Multiple sites

```bash
dsc config set --site prod    --host https://forum.example.com    --api-key KEY1 --api-username admin
dsc config set --site staging --host https://staging.example.com  --api-key KEY2 --api-username admin

dsc config list
# prod (default)
#   host: https://forum.example.com
#   ...

dsc topics list --site staging
```

### Environment variables

```bash
export DISCOURSE_HOST=https://forum.example.com
export DISCOURSE_API_KEY=your_api_key
export DISCOURSE_API_USERNAME=your_username
```

### Precedence

CLI flags > environment variables > config file.

## Usage

### Categories

```bash
dsc categories list
dsc categories show 5
dsc categories create --name "Announcements" --color 0088CC
dsc categories update 5 --name "News" --color FF0000
dsc categories delete 5
```

### Topics

```bash
dsc topics list
dsc topics list --category announcements
dsc topics show 42
dsc topics create --title "Hello World"                  # opens $EDITOR
dsc topics create --title "Hello World" --raw "Content"  # inline content
echo "Content" | dsc topics create --title "Hello World" # from stdin
dsc topics update 42 --title "New Title"
dsc topics update 42 --raw "Updated content"
dsc topics delete 42
```

### Posts

```bash
dsc posts list
dsc posts show 123
dsc posts create --topic-id 42                # opens $EDITOR
dsc posts create --topic-id 42 --raw "Reply"  # inline content
dsc posts update 123 --raw "Edited content"
dsc posts delete 123
```

## Global flags

| Flag | Description |
|------|-------------|
| `--site NAME` | Use a named site from config |
| `--host URL` | Override host |
| `--api-key KEY` | Override API key |
| `--api-username USER` | Override API username |
| `--json` | Output raw JSON (for scripting) |
| `--quiet` | Suppress output, exit code only |

## Scripting

The `--json` flag outputs raw JSON suitable for piping to `jq`:

```bash
dsc topics list --json | jq '.[].title'
dsc categories list --json | jq '.[] | select(.name == "General") | .id'
```

## LLM Agent Skill

`dsc` ships with a skill file that teaches LLM coding agents (Claude Code, Codex, Gemini) how to use the CLI. Install it with:

```bash
dsc skill install           # installs for all three agents
dsc skill install --claude  # Claude Code only (~/.claude/skills/dsc)
dsc skill install --codex   # Codex only (~/.codex/skills/dsc)
dsc skill install --gemini  # Gemini CLI only (~/.gemini/skills/dsc)
```

The skill is installed as a symlink and updates automatically when you upgrade the gem.

## Requirements

- Ruby >= 2.7
- A Discourse instance with API access

## License

MIT
