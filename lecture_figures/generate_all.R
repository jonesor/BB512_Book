# Generate every lecture when sourced in RStudio or executed with Rscript.
local({
  files <- Filter(Negate(is.null), lapply(sys.frames(), function(frame) frame$ofile))
  file <- if (length(files)) tail(files, 1L)[[1L]] else {
    sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1L])
  }
  runner <- file.path(dirname(normalizePath(file, mustWork = TRUE)), "render_all.R")
  message("Generating lecture figures using: ", runner)
  base::source(runner, local = TRUE)
  render_lectures()
})
