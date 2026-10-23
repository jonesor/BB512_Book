# Slide "Lack's starlings": EMPIRICAL. Swiss starlings (Sturnus vulgaris), Lack (1948), as tabulated in
# Neal (2004), "Number of offspring" (post-fledging survival in relation to brood size).
# Bars (right axis, grey): how common each brood size was. Points: young recovered > 3 months after fledging, per brood.
# Published summary values hard-coded; 3,516 broods, 15,757 eggs, 306 young recovered.
source("R/theme_bb512.R")
fam <- "Avenir Next"

st <- data.frame(brood = 1:10,
                 broods = c(65, 164, 426, 989, 1235, 526, 93, 15, 2, 1),
                 recovered = c(0, 6, 26, 82, 128, 53, 10, 1, 0, 0))
st$prop <- st$broods / sum(st$broods)
st$per_brood <- st$recovered / st$broods
k <- max(st$per_brood) / max(st$prop)   # secondary-axis scale so both peaks reach the same height

p <- ggplot2::ggplot(st, ggplot2::aes(brood)) +
  ggplot2::geom_col(ggplot2::aes(y = prop * k), fill = bb512$sage, width = 0.75) +
  ggplot2::geom_line(ggplot2::aes(y = per_brood), colour = bb512$forest, linewidth = 1.3) +
  ggplot2::geom_point(ggplot2::aes(y = per_brood), colour = bb512$forest, size = 3.4) +
  ggplot2::annotate("text", x = 2.0, y = 0.098, label = "Young recovered\nper brood", hjust = 0.5,
                    family = fam, size = 5.2, fontface = "bold", colour = bb512$forest, lineheight = 0.95) +
  ggplot2::scale_x_continuous("Brood size (eggs)", breaks = 1:10) +
  ggplot2::scale_y_continuous("Young recovered per brood", limits = c(0, 0.121),
                              breaks = seq(0, 0.12, 0.04), expand = c(0, 0),
                              sec.axis = ggplot2::sec_axis(~ . / k, name = "Proportion of broods",
                                                           breaks = seq(0, 0.3, 0.1))) +
  theme_bb512(base_family = fam) +
  ggplot2::theme(axis.title.y.right = ggplot2::element_text(colour = bb512$grey, size = 16),
                 axis.title.y.left = ggplot2::element_text(colour = bb512$forest))

save_bb512(p, "04_lack_starlings", layout = "takeaway")
