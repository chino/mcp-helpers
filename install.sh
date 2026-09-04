#!/usr/bin/env bash

# Symlink every helper in bin/ onto your PATH.
#
# Symlinks rather than copies, so `git pull` updates the installed commands and
# edits made through the link land back in the repo.

set -euo pipefail

TARGET="${TARGET:-$HOME/bin}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/bin" && pwd)"

dry=0
while [ $# -gt 0 ]; do
	case "$1" in
		-n|--dry-run) dry=1; shift ;;
		-t|--target)  TARGET="$2"; shift 2 ;;
		-h|--help)
			cat <<USAGE
usage: ${0##*/} [-n] [-t DIR]

  -n  dry run: show what would change, touch nothing
  -t  install directory (default: \$TARGET or ~/bin)
USAGE
			exit 0 ;;
		*) echo "unknown option: $1" >&2; exit 2 ;;
	esac
done

[ "$dry" -eq 1 ] || mkdir -p "$TARGET"

for src in "$SRC"/*; do
	[ -f "$src" ] || continue
	name="${src##*/}"
	dest="$TARGET/$name"

	# already pointing where we want it
	if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$src" ]; then
		echo "  ok       $name"
		continue
	fi

	# a real file here is someone's own copy; don't clobber it silently
	if [ -e "$dest" ] && [ ! -L "$dest" ]; then
		echo "  SKIP     $name (regular file exists at $dest; move it aside)" >&2
		continue
	fi

	if [ "$dry" -eq 1 ]; then
		echo "  would link $name -> $src"
	else
		ln -sfn "$src" "$dest"
		echo "  linked   $name -> $src"
	fi
done

case ":$PATH:" in
	*":$TARGET:"*) ;;
	*) echo "note: $TARGET is not on your PATH" >&2 ;;
esac
