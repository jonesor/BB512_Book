# Slide "Kettlewell's mark-release-recapture experiments": recapture rates by morph and wood.
# Empirical: Kettlewell (1956), as tabulated in Neal (2004) Table 11.1.
# Birmingham (polluted): carbonaria 82/154, typica 16/64. Dorset (unpolluted): carbonaria 30/473, typica 62/496.
source("R/theme_bb512.R")
fam <- "Avenir Next"
df <- data.frame(site = factor(rep(c("Polluted wood\n(near Birmingham)", "Unpolluted wood\n(Dorset)"), each = 2),
                               levels = c("Polluted wood\n(near Birmingham)", "Unpolluted wood\n(Dorset)")),
                 morph = factor(rep(c("carbonaria", "typica"), 2), levels = c("carbonaria", "typica")),
                 rel = c(154, 64, 473, 496), rec = c(82, 16, 30, 62))
df$rate <- 100 * df$rec / df$rel
df$lab <- sprintf("%.0f%%\n(%d/%d)", df$rate, df$rec, df$rel)
p <- ggplot2::ggplot(df, ggplot2::aes(morph, rate, fill = morph)) +
  ggplot2::geom_col(width = 0.62) +
  ggplot2::geom_text(ggplot2::aes(label = lab), vjust = -0.25, family = fam, size = 5, lineheight = 0.9,
                     colour = bb512$ink) +
  ggplot2::facet_wrap(~site) +
  ggplot2::scale_fill_manual(values = c(carbonaria = bb512$ink, typica = bb512$sage), guide = "none") +
  ggplot2::scale_y_continuous(limits = c(0, 72), breaks = seq(0, 60, 20)) +
  ggplot2::labs(x = NULL, y = "Recaptured (%)") +
  theme_bb512() +
  ggplot2::theme(axis.text.x = ggplot2::element_text(face = "italic", size = 16, colour = bb512$ink),
                 panel.spacing = grid::unit(0.4, "in"))
save_bb512(p, "11_kettlewell", layout = "takeaway")
