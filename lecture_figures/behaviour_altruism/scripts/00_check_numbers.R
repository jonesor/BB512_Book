# Arithmetic check for every number used on the slides and in the speaker notes.
# Makes no figure. Run: Rscript scripts/00_check_numbers.R
# Sources: Neal (2004) Chapter 19; Reyer (1990) via Neal Table 19.3;
# Maynard Smith & Price (1973) Hawk-Dove game with Neal's display cost D.

cat("\n--- Relatedness (outbred, diploid; r = sum over paths of (1/2)^links) ---\n")
r_path <- function(links) sum(0.5^links)
rel <- c(parent_offspring = r_path(1),
         full_sib = r_path(c(2, 2)),           # via mother and via father
         half_sib = r_path(2),
         grandparent = r_path(2),
         aunt_niece = r_path(c(3, 3)),
         first_cousin = r_path(c(4, 4)))
print(rel)

cat("\n--- Haldane: two brothers or eight cousins (break-even, rb = c with c = 1 life) ---\n")
cat("2 brothers x 0.5 =", 2 * 0.5, "; 8 cousins x 0.125 =", 8 * 0.125, "\n")
cat("Neal's version: 1-in-10 risk of death to save 1 child: gain 0.5 copies vs expected loss 0.1 copies -> ratio",
    0.5 / 0.1, "\n")

cat("\n--- Inclusive fitness worked example (Neal convention: offspring counted x r) ---\n")
breed <- 1 * 0.5            # one own offspring
help  <- 0 * 0.5 + 3 * 0.25 # three extra nieces/nephews
cat("Breed: fD =", breed, " | Help sister raise 3 extra: fD = 0, fI =", help, "\n")
cat("Break-even number of extra nieces/nephews per own offspring forgone:", 0.5 / 0.25, "\n")

cat("\n--- Pied kingfisher, Reyer (1990), Neal Table 19.3 (two-year totals) ---\n")
kf <- data.frame(status = c("Breeder", "Primary helper", "Secondary helper", "Delayer"),
                 direct = c(1.76, 0.42, 0.87, 0.30),
                 indirect = c(0, 0.65, 0.05, 0))
kf$inclusive <- kf$direct + kf$indirect
print(kf)
cat("Neal Table 19.2 primary helper year-1 indirect: 1.8 x 0.32 =", 1.8 * 0.32, "\n")

cat("\n--- Haplodiploid relatedness (worker's view; single-mated queen unless stated) ---\n")
sister_r <- function(k) 0.5 * 0.5 + 0.5 * (1 / k) # maternal half + paternal half (1 if same father)
cat("Sister, queen mated once:", sister_r(1), "\n")
cat("Sister, queen mated with 2, 5, 10 equally successful males:",
    sister_r(2), sister_r(5), sister_r(10), "\n")
cat("Own daughter: 0.5; brother: 0.25; mean over equal sex ratio of siblings:",
    (0.75 + 0.25) / 2, "\n")

cat("\n--- Naked mole-rat (Reeve et al. 1990, PNAS 87: 2496-2500): r = 0.81, F = 0.45 ---\n")
cat("Ratio of colony relatedness to outbred full sibs:", round(0.81 / 0.5, 2), "\n")

cat("\n--- Zebrafish alarm response (Gandolfi 1972; digitised from Neal Fig. 19.2) ---\n")
zf_low4 <- -2.58; zf_high4 <- -5.86
cat("Difference in log10 ED50 at generation 4:", zf_low4 - zf_high4,
    "-> fold difference", round(10^(zf_low4 - zf_high4)), "\n")

cat("\n--- Hawk-Dove game, payoff to row player ---\n")
hd <- function(B, C, D) {
  m <- matrix(c((B - C) / 2, B, 0, B / 2 - D), 2, byrow = TRUE,
              dimnames = list(c("Hawk", "Dove"), c("vs Hawk", "vs Dove")))
  m
}
for (sc in list(c(50, 25, 10), c(50, 100, 10), c(4, 3, 0))) {
  m <- hd(sc[1], sc[2], sc[3])
  cat(sprintf("\nB = %g, C = %g, D = %g\n", sc[1], sc[2], sc[3])); print(m)
  cat("Hawk invades Doves?", m["Hawk", "vs Dove"] > m["Dove", "vs Dove"],
      "| Dove invades Hawks?", m["Dove", "vs Hawk"] > m["Hawk", "vs Hawk"], "\n")
  a <- m[1, 1]; b <- m[1, 2]; c <- m[2, 1]; d <- m[2, 2]
  if (c > a && b > d) {
    p <- (b - d) / ((b - d) + (c - a))
    cat("Mixed ESS p* =", p, "=", MASS_frac <- paste0(round(p * 12), "/12"),
        "| mean payoff at ESS =", a * p + b * (1 - p), "\n")
    cat("General formula (B/2 + D)/(C/2 + D) =", (sc[1] / 2 + sc[3]) / (sc[2] / 2 + sc[3]), "\n")
  }
}
cat("\nWith D = 0 (classic Maynard Smith): p* = B/C, e.g. B = 50, C = 100 ->", 50 / 100, "\n")

cat("\n--- Hawk-Dove-Bourgeois, B = 50, C = 100, D = 10 (Neal Table 19.5) ---\n")
a <- -25; b <- 50; c <- 0; d <- 15
hdb <- matrix(c(a, b, (a + b) / 2,
                c, d, (c + d) / 2,
                (a + c) / 2, (b + d) / 2, (b + c) / 2), 3, byrow = TRUE,
              dimnames = list(c("Hawk", "Dove", "Bourgeois"), c("vs H", "vs D", "vs B")))
print(hdb)
cat("Bourgeois resists Hawk:", hdb["Hawk", "vs B"] < hdb["Bourgeois", "vs B"],
    "| resists Dove:", hdb["Dove", "vs B"] < hdb["Bourgeois", "vs B"], "\n")
cat("Note: Neal's printed table shows 32 for Bourgeois vs Dove; (b + d)/2 =", (b + d) / 2, "\n")
cat("Bourgeois is an ESS whenever B < C: Hawk vs Bourgeois = (3B - C)/4 < B/2 <=> B < C\n")
