# Why heterozygosity measures differentiation. Analytical, not data.
# Expected heterozygosity H = 2p(1 - p) is a hump-shaped (concave) function of p.
# For two equal-sized populations, H_S = mean of their H values; H_T = H at the mean p.
# Because the curve is concave, H_S <= H_T, and the gap H_T - H_S grows as the
# populations' allele frequencies diverge. F_ST = (H_T - H_S) / H_T.
source("R/theme_bb512.R")
library(ggplot2)
fam <- bb512_font()
H <- function(p) 2 * p * (1 - p)
cases <- data.frame(case = c("Similar populations", "Different populations"),
                    p1 = c(0.4, 0.1), p2 = c(0.6, 0.9))
cases$case <- factor(cases$case, levels = cases$case)
cases$HS <- (H(cases$p1) + H(cases$p2)) / 2
cases$pbar <- (cases$p1 + cases$p2) / 2
cases$HT <- H(cases$pbar)
cases$FST <- (cases$HT - cases$HS) / cases$HT
print(cases)
curve <- merge(data.frame(p = seq(0, 1, length.out = 301)), data.frame(case = cases$case))
curve$H <- H(curve$p)
pops <- rbind(data.frame(case = cases$case, p = cases$p1, H = H(cases$p1)),
              data.frame(case = cases$case, p = cases$p2, H = H(cases$p2)))
p <- ggplot() +
  geom_line(data = curve, aes(p, H), colour = bb512$grey, linewidth = 1) +
  geom_segment(data = cases, aes(x = p1, xend = p2, y = HS, yend = HS), colour = bb512$forest,
               linewidth = 0.8, linetype = "dashed") +
  geom_point(data = pops, aes(p, H), colour = bb512$forest, size = 3.6) +
  geom_segment(data = cases, aes(x = pbar, xend = pbar, y = HS, yend = HT), colour = bb512$clay,
               linewidth = 1.4) +
  geom_point(data = cases, aes(pbar, HT), colour = bb512$clay, size = 3.6) +
  geom_point(data = cases, aes(pbar, HS), colour = bb512$forest, size = 3.6, shape = 21,
             fill = bb512$bg, stroke = 1.3) +
  geom_text(data = cases, aes(pbar, HT + 0.045, label = "H[T]"), parse = TRUE,
            colour = bb512$clay, size = 5.2, family = fam) +
  geom_text(data = cases, aes(x = ifelse(as.integer(case) == 1, pbar, pbar), y = HS - 0.05, label = "H[S]"),
            parse = TRUE, colour = bb512$forest, size = 5.2, family = fam) +
  geom_text(data = cases, aes(0.5, 0.06,
            label = paste0("'gap = ", sprintf("%.2f", HT - HS), ",  '*F[ST] == ", sprintf("'%.2f'", FST))),
            parse = TRUE, colour = bb512$clay, size = 5, family = fam) +
  facet_wrap(~case) +
  scale_x_continuous(breaks = c(0, 0.5, 1), labels = c("0", "0.5", "1")) +
  scale_y_continuous(limits = c(0, 0.6), breaks = seq(0, 0.5, 0.25)) +
  labs(x = "Allele frequency, p", y = "Expected heterozygosity, 2p(1 − p)") +
  theme_bb512() + theme(panel.spacing = unit(1.6, "lines"))
save_bb512(p, "23b_why_heterozygosity", layout = "takeaway")
