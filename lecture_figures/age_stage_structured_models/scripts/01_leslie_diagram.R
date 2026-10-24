# Age-based life cycle diagram (post-breeding census), shown in two steps:
# (a) survival only, (b) survival + fertility.
# Analytical: values from the life table in R/mpm_models.R; F(x) = p(x) m(x+1).
source("R/theme_bb512.R"); source("R/mpm_models.R"); source("R/diagram_helpers.R")
W <- 11.733; H <- 3.95
nodes <- data.frame(id = paste0("a", 0:3), x = c(1.95, 4.8, 7.65, 10.5), y = 1.2,
                    label = paste("Age", 0:3))
f2 <- function(x) formatC(x, format = "f", digits = 2)
surv <- rbind(edge("a0", "a1", f2(p_x[1]), "survival", label_dy = 0.3),
              edge("a1", "a2", f2(p_x[2]), "survival", label_dy = 0.3),
              edge("a2", "a3", f2(p_x[3]), "survival", label_dy = 0.3))
fert <- rbind(edge("a0", "a0", format(Fx[1]), "fertility_loop", a_out = -150, label_dx = -0.1, label_dy = 0.05),
              edge("a1", "a0", format(Fx[2]), "fertility", a_out = 110, a_in = 70, k = 0.9),
              edge("a2", "a0", format(Fx[3]), "fertility", a_out = 105, a_in = 88, k = 1.9))
save_bb512(lc_plot(nodes, surv, W, H), "01a_leslie_survival", layout = "full")
save_bb512(lc_plot(nodes, rbind(surv, fert), W, H), "01b_leslie_full", layout = "full")
