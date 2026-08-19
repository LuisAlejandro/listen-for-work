# LinkedIn PDF import (Phase 0)

Drop a LinkedIn profile export at `$home/input/profile.pdf`. Nothing watches that folder. Phase 0 runs at the start of every hunt, CV-only run, and Monday job. Chat “import my LinkedIn PDF” runs Phase 0 and stops.

Do not scrape LinkedIn. Do not call the LinkedIn API.

## When to rewrite

`mkdir -p $home/input`. If `profile.pdf` is missing, seed placeholders (see SKILL.md Prerequisites) and continue.

If the PDF exists, import when **any** of:

- `$home/input/cv-base.tex` is missing
- that file contains `Your Name`
- `profile.pdf` is newer than `cv-base.tex`
- `profile.pdf` is newer than `profile.md`, or `profile.md` is missing

Otherwise leave both files. A newer PDF overwrites hand edits on purpose.

Compare mtimes with `test`:

```bash
pdf="$home/input/profile.pdf"
tex="$home/input/cv-base.tex"
md="$home/input/profile.md"

test "$pdf" -nt "$tex"   # PDF newer than tex (true if tex is missing)
test "$pdf" -nt "$md"    # PDF newer than md (true if md is missing)
grep -q 'Your Name' "$tex"  # only if tex exists
```

`test a -nt b` is true when `b` is missing.

## Extract

Prefer Poppler:

```bash
pdftotext -layout "$home/input/profile.pdf" -
```

If `pdftotext` is missing, `read_file` the PDF with Hermes. Do not OCR a scanned export unless those two paths fail.

Use the extracted text as the only source. LinkedIn PDFs are noisy (section labels, “Show more”, contact order). Keep facts; drop UI chrome.

## Write the CV

Start from `${HERMES_SKILL_DIR}/templates/cv/cv-base.tex`. Keep the preamble, geometry, macros (`\resumeItem`, `\resumeSubheading`), and `Path=/work/fonts/IBMPlexSans/` / `Path=/work/fonts/IBMPlexSerif/`. Write the result to `$home/input/cv-base.tex`. Do not write under `templates/cv/`.

Fill from the PDF only:

| Template | LinkedIn PDF |
|---|---|
| Header name | Profile name. Drop `Your Name` once the real name is in |
| Header tagline | Headline / current title, focus, domain, location if stated |
| Contact | Phone, email, LinkedIn URL, website **only if the PDF has them**. Omit fake `+1-555-0100` / `you@example.com` / `example.com` |
| About me | About / summary. One truthful paragraph |
| Skills | Skills and top tools. Group as Craft / Tools / Domain when the PDF supports it; otherwise one honest list |
| Experience | Each job: company, title, dates, location, bullets as written. Drop the Acme / Northwind / Foundry placeholders |
| Education | School, degree, dates, location if stated |

Certifications and Open source: include a section only when the PDF lists items. Otherwise omit those sections. Do not leave Example Cert or Example Project.

Escape `%`, `&`, `$`, `_` as `\%`, `\&`, `\$`, `\_`. Keep `\normalsize` in the header tagline.

## Write the profile

Write `$home/input/profile.md` with the same headings as `candidate-profile.example.md`:

| Section | Source |
|---|---|
| Role target | Headline and current title. Add reject-titles only if the PDF states them |
| Core stack | Skills / tools from the PDF. Comma-separated |
| Focus | About text (domain or craft). Leave empty if About is missing |
| Location | Only if the PDF states it |
| Hard filters | Empty unless the PDF clearly states excludes |
| Company signal | Empty unless the PDF clearly names target companies or kinds of orgs |

## Honesty

Never invent employers, titles, dates, metrics, skills, location, or contact fields. If a bullet is a fragment, copy it as a fragment. If dates are missing, omit them. Prefer fewer true lines over a filled template.

After a successful import, `cv-base.tex` must not contain `Your Name`.
