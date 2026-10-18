library(ggplot2)
library(dplyr)
library(tibble)
library(patchwork)

# BB512 colours
col_AA <- "#2A6656"  # Dark green
col_Aa <- "#D9A441"  # Ochre
col_aa <- "#B9C9C0"  # Sage
col_text <- "#243F36"
col_bg <- "#FBFAF6"

# Construct a graphical Punnett square
punnett_plot <- function(p = 0.6, show_probabilities = TRUE) {

  stopifnot(is.numeric(p), length(p) == 1,
            !is.na(p), p >= 0, p <= 1)

  q <- 1 - p

  cells <- tibble(
    genotype = c("AA", "Aa", "aA", "aa"),
    class = c("AA", "Aa", "Aa", "aa"),

    xmin = c(0, p, 0, p),
    xmax = c(p, 1, p, 1),

    ymin = c(q, q, 0, 0),
    ymax = c(1, 1, q, q),

    probability = c(p^2, p*q, q*p, q^2)
  ) |>
    mutate(
      x = (xmin + xmax) / 2,
      y = (ymin + ymax) / 2,
      label = if (show_probabilities) {
        sprintf("%s\n%.2f", genotype, probability)
      } else {
        genotype
      }
    )

  ggplot(cells) +
    geom_rect(
      aes(xmin = xmin, xmax = xmax,
          ymin = ymin, ymax = ymax,
          fill = class),
      colour = col_bg,
      linewidth = 1.8
    ) +
    geom_text(
      aes(x = x, y = y, label = label),
      colour = col_text,
      size = 6,
      lineheight = 1.3,
      fontface = "bold"
    ) +
    scale_fill_manual(
      values = c(
        AA = col_AA,
        Aa = col_Aa,
        aa = col_aa
      ),
      guide = "none"
    ) +
    coord_fixed(
      xlim = c(0, 1),
      ylim = c(0, 1),
      expand = FALSE
    ) +
    labs(
      x = NULL,
      y = NULL
    ) +
    theme_void(base_family = "Helvetica") +
    theme(
      plot.background = element_rect(
        fill = col_bg, colour = NA
      ),
      panel.background = element_rect(
        fill = col_bg, colour = NA
      ),
      plot.margin = margin(10, 10, 10, 10)
    )
}

p_values <- c(0.2, 0.5, 0.8)

plots <- lapply(p_values, function(p) {
  punnett_plot(p, show_probabilities = FALSE) +
    ggtitle(sprintf("p = %.1f", p)) +
    theme(
      plot.title = element_text(
        size = 20,
        face = "bold",
        hjust = 0.5,
        colour = col_text,
        margin = margin(b = 12)
      )
    )
})

combined <- wrap_plots(plots, nrow = 1)

combined

ggsave(
  "BB512_punnett_squares.png",
  plot = combined,
  width = 11.73,
  height = 3.95,
  units = "in",
  bg = col_bg
)