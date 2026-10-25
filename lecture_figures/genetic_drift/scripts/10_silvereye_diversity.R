# Slide: "Large founding flocks mean weak founder effects" (Figure & Bullets, "half")
# Empirical data: silvereye (Zosterops lateralis) allelic diversity (mean number of
# alleles per locus, 6 microsatellites) against the number of founder events since
# Tasmania. Values were digitised from Clegg et al. (2002) PNAS 99: 8127-8132, Fig. 2a
# (image at 700 px; reading error about +/- 0.15 alleles). Check: Tasmania to Norfolk
# gives a 39.5% drop, matching the 40% stated in the paper's text.
# Founder events follow the paper's Fig. 1: Tasmania -> South Island (1830) ->
# North Island (Palmerston North, 1856) -> Auckland (1865) -> Norfolk Island (1904);
# South Island -> Chatham Islands (1856).
# Effective founder numbers (posterior means, Table 1): South Is. 198, North Is. 143,
# Chatham 207, Norfolk 24. Standard errors across loci (about +/- 2 alleles) are omitted.
source("R/theme_bb512.R"); library(ggplot2)

recent <- data.frame(
  pop   = c("Tasmania", "South Is.", "Chatham Is.", "North Is.", "Auckland", "Norfolk Is."),
  steps = c(0, 1, 2, 2, 3, 4),
  x     = c(0, 1, 2.08, 1.92, 3, 4),            # small dodge at 2 founder events
  alleles = c(11.59, 11.66, 9.84, 9.23, 8.49, 7.01))
old <- c(Heron = 5.73, LordHowe = 6.94, NorfolkTenuirostris = 4.58)

route  <- recent[c(1, 2, 4, 5, 6), ]
branch <- recent[c(2, 3), ]

lab <- data.frame(
  x = c(0, 1, 2.2, 1.85, 2.8, 4.1),
  y = recent$alleles + c(-0.85, 1.35, 0, -0.75, -0.8, -1.25),
  label = c("Tasmania", "South Is.\n~200 founders", "Chatham", "North Is.", "Auckland",
            "Norfolk Is.\n~24 founders"),
  hjust = c(0.2, 0.5, 0, 1, 0.5, 1))

fs <- 14 / .pt
fig <- ggplot() +
  annotate("rect", xmin = -0.35, xmax = 4.35, ymin = min(old), ymax = max(old),
           fill = bb512$sage, alpha = 0.35) +
  annotate("text", x = -0.25, y = mean(range(old)), hjust = 0, size = fs,
           colour = bb512$grey, family = .bb512_font, lineheight = 0.9,
           label = "Long-isolated island forms") +
  geom_path(data = route, aes(x, alleles), colour = bb512$forest, linewidth = 0.9) +
  geom_path(data = branch, aes(x, alleles), colour = bb512$forest, linewidth = 0.9) +
  geom_point(data = recent, aes(x, alleles), colour = bb512$forest, size = 4) +
  geom_point(data = recent[recent$pop == "Norfolk Is.", ], aes(x, alleles),
             colour = bb512$clay, size = 4.6) +
  geom_text(data = lab, aes(x, y, label = label, hjust = hjust), size = fs,
            colour = bb512$ink, family = .bb512_font, lineheight = 0.9) +
  scale_x_continuous("Founder events since Tasmania", breaks = 0:4,
                     expand = expansion(add = 0)) +
  scale_y_continuous("Alleles per locus", limits = c(0, 14), breaks = c(0, 4, 8, 12),
                     expand = expansion(mult = 0)) +
  coord_cartesian(xlim = c(-0.35, 4.35), clip = "off") +
  theme_bb512()

save_bb512(fig, "10_silvereye_diversity", layout = "half")
