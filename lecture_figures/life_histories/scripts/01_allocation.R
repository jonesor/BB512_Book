# Slide "One budget, three uses": allocation of a limited resource budget to maintenance, growth and
# reproduction in a slow and a fast life history. SCHEMATIC, illustrative shares (redrawn from the
# elephant/mouse bars of the previous version of the lecture; after Gadgil & Bossert 1970).
source("R/theme_bb512.R")
fam <- "Avenir Next"

alloc <- data.frame(
  strategy = rep(c("Slow life history\n(e.g. elephant)", "Fast life history\n(e.g. mouse)"), each = 3),
  use = rep(c("Maintenance", "Growth", "Reproduction"), 2),
  share = c(45, 30, 25,   15, 25, 60))
alloc$strategy <- factor(alloc$strategy, rev(unique(alloc$strategy)))
alloc$use <- factor(alloc$use, c("Maintenance", "Growth", "Reproduction"))
cols <- c(Maintenance = bb512$blue, Growth = bb512$forest, Reproduction = bb512$clay)

# label positions (centre of each segment); bars stack left to right in factor order
alloc <- alloc[order(alloc$strategy, alloc$use), ]
alloc$right <- ave(alloc$share, alloc$strategy, FUN = cumsum)
alloc$mid <- alloc$right - alloc$share / 2

p <- ggplot2::ggplot(alloc, ggplot2::aes(y = strategy, x = share, fill = use)) +
  ggplot2::geom_col(width = 0.62, colour = bb512$bg, linewidth = 1.2,
                    position = ggplot2::position_stack(reverse = TRUE)) +
  # direct labels above the top bar (the segments of the fast bar are identified by colour)
  ggplot2::geom_text(data = subset(alloc, strategy == levels(alloc$strategy)[2]),
                     ggplot2::aes(x = mid, y = 2.45, label = use, colour = use), family = fam,
                     fontface = "bold", size = 5.4, inherit.aes = FALSE) +
  ggplot2::scale_colour_manual(values = cols, guide = "none") +
  ggplot2::scale_fill_manual(values = cols, guide = "none") +
  ggplot2::scale_x_continuous("Share of the energy and time budget (%)", limits = c(0, 100),
                              breaks = seq(0, 100, 25), expand = c(0, 0)) +
  ggplot2::scale_y_discrete(expand = ggplot2::expansion(add = c(0.5, 0.75))) +
  ggplot2::labs(y = NULL) +
  theme_bb512(base_family = fam) +
  ggplot2::theme(axis.text.y = ggplot2::element_text(size = 16, colour = bb512$ink, hjust = 1),
                 panel.grid.major.y = ggplot2::element_blank(),
                 panel.grid.major.x = ggplot2::element_line(colour = bb512$grid, linewidth = 0.5),
                 axis.line.y = ggplot2::element_blank(),
                 plot.margin = ggplot2::margin(14, 46, 12, 16, "pt")) +
  ggplot2::coord_cartesian(clip = "off")

save_bb512(p, "01_allocation", layout = "takeaway")
