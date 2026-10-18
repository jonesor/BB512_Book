# ==============================================================================
# DEMONSTRATION OF THE WAHLUND EFFECT IN R
# ==============================================================================

# 1. Define Allele Frequencies for Two Subpopulations
# Notice that Subpop A has a high frequency of 'A', while Subpop B has a low frequency.
p_A <- 0.8
q_A <- 1 - p_A

p_B <- 0.2
q_B <- 1 - p_B

# 2. Generate Genotype Frequencies assuming Perfect HWE within each subpopulation
# Genotype ratios: c(AA, Aa, aa)
subpop_A <- c(AA = p_A^2,      Aa = 2 * p_A * q_A, aa = q_A^2)
subpop_B <- c(AA = p_B^2,      Aa = 2 * p_B * q_B, aa = q_B^2)

cat("--- Individual Subpopulations (In Perfect HWE) ---\n")
print(round(subpop_A, 3))
print(round(subpop_B, 3))
cat("\n")

# 3. Pool the Two Subpopulations Together (Equally sized)
# The actual genotype distribution in our pooled sample is simply the average of the two.
pooled_observed_genotypes <- (subpop_A + subpop_B) / 2
obs_heterozygosity <- pooled_observed_genotypes["Aa"]

# 4. Calculate Pooled Allele Frequencies from the Combined Sample
p_mean <- (p_A + p_B) / 2
q_mean <- (1 - p_mean)

# 5. Calculate Expected Heterozygosity of the Pooled Sample based on Average Frequencies
# This is what a scientist would *expect* if they assumed the sample came from one random-mating population.
exp_heterozygosity <- 2 * p_mean * q_mean

# 6. Verify the Mathematical Law: Deficit = 2 * Variance
# Note: population variance uses 'n', so we adjust R's default sample variance (n-1)
allele_freq_variance <- var(c(p_A, p_B)) * (1 / 2) 
mathematical_deficit <- 2 * allele_freq_variance

# ==============================================================================
# DISPLAY THE RESULTS
# ==============================================================================
cat("--- Pooled Population Comparison ---\n")
cat(sprintf("Observed Heterozygosity (True Count):      %0.3f\n", obs_heterozygosity))
cat(sprintf("Expected Heterozygosity (Under HWE Formula): %0.3f\n", exp_heterozygosity))
cat(sprintf("Heterozygote Deficit (Expected - Observed):  %0.3f\n\n", exp_heterozygosity - obs_heterozygosity))

cat("--- Mathematical Proof Verification ---\n")
cat(sprintf("Twice the Variance of Allele Frequencies (2 * sigma^2): %0.3f\n", mathematical_deficit))
