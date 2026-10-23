# Slide "The force of selection fades after maturity": EMPIRICAL life table, ANALYTICAL measure.
# Female red deer (Cervus elaphus), Rhum, 1957: l_x and m_x from Neal (2004), Table 16.1 (Lowe 1969).
# Force of selection on survival from age a to a + 1 (Hamilton 1966), for a stationary population (r = 0,
# as Neal assumes for this life table): the share of lifetime reproduction that still lies ahead,
#   F(a) = sum_{y > a} l_y m_y / R0.
# F = 1 until breeding starts at age 3, then falls as each year's reproduction is "used up".
source("R/theme_bb512.R")
fam <- "Avenir Next"

deer <- data.frame(
  x  = 0:16,
  lx = c(1.000, 0.760, 0.656, 0.591, 0.527, 0.463, 0.400, 0.336, 0.271, 0.138,
         0.045, 0.039, 0.032, 0.026, 0.019, 0.013, 0.009),
  mx = c(0, 0, 0, 0.311, 0.278, 0.302, 0.400, 0.476, 0.358, 0.447,
         0.289, 0.283, 0.285, 0.283, 0.282, 0.285, 0.284))
lxmx <- deer$lx * deer$mx
deer$force <- sapply(deer$x, function(a) sum(lxmx[deer$x > a]) / sum(lxmx))

p <- ggplot2::ggplot(deer, ggplot2::aes(x, force)) +
  ggplot2::annotate("rect", xmin = -0.3, xmax = 2.5, ymin = 0, ymax = 1.12, fill = bb512$sage, alpha = 0.18) +
  ggplot2::annotate("text", x = 1.1, y = 0.55, label = "Not yet\nbreeding", family = fam, size = 5,
                    colour = bb512$grey, lineheight = 0.95) +
  ggplot2::geom_line(colour = bb512$forest, linewidth = 1.4) +
  ggplot2::geom_point(colour = bb512$forest, size = 3) +
  ggplot2::annotate("text", x = 3.4, y = 1.05, label = "First breeding at age 3", hjust = 0, family = fam,
                    size = 5, colour = bb512$clay, fontface = "bold") +
  ggplot2::annotate("text", x = 9.3, y = 0.30, label = "By age 9, only 5% of\nlifetime reproduction\nis still to come",
                    hjust = 0, family = fam, size = 5, colour = bb512$ink, lineheight = 0.95) +
  ggplot2::annotate("segment", x = 9.25, xend = 9.05, y = 0.2, yend = 0.075, colour = bb512$grey, linewidth = 0.6) +
  ggplot2::scale_x_continuous("Age (years)", breaks = seq(0, 16, 2), expand = c(0.02, 0)) +
  ggplot2::scale_y_continuous("Strength of selection\non survival", limits = c(0, 1.12),
                              breaks = seq(0, 1, 0.25), expand = c(0, 0)) +
  theme_bb512(base_family = fam)

save_bb512(p, "07_red_deer_force", layout = "takeaway")
