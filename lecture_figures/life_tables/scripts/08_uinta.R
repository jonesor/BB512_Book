# 08_uinta.R
# Slide "Real data: fewer squirrels, faster growth".
# Empirical. Uinta ground squirrel (Neal: Spermophilus armatus; now
# Urocitellus armatus), lawn habitat, Utah (Slade & Balph 1974), from Neal's
# table of age-specific survival and fertility before and after the population
# density was approximately halved. Survivorship lx on a log scale (ages at
# census: 0, 0.75, 1.75 ... years; zeros omitted). Fertility (mx) barely
# changed (1.96-2.73 before, 1.75-2.76 after), so the faster growth came from
# better survival and longevity.
source("R/theme_bb512.R")
library(ggplot2)

age <- c(0, 0.75, 1.75, 2.75, 3.75, 4.75, 5.75)
d <- rbind(
  data.frame(age = age[1:5], lx = c(1, 0.292, 0.128, 0.041, 0.013), grp = "Before"),
  data.frame(age = age, lx = c(1, 0.359, 0.190, 0.089, 0.041, 0.019, 0.009), grp = "After"))
cols <- c("Before" = bb512$clay, "After" = bb512$forest)

p <- ggplot(d, aes(age, lx, colour = grp)) +
  geom_line(linewidth = 1.5) +
  geom_point(size = 3) +
  annotate("text", x = 3.9, y = 0.013, label = "Before", hjust = 0, size = 5.6,
           fontface = "bold", family = "Avenir Next", colour = bb512$clay) +
  annotate("text", x = 3.0, y = 0.17, label = "Density halved", hjust = 0, size = 5.6,
           fontface = "bold", family = "Avenir Next", colour = bb512$forest) +
  scale_colour_manual(values = cols, guide = "none") +
  scale_y_log10(breaks = c(0.01, 0.1, 1), labels = c("0.01", "0.1", "1")) +
  scale_x_continuous(breaks = 0:6, expand = expansion(mult = c(0.02, 0))) +
  coord_cartesian(xlim = c(0, 6), clip = "off") +
  labs(x = "Age (years)", y = expression("Survivorship, " * italic(l)[x] * " (log scale)")) +
  theme_bb512()

save_bb512(p, "08_uinta", layout = "takeaway")
