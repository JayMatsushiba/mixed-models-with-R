# Bootstrap Assumptions: When Does It Work and When Does It Fail?
# Understanding the conditions needed for valid bootstrap inference

library(dplyr)

cat("========================================================================\n")
cat("WHAT ARE THE ASSUMPTIONS FOR BOOTSTRAPPING TO WORK?\n")
cat("========================================================================\n\n")

cat("Unlike traditional methods, bootstrap has FEWER assumptions,\n")
cat("but it's not assumption-free!\n\n")

cat("Let me break down what bootstrap needs to work properly...\n\n")

# ============================================================================
# PART 1: Core Assumptions
# ============================================================================

cat("========================================================================\n")
cat("PART 1: CORE ASSUMPTIONS OF BOOTSTRAPPING\n")
cat("========================================================================\n\n")

cat("1. INDEPENDENCE OF OBSERVATIONS (for standard bootstrap)\n")
cat("   ────────────────────────────────────────────────────────\n")
cat("   Assumption: Your original observations are independent\n\n")

cat("   ✓ Valid:\n")
cat("     - Random sample from population\n")
cat("     - Each observation drawn independently\n\n")

cat("   ✗ Violates assumption:\n")
cat("     - Time series (observations correlated over time)\n")
cat("     - Spatial data (nearby locations correlated)\n")
cat("     - Clustered data WITHOUT accounting for clustering\n\n")

cat("   For mixed models:\n")
cat("     → This is why we use SPECIAL bootstrap procedures!\n")
cat("     → Case resampling: Sample clusters, not observations\n")
cat("     → Parametric: Model the dependence structure\n\n")

cat("2. REPRESENTATIVE SAMPLE\n")
cat("   ────────────────────────────────────────────────────────\n")
cat("   Assumption: Your sample represents the population\n\n")

cat("   ✓ Valid:\n")
cat("     - Random sampling\n")
cat("     - Probability sampling\n")
cat("     - Sample covers range of population\n\n")

cat("   ✗ Violates assumption:\n")
cat("     - Biased sampling (e.g., only volunteers)\n")
cat("     - Truncated/censored data\n")
cat("     - Missing important subgroups\n\n")

cat("   Why it matters:\n")
cat("     Bootstrap treats sample AS the population.\n")
cat("     If sample is biased, bootstrap will replicate that bias!\n\n")

cat("3. SUFFICIENT SAMPLE SIZE\n")
cat("   ────────────────────────────────────────────────────────\n")
cat("   Assumption: Large enough sample to represent population variability\n\n")

cat("   ✓ Generally safe:\n")
cat("     - n ≥ 30 for simple statistics (means, proportions)\n")
cat("     - n ≥ 50-100 for more complex statistics\n")
cat("     - For mixed models: enough GROUPS (20+ clusters)\n\n")

cat("   ✗ Bootstrap may fail:\n")
cat("     - Very small samples (n < 10)\n")
cat("     - Few clusters in mixed models (< 10 groups)\n")
cat("     - Rare events (e.g., only 2 successes in sample)\n\n")

cat("   Why it matters:\n")
cat("     Small samples may not capture population variability.\n")
cat("     Bootstrap can only resample what's in your data!\n\n")

cat("4. SMOOTHNESS (for parametric bootstrap)\n")
cat("   ────────────────────────────────────────────────────────\n")
cat("   Assumption: The statistic of interest is 'smooth'\n\n")

cat("   ✓ Smooth statistics:\n")
cat("     - Mean, median, regression coefficients\n")
cat("     - Variance, standard deviation\n")
cat("     - Correlations\n\n")

cat("   ⚠ Less smooth:\n")
cat("     - Minimum, maximum\n")
cat("     - Range\n")
cat("     - Quantiles (especially extreme ones)\n\n")

cat("   Why it matters:\n")
cat("     Bootstrap works better for statistics that don't\n")
cat("     change wildly with small perturbations in data.\n\n")

# ============================================================================
# PART 2: Additional Assumptions for Parametric Bootstrap
# ============================================================================

cat("========================================================================\n")
cat("PART 2: PARAMETRIC BOOTSTRAP - ADDITIONAL ASSUMPTIONS\n")
cat("========================================================================\n\n")

cat("Parametric bootstrap (used in mixed models) assumes:\n\n")

cat("5. MODEL IS CORRECTLY SPECIFIED\n")
cat("   ────────────────────────────────────────────────────────\n")
cat("   Assumption: Your model structure is correct\n\n")

cat("   For mixed models, this means:\n")
cat("     ✓ Correct random effects structure\n")
cat("     ✓ Correct fixed effects\n")
cat("     ✓ Correct distributional assumptions\n\n")

cat("   Example - GPA mixed model:\n")
cat("     Model: gpa ~ occasion + (1|student)\n")
cat("     Assumes:\n")
cat("       - Linear effect of time\n")
cat("       - Random intercepts (not slopes)\n")
cat("       - Normal residuals\n")
cat("       - Constant variance over time\n\n")

cat("   ✗ Problems if:\n")
cat("     - Effect is non-linear (but you fit linear)\n")
cat("     - Need random slopes (but only have intercepts)\n")
cat("     - Residuals are not normal\n")
cat("     - Heteroscedasticity (variance changes)\n\n")

cat("   Why it matters:\n")
cat("     Parametric bootstrap simulates FROM the fitted model.\n")
cat("     If model is wrong, simulated data won't match reality.\n")
cat("     Bootstrap CIs will be biased!\n\n")

cat("6. DISTRIBUTIONAL ASSUMPTIONS (for parametric)\n")
cat("   ────────────────────────────────────────────────────────\n")
cat("   Assumption: Random effects and residuals follow assumed distributions\n\n")

cat("   Standard mixed model assumes:\n")
cat("     u_j ~ N(0, τ²)     [random effects are normal]\n")
cat("     ε_ij ~ N(0, σ²)    [residuals are normal]\n\n")

cat("   ✓ Safe if:\n")
cat("     - Residual plots look reasonable\n")
cat("     - QQ plots approximately linear\n")
cat("     - No severe outliers\n\n")

cat("   ✗ Problems if:\n")
cat("     - Heavy-tailed distributions\n")
cat("     - Skewed distributions\n")
cat("     - Multimodal distributions\n\n")

cat("   Note: Case resampling doesn't require this assumption!\n\n")

# ============================================================================
# PART 3: What Bootstrap Does NOT Assume
# ============================================================================

cat("========================================================================\n")
cat("PART 3: WHAT BOOTSTRAP DOES NOT ASSUME (Advantages!)\n")
cat("========================================================================\n\n")

cat("Unlike traditional methods, bootstrap does NOT require:\n\n")

cat("✓ NORMALITY (for non-parametric bootstrap)\n")
cat("  Traditional: Assume sampling distribution is normal\n")
cat("  Bootstrap: Empirically estimates the distribution\n")
cat("              (can be skewed, heavy-tailed, whatever!)\n\n")

cat("✓ KNOWN STANDARD ERROR FORMULA\n")
cat("  Traditional: Need SE formula (often complex or non-existent)\n")
cat("  Bootstrap: Just resample and calculate!\n\n")

cat("✓ ASYMPTOTIC THEORY\n")
cat("  Traditional: Rely on large-sample approximations\n")
cat("  Bootstrap: Works with moderate samples\n\n")

cat("✓ SPECIFIC DEGREES OF FREEDOM\n")
cat("  Traditional mixed models: Fuzzy df problem\n")
cat("  Bootstrap: No df needed!\n\n")

# ============================================================================
# PART 4: When Bootstrap Fails
# ============================================================================

cat("========================================================================\n")
cat("PART 4: WHEN BOOTSTRAP FAILS OR PERFORMS POORLY\n")
cat("========================================================================\n\n")

cat("1. VERY SMALL SAMPLES\n")
cat("   ─────────────────────────────────────────────────────\n")
set.seed(123)
tiny_sample = c(10, 15, 20)
cat("   Example: n = 3\n")
cat("   Sample: ", tiny_sample, "\n\n")

cat("   Problem: Only 3 unique values!\n")
cat("   Bootstrap can only create combinations of these 3 values.\n")
cat("   Won't capture population variability well.\n\n")

cat("   Bootstrap samples:\n")
for(i in 1:5) {
  boot = sample(tiny_sample, 3, replace = TRUE)
  cat("     ", boot, "\n")
}
cat("\n   → Limited diversity\n\n")

cat("2. HEAVY DEPENDENCE (not accounting for it)\n")
cat("   ─────────────────────────────────────────────────────\n")
cat("   Example: Time series with strong autocorrelation\n")
cat("   \n")
cat("   Original: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]\n")
cat("             (strong trend)\n\n")

cat("   Standard bootstrap (WRONG):\n")
cat("     Might give: [5, 2, 8, 1, 9, 3, ...]  (shuffled)\n")
cat("     → Breaks time dependency!\n")
cat("     → CIs will be too narrow\n\n")

cat("   Correct approach: Block bootstrap or model-based\n\n")

cat("3. ESTIMATING EXTREMES\n")
cat("   ─────────────────────────────────────────────────────\n")
cat("   Example: Estimating maximum\n")
set.seed(42)
data_sample = rnorm(20, mean = 0, sd = 1)
cat("   Sample max: ", sprintf("%.2f", max(data_sample)), "\n\n")

cat("   Problem: Bootstrap max can never exceed sample max!\n")
cat("   → Underestimates true population max\n\n")

boot_maxes = replicate(100, max(sample(data_sample, 20, replace = TRUE)))
cat("   Bootstrap max range: [", sprintf("%.2f", min(boot_maxes)),
    ", ", sprintf("%.2f", max(boot_maxes)), "]\n", sep="")
cat("   → Never exceeds ", sprintf("%.2f", max(data_sample)), "\n\n", sep="")

cat("4. SPARSE DATA / RARE EVENTS\n")
cat("   ─────────────────────────────────────────────────────\n")
cat("   Example: Binary outcome with rare events\n")
cat("   Sample: 98 failures, 2 successes (out of 100)\n\n")

cat("   Problem: Some bootstrap samples may have 0 successes!\n")
cat("   → Can't estimate probability of success\n")
cat("   → CI may be unreliable\n\n")

cat("5. MODEL MISSPECIFICATION (parametric bootstrap)\n")
cat("   ─────────────────────────────────────────────────────\n")
cat("   Example: Fit linear model to non-linear data\n\n")

cat("   True relationship: y = x²\n")
cat("   Your model: y = β₀ + β₁x  (linear)\n\n")

cat("   Parametric bootstrap:\n")
cat("     → Simulates from LINEAR model\n")
cat("     → Doesn't capture non-linearity\n")
cat("     → CIs are wrong!\n\n")

cat("6. FEW CLUSTERS (mixed models)\n")
cat("   ─────────────────────────────────────────────────────\n")
cat("   Example: 5 schools with students nested within\n\n")

cat("   Problem: Only 5 unique cluster effects\n")
cat("   Case resampling: Can only resample from these 5\n")
cat("   → May not represent population of all schools\n\n")

cat("   General guideline:\n")
cat("     - n_clusters < 10: Bootstrap unreliable\n")
cat("     - n_clusters 10-20: Use with caution\n")
cat("     - n_clusters > 20: Usually okay\n\n")

# ============================================================================
# PART 5: Testing Assumptions
# ============================================================================

cat("========================================================================\n")
cat("PART 5: HOW TO CHECK IF BOOTSTRAP WILL WORK\n")
cat("========================================================================\n\n")

cat("1. CHECK SAMPLE SIZE\n")
cat("   ─────────────────────────────────────────────────────\n")
cat("   Questions:\n")
cat("     • Do I have at least 30-50 observations?\n")
cat("     • For mixed models: At least 20 clusters?\n")
cat("     • Do I have enough of each category/group?\n\n")

cat("2. CHECK INDEPENDENCE\n")
cat("   ─────────────────────────────────────────────────────\n")
cat("   Questions:\n")
cat("     • Are observations independent?\n")
cat("     • If clustered, am I using appropriate bootstrap method?\n")
cat("     • Any time/spatial dependence?\n\n")

cat("   For mixed models:\n")
cat("     → Use case resampling (clusters) or parametric bootstrap\n")
cat("     → Don't use standard bootstrap on all observations!\n\n")

cat("3. CHECK MODEL (for parametric bootstrap)\n")
cat("   ─────────────────────────────────────────────────────\n")
cat("   Diagnostics:\n")
cat("     • Residual plots (should be random)\n")
cat("     • QQ plots (should be linear)\n")
cat("     • Variance homogeneity\n")
cat("     • No systematic patterns\n\n")

cat("4. CHECK REPRESENTATIVENESS\n")
cat("   ─────────────────────────────────────────────────────\n")
cat("   Questions:\n")
cat("     • Is sample randomly selected?\n")
cat("     • Any selection bias?\n")
cat("     • Missing important subgroups?\n\n")

cat("5. SENSITIVITY ANALYSIS\n")
cat("   ─────────────────────────────────────────────────────\n")
cat("   Try different methods:\n")
cat("     • Parametric vs case resampling bootstrap\n")
cat("     • Bootstrap vs profile likelihood\n")
cat("     • Different number of bootstrap iterations\n")
cat("   If results similar → more confident\n")
cat("   If results very different → investigate!\n\n")

# ============================================================================
# PART 6: Mixed Models Specific
# ============================================================================

cat("========================================================================\n")
cat("PART 6: BOOTSTRAP ASSUMPTIONS FOR MIXED MODELS SPECIFICALLY\n")
cat("========================================================================\n\n")

cat("PARAMETRIC BOOTSTRAP (default in lme4::bootMer):\n")
cat("─────────────────────────────────────────────────────────────\n")
cat("Assumes:\n")
cat("  1. Model structure is correct\n")
cat("     (correct random effects, fixed effects)\n\n")

cat("  2. Random effects ~ N(0, τ²)\n")
cat("     (normally distributed)\n\n")

cat("  3. Residuals ~ N(0, σ²)\n")
cat("     (normally distributed, constant variance)\n\n")

cat("  4. Independence BETWEEN clusters\n")
cat("     (students are independent of each other)\n\n")

cat("  5. Observations WITHIN clusters can be dependent\n")
cat("     (that's what the random effects model!)\n\n")

cat("Doesn't assume:\n")
cat("  ✓ Specific degrees of freedom\n")
cat("  ✓ Large number of clusters (though > 20 recommended)\n\n")

cat("CASE RESAMPLING (alternative):\n")
cat("─────────────────────────────────────────────────────────────\n")
cat("Assumes:\n")
cat("  1. Clusters are INDEPENDENT\n\n")

cat("  2. Clusters are EXCHANGEABLE\n")
cat("     (one cluster is representative of another)\n\n")

cat("  3. Enough clusters to resample from\n")
cat("     (at least 20-30)\n\n")

cat("Doesn't assume:\n")
cat("  ✓ Normality of random effects\n")
cat("  ✓ Normality of residuals\n")
cat("  ✓ Specific model structure\n")
cat("  ✓ Homoscedasticity\n\n")

cat("→ Case resampling is more robust but needs more clusters\n\n")

# ============================================================================
# PART 7: Practical Guidelines
# ============================================================================

cat("========================================================================\n")
cat("PART 7: PRACTICAL GUIDELINES - WHEN TO TRUST BOOTSTRAP\n")
cat("========================================================================\n\n")

cat("GREEN LIGHT (Bootstrap should work well):\n")
cat("  ✓ n > 50 (or > 20 clusters for mixed models)\n")
cat("  ✓ Random/probability sample\n")
cat("  ✓ Model diagnostics look reasonable\n")
cat("  ✓ Estimating smooth statistics (means, coefficients, variance)\n")
cat("  ✓ Using appropriate method for data structure\n\n")

cat("YELLOW LIGHT (Use with caution):\n")
cat("  ⚠ 10 < n < 50 (or 10-20 clusters)\n")
cat("  ⚠ Some model misspecification concerns\n")
cat("  ⚠ Moderate outliers\n")
cat("  ⚠ Estimating quantiles or other less-smooth statistics\n")
cat("  → Compare with other methods (profile likelihood, Bayesian)\n\n")

cat("RED LIGHT (Bootstrap may fail):\n")
cat("  ✗ n < 10 (or < 10 clusters)\n")
cat("  ✗ Strong dependence not accounted for\n")
cat("  ✗ Severe model misspecification\n")
cat("  ✗ Estimating extremes (min, max)\n")
cat("  ✗ Very rare events\n")
cat("  ✗ Highly biased sample\n")
cat("  → Consider alternatives or collect more data\n\n")

# ============================================================================
# SUMMARY
# ============================================================================

cat("========================================================================\n")
cat("SUMMARY: BOOTSTRAP ASSUMPTIONS\n")
cat("========================================================================\n\n")

cat("KEY ASSUMPTIONS:\n\n")

cat("1. INDEPENDENCE (or appropriate handling of dependence)\n")
cat("   For mixed models: Use case/parametric bootstrap\n\n")

cat("2. REPRESENTATIVE SAMPLE\n")
cat("   Sample should represent population\n\n")

cat("3. SUFFICIENT SAMPLE SIZE\n")
cat("   Generally n ≥ 30, for mixed models ≥ 20 clusters\n\n")

cat("4. MODEL CORRECTNESS (parametric bootstrap only)\n")
cat("   Your model structure and assumptions should be right\n\n")

cat("WHAT BOOTSTRAP DOESN'T NEED:\n")
cat("  ✓ Normality (non-parametric bootstrap)\n")
cat("  ✓ Known SE formulas\n")
cat("  ✓ Degrees of freedom\n\n")

cat("WHEN IT FAILS:\n")
cat("  ✗ Very small samples\n")
cat("  ✗ Strong unmodeled dependence\n")
cat("  ✗ Estimating extremes\n")
cat("  ✗ Severe model misspecification (parametric)\n")
cat("  ✗ Few clusters (mixed models)\n\n")

cat("BOTTOM LINE:\n")
cat("Bootstrap is flexible but not magic!\n")
cat("Check your assumptions and compare with other methods when in doubt.\n\n")

cat("========================================================================\n")
