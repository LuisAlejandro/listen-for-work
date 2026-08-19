# LaTeX CV build environment

User files live under `listen-for-work.home` (default `~/listen-for-work`):

- `$home/input/profile.pdf` — optional LinkedIn profile export. Phase 0 (see `linkedin-import.md`) rewrites the `.tex` and `.md` when this file is newer than them, when the CV is missing, or when the CV still contains `Your Name`.
- `$home/input/cv-base.tex` — the résumé to tailor. Filled from the PDF, or seeded from `templates/cv/cv-base.tex` if missing (the `.tex` file only).
- `$home/input/profile.md` — hunt profile. Filled from the PDF, or seeded from `references/candidate-profile.example.md` if missing.
- `$home/output/<slug>/cv.tex` and `cv.pdf` — per-company tailored copies
- `$home/job-descriptions/<slug>.md` — job-description text
- `$home/digest/YYYY-MM-DD/` — digest (when `digest_log` is on)

The XeLaTeX kit stays in the skill at `templates/cv/`:

- `fonts/IBMPlexSans/` and `fonts/IBMPlexSerif/`
- `compile.sh` + `docker-compose.yml` that compile with XeLaTeX inside Docker

Replace `Your Name` in `$home/input/cv-base.tex` before a real hunt, or drop `profile.pdf` so Phase 0 fills it. Interactive CV-only runs may use other paths the user names.

The bundled `cv-base.tex` is a layout template, not a personal résumé. Do not write generated CVs into `templates/cv/`.

## Recruiter edits

Persona: Talent Acquisition Director. Do not invent skills, metrics, employers, titles, or jobs. If the JD wants a missing skill, highlight the closest transferable one. Skip dramatic filler (`spearheaded`, `delved`, `synergized`). Keep ATS section headers (`Experience`, `Education`, `Skills`). Rewrite the summary to the JD. Reorder skills so the relevant ones come first. Rewrite 3–5 weak bullets with XYZ or STAR. Stay within ±15% of the original character count. Escape `%`, `&`, `$`, `_` as `\%`, `\&`, `\$`, `\_`.

## Document geometry

The bundled template uses letter paper and:

```latex
\usepackage[letterpaper, hmargin=1.2cm, vmargin=1.0cm]{geometry}
```

- Do not widen past 1.2cm / 1.0cm.
- Do not shrink below the base file's margins.
- If compile logs `Overfull \hbox`, shorten the bullet. Do not shrink margins.

## Contact info

Preserve every contact field from the base CV exactly: phone, email, URLs. Do not mask, truncate, or redact them.

## Header tagline size

Keep the header tagline at `\normalsize`, not `\Large`. A long tagline at `\Large` overflows the right margin.

## Bullet length

When rewriting bullets, stay within ±15% of the original character count. Split into two `\item[]` lines rather than one long line.

## Docker / compile.sh

Compile with `LISTEN_FOR_WORK_HOME` set to `$home`:

```bash
export LISTEN_FOR_WORK_HOME="$HOME/listen-for-work"
"${HERMES_SKILL_DIR}/templates/cv/compile.sh" --generate   # input/cv-base.tex
"${HERMES_SKILL_DIR}/templates/cv/compile.sh" --pdftotext  # input/profile.pdf → stdout
"${HERMES_SKILL_DIR}/templates/cv/compile.sh" acme         # output/acme/cv.tex
"${HERMES_SKILL_DIR}/templates/cv/compile.sh" --build acme # rebuild image first
```

The script builds the image if it is missing, runs XeLaTeX with `docker compose run --rm`, and removes the container. The user must be able to talk to Docker (`docker` group on Linux). After a group change, refresh the session. The container user is the host UID and GID (`id -u` and `id -g`).

Docker mounts the kit at `/work` and `$home` at `/data`.

## Font path

In `$home/input/cv-base.tex` and every `$home/output/<slug>/cv.tex`, set:

```latex
Path=/work/fonts/IBMPlexSans/
Path=/work/fonts/IBMPlexSerif/
```

Those paths are inside the container. After seeding the input file from the template, rewrite `Path=./fonts/` to `Path=/work/fonts/` if the copy still has the relative path.

## Compile log

After `xelatex`, scan the `.log` for:

- `Overfull \hbox` → shorten or split the bullet
- `Underfull \hbox` → rare cases are fine; rephrase if the line looks broken
- Missing fonts → font path fix above

## Common pitfalls

1. Docker unreachable: enable Linux integration in Docker Desktop, restart the distro.
2. Permission denied on docker.sock: add the user to `docker`, refresh the session.
3. XeLaTeX fatal error: unescaped `%`, `&`, `$`, or `_` in rewritten bullets.
4. Margin overflow: oversized header, narrower margins than the base, or bullets over 115% of original length.
5. Hunt skipped CVs: `input/cv-base.tex` still contains `Your Name` (no PDF import, or the PDF lacked a name).
6. `compile.sh` with no slug (and without `--generate` or `--pdftotext`) fails on purpose.
