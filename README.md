## READ ME

### Things to do each year:

- Look for references to the year (e.g. 2023) and change them to the current year.
- Check schedule times are OK. Edit the line: `savingsTimeSwitch <- with_tz(lubridate::as_datetime("2021-10-31 03:00:00"),"Europe/Copenhagen")`, which is in the `Index.Rmd` and `personalCalendar.R` files.
- Confirm that the times are correct by cross-referencing the outputs on the website with the official calendar.
- Edit the Instructors part of `Index.Rmd` to add/remove instructors as appropriate.
- Edit the Excel schedule `BB512_Schedule.xlsx` to put the instructors in the correct place.
- Style check: Run `styler::style_dir(filetype = "Rmd")`
- Spell check: use `SpellCheckScript.R`
- Rebuild GitHub site. (`Build Book` button in RStudio)

