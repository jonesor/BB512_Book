# Elasticity of lambda for the loggerhead turtle model of Crouse, Crowder & Caswell (1987),
# by stage and type of transition. Analytical, from the published matrix (R/mpm_models.R).
source("R/theme_bb512.R"); source("R/mpm_models.R")
library(ggplot2)
E <- mpm_elas(A_crouse)
short <- c("Eggs", "Small\njuv.", "Large\njuv.", "Sub-\nadults", "Novice\nbreed.", "Remi-\ngrants", "Mature\nbreed.")
d <- rbind(data.frame(stage = 1:7, type = "Stay in stage", e = diag(E)),
           data.frame(stage = 1:7, type = "Grow to next stage", e = c(E[cbind(2:7, 1:6)], 0)),
           data.frame(stage = 1:7, type = "Reproduce", e = E[1, ]))
d$type <- factor(d$type, levels = c("Reproduce", "Grow to next stage", "Stay in stage"))
p <- ggplot(d, aes(factor(stage), e, fill = type)) +
  geom_col(width = 0.7) +
  scale_fill_manual(values = c("Reproduce" = bb512$clay, "Grow to next stage" = bb512$blue,
                               "Stay in stage" = bb512$forest), name = NULL) +
  scale_x_discrete(labels = short) +
  scale_y_continuous(limits = c(0, 0.3), breaks = seq(0, 0.3, 0.1)) +
  labs(x = NULL, y = "Elasticity") +
  theme_bb512() +
  theme(axis.text.x = element_text(size = 14, lineheight = 0.9), legend.margin = margin(0, 0, 0, 0))
save_bb512(p, "07_crouse_elasticity", layout = "takeaway")
