# Slide "How fast does a favoured allele spread?": frequency of the favoured allele over time.
# Deterministic iteration (no drift). s = 0.1; favoured allele starts at p0 = 0.01.
# Haploid; diploid no dominance (Case B); favoured allele dominant (Case C);
# favoured allele recessive (Case D). Compare Neal Fig. 10.4.
source("R/theme_bb512.R"); source("R/models.R")
fam <- "Avenir Next"
s <- 0.1; q0 <- 0.99; G <- 1000
run <- function(case) { w <- case_fitness(case, s = s); 1 - iterate(q0, G, zygotic_step, w[1], w[2], w[3]) }
df <- rbind(
  data.frame(t = 0:G, p = 1 - iterate(q0, G, haploid_step, s = s), m = "Haploid"),
  data.frame(t = 0:G, p = run("B"), m = "B"), data.frame(t = 0:G, p = run("C"), m = "C"),
  data.frame(t = 0:G, p = run("D"), m = "D"))
cols <- c(Haploid = bb512$grey, B = bb512$gold, C = bb512$forest, D = bb512$clay)
lab <- data.frame(m = c("Haploid", "B", "C", "D"), x = c(55, 150, 300, 640), y = c(1.07, 0.62, 0.85, 0.30),
  txt = c("Haploid", "No dominance", "Favoured allele dominant", "Favoured allele recessive"),
  h = c(0, 0, 0, 1))
p <- ggplot2::ggplot(df, ggplot2::aes(t, p, colour = m)) +
  ggplot2::geom_line(ggplot2::aes(linetype = m == "Haploid"), linewidth = 1.4) +
  ggplot2::geom_text(data = lab, ggplot2::aes(x, y, label = txt, hjust = h), family = fam, size = 5.2) +
  ggplot2::scale_colour_manual(values = cols, guide = "none") +
  ggplot2::scale_linetype_manual(values = c(`TRUE` = "dashed", `FALSE` = "solid"), guide = "none") +
  ggplot2::scale_y_continuous(limits = c(0, 1.1), breaks = seq(0, 1, 0.25)) +
  ggplot2::scale_x_continuous(breaks = seq(0, 1000, 250)) +
  ggplot2::labs(x = "Generation (t)", y = "Favoured allele (p)") +
  theme_bb512()
save_bb512(p, "09_spread_by_case", layout = "full")
for (m in unique(df$m)) { d <- df[df$m == m, ]; cat(m, ": p>0.5 at t =", d$t[which(d$p > 0.5)[1]],
  "; p>0.99 at t =", d$t[which(d$p > 0.99)[1]], "\n") }
