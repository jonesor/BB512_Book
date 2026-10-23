# Slide "Why blending inheritance fails" (layout "takeaway").
# Simulation, random mating, N = 2000, no selection, mutation or drift of note.
# Blending: each offspring's value is the mean of its two parents' values.
# Particulate (Mendelian): trait = sum of 20 additive biallelic loci (p = 0.5), each parent passes one
#   allele per locus at random; values standardised so the generation-0 variance is 1.
# Expected: blending variance halves every generation (0.5^t); particulate variance stays ~1.
source("R/theme_bb512.R")
fam <- Sys.getenv("BB512_FONT", "Avenir Next")
set.seed(512)
N <- 2000; L <- 20; gens <- 0:8

# Particulate: genotype matrices of allele counts (0/1) for two haplotypes
h1 <- matrix(rbinom(N * L, 1, 0.5), N); h2 <- matrix(rbinom(N * L, 1, 0.5), N)
z  <- function(h1, h2) rowSums(h1 + h2)
v0 <- var(z(h1, h2))
vp <- numeric(length(gens)); vp[1] <- 1
for (g in gens[-1]) {
  m <- sample(N, N, TRUE); f <- sample(N, N, TRUE)
  pick <- function(a, b) { k <- matrix(rbinom(N * L, 1, 0.5), N); a * k + b * (1 - k) }
  n1 <- pick(h1[m, ], h2[m, ]); n2 <- pick(h1[f, ], h2[f, ])
  h1 <- n1; h2 <- n2
  vp[g + 1] <- var(z(h1, h2)) / v0
}
# Blending
x <- rnorm(N); x <- (x - mean(x)) / sd(x)
vb <- numeric(length(gens)); vb[1] <- 1
for (g in gens[-1]) {
  x <- (x[sample(N, N, TRUE)] + x[sample(N, N, TRUE)]) / 2
  vb[g + 1] <- var(x)
}
cat("Particulate:", round(vp, 3), "\nBlending:", round(vb, 3), "\nExpected blending:", round(0.5^gens, 3), "\n")

d <- rbind(data.frame(g = gens, v = vp, model = "Particulate"),
           data.frame(g = gens, v = vb, model = "Blending"))
p <- ggplot2::ggplot(d, ggplot2::aes(g, v, colour = model)) +
  ggplot2::geom_line(linewidth = 1.4) + ggplot2::geom_point(size = 2.8) +
  ggplot2::annotate("text", x = 8, y = 1.12, label = "Particulate (Mendelian)", hjust = 1,
                    colour = bb512$forest, family = fam, size = 5.2) +
  ggplot2::annotate("text", x = 2.2, y = 0.47, label = "Blending: halves\nevery generation", hjust = 0,
                    colour = bb512$clay, family = fam, size = 5.2, lineheight = 0.9) +
  ggplot2::scale_colour_manual(values = c(Particulate = bb512$forest, Blending = bb512$clay), guide = "none") +
  ggplot2::scale_x_continuous(breaks = gens) +
  ggplot2::scale_y_continuous(limits = c(0, 1.2), breaks = seq(0, 1, 0.25)) +
  ggplot2::labs(x = "Generation", y = "Variation in the trait\n(variance, generation 0 = 1)") +
  theme_bb512(base_family = fam)
save_bb512(p, "04_blending", layout = "takeaway")
