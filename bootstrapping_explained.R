# Bootstrapping: A Complete Explanation
# What it is, why it's used, and how it works in mixed models

library(lme4)
library(dplyr)

load('data/gpa.RData')

cat("========================================================================\n")
cat("WHAT IS BOOTSTRAPPING?\n")
cat("========================================================================\n\n")

cat("QUICK DEFINITION:\n")
cat("Bootstrapping is a resampling method that estimates uncertainty\n")
cat("(standard errors, confidence intervals) by repeatedly sampling\n")
cat("from your data with replacement.\n\n")

cat("Think of it as: 'What if we collected our data many times?'\n\n")

# ============================================================================
# PART 1: The Core Idea
# ============================================================================

cat("========================================================================\n")
cat("PART 1: THE CORE IDEA OF BOOTSTRAPPING\n")
cat("========================================================================\n\n")

cat("THE PROBLEM:\n")
cat("  We want to know: 'How uncertain are our estimates?'\n")
cat("  Ideally: Collect new data 1000 times, fit model each time\n")
cat("  Reality: We only have ONE dataset!\n\n")

cat("THE BOOTSTRAP SOLUTION:\n")
cat("  1. Treat your sample as if it's the population\n")
cat("  2. Sample from it WITH REPLACEMENT (same size as original)\n")
cat("  3. Fit your model to this 'bootstrap sample'\n")
cat("  4. Repeat steps 2-3 many times (e.g., 1000 times)\n")
cat("  5. Look at distribution of estimates across bootstrap samples\n\n")

cat("INTUITION:\n")
cat("  Each bootstrap sample is like a 'parallel universe' version\n")
cat("  of your data collection. The variation across bootstrap samples\n")
cat("  approximates the variation you'd see collecting real data repeatedly.\n\n")

# ============================================================================
# PART 2: Simple Example (Not Mixed Models Yet)
# ============================================================================

cat("========================================================================\n")
cat("PART 2: SIMPLE EXAMPLE - Bootstrapping a Mean\n")
cat("========================================================================\n\n")

# Take a small sample for illustration
set.seed(123)
sample_data = rnorm(20, mean = 100, sd = 15)

cat("Original sample (n=20):\n")
cat("  Mean = ", sprintf("%.2f", mean(sample_data)), "\n", sep="")
cat("  SD   = ", sprintf("%.2f", sd(sample_data)), "\n\n", sep="")

cat("Standard error of the mean (formula): SE = SD/√n\n")
cat("  SE = ", sprintf("%.2f", sd(sample_data)/sqrt(20)), "\n\n", sep="")

cat("Now let's bootstrap to estimate the SE...\n\n")

# Bootstrap
n_boot = 1000
boot_means = numeric(n_boot)

for(i in 1:n_boot) {
  # Sample WITH REPLACEMENT
  boot_sample = sample(sample_data, size = 20, replace = TRUE)
  boot_means[i] = mean(boot_sample)
}

cat("Bootstrapped SE (from ", n_boot, " bootstrap samples):\n", sep="")
cat("  SE = ", sprintf("%.2f", sd(boot_means)), "\n\n", sep="")

cat("Bootstrap 95% CI (percentile method):\n")
cat("  [", sprintf("%.2f", quantile(boot_means, 0.025)), ", ",
    sprintf("%.2f", quantile(boot_means, 0.975)), "]\n\n", sep="")

cat("See? Bootstrap SE ≈ formula SE!\n")
cat("And we got a confidence interval without assuming normality.\n\n")

# ============================================================================
# PART 3: Why Bootstrap for Mixed Models?
# ============================================================================

cat("========================================================================\n")
cat("PART 3: WHY USE BOOTSTRAPPING FOR MIXED MODELS?\n")
cat("========================================================================\n\n")

cat("Remember these challenges with mixed models:\n\n")

cat("1. DEGREES OF FREEDOM PROBLEM:\n")
cat("   - No clear df for p-values/CIs\n")
cat("   - Different parameters have different effective sample sizes\n\n")

cat("2. ASYMPTOTIC ASSUMPTIONS:\n")
cat("   - Standard CIs assume large sample and normality\n")
cat("   - May not hold for:\n")
cat("     • Small number of groups\n")
cat("     • Variance components (bounded at zero)\n")
cat("     • Individual random effects\n\n")

cat("3. COMPLEX MODELS:\n")
cat("   - No closed-form standard errors for some quantities\n")
cat("   - e.g., predictions, functions of parameters\n\n")

cat("BOOTSTRAPPING HELPS BECAUSE:\n")
cat("  ✓ No distributional assumptions needed\n")
cat("  ✓ No df calculations needed\n")
cat("  ✓ Works for any quantity you can calculate\n")
cat("  ✓ Especially good for random effects and variance components\n\n")

cat("From the textbook (random_intercepts.Rmd:342):\n")
cat("  'With lme4 this typically would be done via bootstrapping,\n")
cat("   specifically with the bootMer function.'\n\n")

# ============================================================================
# PART 4: Types of Bootstrap for Mixed Models
# ============================================================================

cat("========================================================================\n")
cat("PART 4: TYPES OF BOOTSTRAP FOR MIXED MODELS\n")
cat("========================================================================\n\n")

cat("There are different ways to bootstrap clustered/hierarchical data:\n\n")

cat("1. PARAMETRIC BOOTSTRAP:\n")
cat("   - Assume the model is correct\n")
cat("   - Simulate new data from the fitted model\n")
cat("   - Refit to simulated data\n")
cat("   Process:\n")
cat("     a) Fit model to original data\n")
cat("     b) Simulate response from: y* ~ N(Xβ + Zu, σ²)\n")
cat("        where u ~ N(0, τ²) (new random effects)\n")
cat("     c) Refit model to y*\n")
cat("     d) Repeat many times\n\n")

cat("2. CASE RESAMPLING (resample groups):\n")
cat("   - Sample entire clusters with replacement\n")
cat("   - Preserves within-cluster correlation\n")
cat("   Example: Sample 200 students with replacement\n")
cat("            (some students appear 0, 1, 2+ times)\n\n")

cat("3. RESIDUAL BOOTSTRAP:\n")
cat("   - Resample residuals while keeping structure\n")
cat("   - More complex, less common\n\n")

cat("For lme4::bootMer:\n")
cat("  - Parametric bootstrap is the default\n")
cat("  - Can also do case resampling\n\n")

# ============================================================================
# PART 5: Demonstration with bootMer
# ============================================================================

cat("========================================================================\n")
cat("PART 5: BOOTSTRAPPING WITH bootMer (Conceptual)\n")
cat("========================================================================\n\n")

cat("NOTE: I'll show the code structure, but won't run it\n")
cat("      (bootstrapping is slow with many iterations)\n\n")

gpa_mixed = lmer(gpa ~ occasion + (1 | student), data = gpa)

cat("Our fitted model:\n")
cat("  gpa ~ occasion + (1|student)\n\n")

cat("Let's say we want a CI for the ICC:\n")
cat("  ICC = τ² / (τ² + σ²)\n\n")

cat("Step 1: Write a function to extract what you want\n")
cat("────────────────────────────────────────────────────\n")
cat("icc_function = function(model) {\n")
cat("  vc = as.data.frame(VarCorr(model))\n")
cat("  tau_sq = vc$vcov[1]\n")
cat("  sigma_sq = vc$vcov[2]\n")
cat("  return(tau_sq / (tau_sq + sigma_sq))\n")
cat("}\n\n")

cat("Step 2: Bootstrap using bootMer\n")
cat("────────────────────────────────────────────────────\n")
cat("# DON'T RUN (slow!):\n")
cat("# boot_results = bootMer(\n")
cat("#   gpa_mixed,           # fitted model\n")
cat("#   icc_function,        # function to apply\n")
cat("#   nsim = 1000,         # number of bootstrap samples\n")
cat("#   use.u = FALSE,       # parametric bootstrap\n")
cat("#   type = 'parametric'  # simulate from model\n")
cat("# )\n\n")

cat("Step 3: Get confidence interval\n")
cat("────────────────────────────────────────────────────\n")
cat("# boot.ci(boot_results, type = 'perc')\n\n")

cat("What happens under the hood:\n")
cat("  Loop 1000 times:\n")
cat("    1. Simulate new y from fitted model\n")
cat("    2. Refit model to simulated y\n")
cat("    3. Calculate ICC from refitted model\n")
cat("    4. Store ICC value\n")
cat("  \n")
cat("  Result: 1000 ICC values\n")
cat("  CI = [2.5th percentile, 97.5th percentile]\n\n")

# ============================================================================
# PART 6: Manual Parametric Bootstrap Example
# ============================================================================

cat("========================================================================\n")
cat("PART 6: MANUAL PARAMETRIC BOOTSTRAP (Small Scale)\n")
cat("========================================================================\n\n")

cat("Let me show you what happens with a SMALL example\n")
cat("(just 20 bootstrap samples for speed):\n\n")

set.seed(42)
n_boot = 20  # Small number for demonstration

# Extract parameters from fitted model
fixed_eff = fixef(gpa_mixed)
vc = as.data.frame(VarCorr(gpa_mixed))
tau = vc$sdcor[1]
sigma = vc$sdcor[2]

cat("Original model estimates:\n")
cat("  Intercept: ", sprintf("%.4f", fixed_eff[1]), "\n", sep="")
cat("  Occasion:  ", sprintf("%.4f", fixed_eff[2]), "\n", sep="")
cat("  τ (student SD): ", sprintf("%.4f", tau), "\n", sep="")
cat("  σ (residual SD): ", sprintf("%.4f", sigma), "\n\n", sep="")

# Storage for bootstrap estimates
boot_intercepts = numeric(n_boot)
boot_occasions = numeric(n_boot)
boot_taus = numeric(n_boot)
boot_sigmas = numeric(n_boot)

cat("Running ", n_boot, " bootstrap iterations...\n", sep="")
cat("(Each iteration: simulate data → refit model)\n\n")

for(b in 1:n_boot) {
  # Step 1: Simulate new random effects for each student
  n_students = length(unique(gpa$student))
  new_random_effects = rnorm(n_students, mean = 0, sd = tau)

  # Step 2: Simulate new response
  gpa_sim = gpa
  for(i in 1:nrow(gpa_sim)) {
    student_id = as.numeric(gpa_sim$student[i])
    # Fixed effects + random effect + residual
    gpa_sim$gpa[i] = fixed_eff[1] +
                     fixed_eff[2] * gpa_sim$occasion[i] +
                     new_random_effects[student_id] +
                     rnorm(1, mean = 0, sd = sigma)
  }

  # Step 3: Refit model to simulated data
  boot_model = lmer(gpa ~ occasion + (1|student), data = gpa_sim)

  # Step 4: Extract estimates
  boot_fixed = fixef(boot_model)
  boot_vc = as.data.frame(VarCorr(boot_model))

  boot_intercepts[b] = boot_fixed[1]
  boot_occasions[b] = boot_fixed[2]
  boot_taus[b] = boot_vc$sdcor[1]
  boot_sigmas[b] = boot_vc$sdcor[2]
}

cat("Bootstrap results (", n_boot, " samples):\n", sep="")
cat("─────────────────────────────────────────────────────────\n")
cat("Parameter      Original   Boot Mean   Boot SD\n")
cat("─────────────────────────────────────────────────────────\n")
cat(sprintf("Intercept      %.4f     %.4f      %.4f\n",
            fixed_eff[1], mean(boot_intercepts), sd(boot_intercepts)))
cat(sprintf("Occasion       %.4f     %.4f      %.4f\n",
            fixed_eff[2], mean(boot_occasions), sd(boot_occasions)))
cat(sprintf("τ (student SD) %.4f     %.4f      %.4f\n",
            tau, mean(boot_taus), sd(boot_taus)))
cat(sprintf("σ (resid SD)   %.4f     %.4f      %.4f\n",
            sigma, mean(boot_sigmas), sd(boot_sigmas)))
cat("─────────────────────────────────────────────────────────\n\n")

cat("Bootstrap 95% CI (percentile method):\n")
cat("  Intercept: [", sprintf("%.4f", quantile(boot_intercepts, 0.025)), ", ",
    sprintf("%.4f", quantile(boot_intercepts, 0.975)), "]\n", sep="")
cat("  τ:         [", sprintf("%.4f", quantile(boot_taus, 0.025)), ", ",
    sprintf("%.4f", quantile(boot_taus, 0.975)), "]\n\n", sep="")

cat("Note: With only ", n_boot, " samples, these are rough estimates.\n", sep="")
cat("Typically use 1000+ bootstrap samples for reliable CIs.\n\n")

# ============================================================================
# PART 7: When to Use Bootstrap
# ============================================================================

cat("========================================================================\n")
cat("PART 7: WHEN TO USE BOOTSTRAPPING IN MIXED MODELS\n")
cat("========================================================================\n\n")

cat("Use bootstrap for:\n\n")

cat("1. CONFIDENCE INTERVALS FOR VARIANCE COMPONENTS:\n")
cat("   - τ, σ are bounded at zero (not normally distributed)\n")
cat("   - Wald CIs can give negative lower bounds (nonsense!)\n")
cat("   - Bootstrap respects the boundary\n\n")

cat("2. CONFIDENCE INTERVALS FOR INDIVIDUAL RANDOM EFFECTS:\n")
cat("   - Want to know if Student 1's effect is 'significant'\n")
cat("   - From textbook: use bootMer or merTools package\n\n")

cat("3. CONFIDENCE INTERVALS FOR DERIVED QUANTITIES:\n")
cat("   - ICC = τ²/(τ²+σ²)\n")
cat("   - R² analogs\n")
cat("   - Predictions\n")
cat("   - Any function of parameters\n\n")

cat("4. SMALL SAMPLE SIZES:\n")
cat("   - Few groups (e.g., 10-20)\n")
cat("   - Asymptotic theory may not hold\n")
cat("   - Bootstrap more accurate\n\n")

cat("5. COMPLEX MODELS:\n")
cat("   - Multiple random effects\n")
cat("   - Crossed random effects\n")
cat("   - When you don't trust asymptotic approximations\n\n")

cat("Don't necessarily need bootstrap for:\n")
cat("  - Fixed effects with many groups (Wald CIs often fine)\n")
cat("  - Large samples with simple structure\n")
cat("  - Quick exploratory analysis\n\n")

# ============================================================================
# PART 8: Alternatives to Bootstrap
# ============================================================================

cat("========================================================================\n")
cat("PART 8: ALTERNATIVES TO BOOTSTRAPPING\n")
cat("========================================================================\n\n")

cat("1. WALD CONFIDENCE INTERVALS (Fast but approximate):\n")
cat("   confint(model, method = 'Wald')\n")
cat("   - Assumes normality\n")
cat("   - Can give impossible values for variance components\n")
cat("   - Fast!\n\n")

cat("2. PROFILE LIKELIHOOD (More accurate):\n")
cat("   confint(model, method = 'profile')\n")
cat("   - Uses actual likelihood function\n")
cat("   - Respects parameter boundaries\n")
cat("   - Slower than Wald, faster than bootstrap\n")
cat("   - Often recommended default\n\n")

cat("3. BAYESIAN METHODS (Best but requires different framework):\n")
cat("   library(brms) or library(rstanarm)\n")
cat("   - Get full posterior distribution\n")
cat("   - Natural uncertainty quantification\n")
cat("   - Credible intervals instead of confidence intervals\n\n")

cat("4. merTools PACKAGE (Approximate bootstrap):\n")
cat("   library(merTools)\n")
cat("   predictInterval(model)\n")
cat("   - Faster than full bootstrap\n")
cat("   - From textbook: 'on par with Bayesian results'\n\n")

# ============================================================================
# PART 9: Limitations of Bootstrap
# ============================================================================

cat("========================================================================\n")
cat("PART 9: LIMITATIONS OF BOOTSTRAPPING\n")
cat("========================================================================\n\n")

cat("1. COMPUTATIONAL COST:\n")
cat("   - Need 1000+ iterations\n")
cat("   - Each iteration refits the entire model\n")
cat("   - Can be VERY slow for large/complex models\n\n")

cat("2. ASSUMES MODEL IS CORRECT:\n")
cat("   - Parametric bootstrap assumes your model structure is right\n")
cat("   - If model is misspecified, bootstrap CIs can be misleading\n\n")

cat("3. SMALL SAMPLE ISSUES:\n")
cat("   - Bootstrap works best with 'enough' data\n")
cat("   - With very few groups, bootstrap can be unreliable\n\n")

cat("4. NOT A MAGIC FIX:\n")
cat("   - Won't fix fundamental data problems\n")
cat("   - Can't create information that isn't there\n\n")

# ============================================================================
# PART 10: Key Concepts Summary
# ============================================================================

cat("========================================================================\n")
cat("PART 10: KEY CONCEPTS - BOOTSTRAPPING\n")
cat("========================================================================\n\n")

cat("WHAT IS IT?\n")
cat("  Resampling method to estimate uncertainty by repeatedly\n")
cat("  sampling from data (or simulating from model) and refitting.\n\n")

cat("HOW DOES IT WORK?\n")
cat("  1. Fit model to original data\n")
cat("  2. Generate new 'bootstrap' dataset\n")
cat("     (parametric: simulate from model)\n")
cat("     (case resampling: sample groups with replacement)\n")
cat("  3. Refit model to bootstrap data\n")
cat("  4. Save estimates\n")
cat("  5. Repeat 1000+ times\n")
cat("  6. Use distribution of estimates for CI\n\n")

cat("WHY USE IT FOR MIXED MODELS?\n")
cat("  - No df assumptions needed\n")
cat("  - Works for variance components (bounded parameters)\n")
cat("  - Works for any derived quantity\n")
cat("  - More accurate with small samples\n\n")

cat("WHEN TO USE IT?\n")
cat("  - CIs for variance components\n")
cat("  - CIs for individual random effects\n")
cat("  - CIs for ICC, R², predictions\n")
cat("  - Small number of groups\n")
cat("  - Complex models\n\n")

cat("IN R (lme4):\n")
cat("  bootMer(model, function_to_apply, nsim = 1000)\n\n")

cat("ALTERNATIVES:\n")
cat("  - Profile likelihood (often good enough)\n")
cat("  - Bayesian methods (best, but different framework)\n")
cat("  - merTools (fast approximation)\n\n")

cat("========================================================================\n")
cat("BOTTOM LINE: Bootstrap = 'What if we had many datasets?'\n")
cat("             Approximates sampling distribution by resampling/simulating\n")
cat("========================================================================\n")
