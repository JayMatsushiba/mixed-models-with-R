################################################################################
# COMPLETE GUIDE TO lmer() SYNTAX
################################################################################

library(lme4)

cat("====================================================================\n")
cat("BASIC lmer() STRUCTURE\n")
cat("====================================================================\n\n")

cat("General form:\n")
cat("  lmer(formula, data, ...)\n\n")

cat("Formula structure:\n")
cat("  outcome ~ fixed_effects + (random_effects | grouping_variable)\n\n")

cat("====================================================================\n")
cat("PART 1: FIXED EFFECTS (left of |)\n")
cat("====================================================================\n\n")

cat("Just like regular lm() models:\n\n")

cat("1. Single predictor:\n")
cat("   y ~ x\n")
cat("   → β₀ + β₁×x\n\n")

cat("2. Multiple predictors:\n")
cat("   y ~ x1 + x2\n")
cat("   → β₀ + β₁×x1 + β₂×x2\n\n")

cat("3. Interaction:\n")
cat("   y ~ x1 + x2 + x1:x2    (or y ~ x1 * x2)\n")
cat("   → β₀ + β₁×x1 + β₂×x2 + β₃×x1×x2\n\n")

cat("4. No intercept:\n")
cat("   y ~ 0 + x    (or y ~ -1 + x)\n")
cat("   → β₁×x  (no intercept term)\n\n")

cat("5. Categorical variables:\n")
cat("   y ~ factor_var\n")
cat("   → Automatically creates dummy variables\n\n")

cat("====================================================================\n")
cat("PART 2: RANDOM EFFECTS (inside parentheses)\n")
cat("====================================================================\n\n")

cat("Syntax: (random_formula | grouping_variable)\n\n")

cat("The random_formula specifies WHAT varies by group\n")
cat("The grouping_variable specifies WHO/WHAT the groups are\n\n")

cat("Examples:\n")
cat("─────────────────────────────────────────────────────────────────\n\n")

cat("1. Random intercepts only:\n")
cat("   (1 | student)\n")
cat("   → Each student has their own intercept\n")
cat("   → Model: y = (β₀ + u₀ᵢ) + β₁×x + ε\n\n")

cat("2. Random slopes only (rare):\n")
cat("   (0 + x | student)\n")
cat("   → Each student has their own slope for x\n")
cat("   → Model: y = β₀ + (β₁ + u₁ᵢ)×x + ε\n\n")

cat("3. Random intercepts AND slopes (correlated):\n")
cat("   (1 + x | student)\n")
cat("   → Each student has own intercept AND slope\n")
cat("   → Correlation between intercepts and slopes estimated\n")
cat("   → Model: y = (β₀ + u₀ᵢ) + (β₁ + u₁ᵢ)×x + ε\n\n")

cat("4. Random intercepts AND slopes (uncorrelated):\n")
cat("   (1 | student) + (0 + x | student)\n")
cat("   → Each student has own intercept AND slope\n")
cat("   → NO correlation estimated (independent)\n\n")

cat("5. Multiple grouping levels (crossed):\n")
cat("   (1 | student) + (1 | school)\n")
cat("   → Students nested in... nothing\n")
cat("   → Schools are separate grouping\n")
cat("   → Use when students can belong to multiple schools\n\n")

cat("6. Nested random effects:\n")
cat("   (1 | school/classroom)\n")
cat("   → Expands to: (1 | school) + (1 | school:classroom)\n")
cat("   → Classrooms nested within schools\n\n")

cat("7. Interaction as grouping:\n")
cat("   (1 | school:treatment)\n")
cat("   → Random effect for each school×treatment combination\n")
cat("   → Useful for categorical random effects\n\n")

cat("====================================================================\n")
cat("PART 3: COMPLETE EXAMPLES WITH EXPLANATIONS\n")
cat("====================================================================\n\n")

cat("Example 1: GPA over time\n")
cat("─────────────────────────────────────────────────────────────────\n")
cat("Model: gpa ~ occasion + (1 + occasion | student)\n\n")
cat("Reads as:\n")
cat("  • GPA predicted by occasion (fixed effect)\n")
cat("  • Each student has their own intercept (1)\n")
cat("  • Each student has their own slope for occasion\n")
cat("  • Intercepts and slopes can be correlated\n\n")
cat("Fixed effects:     β₀ (average starting GPA)\n")
cat("                   β₁ (average change per semester)\n")
cat("Random effects:    u₀ᵢ (student i's deviation in intercept)\n")
cat("                   u₁ᵢ (student i's deviation in slope)\n")
cat("Full model:        GPAᵢⱼ = (β₀ + u₀ᵢ) + (β₁ + u₁ᵢ)×occasion + εᵢⱼ\n\n")

cat("Example 2: Adding covariates\n")
cat("─────────────────────────────────────────────────────────────────\n")
cat("Model: gpa ~ occasion + sex + highgpa + (1 + occasion | student)\n\n")
cat("Reads as:\n")
cat("  • GPA predicted by occasion, sex, and highgpa (all fixed)\n")
cat("  • Random intercepts and slopes for occasion by student\n")
cat("  • Sex and highgpa effects are FIXED (same for everyone)\n\n")

cat("Example 3: Categorical random effect (method 1)\n")
cat("─────────────────────────────────────────────────────────────────\n")
cat("Model: achievement ~ ses + (1 + ses | school)\n\n")
cat("Reads as:\n")
cat("  • Achievement predicted by SES (if 3 levels: 2 coefficients)\n")
cat("  • Each school has own intercept\n")
cat("  • Each school has own effects for each SES level\n")
cat("  • All can be correlated\n")
cat("  → Can have convergence issues!\n\n")

cat("Example 4: Categorical random effect (method 2 - simpler)\n")
cat("─────────────────────────────────────────────────────────────────\n")
cat("Model: achievement ~ ses + (1 | school) + (1 | school:ses)\n\n")
cat("Reads as:\n")
cat("  • Achievement predicted by SES\n")
cat("  • Random effect for school (overall school effect)\n")
cat("  • Random effect for each school×SES combination\n")
cat("  • No correlations estimated → more stable\n\n")

cat("Example 5: Nested structure\n")
cat("─────────────────────────────────────────────────────────────────\n")
cat("Model: score ~ time + (1 | school/classroom/student)\n\n")
cat("Expands to:\n")
cat("  (1 | school) + (1 | school:classroom) + (1 | school:classroom:student)\n\n")
cat("Reads as:\n")
cat("  • Students nested in classrooms nested in schools\n")
cat("  • Three levels of random effects\n\n")

cat("Example 6: Crossed random effects\n")
cat("─────────────────────────────────────────────────────────────────\n")
cat("Model: rating ~ (1 | rater) + (1 | item)\n\n")
cat("Reads as:\n")
cat("  • Each rater has their own intercept\n")
cat("  • Each item has its own intercept\n")
cat("  • Raters and items are CROSSED (not nested)\n")
cat("  • Every rater rates every item\n\n")

cat("====================================================================\n")
cat("PART 4: SPECIAL SYNTAX ELEMENTS\n")
cat("====================================================================\n\n")

cat("The '1' in random effects:\n")
cat("  • Stands for 'intercept'\n")
cat("  • (1 | group) means random intercepts\n")
cat("  • Always include unless you specifically don't want intercepts\n\n")

cat("The '0' in random effects:\n")
cat("  • Removes intercept\n")
cat("  • (0 + x | group) means random slopes only, no intercepts\n")
cat("  • Rarely used alone\n\n")

cat("The '+' inside parentheses:\n")
cat("  • (1 + x | group) means random intercepts AND slopes\n")
cat("  • WITH correlation between them\n\n")

cat("The '||' (double bar):\n")
cat("  • (1 + x || group) means random intercepts AND slopes\n")
cat("  • WITHOUT correlation (same as (1|group) + (0+x|group))\n\n")

cat("The '/' (slash):\n")
cat("  • (1 | A/B) expands to (1|A) + (1|A:B)\n")
cat("  • Means 'B nested within A'\n\n")

cat("The ':' (colon):\n")
cat("  • (1 | school:teacher) means random effect for each combination\n")
cat("  • Creates interaction as grouping variable\n\n")

cat("====================================================================\n")
cat("PART 5: COMMON PATTERNS\n")
cat("====================================================================\n\n")

cat("Pattern 1: Longitudinal data (repeated measures)\n")
cat("  lmer(outcome ~ time + covariates + (1 + time | subject), data)\n")
cat("  → Each subject has own trajectory\n\n")

cat("Pattern 2: Students in schools\n")
cat("  lmer(outcome ~ predictors + (1 | school), data)\n")
cat("  → School-level random intercepts only\n\n")

cat("Pattern 3: Students in schools with varying effects\n")
cat("  lmer(outcome ~ treatment + (1 + treatment | school), data)\n")
cat("  → Treatment effect varies by school\n\n")

cat("Pattern 4: Multilevel with covariates\n")
cat("  lmer(outcome ~ student_var + school_var + (1 | school), data)\n")
cat("  → Both individual and school-level predictors\n\n")

cat("Pattern 5: Three-level nested\n")
cat("  lmer(outcome ~ time + (1 | country/region/city), data)\n")
cat("  → Three nested levels of clustering\n\n")

cat("====================================================================\n")
cat("PART 6: WHAT NOT TO DO (COMMON MISTAKES)\n")
cat("====================================================================\n\n")

cat("Mistake 1: Treating cluster-level variables as random\n")
cat("  WRONG: lmer(gpa ~ occasion + (1 | student) + (1 | sex), data)\n")
cat("  RIGHT: lmer(gpa ~ occasion + sex + (1 | student), data)\n")
cat("  → Sex is a CHARACTERISTIC of students, not a grouping\n\n")

cat("Mistake 2: Forgetting the '1'\n")
cat("  WRONG: lmer(y ~ x + (x | group), data)\n")
cat("  RIGHT: lmer(y ~ x + (1 + x | group), data)\n")
cat("  → Usually want random intercepts too\n\n")

cat("Mistake 3: Random effects for variables that don't vary within group\n")
cat("  WRONG: lmer(score ~ time + (1 + school_type | school), data)\n")
cat("  → school_type doesn't vary within school!\n\n")

cat("Mistake 4: Overcomplicating\n")
cat("  WRONG: lmer(y ~ x + (1 + x + x^2 + x^3 | group), data)\n")
cat("  → Start simple, add complexity only if needed\n\n")

cat("====================================================================\n")
cat("PART 7: QUICK REFERENCE CHEAT SHEET\n")
cat("====================================================================\n\n")

cat("Random intercepts only:\n")
cat("  (1 | group)\n\n")

cat("Random slopes only:\n")
cat("  (0 + x | group)\n\n")

cat("Random intercepts + slopes (correlated):\n")
cat("  (1 + x | group)\n\n")

cat("Random intercepts + slopes (uncorrelated):\n")
cat("  (1 | group) + (0 + x | group)\n")
cat("  OR: (1 + x || group)\n\n")

cat("Multiple grouping levels:\n")
cat("  (1 | group1) + (1 | group2)\n\n")

cat("Nested:\n")
cat("  (1 | level1/level2)\n")
cat("  Expands to: (1 | level1) + (1 | level1:level2)\n\n")

cat("Interaction grouping:\n")
cat("  (1 | group1:group2)\n\n")

