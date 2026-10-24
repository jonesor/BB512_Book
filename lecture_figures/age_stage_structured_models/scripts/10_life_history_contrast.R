# Elasticity of lambda split into reproduction, survival of pre-breeding stages and survival of
# breeding (and older) stages, for a fast (red fox) and two slow (loggerhead, killer whale)
# life histories. Analytical, from the three empirical matrices in R/mpm_models.R.
source("R/theme_bb512.R"); source("R/mpm_models.R")
library(ggplot2)
split_elas <- function(A, Fm, adult_cols) {
  E <- mpm_elas(A); Es <- E * (Fm == 0)            # survival (stay or move) elements only
  c(Reproduction = sum(E[Fm > 0]),
    "Survival, pre-breeding" = sum(Es[, -adult_cols]),
    "Survival, breeders" = sum(Es[, adult_cols]))
}
sp <- list("Red fox" = split_elas(A_fox, F_fox, 2:4),
           "Loggerhead turtle" = split_elas(A_crouse, F_crouse, 5:7),
           "Killer whale" = split_elas(A_whale, F_whale, 3:4))
d <- do.call(rbind, lapply(names(sp), function(n) data.frame(species = n, type = names(sp[[n]]), e = sp[[n]])))
d$species <- factor(d$species, levels = rev(names(sp)))
d$type <- factor(d$type, levels = c("Reproduction", "Survival, pre-breeding", "Survival, breeders"))
p <- ggplot(d, aes(e, species, fill = type)) +
  geom_col(width = 0.62, position = position_stack(reverse = TRUE)) +
  geom_text(aes(label = ifelse(e >= 0.08, formatC(e, format = "f", digits = 2), "")),
            position = position_stack(vjust = 0.5, reverse = TRUE), colour = "white", size = 5.2,
            family = "Avenir Next", fontface = "bold") +
  scale_fill_manual(values = c("Reproduction" = bb512$clay, "Survival, pre-breeding" = bb512$blue,
                               "Survival, breeders" = bb512$forest), name = NULL) +
  scale_x_continuous(limits = c(0, 1.001), breaks = seq(0, 1, 0.25), expand = c(0, 0)) +
  guides(fill = guide_legend(nrow = 2, byrow = TRUE)) +
  labs(x = "Share of total elasticity", y = NULL) +
  theme_bb512() +
  theme(panel.grid.major.y = element_blank(), panel.grid.major.x = element_line(colour = bb512$grid),
        axis.text.y = element_text(size = 16, colour = bb512$ink), legend.text = element_text(size = 14))
save_bb512(p, "10_life_history_contrast", layout = "takeaway")
