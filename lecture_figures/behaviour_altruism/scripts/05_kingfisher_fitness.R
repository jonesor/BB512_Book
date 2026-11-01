# Direct and indirect fitness of yearling male pied kingfishers (Ceryle rudis) over their first
# two years. EMPIRICAL: Reyer (1990), as tabulated in Neal (2004) Table 19.3 (totals).
# Fitness units follow Neal: offspring weighted by relatedness (r). Neal prints 1.09 as the primary
# helper's inclusive total; the components sum to 1.07 (direct 0.42 + indirect 0.65), used here.
source("R/theme_bb512.R")
library(ggplot2)
fam <- "Avenir Next"
kf <- data.frame(status = c("Breeder\n(only ~5% of yearlings)", "Primary helper\n(helps parents)", "Secondary helper\n(helps non-kin)", "Delayer\n(no help)"),
                 direct = c(1.76, 0.42, 0.87, 0.30), indirect = c(0, 0.65, 0.05, 0))
kf$status <- factor(kf$status, levels = rev(kf$status))
long <- rbind(data.frame(status = kf$status, part = "Direct", value = kf$direct),
              data.frame(status = kf$status, part = "Indirect", value = kf$indirect))
long$part <- factor(long$part, levels = c("Indirect", "Direct"))
tot <- data.frame(status = kf$status, total = kf$direct + kf$indirect)
p <- ggplot(long, aes(value, status, fill = part)) +
  geom_col(width = 0.62) +
  geom_text(data = tot, aes(x = total + 0.04, y = status, label = sprintf("%.2f", total)),
            inherit.aes = FALSE, hjust = 0, family = fam, size = 5.3, colour = bb512$ink, fontface = "bold") +
  annotate("text", x = 0.21, y = 3, label = "Direct", colour = "white", family = fam, size = 5, fontface = "bold") +
  annotate("text", x = 0.745, y = 3, label = "Indirect", colour = "white", family = fam, size = 5, fontface = "bold") +
  scale_fill_manual(values = c(Direct = bb512$forest, Indirect = bb512$clay), guide = "none") +
  scale_x_continuous(limits = c(0, 2.05), breaks = seq(0, 2, 0.5), expand = c(0, 0)) +
  labs(x = "Fitness over first two years (offspring × r)", y = NULL) +
  theme_bb512() +
  theme(panel.grid.major.y = element_blank(), panel.grid.major.x = element_line(colour = bb512$grid, linewidth = 0.5),
        axis.text.y = element_text(colour = bb512$ink, size = 15, lineheight = 0.9), axis.line.y = element_blank())
save_bb512(p, "05_kingfisher_fitness", layout = "takeaway")
