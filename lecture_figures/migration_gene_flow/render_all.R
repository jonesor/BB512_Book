# Render this lecture through the shared runner.
local({
  files <- Filter(Negate(is.null), lapply(sys.frames(), function(frame) frame$ofile))
  file <- if (length(files)) tail(files, 1L)[[1L]] else {
    sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1L])
  }
  runner <- file.path(dirname(normalizePath(file)), "..", "render_all.R")
  base::source(runner, local = TRUE)
  render_lecture("migration_gene_flow")
})
