# Answer, Part 4: prey refuge Hr = 0, 100, 200, 400 prey (dt = 1, 300 time units). Prey through time.
# Hr = 0: prey hit zero at t = 220. DETERMINISTIC simulations. Layout: full.
source("R/theme_bb512.R"); source("R/pp_model.R")
library(ggplot2)
d <- do.call(rbind, lapply(c(0, 100, 200, 400), function(Hr) {
  s <- pp_sim(Hr = Hr, dt = 1, total = 300)
  data.frame(t = s$t, H = s$H, Hr = paste0("H[r] == ", Hr))
}))
d$Hr <- factor(d$Hr, levels = unique(d$Hr))
d$H[d$H <= 0] <- NA   # zero cannot be shown on a log scale: mark extinction instead
ext <- data.frame(Hr = factor(levels(d$Hr)[1], levels = levels(d$Hr)), t = 220, H = 1.5)
p <- ggplot(d, aes(t, H)) +
  geom_line(colour = bb512$forest, linewidth = 0.9, na.rm = TRUE) +
  geom_point(data = ext, colour = bb512$clay, size = 3) +
  geom_label(data = ext, aes(label = "extinct\nt = 220"), hjust = 0, nudge_x = 10, vjust = 0.2,
             family = "Avenir Next", size = 3.8, colour = bb512$clay, fill = bb512$bg, label.size = 0,
             lineheight = 0.9) +
  facet_wrap(~Hr, nrow = 1, labeller = label_parsed) +
  scale_y_log10(name = "Prey (H), log scale", labels = scales::label_comma(), breaks = c(1, 10, 100, 1000, 10000)) +
  coord_cartesian(ylim = c(1, 20000)) +
  scale_x_continuous(name = "Time (t)", breaks = c(0, 100, 200, 300)) +
  theme_bb512() + theme(axis.text = element_text(size = 12), panel.spacing = unit(1.2, "lines"))
save_bb512(p, "08_refuge", layout = "full")
