---
name: journeymaxx
description: Put user journeys in front of Ori for review through the `journeymaxx` CLI instead of a doc, Basecamp comment or artifact. Use whenever you are writing or revising a batch of user journeys and Ori says "journeymaxx", "pass them by me", "I'll review in the cli", or is running journeymaxx alongside the session.
---

# journeymaxx

`journeymaxx` is Ori's terminal review queue for user journeys.
You queue journeys into a `.journeymaxx` JSON file; Ori runs `journeymaxx` in another pane and
goes through them one at a time: enter approves, `c` sends you a message (`v` to say it), ctrl+g edits the text
in vim, `r` rejects. You read what he did and revise.

## The loop

1. **Queue the batch.** One journey per chunk, chunks split by a `---` line, first line is the
   title. Do not number titles: the CLI numbers them (`#1`, `#2`, ...).

   ```bash
   journeymaxx add <<'EOF'
   Pick my sport
   - I open the app and pick **Football**.
   - My setup list shows the same steps as rugby.
   ---
   Upload my first game
   - I drag my footage in.
   EOF
   ```

   A JSON array of `{"title", "body"}` on stdin works too. `add` prints the file path and the
   exact `journeymaxx -f <path>` command: give Ori that line the first time.

2. **Wait for feedback.** `journeymaxx wait` blocks until Ori comments, edits or rejects
   something (or nothing is left pending), prints it, and marks it read. Run it in the
   background so you are woken when it exits. `journeymaxx feedback` prints the same without
   blocking; `--json` on either for structured output; `wait --timeout N` exits 2 when it passes.

3. **Act on each item, then wait again.**
   - `comment`: revise and resubmit. `journeymaxx revise 7 -m "what changed" <<< "new body"`
     (`--title` to change the title). It goes back to pending and Ori sees a diff.
   - Only when you need something from him (a question, pushback, or a contradiction with
     something he said or approved): `journeymaxx ask 7 "..."`. It goes back to pending.
   - `edited`: Ori rewrote it himself. Take the new text as final and apply the same change to
     the journeys still pending, so he does not have to make that edit twice.
   - `rejected`: drop it, silently. Do not resubmit, and do not send "Right, dropped" or any
     other acknowledgement: Ori does not want a rejected journey back in his queue (18 Nov
     2026). The one exception is `ask`, when the rejection raises a real question or
     contradicts something else. Follow-on changes you made elsewhere go in your chat reply.
   - `approved`: done.

4. **Finish.** When nothing is pending, `journeymaxx export` prints the approved journeys as
   markdown (`--status all` for everything) for the PRD, Basecamp or wherever they are going.

## Notes

- The file is the nearest `.journeymaxx` above the current directory; with none, it is created
  at the root of the main checkout, so a session in a worktree and Ori in the main checkout
  share one. `-f PATH` or `JOURNEYMAXX_FILE` overrides.
- Nothing reaches Ori's queue unless he has to decide something: new journeys, revisions, and
  `ask`. `journeymaxx reply ID "..."` only leaves a note on the thread (status unchanged) and
  is rarely worth using.
- Ori may speak a comment (`v`, ElevenLabs speech-to-text) instead of typing it. It arrives as a
  normal `comment`, but words can be misheard: read it for what he meant, and `ask` when a
  misheard word changes the meaning. If he says voice is not working, `journeymaxx transcribe
  FILE` checks the key, and the README's "Speaking a message" covers the mic setup.
- Never edit `.journeymaxx` by hand; go through the commands (they lock the file, and Ori's
  screen reloads as it changes).
- `journeymaxx list`, `journeymaxx show ID` (with its thread) for a look at the state. Each
  journey keeps `approved_at`, `rejected_at`, `changes_requested_at` and a full `history`.
- How Ori wants journeys written is in the `user-journeys-end-state-only` memory.
