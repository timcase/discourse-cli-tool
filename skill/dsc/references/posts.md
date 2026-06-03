# Posts

## List

```bash
dsc posts list
dsc posts list --json
```

## Show

```bash
dsc posts show ID
dsc posts show ID --json
```

## Create

```bash
dsc posts create --topic-id ID --raw "Reply content"
dsc posts create --topic-id ID                           # opens $EDITOR
echo "Reply" | dsc posts create --topic-id ID           # from stdin
```

Options: `--topic-id` (required), `--raw TEXT`

## Update

```bash
dsc posts update ID --raw "Edited content"
dsc posts update ID                                      # opens $EDITOR
echo "New content" | dsc posts update ID                # from stdin
```

Options: `--raw TEXT`

## Delete

```bash
dsc posts delete ID
```
