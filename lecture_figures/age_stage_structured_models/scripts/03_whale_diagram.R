# Life cycle diagram for resident killer whales (Orcinus orca), females only.
# Empirical: Brault & Caswell (1993), all pods combined (A_whale in R/mpm_models.R).
source("R/theme_bb512.R"); source("R/mpm_models.R"); source("R/diagram_helpers.R")
W <- 11.733; H <- 3.95
A <- A_whale
nodes <- data.frame(id = c("Y", "J", "M", "P"), x = c(1.7, 4.4, 7.1, 9.8), y = 1.72,
                    label = c("Yearling", "Juvenile", "Mature", "Post-\nrepro."))
f2 <- function(x) formatC(x, format = "f", digits = 2)
e <- rbind(edge("Y", "J", f2(A[2, 1]), "survival", label_dy = 0.28),
           edge("J", "M", f2(A[3, 2]), "survival", label_dy = 0.28),
           edge("M", "P", f2(A[4, 3]), "survival", label_dy = 0.28),
           edge("J", "J", f2(A[2, 2]), "stasis", a_out = -90),
           edge("M", "M", f2(A[3, 3]), "stasis", a_out = -90),
           edge("P", "P", f2(A[4, 4]), "stasis", a_out = -90),
           edge("J", "Y", formatC(A[1, 2], format = "f", digits = 3), "fertility", a_out = 115, a_in = 70, k = 0.75),
           edge("M", "Y", f2(A[1, 3]), "fertility", a_out = 105, a_in = 88, k = 1.3))
save_bb512(lc_plot(nodes, e, W, H, r = 0.7, node_text_size = 5.0), "03_whale_diagram", layout = "full")
