# Dotenv V

Dotenv V is a package to parse environment files. It support reading in multiple environment files which are added to the process' environment variables upon load.

To use this package, import the module and call `load`:

```V
import dotenv
import os

// Loads `.env` file by default
parsed := dotenv.load() or { panic(err) }
assert os.getenv('KEY') == parsed['KEY']
```

To load one or more specific files:

```V
import dotenv
parsed := dotenv.load('./env_file', '/path/to/env') or { panic(err) }
```

## Syntax

The syntax for the env files should follow the Docker spec (https://docs.docker.com/compose/environment-variables/env-file/). At the time of writing, this boils down to:

- Lines starting with # are ignored
- Blank lines are ignored
- Each line is a key-value pair (no multi line). Values can be escaped:
  - `VAR=VAL` -> `VAL`
  - `VAR="VAL"` -> `VAL`
  - `VAR='VAL'` -> `VAL`
- Inline comments for unquoted values must be preceded with a space:
  - `VAR=VAL # comment` -> `VAL`
  - `VAR=VAL# not a comment` -> `VAL# not a comment`
- Inline comments for quoted values must follow the closing quote:
  - `VAR="VAL # not a comment"` -> `VAL # not a comment`
  - `VAR="VAL" # comment` -> `VAL`
- Quotes can be escaped with `\`:
  - `VAR='Let\'s go!'` -> `Let's go!`
  - `VAR="{\"hello\": \"json\"}"` -> `{"hello": "json"}`
- The `\n`, `\r`, `\t`, `\\` shell escape sequences are supported in double-quoted values:
  - `VAR="some\tvalue"` -> `some value`
  - `VAR='some\tvalue'` -> `some\tvalue`
  - `VAR=some\tvalue` -> `some\tvalue`

To see examples of how files are parsed, look at the `./env_test.v` and `.env` files.
