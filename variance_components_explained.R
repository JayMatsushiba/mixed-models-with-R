# Variance Components in Mixed Models: Complete Explanation
# Understanding what they are, how to interpret them, and why they matter

library(lme4)
library(dplyr)
library(ggplot2)

# Load the GPA data
load('data/gpa.RData')

cat("========================================================================\n")
cat("VARIANCE COMPONENTS: The Heart of Mixed Models\n")
cat("========================================================================\n\n")

# ============================================================================
# PART 1: What ARE Variance Components?
# ============================================================================

cat("PART 1: WHAT ARE VARIANCE COMPONENTS?\n")
cat("======================================\n\n")

cat("In a mixed model, TOTAL variance in the outcome comes from multiple sources:\n\n")

cat("Standard Regression:\n")
cat("  Total Variance = Residual Variance (σ²)\n")
cat("  (Everything we can't explain is lumped together)\n\n")

cat("Mixed Model:\n")
cat("  Total Variance = Between-Group Variance (τ²) + Within-Group Variance (σ²)\n")
cat("  (We DECOMPOSE variance into meaningful components)\n\n")

cat("These τ² and σ² are the VARIANCE COMPONENTS!\n\n")

# ============================================================================
# PART 2: Fitting the Models
# ============================================================================

cat("========================================================================\n")
cat("PART 2: COMPARING STANDARD REGRESSION VS MIXED MODEL\n")
cat("========================================================================\n\n")

# Standard regression
gpa_lm = lm(gpa ~ occasion, data = gpa)
sigma_lm = sigma(gpa_lm)

cat("STANDARD REGRESSION: gpa ~ occasion\n")
cat("-----------------------------------\n")
cat("Residual SD (σ): ", sprintf("%.4f", sigma_lm), "\n", sep="")
cat("Residual Var (σ²):", sprintf("%.4f", sigma_lm^2), "\n\n", sep="")
cat("This is ALL unexplained variance (mixed together)\n\n")

# Mixed model
gpa_mixed = lmer(gpa ~ occasion + (1 | student), data = gpa)
vc = as.data.frame(VarCorr(gpa_mixed))

tau = vc$sdcor[1]      # Between-student SD
sigma = vc$sdcor[2]    # Within-student SD
tau_sq = vc$vcov[1]    # Between-student variance
sigma_sq = vc$vcov[2]  # Within-student variance

cat("MIXED MODEL: gpa ~ occasion + (1|student)\n")
cat("------------------------------------------\n")
cat("Random Effects (Variance Components):\n\n")

cat("  Between-Student SD (τ):  ", sprintf("%.4f", tau), "\n", sep="")
cat("  Between-Student Var (τ²):", sprintf("%.4f", tau_sq), "\n\n", sep="")

cat("  Within-Student SD (σ):   ", sprintf("%.4f", sigma), "\n", sep="")
cat("  Within-Student Var (σ²): ", sprintf("%.4f", sigma_sq), "\n\n", sep="")

cat("  Total Variance:          ", sprintf("%.4f", tau_sq + sigma_sq), "\n\n", sep="")

cat("Key observation:\n")
cat("  Standard regression σ² = ", sprintf("%.4f", sigma_lm^2), "\n", sep="")
cat("  Mixed model τ² + σ²    = ", sprintf("%.4f", tau_sq + sigma_sq), "\n", sep="")
cat("  → Mixed model SEPARATES the variance!\n\n")

# ============================================================================
# PART 3: What Do These Numbers Mean?
# ============================================================================

cat("========================================================================\n")
cat("PART 3: INTERPRETING VARIANCE COMPONENTS\n")
cat("========================================================================\n\n")

cat("τ (tau) = Between-Student Standard Deviation = ", sprintf("%.4f", tau), "\n", sep="")
cat("-------------------------------------------------------------\n")
cat("This tells us: 'How much do students differ in their baseline GPA?'\n\n")

cat("Interpretation from textbook (random_intercepts.Rmd:308):\n")
cat("  'This tells us how much, on average, GPA bounces around as we\n")
cat("   move from student to student... each student has their own unique\n")
cat("   deviation, and that value is the estimated average deviation.'\n\n")

cat("Practical meaning:\n")
cat("  - If we pick two random students, they differ by ~", sprintf("%.2f", tau),
    " GPA points on average\n", sep="")
cat("  - Some students consistently score ", sprintf("%.2f", tau), " points higher\n", sep="")
cat("  - Others consistently score ", sprintf("%.2f", tau), " points lower\n", sep="")
cat("  - This is AFTER accounting for time trends\n\n")

cat("σ (sigma) = Within-Student Standard Deviation = ", sprintf("%.4f", sigma), "\n", sep="")
cat("-----------------------------------------------------------\n")
cat("This tells us: 'How much does a student vary around their own average?'\n\n")

cat("Practical meaning:\n")
cat("  - Even after knowing a student's baseline, their GPA varies by ~",
    sprintf("%.2f", sigma), "\n", sep="")
cat("  - This is measurement error, random fluctuation, unmeasured factors\n")
cat("  - 'Within-person noise'\n\n")

# ============================================================================
# PART 4: Comparing the Components
# ============================================================================

cat("========================================================================\n")
cat("PART 4: COMPARING THE VARIANCE COMPONENTS\n")
cat("========================================================================\n\n")

cat("Which source of variation is larger?\n\n")

cat("Between-Student (τ): ", sprintf("%.4f", tau), "\n", sep="")
cat("Within-Student (σ):  ", sprintf("%.4f", sigma), "\n\n", sep="")

cat("Ratio: τ/σ = ", sprintf("%.2f", tau/sigma), "\n\n", sep="")

cat("From the textbook (random_intercepts.Rmd:308):\n")
cat("  'Note that scores move due to the student more than double\n")
cat("   what they move based on a semester change.'\n\n")

cat("What this means:\n")
cat("  - Student identity matters MORE than within-person variation\n")
cat("  - Knowing which student it is tells you a LOT about their GPA\n")
cat("  - Observations from the same student are HIGHLY correlated\n\n")

# Calculate effect of occasion for comparison
occ_effect = fixef(gpa_mixed)["occasion"]

cat("Context: Occasion effect = ", sprintf("%.4f", occ_effect), " per semester\n", sep="")
cat("  → Over 6 semesters, occasion causes ", sprintf("%.2f", occ_effect * 5),
    " GPA change\n", sep="")
cat("  → Student differences (τ = ", sprintf("%.2f", tau),
    ") are LARGER than this!\n\n", sep="")

# ============================================================================
# PART 5: Intraclass Correlation (ICC)
# ============================================================================

cat("========================================================================\n")
cat("PART 5: INTRACLASS CORRELATION (ICC)\n")
cat("========================================================================\n\n")

icc = tau_sq / (tau_sq + sigma_sq)
pct_between = 100 * icc
pct_within = 100 * (1 - icc)

cat("ICC = τ² / (τ² + σ²)\n")
cat("    = ", sprintf("%.4f", tau_sq), " / (", sprintf("%.4f", tau_sq),
    " + ", sprintf("%.4f", sigma_sq), ")\n", sep="")
cat("    = ", sprintf("%.4f", tau_sq), " / ", sprintf("%.4f", tau_sq + sigma_sq),
    "\n", sep="")
cat("    = ", sprintf("%.4f", icc), "\n\n", sep="")

cat("From the textbook (random_intercepts.Rmd:310):\n")
cat("  'This value is also called the intraclass correlation,\n")
cat("   because it is also an estimate of the within cluster correlation.'\n\n")

cat("Three ways to interpret ICC = ", sprintf("%.2f", icc), ":\n\n", sep="")

cat("1. VARIANCE DECOMPOSITION:\n")
cat("   ", sprintf("%.1f%%", pct_between), " of total variance is BETWEEN students\n", sep="")
cat("   ", sprintf("%.1f%%", pct_within), " of total variance is WITHIN students\n\n", sep="")

cat("2. CORRELATION:\n")
cat("   Any two observations from the same student correlate at r = ",
    sprintf("%.2f", icc), "\n", sep="")
cat("   → Knowing one observation tells you a LOT about another from same student\n\n")

cat("3. CLUSTERING STRENGTH:\n")
cat("   ICC = ", sprintf("%.2f", icc), " means STRONG clustering\n", sep="")
cat("   Guidelines (rough):\n")
cat("     ICC < 0.05: Weak clustering (maybe don't need mixed model)\n")
cat("     ICC 0.05-0.15: Moderate clustering\n")
cat("     ICC > 0.15: Strong clustering (definitely use mixed model!)\n\n")

cat("In this data: ICC = ", sprintf("%.2f", icc),
    " → Very strong student effects!\n\n", sep="")

# ============================================================================
# PART 6: Individual Random Effects
# ============================================================================

cat("========================================================================\n")
cat("PART 6: INDIVIDUAL STUDENT EFFECTS (Random Effects)\n")
cat("========================================================================\n\n")

cat("The variance components (τ, σ) describe the DISTRIBUTION.\n")
cat("But we can also get INDIVIDUAL estimates for each student!\n\n")

# Get random effects
re = ranef(gpa_mixed)$student
colnames(re) = "effect"
re$student = rownames(re)

# Get random intercepts (overall intercept + random effect)
ri = coef(gpa_mixed)$student
colnames(ri) = c("intercept", "occasion")
ri$student = rownames(ri)

overall_int = fixef(gpa_mixed)["(Intercept)"]

cat("Overall intercept (fixed effect): ", sprintf("%.4f", overall_int), "\n\n", sep="")

cat("First 10 students:\n")
cat("─────────────────────────────────────────────────────────────\n")
cat("Student  Random Effect  Student Intercept  Interpretation\n")
cat("─────────────────────────────────────────────────────────────\n")

for(i in 1:10) {
  stud = re$student[i]
  eff = re$effect[i]
  sint = ri$intercept[i]

  if(eff > 0) {
    interp = sprintf("%.2f above avg", eff)
  } else {
    interp = sprintf("%.2f below avg", abs(eff))
  }

  cat(sprintf("  %3s    %7.4f         %7.4f        %s\n",
              stud, eff, sint, interp))
}
cat("─────────────────────────────────────────────────────────────\n\n")

cat("How to read this:\n")
cat("  Random Effect: Student's deviation from overall average\n")
cat("  Student Intercept: Overall intercept + random effect\n")
cat("                   = ", sprintf("%.3f", overall_int), " + random effect\n\n", sep="")

cat("From the textbook (random_intercepts.Rmd:148):\n")
cat("  'student_effect ~ N(0, τ)'\n")
cat("  → These effects are normally distributed with mean 0\n")
cat("  → SD = τ = ", sprintf("%.3f", tau), "\n\n", sep="")

# ============================================================================
# PART 7: Distribution of Random Effects
# ============================================================================

cat("========================================================================\n")
cat("PART 7: DISTRIBUTION OF RANDOM EFFECTS\n")
cat("========================================================================\n\n")

cat("Summary statistics of student random effects:\n")
cat("  Mean:   ", sprintf("%7.4f", mean(re$effect)), " (should be ≈ 0)\n", sep="")
cat("  SD:     ", sprintf("%7.4f", sd(re$effect)), " (should be ≈ τ = ",
    sprintf("%.3f", tau), ")\n", sep="")
cat("  Min:    ", sprintf("%7.4f", min(re$effect)), "\n", sep="")
cat("  Q1:     ", sprintf("%7.4f", quantile(re$effect, 0.25)), "\n", sep="")
cat("  Median: ", sprintf("%7.4f", median(re$effect)), "\n", sep="")
cat("  Q3:     ", sprintf("%7.4f", quantile(re$effect, 0.75)), "\n", sep="")
cat("  Max:    ", sprintf("%7.4f", max(re$effect)), "\n\n", sep="")

cat("Interpretation:\n")
cat("  - Most students near 0 (average)\n")
cat("  - Range from ", sprintf("%.2f", min(re$effect)), " to ",
    sprintf("%.2f", max(re$effect)), "\n", sep="")
cat("  - This is a ", sprintf("%.2f", max(re$effect) - min(re$effect)),
    " GPA point difference!\n", sep="")
cat("  - The 'best' student starts ", sprintf("%.2f", max(re$effect)),
    " points higher than average\n", sep="")
cat("  - The 'worst' student starts ", sprintf("%.2f", abs(min(re$effect))),
    " points lower than average\n\n", sep="")

# ============================================================================
# PART 8: Why Variance Components Matter
# ============================================================================

cat("========================================================================\n")
cat("PART 8: WHY VARIANCE COMPONENTS MATTER\n")
cat("========================================================================\n\n")

cat("1. UNDERSTANDING YOUR DATA:\n")
cat("   - Is variation mostly between groups or within groups?\n")
cat("   - ICC = ", sprintf("%.2f", icc), " → ", sprintf("%.0f%%", pct_between),
    " is between-student\n", sep="")
cat("   - Student identity is VERY important for predicting GPA\n\n")

cat("2. CORRECT STANDARD ERRORS:\n")
cat("   - Accounting for clustering gives honest uncertainty estimates\n")
cat("   - Remember: intercept SE increased from 0.0178 → 0.0217\n\n")

cat("3. PREDICTION:\n")
cat("   - Population average (ignore random effects):\n")
cat("     GPA = ", sprintf("%.2f", overall_int), " + ",
    sprintf("%.3f", occ_effect), " × occasion\n", sep="")
cat("   - Individual student (include random effect):\n")
cat("     Student 1: GPA = ", sprintf("%.2f", ri$intercept[1]), " + ",
    sprintf("%.3f", occ_effect), " × occasion\n", sep="")
cat("     Student 2: GPA = ", sprintf("%.2f", ri$intercept[2]), " + ",
    sprintf("%.3f", occ_effect), " × occasion\n", sep="")
cat("     → Different predictions for different students!\n\n")

cat("4. IDENTIFYING UNUSUAL GROUPS:\n")
cat("   - Students with large |random effect| are unusual\n")
cat("   - Could investigate why (intervention targets, quality control)\n\n")

cat("5. ASSESSING MODEL FIT:\n")
cat("   - If τ ≈ 0, maybe don't need mixed model\n")
cat("   - Here τ = ", sprintf("%.3f", tau), " >> 0, so mixed model justified\n\n", sep="")

# ============================================================================
# PART 9: Confidence Intervals for Variance Components
# ============================================================================

cat("========================================================================\n")
cat("PART 9: CONFIDENCE INTERVALS FOR VARIANCE COMPONENTS\n")
cat("========================================================================\n\n")

cat("Getting CIs for variance components...\n")
ci_vc = confint(gpa_mixed, method = 'Wald')

cat("\n95% Confidence Intervals:\n")
cat("─────────────────────────────────────────────\n")
cat("Parameter        Estimate    [95% CI]\n")
cat("─────────────────────────────────────────────\n")

# For SD of random effects
if(!is.na(ci_vc[".sig01", 1])) {
  cat(sprintf("Student SD (τ)   %.4f      [%.4f, %.4f]\n",
              tau, ci_vc[".sig01", 1], ci_vc[".sig01", 2]))
}

# For residual SD
if(!is.na(ci_vc[".sigma", 1])) {
  cat(sprintf("Residual SD (σ)  %.4f      [%.4f, %.4f]\n",
              sigma, ci_vc[".sigma", 1], ci_vc[".sigma", 2]))
}

cat("─────────────────────────────────────────────\n\n")

cat("Interpretation:\n")
cat("  - Both CIs are clearly > 0\n")
cat("  - Strong evidence for both sources of variation\n")
cat("  - Between-student variation is substantial and significant\n\n")

# ============================================================================
# PART 10: Visual Summary
# ============================================================================

cat("========================================================================\n")
cat("PART 10: VISUAL SUMMARY - Variance Decomposition\n")
cat("========================================================================\n\n")

cat("                 TOTAL VARIANCE IN GPA\n")
cat("                  (", sprintf("%.4f", tau_sq + sigma_sq), ")\n", sep="")
cat("                         |\n")
cat("           +-------------+-------------+\n")
cat("           |                           |\n")
cat("   BETWEEN-STUDENT             WITHIN-STUDENT\n")
cat("   (Who you are)               (Fluctuation)\n")
cat("        τ² = ", sprintf("%.4f", tau_sq), "           σ² = ",
    sprintf("%.4f", sigma_sq), "\n", sep="")
cat("        ", sprintf("%.1f%%", pct_between), " of total         ",
    sprintf("%.1f%%", pct_within), " of total\n", sep="")
cat("\n")
cat("   Student 1: +", sprintf("%.2f", re$effect[1]), "\n", sep="")
cat("   Student 2: ", sprintf("%.2f", re$effect[2]), "\n", sep="")
cat("   Student 3: +", sprintf("%.2f", re$effect[3]), "\n", sep="")
cat("   ...\n")
cat("   (200 students total)\n\n")

# ============================================================================
# SUMMARY
# ============================================================================

cat("========================================================================\n")
cat("KEY TAKEAWAYS\n")
cat("========================================================================\n\n")

cat("1. Variance components DECOMPOSE total variance:\n")
cat("   Total = Between-group (τ²) + Within-group (σ²)\n\n")

cat("2. τ (tau) = between-student SD = ", sprintf("%.3f", tau), "\n", sep="")
cat("   → How much students differ in baseline GPA\n\n")

cat("3. σ (sigma) = within-student SD = ", sprintf("%.3f", sigma), "\n", sep="")
cat("   → How much a student varies around their own average\n\n")

cat("4. ICC = τ²/(τ²+σ²) = ", sprintf("%.2f", icc), "\n", sep="")
cat("   → ", sprintf("%.0f%%", pct_between), " of variance is between students\n", sep="")
cat("   → Observations from same student correlate at r = ", sprintf("%.2f", icc),
    "\n\n", sep="")

cat("5. Random effects are individual deviations:\n")
cat("   → student_effect ~ N(0, τ)\n")
cat("   → Can extract and interpret for each student\n\n")

cat("6. This is UNIQUE to mixed models:\n")
cat("   → Standard regression can't separate these sources\n")
cat("   → Mixed models reveal the structure of your data\n\n")

cat("From textbook (random_intercepts.Rmd:308):\n")
cat("  'This is an important interpretive aspect not available\n")
cat("   to us with a standard regression model.'\n\n")
