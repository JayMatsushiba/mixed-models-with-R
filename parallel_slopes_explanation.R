# Why Does GPA Increase "Regardless of Sex or Highgpa"?
# Understanding Additive vs Interactive Effects in Mixed Models

library(lme4)
library(ggplot2)
library(dplyr)

load('data/gpa.RData')

cat("========================================================================\n")
cat("WHY DOES GPA INCREASE 'REGARDLESS' OF SEX OR HIGHGPA?\n")
cat("========================================================================\n\n")

cat("This is about understanding what the model ASSUMES vs what it TESTS.\n\n")

# ============================================================================
# PART 1: What the Model Assumes
# ============================================================================

cat("========================================================================\n")
cat("PART 1: WHAT YOUR MODEL ASSUMES\n")
cat("========================================================================\n\n")

cat("Your model:\n")
cat("  gpa ~ occasion + sex + highgpa + (1|student)\n\n")

cat("This is an ADDITIVE model. Let's write it out:\n\n")

cat("Mathematical form:\n")
cat("  GPA_ij = β₀ + β₁×occasion + β₂×sex + β₃×highgpa + u_i + ε_ij\n\n")

cat("For a specific student:\n")
cat("  GPA = (Intercept + sex effect + highgpa effect + student effect)\n")
cat("        + (occasion effect) × time\n\n")

cat("Key point: The OCCASION COEFFICIENT is the SAME for everyone!\n\n")

cat("Example predictions:\n")
cat("  Male with highgpa=3.0:\n")
cat("    Semester 0: β₀ + β₂×0 + β₃×3.0 + u_i\n")
cat("    Semester 1: β₀ + β₂×0 + β₃×3.0 + u_i + β₁×1\n")
cat("    Semester 2: β₀ + β₂×0 + β₃×3.0 + u_i + β₁×2\n")
cat("    → Slope = β₁\n\n")

cat("  Female with highgpa=3.5:\n")
cat("    Semester 0: β₀ + β₂×1 + β₃×3.5 + u_i\n")
cat("    Semester 1: β₀ + β₂×1 + β₃×3.5 + u_i + β₁×1\n")
cat("    Semester 2: β₀ + β₂×1 + β₃×3.5 + u_i + β₁×2\n")
cat("    → Slope = β₁ (SAME!)\n\n")

cat("Different INTERCEPTS (starting points)\n")
cat("Same SLOPES (rate of change)\n\n")

cat("This is called the PARALLEL SLOPES assumption.\n\n")

# ============================================================================
# PART 2: Fit the Models
# ============================================================================

cat("========================================================================\n")
cat("PART 2: ACTUAL MODEL RESULTS\n")
cat("========================================================================\n\n")

# Fit models
gpa_mixed_both <- lmer(gpa ~ occasion + sex + highgpa + (1 | student),
                       data = gpa)

cat("Model: gpa ~ occasion + sex + highgpa + (1|student)\n\n")

# Get fixed effects
fe <- fixef(gpa_mixed_both)

cat("Fixed Effects:\n")
cat("─────────────────────────────────────\n")
cat(sprintf("Intercept:   %7.4f\n", fe[1]))
cat(sprintf("occasion:    %7.4f  ← SAME for everyone\n", fe[2]))
cat(sprintf("sexFemale:   %7.4f\n", fe[3]))
cat(sprintf("highgpa:     %7.4f\n\n", fe[4]))

cat("What this means:\n")
cat("  • Everyone's GPA increases by %.3f per semester\n", fe[2])
cat("  • Males and females: SAME rate of increase (%.3f)\n", fe[2])
cat("  • Low and high achievers: SAME rate of increase (%.3f)\n\n", fe[2])

# ============================================================================
# PART 3: Visual Demonstration
# ============================================================================

cat("========================================================================\n")
cat("PART 3: WHAT 'PARALLEL SLOPES' MEANS\n")
cat("========================================================================\n\n")

cat("Let's create predictions for different students:\n\n")

# Create example students
example_students <- expand.grid(
  occasion = 0:5,
  sex = factor(c("male", "female"), levels = c("male", "female")),
  highgpa = c(3.0, 3.5)
)

# For demonstration, set student random effect to 0 (population average)
example_students$predicted <- predict(gpa_mixed_both,
                                      newdata = example_students,
                                      re.form = NA)

cat("Predictions for 4 'types' of students:\n")
cat("─────────────────────────────────────────────────────────────────\n")

for(s in c("male", "female")) {
  for(h in c(3.0, 3.5)) {
    subset_data <- example_students[example_students$sex == s &
                                    example_students$highgpa == h, ]

    cat(sprintf("\n%s, highgpa=%.1f:\n", s, h))
    cat("  Sem 0: ", sprintf("%.3f", subset_data$predicted[1]), "\n")
    cat("  Sem 1: ", sprintf("%.3f", subset_data$predicted[2]), "\n")
    cat("  Sem 2: ", sprintf("%.3f", subset_data$predicted[3]), "\n")
    cat("  Sem 3: ", sprintf("%.3f", subset_data$predicted[4]), "\n")
    cat("  Sem 4: ", sprintf("%.3f", subset_data$predicted[5]), "\n")
    cat("  Sem 5: ", sprintf("%.3f", subset_data$predicted[6]), "\n")

    slope <- (subset_data$predicted[6] - subset_data$predicted[1]) / 5
    cat("  → Slope: ", sprintf("%.4f", slope), " (all the same!)\n")
  }
}

cat("\n")
cat("Visual representation:\n")
cat("GPA\n")
cat(" │\n")
cat("3.5│     Female, highgpa=3.5  ╱╱╱╱╱╱╱  (highest starting point)\n")
cat("   │                        ╱\n")
cat("3.3│     Female, highgpa=3.0  ╱╱╱╱╱╱  (high starting point)\n")
cat("   │                      ╱\n")
cat("3.1│     Male, highgpa=3.5  ╱╱╱╱╱╱    (mid starting point)\n")
cat("   │                    ╱\n")
cat("2.9│     Male, highgpa=3.0  ╱╱╱╱╱     (lower starting point)\n")
cat("   │                  ╱\n")
cat("2.7│               ╱╱\n")
cat("   └────┴────┴────┴────┴────┴────► Semester\n")
cat("        0    1    2    3    4    5\n\n")

cat("Notice: All lines are PARALLEL (same slope = %.3f)\n", fe[2])
cat("They just start at different heights!\n\n")

# ============================================================================
# PART 4: What 'Regardless' Actually Means
# ============================================================================

cat("========================================================================\n")
cat("PART 4: WHAT 'REGARDLESS' ACTUALLY MEANS\n")
cat("========================================================================\n\n")

cat("When we say 'GPA increases regardless of sex or highgpa', we mean:\n\n")

cat("1. The MODEL ASSUMES the time effect is constant across groups\n")
cat("   • Males: GPA increases by %.3f per semester\n", fe[2])
cat("   • Females: GPA increases by %.3f per semester\n", fe[2])
cat("   • Low achievers: GPA increases by %.3f per semester\n", fe[2])
cat("   • High achievers: GPA increases by %.3f per semester\n\n", fe[2])

cat("2. Sex and highgpa affect WHERE you START (intercept)\n")
cat("   • Females start %.3f points higher than males\n", fe[3])
cat("   • Each point of highgpa adds %.3f to starting GPA\n", fe[4])
cat("   • But everyone improves at the SAME RATE over time\n\n")

cat("3. This is an ASSUMPTION, not necessarily reality!\n")
cat("   • The model forces parallel slopes\n")
cat("   • Reality: males and females might improve at different rates\n")
cat("   • We can TEST this with interactions!\n\n")

# ============================================================================
# PART 5: What If Slopes Were Different?
# ============================================================================

cat("========================================================================\n")
cat("PART 5: WHAT IF SLOPES *WEREN'T* THE SAME? (INTERACTIONS)\n")
cat("========================================================================\n\n")

cat("To test if sex/highgpa affect the RATE of change, add interactions:\n\n")

cat("Model with interaction:\n")
cat("  gpa ~ occasion + sex + highgpa + occasion:sex + (1|student)\n\n")

# Fit interaction model
gpa_interact <- lmer(gpa ~ occasion + sex + highgpa + occasion:sex +
                     (1 | student), data = gpa)

cat("This allows:\n")
cat("  • Males: slope = β₁\n")
cat("  • Females: slope = β₁ + β_interaction\n\n")

fe_int <- fixef(gpa_interact)

cat("Results with interaction:\n")
cat("─────────────────────────────────────\n")
cat(sprintf("occasion (baseline):     %7.4f  (slope for males)\n", fe_int[2]))
cat(sprintf("occasion:sexFemale:      %7.4f  (additional slope for females)\n\n",
            fe_int[5]))

if(abs(fe_int[5]) < 0.01) {
  cat("Interpretation: Interaction ≈ 0\n")
  cat("  → Females and males improve at about the same rate\n")
  cat("  → Parallel slopes assumption is reasonable!\n\n")
} else {
  cat("Interpretation: Interaction ≠ 0\n")
  cat("  → Females and males improve at different rates\n")
  cat("  → Slopes are NOT parallel\n\n")
}

# Test significance of interaction
cat("To formally test if slopes differ:\n")
cat("  Compare models with and without interaction using anova()\n")
cat("  or check if CI for interaction includes zero\n\n")

# ============================================================================
# PART 6: The Confusion Clarified
# ============================================================================

cat("========================================================================\n")
cat("PART 6: CLARIFYING THE CONFUSION\n")
cat("========================================================================\n\n")

cat("INCORRECT interpretation:\n")
cat("  'GPA increases over time, and this is unrelated to sex/highgpa'\n")
cat("  ✗ This sounds like sex/highgpa don't matter at all!\n\n")

cat("CORRECT interpretation:\n")
cat("  'The RATE of GPA increase is the same (%.3f per semester)\n", fe[2])
cat("   for all students, regardless of their sex or high school GPA.\n")
cat("   However, sex and highgpa DO affect starting GPA levels.'\n\n")

cat("More precisely:\n")
cat("  'In this additive model, we assume parallel slopes:\n")
cat("   • occasion effect = %.3f for everyone (same rate of change)\n", fe[2])
cat("   • sex affects baseline level (females start %.3f higher)\n", fe[3])
cat("   • highgpa affects baseline level (%.3f points per HS GPA point)\n", fe[4])
cat("   • These factors shift your starting point up/down,\n")
cat("     but don't change how fast you improve over time.'\n\n")

# ============================================================================
# PART 7: Real Data Check
# ============================================================================

cat("========================================================================\n")
cat("PART 7: CHECKING THE ASSUMPTION WITH REAL DATA\n")
cat("========================================================================\n\n")

cat("Does the parallel slopes assumption hold?\n\n")

# Calculate average GPA change by sex
gpa_by_sex <- gpa %>%
  group_by(sex, occasion) %>%
  summarise(mean_gpa = mean(gpa), .groups = 'drop')

# Simple check: compare slopes
if(nrow(gpa_by_sex) > 0) {
  male_slope <- with(gpa_by_sex[gpa_by_sex$sex == "Male",],
                     (mean_gpa[6] - mean_gpa[1]) / 5)
  female_slope <- with(gpa_by_sex[gpa_by_sex$sex == "Female",],
                       (mean_gpa[6] - mean_gpa[1]) / 5)

  cat("Empirical slopes (just from means, not the model):\n")
  cat(sprintf("  Males:   %.4f increase per semester\n", male_slope))
  cat(sprintf("  Females: %.4f increase per semester\n\n", female_slope))

  if(abs(male_slope - female_slope) < 0.02) {
    cat("→ Very similar! Parallel slopes assumption seems reasonable.\n\n")
  } else {
    cat("→ Somewhat different. Might want to test interaction.\n\n")
  }
}

# ============================================================================
# SUMMARY
# ============================================================================

cat("========================================================================\n")
cat("SUMMARY: WHY 'REGARDLESS'?\n")
cat("========================================================================\n\n")

cat("1. YOUR MODEL STRUCTURE:\n")
cat("   gpa ~ occasion + sex + highgpa + (1|student)\n")
cat("   → Additive effects only (no interactions)\n")
cat("   → Forces parallel slopes\n\n")

cat("2. WHAT THIS MEANS:\n")
cat("   • occasion coefficient (%.3f) is the SAME for everyone\n", fe[2])
cat("   • Sex/highgpa affect LEVEL (where you start)\n")
cat("   • Sex/highgpa don't affect SLOPE (how fast you improve)\n\n")

cat("3. SAYING 'REGARDLESS':\n")
cat("   ✓ CORRECT: 'The rate of increase (%.3f) is the same\n", fe[2])
cat("               regardless of sex or highgpa'\n")
cat("   ✓ CORRECT: 'Everyone improves at %.3f per semester,\n", fe[2])
cat("               irrespective of their sex or high school GPA'\n\n")

cat("   ✗ WRONG: 'Sex and highgpa don't affect GPA'\n")
cat("            (They DO affect starting level!)\n\n")

cat("4. THIS IS AN ASSUMPTION:\n")
cat("   • Your model ASSUMES parallel slopes\n")
cat("   • Test with interactions if you suspect different rates\n")
cat("   • Model: occasion:sex or occasion:highgpa\n\n")

cat("5. KEY DISTINCTION:\n")
cat("   Intercept effects (sex, highgpa): Shift the line UP/DOWN\n")
cat("   Slope effects (occasion): Tilt the line (rate of change)\n")
cat("   Interaction: Let different groups have different slopes\n\n")

cat("========================================================================\n")
