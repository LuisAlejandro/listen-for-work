# Listen for Work

<img src="listen-for-work.gif" alt="It's not so much the looking as the listening. I listen for work." width="100%" />

> It's not so much the looking as the listening. I listen for work.

Finds jobs that match you, writes a weekly digest, and can tailor a LaTeX CV. Built for [Hermes](https://hermes-agent.nousresearch.com/); it follows the Agent Skills format, so it also runs in Claude Code, Cursor, Codex, OpenCode, and other harnesses that load `SKILL.md`.

## Prerequisites

- An agent that can load skills (Hermes, Claude Code, Cursor, Codex, OpenCode, and the rest)
- **[Docker](https://docs.docker.com/get-docker/)** — needed to compile tailored CV PDFs
- **Hermes only:** a messaging channel (Discord, Telegram, Slack, or another gateway) if you want the digest delivered there. Run `hermes gateway setup` (or `hermes setup`) and connect one.

## Install

Hermes:

```bash
hermes skills install LuisAlejandro/listen-for-work/listen-for-work
```

Restart Hermes or run `hermes skills list` and confirm `listen-for-work` is there.

Any harness (Claude Code, Cursor, Codex, OpenCode, and others):

```bash
npx skills@latest add LuisAlejandro/listen-for-work
```

## Get it working

**1. Drop your LinkedIn PDF.** In LinkedIn, export your profile as a PDF. Save it here:

```bash
mkdir -p ~/listen-for-work/input
# then save the file as:
# ~/listen-for-work/input/profile.pdf
```

**2. Run a hunt.** In chat:

```
Use listen-for-work to scan this week's remote roles.
```

The skill reads the PDF, fills your CV and hunt profile, scans job boards, and returns a digest. Docker compiles the tailored CV PDFs.

**3. Get it every Monday (optional, Hermes).** Installing the skill suggests a Monday 09:00 job. Accept it from `/suggestions` when you want a weekly run. The job delivers the digest to every connected home channel.

## Further configuration

Defaults are enough for the steps above. Change them only if you need to.

**Where files live.** Your data goes under `~/listen-for-work` (`input/`, `output/`, `job-descriptions/`, `digest/`). To use another folder in Hermes:

```bash
hermes config set skills.config.listen-for-work.home ~/listen-for-work
```

**How many CVs.** Default is 5 tailored CVs per hunt (roles scored 80 or above). Set `0` to skip CVs.

```bash
hermes config set skills.config.listen-for-work.cv_number 5
```

**Digest on disk.** By default the weekly digest is also written to `~/listen-for-work/digest/YYYY-MM-DD/job-digest.md`. Turn that off if you only want it in chat:

```bash
hermes config set skills.config.listen-for-work.digest_log false
```

**Import without hunting.** After you drop `profile.pdf`:

```
Use listen-for-work to import my LinkedIn PDF.
```

A newer PDF overwrites the CV and profile. If you skip the PDF, edit `~/listen-for-work/input/profile.md` and `~/listen-for-work/input/cv-base.tex` yourself (replace `Your Name` before a real hunt).

**Tailor one job.** Ask the agent to adapt your CV to a company or a job-description file. Docker must be running.

**CV PDFs in chat (Hermes).** If the files do not attach, add `~/listen-for-work/output` to `HERMES_MEDIA_ALLOW_DIRS`.

**Monday delivery (Hermes).** Default `deliver` is `all`. Point it at one channel with `hermes cron edit` (`discord:#jobs`, `telegram`, `origin`).

## Made with 💖 and 🍔

![Banner](https://raw.githubusercontent.com/Dockershelf/dockershelf/develop/images/author-banner.svg)

> Web [luisalejandro.org](http://luisalejandro.org/) · GitHub [@LuisAlejandro](https://github.com/LuisAlejandro) · Twitter [@LuisAlejandro](https://twitter.com/LuisAlejandro)
