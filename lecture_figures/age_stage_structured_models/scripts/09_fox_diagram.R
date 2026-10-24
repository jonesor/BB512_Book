# Life cycle diagram for the red fox (Vulpes vulpes), Bristol, UK; females, age classes.
# Empirical: Devenish-Nelson et al. (2013) via COMADRE (A_fox in R/mpm_models.R).
source("R/theme_bb512.R"); source("R/mpm_models.R"); source("R/diagram_helpers.R")
W <- 11.733; H <- 3.95
A <- A_fox
nodes <- data.frame(id = paste0("a", 0:3), x = c(1.95, 4.8, 7.65, 10.3), y = 1.5,
                    label = c("Age 0", "Age 1", "Age 2", "Age 3+"))
f2 <- function(x) formatC(x, format = "f", digits = 2)
e <- rbind(edge("a0", "a1", f2(A[2, 1]), "survival", label_dy = 0.3),
           edge("a1", "a2", f2(A[3, 2]), "survival", label_dy = 0.3),
           edge("a2", "a3", f2(A[4, 3]), "survival", label_dy = 0.3),
           edge("a3", "a3", f2(A[4, 4]), "stasis", a_out = -90),
           edge("a0", "a0", f2(A[1, 1]), "fertility_loop", a_out = -150, label_dx = -0.1, label_dy = 0.05),
           edge("a1", "a0", f2(A[1, 2]), "fertility", a_out = 110, a_in = 70, k = 0.65),
           edge("a2", "a0", f2(A[1, 3]), "fertility", a_out = 105, a_in = 82, k = 1.15),
           edge("a3", "a0", f2(A[1, 4]), "fertility", a_out = 100, a_in = 90, k = 1.65))
save_bb512(lc_plot(nodes, e, W, H), "09_fox_diagram", layout = "full")
