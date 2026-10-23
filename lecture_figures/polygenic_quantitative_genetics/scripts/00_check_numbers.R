# Prints every number used on the slides and in the speaker notes (makes no figure).
cat("--- Wheat F2, 3 loci (Neal Fig. 12.1)\n")
cat("gamete types:", 2^3, " combinations:", 8 * 8, " genotypes:", 3^3, " phenotype classes:", 7, "\n")
cat("class counts:", choose(6, 0:6), " sum:", sum(choose(6, 0:6)), "\n")
cat("4 loci: classes", 2 * 4 + 1, "; extreme class frequency 1 /", 4^4, "\n")

cat("--- East (1916) Nicotiana, Neal section 12.2\n")
VP <- 40.5; VE <- 5.2; h2 <- 0.8348
VG <- VP - VE; VA <- h2 * VP; VNA <- VG - VA
cat(sprintf("VG = %.1f (%.0f%%), VE = %.1f (%.0f%%)\n", VG, 100 * VG / VP, VE, 100 * VE / VP))
cat(sprintf("VA = %.4f x %.1f = %.2f (%.0f%%); VD+VI = %.1f - %.1f = %.1f (%.0f%%)\n",
            h2, VP, VA, 100 * VA / VP, VG, round(VA, 1), round(VG - round(VA, 1), 1), 100 * round(VNA, 1) / VP))
cat(sprintf("broad-sense H2 = VG/VP = %.2f\n", VG / VP))

cat("--- Neal problem 12.1 (mice tails)\n")
F1 <- 2.5; F2 <- 12.5; b <- 0.75
cat(sprintf("h2 = %.2f; VE = %.2f; VG = %.2f; VA = %.3f; VD+VI = %.3f\n", b, F1, F2 - F1, b * F2, F2 - F1 - b * F2))
mp <- (88 + 92) / 2
cat(sprintf("(c) mid-parent %.0f, S = %.0f, R = %.1f, offspring mean %.1f\n", mp, mp - 80, b * (mp - 80), 80 + b * (mp - 80)))
cat(sprintf("    parents averaging 70: S = %.0f, R = %.1f, offspring mean %.1f\n", -10, b * -10, 80 + b * -10))

cat("--- Darwin's finch bill depth (previous slide numbers)\n")
cat(sprintf("0.793 x 0.447 = %.3f; 0.793 x 0.44 = %.3f\n", 0.793 * 0.447, 0.793 * 0.44))

cat("--- Breeder's equation, sheep\n")
cat(sprintf("S = 125 - 100 = %d; R = 0.5 x 25 = %.1f; new mean %.1f; if h2 = 0: %d; if h2 = 1: %d\n",
            25L, 0.5 * 25, 100 + 12.5, 100L, 125L))
cat(sprintf("Two generations at S = 25: mean %.1f\n", 100 + 2 * 12.5))

cat("--- Racehorses, Wilson & Rambaut (2008)\n")
cat(sprintf("h2 = 0.299 / 3.130 = %.3f; not additive genetic = %.1f%%\n", 0.299 / 3.130, 100 * (1 - 0.299 / 3.130)))

cat("--- Illinois corn (Neal Table 12.3)\n")
cat(sprintf("high line: %.2f -> %.2f (%.0f%% of start); low line %.2f -> %.2f (%.0f%%)\n",
            0.32, 0.12, 100 * 0.12 / 0.32, 0.50, 0.15, 100 * 0.15 / 0.50))
