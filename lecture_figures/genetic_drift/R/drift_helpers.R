# Shared helpers for the genetic drift lecture figures.

# Wright-Fisher drift: diploid population of N individuals (2N gene copies),
# no selection, mutation or migration, non-overlapping generations.
# Returns a data frame of allele frequency p per replicate and generation.
wf_drift <- function(N, p0, n_gen, n_rep) {
  out <- vector("list", n_rep)
  for (r in seq_len(n_rep)) {
    p <- numeric(n_gen + 1)
    p[1] <- p0
    for (g in seq_len(n_gen)) p[g + 1] <- rbinom(1, 2 * N, p[g]) / (2 * N)
    out[[r]] <- data.frame(rep = r, generation = 0:n_gen, p = p)
  }
  do.call(rbind, out)
}

# Text helper so annotations use the same family as the theme.
bb_text <- function(...) ggplot2::annotate("text", family = .bb512_font, ...)
