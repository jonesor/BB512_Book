# Slide 38: Standing variation and pesticide resistance.
# Deterministic haploid selection; no new mutations or drift are needed
# once the resistance allele is already present.
source("R/theme_bb512.R")

s <- 0.25
start_p <- 0.02
pesticide_at <- 15L
generations <- 50L
freq_R <- numeric(generations + 1L)
freq_R[1L] <- start_p
for (g in seq_len(generations)) {
  p_old <- freq_R[g]
  # Generation 15 marks the start of pesticide selection.
  if (g >= pesticide_at) {
    freq_R[g + 1L] <- p_old * (1 + s) / (p_old * (1 + s) + (1 - p_old))
  } else {
    freq_R[g + 1L] <- p_old
  }
}
df <- data.frame(generation = 0:generations, freq_R = freq_R)

p <- ggplot2::ggplot(df, ggplot2::aes(generation, freq_R)) +
  ggplot2::geom_vline(xintercept = pesticide_at, linetype = "dashed",
                      colour = bb512$clay, linewidth = 0.8) +
  ggplot2::geom_line(colour = bb512$forest, linewidth = 1.5) +
  ggplot2::annotate("text", x = pesticide_at + 1.1, y = 0.80,
                    label = "Pesticide introduced", hjust = 0,
                    colour = bb512$clay, size = 5.2) +
  ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
  ggplot2::labs(x = "Generations", y = "Resistance allele frequency") +
  theme_bb512()

save_bb512(p, "09_pesticide_resistance", layout = "half")
