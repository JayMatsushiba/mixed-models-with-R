# Bootstrap Sampling Clarification
# YES! You sample FROM your sample, multiple times

library(dplyr)

cat("========================================================================\n")
cat("QUESTION: Do we sample FROM our sample dataset multiple times?\n")
cat("========================================================================\n\n")

cat("ANSWER: YES! That's exactly what bootstrapping does.\n\n")

cat("Let me show you exactly what this means...\n\n")

# ============================================================================
# PART 1: The Key Insight
# ============================================================================

cat("========================================================================\n")
cat("PART 1: THE KEY INSIGHT\n")
cat("========================================================================\n\n")

cat("The bootstrap philosophy:\n")
cat("  1. We have a SAMPLE from some population\n")
cat("  2. We treat our sample AS IF it were the population\n")
cat("  3. We take NEW samples FROM our original sample\n")
cat("  4. These new samples are called 'bootstrap samples'\n\n")

cat("Visual:\n")
cat("  \n")
cat("  Population (unknown, infinite)\n")
cat("        |\n")
cat("        | We sampled once\n")
cat("        ↓\n")
cat("  Our Sample (n observations)\n")
cat("        |\n")
cat("        | We treat this AS the population\n")
cat("        | and sample FROM it many times\n")
cat("        ↓\n")
cat("  Bootstrap Sample 1 (n observations, WITH REPLACEMENT)\n")
cat("  Bootstrap Sample 2 (n observations, WITH REPLACEMENT)\n")
cat("  Bootstrap Sample 3 (n observations, WITH REPLACEMENT)\n")
cat("  ...\n")
cat("  Bootstrap Sample 1000 (n observations, WITH REPLACEMENT)\n\n")

cat("So YES - we're sampling from our sample!\n\n")

# ============================================================================
# PART 2: Simple Concrete Example
# ============================================================================

cat("========================================================================\n")
cat("PART 2: CONCRETE EXAMPLE - Sampling from Your Sample\n")
cat("========================================================================\n\n")

# Create a tiny sample for illustration
set.seed(42)
original_sample = c(10, 15, 20, 25, 30)

cat("Our original sample (what we collected):\n")
cat("  ", original_sample, "\n\n")

cat("This is our ONLY data. We pretend it's the 'population'.\n\n")

cat("Now let's take 5 bootstrap samples FROM this sample:\n")
cat("(sampling WITH REPLACEMENT, same size as original)\n\n")

for(i in 1:5) {
  boot_sample = sample(original_sample, size = length(original_sample),
                      replace = TRUE)
  cat("Bootstrap sample ", i, ": ", boot_sample, "\n", sep="")
}

cat("\n")
cat("Notice:\n")
cat("  - Each bootstrap sample has 5 observations (same size as original)\n")
cat("  - Some values appear multiple times (e.g., 20, 20, 20)\n")
cat("  - Some values might not appear at all\n")
cat("  - All values come FROM our original sample\n\n")

cat("The key: WITH REPLACEMENT\n")
cat("  → Once we pick a value, we 'put it back'\n")
cat("  → So it can be picked again\n")
cat("  → That's why we see duplicates\n\n")

# ============================================================================
# PART 3: Why "With Replacement"?
# ============================================================================

cat("========================================================================\n")
cat("PART 3: WHY SAMPLE WITH REPLACEMENT?\n")
cat("========================================================================\n\n")

cat("Comparison:\n\n")

cat("WITHOUT replacement (just shuffling):\n")
set.seed(42)
no_replace = sample(original_sample, size = 5, replace = FALSE)
cat("  Sample 1: ", no_replace, "\n", sep="")
no_replace = sample(original_sample, size = 5, replace = FALSE)
cat("  Sample 2: ", no_replace, "\n", sep="")
cat("  → Just different orderings of the SAME data\n")
cat("  → No new information!\n\n")

cat("WITH replacement (bootstrap):\n")
set.seed(42)
with_replace1 = sample(original_sample, size = 5, replace = TRUE)
cat("  Sample 1: ", with_replace1, "\n", sep="")
with_replace2 = sample(original_sample, size = 5, replace = TRUE)
cat("  Sample 2: ", with_replace2, "\n", sep="")
cat("  → Different compositions\n")
cat("  → Creates variation that mimics sampling variation\n\n")

cat("The 'with replacement' creates variability that approximates\n")
cat("the variability we'd see if we could sample from the population again.\n\n")

# ============================================================================
# PART 4: Bootstrap for Mixed Models - Sampling Students
# ============================================================================

cat("========================================================================\n")
cat("PART 4: BOOTSTRAPPING MIXED MODELS - Sampling FROM Your Sample\n")
cat("========================================================================\n\n")

cat("For mixed models, there are TWO main approaches:\n\n")

cat("APPROACH 1: PARAMETRIC BOOTSTRAP (most common)\n")
cat("────────────────────────────────────────────────\n")
cat("  We DON'T resample the actual data\n")
cat("  Instead, we use our fitted model to SIMULATE new data\n")
cat("  Process:\n")
cat("    1. Fit model to original data\n")
cat("    2. Use fitted model as the 'population'\n")
cat("    3. Simulate new datasets FROM the model\n")
cat("    4. Each simulated dataset is a 'bootstrap sample'\n\n")

cat("  Example with GPA data:\n")
cat("    Original: 200 students, 6 obs each\n")
cat("    Fitted model gives: β, τ, σ\n")
cat("    Bootstrap iteration 1:\n")
cat("      - Simulate 200 new student effects from N(0, τ²)\n")
cat("      - Simulate 1200 new residuals from N(0, σ²)\n")
cat("      - Create y* = Xβ + Zu* + ε*\n")
cat("      - Refit model to y*\n\n")

cat("  This is sampling FROM the fitted model\n")
cat("  (treating the model as the population)\n\n")

cat("APPROACH 2: CASE RESAMPLING (alternative)\n")
cat("────────────────────────────────────────────────\n")
cat("  We DO resample the actual data\n")
cat("  But we resample entire CLUSTERS (students)\n")
cat("  Process:\n")
cat("    1. Sample students WITH REPLACEMENT\n")
cat("    2. Keep all observations for each sampled student\n\n")

cat("  Example with GPA data:\n")
cat("    Original: Students 1, 2, 3, ..., 200\n")
cat("    Bootstrap sample 1 might have:\n")
cat("      Students: 1, 1, 5, 7, 7, 7, 12, ..., 199\n")
cat("                ↑     ↑        ↑\n")
cat("                Student 1 appears twice\n")
cat("                Student 5 once\n")
cat("                Student 7 three times\n")
cat("                Students 2, 3, 4, 6... don't appear\n\n")

cat("  This is literally sampling FROM your sample of students!\n\n")

# ============================================================================
# PART 5: Demonstration - Case Resampling
# ============================================================================

cat("========================================================================\n")
cat("PART 5: DEMONSTRATION - Case Resampling FROM Your Sample\n")
cat("========================================================================\n\n")

# Create tiny example dataset
students = data.frame(
  student = rep(1:5, each = 3),
  time = rep(0:2, times = 5),
  score = c(
    # Student 1
    10, 12, 14,
    # Student 2
    15, 17, 19,
    # Student 3
    8, 10, 12,
    # Student 4
    20, 22, 24,
    # Student 5
    12, 14, 16
  )
)

cat("Our original sample: 5 students, 3 observations each\n\n")

cat("Student  Time  Score\n")
cat("───────────────────────\n")
for(i in 1:nrow(students)) {
  cat(sprintf("  %d      %d     %d\n",
              students$student[i],
              students$time[i],
              students$score[i]))
}
cat("\n")

cat("Bootstrap Sample 1: Sample 5 students WITH REPLACEMENT\n")
cat("───────────────────────────────────────────────────────\n")
set.seed(123)
boot_students_1 = sample(1:5, size = 5, replace = TRUE)
cat("Sampled students: ", boot_students_1, "\n\n")

boot_data_1 = students %>%
  filter(student %in% boot_students_1) %>%
  group_by(student) %>%
  slice(rep(1:n(), times = sum(boot_students_1 == student[1]))) %>%
  ungroup()

cat("Bootstrap dataset 1 (all obs for sampled students):\n")
cat("Student  Time  Score   Note\n")
cat("──────────────────────────────────────────\n")
for(s in boot_students_1) {
  stud_data = students[students$student == s, ]
  for(j in 1:nrow(stud_data)) {
    note = if(j == 1) sprintf("(from original student %d)", s) else ""
    cat(sprintf("  %d      %d     %d     %s\n",
                s, stud_data$time[j], stud_data$score[j], note))
  }
}
cat("\n")

cat("Notice:\n")
cat("  - We sampled FROM our original 5 students\n")
cat("  - Some students appear multiple times\n")
cat("  - Some students don't appear at all\n")
cat("  - We keep ALL observations for each sampled student\n\n")

cat("Bootstrap Sample 2: Different random sample\n")
cat("───────────────────────────────────────────────────────\n")
boot_students_2 = sample(1:5, size = 5, replace = TRUE)
cat("Sampled students: ", boot_students_2, "\n\n")

cat("Each bootstrap sample is different!\n")
cat("That variation approximates sampling variation.\n\n")

# ============================================================================
# PART 6: The Philosophy
# ============================================================================

cat("========================================================================\n")
cat("PART 6: THE BOOTSTRAP PHILOSOPHY\n")
cat("========================================================================\n\n")

cat("Traditional approach:\n")
cat("  'I have a sample. What can I say about the population?'\n")
cat("  → Use formulas (e.g., SE = SD/√n)\n")
cat("  → Requires assumptions (normality, etc.)\n\n")

cat("Bootstrap approach:\n")
cat("  'I have a sample. Let me treat it AS the population.'\n")
cat("  'If I sampled from this population many times, what would happen?'\n")
cat("  → Simulate the process of sampling\n")
cat("  → See empirically what happens\n")
cat("  → Fewer assumptions needed\n\n")

cat("Key insight:\n")
cat("  Sample → Population  (relationship we care about)\n")
cat("  is approximated by\n")
cat("  Bootstrap Sample → Original Sample  (relationship we can study)\n\n")

cat("We're using the sample-to-population relationship\n")
cat("to learn about the sampling distribution!\n\n")

# ============================================================================
# PART 7: What Gets Varied in Each Type
# ============================================================================

cat("========================================================================\n")
cat("PART 7: WHAT VARIES ACROSS BOOTSTRAP SAMPLES?\n")
cat("========================================================================\n\n")

cat("CASE RESAMPLING:\n")
cat("  Original sample: 200 students\n")
cat("  Bootstrap sample 1: Students {1, 1, 5, 7, 7, 12, ...}\n")
cat("  Bootstrap sample 2: Students {2, 3, 3, 8, 10, 10, ...}\n")
cat("  → WHICH students vary\n")
cat("  → Data values come from original sample\n\n")

cat("PARAMETRIC BOOTSTRAP:\n")
cat("  Original sample: 200 students, fitted model\n")
cat("  Bootstrap sample 1: Simulate y₁* from model\n")
cat("  Bootstrap sample 2: Simulate y₂* from model\n")
cat("  → DATA VALUES vary (simulated)\n")
cat("  → Same 200 students\n\n")

# ============================================================================
# PART 8: Common Confusion
# ============================================================================

cat("========================================================================\n")
cat("PART 8: COMMON CONFUSION CLARIFIED\n")
cat("========================================================================\n\n")

cat("QUESTION: 'Are we collecting new data?'\n")
cat("ANSWER: NO! We're resampling/simulating from our ONE dataset.\n\n")

cat("QUESTION: 'So we're making up data?'\n")
cat("ANSWER: Sort of! But in a principled way:\n")
cat("  - Case resampling: Rearranging existing data\n")
cat("  - Parametric: Simulating based on fitted model\n")
cat("  Both approximate what would happen with new samples\n\n")

cat("QUESTION: 'Isn't that circular reasoning?'\n")
cat("ANSWER: Not quite! The key insight:\n")
cat("  - Our sample approximates the population\n")
cat("  - Resampling from sample approximates resampling from population\n")
cat("  - The approximation gets better with larger samples\n\n")

cat("QUESTION: 'Why does this work?'\n")
cat("ANSWER: Mathematical theory! Under reasonable conditions:\n")
cat("  - Bootstrap distribution converges to sampling distribution\n")
cat("  - As sample size → ∞, bootstrap → perfect\n")
cat("  - With finite samples, it's an approximation (usually good)\n\n")

# ============================================================================
# SUMMARY
# ============================================================================

cat("========================================================================\n")
cat("SUMMARY: YES, WE SAMPLE FROM OUR SAMPLE!\n")
cat("========================================================================\n\n")

cat("1. We have ONE sample from the population\n\n")

cat("2. We treat this sample AS IF it were the population\n\n")

cat("3. We take many samples FROM this sample:\n")
cat("   - Case resampling: Sample observations/clusters WITH REPLACEMENT\n")
cat("   - Parametric: Simulate new data FROM fitted model\n\n")

cat("4. Each new sample is a 'bootstrap sample'\n\n")

cat("5. We fit our model to EACH bootstrap sample\n\n")

cat("6. We look at the DISTRIBUTION of estimates across bootstrap samples\n\n")

cat("7. This distribution approximates the sampling distribution\n")
cat("   (i.e., what we'd see if we could sample from population repeatedly)\n\n")

cat("Key phrases:\n")
cat("  ✓ 'Sampling from your sample'\n")
cat("  ✓ 'Resampling with replacement'\n")
cat("  ✓ 'Treating sample as population'\n")
cat("  ✓ 'Simulating the sampling process'\n\n")

cat("You had it exactly right: We sample FROM our sample, multiple times!\n\n")

cat("========================================================================\n")
