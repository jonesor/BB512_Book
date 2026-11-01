# Slide: "Sampling error in allele frequencies" (Title, Bullets & Photo, "takeaway")
# Analytical (exact binomial): distribution of the frequency of A after ONE generation
# of Wright-Fisher sampling from p = 0.5, for N = 10 (2N = 20) and N = 100 (2N = 200).
# Frequencies are grouped into classes 0.05 wide so the two cases are comparable.
source("R/theme_bb512.R"); library(ggplot2)

one <- function(N, lab) {
  k <- 0:(2 * N); pr <- dbinom(k, 2 * N, 0.5)
  cls <- floor(k / (2 * N) / 0.05 + 0.5 + 1e-9) * 0.05
  a <- aggregate(pr, list(cls = cls), sum)
  data.frame(cls = a$cls, prob = a$x, lab = lab)
}
labs2 <- c("N = 10 (20 gene copies)", "N = 100 (200 gene copies)")
d <- rbind(one(10, labs2[1]), one(100, labs2[2]))
d$lab <- factor(d$lab, levels = labs2)

fig <- ggplot(d, aes(cls, prob, fill = lab)) +
  geom_col(width = 0.045) +
  facet_wrap(~lab, ncol = 1) +
  scale_fill_manual(values = setNames(c(bb512$clay, bb512$forest), labs2), guide = "none") +
  scale_x_continuous(breaks = seq(0.1, 0.9, 0.2)) +
  coord_cartesian(xlim = c(0.08, 0.92)) +
  scale_y_continuous(breaks = c(0, 0.25, 0.5)) +
  labs(x = expression("Frequency of " * italic(A) * " in the next generation"),
       y = "Proportion of populations") +
  theme_bb512()
save_bb512(fig, "03_sampling_error", layout = "takeaway")
