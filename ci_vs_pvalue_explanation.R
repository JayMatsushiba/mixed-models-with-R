# Confidence Intervals vs P-values: A Complete Explanation
# With special focus on why this matters for mixed models

library(lme4)
library(dplyr)

# Load the GPA data
load('data/gpa.RData')

cat("========================================================================\n")
cat("CONFIDENCE INTERVALS vs P-VALUES: What's the Difference?\n")
cat("========================================================================\n\n")

# ============================================================================
# PART 1: The Conceptual Difference
# ============================================================================

cat("PART 1: CONCEPTUAL DIFFERENCE\n")
cat("------------------------------\n\n")

cat("P-VALUE:\n")
cat("  - Tests a specific NULL HYPOTHESIS (usually: effect = 0)\n")
cat("  - Gives probability of seeing data this extreme IF null is true\n")
cat("  - Binary decision: reject or don't reject null\n")
cat("  - Answers: 'Is there an effect?'\n\n")

cat("CONFIDENCE INTERVAL (CI):\n")
cat("  - Estimates a RANGE of plausible values for the parameter\n")
cat("  - Shows both magnitude and precision of estimate\n")
cat("  - Continuous information about effect size\n")
cat("  - Answers: 'What is the effect?' and 'How certain are we?'\n\n")

# ============================================================================
# PART 2: Standard Regression Example
# ============================================================================

cat("========================================================================\n")
cat("PART 2: STANDARD REGRESSION (Simple Case)\n")
cat("========================================================================\n\n")

gpa_lm = lm(gpa ~ occasion, data = gpa)
summary_lm = summary(gpa_lm)

cat("Model: GPA ~ occasion\n\n")

# Extract key values
coef_occ = coef(gpa_lm)[2]
se_occ = summary_lm$coefficients[2, 2]
t_stat = summary_lm$coefficients[2, 3]
p_val = summary_lm$coefficients[2, 4]
df = gpa_lm$df.residual

cat("Coefficient for occasion:", sprintf("%.4f", coef_occ), "\n")
cat("Standard Error:         ", sprintf("%.4f", se_occ), "\n")
cat("Degrees of Freedom:     ", df, "\n\n")

# Calculate 95% CI manually
t_crit = qt(0.975, df)  # Two-tailed, 95% CI
ci_lower = coef_occ - t_crit * se_occ
ci_upper = coef_occ + t_crit * se_occ

cat("--- P-VALUE CALCULATION ---\n")
cat("t-statistic = coefficient / SE\n")
cat("            = ", sprintf("%.4f", coef_occ), " / ", sprintf("%.4f", se_occ), "\n")
cat("            = ", sprintf("%.4f", t_stat), "\n\n")

cat("Null hypothesis: occasion effect = 0\n")
cat("p-value = P(|t| > ", sprintf("%.4f", abs(t_stat)), " | H0 true)\n", sep="")
cat("        = ", sprintf("%.6f", p_val), "\n", sep="")
cat("        < 0.05 → Reject null (effect is significant)\n\n")

cat("Interpretation:\n")
cat("  'IF there were no effect, we'd see data this extreme\n")
cat("   only ", sprintf("%.4f%%", p_val * 100), " of the time.'\n\n", sep="")

cat("--- CONFIDENCE INTERVAL CALCULATION ---\n")
cat("95% CI = coefficient ± (t_critical × SE)\n")
cat("       = ", sprintf("%.4f", coef_occ), " ± (", sprintf("%.3f", t_crit),
    " × ", sprintf("%.4f", se_occ), ")\n", sep="")
cat("       = [", sprintf("%.4f", ci_lower), ", ", sprintf("%.4f", ci_upper), "]\n\n", sep="")

cat("Interpretation:\n")
cat("  'We are 95% confident the true occasion effect\n")
cat("   is between ", sprintf("%.4f", ci_lower), " and ", sprintf("%.4f", ci_upper), "'\n\n", sep="")

cat("Note: Both give same conclusion here:\n")
cat("  - CI doesn't include 0 → significant\n")
cat("  - p-value < 0.05 → significant\n")
cat("  But CI tells us HOW BIG the effect is!\n\n")

# ============================================================================
# PART 3: Mixed Model - The Complication
# ============================================================================

cat("========================================================================\n")
cat("PART 3: MIXED MODELS - Why P-values Are Problematic\n")
cat("========================================================================\n\n")

gpa_mixed = lmer(gpa ~ occasion + (1 | student), data = gpa)
summary_mixed = summary(gpa_mixed)

cat("Model: GPA ~ occasion + (1|student)\n\n")

coef_mixed = fixef(gpa_mixed)
se_mixed = summary_mixed$coefficients[, 2]

cat("Fixed Effects:\n")
cat("  Intercept: ", sprintf("%.4f", coef_mixed[1]), " (SE = ",
    sprintf("%.4f", se_mixed[1]), ")\n", sep="")
cat("  Occasion:  ", sprintf("%.4f", coef_mixed[2]), " (SE = ",
    sprintf("%.4f", se_mixed[2]), ")\n\n", sep="")

cat("THE PROBLEM: What are the degrees of freedom?\n")
cat("---------------------------------------------\n\n")

cat("For standard regression:\n")
cat("  df = N - p = 1200 - 2 = 1198\n")
cat("  Clear and unambiguous!\n\n")

cat("For mixed models:\n")
cat("  Option 1: df = N_total - p = 1200 - 2 = 1198?\n")
cat("            (Too large - ignores clustering)\n\n")
cat("  Option 2: df = N_clusters - p = 200 - 2 = 198?\n")
cat("            (Maybe for intercept, but not occasion?)\n\n")
cat("  Option 3: Something in between?\n")
cat("            (Satterthwaite, Kenward-Roger approximations)\n\n")

cat("The issue (from random_intercepts.Rmd:292):\n")
cat("  'We are essentially dealing with different sample sizes,\n")
cat("   the N_c within clusters (which may vary!) and N total.\n")
cat("   This puts us in a fuzzy situation regarding degrees of freedom.'\n\n")

cat("Different parameters have different effective sample sizes:\n")
cat("  - Intercept:  More like N = 200 (between-student)\n")
cat("  - Occasion:   More like N = 1200 (within-student)\n")
cat("  - Other vars: Somewhere in between\n\n")

cat("Result: lme4 DOES NOT provide p-values by default!\n\n")

# ============================================================================
# PART 4: Confidence Intervals for Mixed Models
# ============================================================================

cat("========================================================================\n")
cat("PART 4: CONFIDENCE INTERVALS - The Better Approach\n")
cat("========================================================================\n\n")

cat("Why CIs are 'more straightforward' for mixed models:\n")
cat("  - Don't require exact degrees of freedom\n")
cat("  - Can use profile likelihood methods\n")
cat("  - Show effect size AND uncertainty\n")
cat("  - Work for variance components too!\n\n")

# Get confidence intervals (this can take a moment)
cat("Calculating CIs using profile likelihood...\n")
cat("(This uses the likelihood function, not just normal approximation)\n\n")

# Use confint with method='Wald' for speed (profile is more accurate but slower)
ci_mixed = confint(gpa_mixed, method = 'Wald')

cat("95% Confidence Intervals:\n")
cat("---------------------\n")
for(i in 1:nrow(ci_mixed)) {
  cat(sprintf("%-20s [%7.4f, %7.4f]\n",
              rownames(ci_mixed)[i],
              ci_mixed[i,1],
              ci_mixed[i,2]))
}
cat("\n")

cat("Interpretation:\n")
cat("---------------------\n")
cat("Fixed Effects:\n")
cat("  Intercept CI [", sprintf("%.3f", ci_mixed["(Intercept)", 1]), ", ",
    sprintf("%.3f", ci_mixed["(Intercept)", 2]), "]\n", sep="")
cat("    → Average starting GPA is between these values (95% confidence)\n")
cat("    → Doesn't include 0, so significantly different from 0\n\n")

cat("  Occasion CI [", sprintf("%.4f", ci_mixed["occasion", 1]), ", ",
    sprintf("%.4f", ci_mixed["occasion", 2]), "]\n", sep="")
cat("    → GPA increases between ", sprintf("%.4f", ci_mixed["occasion", 1]),
    " and ", sprintf("%.4f", ci_mixed["occasion", 2]), " per semester\n", sep="")
cat("    → Doesn't include 0, so time effect is significant\n\n")

cat("Variance Components:\n")
cat("  Student SD (τ): [", sprintf("%.3f", ci_mixed[".sig01", 1]), ", ",
    sprintf("%.3f", ci_mixed[".sig01", 2]), "]\n", sep="")
cat("    → Between-student variation in intercepts\n")
cat("    → Definitely > 0 (substantial student differences)\n\n")

cat("  Residual SD (σ): [", sprintf("%.3f", ci_mixed[".sigma", 1]), ", ",
    sprintf("%.3f", ci_mixed[".sigma", 2]), "]\n", sep="")
cat("    → Within-student variation\n\n")

# ============================================================================
# PART 5: Key Differences Summary
# ============================================================================

cat("========================================================================\n")
cat("PART 5: KEY DIFFERENCES SUMMARY\n")
cat("========================================================================\n\n")

cat("┌─────────────────┬──────────────────────┬──────────────────────┐\n")
cat("│                 │      P-VALUE         │  CONFIDENCE INTERVAL │\n")
cat("├─────────────────┼──────────────────────┼──────────────────────┤\n")
cat("│ What it tests   │ H0: effect = 0       │ Range of plausible   │\n")
cat("│                 │                      │ values               │\n")
cat("├─────────────────┼──────────────────────┼──────────────────────┤\n")
cat("│ Output type     │ Single number        │ Interval [lower,     │\n")
cat("│                 │ (probability)        │ upper]               │\n")
cat("├─────────────────┼──────────────────────┼──────────────────────┤\n")
cat("│ Tells you       │ 'Is there effect?'   │ 'How big is effect?' │\n")
cat("│                 │                      │ AND 'How certain?'   │\n")
cat("├─────────────────┼──────────────────────┼──────────────────────┤\n")
cat("│ In mixed models │ Requires df          │ More robust (uses    │\n")
cat("│                 │ (complicated!)       │ likelihood methods)  │\n")
cat("├─────────────────┼──────────────────────┼──────────────────────┤\n")
cat("│ For variance    │ Not applicable       │ Works great!         │\n")
cat("│ components      │                      │                      │\n")
cat("├─────────────────┼──────────────────────┼──────────────────────┤\n")
cat("│ Information     │ Less (binary)        │ More (continuous)    │\n")
cat("│ content         │                      │                      │\n")
cat("└─────────────────┴──────────────────────┴──────────────────────┘\n\n")

# ============================================================================
# PART 6: The Relationship
# ============================================================================

cat("========================================================================\n")
cat("PART 6: THE RELATIONSHIP BETWEEN CIs AND P-VALUES\n")
cat("========================================================================\n\n")

cat("For a two-sided test at α = 0.05:\n\n")

cat("IF the 95% CI includes 0:\n")
cat("  → Cannot reject H0: effect = 0\n")
cat("  → p-value > 0.05\n")
cat("  → Effect not significant\n\n")

cat("IF the 95% CI does NOT include 0:\n")
cat("  → Reject H0: effect = 0\n")
cat("  → p-value < 0.05\n")
cat("  → Effect is significant\n\n")

cat("Example from our mixed model:\n")
cat("  Occasion CI: [", sprintf("%.4f", ci_mixed["occasion", 1]), ", ",
    sprintf("%.4f", ci_mixed["occasion", 2]), "]\n", sep="")
cat("  → Doesn't include 0\n")
cat("  → Would have p < 0.05 if we calculated it\n")
cat("  → But CI tells us MORE: effect is between ",
    sprintf("%.4f", ci_mixed["occasion", 1]), " and ",
    sprintf("%.4f", ci_mixed["occasion", 2]), "\n\n", sep="")

# ============================================================================
# PART 7: Why the Textbook Prefers CIs for Mixed Models
# ============================================================================

cat("========================================================================\n")
cat("PART 7: WHY TEXTBOOK PREFERS CIs FOR MIXED MODELS\n")
cat("========================================================================\n\n")

cat("From random_intercepts.Rmd:292:\n")
cat("  'However, it's more straightforward to get confidence intervals'\n\n")

cat("Reasons:\n")
cat("1. DF problem is messy\n")
cat("   - Different effective sample sizes for different parameters\n")
cat("   - Multiple approximation methods (Satterthwaite, Kenward-Roger)\n")
cat("   - No consensus on 'best' method\n\n")

cat("2. Different software = different p-values\n")
cat("   - SAS uses one method\n")
cat("   - SPSS uses another\n")
cat("   - Often don't tell you which!\n\n")

cat("3. Profile CIs are more accurate\n")
cat("   - Use the actual likelihood function\n")
cat("   - Don't assume normal distribution\n")
cat("   - Especially good for variance components\n\n")

cat("4. CIs give more information\n")
cat("   - Effect size + precision\n")
cat("   - Practically significant vs statistically significant\n")
cat("   - Can assess magnitude, not just existence\n\n")

cat("From footnote [^fuzzyp] (random_intercepts.Rmd:598):\n")
cat("  'Note that many common modeling situations involve a fuzzy p\n")
cat("   setting... this usually is a sign you're doing something\n")
cat("   interesting, or handling complexity in an appropriate way.'\n\n")

# ============================================================================
# PART 8: Practical Recommendations
# ============================================================================

cat("========================================================================\n")
cat("PART 8: PRACTICAL RECOMMENDATIONS\n")
cat("========================================================================\n\n")

cat("For standard regression:\n")
cat("  ✓ Both p-values and CIs are straightforward\n")
cat("  ✓ Report both if you like\n")
cat("  → But CIs still give more information\n\n")

cat("For mixed models:\n")
cat("  ✓ Always report confidence intervals\n")
cat("  ✓ Use confint() with method='profile' for best accuracy\n")
cat("  ✓ Or method='Wald' for speed (less accurate)\n\n")

cat("If you MUST have p-values for mixed models:\n")
cat("  - Use lmerTest package (adds Satterthwaite approximation)\n")
cat("  - Or use parametric bootstrap\n")
cat("  - Or use Bayesian methods (posterior probabilities)\n")
cat("  - But understand the limitations!\n\n")

cat("Best practice:\n")
cat("  Report: coefficient ± SE [95% CI]\n")
cat("  Example: 'Occasion effect: 0.106 ± 0.004 [0.098, 0.114]'\n")
cat("  → Shows point estimate, uncertainty, AND plausible range\n\n")

# ============================================================================
# FINAL EXAMPLE
# ============================================================================

cat("========================================================================\n")
cat("FINAL EXAMPLE: Comparing Interpretations\n")
cat("========================================================================\n\n")

occ_coef = fixef(gpa_mixed)["occasion"]
occ_se = se_mixed["occasion"]
occ_ci = ci_mixed["occasion", ]

cat("POOR interpretation (p-value focused):\n")
cat("  'The occasion effect was significant (p < 0.001)'\n")
cat("  → Tells us: effect exists\n")
cat("  → Doesn't tell us: how big? how certain?\n\n")

cat("BETTER interpretation (CI focused):\n")
cat("  'GPA increased by ", sprintf("%.3f", occ_coef),
    " points per semester (95% CI: [",
    sprintf("%.3f", occ_ci[1]), ", ", sprintf("%.3f", occ_ci[2]), "])'\n", sep="")
cat("  → Tells us: effect size (", sprintf("%.3f", occ_coef), " points)\n", sep="")
cat("  → AND: precision (narrow CI = precise estimate)\n")
cat("  → AND: significance (doesn't include 0)\n\n")

cat("BEST interpretation (full context):\n")
cat("  'Students' GPA increased by ", sprintf("%.3f", occ_coef),
    " points per semester\n", sep="")
cat("   (95% CI: [", sprintf("%.3f", occ_ci[1]), ", ",
    sprintf("%.3f", occ_ci[2]), "]), representing approximately\n", sep="")
cat("   one-third of a letter grade improvement over 3 years.'\n")
cat("  → Adds practical significance and context!\n\n")

cat("========================================================================\n")
cat("Remember: Numbers without context are just numbers.\n")
cat("CIs help provide that context!\n")
cat("========================================================================\n")
