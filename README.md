## READ ME

### Build workflow

- Build the book: run `_build.sh` (renders the gitbook).
- Build from RStudio: open `BB512_Book.Rproj`, then use the `Build Book` button in the Build pane.
- Build from the RStudio Console: run `bookdown::render_book("index.Rmd")`.
- Use `_clean.sh` to remove caches and generated artifacts before a clean rebuild.

### Build/release notes

- The published site is served from `docs/` (GitHub Pages).
- `bookdown::gitbook` output is written to `docs/` per `_bookdown.yml`.

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
- Rebuild GitHub site. (`Build Book` button in RStudio)
