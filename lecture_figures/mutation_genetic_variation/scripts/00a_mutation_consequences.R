# Slide 6: "Mutations have different consequences" (Title & Photo, "fullbox")
# Schematic, not data. Four point-mutation outcomes for the codon GAA (glutamic acid):
#   synonymous GAA -> GAG (Glu -> Glu), missense GAA -> GCA (Glu -> Ala),
#   nonsense GAA -> TAA (Glu -> STOP), frameshift: insert C after ATG.
# Codon assignments from the standard genetic code. Changed bases in clay.
# R version of the matplotlib diagram previously pasted into the deck.
source("R/theme_bb512.R")
library(ggplot2)

fam <- "Avenir Next"

# One row of bases, laid out letter by letter so changed bases can be coloured.
# 'changed' gives the positions (1-based, in the string without spaces) to colour clay.
bases_df <- function(seq, x0, y, changed = integer(0), step = 0.021) {
  ch <- strsplit(seq, "")[[1]]
  x <- x0; out <- list(); k <- 0
  for (c in ch) {
    if (c == " ") { x <- x + step * 0.55; next }
    k <- k + 1
    out[[k]] <- data.frame(x = x, y = y, lab = c,
                           col = if (k %in% changed) bb512$clay else bb512$ink)
    x <- x + step
  }
  do.call(rbind, out)
}

panels <- data.frame(
  title = c("Synonymous", "Missense", "Nonsense", "Frameshift"),
  px    = c(0, 0.5, 0, 0.5),
  py    = c(0.5, 0.5, 0, 0)
)
w <- 0.485; h <- 0.47

# Per-panel content: before, after, changed positions in 'after', protein line, effect
content <- list(
  list(before = "GAA", after = "GAG", chg = 3, prot = "Glu %->% Glu",
       effect = "Same amino acid", ecol = bb512$forest),
  list(before = "GAA", after = "GCA", chg = 2, prot = "Glu %->% Ala",
       effect = "Different amino acid", ecol = bb512$gold),
  list(before = "GAA", after = "TAA", chg = 1, prot = "Glu %->% STOP",
       effect = "Premature termination", ecol = bb512$clay),
  list(before = "ATG GAA TTT", after = "ATG CGA ATT", chg = 4, prot = "Met~Glu~Phe %->% Met~Arg~Ile~\"...\"",
       effect = "Insert C after ATG: reading frame shifts", ecol = bb512$clay)
)

boxes <- transform(panels, xmin = px + 0.008, xmax = px + w, ymin = py + 0.015, ymax = py + h)
letters_df <- data.frame(); arrows_df <- data.frame(); txt_df <- data.frame()
for (i in seq_len(nrow(panels))) {
  cx <- panels$px[i] + 0.035; cy <- panels$py[i]
  ci <- content[[i]]
  st <- if (nchar(ci$before) > 3) 0.0165 else 0.021
  b <- bases_df(ci$before, cx, cy + 0.27, step = st)
  a_x0 <- max(b$x) + 0.07
  a <- bases_df(ci$after, a_x0, cy + 0.27, changed = ci$chg, step = st)
  letters_df <- rbind(letters_df, b, a)
  arrows_df <- rbind(arrows_df, data.frame(x = max(b$x) + 0.02, xend = a_x0 - 0.022,
                                           y = cy + 0.27))
  txt_df <- rbind(txt_df,
    data.frame(x = cx, y = cy + 0.385, lab = panels$title[i], col = bb512$forest,
               size = 6.2, face = "bold", parse = FALSE),
    data.frame(x = cx, y = cy + 0.15, lab = ci$prot, col = bb512$ink,
               size = 5.2, face = "plain", parse = TRUE),
    data.frame(x = cx, y = cy + 0.07, lab = ci$effect, col = ci$ecol,
               size = 5.2, face = "plain", parse = FALSE))
}

p <- ggplot() +
  geom_rect(data = boxes, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            fill = bb512$pale, colour = NA) +
  geom_text(data = letters_df, aes(x, y, label = lab, colour = col),
            size = 7, fontface = "bold", family = fam, hjust = 0.5) +
  geom_segment(data = arrows_df, aes(x = x, xend = xend, y = y, yend = y),
               colour = bb512$grey, linewidth = 0.9,
               arrow = arrow(length = unit(0.12, "in"), type = "closed")) +
  geom_text(data = subset(txt_df, !parse), aes(x, y, label = lab, colour = col,
            size = size, fontface = face), family = fam, hjust = 0) +
  geom_text(data = subset(txt_df, parse), aes(x, y, label = lab, colour = col, size = size),
            family = fam, hjust = 0, parse = TRUE) +
  scale_colour_identity() + scale_size_identity() +
  coord_cartesian(xlim = c(0, 1), ylim = c(0, 0.985), expand = FALSE, clip = "off") +
  theme_void() +
  theme(plot.background = element_rect(fill = bb512$bg, colour = NA),
        plot.margin = margin(6, 6, 6, 6))

save_bb512(p, "00a_mutation_consequences", layout = "fullbox")
