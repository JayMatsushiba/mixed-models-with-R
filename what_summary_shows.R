# What Does summary(gpa_mixed) Actually Show?
# Clarifying what "residual" means in mixed model output

library(lme4)
library(dplyr)

load('data/gpa.RData')

cat("========================================================================\n")
cat("QUESTION: Does summary(gpa_mixed) return residual of fixed effects?\n")
cat("========================================================================\n\n")

cat("SHORT ANSWER: NO!\n\n")

cat("summary(gpa_mixed) shows the residual variance AFTER accounting for\n")
cat("BOTH fixed effects AND random effects.\n\n")

cat("Let me demonstrate exactly what it shows...\n\n")

# ============================================================================
# PART 1: Fit the Model and Look at Summary
# ============================================================================

cat("========================================================================\n")
cat("PART 1: WHAT summary() SHOWS\n")
cat("========================================================================\n\n")

gpa_mixed = lmer(gpa ~ occasion + (1 | student), data = gpa)

cat("Model: gpa ~ occasion + (1|student)\n\n")

cat("Here's the actual summary output:\n")
cat("----------------------------------\n")
print(summary(gpa_mixed))
cat("\n")

# Extract key components
vc = as.data.frame(VarCorr(gpa_mixed))
tau = vc$sdcor[1]
sigma = vc$sdcor[2]
tau_sq = vc$vcov[1]
sigma_sq = vc$vcov[2]

cat("========================================================================\n")
cat("PART 2: BREAKING DOWN THE OUTPUT\n")
cat("========================================================================\n\n")

cat("Random effects section shows:\n")
cat("------------------------------\n")
cat("Groups   Name        Variance Std.Dev.\n")
cat("student  (Intercept) ", sprintf("%.4f", tau_sq), "   ", sprintf("%.4f", tau), "\n", sep="")
cat("Residual             ", sprintf("%.4f", sigma_sq), "   ", sprintf("%.4f", sigma), "\n\n", sep="")

cat("What these mean:\n\n")

cat("1. student (Intercept) variance = τ² = ", sprintf("%.4f", tau_sq), "\n", sep="")
cat("   → Variance of the random effects\n")
cat("   → How much students vary in their intercepts\n")
cat("   → This is EXPLAINED variance (by student identity)\n\n")

cat("2. Residual variance = σ² = ", sprintf("%.4f", sigma_sq), "\n", sep="")
cat("   → Variance AFTER accounting for fixed AND random effects\n")
cat("   → What's left over after the full model\n")
cat("   → This is UNEXPLAINED variance\n\n")

# ============================================================================
# PART 3: What Gets Subtracted from Residuals?
# ============================================================================

cat("========================================================================\n")
cat("PART 3: WHAT THE 'RESIDUAL' HAS ALREADY ACCOUNTED FOR\n")
cat("========================================================================\n\n")

cat("The residual variance σ² = ", sprintf("%.4f", sigma_sq), " is calculated AFTER removing:\n\n", sep="")

cat("1. Fixed effects (occasion):\n")
cat("   ✓ Systematic trend over time (β₁ = ", sprintf("%.4f", fixef(gpa_mixed)[2]), ")\n", sep="")
cat("   ✓ Overall intercept (β₀ = ", sprintf("%.4f", fixef(gpa_mixed)[1]), ")\n\n", sep="")

cat("2. Random effects (student):\n")
cat("   ✓ Student-specific intercepts (τ = ", sprintf("%.4f", tau), ")\n", sep="")
cat("   ✓ Each student's deviation from overall average\n\n")

cat("What's LEFT is σ² = ", sprintf("%.4f", sigma_sq), "\n\n", sep="")

# ============================================================================
# PART 4: Demonstrate with Actual Residuals
# ============================================================================

cat("========================================================================\n")
cat("PART 4: CALCULATING RESIDUALS MANUALLY\n")
cat("========================================================================\n\n")

# Get predictions and residuals
pred_full = predict(gpa_mixed)  # Fixed + random effects
resid_full = residuals(gpa_mixed)  # Actual - predicted

cat("For each observation, the residual is:\n")
cat("  residual = actual - predicted\n")
cat("  where predicted = fixed effects + random effects\n\n")

cat("Example observations:\n")
cat("────────────────────────────────────────────────────────────────────\n")
cat("Student  Occasion  Actual   Predicted  Residual\n")
cat("────────────────────────────────────────────────────────────────────\n")

for(i in 1:10) {
  stud = gpa$student[i]
  occ = gpa$occasion[i]
  actual = gpa$gpa[i]
  pred = pred_full[i]
  res = resid_full[i]

  cat(sprintf("  %3s      %3d     %.4f    %.4f    %7.4f\n",
              stud, occ, actual, pred, res))
}
cat("────────────────────────────────────────────────────────────────────\n\n")

cat("The variance of these residuals is σ² = ", sprintf("%.4f", var(resid_full)), "\n", sep="")
cat("(Should match what summary() shows: σ² = ", sprintf("%.4f", sigma_sq), ")\n\n", sep="")

# ============================================================================
# PART 5: Contrast with "Residuals of Fixed Effects Only"
# ============================================================================

cat("========================================================================\n")
cat("PART 5: WHAT 'RESIDUAL OF FIXED EFFECTS' WOULD BE\n")
cat("========================================================================\n\n")

cat("If we wanted residuals ONLY accounting for fixed effects\n")
cat("(ignoring random effects), we would calculate:\n\n")

# Get predictions with only fixed effects (no random effects)
pred_fixed_only = predict(gpa_mixed, re.form = NA)
resid_fixed_only = gpa$gpa - pred_fixed_only

var_resid_fixed_only = var(resid_fixed_only)

cat("  residual_fixed_only = actual - predicted_fixed\n")
cat("  where predicted_fixed = intercept + β₁ × occasion\n")
cat("                       (NO student random effects)\n\n")

cat("Example observations:\n")
cat("────────────────────────────────────────────────────────────────────\n")
cat("Student  Occasion  Actual   Pred(fixed)  Resid(fixed only)\n")
cat("────────────────────────────────────────────────────────────────────\n")

for(i in 1:10) {
  stud = gpa$student[i]
  occ = gpa$occasion[i]
  actual = gpa$gpa[i]
  pred_fix = pred_fixed_only[i]
  res_fix = resid_fixed_only[i]

  cat(sprintf("  %3s      %3d     %.4f     %.4f       %7.4f\n",
              stud, occ, actual, pred_fix, res_fix))
}
cat("────────────────────────────────────────────────────────────────────\n\n")

cat("Variance of 'residuals after fixed effects only': ", sprintf("%.4f", var_resid_fixed_only), "\n\n", sep="")

cat("Compare the two:\n")
cat("  Residual variance (full model, what summary shows): σ² = ", sprintf("%.4f", sigma_sq), "\n", sep="")
cat("  Residual variance (fixed only, NOT what summary shows): ", sprintf("%.4f", var_resid_fixed_only), "\n\n", sep="")

cat("Notice: Residual after fixed only (", sprintf("%.4f", var_resid_fixed_only),
    ") is LARGER\n", sep="")
cat("because it still contains the random effects variance (τ² = ", sprintf("%.4f", tau_sq), ")\n\n", sep="")

cat("In fact: ", sprintf("%.4f", var_resid_fixed_only), " ≈ τ² + σ² = ",
    sprintf("%.4f", tau_sq), " + ", sprintf("%.4f", sigma_sq), " = ",
    sprintf("%.4f", tau_sq + sigma_sq), "\n\n", sep="")

# ============================================================================
# PART 6: Visual Demonstration
# ============================================================================

cat("========================================================================\n")
cat("PART 6: VISUAL COMPARISON\n")
cat("========================================================================\n\n")

cat("Let's look at Student 1 across all 6 semesters:\n\n")

stud1_data = gpa %>% filter(student == "1")
stud1_actual = stud1_data$gpa
stud1_pred_full = predict(gpa_mixed, newdata = stud1_data)
stud1_pred_fixed = predict(gpa_mixed, newdata = stud1_data, re.form = NA)
stud1_resid_full = stud1_actual - stud1_pred_full
stud1_resid_fixed = stud1_actual - stud1_pred_fixed

cat("Semester  Actual   Pred(full)  Resid(full)  Pred(fixed)  Resid(fixed)\n")
cat("──────────────────────────────────────────────────────────────────────\n")
for(i in 1:6) {
  cat(sprintf("   %d      %.3f      %.3f       %6.3f       %.3f        %6.3f\n",
              i-1, stud1_actual[i], stud1_pred_full[i], stud1_resid_full[i],
              stud1_pred_fixed[i], stud1_resid_fixed[i]))
}
cat("──────────────────────────────────────────────────────────────────────\n\n")

cat("SD of Resid(full):  ", sprintf("%.4f", sd(stud1_resid_full)), " ← This contributes to σ\n", sep="")
cat("SD of Resid(fixed): ", sprintf("%.4f", sd(stud1_resid_fixed)), " ← Larger! Includes student effect\n\n", sep="")

cat("The difference:\n")
cat("  Resid(fixed) = Resid(full) + Student 1's random effect\n")
cat("  Resid(fixed) = Resid(full) + ", sprintf("%.4f", ranef(gpa_mixed)$student["1", 1]), "\n\n", sep="")

# ============================================================================
# PART 7: The Mathematical Relationship
# ============================================================================

cat("========================================================================\n")
cat("PART 7: THE MATHEMATICAL RELATIONSHIP\n")
cat("========================================================================\n\n")

cat("For observation i from student j:\n\n")

cat("Full model:\n")
cat("  y_ij = (β₀ + u_j) + β₁ × occasion_ij + ε_ij\n")
cat("       = fixed effects + random effect + residual\n\n")

cat("Residual from full model:\n")
cat("  ε_ij = y_ij - [(β₀ + u_j) + β₁ × occasion_ij]\n")
cat("       = actual - [fixed + random]\n")
cat("  Var(ε_ij) = σ² = ", sprintf("%.4f", sigma_sq), " ← What summary() shows!\n\n", sep="")

cat("Residual from fixed effects only:\n")
cat("  r_ij = y_ij - [β₀ + β₁ × occasion_ij]\n")
cat("       = actual - [fixed only]\n")
cat("       = (β₀ + u_j) + β₁ × occasion_ij + ε_ij - [β₀ + β₁ × occasion_ij]\n")
cat("       = u_j + ε_ij\n")
cat("  Var(r_ij) = Var(u_j) + Var(ε_ij) = τ² + σ²\n")
cat("            = ", sprintf("%.4f", tau_sq), " + ", sprintf("%.4f", sigma_sq),
    " = ", sprintf("%.4f", tau_sq + sigma_sq), " ← NOT what summary() shows!\n\n", sep="")

# ============================================================================
# PART 8: Why This Matters
# ============================================================================

cat("========================================================================\n")
cat("PART 8: WHY THIS DISTINCTION MATTERS\n")
cat("========================================================================\n\n")

cat("1. INTERPRETING σ² in summary():\n")
cat("   → It's the residual AFTER accounting for EVERYTHING\n")
cat("   → Both fixed effects (occasion) AND random effects (student)\n")
cat("   → This is the true 'unexplained' variance\n\n")

cat("2. COMPARING MODELS:\n")
cat("   → When you add predictors, watch σ² decrease\n")
cat("   → σ² decreasing = model explaining more\n\n")

# Demonstrate with another model
gpa_mixed2 = lmer(gpa ~ occasion + sex + (1 | student), data = gpa)
vc2 = as.data.frame(VarCorr(gpa_mixed2))
sigma_sq2 = vc2$vcov[2]

cat("   Example:\n")
cat("   Model 1: gpa ~ occasion + (1|student)\n")
cat("            σ² = ", sprintf("%.4f", sigma_sq), "\n\n", sep="")
cat("   Model 2: gpa ~ occasion + sex + (1|student)\n")
cat("            σ² = ", sprintf("%.4f", sigma_sq2), "\n\n", sep="")

if(sigma_sq2 < sigma_sq) {
  cat("   σ² decreased → sex helps explain variance!\n\n")
} else {
  cat("   σ² didn't decrease much → sex doesn't help much\n\n")
}

cat("3. MODEL FIT:\n")
cat("   → Lower σ² = better fit\n")
cat("   → σ² = ", sprintf("%.4f", sigma_sq), " is what's LEFT unexplained\n\n", sep="")

cat("4. RESIDUAL DIAGNOSTICS:\n")
cat("   → residuals(gpa_mixed) are what you plot for diagnostics\n")
cat("   → These should be ~N(0, σ²)\n")
cat("   → They already account for random effects!\n\n")

# ============================================================================
# PART 9: Common Misunderstanding
# ============================================================================

cat("========================================================================\n")
cat("PART 9: COMMON MISUNDERSTANDING\n")
cat("========================================================================\n\n")

cat("WRONG interpretation:\n")
cat("  'σ² in summary() is the residual variance after fixed effects,\n")
cat("   not accounting for random effects yet.'\n")
cat("  ✗ This is INCORRECT!\n\n")

cat("CORRECT interpretation:\n")
cat("  'σ² in summary() is the residual variance after BOTH\n")
cat("   fixed effects AND random effects have been accounted for.'\n")
cat("  ✓ This is CORRECT!\n\n")

cat("To get residuals after fixed effects only (not what summary shows):\n")
cat("  resid_fixed_only = gpa$gpa - predict(gpa_mixed, re.form = NA)\n")
cat("  Var(resid_fixed_only) = ", sprintf("%.4f", var_resid_fixed_only), "\n", sep="")
cat("                        = τ² + σ² (approximately)\n\n")

# ============================================================================
# SUMMARY
# ============================================================================

cat("========================================================================\n")
cat("SUMMARY: WHAT summary(gpa_mixed) SHOWS\n")
cat("========================================================================\n\n")

cat("The 'Residual' line in summary() random effects:\n\n")

cat("  Residual  Variance = ", sprintf("%.4f", sigma_sq), "  Std.Dev. = ", sprintf("%.4f", sigma), "\n\n", sep="")

cat("This is:\n")
cat("  ✓ Variance AFTER fixed effects (occasion)\n")
cat("  ✓ Variance AFTER random effects (student)\n")
cat("  ✓ What's LEFT unexplained by the full model\n")
cat("  ✓ Var(actual - predicted_full)\n\n")

cat("This is NOT:\n")
cat("  ✗ Variance after fixed effects only\n")
cat("  ✗ Variance of random effects\n")
cat("  ✗ Variance explained by the model\n\n")

cat("Key equation:\n")
cat("  Residual for observation i from student j:\n")
cat("    ε_ij = y_ij - [(β₀ + u_j) + β₁ × x_ij]\n")
cat("                   └─────┬─────┘   └──┬──┘\n")
cat("                    random      fixed\n")
cat("                    effect      effect\n\n")

cat("  Var(ε_ij) = σ² = ", sprintf("%.4f", sigma_sq), " ← This is what summary() shows!\n\n", sep="")

cat("========================================================================\n")
cat("BOTTOM LINE: summary() shows residual variance AFTER accounting for\n")
cat("             BOTH fixed AND random effects, not just fixed effects!\n")
cat("========================================================================\n")
