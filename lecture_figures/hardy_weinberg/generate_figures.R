# BB512 lecture 08: Hardy-Weinberg principle ---------------------------------
#
# Figures:
#   13  Area-proportional Punnett square for p = 0.6 (slide 13, "A Punnett
#       square gives the same result"), plus 13b, the same square at
#       p = 0.2, 0.5 and 0.8 (adapted from scripts/punnet_square.R).
#   14  Expected genotype frequencies as a function of allele frequency p
#       (slide 14, "How genotype frequencies depend on p").
#
# Run from the repository root:
#   source("lecture_figures/hardy_weinberg/generate_figures.R")
#
# Writes full- and half-width PNGs, using the same slide sizes as the BB852
# lecture figure generators. Colours are taken from the BB512 Keynote theme.

library(ggplot2)
library(ragg)
library(dplyr)
library(tibble)
library(patchwork)


# Sizes, fonts and output folders -------------------------------------------

bb512_sizes <- list(
  full = c(11.73, 3.95),  # Keynote "Title & Photo" placeholder
  half = c(5.57, 4.25)
)

available_fonts <- unique(systemfonts::system_fonts()$family)
bb512_font <- if ("Avenir Next" %in% available_fonts) "Avenir Next" else "Helvetica"

output_root <- file.path("lecture_figures", "hardy_weinberg", "output")
full_output_directory <- file.path(output_root, "full")
half_output_directory <- file.path(output_root, "half")
dir.create(full_output_directory, recursive = TRUE, showWarnings = FALSE)
dir.create(half_output_directory, recursive = TRUE, showWarnings = FALSE)

save_bb512 <- function(plot, filename, layout = "full") {
  size <- bb512_sizes[[layout]]
  ggsave(paste0(filename, ".png"), plot,
         width = size[1], height = size[2], units = "in", dpi = 300,
         device = ragg::agg_png, bg = "transparent")
  invisible(filename)
}


# BB512 Keynote theme colours ------------------------------------------------

col_AA <- "#21443A"  # dark green
col_Aa <- "#9A4535"  # brick red
col_aa <- "#B9822F"  # ochre
ink    <- "#2B2B2B"


# Data -----------------------------------------------------------------------

p   <- seq(0, 1, by = 0.01)
dat <- rbind(
  data.frame(p = p, freq = p^2,             genotype = "AA: p²"),
  data.frame(p = p, freq = 2 * p * (1 - p), genotype = "Aa: 2pq"),
  data.frame(p = p, freq = (1 - p)^2,       genotype = "aa: q²")
)
dat$genotype <- factor(dat$genotype,
                       levels = c("AA: p²", "Aa: 2pq", "aa: q²"))
cols <- setNames(c(col_AA, col_Aa, col_aa), levels(dat$genotype))

# Direct labels replace the legend; each sits where its curve is well separated
labs_df <- data.frame(
  p        = c(0.93, 0.50, 0.07),
  freq     = c(0.93^2, 0.5, 0.93^2),
  genotype = levels(dat$genotype),
  hjust    = c(1.15, 0.5, -0.15),
  vjust    = c(0, -0.9, 0)
)


# Plot ---------------------------------------------------------------------

genotype_plot <- function(base_size = 18, label_size = 6.5,
                          y_title = "Expected genotype\nfrequency") {
  ggplot(dat, aes(p, freq, colour = genotype)) +
    # mark the heterozygosity maximum discussed on the next slide
    geom_vline(xintercept = 0.5, colour = "grey75",
               linewidth = 0.4, linetype = "dashed") +
    geom_line(linewidth = 1.6, lineend = "round") +
    geom_text(data = labs_df,
              aes(label = genotype, hjust = hjust, vjust = vjust),
              size = label_size, fontface = "bold", family = bb512_font) +
    scale_colour_manual(values = cols, guide = "none") +
    scale_x_continuous(breaks = seq(0, 1, 0.2),
                       expand = expansion(mult = 0.01)) +
    scale_y_continuous(breaks = seq(0, 1, 0.25), limits = c(0, 1.05),
                       expand = expansion(mult = c(0, 0))) +
    labs(x = "Allele frequency, p", y = y_title) +
    theme_minimal(base_size = base_size, base_family = bb512_font) +
    theme(
      plot.background    = element_rect(fill = "transparent", colour = NA),
      panel.background   = element_rect(fill = "transparent", colour = NA),
      panel.grid.minor   = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(colour = "grey88", linewidth = 0.4),
      axis.text    = element_text(colour = ink),
      axis.title   = element_text(colour = ink),
      axis.title.y = element_text(margin = margin(r = 10)),
      axis.title.x = element_text(margin = margin(t = 8)),
      plot.margin  = margin(10, 20, 6, 6)
    )
}

# Half width is taller than it is wide, so the y title fits on one line
figure_14      <- genotype_plot()
figure_14_half <- genotype_plot(base_size = 16, label_size = 5.5,
                                y_title = "Expected genotype frequency")

save_bb512(figure_14,      file.path(full_output_directory, "14_genotype_frequencies"), "full")
save_bb512(figure_14_half, file.path(half_output_directory, "14_genotype_frequencies"), "half")


# Punnett squares -------------------------------------------------------------
# Adapted from scripts/punnet_square.R. Cell areas are proportional to genotype
# probabilities, so the square shows p^2 + 2pq + q^2 = 1 geometrically.

# Colours from scripts/punnet_square.R
pun_AA   <- "#2A6656"  # dark green
pun_Aa   <- "#D9A441"  # ochre
pun_aa   <- "#B9C9C0"  # sage
pun_text <- "#243F36"
pun_gap  <- "#FBFAF6"  # cell borders, matches the slide background

punnett_plot <- function(p = 0.6, show_probabilities = TRUE,
                         show_gametes = TRUE, cell_size = 6.5,
                         gamete_size = 6, scale_size = 4.2) {
  stopifnot(is.numeric(p), length(p) == 1, !is.na(p), p >= 0, p <= 1)
  q <- 1 - p

  cells <- tibble(
    genotype    = c("AA", "Aa", "aA", "aa"),
    class       = c("AA", "Aa", "Aa", "aa"),
    term        = c("p²", "pq", "qp", "q²"),
    xmin = c(0, p, 0, p), xmax = c(p, 1, p, 1),
    ymin = c(q, q, 0, 0), ymax = c(1, 1, q, q),
    probability = c(p^2, p * q, q * p, q^2)
  ) |>
    mutate(
      x = (xmin + xmax) / 2,
      y = (ymin + ymax) / 2,
      label = if (show_probabilities) {
        sprintf("%s\n%s = %.2f", genotype, term, probability)
      } else {
        genotype
      },
      # light text on the dark green cell keeps contrast readable
      text_colour = ifelse(class == "AA", pun_gap, pun_text)
    )

  g <- ggplot(cells) +
    geom_rect(aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
                  fill = class)) +
    # gaps only between cells, so the outer edges sit exactly on 0 and 1
    annotate("segment", x = p, xend = p, y = 0, yend = 1,
             colour = pun_gap, linewidth = 1.8) +
    annotate("segment", x = 0, xend = 1, y = q, yend = q,
             colour = pun_gap, linewidth = 1.8) +
    geom_text(aes(x = x, y = y, label = label, colour = text_colour),
              size = cell_size, lineheight = 1.15, fontface = "bold",
              family = bb512_font) +
    scale_fill_manual(values = c(AA = pun_AA, Aa = pun_Aa, aa = pun_aa),
                      guide = "none") +
    scale_colour_identity()

  if (show_gametes) {
    # Scales along the top (first gamete) and left (second gamete), both
    # measured from the top-left corner, so each side length is read straight
    # off the axis and each cell's area is width x height.
    a_col   <- "#9A7020"            # darker ochre so "a" labels stay legible
    muted   <- "#6B6E75"
    off     <- 0.03                 # gap between square and scale line
    tick    <- 0.018
    v       <- seq(0, 1, by = 0.1)
    labelled <- seq(0, 1, by = 0.2)
    top_y   <- 1 + off
    left_x  <- -off

    # top scale: x = value
    top_ticks  <- tibble(x = v, y = top_y,
                         yend = top_y + ifelse(v %in% labelled, tick * 1.6, tick))
    top_nums   <- tibble(x = labelled, y = top_y + tick * 2.4,
                         label = sprintf("%.1f", labelled))
    # left scale: value v sits at y = 1 - v
    left_ticks <- tibble(y = 1 - v, x = left_x,
                         xend = left_x - ifelse(v %in% labelled, tick * 1.6, tick))
    left_nums  <- tibble(y = 1 - labelled, x = left_x - tick * 2.4,
                         label = sprintf("%.1f", labelled))

    # the p | q boundary, carried from each scale to the square
    boundary <- tibble(x = c(p, left_x - tick * 1.6), xend = c(p, 0),
                       y = c(top_y + tick * 1.6, q), yend = c(1, q))

    spans <- tibble(
      x      = c(p / 2, p + q / 2, left_x - 0.2, left_x - 0.2),
      y      = c(top_y + 0.19, top_y + 0.19, 1 - p / 2, q / 2),
      label  = c(sprintf("A: p = %.1f", p), sprintf("a: q = %.1f", q),
                 sprintf("A: p = %.1f", p), sprintf("a: q = %.1f", q)),
      hjust  = c(0.5, 0.5, 1, 1),
      colour = c(pun_AA, a_col, pun_AA, a_col)
    )

    g <- g +
      annotate("segment", x = 0, xend = 1, y = top_y, yend = top_y,
               colour = muted, linewidth = 0.5) +
      annotate("segment", x = left_x, xend = left_x, y = 0, yend = 1,
               colour = muted, linewidth = 0.5) +
      geom_segment(data = top_ticks, aes(x = x, xend = x, y = y, yend = yend),
                   colour = muted, linewidth = 0.5) +
      geom_segment(data = left_ticks, aes(x = x, xend = xend, y = y, yend = y),
                   colour = muted, linewidth = 0.5) +
      geom_segment(data = boundary, aes(x = x, xend = xend, y = y, yend = yend),
                   colour = pun_text, linewidth = 0.6, linetype = "22") +
      geom_text(data = top_nums, aes(x = x, y = y, label = label),
                vjust = 0, colour = muted, size = scale_size,
                family = bb512_font) +
      geom_text(data = left_nums, aes(x = x, y = y, label = label),
                hjust = 1, colour = muted, size = scale_size,
                family = bb512_font) +
      geom_text(data = spans, aes(x = x, y = y, label = label, hjust = hjust),
                colour = spans$colour, size = gamete_size, fontface = "bold",
                family = bb512_font)
  }

  xlims <- if (show_gametes) c(-0.66, 1.04) else c(0, 1)
  ylims <- if (show_gametes) c(-0.01, 1.28) else c(0, 1)
  g +
    coord_fixed(xlim = xlims, ylim = ylims, expand = FALSE, clip = "off") +
    theme_void(base_family = bb512_font) +
    theme(
      plot.background  = element_rect(fill = "transparent", colour = NA),
      panel.background = element_rect(fill = "transparent", colour = NA),
      plot.margin = margin(10, 10, 10, 10)
    )
}

# Figure 13: the lecture example, p = 0.6
figure_13      <- punnett_plot(p = 0.6, cell_size = 5.4, gamete_size = 5,
                               scale_size = 3.6)
figure_13_half <- punnett_plot(p = 0.6, cell_size = 4.6, gamete_size = 4.2,
                               scale_size = 3.4)

save_bb512(figure_13,      file.path(full_output_directory, "13_punnett_square"), "full")
save_bb512(figure_13_half, file.path(half_output_directory, "13_punnett_square"), "half")

# Figure 13b: how the square changes with p (original script's comparison)
punnett_panel <- function(p) {
  punnett_plot(p, show_probabilities = FALSE, show_gametes = FALSE) +
    ggtitle(sprintf("p = %.1f", p)) +
    theme(plot.title = element_text(size = 20, face = "bold", hjust = 0.5,
                                    colour = pun_text,
                                    margin = margin(b = 12)))
}

figure_13b <- wrap_plots(lapply(c(0.2, 0.5, 0.8), punnett_panel), nrow = 1) +
  plot_annotation(theme = theme(
    plot.background = element_rect(fill = "transparent", colour = NA)
  ))
save_bb512(figure_13b, file.path(full_output_directory, "13b_punnett_squares_p_values"), "full")
