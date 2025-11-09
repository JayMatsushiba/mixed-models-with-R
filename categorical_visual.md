# Visual Guide: Categorical Random Effects

## The Building Blocks

### Fixed Effect: ses (3 levels)

```
Population Model:
achievement = β₀ + β₁(sesmid) + β₂(seshigh) + ε

For each student:
- If low SES:  achievement = 50 + 0 + 0 = 50
- If mid SES:  achievement = 50 + 5 + 0 = 55
- If high SES: achievement = 50 + 0 + 10 = 60
```

---

## Random Effect: Let SES vary by school

### Model: `achievement ~ ses + (1 + ses | school)`

```
For each school j:
achievement_ij = (β₀ + u₀j) + (β₁ + u₁j)(sesmid) + (β₂ + u₂j)(seshigh) + ε_ij

Where:
  u₀j = random intercept for school j
  u₁j = random slope for sesmid in school j
  u₂j = random slope for seshigh in school j
```

---

## Concrete Example: Three Schools

### School A (reduces SES gaps)
```
Fixed effects:      β₀=50, β₁=5, β₂=10
Random effects:     u₀=+5, u₁=-2, u₂=-3

Predictions:
  Low:  (50+5) = 55
  Mid:  55 + (5-2) = 58
  High: 55 + (10-3) = 62
  
Gap: high-low = 7 points (vs. 10 in population)
→ This school is equity-promoting!
```

### School B (amplifies SES gaps)
```
Fixed effects:      β₀=50, β₁=5, β₂=10
Random effects:     u₀=-3, u₁=+4, u₂=+8

Predictions:
  Low:  (50-3) = 47
  Mid:  47 + (5+4) = 56
  High: 47 + (10+8) = 65
  
Gap: high-low = 18 points (vs. 10 in population)
→ This school magnifies inequality
```

### School C (average)
```
Fixed effects:      β₀=50, β₁=5, β₂=10
Random effects:     u₀=0, u₁=0, u₂=0

Predictions:
  Low:  50
  Mid:  55
  High: 60
  
Gap: exactly at population average
```

---

## The Correlation Matrix

```
              Intercept  sesmid  seshigh
Intercept         1.00   -0.40    -0.35
sesmid           -0.40    1.00     0.80
seshigh          -0.35    0.80     1.00

Interpretation:
• Cor(intercept, sesmid) = -0.40
  Schools with higher baseline → smaller SES gaps
  
• Cor(sesmid, seshigh) = 0.80
  Schools with big mid-low gaps → also have big high-low gaps
  SES effects are consistent
```

---

## Why This Gets Complex

### Parameter Count

For k categories:

| Categories | Random Effects | Variances | Correlations | Total Parameters |
|-----------|---------------|-----------|--------------|-----------------|
| 2         | 2             | 2         | 1            | 3               |
| 3         | 3             | 3         | 3            | 6               |
| 4         | 4             | 4         | 6            | 10              |
| 5         | 5             | 5         | 10           | 15              |

Formula: k variances + k(k-1)/2 correlations

---

## The Alternative: Interaction Approach

Instead of: `(1 + ses | school)`

Use: `(1 | school) + (1 | school:ses)`

```
This creates:
  Random effect for: school 1
  Random effect for: school 1:low
  Random effect for: school 1:mid  
  Random effect for: school 1:high
  Random effect for: school 2
  Random effect for: school 2:low
  ...

No correlations estimated → simpler, more stable
```

---

## Key Takeaway

**The statement means**: When you make a categorical variable random, you're not just adding ONE random slope (like with a continuous variable). You're adding k-1 random slopes (one for each non-reference category), PLUS all their correlations with each other and the intercept.

This is why it "complicates our model" and can lead to "convergence problems"!

