# Practical files

Spreadsheets and other files that students download from the BB512 book. The book links to them directly
(`https://github.com/jonesor/BB512_Book/raw/main/practical_files/<file>`), which works without a GitHub account.
Keep file names stable: renaming a file breaks its link in the book.

| File | Used in | Notes |
|---|---|---|
| `LV_competition_worksheet.xlsx` | Lotka-Volterra competition, Part 1 | Parameters, time column (t = 0 to 200), isocline ends and graphs ready; students type the formulas in B12 and C12 |
| `LV_competition_completed.xlsx` | Solutions: Lotka-Volterra competition | Completed sheet with the starting values; settles at (720, 640) |
| `LV_predator_prey_worksheet.xlsx` | Lotka-Volterra predator-prey dynamics, Parts 1, 3 and 4 | Built by `lecture_figures/lv_predation/build_worksheet.py`. Part 1: students type B12 and C12; Part 3 (prey K): students type the prey formula in B12; Part 4 (prey refuge): ready to use. 3000 rows (dt = 0.1 covers 300 time units) |
| `LV_predator_prey_completed.xlsx` | Solutions: Lotka-Volterra predator-prey dynamics | Completed sheet; dt = 1 gives (1050, 19.6) at t = 1 and prey extinction at t = 220 |
