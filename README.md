# journeymaxx

Review a batch of user journeys from the terminal, next to a Claude Code session.

Claude writes journeys into a `.journeymaxx` file. You run `journeymaxx` in another pane and go
through them one at a time, instead of reviewing them in a doc.

## Install

Needs Python 3 (standard library only) on Linux or macOS. Talking to it also needs an
ElevenLabs API key (free plan is fine), and `ffmpeg` when the microphone is on the same machine.

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
| `t` | talk mode: it reads each journey out and you answer out loud (below) |
| `v` | say the message instead: enter stops, the transcript lands in the message box to fix or send. Inside the message box, ctrl+r adds more speech |
| ctrl+g or `e` | edit the title and body in `$VISUAL` / `$EDITOR` (vim by default) |
| `r` | reject, with an optional reason |
| `u` | put a journey back to pending |
| `d` | diff against the previous version |
| ↑↓ or `j` `k` | move through all journeys; `n` jumps to the next pending |
| space / `b` | scroll a long journey |
| `q` | quit |

## Talking to it

**Talk mode** (`t`, or start with `journeymaxx talk`) goes through the queue out loud. It reads
each pending journey, beeps, and listens. It stops listening when you pause, so you never touch
the keyboard:

| Say | What happens |
|---|---|
| "yes", "looks good", "perfect" | approved |
| "no", "drop it", "reject it, coaches never see that" | rejected (anything after "reject it" is the reason) |
| anything else ("no, step two should say…") | sent to Claude as your comment |
| "next" / "skip" | moves on, decides nothing |
| "again please", "say that again", "one more time" | reads it again |
| "undo", "go back" | puts your last decision back to pending |
| "stop" | ends talk mode (or esc) |

It chimes (rising for approved, falling for rejected, three notes for sent to Claude) and
reads the next one straight away. A one or two word answer ends after 0.7 seconds of quiet;
a longer one after 1.3, so a comment is not cut off while you think. When Claude
revises a journey or asks you something, talk mode reads that out too ("Number 4, revised.
Claude says: …"), so you and Claude go back and forth without leaving it. Space answers
before it finishes reading.

**One message**: `v` records you and puts what you said in the message box. Enter stops,
enter again sends. Inside the message box, ctrl+r adds more speech.

### Setup

1. Your speech goes to ElevenLabs speech-to-text (Scribe). Put an ElevenLabs API key in
   `~/.config/journeymaxx/elevenlabs_api_key` (`chmod 600`), or set `ELEVENLABS_API_KEY`.
   `journeymaxx transcribe some.mp3` checks it works.
2. Reading out uses a free voice: your browser's, `say` on macOS (Karen, Australian), `espeak`
   on Linux. On the mic page, pick the voice and the speed (1.5× to start) and press **Test**;
   the page remembers them. Australian voices are listed first, natural-sounding ones on top:
   Edge's "Natasha (Natural)" is the best free one, and on a Mac "Lee (Enhanced)" once you
   download it in System Settings > Accessibility > Spoken Content.
   `JOURNEYMAXX_TTS=elevenlabs` uses ElevenLabs instead (Charlie, Australian, at its top
   speed; `JOURNEYMAXX_VOICE` picks another voice id). That uses your ElevenLabs character quota, and the free plan runs out after about one
   batch a month.
3. Where the microphone and speaker are:
   - **On your own machine** (macOS, or Linux with PulseAudio): `ffmpeg` records.
     `JOURNEYMAXX_MIC_DEVICE` picks another input (`:1` on macOS).
   - **Over SSH**, the server has no sound card, so journeymaxx serves a page on
     `http://localhost:8737` and your browser listens and speaks. Forward the port (Cursor and
     VS Code do it on their own; otherwise `ssh -L 8737:localhost:8737 <host>`), open the page
     once, click **Enable microphone**, and leave the tab open. The top right of the TUI says
     `mic ready` once the page is connected. The page's button works like `v`.

   It picks the browser when `SSH_CONNECTION` is set or `ffmpeg` is missing. Force one with
   `JOURNEYMAXX_MIC=local` or `JOURNEYMAXX_MIC=browser`; `JOURNEYMAXX_MIC_PORT` changes the port.
   `JOURNEYMAXX_PAUSE` is how many seconds of quiet end an answer (1.3), and
   `JOURNEYMAXX_SHORT_PAUSE` a one or two word one (0.7).

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
| `journeymaxx transcribe FILE` | speech to text for an audio file; checks the ElevenLabs key |

`skill/SKILL.md` tells Claude how to run the loop.

## The file

`.journeymaxx` is JSON: each journey has `id`, `title`, `body`, `status` (`pending`, `approved`,
`changes_requested`, `rejected`), `approved_at`, `rejected_at`, `changes_requested_at`, and a
`history` of every comment, edit, revision and decision.

It is the nearest `.journeymaxx` above the current directory. With none, it is created at the
root of the main git checkout, so a session in a worktree and a reviewer in the main checkout
share one. Override with `-f PATH` or `JOURNEYMAXX_FILE`.
