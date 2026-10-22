# Slide 8: Four ways to model gene flow (schematic, not data).
# Panels: continent–island, island, stepping-stone, isolation by distance.
source("R/theme_bb512.R")
library(ggplot2)

fam <- bb512_font()
circle <- function(x0, y0, r, n = 60, id) {
  a <- seq(0, 2 * pi, length.out = n)
  data.frame(x = x0 + r * cos(a), y = y0 + r * sin(a), id = id)
}
panel_title <- function(x, y, lab) annotate("text", x = x, y = y, label = lab,
  family = fam, fontface = "bold", colour = bb512$forest, size = 5.6, hjust = 0)
arrow_seg <- function(x, y, xend, yend, both = FALSE, col = bb512$grey) {
  annotate("segment", x = x, y = y, xend = xend, yend = yend, colour = col,
           linewidth = 0.8,
           arrow = arrow(length = unit(0.12, "in"), type = "closed",
                         ends = if (both) "both" else "last"))
}

# Panel offsets (x, y): top-left, top-right, bottom-left, bottom-right
# 1. Continent–island
blobs <- rbind(circle(1.3, 6.4, 1.05, id = "c"), circle(4.0, 6.4, 0.35, id = "i1"))
# 2. Island model: four islands around a migrant pool
isl <- rbind(circle(7.0, 7.55, 0.3, id = "a"), circle(9.6, 7.55, 0.3, id = "b"),
             circle(7.0, 5.85, 0.3, id = "c2"), circle(9.6, 5.85, 0.3, id = "d"))
# 3. Stepping-stone: five islands in a line
ss <- do.call(rbind, lapply(1:5, function(i) circle(0.45 + (i - 1) * 1.15, 2.2, 0.22, id = paste0("s", i))))
# 4. Isolation by distance: continuous grid of individuals, one neighbourhood
grid <- expand.grid(x = seq(6.3, 10.3, by = 0.4), y = seq(0.9, 3.5, by = 0.4))

p <- ggplot() +
  # dividing lines
  annotate("segment", x = 5.6, xend = 5.6, y = 0.3, yend = 8.6, colour = bb512$grid, linewidth = 0.6) +
  annotate("segment", x = 0, xend = 11, y = 4.35, yend = 4.35, colour = bb512$grid, linewidth = 0.6) +
  # 1
  panel_title(0, 8.35, "1  Continent–island") +
  geom_polygon(data = blobs[blobs$id == "c", ], aes(x, y), fill = bb512$forest) +
  geom_polygon(data = blobs[blobs$id == "i1", ], aes(x, y), fill = bb512$sage) +
  arrow_seg(2.45, 6.4, 3.55, 6.4) +
  annotate("text", x = 1.3, y = 6.4, label = "q[m]", parse = TRUE, colour = bb512$bg, size = 6, family = fam) +
  annotate("text", x = 3.0, y = 6.75, label = "m", fontface = "italic", colour = bb512$ink, size = 5.6, family = fam) +
  annotate("text", x = 2.8, y = 5.0, label = "one-way, source to sink", colour = bb512$grey, size = 5, family = fam) +
  # 2
  panel_title(5.9, 8.35, "2  Island") +
  annotate("rect", xmin = 7.85, xmax = 8.75, ymin = 6.35, ymax = 7.05, fill = bb512$pale, colour = bb512$grey, linewidth = 0.4) +
  annotate("text", x = 8.3, y = 6.7, label = "pool", colour = bb512$ink, size = 4.9, family = fam) +
  geom_polygon(data = isl, aes(x, y, group = id), fill = bb512$forest) +
  arrow_seg(7.3, 7.4, 7.85, 7.0, both = TRUE) + arrow_seg(9.3, 7.4, 8.75, 7.0, both = TRUE) +
  arrow_seg(7.3, 6.0, 7.85, 6.4, both = TRUE) + arrow_seg(9.3, 6.0, 8.75, 6.4, both = TRUE) +
  annotate("text", x = 8.3, y = 5.0, label = "all exchange equally", colour = bb512$grey, size = 5, family = fam) +
  # 3
  panel_title(0, 3.95, "3  Stepping-stone") +
  geom_polygon(data = ss, aes(x, y, group = id), fill = bb512$forest) +
  arrow_seg(0.74, 2.2, 1.31, 2.2, both = TRUE) + arrow_seg(1.89, 2.2, 2.46, 2.2, both = TRUE) +
  arrow_seg(3.04, 2.2, 3.61, 2.2, both = TRUE) + arrow_seg(4.19, 2.2, 4.76, 2.2, both = TRUE) +
  annotate("text", x = 2.6, y = 1.0, label = "neighbours only", colour = bb512$grey, size = 5, family = fam) +
  # 4
  panel_title(5.9, 3.95, "4  Isolation by distance") +
  geom_point(data = grid, aes(x, y), colour = bb512$sage, size = 1.6) +
  geom_polygon(data = circle(8.3, 2.1, 0.85, id = "n"), aes(x, y), fill = NA, colour = bb512$clay, linewidth = 1) +
  geom_point(aes(x = 8.3, y = 2.1), colour = bb512$clay, size = 3) +
  annotate("text", x = 8.3, y = 0.45, label = "continuous; mates nearby", colour = bb512$grey, size = 5, family = fam) +
  coord_fixed(xlim = c(0, 11), ylim = c(0.2, 8.6), expand = FALSE) +
  theme_void() +
  theme(plot.background = element_rect(fill = bb512$bg, colour = NA),
        plot.margin = margin(6, 6, 6, 6))

save_bb512(p, "08_four_models", layout = "takeaway")
