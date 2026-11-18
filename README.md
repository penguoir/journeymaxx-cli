# journeymaxx

Review a batch of user journeys from the terminal, next to a Claude Code session.

Claude writes journeys into a `.journeymaxx` file. You run `journeymaxx` in another pane and go
through them one at a time, instead of reviewing them in a doc.

## Install

Needs Python 3 (standard library only) on Linux or macOS.

```sh
git clone https://github.com/penguoir/journeymaxx-cli && ./journeymaxx-cli/install.sh
```

This links `journeymaxx` into `~/.local/bin` and the Claude Code skill into
`~/.claude/skills/journeymaxx`, so `git pull` updates both.

## Reviewing

Run `journeymaxx`. It reloads as the file changes, so new and revised journeys appear while you
review.

| Key | What it does |
|---|---|
| enter | approve, go to the next pending journey |
| `c` | write a message to Claude (marks it "change requested") |
| ctrl+g or `e` | edit the title and body in `$VISUAL` / `$EDITOR` (vim by default) |
| `r` | reject, with an optional reason |
| `u` | put a journey back to pending |
| `d` | diff against the previous version |
| ↑↓ or `j` `k` | move through all journeys; `n` jumps to the next pending |
| space / `b` | scroll a long journey |
| `q` | quit |

## Commands for Claude

| Command | What it does |
|---|---|
| `journeymaxx add` | queue journeys from stdin: markdown chunks split by a `---` line (first line is the title), or a JSON array of `{"title", "body"}` |
| `journeymaxx wait` | block until a comment, edit or rejection arrives (or nothing is pending), print it, mark it read |
| `journeymaxx feedback` | the same without blocking |
| `journeymaxx revise ID -m "note"` | new text on stdin; back to pending, with a diff for the reviewer |
| `journeymaxx ask ID "..."` | a question or pushback the reviewer must answer; back to pending |
| `journeymaxx reply ID "..."` | a note on the thread; stays out of the review queue |
| `journeymaxx list`, `show ID`, `export` | look at the state; print approved journeys as markdown |

`skill/SKILL.md` tells Claude how to run the loop.

## The file

`.journeymaxx` is JSON: each journey has `id`, `title`, `body`, `status` (`pending`, `approved`,
`changes_requested`, `rejected`), `approved_at`, `rejected_at`, `changes_requested_at`, and a
`history` of every comment, edit, revision and decision.

It is the nearest `.journeymaxx` above the current directory. With none, it is created at the
root of the main git checkout, so a session in a worktree and a reviewer in the main checkout
share one. Override with `-f PATH` or `JOURNEYMAXX_FILE`.
