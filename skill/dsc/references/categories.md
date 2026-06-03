# Categories

## List

```bash
dsc categories list
dsc categories list --json | jq '.[].name'
```

## Show

```bash
dsc categories show ID
```

## Create

```bash
dsc categories create --name "Announcements"
dsc categories create --name "Announcements" --color 0088CC --text-color FFFFFF
dsc categories create --name "Announcements" --description "Official announcements"
```

Options: `--name` (required), `--color HEX`, `--text-color HEX`, `--description TEXT`

## Update

```bash
dsc categories update ID --name "News"
dsc categories update ID --name "News" --color FF0000
```

Options: `--name` (required), `--color HEX`, `--text-color HEX`, `--description TEXT`

## Delete

```bash
dsc categories delete ID
```
