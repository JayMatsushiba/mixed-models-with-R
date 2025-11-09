# IMPORTANT CLARIFICATION: Residual Variance vs Fixed Effects Variance
# Correcting a common misconception

library(lme4)
library(dplyr)

load('data/gpa.RData')

cat("========================================================================\n")
cat("MISCONCEPTION: Is Residual Variance = Variance from Fixed Effects?\n")
cat("========================================================================\n\n")

cat("SHORT ANSWER: NO!\n\n")

cat("Residual variance (σ²) is the UNEXPLAINED variance,\n")
cat("not the variance EXPLAINED by fixed effects.\n\n")

cat("Let me show you the correct breakdown...\n\n")

# ============================================================================
# PART 1: The Correct Variance Decomposition
# ============================================================================

cat("========================================================================\n")
cat("PART 1: THE CORRECT VARIANCE DECOMPOSITION\n")
cat("========================================================================\n\n")

cat("Total Variance in Outcome = Explained + Unexplained\n\n")

cat("EXPLAINED Variance:\n")
cat("  - Variance captured by FIXED effects (occasion)\n")
cat("  - Variance captured by RANDOM effects (student)\n\n")

cat("UNEXPLAINED Variance:\n")
cat("  - Residual variance (σ²)\n")
cat("  - What's LEFT OVER after accounting for everything in the model\n\n")

# ============================================================================
# PART 2: Demonstration with GPA Data
# ============================================================================

cat("========================================================================\n")
cat("PART 2: DEMONSTRATION WITH ACTUAL DATA\n")
cat("========================================================================\n\n")

# Calculate total variance in raw GPA
total_var_gpa = var(gpa$gpa)

cat("Starting point: Total variance in GPA\n")
cat("  Var(GPA) = ", sprintf("%.4f", total_var_gpa), "\n\n", sep="")

# Fit models
gpa_mixed = lmer(gpa ~ occasion + (1 | student), data = gpa)
vc = as.data.frame(VarCorr(gpa_mixed))

tau_sq = vc$vcov[1]    # Between-student variance
sigma_sq = vc$vcov[2]  # Within-student (residual) variance

cat("Mixed Model: gpa ~ occasion + (1|student)\n")
cat("-------------------------------------------\n")
cat("Random Effects (Variance Components):\n")
cat("  Between-student variance (τ²): ", sprintf("%.4f", tau_sq), "\n", sep="")
cat("  Residual variance (σ²):        ", sprintf("%.4f", sigma_sq), "\n", sep="")
cat("  Sum (τ² + σ²):                 ", sprintf("%.4f", tau_sq + sigma_sq), "\n\n", sep="")

cat("Fixed Effects:\n")
cat("  Intercept: ", sprintf("%.4f", fixef(gpa_mixed)[1]), "\n", sep="")
cat("  Occasion:  ", sprintf("%.4f", fixef(gpa_mixed)[2]), "\n\n", sep="")

# ============================================================================
# PART 3: What Each Component Represents
# ============================================================================

cat("========================================================================\n")
cat("PART 3: WHAT EACH VARIANCE COMPONENT ACTUALLY MEANS\n")
cat("========================================================================\n\n")

cat("τ² (Between-student variance) = ", sprintf("%.4f", tau_sq), "\n", sep="")
cat("└─> Variance EXPLAINED by knowing which student it is\n")
cat("    (Random effects capture this)\n\n")

cat("σ² (Residual variance) = ", sprintf("%.4f", sigma_sq), "\n", sep="")
cat("└─> Variance LEFT OVER after accounting for:\n")
cat("    • Fixed effects (occasion)\n")
cat("    • Random effects (student)\n")
cat("    This is UNEXPLAINED variance!\n\n")

cat("Fixed effects variance = ???\n")
cat("└─> Variance EXPLAINED by the occasion predictor\n")
cat("    This is NOT directly shown in variance components!\n")
cat("    (But we can calculate it...)\n\n")

# ============================================================================
# PART 4: Calculating Variance Explained by Fixed Effects
# ============================================================================

cat("========================================================================\n")
cat("PART 4: CALCULATING VARIANCE EXPLAINED BY FIXED EFFECTS\n")
cat("========================================================================\n\n")

cat("To find variance explained by occasion, we need to look at\n")
cat("how much the PREDICTIONS vary due to occasion.\n\n")

# Get fitted values (predictions)
fitted_vals = fitted(gpa_mixed)

# For fixed effects only (no random effects)
fitted_fixed = predict(gpa_mixed, re.form = NA)

# Calculate variance of fitted values from fixed effects only
var_fixed = var(fitted_fixed)

cat("Variance of predictions from FIXED effects only:\n")
cat("  (i.e., variation due to occasion)\n")
cat("  Var(fitted values, no RE) = ", sprintf("%.4f", var_fixed), "\n\n", sep="")

# Get predictions with random effects
var_with_re = var(fitted_vals)

cat("Variance of predictions from FIXED + RANDOM effects:\n")
cat("  (i.e., variation due to occasion AND student)\n")
cat("  Var(fitted values, with RE) = ", sprintf("%.4f", var_with_re), "\n\n", sep="")

# ============================================================================
# PART 5: The Complete Variance Breakdown
# ============================================================================

cat("========================================================================\n")
cat("PART 5: COMPLETE VARIANCE BREAKDOWN\n")
cat("========================================================================\n\n")

cat("Total observed variance in GPA: ", sprintf("%.4f", total_var_gpa), "\n\n", sep="")

cat("This breaks down as:\n\n")

cat("1. Variance EXPLAINED by fixed effects (occasion):\n")
cat("   ", sprintf("%.4f", var_fixed), " (", sprintf("%.1f%%", 100*var_fixed/total_var_gpa), ")\n\n", sep="")

cat("2. Variance EXPLAINED by random effects (student):\n")
cat("   ", sprintf("%.4f", tau_sq), " (", sprintf("%.1f%%", 100*tau_sq/total_var_gpa), ")\n\n", sep="")

cat("3. RESIDUAL variance (unexplained):\n")
cat("   ", sprintf("%.4f", sigma_sq), " (", sprintf("%.1f%%", 100*sigma_sq/total_var_gpa), ")\n\n", sep="")

total_explained = var_fixed + tau_sq
cat("Total EXPLAINED: ", sprintf("%.4f", total_explained), " (",
    sprintf("%.1f%%", 100*total_explained/total_var_gpa), ")\n", sep="")
cat("Total UNEXPLAINED: ", sprintf("%.4f", sigma_sq), " (",
    sprintf("%.1f%%", 100*sigma_sq/total_var_gpa), ")\n\n", sep="")

# ============================================================================
# PART 6: Why the Confusion?
# ============================================================================

cat("========================================================================\n")
cat("PART 6: WHY THE CONFUSION HAPPENS\n")
cat("========================================================================\n\n")

cat("The confusion comes from the fact that variance components\n")
cat("(τ² and σ²) are shown prominently in mixed model output,\n")
cat("but they have a SPECIFIC meaning:\n\n")

cat("τ² = Variance of the RANDOM effects distribution\n")
cat("   = How much groups vary in their intercepts/slopes\n")
cat("   = This IS explained variance (by group membership)\n\n")

cat("σ² = Variance of the RESIDUALS\n")
cat("   = What's left after accounting for ALL model components\n")
cat("   = This is UNEXPLAINED variance\n\n")

cat("NEITHER of these directly tells you about fixed effects!\n\n")

cat("Fixed effects explain variance through the systematic relationship\n")
cat("between predictors and outcome (the β coefficients).\n\n")

# ============================================================================
# PART 7: Comparison with Standard Regression
# ============================================================================

cat("========================================================================\n")
cat("PART 7: COMPARISON WITH STANDARD REGRESSION\n")
cat("========================================================================\n\n")

gpa_lm = lm(gpa ~ occasion, data = gpa)
sigma_sq_lm = sigma(gpa_lm)^2

# R-squared
rsq = summary(gpa_lm)$r.squared
var_explained_lm = rsq * total_var_gpa
var_unexplained_lm = (1-rsq) * total_var_gpa

cat("Standard Regression: gpa ~ occasion\n")
cat("------------------------------------\n")
cat("R² = ", sprintf("%.4f", rsq), "\n\n", sep="")

cat("Variance EXPLAINED by occasion:   ", sprintf("%.4f", var_explained_lm),
    " (", sprintf("%.1f%%", 100*rsq), ")\n", sep="")
cat("Variance UNEXPLAINED (residual):  ", sprintf("%.4f", var_unexplained_lm),
    " (", sprintf("%.1f%%", 100*(1-rsq)), ")\n\n", sep="")

cat("Residual variance σ² = ", sprintf("%.4f", sigma_sq_lm), "\n\n", sep="")

cat("Notice: In standard regression, σ² is the UNEXPLAINED variance!\n")
cat("Same is true in mixed models.\n\n")

# ============================================================================
# PART 8: The Correct Interpretation
# ============================================================================

cat("========================================================================\n")
cat("PART 8: THE CORRECT INTERPRETATION OF σ² (RESIDUAL VARIANCE)\n")
cat("========================================================================\n\n")

cat("σ² = ", sprintf("%.4f", sigma_sq), " represents:\n\n", sep="")

cat("✓ Variance NOT explained by fixed effects (occasion)\n")
cat("✓ Variance NOT explained by random effects (student)\n")
cat("✓ The 'error' or 'noise' in the model\n")
cat("✓ Includes:\n")
cat("    • Measurement error\n")
cat("    • Omitted variables\n")
cat("    • Random fluctuation\n")
cat("    • Model misspecification\n\n")

cat("✗ It is NOT the variance due to fixed effects\n")
cat("✗ It is NOT the variance explained by the model\n\n")

# ============================================================================
# PART 9: How to Think About It
# ============================================================================

cat("========================================================================\n")
cat("PART 9: THE RIGHT MENTAL MODEL\n")
cat("========================================================================\n\n")

cat("Think of variance decomposition like this:\n\n")

cat("TOTAL VARIANCE in GPA = ", sprintf("%.4f", total_var_gpa), "\n", sep="")
cat("          |\n")
cat("    ┌─────┴─────┐\n")
cat("    |           |\n")
cat("EXPLAINED   UNEXPLAINED\n")
cat("    |           |\n")
cat("    |         σ² = ", sprintf("%.4f", sigma_sq), " (",
    sprintf("%.0f%%", 100*sigma_sq/total_var_gpa), ")\n", sep="")
cat("    |\n")
cat("  ┌─┴─┐\n")
cat("  |   |\n")
cat("Fixed Random\n")
cat("  |   |\n")
cat("Occasion  Student\n")
cat("  |       |\n")
cat(sprintf("%.4f", var_fixed), "  τ² = ", sprintf("%.4f", tau_sq), "\n", sep="")
cat("(", sprintf("%.0f%%", 100*var_fixed/total_var_gpa), ")  (",
    sprintf("%.0f%%", 100*tau_sq/total_var_gpa), ")\n\n", sep="")

# ============================================================================
# PART 10: Why This Matters
# ============================================================================

cat("========================================================================\n")
cat("PART 10: WHY THIS DISTINCTION MATTERS\n")
cat("========================================================================\n\n")

cat("1. INTERPRETING MODEL FIT:\n")
cat("   - Low σ² = good fit (little unexplained variance)\n")
cat("   - High σ² = poor fit (lots unexplained)\n")
cat("   - σ² is what you want to MINIMIZE\n\n")

cat("2. ADDING PREDICTORS:\n")
cat("   - Adding useful fixed effects → σ² goes DOWN\n")
cat("   - σ² going down = explaining more variance\n\n")

cat("3. R² ANALOGS:\n")
cat("   - In standard regression: R² = 1 - (σ²/total variance)\n")
cat("   - In mixed models: More complicated, but same idea\n")
cat("   - σ² is in the DENOMINATOR (what's unexplained)\n\n")

cat("4. MODEL COMPARISON:\n")
cat("   - Compare models by how much σ² they reduce\n")
cat("   - Lower σ² = better fitting model\n\n")

# ============================================================================
# PART 11: Example to Drive It Home
# ============================================================================

cat("========================================================================\n")
cat("PART 11: CONCRETE EXAMPLE\n")
cat("========================================================================\n\n")

cat("Let's look at one specific observation:\n\n")

# Pick student 1, occasion 0
obs_idx = which(gpa$student == "1" & gpa$occasion == 0)[1]
actual_gpa = gpa$gpa[obs_idx]
pred_overall = fixef(gpa_mixed)[1]  # Just intercept
pred_fixed = predict(gpa_mixed, re.form=NA)[obs_idx]  # Fixed effects
pred_full = predict(gpa_mixed)[obs_idx]  # Fixed + Random
residual = actual_gpa - pred_full

cat("Student 1, Semester 0:\n")
cat("  Actual GPA:                    ", sprintf("%.4f", actual_gpa), "\n\n", sep="")

cat("  Population average intercept:  ", sprintf("%.4f", pred_overall), "\n", sep="")
cat("  └─> If we knew nothing\n\n")

cat("  Prediction (fixed effects):    ", sprintf("%.4f", pred_fixed), "\n", sep="")
cat("  └─> Using occasion = 0\n")
cat("      (same as intercept in this case)\n\n")

cat("  Prediction (fixed + random):   ", sprintf("%.4f", pred_full), "\n", sep="")
cat("  └─> Using occasion = 0 AND student 1's effect\n\n")

cat("  Residual (actual - predicted): ", sprintf("%.4f", residual), "\n", sep="")
cat("  └─> This is the σ component!\n")
cat("      What's LEFT OVER after model\n\n")

cat("Breakdown of the prediction:\n")
cat("  ", sprintf("%.4f", actual_gpa), " (actual)\n", sep="")
cat("  = ", sprintf("%.4f", pred_fixed), " (fixed effects: intercept + 0×occasion)\n", sep="")
cat("  + ", sprintf("%.4f", pred_full - pred_fixed), " (random effect for student 1)\n", sep="")
cat("  + ", sprintf("%.4f", residual), " (residual: unexplained)\n\n", sep="")

cat("The residual ", sprintf("%.4f", residual), " is drawn from N(0, σ² = ",
    sprintf("%.4f", sigma_sq), ")\n", sep="")
cat("This is the UNEXPLAINED part, NOT the fixed effects part!\n\n")

# ============================================================================
# SUMMARY
# ============================================================================

cat("========================================================================\n")
cat("SUMMARY: CRITICAL POINTS\n")
cat("========================================================================\n\n")

cat("1. σ² (residual variance) = UNEXPLAINED variance\n")
cat("   NOT variance from fixed effects!\n\n")

cat("2. Fixed effects EXPLAIN variance through their coefficients\n")
cat("   Var(fitted values from fixed effects) = ", sprintf("%.4f", var_fixed), "\n\n", sep="")

cat("3. Random effects EXPLAIN variance through group differences\n")
cat("   τ² = ", sprintf("%.4f", tau_sq), "\n\n", sep="")

cat("4. Residual variance is what's LEFT:\n")
cat("   σ² = ", sprintf("%.4f", sigma_sq), " (",
    sprintf("%.0f%%", 100*sigma_sq/total_var_gpa), " of total)\n\n", sep="")

cat("5. Total variance breakdown:\n")
cat("   Total = Var(fixed) + Var(random) + Var(residual)\n")
cat("         = ", sprintf("%.4f", var_fixed), " + ", sprintf("%.4f", tau_sq),
    " + ", sprintf("%.4f", sigma_sq), "\n", sep="")
cat("         = ", sprintf("%.4f", var_fixed + tau_sq + sigma_sq), " ≈ ",
    sprintf("%.4f", total_var_gpa), "\n\n", sep="")

cat("6. As you add predictors:\n")
cat("   • Fixed effects explain more → Var(fixed) ↑\n")
cat("   • Less left unexplained → σ² ↓\n\n")

cat("========================================================================\n")
cat("REMEMBER: Residual = what's LEFT, not what's EXPLAINED by fixed effects!\n")
cat("========================================================================\n")
