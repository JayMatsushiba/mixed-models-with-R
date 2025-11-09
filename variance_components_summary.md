# Variance Components: Complete Guide

## What Are Variance Components?

Variance components are the **sources of variation** in your outcome variable. Mixed models let you **decompose** total variance into meaningful pieces.

### Standard Regression (Lumps Everything Together)
```
Total Variance = Residual Variance (σ²) = 0.1216

One big bucket of "unexplained variance"
```

### Mixed Model (Separates Sources)
```
Total Variance = Between-Group (τ²) + Within-Group (σ²)
               = 0.0637        +        0.0581       = 0.1218

Two buckets:
  1. Differences BETWEEN students (who you are)
  2. Variation WITHIN students (fluctuation)
```

---

## The Two Key Components (GPA Example)

### τ (tau) = Between-Student Standard Deviation = 0.252

**What it means:**
- "How much do students differ in their baseline GPA?"
- If you pick two random students, they differ by ~0.25 GPA points on average
- Some students are consistently 0.25 points above average
- Others are consistently 0.25 points below average

**From textbook ([random_intercepts.Rmd:308](random_intercepts.Rmd#L308)):**
> "This tells us how much, on average, GPA bounces around as we move from student to student... each student has their own unique deviation."

**Practical example:**
- Student A: Always scores around 3.2 GPA
- Student B: Always scores around 2.7 GPA
- τ captures this stable difference (0.5 apart)

---

### σ (sigma) = Within-Student Standard Deviation = 0.241

**What it means:**
- "How much does a student vary around THEIR OWN average?"
- Even after knowing Student A averages 3.2, their GPA varies by ~0.24
- This includes: measurement error, random fluctuation, unmeasured factors

**Practical example:**
- Student A's 6 GPAs: 3.0, 3.2, 3.3, 3.1, 3.4, 3.2
- Average = 3.2, but bounces around
- σ captures this within-person variation

---

## Comparing the Components

```
Between-Student (τ): 0.252
Within-Student (σ):  0.241

Ratio: τ/σ = 1.05
```

**Interpretation:**
- τ ≈ σ means both sources are roughly equal
- Student identity matters about as much as within-person fluctuation
- Actually, τ is slightly LARGER, meaning "who you are" matters more!

**Context (from textbook):**
> "Note that scores move due to the student more than double what they move based on a semester change."

- Occasion effect = 0.106 per semester
- Over 5 semesters = 0.53 total change
- Student differences (τ = 0.25) are half this size but persistent!

---

## The Intraclass Correlation (ICC)

### Formula
```
ICC = τ² / (τ² + σ²)
    = 0.0637 / (0.0637 + 0.0581)
    = 0.0637 / 0.1218
    = 0.523
```

### Three Ways to Interpret ICC = 0.52

#### 1. Variance Decomposition
```
52.3% of total variance is BETWEEN students
47.7% of total variance is WITHIN students
```

**Visual:**
```
Total GPA Variance
        |
    ┌───┴───┐
52% │       │ 48%
Between   Within
Students  Student
```

#### 2. Correlation
**ICC = 0.52 means:** Any two observations from the same student correlate at r = 0.52

**Practical meaning:**
- You measure Student A's GPA in semester 1: 3.2
- Correlation of 0.52 means semester 2 GPA is probably also around 3.2
- High ICC = strong predictability within student

#### 3. Clustering Strength

| ICC Range | Interpretation | Action |
|-----------|----------------|--------|
| < 0.05 | Weak clustering | Maybe don't need mixed model |
| 0.05-0.15 | Moderate clustering | Consider mixed model |
| > 0.15 | Strong clustering | **Definitely use mixed model!** |

**This data: ICC = 0.52 → VERY STRONG clustering!**

---

## Individual Random Effects

Variance components (τ, σ) describe the **distribution**.
But we can also extract **individual estimates** for each student!

### Model Equation
```
GPA_ij = (β₀ + u_i) + β₁ × occasion_ij + ε_ij

Where:
  β₀ = overall intercept (2.599)
  u_i = random effect for student i ~ N(0, τ)
  β₁ = occasion effect (0.106)
  ε_ij = residual error ~ N(0, σ)
```

### Example Students

| Student | Random Effect (u_i) | Student Intercept | Interpretation |
|---------|-------------------|-------------------|----------------|
| 1 | -0.071 | 2.528 | 0.07 below average |
| 2 | -0.216 | 2.384 | 0.22 below average |
| 3 | +0.088 | 2.688 | 0.09 above average |
| 8 | +0.219 | 2.818 | 0.22 above average |

**How to read:**
- Random Effect: Deviation from population average
- Student Intercept: 2.599 (overall) + random effect
- These are **predictions** for each student's baseline

### Distribution of Random Effects

```
Summary Statistics (200 students):
  Mean:    0.00   (by assumption)
  SD:      0.24   (close to τ = 0.25)
  Min:    -0.53   (lowest student)
  Max:    +0.77   (highest student)
  Range:   1.30   (huge difference!)
```

**From textbook ([random_intercepts.Rmd:148](random_intercepts.Rmd#L148)):**
> "student_effect ~ N(0, τ)"

**Visual:**
```
       Frequency
          |
       ** |                  Normal Distribution
      **** |                 Mean = 0
     ****** |                SD = τ = 0.25
    ******** |
   ********** |
  ************|________________________
 -0.5    0.0   +0.5   +1.0
     Random Effects
```

Most students are near 0 (average), with some notably high/low.

---

## Why Variance Components Matter

### 1. Understanding Your Data

**Question:** What drives variation in GPA?

**Answer from variance components:**
- 52% is stable differences between students (ability, background)
- 48% is fluctuation within students (effort, luck, measurement error)

**Actionable insight:**
- Interventions targeting individual students (tutoring) could address 52%
- Interventions reducing variability (consistent teaching) could address 48%

### 2. Correct Standard Errors

**Impact on inference:**
- Standard regression: SE(intercept) = 0.0178 (too small!)
- Mixed model: SE(intercept) = 0.0217 (honest!)
- Why? Mixed model recognizes N_effective = 200 students, not 1200 obs

### 3. Individual Predictions

**Population-level prediction (ignore random effects):**
```r
predict(model, re.form = NA)
→ GPA = 2.60 + 0.106 × occasion
→ Same for everyone
```

**Individual prediction (include random effects):**
```r
predict(model)
→ Student 1: GPA = 2.53 + 0.106 × occasion
→ Student 2: GPA = 2.38 + 0.106 × occasion
→ Student 8: GPA = 2.82 + 0.106 × occasion
→ Different intercepts!
```

**This is powerful:** You can make **personalized predictions** for each student!

### 4. Identifying Unusual Groups

**Students with large |random effect|:**

| Student | Random Effect | Status |
|---------|--------------|--------|
| 183 | +0.768 | Top performer (investigate why!) |
| 97 | -0.534 | Struggling (may need help) |

**Use cases:**
- Quality control (which schools/hospitals are outliers?)
- Intervention targeting (who needs extra support?)
- Success analysis (what makes high performers different?)

### 5. Model Justification

**Decision rule:**
- If τ ≈ 0 → Maybe don't need mixed model (little clustering)
- If τ >> 0 → Definitely need mixed model!

**This data:**
```
τ = 0.252 >> 0
CI: [0.22, 0.29] (clearly doesn't include 0)
→ Strong evidence for student effects
→ Mixed model is justified
```

---

## Visual Summary

### Variance Decomposition

```
                 TOTAL VARIANCE IN GPA
                      (σ² = 0.122)
                           |
          ┌────────────────┴─────────────────┐
          |                                  |
   BETWEEN STUDENTS                  WITHIN STUDENTS
   τ² = 0.064 (52%)                  σ² = 0.058 (48%)
          |                                  |
   ┌──────┴──────┐                   Measurement error
   |             |                    Daily fluctuation
Student 1: -0.07 |                   Unmeasured factors
Student 2: -0.22 |
Student 3: +0.09 |
   ...           |
Student 200      |
```

### How Students Differ

```
GPA over Time (6 semesters)

 4.0 ┤                    Student 8 (high performer)
     │                   ╱╱╱╱╱╱╱╱
 3.5 ┤                 ╱╱
     │              ╱╱          Average (fixed effect)
 3.0 ┤            ╱          ─────────────
     │          ╱        ─────
 2.5 ┤        ╱      ─────
     │      ╱    ─────
 2.0 ┤    ╱ ─────               Student 2 (low performer)
     └─────┬─────┬─────┬─────┬─────┬─────
           0     1     2     3     4     5
                    Semester

Key insight:
- All have same SLOPE (occasion effect = 0.106)
- Different INTERCEPTS (random effects)
- Student 8 starts ~0.4 points higher than Student 2!
```

---

## Formulas and Notation Summary

### Variance Components

| Symbol | Name | Value | Meaning |
|--------|------|-------|---------|
| τ | Between-group SD | 0.252 | How much groups differ |
| τ² | Between-group variance | 0.064 | Variance between groups |
| σ | Within-group SD | 0.241 | Variation within groups |
| σ² | Within-group variance | 0.058 | Residual variance |
| ICC | Intraclass correlation | 0.52 | % variance between groups |

### Model Formulation

**Level 1 (observation level):**
```
GPA_ij = β₀_i + β₁ × occasion_ij + ε_ij
```

**Level 2 (student level):**
```
β₀_i = β₀ + u_i
```

**Combined:**
```
GPA_ij = (β₀ + u_i) + β₁ × occasion_ij + ε_ij

Where:
  u_i ~ N(0, τ²)   [random effect]
  ε_ij ~ N(0, σ²)  [residual]
```

---

## Common Questions

### Q: Why is my τ close to σ?

**Answer:** This means between-group and within-group variation are similar in magnitude.

In the GPA data:
- τ = 0.252 (between students)
- σ = 0.241 (within students)
- τ/σ = 1.05 → roughly equal

**Interpretation:** Student identity matters about as much as random fluctuation.

### Q: What if τ is much larger than σ?

**Example:** School effects on test scores might have τ = 0.8, σ = 0.3

**Interpretation:**
- Most variation is BETWEEN schools (ICC ≈ 0.88)
- Within-school variation is small
- School identity is extremely important
- Strong clustering → definitely need mixed model!

### Q: What if τ is much smaller than σ?

**Example:** τ = 0.05, σ = 0.4 (ICC = 0.015)

**Interpretation:**
- Most variation is WITHIN groups
- Between-group differences are tiny
- Weak clustering → maybe don't need mixed model
- But still good to check!

### Q: Can I compare variance components across studies?

**Be careful!**
- τ and σ are in the units of your outcome
- Different outcomes = different scales
- **ICC is scale-free** → better for comparisons

**Example:**
- Study 1: GPA (0-4 scale), ICC = 0.52
- Study 2: Test scores (0-100 scale), ICC = 0.48
- Can compare ICCs directly!

---

## Connection to Standard Regression

### What Standard Regression Sees

```r
lm(gpa ~ occasion)

Residual SD = 0.349

This MIXES τ and σ:
  √(τ² + σ²) = √(0.064 + 0.058) = √0.122 = 0.349
```

**Problem:** Can't tell them apart!

### What Mixed Model Sees

```r
lmer(gpa ~ occasion + (1|student))

Student SD (τ) = 0.252
Residual SD (σ) = 0.241

This SEPARATES them!
```

**Benefit:** Understand data structure!

---

## Key Takeaways

### 1. Variance components decompose total variance
```
Total = Between (τ²) + Within (σ²)
```

### 2. τ tells you about GROUP differences
- How much do students/schools/hospitals differ?
- GPA example: τ = 0.252 (moderate differences)

### 3. σ tells you about RESIDUAL variation
- How much fluctuation remains?
- GPA example: σ = 0.241 (similar to τ)

### 4. ICC combines them into % between-group
```
ICC = τ² / (τ² + σ²) = 0.52
→ 52% of variance is between students
```

### 5. This is UNIQUE to mixed models

**From textbook ([random_intercepts.Rmd:308](random_intercepts.Rmd#L308)):**
> "This is an important interpretive aspect not available to us with a standard regression model."

### 6. Use them for:
- ✓ Understanding your data
- ✓ Justifying mixed models
- ✓ Individual predictions
- ✓ Identifying outliers
- ✓ Correct inference

---

## R Code Quick Reference

```r
library(lme4)

# Fit model
model = lmer(outcome ~ predictor + (1|group), data = data)

# Get variance components
VarCorr(model)

# Extract values
vc = as.data.frame(VarCorr(model))
tau = vc$sdcor[1]      # Between-group SD
sigma = vc$sdcor[2]    # Within-group SD

# Calculate ICC
tau_sq = vc$vcov[1]
sigma_sq = vc$vcov[2]
icc = tau_sq / (tau_sq + sigma_sq)

# Get individual random effects
ranef(model)$group     # Random effects (u_i)
coef(model)$group      # Random intercepts (β₀ + u_i)

# Confidence intervals
confint(model, method = 'profile')  # Accurate but slow
confint(model, method = 'Wald')     # Fast approximation
```

---

## Further Reading

From the textbook:
- [Random Intercepts Model](random_intercepts.Rmd#L306-L310) - Variance components section
- [Random Slopes Model](random_slopes.Rmd) - When slopes also vary
- [Issues: Sample Sizes](issues.Rmd#L48-L59) - How many groups needed?
- [Supplemental](supplemental.Rmd) - Connection to latent variables

Key concept: Variance components let you understand **where variation comes from**, which is impossible with standard regression!
