################################################################################
# CONCRETE EXAMPLE: Three Schools, Three SES Levels
################################################################################

cat("====================================================================\n")
cat("CONCRETE EXAMPLE\n")
cat("====================================================================\n\n")

cat("Data: 3 schools, students from low/mid/high SES backgrounds\n\n")

cat("FIXED EFFECTS (Population averages):\n")
cat("  Intercept:  50 (low SES students average 50)\n")
cat("  sesmid:     +5 (mid SES students score 5 points higher)\n")
cat("  seshigh:   +10 (high SES students score 10 points higher)\n\n")

cat("────────────────────────────────────────────────────────────────────\n")
cat("MODEL 1: (1 + ses | school) - Random slopes approach\n")
cat("────────────────────────────────────────────────────────────────────\n\n")

cat("Random effects for each school:\n\n")

cat("School A: (SES gap is LARGER than average)\n")
cat("  Random intercept:    +0 (no deviation for low SES)\n")
cat("  Random slope sesmid: +3 (mid-low gap is 3 points MORE)\n")
cat("  Random slope seshigh:+5 (high-low gap is 5 points MORE)\n\n")
cat("  Predictions:\n")
cat("    Low:  50 + 0 = 50\n")
cat("    Mid:  50 + (5+3) = 58  (population: 55)\n")
cat("    High: 50 + (10+5) = 65 (population: 60)\n")
cat("    → This school has BIGGER SES gaps\n\n")

cat("School B: (SES gap is SMALLER than average)\n")
cat("  Random intercept:    +5 (all students 5 points higher)\n")
cat("  Random slope sesmid: -2 (mid-low gap is 2 points LESS)\n")
cat("  Random slope seshigh:-3 (high-low gap is 3 points LESS)\n\n")
cat("  Predictions:\n")
cat("    Low:  50 + 5 = 55\n")
cat("    Mid:  55 + (5-2) = 58  (population: 55)\n")
cat("    High: 55 + (10-3) = 62 (population: 60)\n")
cat("    → This school REDUCES SES gaps (equity-promoting!)\n\n")

cat("School C: (Average SES gap, low overall)\n")
cat("  Random intercept:    -3 (all students 3 points lower)\n")
cat("  Random slope sesmid:  0 (average mid-low gap)\n")
cat("  Random slope seshigh: 0 (average high-low gap)\n\n")
cat("  Predictions:\n")
cat("    Low:  50 - 3 = 47\n")
cat("    Mid:  47 + 5 = 52\n")
cat("    High: 47 + 10 = 57\n")
cat("    → Low performing but typical SES pattern\n\n")

cat("────────────────────────────────────────────────────────────────────\n")
cat("MODEL 2: (0 + ses | school) - Intercept form\n")
cat("────────────────────────────────────────────────────────────────────\n\n")

cat("Same model, different parameterization:\n")
cat("Instead of 'intercept + slopes', we estimate 3 separate 'intercepts'\n\n")

cat("School A random effects:\n")
cat("  seslow:  +0\n")
cat("  sesmid:  +3\n")
cat("  seshigh: +5\n")
cat("  Predictions: Low=50, Mid=58, High=65 (SAME as Model 1!)\n\n")

cat("School B random effects:\n")
cat("  seslow:  +5\n")
cat("  sesmid:  +3\n")
cat("  seshigh: +2\n")
cat("  Predictions: Low=55, Mid=58, High=62 (SAME as Model 1!)\n\n")

cat("────────────────────────────────────────────────────────────────────\n")
cat("MODEL 3: (1|school) + (1|school:ses) - Interaction form\n")
cat("────────────────────────────────────────────────────────────────────\n\n")

cat("This creates separate random effects for each school×SES combination:\n\n")

cat("School A:\n")
cat("  Random effect for school A:      +2\n")
cat("  Random effect for A:low:         -2\n")
cat("  Random effect for A:mid:         +1\n")
cat("  Random effect for A:high:        +3\n\n")
cat("  Predictions:\n")
cat("    Low:  50 + 2 - 2 = 50\n")
cat("    Mid:  55 + 2 + 1 = 58\n")
cat("    High: 60 + 2 + 3 = 65\n")
cat("    → Similar to Model 1/2, but arrived at differently\n\n")

cat("====================================================================\n")
cat("WHICH MODEL IS BEST?\n")
cat("====================================================================\n\n")

cat("All three models are trying to capture the same phenomenon:\n")
cat("  'SES effects differ by school'\n\n")

cat("Model 1/2: Mathematically elegant, estimates correlations\n")
cat("           May fail to converge with complex data\n\n")

cat("Model 3:   More robust, often converges when 1/2 fail\n")
cat("           Doesn't estimate correlations\n")
cat("           Better with imbalanced data\n\n")

cat("In practice:\n")
cat("  • Try Model 1 first (most informative)\n")
cat("  • If convergence issues, use Model 3\n")
cat("  • Model 2 is just a reparameterization of Model 1\n")

