# Slide: "The gene pool model" (Title & Photo, "full")
# Conceptual schematic (no data): parents -> gene pool of 2N gene copies -> offspring
# drawn at random WITH replacement. Offspring are a chance sample: here p shifts 0.5 -> 0.7.
source("R/theme_bb512.R"); source("R/drift_helpers.R"); library(ggplot2)
set.seed(17)
colA <- bb512$clay; cola <- bb512$blue

geno_df <- function(x0, genos, y = 0) {
  do.call(rbind, lapply(seq_along(genos), function(i) {
    al <- strsplit(genos[i], "")[[1]]
    data.frame(x = x0 + c(-0.17, 0.17), y = y + (length(genos) + 1) / 2 - i, allele = al, ind = i)
  }))
}
parents   <- c("AA", "Aa", "aa", "Aa", "Aa")   # 5 A of 10: p = 0.5
offspring <- c("AA", "Aa", "AA", "aA", "Aa")   # 7 A of 10: p = 0.7
P <- geno_df(0, parents); O <- geno_df(8.4, offspring)

# Gene pool: many copies at p = 0.5, placed without overlap (guarded loop)
n_pool <- 36; pool <- data.frame(x = numeric(0), y = numeric(0))
tries <- 0
while (nrow(pool) < n_pool && tries < 20000) {
  tries <- tries + 1
  cand <- c(runif(1, 2.85, 5.15), runif(1, -1.75, 1.75))
  if (nrow(pool) == 0 || min(sqrt((pool$x - cand[1])^2 + (pool$y - cand[2])^2)) > 0.42)
    pool <- rbind(pool, data.frame(x = cand[1], y = cand[2]))
}
pool$allele <- sample(rep(c("A", "a"), length.out = nrow(pool)))

alle <- rbind(P[, c("x", "y", "allele")], O[, c("x", "y", "allele")], pool)
boxes <- rbind(
  data.frame(xmin = -0.42, xmax = 0.42, ymin = P$y[c(TRUE, FALSE)] - 0.36, ymax = P$y[c(TRUE, FALSE)] + 0.36),
  data.frame(xmin = 7.98, xmax = 8.82, ymin = O$y[c(TRUE, FALSE)] - 0.36, ymax = O$y[c(TRUE, FALSE)] + 0.36))

fig <- ggplot() +
  annotate("rect", xmin = 2.55, xmax = 5.45, ymin = -2.1, ymax = 2.1,
           fill = bb512$pale, colour = bb512$sage, linewidth = 0.8) +
  geom_rect(data = boxes, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            fill = bb512$pale, colour = bb512$sage, linewidth = 0.6) +
  geom_point(data = alle, aes(x, y, colour = allele), size = 7.5) +
  geom_text(data = alle, aes(x, y, label = allele), colour = "white", size = 5,
            fontface = "bold.italic", family = .bb512_font) +
  annotate("segment", x = c(0.7, 5.75), xend = c(2.25, 7.65), y = 0, yend = 0,
           arrow = arrow(length = unit(0.18, "in"), type = "closed"),
           colour = bb512$grey, linewidth = 1) +
  bb_text(x = c(1.475, 6.7), y = 0.45, label = c("gametes", "random draws"),
          size = 5, colour = bb512$grey) +
  bb_text(x = 6.7, y = -0.45, label = "with replacement", size = 5, colour = bb512$grey) +
  bb_text(x = c(0, 4, 8.4), y = 2.6, label = c("Parents", "Gene pool", "Offspring"),
          size = 6.5, fontface = "bold", colour = bb512$ink) +
  bb_text(x = c(0, 4, 8.4), y = -2.6, size = 5.5, colour = bb512$ink,
          label = c("italic(p) == 0.5", "italic(p) == 0.5", "italic(p) == 0.7"), parse = TRUE) +
  scale_colour_manual(values = c(A = colA, a = cola), guide = "none") +
  coord_fixed(xlim = c(-0.9, 9.3), ylim = c(-2.9, 2.9), expand = FALSE) +
  theme_void() +
  theme(plot.background = element_rect(fill = bb512$bg, colour = NA))
save_bb512(fig, "04_gene_pool", layout = "full")
