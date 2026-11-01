# 00_check_numbers.R  Prints every number quoted on the slides and in the notes.
source("R/models.R")
cat("Brower & Brower (1966), Neal, chapter on predation (table on Batesian mimicry)\n")
cat("  honeybees eaten by experimental toads:", round(100 * 36 / (36 + 44), 1), "% (Neal: 45%)\n")
cat("  droneflies eaten, experimental:", round(100 * 26 / (26 + 34), 1), "% (Neal: 43.3%)\n")
cat("  droneflies eaten, control:", round(100 * 110 / (110 + 30), 1), "% (Neal: 75.5%; discrepancy noted)\n")
rq <- sim_matching_alleles(gens = 300)
pk <- function(x) which(diff(sign(diff(x))) == -2) + 1
hp <- rq$generation[pk(rq$host)]; pp <- rq$generation[pk(rq$parasite)]
cat("Matching-alleles model: host peaks", head(hp, 6), "\n  parasite peaks", head(pp, 7), "\n")
cat("  mean period (host):", round(mean(diff(hp)), 1), "generations\n")
lag <- sapply(hp, function(h) suppressWarnings(min(pp[pp > h])) - h)
cat("  lag host peak -> parasite peak:", round(mean(lag[is.finite(lag)]), 1), "generations\n")
cat("  range of host allele freq (gens 150-300):", round(range(rq$host[151:300]), 2), "\n")
cat("Darwin's orchid: Darwin died 1882; moth described 1903 ->", 1903 - 1882, "years\n")
cat("Morgan's sphinx: Darwin prediction 1862 -> description 1903:", 1903 - 1862, "years\n")
cat("Darwin's 11.5 inch nectary =", round(11.5 * 2.54, 1), "cm\n")
cat("Cane toads introduced 1935; Phillips & Shine 2004 ->", 2004 - 1935, "years\n")
