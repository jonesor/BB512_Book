# Slide: "Why are males often bigger?" (Figure & Bullets, layout = "half")
# Empirical, comparative: pinniped species, Alexander et al. (1979), as shown in Neal
# (chapter "Sexual selection and mating systems"). Points DIGITISED from Neal's figure
# (13 species; overlapping points may be hidden in the source).
source("R/theme_bb512.R")
library(ggplot2)
d <- data.frame(
  ratio = c(0.878, 0.878, 1.0, 1.089, 1.178, 1.178, 1.178, 1.369, 1.369, 1.400, 1.400, 1.548, 1.619),
  harem = c(3.0, 1, 1, 1, 1, 4.4, 9.7, 7.3, 6.4, 12.7, 7.9, 39, 47))
p <- ggplot(d, aes(ratio, harem)) +
  geom_point(size = 3.5, colour = bb512$forest) +
  annotate("text", x = 1.6, y = 70, label = "Elephant seals", colour = bb512$clay, size = 5, hjust = 1) +
  scale_x_continuous("Male : female body length", limits = c(0.85, 1.7), breaks = seq(0.9, 1.7, 0.2)) +
  scale_y_log10("Mean harem size", limits = c(0.8, 100), breaks = c(1, 10, 100)) +
  theme_bb512()
save_bb512(p, "04_pinniped_harems", layout = "half")
