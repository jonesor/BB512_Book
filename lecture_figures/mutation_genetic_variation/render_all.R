# Compatibility entry point: render this lecture through the shared runner.
local({
  files <- Filter(Negate(is.null), lapply(sys.frames(), function(frame) frame$ofile))
  file <- if (length(files)) tail(files, 1L)[[1L]] else {
    sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1L])
  }
  runner <- file.path(dirname(normalizePath(file)), "..", "render_all.R")
  source(runner, local = TRUE)
  render_lecture("mutation_genetic_variation")
})
