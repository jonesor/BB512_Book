# 07_primate_lice.R  (slide "Humans carry two louse histories", layout = "half")
# Redrawn, simplified from Reed et al. (2007) BMC Biology 5: 7 (open access).
# Host tree (((human, chimpanzee), gorilla), Old World monkeys); louse tree
# ((Pediculus humanus, P. schaeffi), (Pthirus pubis, P. gorillae)), Pedicinus.
# Pediculus split ~6 Mya, matching the human-chimp split (cospeciation).
# Pthirus split ~3-4 Mya, much later than the human-gorilla split (~7 Mya):
# most parsimoniously a host switch from gorillas to humans. Topology only;
# branch lengths are not to scale.
source("R/theme_bb512.R")
library(ggplot2)
FAM <- getOption("bb512.family", "Avenir Next")
seg <- function(x, y, xend, yend) data.frame(x, y, xend, yend)
hy <- c(Human = 5, Chimpanzee = 4, Gorilla = 2, "Old World\nmonkeys" = 1)
host <- rbind(seg(0.75, 5, 1, 5), seg(0.75, 4, 1, 4), seg(0.75, 4, 0.75, 5),
              seg(0.5, 4.5, 0.75, 4.5), seg(0.5, 2, 1, 2), seg(0.5, 2, 0.5, 4.5),
              seg(0.25, 3.25, 0.5, 3.25), seg(0.25, 1, 1, 1), seg(0.25, 1, 0.25, 3.25),
              seg(0.1, 2.125, 0.25, 2.125))
py <- c("Head louse" = 5, "Chimp louse" = 4, "Pubic louse" = 3, "Gorilla louse" = 2, "Monkey louse" = 1)
lice0 <- rbind(seg(3.25, 5, 3, 5), seg(3.25, 4, 3, 4), seg(3.25, 4, 3.25, 5),        # Pediculus
              seg(3.25, 3, 3, 3), seg(3.25, 2, 3, 2), seg(3.25, 2, 3.25, 3),        # Pthirus
              seg(3.5, 4.5, 3.25, 4.5), seg(3.5, 2.5, 3.25, 2.5), seg(3.5, 2.5, 3.5, 4.5),
              seg(3.75, 3.5, 3.5, 3.5), seg(3.75, 1, 3, 1), seg(3.75, 1, 3.75, 3.5),
              seg(3.9, 2.25, 3.75, 2.25))
lice <- transform(lice0, x = x + 1.5, xend = xend + 1.5)
links <- data.frame(y = c(5, 4, 2, 1), yend = c(5, 4, 2, 1))
g <- ggplot() +
  geom_segment(data = host, aes(x, y, xend = xend, yend = yend), colour = bb512$forest, linewidth = 1.4, lineend = "square") +
  geom_segment(data = lice, aes(x, y, xend = xend, yend = yend), colour = bb512$blue, linewidth = 1.4, lineend = "square") +
  geom_segment(data = links, aes(x = 1.9, xend = 3.2, y = y, yend = yend), colour = bb512$sage, linetype = "dotted", linewidth = 0.9) +
  geom_segment(aes(x = 1.9, xend = 3.2, y = 5, yend = 3), colour = bb512$clay, linetype = "dashed", linewidth = 1.1) +
  annotate("text", x = 1.06, y = hy, label = names(hy), hjust = 0, size = 4.9, family = FAM, colour = bb512$forest, lineheight = 0.85) +
  annotate("text", x = 4.44, y = py, label = names(py), hjust = 1, size = 4.9, family = FAM, colour = bb512$blue) +
  annotate("text", x = 0.5, y = 5.9, label = "Primates", size = 5.6, family = FAM, colour = bb512$forest) +
  annotate("text", x = 5.4, y = 5.9, hjust = 1, label = "Sucking lice", size = 5.6, family = FAM, colour = bb512$blue) +
  annotate("text", x = 2.35, y = 3.5, label = "host switch", hjust = 1, size = 4.6, family = FAM, colour = bb512$clay) +
  coord_cartesian(xlim = c(0.05, 5.45), ylim = c(0.5, 6.2), expand = FALSE) +
  theme_void() + theme(plot.background = element_rect(fill = bb512$bg, colour = NA))
save_bb512(g, "07_primate_lice", layout = "half")
