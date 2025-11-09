# Understanding Why Standard Errors Increase for Intercept in Mixed Models
# This script demonstrates the key concepts from the textbook

library(lme4)
library(dplyr)

# Load the GPA data
load('data/gpa.RData')

# Data structure:
# - 200 students
# - 6 observations per student (semesters 0-5)
# - Total: 1200 observations

cat("Data structure:\n")
cat("Number of students:", length(unique(gpa$student)), "\n")
cat("Observations per student:", table(table(gpa$student))[1], "students with",
    names(table(table(gpa$student)))[1], "observations\n")
cat("Total observations:", nrow(gpa), "\n\n")

# ============================================================================
# MODEL 1: Standard Regression (WRONG - ignores clustering)
# ============================================================================
cat("=", rep("=", 70), "=\n", sep="")
cat("MODEL 1: Standard Linear Regression\n")
cat("=", rep("=", 70), "=\n", sep="")

gpa_lm = lm(gpa ~ occasion, data = gpa)
summary_lm = summary(gpa_lm)

cat("\nFixed Effects:\n")
cat("Intercept:     ", sprintf("%.4f", coef(gpa_lm)[1]),
    " (SE = ", sprintf("%.4f", summary_lm$coefficients[1,2]), ")\n", sep="")
cat("Occasion:      ", sprintf("%.4f", coef(gpa_lm)[2]),
    " (SE = ", sprintf("%.4f", summary_lm$coefficients[2,2]), ")\n", sep="")
cat("\nResidual SD:   ", sprintf("%.4f", sigma(gpa_lm)), "\n", sep="")
cat("\nWhat this assumes:\n")
cat("- All 1200 observations are independent\n")
cat("- Effective sample size = 1200\n")
cat("- This is WRONG because observations within students are correlated!\n\n")

# ============================================================================
# MODEL 2: Mixed Model with Random Intercepts (CORRECT)
# ============================================================================
cat("=", rep("=", 70), "=\n", sep="")
cat("MODEL 2: Mixed Model with Random Intercepts\n")
cat("=", rep("=", 70), "=\n", sep="")

gpa_mixed = lmer(gpa ~ occasion + (1 | student), data = gpa)
summary_mixed = summary(gpa_mixed)

cat("\nFixed Effects:\n")
cat("Intercept:     ", sprintf("%.4f", fixef(gpa_mixed)[1]),
    " (SE = ", sprintf("%.4f", summary_mixed$coefficients[1,2]), ")\n", sep="")
cat("Occasion:      ", sprintf("%.4f", fixef(gpa_mixed)[2]),
    " (SE = ", sprintf("%.4f", summary_mixed$coefficients[2,2]), ")\n", sep="")

cat("\nRandom Effects (Variance Components):\n")
vc = as.data.frame(VarCorr(gpa_mixed))
cat("Student SD (τ):", sprintf("%.4f", vc$sdcor[1]), "\n")
cat("Residual SD (σ):", sprintf("%.4f", vc$sdcor[2]), "\n")

cat("\nWhat this recognizes:\n")
cat("- Observations within students are correlated\n")
cat("- For intercept, effective sample size ≈ 200 (number of students)\n")
cat("- For occasion, effective sample size ≈ 1200 (within-student variation)\n\n")

# ============================================================================
# KEY COMPARISON
# ============================================================================
cat("=", rep("=", 70), "=\n", sep="")
cat("KEY COMPARISON: Why Standard Errors Change\n")
cat("=", rep("=", 70), "=\n", sep="")

se_lm_int = summary_lm$coefficients[1,2]
se_mixed_int = summary_mixed$coefficients[1,2]
se_lm_occ = summary_lm$coefficients[2,2]
se_mixed_occ = summary_mixed$coefficients[2,2]

cat("\nINTERCEPT Standard Error:\n")
cat("  Standard Regression: ", sprintf("%.4f", se_lm_int), "\n", sep="")
cat("  Mixed Model:         ", sprintf("%.4f", se_mixed_int), "\n", sep="")
cat("  Change:              ", sprintf("%.4f", se_mixed_int - se_lm_int),
    " (", sprintf("%+.1f%%", 100*(se_mixed_int/se_lm_int - 1)), ")\n", sep="")
cat("  → SE INCREASED because we recognize N=200 students, not N=1200 obs\n\n")

cat("OCCASION Standard Error:\n")
cat("  Standard Regression: ", sprintf("%.4f", se_lm_occ), "\n", sep="")
cat("  Mixed Model:         ", sprintf("%.4f", se_mixed_occ), "\n", sep="")
cat("  Change:              ", sprintf("%.4f", se_mixed_occ - se_lm_occ),
    " (", sprintf("%+.1f%%", 100*(se_mixed_occ/se_lm_occ - 1)), ")\n", sep="")
cat("  → SE DECREASED because σ is smaller (removed student variation)\n\n")

# ============================================================================
# VARIANCE DECOMPOSITION
# ============================================================================
cat("=", rep("=", 70), "=\n", sep="")
cat("VARIANCE DECOMPOSITION\n")
cat("=", rep("=", 70), "=\n", sep="")

tau_sq = vc$vcov[1]  # Student variance
sigma_sq = vc$vcov[2]  # Residual variance
total_var = tau_sq + sigma_sq
icc = tau_sq / total_var

cat("\nTotal variation in GPA breaks down into:\n")
cat("  Between students (τ²): ", sprintf("%.4f", tau_sq),
    " (", sprintf("%.1f%%", 100*tau_sq/total_var), ")\n", sep="")
cat("  Within students (σ²):  ", sprintf("%.4f", sigma_sq),
    " (", sprintf("%.1f%%", 100*sigma_sq/total_var), ")\n", sep="")
cat("  Total variance:        ", sprintf("%.4f", total_var), "\n\n", sep="")

cat("Intraclass Correlation (ICC):", sprintf("%.4f", icc), "\n")
cat("→ Correlation between any two observations from the same student\n")
cat("→", sprintf("%.1f%%", 100*icc), "of variance is due to student differences\n\n")

# ============================================================================
# WHY THIS MATTERS: Effective Sample Size
# ============================================================================
cat("=", rep("=", 70), "=\n", sep="")
cat("INTUITION: Effective Sample Size\n")
cat("=", rep("=", 70), "=\n", sep="")

cat("\nFor the INTERCEPT (average starting GPA):\n")
cat("  - This is a BETWEEN-student comparison\n")
cat("  - We're comparing Student 1's average vs Student 2's average vs ...\n")
cat("  - We have 200 students, so N_effective ≈ 200\n")
cat("  - With ICC =", sprintf("%.2f", icc), ", observations within student are highly correlated\n")
cat("  - More uncertainty → Larger SE\n\n")

cat("For OCCASION (time trend):\n")
cat("  - This is a WITHIN-student comparison\n")
cat("  - We compare each student's semester 1 vs 2 vs 3...\n")
cat("  - We have 1200 total observations for this comparison\n")
cat("  - After removing between-student variance, σ is smaller\n")
cat("  - Less uncertainty → Smaller SE\n\n")

# ============================================================================
# DEMONSTRATION: What standard regression thinks
# ============================================================================
cat("=", rep("=", 70), "=\n", sep="")
cat("WHAT WENT WRONG IN STANDARD REGRESSION?\n")
cat("=", rep("=", 70), "=\n", sep="")

cat("\nStandard regression residual SD:", sprintf("%.4f", sigma(gpa_lm)), "\n")
cat("This mixes two sources of variation:\n")
cat("  1. Between-student differences (τ =", sprintf("%.4f", vc$sdcor[1]), ")\n")
cat("  2. Within-student variation    (σ =", sprintf("%.4f", vc$sdcor[2]), ")\n\n")

cat("Standard regression SE for intercept is based on:\n")
cat("  SE ≈ σ / sqrt(N) =", sprintf("%.4f", sigma(gpa_lm)),
    "/ sqrt(1200) =", sprintf("%.4f", sigma(gpa_lm)/sqrt(1200)), "\n\n")

cat("But the CORRECT SE should account for clustering.\n")
cat("Mixed model SE for intercept incorporates:\n")
cat("  - Between-student variance (τ² =", sprintf("%.4f", tau_sq), ")\n")
cat("  - Number of students (n = 200)\n")
cat("  - Number of observations per student (m = 6)\n")
cat("  Result: SE =", sprintf("%.4f", se_mixed_int), "\n\n")

cat("The standard regression was OVERCONFIDENT (SE too small) because it\n")
cat("treated 1200 correlated observations as if they were independent.\n\n")

# ============================================================================
# SUMMARY
# ============================================================================
cat("=", rep("=", 70), "=\n", sep="")
cat("SUMMARY\n")
cat("=", rep("=", 70), "=\n", sep="")

cat("\n1. Intercept SE INCREASES:\n")
cat("   - Intercept is about differences BETWEEN students\n")
cat("   - N_effective = 200 (students), not 1200 (observations)\n")
cat("   - Mixed model correctly recognizes this\n\n")

cat("2. Occasion SE DECREASES:\n")
cat("   - Occasion is about changes WITHIN students over time\n")
cat("   - Removing between-student variance reduces residual σ\n")
cat("   - Smaller σ → smaller SE\n\n")

cat("3. This is a FEATURE, not a bug:\n")
cat("   - Standard regression gave us falsely precise estimates\n")
cat("   - Mixed model gives honest uncertainty quantification\n")
cat("   - Always use mixed models when you have clustered data!\n\n")

cat("From the textbook (random_intercepts.Rmd:290):\n")
cat("'Allowing random intercepts per person allows us to gain information\n")
cat(" about the individual, while recognizing the uncertainty with regard\n")
cat(' to the overall average that we were underestimating before."\n\n')
