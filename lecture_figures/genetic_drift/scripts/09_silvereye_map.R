# Slide: "Silvereyes: a natural experiment in founder events" (Title & Photo, "full")
# Map of the dated silvereye (Zosterops lateralis) colonisations, redrawn after
# Clegg et al. (2002) PNAS 99: 8127-8132, Fig. 1. Coastlines: mapdata::world2Hires.
# Route: Tasmania -> South Island (1830) -> Palmerston North (1856) -> Auckland (1865)
# -> Norfolk Island (1904); South Island -> Chatham Islands (1856).
# The map fills the left of the figure; the right is left empty for the bird photo,
# which is placed as a separate image in Keynote (so the photo keeps its own licence).
source("R/theme_bb512.R"); library(ggplot2); library(maps); library(mapdata)

xlim <- c(140, 187); ylim <- c(-48, -21.5)
land <- map_data("world2Hires", xlim = xlim + c(-3, 3), ylim = ylim + c(-3, 3))

sites <- data.frame(
  name = c("Tasmania", "South Is.", "Palmerston North", "Auckland", "Norfolk Is.",
           "Chatham Is.", "Lord Howe Is.", "Heron Is."),
  lon  = c(146.6, 171.0, 175.6, 174.8, 167.95, 183.5, 159.08, 151.91),
  lat  = c(-42.0, -43.8, -40.35, -36.85, -29.03, -43.9, -31.55, -23.44),
  type = c(rep("recent", 6), "old", "old"))
rec <- sites[sites$type == "recent", ]
old <- sites[sites$type == "old", ]

leg <- function(from, to) data.frame(x = sites$lon[sites$name == from], y = sites$lat[sites$name == from],
                                     xend = sites$lon[sites$name == to], yend = sites$lat[sites$name == to])
route <- rbind(leg("Tasmania", "South Is."), leg("South Is.", "Palmerston North"),
               leg("Palmerston North", "Auckland"), leg("Auckland", "Norfolk Is."),
               leg("South Is.", "Chatham Is."))
# Shorten each arrow so it starts and stops just outside the points
shrink <- function(d, f = 0.12) {
  dx <- d$xend - d$x; dy <- d$yend - d$y; L <- sqrt(dx^2 + dy^2); k <- pmin(f * 8 / L, 0.3)
  transform(d, x = x + k * dx, y = y + k * dy, xend = xend - k * dx, yend = yend - k * dy)
}
route <- shrink(route)

lab <- data.frame(
  x     = c(146.6, 170.5, 177.0, 172.6, 167.95, 182.2, 159.08, 153.0),
  y     = c(-44.6, -46.3, -40.35, -36.0, -27.4, -45.9, -33.0, -23.44),
  hjust = c(0.5,   0.5,   0,     1,     0.5,    0.5,   0.5,   0),
  label = c("Tasmania", "South Is. 1830", "Palmerston\nNorth 1856", "Auckland 1865",
            "Norfolk Is. 1904", "Chatham Is.\n1856", "Lord Howe Is.", "Heron Is."),
  col   = c(rep(bb512$ink, 6), rep(bb512$grey, 2)))

fs <- 14 / .pt
fig <- ggplot() +
  geom_polygon(data = land, aes(long, lat, group = group), fill = bb512$pale,
               colour = bb512$sage, linewidth = 0.3) +
  annotate("text", x = 145, y = -30, label = "Australia", size = 16 / .pt,
           colour = bb512$grey, family = .bb512_font) +
  geom_curve(data = route, aes(x, y, xend = xend, yend = yend), curvature = -0.15,
             colour = bb512$forest, linewidth = 0.9,
             arrow = grid::arrow(length = grid::unit(0.1, "in"), type = "closed")) +
  geom_point(data = old, aes(lon, lat), shape = 15, size = 3.6, colour = bb512$grey) +
  geom_point(data = rec, aes(lon, lat), shape = 21, size = 3.8, stroke = 1.4,
             colour = bb512$forest, fill = bb512$bg) +
  geom_text(data = lab, aes(x, y, label = label, hjust = hjust), colour = lab$col,
            size = fs, family = .bb512_font, lineheight = 0.9) +
  # Key
  annotate("point", x = 153.5, y = -37.3, shape = 21, size = 3.8, stroke = 1.4,
           colour = bb512$forest, fill = bb512$bg) +
  annotate("text", x = 154.6, y = -37.3, hjust = 0, size = fs, family = .bb512_font,
           colour = bb512$ink, label = "Dated colonisation") +
  annotate("point", x = 153.5, y = -39.4, shape = 15, size = 3.6, colour = bb512$grey) +
  annotate("text", x = 154.6, y = -39.4, hjust = 0, size = fs, family = .bb512_font,
           colour = bb512$grey, label = "Long-isolated form") +
  coord_quickmap(xlim = xlim, ylim = ylim, expand = FALSE, clip = "on") +
  theme_void(base_family = .bb512_font) +
  theme(plot.background = element_rect(fill = bb512$bg, colour = NA),
        panel.background = element_rect(fill = bb512$bg, colour = NA),
        plot.margin = margin(4, 4.3 * 72, 4, 0))   # right 4.3 in kept free for the photo

save_bb512(fig, "09_silvereye_map", layout = "full")
