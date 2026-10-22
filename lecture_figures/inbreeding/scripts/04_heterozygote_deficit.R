# Estimating F from a heterozygote deficit.
# Hardy-Weinberg expectations for a two-allele locus (analytical):
#   AA = p^2, Aa = 2pq, aa = q^2, with p = frequency of A.
# Worked example from the lecture (illustrative numbers, not real data):
#   p = 0.3, expected H_e = 2pq = 0.42, observed H_o = 0.30,
#   F = 1 - H_o / H_e = 0.286.
source("R/theme_bb512.R")

p_ex <- 0.3
H_obs <- 0.30
H_exp <- 2 * p_ex * (1 - p_ex)
F_hat <- 1 - H_obs / H_exp
stopifnot(abs(H_exp - 0.42) < 1e-12, abs(F_hat - 0.2857) < 1e-4)

grid <- seq(0, 1, length.out = 401)
df <- rbind(
  data.frame(p = grid, freq = grid^2,               geno = "AA"),
  data.frame(p = grid, freq = 2 * grid * (1 - grid), geno = "Aa"),
  data.frame(p = grid, freq = (1 - grid)^2,         geno = "aa")
)
cols <- c(AA = bb512$sage, Aa = bb512$forest, aa = bb512$sage)

p <- ggplot2::ggplot(df, ggplot2::aes(p, freq, colour = geno)) +
  ggplot2::geom_vline(xintercept = p_ex, colour = bb512$grey,
                      linetype = "dashed", linewidth = 0.7) +
  ggplot2::geom_line(ggplot2::aes(linewidth = geno == "Aa")) +
  ggplot2::scale_linewidth_manual(values = c(`FALSE` = 1, `TRUE` = 1.5), guide = "none") +
  ggplot2::annotate("segment", x = p_ex, xend = p_ex, y = H_exp - 0.015, yend = H_obs + 0.02,
                    colour = bb512$clay, linewidth = 1.2,
                    arrow = grid::arrow(length = grid::unit(0.12, "inches"), type = "closed")) +
  ggplot2::annotate("point", x = p_ex, y = H_exp, shape = 21, size = 4.2, stroke = 1.4,
                    colour = bb512$forest, fill = bb512$bg) +
  ggplot2::annotate("point", x = p_ex, y = H_obs, size = 4.2, colour = bb512$clay) +
  # labels placed in clear space with thin leader lines to the two points
  ggplot2::annotate("segment", x = c(0.355, 0.355), xend = c(p_ex + 0.012, p_ex + 0.012),
                    y = c(0.62, 0.09), yend = c(H_exp + 0.012, H_obs - 0.012),
                    colour = c(bb512$forest, bb512$clay), linewidth = 0.5) +
  ggplot2::annotate("text", x = 0.365, y = 0.62,
                    label = "Expected~H[e]*' = 0.42'", parse = TRUE, hjust = 0,
                    size = 5.2, colour = bb512$forest, family = "Avenir Next") +
  ggplot2::annotate("text", x = 0.365, y = 0.07,
                    label = "Observed~H[o]*' = 0.30'", parse = TRUE, hjust = 0,
                    size = 5.2, colour = bb512$clay, family = "Avenir Next") +
  ggplot2::annotate("text", x = c(0.97, 0.5, 0.03), y = c(0.86, 0.555, 0.86),
                    label = c("AA", "Aa", "aa"), hjust = c(1, 0.5, 0),
                    colour = c(bb512$grey, bb512$forest, bb512$grey),
                    size = 5.4, fontface = "bold", family = "Avenir Next") +
  ggplot2::scale_colour_manual(values = cols, guide = "none") +
  ggplot2::scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
  ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
  ggplot2::labs(x = "Frequency of allele A (p)", y = "Genotype frequency") +
  theme_bb512()

save_bb512(p, "04_heterozygote_deficit", layout = "takeaway")
