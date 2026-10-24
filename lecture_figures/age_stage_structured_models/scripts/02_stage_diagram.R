# Stage-based life cycle diagram (juvenile, adult, post-reproductive), built in three steps:
# (a) progression, (b) + reproduction, (c) + staying in a stage.
# Illustrative values (A_jas in R/mpm_models.R), from the previous version of the lecture.
source("R/theme_bb512.R"); source("R/mpm_models.R"); source("R/diagram_helpers.R")
W <- 11.733; H <- 3.95
nodes <- data.frame(id = c("J", "A", "S"), x = c(2.6, 5.9, 9.2), y = 1.75,
                    label = c("Juvenile", "Adult", "Post-\nrepro."))
f2 <- function(x) formatC(x, format = "f", digits = 2)
prog <- rbind(edge("J", "A", f2(A_jas[2, 1]), "survival", label_dy = 0.3),
              edge("A", "S", f2(A_jas[3, 2]), "survival", label_dy = 0.3))
repro <- edge("A", "J", f2(A_jas[1, 2]), "fertility", a_out = 115, a_in = 65, k = 1.0)
stay <- rbind(edge("J", "J", f2(A_jas[1, 1]), "stasis", a_out = -90),
              edge("A", "A", f2(A_jas[2, 2]), "stasis", a_out = -90),
              edge("S", "S", f2(A_jas[3, 3]), "stasis", a_out = -90))
r <- 0.8
save_bb512(lc_plot(nodes, prog, W, H, r = r, node_text_size = 5.2), "02a_stage_progression", layout = "full")
save_bb512(lc_plot(nodes, rbind(prog, repro), W, H, r = r, node_text_size = 5.2), "02b_stage_reproduction", layout = "full")
p_full <- lc_plot(nodes, rbind(prog, repro, stay), W, H, r = r, node_text_size = 5.2)
save_bb512(p_full, "02c_stage_full", layout = "full")
# same diagram for the "Your turn" slide (Title, Bullets & Photo layout)
save_bb512(lc_plot(nodes, rbind(prog, repro, stay), W, H, r = r, node_text_size = 5.0) +
             coord_fixed(xlim = c(0.95, 10.85), ylim = c(-0.25, 4.15), expand = FALSE),
           "02d_stage_full_takeaway", layout = "takeaway")
