# Slide "Cumulative selection": single-step versus cumulative selection for the 28-character
# target METHINKS IT IS LIKE A WEASEL (Dawkins 1986; Neal, 'Understanding natural selection').
# SIMULATED. 27 possible characters (A-Z and space). Each generation every character is re-typed
# at random. Cumulative selection: a character that matches the target is kept from then on
# (the same rule as the Blind Watchmaker practical). Single-step: nothing is kept.
# Analytical comparison: P(whole phrase typed correctly at random) = (1/27)^28 = 8.4e-41.
# Seed 512.
source("R/theme_bb512.R")
fam <- "Avenir Next"
set.seed(512)
target <- strsplit("METHINKS IT IS LIKE A WEASEL", "")[[1]]
pool <- c(LETTERS, " ")
n_gen <- 150
run <- function(keep) {
  fixed <- rep(FALSE, length(target)); out <- integer(n_gen)
  for (g in seq_len(n_gen)) {
    guess <- sample(pool, length(target), replace = TRUE)
    if (keep) { guess[fixed] <- target[fixed]; fixed <- fixed | guess == target }
    out[g] <- sum(guess == target)
  }
  out
}
cum <- run(TRUE); single <- run(FALSE)
done <- which(cum == length(target))[1]
message("Cumulative selection reached the target in generation ", done)
df <- rbind(data.frame(gen = 1:n_gen, correct = cum, type = "Keep correct letters"),
            data.frame(gen = 1:n_gen, correct = single, type = "Random typing only"))
p <- ggplot2::ggplot(df, ggplot2::aes(gen, correct, colour = type)) +
  ggplot2::geom_hline(yintercept = 28, linetype = "dashed", colour = bb512$grey, linewidth = 0.7) +
  ggplot2::geom_step(linewidth = 1.3) +
  ggplot2::annotate("text", x = 150, y = 29.8, label = "Whole phrase (28 characters)", hjust = 1,
                    family = fam, size = 5, colour = bb512$grey) +
  ggplot2::annotate("text", x = 150, y = 6.3, label = "Random typing only", hjust = 1,
                    family = fam, size = 5.5, fontface = "bold", colour = bb512$clay) +
  ggplot2::annotate("text", x = 62, y = 15, label = paste0("Keep correct letters:\ndone in ", done, " generations"),
                    hjust = 0, family = fam, size = 5.5, fontface = "bold", colour = bb512$forest, lineheight = 0.9) +
  ggplot2::scale_colour_manual(values = c("Keep correct letters" = bb512$forest,
                                          "Random typing only" = bb512$clay), guide = "none") +
  ggplot2::scale_y_continuous(limits = c(0, 31), breaks = seq(0, 28, 7)) +
  ggplot2::labs(x = "Generation", y = "Correct characters") +
  theme_bb512()
save_bb512(p, "03_cumulative_selection", layout = "takeaway")
