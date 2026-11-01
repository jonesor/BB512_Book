# Slide: "Previously: the Hardy-Weinberg principle" (Figure & Bullets, layout "half")
# Analytical: genotype frequencies p^2, 2pq, q^2 for a diallelic locus at HWE.
source("R/theme_bb512.R"); library(ggplot2)

p <- seq(0, 1, by = 0.005)
d <- rbind(data.frame(p, f = p^2,          g = "AA"),
           data.frame(p, f = 2 * p * (1 - p), g = "Aa"),
           data.frame(p, f = (1 - p)^2,    g = "aa"))
cols <- c(AA = bb512$forest, Aa = bb512$gold, aa = bb512$clay)

fig <- ggplot(d, aes(p, f, colour = g)) +
  geom_line(linewidth = 1.4) +
  annotate("text", x = c(0.93, 0.5, 0.07), y = c(0.75, 0.58, 0.75),
           label = c("AA", "Aa", "aa"), colour = cols[c("AA", "Aa", "aa")],
           size = 6, fontface = "bold", family = .bb512_font) +
  scale_colour_manual(values = cols, guide = "none") +
  scale_x_continuous(breaks = seq(0, 1, 0.25), labels = c("0", "0.25", "0.5", "0.75", "1")) +
  scale_y_continuous(breaks = seq(0, 1, 0.25), labels = c("0", "0.25", "0.5", "0.75", "1")) +
  labs(x = expression("Frequency of allele " * italic(A) * " (" * italic(p) * ")"),
       y = "Genotype frequency") +
  theme_bb512()
save_bb512(fig, "01_hardy_weinberg", layout = "half")
