---
name: listen-for-work
description: "Scan remote jobs, rank matches, write a digest, and tailor a LaTeX CV to a job description. Use when hunting jobs, producing a weekly digest, adapting a CV to a JD, or importing a LinkedIn PDF."
version: 1.0.0
author: Luis Alejandro (@LuisAlejandro)
license: MIT
metadata:
  hermes:
    tags: [Jobs, Career, CV, Resume, Remote, Recruiting, LaTeX, ATS]
    config:
      - key: listen-for-work.home
        description: Directory for input CV, LinkedIn PDF, tailored output, job descriptions, and dated digests
        default: "~/listen-for-work"
        prompt: Home directory for CV data and weekly digests
      - key: listen-for-work.cv_number
        description: How many tailored CVs to generate per hunt (roles with score ≥80)
        default: "5"
        prompt: Number of CVs to generate per hunt
      - key: listen-for-work.digest_log
        description: Write the weekly digest to $home/digest/YYYY-MM-DD/
        default: "true"
        prompt: Write digest files to disk (true/yes/1)
    blueprint:
      schedule: "0 9 * * 1"
      deliver: all
      prompt: "NON-INTERACTIVE. Load listen-for-work. Run Phase 0 then Phases 1–4. Write the digest to disk when digest_log is on. The final response is that digest plus absolute CV PDF paths. Never prompt. Never call send_message."
      no_agent: false
---

# Listen for Work Skill

Weekly job hunt: scan clean-access boards, rank roles against a candidate profile, write a dated digest, and optionally tailor LaTeX CVs. Hermes delivers the digest to the user's configured messaging channels.

This skill does not apply on the user's behalf. It does not invent experience. It does not write cover letters. User CV files live under `listen-for-work.home`. The skill ships a XeLaTeX kit (fonts, Docker, placeholder `templates/cv/cv-base.tex`).

## When to Use

- User asks to scan jobs, run a job hunt, or produce a weekly jobs digest
- Scheduled Monday run via the bundled blueprint
- User asks to rank roles against their CV profile
- User asks to tailor, optimize, adapt, or review a CV for a company or JD
- User asks to import a LinkedIn PDF, or `$home/input/profile.pdf` is present

## Prerequisites

Read skill config injected at load (`listen-for-work.*`). Resolve:

| Setting | Fallback |
|---|---|
| `home` | `~/listen-for-work` |
| `cv_number` | `5`. Non-integers become 5. Values below 1 become 0 (no CVs that hunt) |
| `digest_log` | `true`. `true` / `yes` / `1` write `$home/digest/YYYY-MM-DD/job-digest.md` |

Derived paths:

| Role | Path |
|---|---|
| Input CV | `$home/input/cv-base.tex` |
| Profile | `$home/input/profile.md` |
| LinkedIn export | `$home/input/profile.pdf` |
| Tailored CV | `$home/output/<slug>/cv.tex` and `cv.pdf` |
| Job descriptions | `$home/job-descriptions/<slug>.md` |
| Target companies | `${HERMES_SKILL_DIR}/references/target-companies.json` |
| Digest | `$home/digest/YYYY-MM-DD/` when `digest_log` is on |

Run **Phase 0** first on every hunt, CV-only run, and Monday job. If `$home/input/profile.pdf` is missing: copy `${HERMES_SKILL_DIR}/references/candidate-profile.example.md` to `$home/input/profile.md` when that file is missing; copy **only** `${HERMES_SKILL_DIR}/templates/cv/cv-base.tex` to `$home/input/cv-base.tex` when that file is missing. Do not copy `references/target-companies.json` into `$home`. Do not edit that file during a hunt. Replace placeholders in the seeded profile and CV before the first real hunt if no PDF import ran. Rewrite `Path=./fonts/` to `Path=/work/fonts/` after a placeholder copy if the template still uses the relative path.

Tooling: `web_extract` / `web_search` for boards, `read_file` / `patch` for files, `terminal` for scripts and Docker.

## How to Run

Interactive hunt:

```
Use listen-for-work to scan this week's remote roles.
```

Interactive CV-only: user supplies a base CV path and a JD path (any names, any folders), or uses `$home/input` plus a company/JD.

Import-only:

```
Use listen-for-work to import my LinkedIn PDF.
```

Runs Phase 0 and stops. The final message names `$home/input/cv-base.tex` and `$home/input/profile.md` and whether they were rewritten or left.

Non-interactive: follow the blueprint prompt. Auto-resolve ties with the ranking defaults. Never ask questions.

## Quick Reference

| Step | Action |
|---|---|
| Import | Phase 0 from `$home/input/profile.pdf` when present |
| Profile | `read_file` `$home/input/profile.md` |
| Scan | Six clean-access sources + `references/target-companies.json` |
| Rank | Rubric below, criteria from the profile; keep ≥70 |
| Digest | `$home/digest/YYYY-MM-DD/job-digest.md` when `digest_log` is on |
| CVs | Up to `cv_number` roles with score ≥80, or one JD in CV-only mode |
| Chat | Final response is the digest; Hermes delivers it |

## Procedure

### Phase 0 — LinkedIn PDF import

`mkdir -p $home/input`. Full rules: `references/linkedin-import.md`. Do not scrape LinkedIn.

- **No** `$home/input/profile.pdf`: seed as in Prerequisites (example `profile.md` and placeholder `cv-base.tex` if missing). Continue.
- **PDF present:** import when **any** of: `cv-base.tex` missing; `cv-base.tex` contains `Your Name`; `profile.pdf` is newer than `cv-base.tex`; `profile.pdf` is newer than `profile.md` or `profile.md` is missing. Compare mtimes with `stat`. A newer PDF overwrites hand edits.
- Otherwise leave both files.

When importing: extract text with Docker Poppler (not a host `pdftotext`):

```bash
LISTEN_FOR_WORK_HOME="$home" \
  "${HERMES_SKILL_DIR}/templates/cv/compile.sh" --pdftotext
```

If that fails or prints nothing, `read_file` the PDF. Do not OCR a scanned export unless those two paths fail. Fill `${HERMES_SKILL_DIR}/templates/cv/cv-base.tex` into `$home/input/cv-base.tex` (keep preamble, macros, `/work/fonts/`). Write `$home/input/profile.md` from the example section list. Honesty: never invent jobs, dates, or metrics. Then continue to Phase 1 unless this is an import-only run.

### Phase 1 — Scan

Profile wins for search intent. After Phase 0, `read_file` `$home/input/profile.md`. Then `read_file` `$home/input/cv-base.tex` if it exists and does not contain `Your Name`. Build query seeds from **Role target**, **Core stack**, **Focus**, **Location**, and **Hard filters**. If a profile field is empty, take titles and skills from the CV. Never invent a default stack or seniority.

Apply location and excludes from the profile only. Do not assume remote-only, SWE, or a fitness/wellness exclude list unless the profile says so.

Sources (no CAPTCHA / auth walls). Map profile fields onto each board using `references/sources.md`. Do not force `role=swe`, `category=programming`, or senior/lead filters.

1. HN Who Is Hiring — `https://hn.algolia.com/?query=who%20is%20hiring&sort=byDate&type=story`
2. Wellfound — `https://wellfound.com/jobs`
3. We Work Remotely — `https://weworkremotely.com/remote-jobs/search?term=<query>`
4. Work at a Startup (YC) — `https://www.workatastartup.com/jobs`
5. Get on Board — `https://www.getonbrd.com/search/jobs`
6. Direct boards in `${HERMES_SKILL_DIR}/references/target-companies.json` (Greenhouse / Lever / Ashby / custom). Do not copy or write that file under `$home`.

### Phase 2 — Filter / Rank

Score 0–100. Criteria come from the profile (CV fills gaps):

| Axis | Weight | Criteria |
|---|---|---|
| Seniority fit | 25% | Titles and level from **Role target** (and CV header if needed). Penalty for levels the profile rejects |
| Tech overlap | 30% | **Core stack** plus skills listed in the CV, weighted by JD frequency |
| Focus fit | 20% | Alignment with **Focus** (whatever the profile states) |
| Location | 15% | **Location** and geo rules in the profile |
| Company signal | 10% | **Company signal** plus `why_target` from `references/target-companies.json` |

Thresholds: ≥80 top tier; 70–79 consider; <70 drop.

Dedupe: exact URL; same company + title within 14 days. Cross-posts keep the richer JD and note the other source.

### Phase 3 — Digest

Assemble the digest using the template in `references/digest-template.md`. When `digest_log` is on, create `$home/digest/YYYY-MM-DD/` and write `job-digest.md`. When it is off, skip the on-disk file. Always keep the digest text for the final chat message.

### Phase 4 — CV drafting

Hunt cap: up to `cv_number` roles with score ≥80 (tie-break: Focus fit, then company signal). CV-only mode: one role, no score gate.

`mkdir -p $home/input $home/output $home/job-descriptions`. Also `mkdir -p $home/digest` when `digest_log` is on. If `$home/input/cv-base.tex` does not exist after Phase 0, copy `${HERMES_SKILL_DIR}/templates/cv/cv-base.tex` to that path (the `.tex` file only). Interactive CV-only may use other paths the user names.

If `$home/input/cv-base.tex` still contains `Your Name`, skip Phase 4 in a hunt and note it in the digest. Interactive: ask the user to fill the template or pass their own file.

Act as a Talent Acquisition Director. Full layout and compile rules: `references/cv-build-env.md`.

1. **Gather.** `read_file` `$home/input/cv-base.tex` and the JD. Interactive CV-only: stop and ask if either path is missing. Hunt: slug the company (`anthropic`, `vercel`) and save the JD to `$home/job-descriptions/<slug>.md`.
2. **Analyze.** Extract core requirements, stack, architecture, and keywords. Note what to amplify and what to downplay.
3. **Workspace.** `mkdir -p $home/output/<slug>` and copy `$home/input/cv-base.tex` to `$home/output/<slug>/cv.tex`. Interactive: if that file exists, ask overwrite vs iterate. Non-interactive: overwrite.
4. **Edit with `patch`.** Honesty: never invent skills, metrics, or jobs. If the JD wants a missing skill, highlight the closest transferable one. Tone: skip dramatic filler (`spearheaded`, `delved`, `synergized`). Keep ATS headers (`Experience`, `Education`, `Skills`). Rewrite the summary to the JD. Reorder skills so the relevant ones come first. Rewrite 3–5 weak bullets with XYZ (accomplished X, measured by Y, by doing Z) or STAR. Match original character count (±15%). Set font `Path=` to `/work/fonts/IBMPlexSans/` and `/work/fonts/IBMPlexSerif/` (Docker mount of the skill kit). Escape `%`, `&`, `$`, `_` as `\%`, `\&`, `\$`, `\_`. Do not mask contact fields.
5. **Compile.** With `LISTEN_FOR_WORK_HOME` set to `$home`:
   ```bash
   LISTEN_FOR_WORK_HOME="$home" \
     "${HERMES_SKILL_DIR}/templates/cv/compile.sh" <slug>
   ```
   The script builds the image if it is missing, runs XeLaTeX, and removes the container. Confirm `$home/output/<slug>/cv.pdf` exists. Scan the `.log` for `Overfull \hbox` and shorten the offending line. One failed CV must not abort a hunt. Do not write files into the XeLaTeX kit.
6. **Deliver.** Hunt: add `**Tailored CV:**` plus `$home/output/<slug>/cv.pdf` under the digest pick. Interactive: return a recruiter review (6-second impression; ATS keywords added/removed; before/after bullets; formatting cuts; what was amplified) and end with that PDF path.

Caps: `cv_number` CVs per hunt; no cover letters.

### Phase 5 — Chat delivery

Skip for import-only and interactive CV-only runs (import report or recruiter review is the finale). Hunt runs always do this.

The digest text is the source of truth. When `digest_log` is on, that text also lives at `$home/digest/YYYY-MM-DD/job-digest.md`. The **final assistant message** is that digest, not a one-line stats summary. Cron/gateway `deliver` sends it; do not call `send_message`.

For each compiled CV, include the absolute path `$home/output/<slug>/cv.pdf` as plain text (not in backticks) so the gateway attaches the file. Omit a path when compile failed. End the message with `[[as_document]]`.

An empty qualifying list is still success: return the digest (stats and no qualifying roles). Hermes chunks long replies at platform limits (about 2000 characters on Discord).

## Pitfalls

- CAPTCHA / login walls: skip that source, continue.
- Stale board endpoints: Greenhouse HTML/`.atom` and Lever HTML 404 for many companies — use the JSON APIs in `references/sources.md`. GOB `/search/jobs` is dead; use the category pages.
- GOB "Remote" is often *locally remote only*: open each detail page and read the "Remote work policy" residency restriction before ranking; drop postings that exclude the candidate's location.
- GOB and WWR detail pages are JS-rendered: grep the job URLs out of the raw HTML, then open each detail page in the browser to read the JD.
- HN Algolia default query returns stale threads: use the recency filter in `references/sources.md` to find the current month.
- Unescaped `%` / `&` / `$` / `_` abort XeLaTeX.
- `\Large` tagline or long bullets overflow the margin. Keep `\normalsize` and ±15% length.
- Overfull `\hbox`: shorten the bullet; do not shrink margins.
- Hunt skipped CVs: `input/cv-base.tex` still contains `Your Name` and no import ran
- LinkedIn PDF present but ignored: mtimes say the PDF is older than both filled files.
- Empty qualifying list is still success when the final response is that digest (and the on-disk file, if `digest_log` is on).
- Do not call `send_message`; cron already delivers the final response.

## Verification

- When Phase 0 imported: `$home/input/cv-base.tex` has no `Your Name`, font `Path=` is `/work/fonts/…`, and `$home/input/profile.md` uses the example section headings
- Import-only finale names those two paths and whether they were rewritten
- When `digest_log` is on: digest exists at `$home/digest/YYYY-MM-DD/job-digest.md`
- Stats line matches scanned / unique / ≥80 / 70–79 counts
- Each top pick has score, source URL, and tailor cue
- When Phase 4 ran: `$home/output/<slug>/cv.tex` exists, font `Path=` entries are `/work/fonts/…`, and the PDF compiles without missing-font errors — or a logged compile error per miss
- No invented employers, titles, or metrics
- Interactive CV runs include the recruiter review; hunt runs log compile success or the error and continue
- Hunt finale is the digest text plus absolute PDF paths (not in backticks) and `[[as_document]]`

## References

- `references/linkedin-import.md` — Phase 0 LinkedIn PDF extract and mapping
- `references/candidate-profile.example.md` — profile template
- `references/target-companies.json` — shipped direct-poll list (do not copy to `$home`)
- `references/sources.md` — how to query each board
- `references/digest-template.md` — digest markdown
- `references/cv-build-env.md` — LaTeX / Docker compile and recruiter edit rules
- `templates/cv/cv-base.tex` — placeholder CV layout
- `templates/cv/compile.sh` — Docker XeLaTeX compile
- `templates/cv/Dockerfile`
- `templates/cv/docker-compose.yml`
- `templates/cv/fonts/IBMPlexSans/IBMPlexSans-Light.ttf`
- `templates/cv/fonts/IBMPlexSans/IBMPlexSans-Bold.ttf`
- `templates/cv/fonts/IBMPlexSans/OFL.txt`
- `templates/cv/fonts/IBMPlexSerif/IBMPlexSerif-Thin.ttf`
- `templates/cv/fonts/IBMPlexSerif/IBMPlexSerif-Light.ttf`
- `templates/cv/fonts/IBMPlexSerif/OFL.txt`
