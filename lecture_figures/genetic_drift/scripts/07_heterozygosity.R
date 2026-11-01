# Slide: "Result 2: drift erodes diversity at rate 1/(2N)" (Title, Bullets & Photo, "takeaway")
# Analytical expectation: H_t / H_0 = (1 - 1/(2N))^t, no mutation or migration.
source("R/theme_bb512.R"); source("R/drift_helpers.R"); library(ggplot2)
t <- 0:100; Ns <- c(10, 100, 1000)
d <- do.call(rbind, lapply(Ns, function(N) data.frame(t, H = (1 - 1 / (2 * N))^t, N = N)))
d$Nf <- factor(d$N, levels = Ns)
cols <- setNames(c(bb512$clay, bb512$forest, bb512$blue), Ns)
pts <- data.frame(t = 20, H = (1 - 1 / (2 * c(10, 100)))^20, Nf = factor(c(10, 100), levels = Ns))
pts$lab <- paste0(round(100 * pts$H), "%")
print(pts)

fig <- ggplot(d, aes(t, H, colour = Nf)) +
  geom_vline(xintercept = 20, linetype = "dashed", colour = bb512$grey, linewidth = 0.6) +
  geom_line(linewidth = 1.4) +
  geom_point(data = pts, size = 3.5) +
  geom_text(data = pts, aes(label = lab), nudge_x = c(-3, 3), nudge_y = c(-0.04, 0.05), hjust = c(1, 0), size = 5.5,
            fontface = "bold", family = .bb512_font, show.legend = FALSE) +
  annotate("text", x = 101, y = (1 - 1 / (2 * Ns))^100, label = paste("N =", Ns),
           colour = cols, hjust = 0, size = 5.5, family = .bb512_font) +
  scale_colour_manual(values = cols, guide = "none") +
  scale_x_continuous(limits = c(0, 125), breaks = c(0, 20, 50, 100)) +
  scale_y_continuous(limits = c(0, 1.05), breaks = c(0, 0.5, 1), labels = c("0", "50%", "100%")) +
  labs(x = "Generation", y = "Heterozygosity remaining") +
  theme_bb512()
save_bb512(fig, "07_heterozygosity", layout = "takeaway")
