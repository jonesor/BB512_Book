# Slide "Selection is a filter": one generation of haploid selection, step by step.
# Analytical. Genotype A: frequency 0.5, W = 1. Genotype B: frequency 0.5, W = 0.75 (s = 0.25).
# Step 1: frequencies before selection. Step 2: frequency x relative fitness (contributions).
# Step 3: contributions divided by their total (mean fitness, 0.875), so they sum to 1.
source("R/theme_bb512.R")
fam <- "Avenir Next"
W <- c(A = 1, B = 0.75); f0 <- c(A = 0.5, B = 0.5)
contrib <- f0 * W; f1 <- contrib / sum(contrib)
steps <- c("1. Before selection", "2. Multiply by\nrelative fitness (W)", "3. Divide by total\n(mean fitness)")
df <- data.frame(step = factor(rep(steps, each = 2), levels = steps),
                 genotype = factor(rep(c("A", "B"), 3), levels = c("B", "A")),
                 value = c(f0, contrib, f1))
df$lab <- sprintf("%.3g", df$value)
df$lab[df$step == steps[2]] <- c("0.5 × 1\n= 0.5", "0.5 × 0.75\n= 0.375")
df$lab[df$step == steps[3]] <- c("0.5/0.875\n= 0.571", "0.375/0.875\n= 0.429")
p <- ggplot2::ggplot(df, ggplot2::aes(step, value, fill = genotype)) +
  ggplot2::geom_col(width = 0.55, colour = bb512$bg, linewidth = 1.2) +
  ggplot2::geom_text(ggplot2::aes(label = lab), position = ggplot2::position_stack(vjust = 0.5),
                     colour = "white", family = fam, size = 5, lineheight = 0.9) +
  ggplot2::annotate("text", x = 0.62, y = c(0.75, 0.25), label = c("B", "A"), hjust = 1,
                    family = fam, fontface = "bold", size = 6.5,
                    colour = c(bb512$clay, bb512$forest)) +
  ggplot2::annotate("text", x = 2, y = 0.92, label = "Total = 0.875", family = fam, size = 5,
                    colour = bb512$grey) +
  ggplot2::scale_fill_manual(values = c(A = bb512$forest, B = bb512$clay), guide = "none") +
  ggplot2::scale_y_continuous(limits = c(0, 1.0), breaks = seq(0, 1, 0.25)) +
  ggplot2::labs(x = NULL, y = "Frequency") +
  theme_bb512() +
  ggplot2::theme(axis.text.x = ggplot2::element_text(size = 16, colour = bb512$ink, lineheight = 0.9))
save_bb512(p, "04_selection_filter", layout = "full")
