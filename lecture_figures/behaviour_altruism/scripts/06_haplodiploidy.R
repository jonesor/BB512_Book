# Relatedness of a worker (female) to colony members in a haplodiploid insect (ants, bees, wasps).
# Males are haploid. Analytical: sister r = 1/4 + 1/(2k) for a queen mated with k equally
# successful males; daughter 0.5; brother 0.25 (Neal 2004 section 19.2.2; standard regression r).
source("R/theme_bb512.R")
library(ggplot2)
fam <- "Avenir Next"
d <- data.frame(who = c("Own daughter", "Sister\n(queen mated once)", "Brother", "Sister\n(queen mated 10 times)"),
                r = c(0.5, 0.75, 0.25, 0.25 + 0.5 / 10),
                hl = c("ref", "hl", "ctx", "ctx"))
d$who <- factor(d$who, levels = rev(d$who))
p <- ggplot(d, aes(r, who, fill = hl)) +
  geom_col(width = 0.6) +
  geom_vline(xintercept = 0.5, linetype = "dashed", colour = bb512$grey, linewidth = 0.6) +
  geom_text(aes(x = r + 0.02, label = sprintf("%.2f", r)), hjust = 0, family = fam, size = 5.3,
            colour = bb512$ink, fontface = "bold") +
  scale_fill_manual(values = c(ref = bb512$forest, hl = bb512$clay, ctx = bb512$sage), guide = "none") +
  scale_x_continuous(limits = c(0, 0.98), breaks = seq(0, 0.75, 0.25), expand = c(0, 0)) +
  labs(x = "Relatedness to a worker (r)", y = NULL) +
  theme_bb512() +
  theme(panel.grid.major.y = element_blank(), panel.grid.major.x = element_line(colour = bb512$grid, linewidth = 0.5),
        axis.text.y = element_text(colour = bb512$ink, size = 15, lineheight = 0.9), axis.line.y = element_blank())
save_bb512(p, "06_haplodiploidy", layout = "half")
