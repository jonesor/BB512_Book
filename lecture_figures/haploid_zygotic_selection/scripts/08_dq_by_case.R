# Slide "Dominance shifts the fastest change": size of the change per generation against the frequency of the
# FAVOURED allele (p = 1 - q), for Neal's Cases B, C, D, so the axis matches the next slide (09).
# Case C = favoured allele dominant; Case D = favoured allele recessive.
# Analytical (Neal Eqns 10.4-10.6, Fig. 10.3a), s = 0.1. Haploid model (Eqn 10.1) shown in grey for comparison.
source("R/theme_bb512.R"); source("R/models.R")
fam <- "Avenir Next"
s <- 0.1; qs <- seq(0, 1, by = 0.005)
df <- rbind(
  data.frame(q = qs, d = abs(haploid_dq(qs, s)), m = "Haploid"),
  data.frame(q = qs, d = abs(zygotic_dq(qs, "B", s = s)), m = "B"),
  data.frame(q = qs, d = abs(zygotic_dq(qs, "C", s = s)), m = "C"),
  data.frame(q = qs, d = abs(zygotic_dq(qs, "D", s = s)), m = "D"))
cols <- c(Haploid = bb512$grey, B = bb512$gold, C = bb512$forest, D = bb512$clay)
lab <- data.frame(m = c("Haploid", "B", "C", "D"),
  x = c(0.5, 0.5, 0.14, 0.86), y = c(0.0285, 0.0035, 0.0292, 0.0292),
  txt = c("Haploid", "No dominance", "Favoured dominant", "Favoured recessive"))
p <- ggplot2::ggplot(df, ggplot2::aes(1 - q, d, colour = m)) +
  ggplot2::geom_line(ggplot2::aes(linetype = m == "Haploid"), linewidth = 1.4) +
  ggplot2::annotate("segment", x = 0.5, xend = 0.5, y = 0.0048, yend = 0.0122, colour = bb512$gold, linewidth = 0.6) +
  ggplot2::geom_text(data = lab, ggplot2::aes(x, y, label = txt), family = fam, size = 5.1) +
  ggplot2::scale_colour_manual(values = cols, guide = "none") +
  ggplot2::scale_linetype_manual(values = c(`TRUE` = "dashed", `FALSE` = "solid"), guide = "none") +
  ggplot2::scale_x_continuous(breaks = seq(0, 1, 0.25)) +
  ggplot2::scale_y_continuous(limits = c(0, 0.031), breaks = seq(0, 0.03, 0.01)) +
  ggplot2::labs(x = "Frequency of the favoured allele (p)",
                y = expression("|" * Delta * p * "| per generation")) +
  theme_bb512()
save_bb512(p, "08_dq_by_case", layout = "takeaway")
