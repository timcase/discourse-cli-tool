# Topics

## List

```bash
dsc topics list
dsc topics list --category announcements
dsc topics list --json | jq '.[].title'
```

## Show

```bash
dsc topics show ID
dsc topics show ID --json
```

## Create

```bash
dsc topics create --title "Hello World" --raw "Content here"
dsc topics create --title "Hello World" --category 4
dsc topics create --title "Hello World" --tags "tag1,tag2"
dsc topics create --title "Hello World"                      # opens $EDITOR
echo "Content" | dsc topics create --title "Hello World"    # from stdin
```

Options: `--title` (required), `--raw TEXT`, `--category ID`, `--tags TAG1,TAG2`

## Update

```bash
dsc topics update ID --title "New Title"
dsc topics update ID --raw "New content"       # edits first post, opens $EDITOR if omitted
dsc topics update ID --category 4
dsc topics update ID --title "New Title" --raw "New content"
```

Options: `--title TEXT`, `--raw TEXT`, `--category ID`

Note: `--category` takes an integer category ID (use `dsc categories list` to find IDs). Updating raw content edits the topic's first post.

When only `--title` or `--category` is given (no `--raw`, no piped stdin), content is left unchanged.

## Delete

```bash
dsc topics delete ID
```
