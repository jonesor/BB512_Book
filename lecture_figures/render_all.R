# Source this file to load commands; execute with Rscript to render figures.
.lecture_runner_file <- if (sys.nframe() > 0L) {
  tail(Filter(Negate(is.null), lapply(sys.frames(), function(frame) frame$ofile)), 1L)[[1L]]
} else {
  sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1L])
}

render_lecture <- local({
  root <- dirname(normalizePath(.lecture_runner_file, mustWork = TRUE))
  packages <- list(
    natural_selection = c("ggplot2", "ragg", "patchwork"),
    hardy_weinberg = c("ggplot2", "ragg", "dplyr", "tibble", "patchwork", "systemfonts"),
    inbreeding = c("ggplot2", "scales", "ragg", "patchwork"),
    mutation_genetic_variation = c("ggplot2", "scales", "ragg"),
    haploid_zygotic_selection = c("ggplot2", "scales", "ragg", "patchwork"),
    polygenic_quantitative_genetics = c("ggplot2", "scales", "ragg"),
    life_tables = c("ggplot2", "scales", "ragg", "patchwork", "png"),
    age_stage_structured_models = c("ggplot2", "scales", "ragg"),
    life_histories = c("ggplot2", "scales", "ragg"),
    sexual_selection = c("ggplot2", "ragg", "systemfonts")
  )

  function(lecture, script = NULL) {
    if (length(lecture) != 1L || !lecture %in% names(packages)) {
      stop("Choose a lecture: ", paste(names(packages), collapse = ", "))
    }
    missing <- packages[[lecture]][!vapply(
      packages[[lecture]], requireNamespace, logical(1), quietly = TRUE
    )]
    if (length(missing)) {
      stop("Install required packages first: install.packages(c(",
           paste(sprintf('"%s"', missing), collapse = ", "), "))")
    }
    lecture_dir <- file.path(root, lecture)
    if (lecture == "hardy_weinberg") {
      scripts <- file.path(lecture_dir, "generate_figures.R")
      work_dir <- dirname(root)
      if (!is.null(script)) stop("Hardy-Weinberg currently renders as one script.")
    } else {
      scripts <- sort(list.files(file.path(lecture_dir, "scripts"),
                                 pattern = "\\.R$", full.names = TRUE))
      work_dir <- lecture_dir
      if (!is.null(script)) {
        if (length(script) != 1L || !script %in% basename(scripts)) {
          stop("Choose a script: ", paste(basename(scripts), collapse = ", "))
        }
        scripts <- scripts[basename(scripts) == script]
      }
    }
    if (!length(scripts)) stop("No scripts found for ", lecture)
    old_wd <- getwd()
    old_rng_kind <- RNGkind()
    had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    if (had_seed) old_seed <- get(".Random.seed", envir = .GlobalEnv)
    on.exit({
      setwd(old_wd)
      do.call(RNGkind, as.list(old_rng_kind))
      if (had_seed) {
        assign(".Random.seed", old_seed, envir = .GlobalEnv)
      } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
        rm(".Random.seed", envir = .GlobalEnv)
      }
    }, add = TRUE)
    setwd(work_dir)
    for (file in scripts) {
      message("Generating ", lecture, "/", basename(file))
      # Reset for each script so results do not depend on execution order.
      # A script can override this default with its own documented seed.
      set.seed(512, kind = "Mersenne-Twister", normal.kind = "Inversion",
               sample.kind = "Rejection")
      env <- new.env(parent = globalenv())
      # Keep nested helper sources inside this script's environment as well.
      env$source <- local({
        target <- env
        function(file, local = target, ...) base::source(file, local = local, ...)
      })
      base::source(file, local = env, chdir = FALSE)
    }
    message("Finished ", lecture, ": ", lecture_dir)
    invisible(lecture_dir)
  }
})

render_lectures <- function() {
  for (lecture in c("natural_selection", "hardy_weinberg", "inbreeding",
                    "mutation_genetic_variation", "haploid_zygotic_selection",
                    "polygenic_quantitative_genetics", "life_tables",
                    "age_stage_structured_models", "life_histories",
                    "sexual_selection")) {
    render_lecture(lecture)
  }
  invisible(NULL)
}

rm(.lecture_runner_file)

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) == 0L || identical(args, "all")) {
    render_lectures()
  } else if (length(args) <= 2L) {
    render_lecture(args[1L], if (length(args) == 2L) args[2L] else NULL)
  } else {
    stop("Usage: Rscript lecture_figures/render_all.R [all | lecture [script.R]]")
  }
}
