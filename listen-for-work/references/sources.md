# Board mechanics

Derive every query from the candidate profile (CV fills gaps). Do not reuse a baked stack or seniority. A product-manager or C++ profile must not force `role=swe` or `category=programming`.

Skip a source on CAPTCHA or a login wall; continue with the rest.

## Shared seeds

Build `term` strings from **Role target**, **Core stack**, **Focus**, and **Location**. Add exclude terms from **Hard filters**.

## HN Who Is Hiring

`https://hn.algolia.com/?query=who%20is%20hiring&sort=byDate&type=story`

Open the latest monthly thread. Search inside it with words from the profile (titles, skills, location). Thread-style text; trivial to parse.

## Wellfound

`https://wellfound.com/jobs`

Direct job-post pages are lightweight HTML. Map **Role target** onto Wellfound's role/level controls when they fit (for example SWE vs design vs product). Map **Location** onto location filters. Do not default to `role=swe` or `level=senior+`.

## We Work Remotely

`https://weworkremotely.com/remote-jobs/search?term=<query>`

Put profile-derived seeds in `term`. Add a category query param only when the profile clearly matches one (programming, product, marketing, …).

## Work at a Startup (YC)

`https://www.workatastartup.com/jobs`

Filter with profile-derived function and location. Do not default to `engineering` or `senior+`.

## Get on Board

`https://www.getonbrd.com/search/jobs`

English and Spanish postings. Add `remote=true` or seniority params only when the profile asks for them.

## Direct company feeds

Poll `${HERMES_SKILL_DIR}/references/target-companies.json`. Do not copy it to `$home`. Do not edit it during a hunt.

Schema per entry: `name`, `careers_url`, `board_type` (`greenhouse` / `lever` / `ashby` / `custom`), optional `board_slug`, optional `why_target`.

- Greenhouse: `https://boards.greenhouse.io/<board_slug>` (many expose `.atom`)
- Lever: `https://jobs.lever.co/<board_slug>`
- Ashby: `https://jobs.ashbyhq.com/<board_slug>` (some expose JSON)
- Custom: parse `careers_url` as HTML or a documented JSON/RSS feed
