# Run from this directory:
#     Rscript render_all.R
# Or open this directory in RStudio and run source("render_all.R").

needed <- c("ggplot2", "scales", "ragg")
missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Please install packages before running:\n  install.packages(c(",
       paste(sprintf('"%s"', missing), collapse = ", "), "))")
}

source("R/theme_bb512.R"); source("R/drift_helpers.R")
scripts <- sort(list.files("scripts", pattern = "\\.R$", full.names = TRUE))
if (length(scripts) == 0) stop("No figure scripts found; run from the project directory")
for (script in scripts) {
  message("Generating ", script)
  source(script, local = new.env(parent = globalenv()))
}
message("Finished: PNG files are in figures/")
