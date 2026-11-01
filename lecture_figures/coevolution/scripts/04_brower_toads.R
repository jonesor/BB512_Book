# 04_brower_toads.R  (slide "Experience with the model protects the mimic", layout = "takeaway")
# EMPIRICAL: Brower & Brower (1966), as reported in Neal, chapter on predation (table on Batesian mimicry).
# Percentages are hard-coded from Neal's table. Note: Neal gives 75.5% for the
# control toads, whereas the counts in the same table (110 eaten, 30 rejected)
# give 78.6%; we plot the published 75.5% and flag this in the speaker notes.
source("R/theme_bb512.R")
library(ggplot2)
FAM <- getOption("bb512.family", "Avenir Next")

d <- data.frame(
  prey  = factor(rep(c("Honeybee\n(model)", "Dronefly\n(mimic)", "Mealworm\n(other food)"), 2),
                 levels = c("Honeybee\n(model)", "Dronefly\n(mimic)", "Mealworm\n(other food)")),
  group = factor(rep(c("Stung by honeybees first", "Never met honeybees"), each = 3),
                 levels = c("Stung by honeybees first", "Never met honeybees")),
  eaten = c(45, 43.3, 100, NA, 75.5, 100))

g <- ggplot(d, aes(prey, eaten, fill = group)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.72, na.rm = TRUE) +
  geom_text(aes(label = ifelse(is.na(eaten), "not\noffered", paste0(eaten, "%")),
                y = ifelse(is.na(eaten), 3, eaten + 3),
                colour = is.na(eaten)),
            position = position_dodge(width = 0.8), vjust = 0, size = 5.2,
            family = FAM, lineheight = 0.85) +
  scale_fill_manual(values = c(bb512$clay, bb512$sage), name = NULL) +
  scale_colour_manual(values = c(bb512$ink, bb512$grey), guide = "none") +
  scale_y_continuous(limits = c(0, 112), breaks = c(0, 25, 50, 75, 100),
                     expand = expansion(mult = c(0, 0))) +
  labs(x = NULL, y = "Prey eaten (%)") +
  theme_bb512() + theme(axis.text.x = element_text(size = 15, colour = bb512$ink, lineheight = 0.9))
save_bb512(g, "04_brower_toads", layout = "takeaway")
