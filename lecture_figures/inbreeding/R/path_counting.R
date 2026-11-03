# Path counting for the inbreeding coefficient, and the pedigrees used to teach it.
#
# find_paths(): every pair of lines of descent from a common ancestor to the two
#   parents of the focal individual, sharing no individual except that ancestor.
#   Each path contributes (1/2)^n (1 + F_CA), where n counts the individuals on
#   the path, including both parents and the common ancestor but not the focal
#   individual. Equivalent to Wright's (1/2)^(r + s + 1), with r and s the numbers
#   of generations from the common ancestor to each parent.
# kinship_F(): the same F from the recursive kinship calculation, which does not
#   look for paths at all. It is the independent check on find_paths().
#
# Pedigrees are data frames with columns id, x, y, p1, p2 (p1 and p2 are NA for
# founders). Rows must list parents before their offspring. x and y are drawing
# positions only. Requires theme_bb512.R to have been sourced first.

ped_font <- "Avenir Next"

find_paths <- function(ped, focal = "X") {
  parents <- function(id) {
    row <- ped[match(id, ped$id), ]
    stats::na.omit(unique(c(row$p1, row$p2)))
  }
  # all lines going up from id, each starting at id
  lines_up <- function(id) {
    c(list(id), unlist(lapply(parents(id), function(p) {
      lapply(lines_up(p), function(l) c(id, l))
    }), recursive = FALSE))
  }
  inbreeding <- function(id) {
    row <- ped[match(id, ped$id), ]
    if (is.na(row$p1) || is.na(row$p2)) return(0)
    sum(find_paths(ped, id)$contribution)
  }
  row <- ped[match(focal, ped$id), ]
  up1 <- lines_up(row$p1)
  up2 <- lines_up(row$p2)
  out <- list()
  for (a in up1) for (b in up2) {
    ca <- a[length(a)]
    if (ca != b[length(b)]) next
    if (!setequal(intersect(a, b), ca)) next
    out[[length(out) + 1]] <- list(up1 = a, up2 = b, ca = ca,
                                   individuals = c(a, rev(b)[-1]))
  }
  ord <- order(vapply(out, function(p) p$ca, ""))
  out <- out[ord]
  data <- data.frame(
    ca = vapply(out, function(p) p$ca, ""),
    path = vapply(out, function(p) paste(p$individuals, collapse = "–"), ""),
    n = vapply(out, function(p) length(p$individuals), 1L)
  )
  data$F_ca <- vapply(data$ca, inbreeding, 0)
  data$contribution <- 0.5^data$n * (1 + data$F_ca)
  attr(data, "paths") <- out
  data
}

kinship_F <- function(ped, focal = "X") {
  ids <- ped$id
  k <- matrix(0, nrow(ped), nrow(ped), dimnames = list(ids, ids))
  for (i in seq_along(ids)) {
    p <- c(ped$p1[i], ped$p2[i])
    known <- !is.na(p)
    k[i, i] <- 0.5 * (1 + if (all(known)) k[p[1], p[2]] else 0)
    if (i > 1) for (j in seq_len(i - 1)) {
      k[i, j] <- k[j, i] <- 0.5 * sum(k[j, p[known]])
    }
  }
  row <- ped[match(focal, ped$id), ]
  k[row$p1, row$p2]
}

# The seven matings. Founders unrelated and not inbred. Ids m1, m2, ... are
# unrelated mates, drawn small and unlabelled. Rows are ordered parents first.
ped_frame <- function(...) {
  d <- as.data.frame(do.call(rbind, list(...)), stringsAsFactors = FALSE)
  names(d) <- c("id", "x", "y", "p1", "p2")
  d$x <- as.numeric(d$x); d$y <- as.numeric(d$y)
  d
}
N <- NA_character_

relationships <- list(
  selfing = list(name = "Self-fertilisation", short = "Selfing\n ", F = 1/2,
                 ped = ped_frame(c("A", 0, 1, N, N), c("X", 0, 0, "A", "A"))),
  parent = list(name = "Parent × offspring", short = "Parent ×\noffspring", F = 1/4,
                ped = ped_frame(c("A", -0.6, 2, N, N), c("m1", 0.8, 2, N, N),
                                c("C", 0.4, 1, "A", "m1"), c("X", 0, 0, "C", "A"))),
  full = list(name = "Full siblings", short = "Full\nsiblings", F = 1/4,
              ped = ped_frame(c("A", -0.6, 2, N, N), c("B", 0.6, 2, N, N),
                              c("C", -0.6, 1, "A", "B"), c("D", 0.6, 1, "A", "B"),
                              c("X", 0, 0, "C", "D"))),
  half = list(name = "Half siblings", short = "Half\nsiblings", F = 1/8,
              ped = ped_frame(c("m1", -1.3, 2, N, N), c("A", 0, 2, N, N),
                              c("m2", 1.3, 2, N, N),
                              c("C", -0.6, 1, "A", "m1"), c("D", 0.6, 1, "A", "m2"),
                              c("X", 0, 0, "C", "D"))),
  uncle = list(name = "Uncle × niece", short = "Uncle ×\nniece", F = 1/8,
               ped = ped_frame(c("A", -0.5, 3, N, N), c("B", 0.5, 3, N, N),
                               c("m1", 1.5, 2, N, N),
                               c("C", -0.8, 2, "A", "B"), c("E", 0.7, 2, "A", "B"),
                               c("D", 0.8, 1, "E", "m1"), c("X", 0, 0, "C", "D"))),
  first = list(name = "First cousins", short = "First\ncousins", F = 1/16,
               ped = ped_frame(c("A", -0.45, 3, N, N), c("B", 0.45, 3, N, N),
                               c("m1", -1.55, 2, N, N), c("m2", 1.55, 2, N, N),
                               c("E", -0.8, 2, "A", "B"), c("F", 0.8, 2, "A", "B"),
                               c("C", -0.8, 1, "E", "m1"), c("D", 0.8, 1, "F", "m2"),
                               c("X", 0, 0, "C", "D"))),
  second = list(name = "Second cousins", short = "Second\ncousins", F = 1/64,
                ped = ped_frame(c("A", -0.45, 4, N, N), c("B", 0.45, 4, N, N),
                                c("m1", -1.55, 3, N, N), c("m2", 1.55, 3, N, N),
                                c("E", -0.8, 3, "A", "B"), c("F", 0.8, 3, "A", "B"),
                                c("m3", -1.55, 2, N, N), c("m4", 1.55, 2, N, N),
                                c("G", -0.8, 2, "E", "m1"), c("H", 0.8, 2, "F", "m2"),
                                c("C", -0.8, 1, "G", "m3"), c("D", 0.8, 1, "H", "m4"),
                                c("X", 0, 0, "C", "D")))
)

# Stop if a value on a slide could be wrong: paths, kinship and the stated F must agree.
for (rel in relationships) {
  paths <- find_paths(rel$ped)
  stopifnot(isTRUE(all.equal(sum(paths$contribution), rel$F)),
            isTRUE(all.equal(kinship_F(rel$ped), rel$F)))
}

path_colours <- function(rel) {
  stats::setNames(c(bb512$clay, bb512$blue), c("A", "B"))
}

# ggplot layers for one pedigree, in a coordinate system measured in inches.
#   ox, oy: position of X. sx, sy: inches per unit of the pedigree's x and y.
ped_layers <- function(rel, ox, oy, sx, sy, r, off = 0.03, path_lw = 1.3, base_lw = 0.7,
                       letters_size = NULL, arrow_in = 0.1) {
  ped <- rel$ped
  ped$px <- ox + ped$x * sx
  ped$py <- oy + ped$y * sy
  paths <- find_paths(ped)
  plist <- attr(paths, "paths")
  cols <- path_colours(rel)[paths$ca]
  is_mate <- grepl("^m[0-9]+$", ped$id)
  rad <- ifelse(is_mate, r * 0.5, r)
  names(rad) <- ped$id
  pos <- function(id) ped[match(id, ped$id), ]

  seg <- function(from, to, shift = 0) {
    a <- pos(from); b <- pos(to)
    d <- sqrt((b$px - a$px)^2 + (b$py - a$py)^2)
    ux <- (b$px - a$px) / d; uy <- (b$py - a$py) / d
    data.frame(x = a$px + ux * (rad[[from]] + 0.02) - uy * shift,
               y = a$py + uy * (rad[[from]] + 0.02) + ux * shift,
               xend = b$px - ux * (rad[[to]] + 0.03) - uy * shift,
               yend = b$py - uy * (rad[[to]] + 0.03) + ux * shift)
  }

  # Edges on paths, drawn downwards from the common ancestor. Shared edges get
  # one parallel arrow for each path that uses them.
  on_path <- do.call(rbind, lapply(seq_along(plist), function(k) {
    sides <- list(plist[[k]]$up1, plist[[k]]$up2)
    do.call(rbind, lapply(sides, function(s) {
      if (length(s) < 2) return(NULL)
      data.frame(from = s[-1], to = s[-length(s)], k = k)
    }))
  }))
  arrows <- NULL
  if (!is.null(on_path)) {
    on_path$key <- paste(on_path$from, on_path$to)
    arrows <- do.call(rbind, lapply(seq_len(nrow(on_path)), function(i) {
      same <- on_path$k[on_path$key == on_path$key[i]]
      shift <- (match(on_path$k[i], same) - (length(same) + 1) / 2) * 2 * off
      cbind(seg(on_path$from[i], on_path$to[i], shift), colour = cols[[on_path$k[i]]])
    }))
  }

  # Remaining edges: thin context lines, and dashed lines closing on X.
  edges <- do.call(rbind, lapply(which(!is.na(ped$p1)), function(i) {
    data.frame(from = unique(c(ped$p1[i], ped$p2[i])), to = ped$id[i])
  }))
  keys <- paste(edges$from, edges$to)
  context <- edges[!(keys %in% on_path$key) & edges$to != "X", ]
  closing <- edges[edges$to == "X", ]
  selfing <- nrow(closing) == 1

  th <- seq(0, 2 * pi, length.out = 72)
  fills <- ifelse(is_mate | ped$id == "X", bb512$sage, bb512$forest)
  fills[ped$id %in% names(cols)] <- cols[ped$id[ped$id %in% names(cols)]]
  circles <- do.call(rbind, lapply(seq_len(nrow(ped)), function(i) {
    data.frame(id = ped$id[i], x = ped$px[i] + rad[i] * cos(th),
               y = ped$py[i] + rad[i] * sin(th), fill = fills[i])
  }))

  layers <- list()
  if (nrow(context)) {
    d <- do.call(rbind, Map(seg, context$from, context$to))
    layers <- c(layers, ggplot2::geom_segment(data = d, ggplot2::aes(x, y, xend = xend, yend = yend),
                                              colour = bb512$sage, linewidth = base_lw))
  }
  if (selfing) {
    d <- seg(closing$from, closing$to)
    for (cv in c(-0.6, 0.6)) {
      layers <- c(layers, ggplot2::geom_curve(data = d, ggplot2::aes(x, y, xend = xend, yend = yend),
                                              curvature = cv, colour = bb512$grey,
                                              linewidth = base_lw + 0.2, linetype = "22"))
    }
  } else {
    d <- do.call(rbind, Map(seg, closing$from, closing$to))
    layers <- c(layers, ggplot2::geom_segment(data = d, ggplot2::aes(x, y, xend = xend, yend = yend),
                                              colour = bb512$grey, linewidth = base_lw + 0.2,
                                              linetype = "22"))
  }
  if (!is.null(arrows)) {
    layers <- c(layers, ggplot2::geom_segment(
      data = arrows, ggplot2::aes(x, y, xend = xend, yend = yend, colour = colour),
      linewidth = path_lw, lineend = "round", linejoin = "mitre",
      arrow = grid::arrow(length = grid::unit(arrow_in, "inches"), type = "closed")))
  }
  layers <- c(layers, ggplot2::geom_polygon(data = circles,
                                            ggplot2::aes(x, y, group = id, fill = fill),
                                            colour = NA))
  if (!is.null(letters_size)) {
    labs <- ped[!is_mate, ]
    layers <- c(layers, ggplot2::annotate("text", x = labs$px, y = labs$py, label = labs$id,
                                          colour = ifelse(labs$id == "X", bb512$ink, bb512$bg),
                                          size = letters_size, fontface = "bold", family = ped_font))
  }
  layers
}

# A blank canvas in inches, matching a save_bb512() layout.
ped_canvas <- function(layout) {
  sz <- .bb512_dimensions[[layout]]
  ggplot2::ggplot() +
    ggplot2::scale_colour_identity() +
    ggplot2::scale_fill_identity() +
    ggplot2::coord_equal(xlim = c(0, sz[1]), ylim = c(0, sz[2]), expand = FALSE, clip = "off") +
    ggplot2::theme_void() +
    ggplot2::theme(plot.background = ggplot2::element_rect(fill = bb512$bg, colour = NA),
                   plot.margin = ggplot2::margin(0, 0, 0, 0))
}

fraction <- function(p) sprintf("1/%d", round(1 / p))
