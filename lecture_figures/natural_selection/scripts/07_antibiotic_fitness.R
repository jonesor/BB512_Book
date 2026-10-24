# Slide "Antibiotic resistance: favoured or costly": growth of susceptible and resistant
# bacteria without and with an antibiotic.
# ILLUSTRATIVE VALUES, not data: relative growth rate scaled so that susceptible bacteria
# without antibiotic = 1. Resistant bacteria carry a cost (0.9) whether or not the drug is
# present; with the drug, susceptible growth falls to 0.05. The direction of selection reverses
# with the environment (cf. Andersson & Hughes 2010, Nat. Rev. Microbiol.: many, not all,
# resistance mutations are costly without the antibiotic).
source("R/theme_bb512.R")
fam <- "Avenir Next"
envs <- c("No antibiotic", "With antibiotic")
df <- data.frame(env = factor(rep(envs, each = 2), levels = envs),
                 type = factor(rep(c("Susceptible", "Resistant"), 2), levels = c("Susceptible", "Resistant")),
                 growth = c(1.00, 0.90, 0.05, 0.90))
df$wins <- c(TRUE, FALSE, FALSE, TRUE)
p <- ggplot2::ggplot(df, ggplot2::aes(type, growth, fill = wins)) +
  ggplot2::geom_col(width = 0.7) +
  ggplot2::geom_text(data = df[df$wins, ], ggplot2::aes(label = "Favoured"), hjust = -0.12,
                     family = fam, size = 5, fontface = "bold", colour = bb512$forest) +
  ggplot2::facet_wrap(~env, ncol = 1) +
  ggplot2::coord_flip() +
  ggplot2::scale_fill_manual(values = c(`TRUE` = bb512$forest, `FALSE` = bb512$sage), guide = "none") +
  ggplot2::scale_y_continuous(limits = c(0, 1.45), breaks = c(0, 0.5, 1)) +
  ggplot2::labs(x = NULL, y = "Growth rate (illustrative)") +
  theme_bb512() +
  ggplot2::theme(axis.text.y = ggplot2::element_text(size = 15, colour = bb512$ink),
                 panel.grid.major.y = ggplot2::element_blank(),
                 panel.grid.major.x = ggplot2::element_line(colour = bb512$grid, linewidth = 0.5),
                 panel.spacing = ggplot2::unit(1, "lines"))
save_bb512(p, "07_antibiotic_fitness", layout = "half")
