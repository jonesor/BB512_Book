# Prints every number used on the slides and in the speaker notes (makes no figure).
# Deterministic discrete-time model, see R/lv_model.R. Parameter sets follow the book's
# solutions chapter (6_01_Solutions.Rmd, "Solutions: Lotka-Volterra competition").
source("R/theme_bb512.R"); source("R/lv_model.R")
show <- function(label, ...) {
  s <- lv_sim(...)
  cat(sprintf("%-38s t=50: (%7.1f, %7.1f)  t=200: (%7.1f, %7.1f)\n", label,
              s$N1[51], s$N2[51], s$N1[201], s$N2[201]))
}
cat("Worksheet defaults: equilibrium", lv_equilibrium(1200, 0.75, 1000, 0.5), "\n")
show("Defaults (100, 50)", 1, 1200, 0.75, 1, 1000, 0.5, 100, 50)
show("Q1 (50, 100)", 0.25, 3000, 1.25, 0.5, 1000, 0.5, 50, 100)
show("Q2 (50, 50)", 0.25, 3000, 2.25, 0.25, 2000, 0.25, 50, 50)
cat("Q3 equilibrium", lv_equilibrium(2500, 0.75, 2000, 0.5), "\n")
for (s in list(c(50, 50), c(1000, 1), c(1, 1000), c(500, 2500), c(1000, 3000), c(250, 3000)))
  show(sprintf("Q3 (%g, %g)", s[1], s[2]), 0.75, 2500, 0.75, 0.5, 2000, 0.5, s[1], s[2])
cat("Q4 equilibrium (unstable)", lv_equilibrium(1000, 1.25, 1000, 1.25), "\n")
for (s in list(c(50, 50), c(100, 50), c(50, 100), c(445, 444), c(444, 445)))
  show(sprintf("Q4 (%g, %g)", s[1], s[2]), 0.5, 1000, 1.25, 0.5, 1000, 1.25, s[1], s[2])
cat("Unequal case equilibrium (unstable)", lv_equilibrium(1000, 1.2, 1000, 1.3), "\n")
for (s in list(c(120, 160), c(100, 160)))
  show(sprintf("alpha 1.2, beta 1.3 (%g, %g)", s[1], s[2]), 1, 1000, 1.2, 1, 1000, 1.3, s[1], s[2])
for (s in list(c(100, 300), c(300, 100)))
  show(sprintf("Identical species (%g, %g)", s[1], s[2]), 0.5, 1000, 1, 0.5, 1000, 1, s[1], s[2])
cat("Rhizopertha/Oryzaephilus equilibrium", lv_equilibrium(330, 0.235, 440, 0.12), "\n")
cat("Tribolium equilibrium (unstable)", lv_equilibrium(220, 1, 340, 2.2), "\n")
for (s in list(c(100, 20), c(20, 100)))
  show(sprintf("Tribolium (%g, %g)", s[1], s[2]), 0.5, 220, 1, 0.5, 340, 2.2, s[1], s[2])
cat("Check question: K1 3000, alpha 1.25, K2 1000, beta 0.5 -> invade1:", 1.25 < 3000/1000,
    " invade2:", 0.5 < 1000/3000, "\n")
