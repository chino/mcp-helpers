# mcp-helpers

Launcher scripts and helpers for MCP servers.

## Contents

- `bin/chrome-devtools-mcp` — wrapper around `npx chrome-devtools-mcp`. Pins the
  browser binary, applies the flags needed to avoid being classified as an
  automated client, and tees stdio to log files for debugging. The script's
  header comments document the flag choices and how to recover from a
  Cloudflare challenge loop.

- `bin/cf-cookie-reset` — drops Cloudflare cookies (`cf_clearance`, `cf_chl_*`,
  `__cf_bm`, `__cflb`, `__cfruid`) for a domain from the chrome-devtools-mcp
  profile. `cf_clearance` is bound to the browser fingerprint it was issued
  against, so changing a fingerprint-affecting flag in the launcher invalidates
  existing tokens and the site starts looping on "Just a moment...". Deleting
  the stale cookie lets a fresh one be minted. Backs up the cookie DB first and
  refuses to run while a browser holds the profile.

  Requires `sqlite3`.

## Install

```sh
./install.sh          # symlinks bin/* into ~/bin
./install.sh -n       # dry run
./install.sh -t /usr/local/bin
```

Symlinks rather than copies, so `git pull` updates the installed commands. It
skips any name where a real file already exists rather than clobbering it.

Then point your MCP client at `chrome-devtools-mcp` as the stdio command.

## Typical recovery from a Cloudflare challenge loop

```sh
# 1. close the browser — it flushes cookies from memory on exit and would
#    silently undo the deletion
cf-cookie-reset -n example.com   # preview
cf-cookie-reset example.com      # delete
# 2. issue any MCP tool call; the browser relaunches and a fresh token is issued
```

Editing `bin/chrome-devtools-mcp` additionally requires an MCP reconnect
(`/mcp` in Claude Code), because the server process was started with the old
argv.
