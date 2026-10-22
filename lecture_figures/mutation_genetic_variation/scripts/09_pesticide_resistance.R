# Standing variation vs waiting for a new mutation.
# Haploid selection s = 0.25 after pesticide at generation 10.
# Standing: R allele already at 1e-3 (mutation-selection balance).
# New mutation: R absent; first successful mutation assumed to appear
# 40 generations later (waiting time depends on 2N*mu, cf. 2N-mu slide).
source("R/theme_bb512.R")

s <- 0.25; pest <- 10L; gens <- 120L
run <- function(p_start, arrival) {
  p <- numeric(gens + 1L)
  for (g in 0:gens) {
    i <- g + 1L
    if (g == 0) { p[i] <- p_start; next }
    prev <- p[i - 1L]
    if (g == arrival) prev <- max(prev, 1e-4)
    p[i] <- if (g > pest) prev * (1 + s) / (prev * (1 + s) + 1 - prev) else prev
  }
  p
}
df <- rbind(
  data.frame(g = 0:gens, p = run(1e-3, Inf), scenario = "Standing variation"),
  data.frame(g = 0:gens, p = run(0, pest + 40L), scenario = "New mutation needed")
)
df$scenario <- factor(df$scenario, c("Standing variation", "New mutation needed"))

p <- ggplot2::ggplot(df, ggplot2::aes(g, p, colour = scenario)) +
  ggplot2::geom_vline(xintercept = pest, linetype = "dashed",
                      colour = bb512$grey, linewidth = 0.7) +
  ggplot2::geom_line(linewidth = 1.5) +
  ggplot2::annotate("text", x = pest + 2, y = 0.97, hjust = 0,
                    label = "Pesticide", colour = bb512$grey, size = 5) +
  ggplot2::scale_colour_manual(values = c(bb512$forest, bb512$clay), name = NULL) +
  ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
  ggplot2::labs(x = "Generations", y = "Resistance allele freq.") +
  ggplot2::guides(colour = ggplot2::guide_legend(nrow = 2)) +
  theme_bb512()

save_bb512(p, "09_pesticide_resistance", layout = "half")
