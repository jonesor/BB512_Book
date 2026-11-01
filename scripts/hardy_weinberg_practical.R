# Edit the inputs here; both the practical and its solutions read this file.
hwe <- local({
  inputs <- list(
    worked_recessive = 0.16,
    problem1_A = 0.8,
    problem2_SS = 0.09,
    problem3_counts = c(AA = 90, Aa = 70, aa = 40),
    problem4_white = 0.4
  )
  frequencies <- unlist(inputs[c("worked_recessive", "problem1_A",
                                 "problem2_SS", "problem4_white")])
  counts <- inputs$problem3_counts
  stopifnot(all(is.finite(frequencies)), all(frequencies > 0 & frequencies < 1),
            identical(names(counts), c("AA", "Aa", "aa")),
            all(is.finite(counts)), all(counts >= 0),
            all(counts == floor(counts)), sum(counts) > 0)

  genotype_frequencies <- function(p) {
    q <- 1 - p
    list(p = p, q = q, AA = p^2, Aa = 2 * p * q, aa = q^2,
         dominant = 1 - q^2)
  }
  worked <- genotype_frequencies(1 - sqrt(inputs$worked_recessive))
  p1 <- genotype_frequencies(inputs$problem1_A)
  p2 <- genotype_frequencies(1 - sqrt(inputs$problem2_SS))
  p4 <- genotype_frequencies(1 - sqrt(inputs$problem4_white))
  p4$heterozygous_among_brown <- p4$Aa / p4$dominant

  N <- sum(counts)
  A_copies <- 2 * counts["AA"] + counts["Aa"]
  a_copies <- 2 * counts["aa"] + counts["Aa"]
  p3 <- genotype_frequencies(unname(A_copies / (2 * N)))
  p3$N <- N
  p3$observed <- counts
  p3$A_copies <- unname(A_copies)
  p3$a_copies <- unname(a_copies)
  p3$expected <- N * c(AA = p3$AA, Aa = p3$Aa, aa = p3$aa)
  stopifnot(all(p3$expected > 0))
  p3$contributions <- (counts - p3$expected)^2 / p3$expected
  p3$chi_square <- sum(p3$contributions)
  p3$p_value <- pchisq(p3$chi_square, df = 1, lower.tail = FALSE)
  p3$Ho <- unname(counts["Aa"] / N)
  p3$F <- 1 - p3$Ho / p3$Aa
  delta <- unname(counts["Aa"] - p3$expected["Aa"])
  p3$pattern <- if (abs(delta) < 1e-10) "match" else if (delta < 0) "deficit" else "excess"

  fmt <- function(x, digits = 6) {
    if (digits == 0) return(formatC(x, format = "f", digits = 0))
    sub("\\.$", "", sub("0+$", "", formatC(x, format = "f", digits = digits)))
  }
  pct <- function(x) fmt(100 * x, digits = 1)
  p3$comparison <- switch(p3$pattern,
    deficit = "There are fewer heterozygotes than expected, and more of both homozygotes: a heterozygote deficit.",
    excess = "There are more heterozygotes than expected, and fewer of both homozygotes: a heterozygote excess.",
    match = "The observed counts match the HWE expectations.")
  p3$explanations <- switch(p3$pattern,
    deficit = "Possible explanations include inbreeding or other non-random mating, combining partly separated subpopulations (the Wahlund effect), selection against heterozygotes, or genotyping errors.",
    excess = "Possible explanations include mating between unlike genotypes, selection favouring heterozygotes, or genotyping errors.",
    match = "Matching HWE expectations does not establish that every HWE assumption holds.")
  p3$test_interpretation <- if (any(p3$expected < 5)) {
    "Some expected counts are below 5, so the chi-square approximation may be unreliable; an exact HWE test is preferable."
  } else if (p3$p_value < 0.05) {
    "The test provides evidence of a departure from HWE at the 5% significance level. It does not identify the cause."
  } else {
    "The test does not provide evidence of a departure from HWE at the 5% significance level. This does not prove that all HWE assumptions hold."
  }
  list(inputs = inputs, worked = worked, p1 = p1, p2 = p2, p3 = p3, p4 = p4,
       fmt = fmt, pct = pct)
})
