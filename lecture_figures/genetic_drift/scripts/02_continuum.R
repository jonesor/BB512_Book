# Slide: "Adaptive and neutral evolution are ends of a continuum" (Title & Photo, "full")
# Illustrative simulated data (not empirical): reproductive success vs trait value
# with strong, weak and zero correlation. Seed fixed for reproducibility.
source("R/theme_bb512.R"); library(ggplot2)
set.seed(512)
n <- 30
make <- function(r, lab) {
  # Force the SAMPLE correlation to equal r exactly, so each panel shows what it claims
  x <- as.numeric(scale(rnorm(n)))
  e <- residuals(lm(rnorm(n) ~ x)); e <- as.numeric(scale(e))
  y <- r * x + sqrt(1 - r^2) * e
  data.frame(x = x, y = y, panel = lab)
}
labs3 <- c("Strong correlation: adaptive", "Weak correlation", "No correlation: neutral")
d <- rbind(make(0.9, labs3[1]), make(0.35, labs3[2]), make(0, labs3[3]))
d$panel <- factor(d$panel, levels = labs3)
cols <- setNames(c(bb512$forest, bb512$gold, bb512$blue), labs3)

fig <- ggplot(d, aes(x, y, colour = panel)) +
  geom_point(size = 3.2, alpha = 0.9) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, linewidth = 1,
              colour = bb512$grey, linetype = "dashed") +
  facet_wrap(~panel) +
  scale_colour_manual(values = cols, guide = "none") +
  labs(x = "Trait value", y = "Reproductive success") +
  theme_bb512() +
  theme(axis.text = element_blank(), panel.grid.major.y = element_blank(),
        panel.spacing = unit(2, "lines"))
save_bb512(fig, "02_continuum", layout = "full")
