################################################################################
# CATEGORICAL FEATURES AS RANDOM EFFECTS
################################################################################

# The Challenge: What happens when you want a CATEGORICAL variable to vary by groups?

cat("====================================================================\n")
cat("THE PROBLEM: CATEGORICAL VARIABLES AS RANDOM SLOPES\n")
cat("====================================================================\n\n")

cat("Scenario: Student achievement varies by school AND socioeconomic status (SES)\n")
cat("  • Schools differ in their baseline achievement (random intercept)\n")
cat("  • But ALSO: The SES effect might differ by school!\n")
cat("    - Some schools reduce SES gaps, others don't\n\n")

cat("Question: How do we model this when SES is CATEGORICAL (low/mid/high)?\n\n")

cat("====================================================================\n")
cat("BACKGROUND: HOW CATEGORICAL VARIABLES WORK AS FIXED EFFECTS\n")
cat("====================================================================\n\n")

cat("If SES has 3 levels (low, mid, high), as a FIXED effect:\n\n")

cat("Model: achievement ~ ses\n\n")

cat("This creates:\n")
cat("  • Intercept = mean achievement for reference group (e.g., 'low')\n")
cat("  • sesmid = difference between mid and low\n")
cat("  • seshigh = difference between high and low\n")
cat("  → Total: 3 parameters (1 intercept + 2 slopes)\n\n")

cat("Example values:\n")
cat("  Intercept: 50 (low SES students score 50)\n")
cat("  sesmid:    +5 (mid SES students score 55)\n")
cat("  seshigh:  +12 (high SES students score 62)\n\n")

cat("====================================================================\n")
cat("THE CHALLENGE: MAKING THIS VARY BY SCHOOL\n")
cat("====================================================================\n\n")

cat("If we want the SES effect to VARY BY SCHOOL, we need:\n")
cat("  • Each school has its own intercept (baseline for low SES)\n")
cat("  • Each school has its own sesmid effect\n")
cat("  • Each school has its own seshigh effect\n\n")

cat("Problem: This creates MANY random effects per school:\n")
cat("  • 1 random intercept\n")
cat("  • 1 random slope for sesmid\n")
cat("  • 1 random slope for seshigh\n")
cat("  • PLUS correlations among all three!\n")
cat("  → Can lead to convergence problems\n\n")

cat("====================================================================\n")
cat("THREE WAYS TO MODEL THIS\n")
cat("====================================================================\n\n")

cat("MODEL 1: The 'obvious' way (random slopes for k-1 categories)\n")
cat("─────────────────────────────────────────────────────────────────\n")
cat("Formula: achievement ~ ses + (1 + ses | school)\n\n")

cat("What this means:\n")
cat("  Fixed effects:\n")
cat("    • Intercept (population average for low SES)\n")
cat("    • sesmid (population average difference: mid vs low)\n")
cat("    • seshigh (population average difference: high vs low)\n\n")

cat("  Random effects (per school):\n")
cat("    • Random intercept (school's deviation for low SES)\n")
cat("    • Random slope for sesmid (school's deviation in mid-low gap)\n")
cat("    • Random slope for seshigh (school's deviation in high-low gap)\n")
cat("    • Correlations among all three\n\n")

cat("  Total random effects: 3 per school + 3 correlations = 6 variance parameters\n\n")

cat("Example for School 1:\n")
cat("  Population: Low=50, Mid=55, High=62\n")
cat("  School 1 random effects: Intercept=+2, sesmid=-1, seshigh=+3\n")
cat("  School 1 predictions: Low=52, Mid=56, High=67\n\n")

cat("\n")
cat("MODEL 2: Intercept form (equivalent but different parameterization)\n")
cat("─────────────────────────────────────────────────────────────────\n")
cat("Formula: achievement ~ ses + (0 + ses | school)\n\n")

cat("What '0 +' means: Remove the overall intercept from random effects,\n")
cat("                  estimate separate 'intercept' for EACH SES level\n\n")

cat("What this means:\n")
cat("  Random effects (per school):\n")
cat("    • Random 'intercept' for low SES students\n")
cat("    • Random 'intercept' for mid SES students\n")
cat("    • Random 'intercept' for high SES students\n")
cat("    • Correlations among all three\n\n")

cat("  Same model as Model 1, just different way of writing it!\n")
cat("  Benefit: All random effects on same scale (achievement units)\n\n")

cat("Example for School 1:\n")
cat("  Population: Low=50, Mid=55, High=62\n")
cat("  School 1 random effects: Low=+2, Mid=+1, High=+5\n")
cat("  School 1 predictions: Low=52, Mid=56, High=67\n")
cat("  (Same predictions as Model 1!)\n\n")

cat("\n")
cat("MODEL 3: Interaction approach (simpler, often more stable)\n")
cat("─────────────────────────────────────────────────────────────────\n")
cat("Formula: achievement ~ ses + (1 | school) + (1 | school:ses)\n\n")

cat("What 'school:ses' means: Create a random effect for each school×SES combination\n\n")

cat("What this means:\n")
cat("  Random effects:\n")
cat("    • (1 | school): Overall school effect\n")
cat("    • (1 | school:ses): Additional effect for each school×SES combo\n")
cat("    • NO correlations estimated (simplifies model)\n\n")

cat("  Example random effects:\n")
cat("    • School 1 (overall effect)\n")
cat("    • School 1:low (additional effect for low SES in School 1)\n")
cat("    • School 1:mid (additional effect for mid SES in School 1)\n")
cat("    • School 1:high (additional effect for high SES in School 1)\n\n")

cat("  Benefits:\n")
cat("    • Often converges when Model 1/2 fail\n")
cat("    • Simpler variance structure (no correlations)\n")
cat("    • Conceptually clear (interaction effect)\n\n")

cat("  Drawback:\n")
cat("    • Doesn't estimate correlations (may fit slightly worse)\n\n")

cat("====================================================================\n")
cat("WHEN TO USE EACH MODEL\n")
cat("====================================================================\n\n")

cat("Use MODEL 1/2 when:\n")
cat("  ✓ You care about correlations among SES effects\n")
cat("  ✓ Model converges without issues\n")
cat("  ✓ You want the 'proper' random slopes model\n\n")

cat("Use MODEL 3 when:\n")
cat("  ✓ Model 1/2 fails to converge\n")
cat("  ✓ You have imbalanced data (not all schools have all SES levels)\n")
cat("  ✓ Correlations aren't theoretically important\n")
cat("  ✓ You want a simpler, more stable model\n\n")

cat("====================================================================\n")
cat("KEY INSIGHT\n")
cat("====================================================================\n\n")

cat("Categorical random effects are just like continuous random slopes,\n")
cat("but you're allowing MULTIPLE slopes (k-1) to vary instead of one.\n\n")

cat("This gets complicated fast:\n")
cat("  • 2 categories → 1 random slope + correlation\n")
cat("  • 3 categories → 2 random slopes + 3 correlations\n")
cat("  • 4 categories → 3 random slopes + 6 correlations\n\n")

cat("The interaction approach (Model 3) is often the practical solution\n")
cat("when you need categorical random effects.\n\n")

cat("Think of it as: 'Let each group×category combination have its own effect'\n")
cat("rather than: 'Let each slope vary by group with correlations'\n")

