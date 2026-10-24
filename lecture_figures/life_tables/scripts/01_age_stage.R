# 01_age_stage.R
# Slides "Survival and reproduction change with age" (three-step build).
# Schematic, not data: relative mortality risk and fertility of humans across
# six life stages, drawn as smooth curves through hand-chosen values.
# Mortality is U-shaped ("bathtub"): high in infancy, lowest in childhood,
# rising steeply in old age. Fertility is zero before puberty, peaks in early
# adulthood and falls to zero later. Stages are drawn with equal widths even
# though they differ in length (stated in the speaker notes).
# Photos carried over from the previous version of the lecture (images/source).
source("R/theme_bb512.R")
library(ggplot2)

stages <- c("Baby", "Child", "Teen", "Adult", "Middle age", "Elderly")
files  <- sprintf("images/source/stage%d_%s.png", 1:6,
                  c("baby", "child", "teen", "adult", "middle", "elderly"))
mort   <- c(0.40, 0.04, 0.07, 0.10, 0.30, 0.95)  # relative mortality risk
fert   <- c(0.00, 0.00, 0.12, 0.95, 0.30, 0.00)  # relative fertility

tile_aspect <- 1.45                               # width / height of each photo
crop_to <- function(img, aspect) {                # centre-crop a raster array
  h <- dim(img)[1]; w <- dim(img)[2]
  if (w / h > aspect) { nw <- round(h * aspect); x0 <- (w - nw) %/% 2
    img[, (x0 + 1):(x0 + nw), , drop = FALSE]
  } else { nh <- round(w / aspect); y0 <- (h - nh) %/% 2
    img[(y0 + 1):(y0 + nh), , , drop = FALSE] }
}
imgs <- lapply(files, function(f) crop_to(png::readPNG(f)[, , 1:3], tile_aspect))

# Photo strip occupies y in [-1.25, -0.15]; curves occupy y in [0, 1]
y_lo <- -1.25; y_hi <- -0.15
curve_df <- function(v, what) {
  s <- spline(1:6, v, n = 200, method = "natural")
  data.frame(x = s$x, y = pmax(s$y, 0), what = what)
}

base_plot <- function() {
  p <- ggplot() +
    coord_cartesian(xlim = c(0.5, 6.5), ylim = c(-1.55, 1.08), expand = FALSE, clip = "off") +
    theme_bb512() +
    theme(axis.title = element_blank(), axis.text = element_blank(),
          axis.line = element_blank(), panel.grid.major.y = element_blank(),
          plot.margin = margin(10, 20, 6, 20, "pt"))
  for (i in 1:6) {
    p <- p + annotation_raster(imgs[[i]], xmin = i - 0.47, xmax = i + 0.47,
                               ymin = y_lo, ymax = y_hi, interpolate = TRUE)
  }
  p + annotate("text", x = 1:6, y = -1.43, label = stages, size = 5.6,
               family = "Avenir Next", colour = bb512$ink) +
    annotate("segment", x = 0.53, xend = 6.47, y = 0, yend = 0,
             colour = bb512$grey, linewidth = 0.5,
             arrow = arrow(length = unit(6, "pt"), type = "closed"))
}

mort_layer <- list(
  geom_line(data = curve_df(mort, "m"), aes(x, y), colour = bb512$clay, linewidth = 1.5),
  annotate("text", x = 5.85, y = 0.97, label = "Mortality risk", hjust = 1,
           size = 6, fontface = "bold", family = "Avenir Next", colour = bb512$clay))
fert_layer <- list(
  geom_line(data = curve_df(fert, "f"), aes(x, y), colour = bb512$forest, linewidth = 1.5),
  annotate("text", x = 3.35, y = 0.72, label = "Fertility", hjust = 1,
           size = 6, fontface = "bold", family = "Avenir Next", colour = bb512$forest))

save_bb512(base_plot(), "01a_stages", layout = "full")
save_bb512(base_plot() + mort_layer, "01b_stages_mortality", layout = "full")
save_bb512(base_plot() + mort_layer + fert_layer, "01c_stages_mortality_fertility", layout = "full")
