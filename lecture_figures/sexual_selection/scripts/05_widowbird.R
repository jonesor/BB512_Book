# Slide: "Testing female choice: long-tailed widowbirds" (Title, Bullets & Photo, layout = "takeaway")
# Empirical: Andersson (1982) Nature 299: 818-820; values from Neal (chapter "Sexual selection
# and mating systems"), table of mean active nests per male territory, n = 9 males per group,
# before and after tail manipulation. SDs are large (about 0.7-2.1) and are omitted here.
source("R/theme_bb512.R")
library(ggplot2)
d <- data.frame(
  group  = factor(rep(c("Shortened", "Control\n(cut, reglued)", "Control\n(marked)", "Elongated"), 2),
                  levels = c("Shortened", "Control\n(cut, reglued)", "Control\n(marked)", "Elongated")),
  period = rep(c("Before", "After"), each = 4),
  nests  = c(1.33, 1.56, 1.44, 1.67, 0.44, 0.89, 0.44, 1.89))
d$period <- factor(d$period, levels = c("Before", "After"))
d$hl <- ifelse(d$group == "Elongated" & d$period == "After", "yes", "no")
p <- ggplot(d, aes(group, nests, fill = interaction(period, hl))) +
  geom_col(position = position_dodge(width = 0.75), width = 0.7) +
  scale_fill_manual(values = c(Before.no = bb512$sage, After.no = bb512$forest, After.yes = bb512$gold),
                    breaks = c("Before.no", "After.no"), labels = c("Before treatment", "After treatment"),
                    name = NULL) +
  scale_y_continuous("Active nests per male", limits = c(0, 2), expand = c(0, 0)) +
  xlab(NULL) + theme_bb512() + theme(axis.text.x = element_text(size = 15, colour = bb512$ink))
save_bb512(p, "05_widowbird", layout = "takeaway")
