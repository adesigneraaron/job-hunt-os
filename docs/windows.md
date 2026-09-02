# Running on Windows

Short answer: **yes, with one extra install.**

## What you need

| | |
|---|---|
| Claude Code | Windows 10 (1809+) or later — [install instructions](https://code.claude.com/docs/en/setup) |
| **Git for Windows** | **Required.** [git-scm.com/downloads/win](https://git-scm.com/downloads/win) |
| A browser | Chrome, Edge, or Chromium. Edge is already installed on Windows, and works. |
| Python 3 | [python.org](https://www.python.org/downloads/) — tick **"Add python.exe to PATH"** in the installer |

**Git for Windows is the one that matters.** Without it, Claude Code runs
commands through PowerShell, and every script here is written for Bash. Git for
Windows supplies Git Bash, which Claude Code then uses automatically. Nothing to
configure — just install it before you start.

If Claude Code can't find it, point at it in your `settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
  }
}
```

## Then install as normal

```
/plugin marketplace add adesigneraaron/job-hunt-os
```
```
/plugin install job-hunt-os@job-hunt-os
```

Check everything's found:

```
/job-hunt-os:doctor
```

It reports which browser and which Python it located. If either is missing, it
names the fix.

## WSL works too

If you already use WSL, install Claude Code inside it and everything behaves
exactly as it does on Linux — no special handling needed. Your files live in the
Linux filesystem, so keep your `job-hunt/` folder there rather than reaching
across to `/mnt/c`.

Native Windows and WSL are both fine. Pick whichever your other work already
uses.

## Windows-specific notes

**Python is called `python`, not `python3`.** Handled automatically — the
scripts try `python3`, then `python`, then the `py` launcher. If yours lives
somewhere unusual:

```bash
export JOBHUNT_PYTHON="/c/Path/To/python.exe"
```

**Chrome in a non-standard location.** The scripts check Program Files, the
32-bit Program Files, and your per-user AppData folder, for both Chrome and
Edge. To point at something else:

```bash
export JOBHUNT_CHROME="/c/Path/To/chrome.exe"
```

**Paths are converted for you.** Git Bash writes paths as `/c/Users/you/...`,
but `chrome.exe` is a Windows program and doesn't understand that form — it
would produce a blank PDF with no error message. The renderer converts paths
before handing them over. You don't need to do anything, but if PDFs ever come
out blank, that's the first thing to suspect: run `/job-hunt-os:doctor`, which
warns when it sees a Windows browser without the conversion tool available.

**Antivirus and OneDrive.** If your project folder is inside OneDrive, PDF
rendering can fail intermittently while files sync. Keeping `job-hunt/` outside
OneDrive avoids it.

## If something breaks

Run `/job-hunt-os:doctor` first — it checks each dependency and names the fix.
Then see [troubleshooting.md](troubleshooting.md).

This has had less real-world use on Windows than on macOS. If you hit something
this page doesn't cover, please open an issue — that's genuinely useful.
