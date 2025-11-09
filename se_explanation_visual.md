# Why Does the Intercept SE Increase in Mixed Models?

## The Key Numbers from the GPA Example

### Standard Regression (WRONG)
```
Intercept: 2.5992  (SE = 0.0178)
Occasion:  0.1063  (SE = 0.0059)
Residual SD (σ): 0.3487
```

### Mixed Model (CORRECT)
```
Intercept: 2.5992  (SE = 0.0217)  ← INCREASED by 22%
Occasion:  0.1063  (SE = 0.0041)  ← DECREASED by 31%

Random Effects:
  Student SD (τ):  0.2524
  Residual SD (σ): 0.2410  ← Much smaller!
```

---

## The Critical Insight: Two Different Questions

The intercept and occasion are answering **fundamentally different questions**:

### INTERCEPT: "What is the average starting GPA?"
- This is a **BETWEEN-STUDENT** question
- Comparing Student 1's average vs Student 2's average vs Student 3's...
- **Effective N = 200** (number of students)
- Each student contributes ONE data point to this estimate

### OCCASION: "How much does GPA change per semester?"
- This is a **WITHIN-STUDENT** question
- Comparing each student to themselves over time
- **Effective N ≈ 1200** (all observations contribute)
- Each observation contributes to this estimate

---

## Why Standard Regression Gets It Wrong

### The Fatal Flaw: Treating 1200 Observations as Independent

Standard regression thinks:
```
SE_intercept = σ / sqrt(N_total)
             = 0.3487 / sqrt(1200)
             = 0.0101
```

But wait! Your output shows SE = 0.0178, not 0.0101. Why?

Because even standard regression is doing *something* more complex, but it's still wrong. The key issue: **standard regression uses N = 1200 for the degrees of freedom**, which inflates our confidence.

### The Reality: Observations Within Students are Correlated

The **Intraclass Correlation (ICC) = 0.52** tells us:
- Any two observations from the same student correlate at 0.52
- More than HALF the variance is between students
- Observations within students are NOT independent!

---

## Variance Decomposition: The Smoking Gun

Standard regression sees total variance:
```
Total SD = 0.3487
```

But this MIXES two sources:

Mixed model correctly separates:
```
Between students (τ): 0.2524  ← Student differences
Within students (σ):  0.2410  ← Measurement variation
```

Notice: **τ ≈ σ** → Student differences are as large as measurement error!

---

## Why the Intercept SE Increases

### What Standard Regression Thinks:
- "I have 1200 independent observations"
- "Each observation gives me information about the average GPA"
- "More data → smaller SE"
- **WRONG!**

### What Mixed Model Knows:
- "I have 200 students, each measured 6 times"
- "For the average starting GPA, each student gives me ONE piece of info"
- "The 6 observations per student are correlated (ICC = 0.52)"
- "Effective N for intercept ≈ 200, not 1200"

### The Math:
Mixed model accounts for clustering. A simplified formula:

```
SE_intercept ≈ sqrt(τ²/n + σ²/(n×m))

where:
  n = number of students = 200
  m = observations per student = 6
  τ² = between-student variance = 0.0637
  σ² = within-student variance = 0.0581

SE_intercept ≈ sqrt(0.0637/200 + 0.0581/(200×6))
            ≈ sqrt(0.000319 + 0.000048)
            ≈ sqrt(0.000367)
            ≈ 0.0192
```

(Close to actual 0.0217 - the exact formula is more complex)

Compare to naive: 0.3487 / sqrt(1200) = 0.0101 (too small!)

---

## Why the Occasion SE Decreases

This is the textbook's footnote [^sewithin] from [random_intercepts.Rmd:596](random_intercepts.Rmd#L596):

> "The standard error for our time covariate went down due to our estimate of σ being lower for this model, and there being no additional variance due to cluster membership."

### Key Points:

1. **Smaller residual variance:**
   - Standard regression: σ = 0.3487
   - Mixed model: σ = 0.2410 (31% smaller!)
   - Why? Removed the between-student variation (τ)

2. **Time varies WITHIN students:**
   - Each student experiences all 6 time points
   - This is within-student variation
   - We have full 1200 observations to estimate the time effect

3. **No random slope (yet):**
   - We only allowed random intercepts: `(1|student)`
   - Occasion effect is the SAME for all students (fixed effect)
   - So there's no additional "cluster membership" variance for occasion

---

## Visual Intuition

### Standard Regression View:
```
All 1200 points:  • • • • • • • • • • • • ... (treats as independent)
                  ↓
         Single pool of variation
```

### Mixed Model View:
```
Student 1:  • • • • • •  ← 6 correlated observations
Student 2:  • • • • • •  ← 6 correlated observations
Student 3:  • • • • • •  ← 6 correlated observations
   ...
Student 200: • • • • • • ← 6 correlated observations
            ↓
     200 independent clusters
     1200 total observations
```

For the intercept:
- We're comparing the HEIGHT of these 200 clusters
- N_effective = 200

For occasion (time):
- We're comparing the SLOPE within each cluster
- All 1200 observations contribute

---

## The Bottom Line

### Intercept SE Increases Because:
1. ✓ Recognizes N = 200 students, not 1200 observations
2. ✓ Accounts for correlation within students (ICC = 0.52)
3. ✓ Gives honest uncertainty about the population average
4. ✓ Standard regression was falsely confident

### Occasion SE Decreases Because:
1. ✓ Removes between-student variance from residual
2. ✓ σ drops from 0.3487 → 0.2410
3. ✓ Uses full N = 1200 for within-student effect
4. ✓ More precise estimate of time trend

---

## This is a GOOD Thing!

From [random_intercepts.Rmd:290](random_intercepts.Rmd#L290):

> "Conceptually you can think about allowing random intercepts per person allows us to gain information about the individual, while recognizing the uncertainty with regard to the overall average that we were underestimating before."

**Translation:**
- We learn about individual students (random effects)
- We're honest about uncertainty in population average (larger SE for intercept)
- We get more precise estimates of within-student effects (smaller SE for occasion)

**The mixed model is not being "worse" - it's being HONEST.**

---

## Practical Implications

### If you use standard regression with clustered data:

**For between-cluster effects (like intercept):**
- ✗ p-values too small (false positives!)
- ✗ Confidence intervals too narrow
- ✗ Overconfident conclusions

**For within-cluster effects:**
- ✗ Less efficient (larger SE than necessary)
- ✗ Mixing variance sources
- ✗ Missing the clustering structure

### Always use mixed models when you have:
- Repeated measures
- Students within schools
- Patients within hospitals
- Observations within groups
- Any clustered/hierarchical structure!

---

## Connection to Textbook Quote

The textbook says ([random_intercepts.Rmd:258](random_intercepts.Rmd#L258)):

> "A side effect of doing so [ignoring clustering] is that our standard errors are biased, and thus claims about statistical significance based on them would be off."

Now you know:
- **Intercept SE:** Biased DOWNWARD (too small) in standard regression
- **Within-cluster effects:** Could be biased either way
- **Solution:** Use mixed models!
