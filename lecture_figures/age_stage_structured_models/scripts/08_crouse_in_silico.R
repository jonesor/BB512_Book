# In silico experiment on the loggerhead model (Crouse et al. 1987 matrix):
# lambda when the annual mortality of ONE stage is halved, plus 100% egg survival.
# Analytical. As in Crouse et al. (1987), stay (P) and grow (G) are recalculated from
# annual survival and stage duration (crouse_from_survival() in R/mpm_models.R).
source("R/theme_bb512.R"); source("R/mpm_models.R")
library(ggplot2)
lam0 <- mpm_lambda(A_crouse)
s1 <- crouse_sigma; s1[1] <- 1
short <- c("Eggs", "Small\njuv.", "Large\njuv.", "Sub-\nadults", "Novice\nbreed.", "Remi-\ngrants", "Mature\nbreed.")
d <- data.frame(stage = factor(short, levels = short),
                lambda = sapply(1:7, function(k) mpm_lambda(crouse_halve_mortality(k))))
d$best <- d$lambda == max(d$lambda)
egg100 <- mpm_lambda(crouse_from_survival(s1))
p <- ggplot(d, aes(stage, lambda)) +
  geom_hline(yintercept = 1, linetype = "dashed", colour = bb512$grey, linewidth = 0.7) +
  geom_hline(yintercept = lam0, colour = bb512$grey, linewidth = 0.7) +
  geom_segment(aes(xend = stage, y = lam0, yend = lambda, colour = best), linewidth = 1.3) +
  geom_point(aes(colour = best), size = 5) +
  geom_point(data = data.frame(stage = factor(short[1], levels = short), lambda = egg100),
             shape = 21, size = 5, stroke = 1.4, colour = bb512$gold, fill = bb512$bg) +
  annotate("text", x = 1.12, y = egg100 + 0.006, label = "100% egg\nsurvival", hjust = 0.5, vjust = 0, size = 4.9,
           lineheight = 0.9, colour = bb512$gold, family = "Avenir Next", fontface = "bold") +
  annotate("text", x = 7.45, y = 1.002, label = "stable", hjust = 1, vjust = 0, size = 4.9,
           colour = bb512$grey, family = "Avenir Next") +
  annotate("text", x = 7.45, y = lam0 - 0.0015, label = "now", hjust = 1, vjust = 1, size = 4.9,
           colour = bb512$grey, family = "Avenir Next") +
  scale_colour_manual(values = c(`TRUE` = bb512$clay, `FALSE` = bb512$forest), guide = "none") +
  scale_y_continuous(limits = c(0.935, 1.055), breaks = seq(0.94, 1.04, 0.02)) +
  labs(x = NULL, y = expression("Population growth rate (" * lambda * ")")) +
  theme_bb512() +
  theme(axis.text.x = element_text(size = 14, lineheight = 0.9))
save_bb512(p, "08_crouse_in_silico", layout = "takeaway")
