# Board mechanics

Derive every query from the candidate profile (CV fills gaps). Do not reuse a baked stack or seniority. A product-manager or C++ profile must not force `role=swe` or `category=programming`.

Skip a source on CAPTCHA or a login wall; continue with the rest.

## Shared seeds

Build `term` strings from **Role target**, **Core stack**, **Focus**, and **Location**. Add exclude terms from **Hard filters**.

## HN Who Is Hiring

`https://hn.algolia.com/?query=who%20is%20hiring&sort=byDate&type=story`

The default Algolia query returns stale threads (2016–2020). Find the current month with a recency filter, then open that thread's comments:

```bash
# list recent "Who is hiring" threads, newest first
curl -s "https://hn.algolia.com/api/v1/search?query=who%20is%20hiring&tags=story&hitsPerPage=20&numericFilters=created_at_i%3E1750000000"
# fetch the latest thread's comments (replace <objectID>)
curl -s "https://hn.algolia.com/api/v1/items/<objectID>"
```

Search inside the comments with words from the profile (titles, skills, location). Thread-style text; trivial to parse.

## Wellfound

`https://wellfound.com/jobs`

Direct job-post pages are lightweight HTML. Map **Role target** onto Wellfound's role/level controls when they fit (for example SWE vs design vs product). Map **Location** onto location filters. Do not default to `role=swe` or `level=senior+`.

## We Work Remotely

`https://weworkremotely.com/remote-jobs/search?term=<query>`

Put profile-derived seeds in `term`. Add a category query param only when the profile clearly matches one (programming, product, marketing, …).

The search page is server-rendered but the listing markup is not `span.title`/`span.company`. Each posting is an `<a class="listing-link--unlocked" href="/remote-jobs/<slug>">` anchor; the title and company are nested inside that anchor's body. Parse the anchors, then open the detail page for the JD. Many WWR postings are "Anywhere in the World" but some restrict region (e.g. LATAM & Europe) — read the detail page's Region field before ranking.

## Work at a Startup (YC)

`https://www.workatastartup.com/jobs`

Filter with profile-derived function and location. Do not default to `engineering` or `senior+`.

## Get on Board

`https://www.getonbrd.com/search/jobs` is dead (404). The real entry points are the category pages:

- Programming: `https://www.getonbrd.com/jobs/programming`
- Machine Learning & AI: `https://www.getonbrd.com/jobs/machine-learning-ai`
- SysAdmin / DevOps / QA: `https://www.getonbrd.com/jobs/sysadmin-devops-qa`

English and Spanish postings. Add `remote=true` or seniority params only when the profile asks for them.

**JS-rendered.** The category pages return raw HTML with no job-detail links — only category/tag/city navigation. The actual job URLs are embedded in the page as `https://www.getonbrd.com/jobs/<category>/<slug>` links; grep them out of the HTML, then open each detail page in the browser to read the JD (the detail body is also JS-rendered).

**CRITICAL — "Remote" is frequently a lie.** GOB labels many postings "Remote" but the detail page's "Remote work policy" section says *Locally remote only* with a residency restriction (e.g. "candidates must reside in Chile, Argentina, Peru or Colombia", or "Argentina and Peru"). A title can look like a perfect match and still be ineligible. You MUST open each detail page and read the policy before ranking. Filter out any posting whose residency list excludes the candidate's location.

## Direct company feeds

Poll `${HERMES_SKILL_DIR}/references/target-companies.json`. Do not copy it to `$home`. Do not edit it during a hunt.

Schema per entry: `name`, `careers_url`, `board_type` (`greenhouse` / `lever` / `ashby` / `custom`), optional `board_slug`, optional `why_target`.

- Greenhouse: the HTML board pages (`https://boards.greenhouse.io/<board_slug>`) and `.atom` feeds 404 for many companies. Use the JSON API instead: `https://boards-api.greenhouse.io/v1/boards/<board_slug>/jobs` (returns `{"jobs":[{title, location, ...}]}`). Some slugs still 404 on the API (e.g. supabase, render, neon, notion, sentry, hashicorp, pulumi, cal) — skip those and continue.
- Lever: `https://jobs.lever.co/<board_slug>` 404s for some companies. Use the JSON API: `https://api.lever.co/v0/postings/<board_slug>?mode=json`. Skip on 404.
- Ashby: `https://jobs.ashbyhq.com/<board_slug>` (some expose JSON)
- Custom: parse `careers_url` as HTML or a documented JSON/RSS feed
