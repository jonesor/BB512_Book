# Arithmetic check for every number used on the slides and in the speaker notes
# of BB512 lecture "Evolution of life histories". Makes no figure.
# Run from the lecture folder: LANG=C.UTF-8 Rscript scripts/00_check_numbers.R

cat("\n== Force of selection thought experiment (slides 'Thought experiment') ==\n")
# Fictional organism kept from the previous version of the lecture, now with the practical's 25 ages:
# first breeds at age 1, survives each year with probability 0.8, 10 offspring per year, at most 25 breeding ages.
s <- 0.8; m <- 10; ages <- 1:25
lx <- s^(ages - 1)                       # l_1 = 1
R0 <- sum(lx * m)
cat("R0 (ages 1-25)                        :", round(R0, 2), "\n")              # 49.81
cat("l_x at ages 1,2,3,23,24,25            :", round(lx[c(1, 2, 3, 23, 24, 25)], 4), "\n")
cat("Expected offspring at age 25 (l25*m)  :", round(lx[25] * m, 3), "\n")      # 0.047
cat("Dies before age 25, no benefit        :", round(R0 - lx[25] * m, 2), "\n")  # 49.76
cat("+1 offspring at age 1, dies before 25 :", round(R0 + 1 * lx[1] - lx[25] * m, 2), "\n")  # 50.76
cat("+1 offspring at age 1, no cost        :", round(R0 + 1, 2), "\n")         # 50.81
cat("Share of R0 from ages 1-5            :", round(sum(lx[1:5] * m) / R0, 3), "\n")  # 0.675
cat("Share of R0 from ages 15+            :", round(sum(lx[15:25] * m) / R0, 3), "\n")
# Break-even: earliest death age at which +1 at age 1 still beats the normal life history
be <- sapply(2:25, function(k) R0 + 1 - sum(lx[k:25] * m))
cat("+1 at age 1, dies before age k, k = 15..20:", round(be[14:19], 2), "\n")  # crosses R0 between 17 and 18

cat("\n== Practical 'Trade-offs and the declining force of selection' (25 ages) ==\n")
lx25 <- s^(0:24)
cat("R0 (ages 1-25) =", round(sum(lx25 * m), 2), "; +1 at age 1 =", round(sum(lx25 * m) + 1, 2), "\n")  # 49.81, 50.81

cat("\n== Red deer, Rhum 1957 (Neal 2004, Table 16.1, from Lowe 1969) ==\n")
deer <- data.frame(
  x  = 0:16,
  lx = c(1.000, 0.760, 0.656, 0.591, 0.527, 0.463, 0.400, 0.336, 0.271, 0.138,
         0.045, 0.039, 0.032, 0.026, 0.019, 0.013, 0.009),
  mx = c(0, 0, 0, 0.311, 0.278, 0.302, 0.400, 0.476, 0.358, 0.447,
         0.289, 0.283, 0.285, 0.283, 0.282, 0.285, 0.284))
deer$lxmx <- deer$lx * deer$mx
R0d <- sum(deer$lxmx)
cat("R0 = sum(lx mx)                       :", round(R0d, 3), "(Neal: 1.000)\n")
# Hamilton's (1966) force of selection on survival from age a to a + 1, stationary population (r = 0):
# the share of lifetime reproduction that still lies ahead after age a: sum_{y > a} l_y m_y / R0
deer$force <- sapply(deer$x, function(a) sum(deer$lxmx[deer$x > a]) / R0d)
print(round(deer[, c("x", "lx", "mx", "lxmx", "force")], 3), row.names = FALSE)
# Neal's reproductive value (Eqn 16.2), for the notes
deer$vx <- sapply(deer$x, function(a) sum(deer$lxmx[deer$x >= a]) / deer$lx[deer$x == a])
cat("v_x at ages 0, 3, 9:", round(deer$vx[deer$x %in% c(0, 3, 9)], 3), "(Neal: 1.000, 1.692, 0.820)\n")

cat("\n== Lack's Swiss starlings (Neal 2004, Table 16.2, from Lack 1948) ==\n")
st <- data.frame(brood = 1:10,
                 broods = c(65, 164, 426, 989, 1235, 526, 93, 15, 2, 1),
                 recovered = c(0, 6, 26, 82, 128, 53, 10, 1, 0, 0))
st$eggs <- st$brood * st$broods
st$per_brood <- st$recovered / st$broods
st$relative <- st$per_brood / max(st$per_brood)
print(transform(st, per_brood = round(per_brood, 4), relative = round(relative, 2)), row.names = FALSE)
cat("Broods:", sum(st$broods), " eggs:", sum(st$eggs), " recovered:", sum(st$recovered),
    " (", round(100 * sum(st$recovered) / sum(st$eggs), 1), "% of eggs )\n")
cat("Mean brood size:", round(sum(st$eggs) / sum(st$broods), 2), "(Neal: 4.5)\n")
cat("Neal's lifetime example: 6 young x 4 seasons =", 6 * 4, "; 5 young x 5 seasons =", 5 * 5, "\n")

cat("\n== Cole's paradox (Neal 2004, 'Frequency of reproduction'), self-study slide ==\n")
sA <- 0.9; sj <- 0.05
cat("Annual must make", sA, "more seeds than a perennial if all seeds survive\n")
cat("With adult survival", sA, "and juvenile survival", sj, ": sA/sj =", sA / sj, "more seeds\n")

cat("\n== Optimality schematic (script 03) ==\n")
# benefit B(x) = 10 (1 - exp(-x/3)), cost C(x) = 0.12 x^2 on 0..10; optimum where B'(x) = C'(x)
B <- function(x) 10 * (1 - exp(-x / 3)); C <- function(x) 0.12 * x^2
opt <- optimize(function(x) B(x) - C(x), c(0, 10), maximum = TRUE)
cat("Optimum trait value:", round(opt$maximum, 2), " net benefit:", round(opt$objective, 2), "\n")
