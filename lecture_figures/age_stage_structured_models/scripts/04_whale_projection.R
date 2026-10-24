# Deterministic projection of the killer whale model from two starting populations.
# Analytical (matrix multiplication, no randomness). Empirical matrix: Brault & Caswell (1993).
source("R/theme_bb512.R"); source("R/mpm_models.R")
library(ggplot2)
years <- 60
starts <- list("Start: 100 yearlings" = c(100, 0, 0, 0),
               "Start: 25 in every stage" = c(25, 25, 25, 25))
d <- do.call(rbind, lapply(names(starts), function(s) {
  pr <- mpm_project(A_whale, starts[[s]], years)
  long <- stack(pr[, -1]); long$year <- rep(pr$year, ncol(pr) - 1)
  data.frame(start = s, year = long$year, stage = long$ind, n = long$values)
}))
d$start <- factor(d$start, levels = names(starts))
d$stage <- factor(d$stage, levels = whale_stages)
d <- d[d$n > 0.5, ]                       # log scale: drop stages not yet present
cols <- setNames(c(bb512$forest, bb512$clay, bb512$blue, bb512$gold), whale_stages)
lab <- d[d$year == years, ]
lab <- do.call(rbind, lapply(split(lab, lab$start), function(z) {
  z <- z[order(z$n), ]; ly <- log10(z$n)
  ly0 <- ly
  for (i in seq_along(ly)[-1]) ly[i] <- max(ly[i], ly[i - 1] + 0.42)
  ly <- ly - (max(ly) - max(ly0)) / 2          # centre the spread on the line ends
  z$ny <- 10^ly; z
}))
lab$short <- c(Yearling = "Yearl.", Juvenile = "Juv.", Mature = "Mature",
               "Post-reproductive" = "Post-r.")[as.character(lab$stage)]
p <- ggplot(d, aes(year, n, colour = stage)) +
  geom_line(linewidth = 1.3) +
  geom_text(data = lab, aes(y = ny, label = short), hjust = 0, nudge_x = 1.2, size = 5,
            family = "Avenir Next", fontface = "bold", show.legend = FALSE) +
  facet_wrap(~start) +
  scale_y_log10(breaks = c(1, 10, 100, 1000), limits = c(0.5, 1000)) +
  scale_x_continuous(breaks = seq(0, years, 20), limits = c(0, years + 13)) +
  scale_colour_manual(values = cols, guide = "none") +
  labs(x = "Year", y = "Number of females (log scale)") +
  theme_bb512()
save_bb512(p, "04_whale_projection", layout = "full")
