# Answer, Part 2 task 4: doubling r, a, c or d moves one isocline each.
# Analytical schematic: grey = worksheet values (P = r/a = 25, H = d/c = 1250); colour = after doubling.
# Layout: full.
source("R/theme_bb512.R"); source("R/pp_model.R")
library(ggplot2)
cases <- data.frame(
  panel = factor(c("r doubled", "a doubled", "c doubled", "d doubled"),
                 levels = c("r doubled", "a doubled", "c doubled", "d doubled")),
  Pstar = c(50, 12.5, 25, 25), Hstar = c(1250, 1250, 625, 2500))
lab <- data.frame(panel = cases$panel, x = 2950, y = 57,
                  txt = c("P* = r/a: 25 to 50", "P* = r/a: 25 to 12.5",
                          "H* = d/c: 1250 to 625", "H* = d/c: 1250 to 2500"))
p <- ggplot(cases) +
  geom_hline(yintercept = 25, colour = bb512$sage, linewidth = 1, linetype = "22") +
  geom_vline(xintercept = 1250, colour = bb512$sage, linewidth = 1, linetype = "22") +
  geom_hline(aes(yintercept = Pstar), colour = bb512$forest, linewidth = 1.3) +
  geom_vline(aes(xintercept = Hstar), colour = bb512$clay, linewidth = 1.3) +
  geom_point(aes(Hstar, Pstar), shape = 21, size = 3.4, stroke = 1.1, colour = bb512$ink, fill = bb512$bg) +
  geom_label(data = lab, aes(x, y, label = txt), hjust = 1, family = "Avenir Next", size = 4.0,
             colour = bb512$ink, fill = bb512$bg, label.size = 0) +
  facet_wrap(~panel, nrow = 1) +
  scale_x_continuous(name = "Prey (H)", limits = c(0, 3000), breaks = c(0, 1250, 2500),
                     labels = scales::label_comma(), expand = expansion(mult = c(0, 0.02))) +
  scale_y_continuous(name = "Predators (P)", limits = c(0, 60), breaks = c(0, 25, 50),
                     expand = expansion(mult = c(0, 0.02))) +
  theme_bb512() + theme(axis.text = element_text(size = 12), panel.spacing = unit(1.4, "lines"))
save_bb512(p, "05_answer_isoclines", layout = "full")
