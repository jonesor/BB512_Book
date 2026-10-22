# Slide 14: Luria & Delbrück predictions as cell lineages.
# Redrawn in the BB512 style after the Wikimedia Commons "Luria-Delbruck"
# illustration. Four cultures per hypothesis, each growing from one cell
# through five rounds of division (32 cells) before plating on phage.
# Both hypotheses give the same total number of resistant cells (11),
# but very different variation among cultures.
source("R/theme_bb512.R")

levels_n <- 5L                      # divisions: 1 -> 2 -> 4 -> 8 -> 16 -> 32 cells
row_gap  <- 1.35                    # vertical space per culture
plate_h  <- 0.16

# Build one lineage tree. 'mut_level'/'mut_index' marks the cell where a
# resistance mutation arises (all its descendants inherit it); 'plate_hits'
# marks plated cells that become resistant at exposure (induced model).
build_tree <- function(culture, panel, mut_level = NA, mut_index = NA,
                       plate_hits = integer(0)) {
  y_top <- -(culture - 1) * row_gap
  dy <- 0.2
  nodes <- do.call(rbind, lapply(0:levels_n, function(l) {
    n <- 2^l
    x <- (seq_len(n) - 0.5) / n
    data.frame(level = l, index = seq_len(n), x = x, y = y_top - l * dy)
  }))
  # Resistance inherited from a mutation during growth
  nodes$resistant <- FALSE
  if (!is.na(mut_level)) {
    span <- 2^(nodes$level - mut_level)
    anc  <- ceiling(nodes$index / ifelse(nodes$level >= mut_level, span, Inf))
    nodes$resistant <- nodes$level >= mut_level & anc == mut_index
  }
  # Resistance induced on the plate (final generation only)
  leaf <- nodes$level == levels_n
  nodes$resistant[leaf & nodes$index %in% plate_hits] <- TRUE

  edges <- do.call(rbind, lapply(1:levels_n, function(l) {
    child <- nodes[nodes$level == l, ]
    parent <- nodes[nodes$level == l - 1, ]
    p <- parent[ceiling(child$index / 2), ]
    data.frame(x = p$x, y = p$y, xend = child$x, yend = child$y)
  }))
  leaf_y <- min(nodes$y)
  list(
    nodes = transform(nodes, culture = culture, panel = panel),
    edges = transform(edges, culture = culture, panel = panel),
    plate = data.frame(culture = culture, panel = panel,
                       xmin = -0.02, xmax = 1.02,
                       ymin = leaf_y - plate_h / 2, ymax = leaf_y + plate_h / 2,
                       n = sum(nodes$resistant & leaf), ymid = leaf_y)
  )
}

panels <- c("Induced at exposure", "Arose during growth")
trees <- list(
  # Induced: resistance appears only on the plate, scattered evenly
  build_tree(1, panels[1], plate_hits = c(6, 17, 27)),
  build_tree(2, panels[1], plate_hits = c(11, 24)),
  build_tree(3, panels[1], plate_hits = c(3, 15, 29)),
  build_tree(4, panels[1], plate_hits = c(8, 20, 31)),
  # Arose during growth: timing of the mutation sets the number of mutants
  build_tree(1, panels[2], mut_level = 5, mut_index = 11),  # late: 1 cell
  build_tree(2, panels[2], mut_level = 2, mut_index = 2),   # early: 8 cells (jackpot)
  build_tree(3, panels[2]),                                  # none
  build_tree(4, panels[2], mut_level = 4, mut_index = 13)   # mid: 2 cells
)
nodes <- do.call(rbind, lapply(trees, `[[`, "nodes"))
edges <- do.call(rbind, lapply(trees, `[[`, "edges"))
plates <- do.call(rbind, lapply(trees, `[[`, "plate"))
nodes$panel <- factor(nodes$panel, levels = panels)
edges$panel <- factor(edges$panel, levels = panels)
plates$panel <- factor(plates$panel, levels = panels)
nodes$state <- ifelse(nodes$resistant, "Resistant", "Sensitive")

p <- ggplot2::ggplot() +
  ggplot2::geom_rect(data = plates,
                     ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
                     fill = "#EADBB8", colour = NA) +
  ggplot2::geom_segment(data = edges,
                        ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
                        colour = bb512$grey, linewidth = 0.25) +
  ggplot2::geom_point(data = nodes,
                      ggplot2::aes(x = x, y = y, colour = state),
                      size = 1.25) +
  ggplot2::geom_text(data = plates,
                     ggplot2::aes(x = 1.07, y = ymid, label = n),
                     hjust = 0, size = 4.4, fontface = "bold", colour = bb512$clay) +
  ggplot2::facet_wrap(~ panel, nrow = 1) +
  ggplot2::scale_colour_manual(values = c(Sensitive = bb512$sage,
                                          Resistant = bb512$clay),
                               breaks = c("Sensitive", "Resistant"), name = NULL) +
  ggplot2::scale_x_continuous(limits = c(-0.03, 1.16), expand = c(0, 0)) +
  ggplot2::labs(caption = "Strip = cells spread on phage;  number = resistant colonies") +
  theme_bb512(base_size = 14) +
  ggplot2::theme(axis.text = ggplot2::element_blank(),
                 panel.grid.major.y = ggplot2::element_blank(),
                 axis.title = ggplot2::element_blank(),
                 axis.line = ggplot2::element_blank(),
                 panel.grid = ggplot2::element_blank(),
                 strip.text = ggplot2::element_text(size = 13, face = "bold",
                                                    colour = bb512$forest),
                 panel.spacing = grid::unit(18, "pt"),
                 legend.text = ggplot2::element_text(size = 11),
                 legend.margin = ggplot2::margin(0, 0, 0, 0),
                 plot.caption = ggplot2::element_text(size = 9.5, colour = bb512$grey,
                                                      hjust = 0.5),
                 plot.margin = ggplot2::margin(6, 6, 4, 6, "pt")) +
  ggplot2::guides(colour = ggplot2::guide_legend(override.aes = list(size = 3)))

save_bb512(p, "01c_luria_delbruck_trees", layout = "half")
