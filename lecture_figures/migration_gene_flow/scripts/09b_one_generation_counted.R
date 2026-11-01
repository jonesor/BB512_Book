# Model 1 worked by counting (Neal Example 9.2 numbers): 100 breeders on the island
# field after one generation of immigration with m = 0.05. Residents carry the white
# allele (q0 = 0); immigrants come from yellow fields (qm = 1). Schematic, not data.
source("R/theme_bb512.R")
library(ggplot2)
fam <- bb512_font()
m <- 0.05
n <- 100
d <- expand.grid(col = 1:10, row = 1:10)
d$type <- "Resident (white allele)"
d$type[d$row == 10 & d$col >= 6] <- "Immigrant (yellow allele)"   # 5 immigrants, top-right
stopifnot(sum(d$type == "Immigrant (yellow allele)") == m * n)
p <- ggplot(d, aes(col, row)) +
  geom_point(aes(fill = type), shape = 21, size = 8.5, stroke = 1.1, colour = bb512$grey) +
  scale_fill_manual(values = c("Resident (white allele)" = "#FFFFFF",
                               "Immigrant (yellow allele)" = bb512$gold), name = NULL,
                    breaks = c("Resident (white allele)", "Immigrant (yellow allele)")) +
  annotate("text", x = 5.5, y = -0.2, label = "95 residents + 5 immigrants = 100 breeders",
           colour = bb512$ink, size = 5.2, family = fam) +
  coord_fixed(xlim = c(0.4, 10.6), ylim = c(-0.8, 10.6), clip = "off") +
  theme_void() +
  theme(plot.background = element_rect(fill = bb512$bg, colour = NA),
        legend.position = "top", legend.text = element_text(size = 15, family = fam, colour = bb512$ink),
        plot.margin = margin(10, 10, 10, 10))
save_bb512(p, "09b_one_generation_counted", layout = "half")
