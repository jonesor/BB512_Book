# BB512 figure styling, based on the supplied BB512_Theme.pptx.
# Run scripts from the project directory (the folder containing render_all.R).
# Requires ggplot2 and ragg. The scales package is required by some figures.

bb512 <- list(
  bg       = "#FBFAF6",  # PPTX lt1 / slide background
  ink      = "#1F2623",  # PPTX dk1
  forest   = "#1F4D3F",  # PPTX accent1
  gold     = "#C08A2E",  # PPTX accent2
  clay     = "#A4503A",  # PPTX accent3
  blue     = "#3E6E7E",  # PPTX accent4
  sage     = "#9AAE9F",  # PPTX accent5
  grey     = "#6E6F68",  # PPTX accent6
  pale     = "#EFEEE6",  # PPTX lt2
  grid     = "#D8DDD5"   # restrained neutral major gridlines
)

# The PPTX uses Avenir Next. On a Mac this should be installed.
# Change base_family to Helvetica if the font is not available on your system.
# Use Avenir Next where installed (Mac); otherwise fall back to a similar sans.
.bb512_font <- local({
  fams <- tryCatch(unique(systemfonts::system_fonts()$family), error = function(e) character())
  if ("Avenir Next" %in% fams) "Avenir Next" else if ("Nunito Sans" %in% fams) "Nunito Sans" else "Helvetica"
})

theme_bb512 <- function(base_size = 18, base_family = .bb512_font) {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.background       = ggplot2::element_rect(fill = bb512$bg, colour = NA),
      panel.background      = ggplot2::element_rect(fill = bb512$bg, colour = NA),
      legend.background     = ggplot2::element_rect(fill = bb512$bg, colour = NA),
      legend.key            = ggplot2::element_rect(fill = bb512$bg, colour = NA),
      text                  = ggplot2::element_text(colour = bb512$ink),
      axis.title            = ggplot2::element_text(size = 18, colour = bb512$ink),
      axis.text             = ggplot2::element_text(size = 15, colour = bb512$grey),
      strip.text            = ggplot2::element_text(size = 17, face = "bold", colour = bb512$forest),
      panel.grid.major.y    = ggplot2::element_line(colour = bb512$grid, linewidth = 0.5),
      panel.grid.major.x    = ggplot2::element_blank(),
      panel.grid.minor      = ggplot2::element_blank(),
      axis.ticks            = ggplot2::element_blank(),
      axis.line             = ggplot2::element_line(colour = bb512$grey, linewidth = 0.5),
      legend.text           = ggplot2::element_text(size = 15),
      legend.title          = ggplot2::element_text(size = 15, face = "bold"),
      legend.position       = "bottom",
      legend.box            = "horizontal",
      plot.title            = ggplot2::element_blank(),
      plot.subtitle         = ggplot2::element_blank(),
      plot.caption          = ggplot2::element_blank(),
      plot.margin           = ggplot2::margin(14, 28, 12, 16, "pt")
    )
}

# Exact figure-container sizes from the supplied PPTX theme (inches).
.bb512_dimensions <- list(
  full     = c(11.733, 3.950),  # Title & Photo
  fullbox  = c(11.733, 4.250),  # Title & Photo as it appears in Keynote
  takeaway = c(7.400, 4.250),   # Title, Bullets & Photo
  half     = c(5.567, 4.250),   # Figure & Bullets
  third    = c(3.644, 5.300),   # Photo – 3 Up
  slide    = c(13.333, 7.500)   # full slide if used as a figure
)

save_bb512 <- function(plot, filename, layout = "full", out_dir = "figures",
                       dpi = 300, background = bb512$bg) {
  if (!inherits(plot, "ggplot")) stop("plot must be a ggplot object")
  if (!layout %in% names(.bb512_dimensions)) {
    stop("layout must be one of: ", paste(names(.bb512_dimensions), collapse = ", "))
  }
  if (!requireNamespace("ragg", quietly = TRUE)) stop("Install the 'ragg' package")
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
  sz <- .bb512_dimensions[[layout]]
  png_name <- file.path(out_dir, paste0(filename, ".png"))

  ggplot2::ggsave(png_name, plot = plot, device = ragg::agg_png,
                  width = sz[1], height = sz[2], units = "in",
                  dpi = dpi, bg = background, limitsize = FALSE)
  invisible(png_name)
}

# Default colour order: forest, clay, blue, gold, sage, grey.
bb512_series <- c(bb512$forest, bb512$clay, bb512$blue,
                  bb512$gold, bb512$sage, bb512$grey)
