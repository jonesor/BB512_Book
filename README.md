## READ ME

### Build workflow

- Build the book: run `_build.sh` (renders the gitbook).
- Build from RStudio: open `BB512_Book.Rproj`, then use the `Build Book` button in the Build pane.
- Build from the RStudio Console (HTML + PDF): run
  `bookdown::render_book("index.Rmd", "bookdown::gitbook")` and
  `bookdown::render_book("index.Rmd", "bookdown::pdf_book")`.
- Use `_clean.sh` to remove caches and generated artifacts before a clean rebuild.

### Build/release notes

- The published site is deployed automatically by the `Build Book` GitHub Actions
  workflow (`.github/workflows/build-book.yml`): every push to `main`/`master`
  builds the book and publishes it to GitHub Pages via
  `actions/deploy-pages`. Pull requests and scheduled runs only validate that
  the book builds; they do not publish.
- This requires the repository's Pages source (Settings > Pages) to be set to
  "GitHub Actions" rather than "Deploy from a branch".
- `bookdown::gitbook` output is written to `docs/` per `_bookdown.yml`. The
  committed copy of `docs/` is kept for local browsing/history only — it is
  no longer what GitHub Pages serves from, and no longer needs to be rebuilt
  and committed by hand to publish a change.

### Data provenance

- Generated datasets live in `data/` (see `data/README.md`).
- External datasets are linked from the relevant `.Rmd` files (e.g., Dropbox).

### QA

- Style check: `scripts/style.R`
- Lint: `scripts/lint.R`
- Spell check: `scripts/Check Spelling.R`

### Things to do each year:

- Look for references to the year (e.g. 2023) and change them to the current year.
- Check schedule times are OK and confirm that the times are correct by cross-referencing the outputs on the website with the official calendar.
- Edit the Instructors part of `index.Rmd` to add/remove instructors as appropriate.
- Edit the Excel schedule `BB512_Schedule.xlsx` to put the instructors in the correct place.
- No manual rebuild/publish step is needed — merging to `main`/`master` triggers an automatic build and deploy to GitHub Pages.
