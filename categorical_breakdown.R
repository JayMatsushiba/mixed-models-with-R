################################################################################
# BREAKING DOWN THE CATEGORICAL FEATURE STATEMENT
################################################################################

library(lme4)

cat("====================================================================\n")
cat("PART 1: Categorical Feature as FIXED EFFECT\n")
cat("====================================================================\n\n")

cat("Statement: 'As a fixed effect, a categorical feature would have k-1\n")
cat("            coefficients with default dummy coding'\n\n")

cat("Example: SES has 3 levels (k=3): low, mid, high\n\n")

cat("Model: achievement ~ ses\n\n")

cat("What R creates (dummy coding):\n")
cat("  Reference group: low (k-1 means we pick one as reference)\n")
cat("  \n")
cat("  Dummy variable 1: sesmid  (1 if mid, 0 otherwise)\n")
cat("  Dummy variable 2: seshigh (1 if high, 0 otherwise)\n")
cat("  \n")
cat("  Total coefficients: 1 intercept + 2 dummy variables = 3 parameters\n\n")

cat("Interpretation:\n")
cat("  Intercept = 50    → Mean for LOW SES (reference group)\n")
cat("  sesmid = +5       → Mid SES scores 5 points HIGHER than low\n")
cat("  seshigh = +10     → High SES scores 10 points HIGHER than low\n\n")

cat("Predictions:\n")
cat("  Low SES:  50 + 0*sesmid + 0*seshigh = 50\n")
cat("  Mid SES:  50 + 1*5 + 0*10 = 55\n")
cat("  High SES: 50 + 0*5 + 1*10 = 60\n\n")

cat("Key point: k-1 coefficients because we use one level as reference!\n\n")

cat("====================================================================\n")
cat("PART 2: Making This RANDOM (Varying by Groups)\n")
cat("====================================================================\n\n")

cat("Statement: 'If we allow that effect to be random, then we would have\n")
cat("            separate k-1 slopes to vary by our structured levels'\n\n")

cat("Model: achievement ~ ses + (1 + ses | school)\n\n")

cat("What this creates PER SCHOOL:\n")
cat("  1. Random INTERCEPT (for the reference group = low SES)\n")
cat("  2. Random SLOPE for sesmid (how much mid-low gap varies)\n")
cat("  3. Random SLOPE for seshigh (how much high-low gap varies)\n")
cat("  \n")
cat("  Total: 3 random effects per school\n\n")

cat("Example for School 1:\n")
cat("─────────────────────────────────────────────────────────────\n")
cat("  FIXED EFFECTS (population average):\n")
cat("    Intercept:  50\n")
cat("    sesmid:     +5\n")
cat("    seshigh:    +10\n\n")

cat("  RANDOM EFFECTS for School 1 (deviations from population):\n")
cat("    Random intercept:     +3  (low SES students 3 points higher)\n")
cat("    Random slope sesmid:  -2  (mid-low gap 2 points smaller)\n")
cat("    Random slope seshigh: +5  (high-low gap 5 points bigger)\n\n")

cat("  SCHOOL 1 PREDICTIONS:\n")
cat("    Low:  (50 + 3) = 53\n")
cat("    Mid:  (50 + 3) + (5 - 2) = 56\n")
cat("    High: (50 + 3) + (10 + 5) = 68\n\n")

cat("Example for School 2:\n")
cat("─────────────────────────────────────────────────────────────\n")
cat("  RANDOM EFFECTS for School 2:\n")
cat("    Random intercept:     -5  (low SES students 5 points lower)\n")
cat("    Random slope sesmid:  +3  (mid-low gap 3 points bigger)\n")
cat("    Random slope seshigh: +2  (high-low gap 2 points bigger)\n\n")

cat("  SCHOOL 2 PREDICTIONS:\n")
cat("    Low:  (50 - 5) = 45\n")
cat("    Mid:  (50 - 5) + (5 + 3) = 53\n")
cat("    High: (50 - 5) + (10 + 2) = 57\n\n")

cat("====================================================================\n")
cat("PART 3: 'Multiple Random Coefficients, Along with Their Correlation'\n")
cat("====================================================================\n\n")

cat("Statement: 'resulting in multiple random coefficients, along with\n")
cat("            their correlation'\n\n")

cat("For k=3 categories (low/mid/high), we estimate:\n\n")

cat("VARIANCE COMPONENTS:\n")
cat("  1. Variance of random intercepts       (τ²_intercept)\n")
cat("  2. Variance of random slopes (sesmid)  (τ²_sesmid)\n")
cat("  3. Variance of random slopes (seshigh) (τ²_seshigh)\n\n")

cat("CORRELATIONS (how they relate to each other):\n")
cat("  4. Correlation(intercept, sesmid)\n")
cat("  5. Correlation(intercept, seshigh)\n")
cat("  6. Correlation(sesmid, seshigh)\n\n")

cat("Total parameters: 3 variances + 3 correlations = 6 parameters!\n\n")

cat("Example correlations:\n")
cat("  Cor(intercept, sesmid) = -0.4\n")
cat("    → Schools with higher baseline (intercept) have SMALLER mid-low gaps\n")
cat("    → High-performing schools reduce SES inequality\n\n")

cat("  Cor(sesmid, seshigh) = 0.8\n")
cat("    → Schools with big mid-low gaps also have big high-low gaps\n")
cat("    → SES effects are consistent across levels\n\n")

cat("====================================================================\n")
cat("PUTTING IT ALL TOGETHER\n")
cat("====================================================================\n\n")

cat("The full statement means:\n\n")

cat("1. FIXED EFFECT PART:\n")
cat("   Categorical variable with k categories → k-1 coefficients\n")
cat("   (one level is reference, others compared to it)\n\n")

cat("2. RANDOM EFFECT PART:\n")
cat("   Allow those k-1 coefficients to vary by groups\n")
cat("   → k-1 random slopes (plus random intercept)\n\n")

cat("3. COMPLEXITY:\n")
cat("   Multiple random effects → must estimate their correlations\n")
cat("   k categories → (k-1) + 1 = k random effects per group\n")
cat("   k random effects → k*(k-1)/2 correlations\n\n")

cat("Example complexity:\n")
cat("  2 categories: 2 random effects, 1 correlation\n")
cat("  3 categories: 3 random effects, 3 correlations\n")
cat("  4 categories: 4 random effects, 6 correlations\n")
cat("  5 categories: 5 random effects, 10 correlations (!)\n\n")

cat("This is why categorical random effects can cause convergence issues!\n")

