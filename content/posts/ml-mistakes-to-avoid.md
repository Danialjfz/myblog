---
title: "5 ML Mistakes I Made So You Don't Have To"
date: 2025-11-19
draft: false
description: "Machine learning tutorials make everything look smooth and polished. Reality is messier. Here are the painful lessons I learned the hard way, complete with the mistakes, the debugging nightmares, and what actually fixed them."
keywords: ["machine learning mistakes", "ML debugging", "data science errors", "overfitting", "data leakage", "ML best practices", "AI pitfalls"]
tags: ["machine-learning", "best-practices", "lessons-learned", "debugging"]
categories: ["AI/ML", "Tutorials"]
sitemap:
  priority: 0.8
---

Machine Learning tutorials are all lies.

Okay not really, but they make everything look so smooth. Load data, build model, train, boom—95% accuracy! Ship it!

Nobody shows you the part where you get 99% accuracy in training and then deploy it and it's complete garbage. Or when you spend three entire days trying to figure out why your experiments aren't reproducible and you're slowly losing your mind. Or that moment when you realize you've been cheating the whole time and all your results are meaningless.

I've done all of these. Multiple times. Some of these mistakes cost me hours. Some cost me days. One of them cost me a presentation where I had to stand in front of people and explain why my "working" model was actually completely broken.

So here are my greatest hits of ML failure. Learn from my pain.

## Mistake #1: Not Checking Your Data First

**The mistake**: Jumping straight into building your model without actually looking at the data first.

**How I learned this**: So there I was, two days into debugging this image classifier that was performing like absolute trash. I tried everything. Different architectures. Different learning rates. Different optimizers. Batch normalization. Dropout. More layers. Fewer layers. I was grasping at straws.

Finally, at like 11pm on day two, completely out of ideas, I did something I should've done on day zero: I actually looked at the images.

About 30% of them were just... black. Completely black. Empty.

My data loading script had been failing silently on certain files and just returning arrays of zeros. And I'd been trying to train a model on this garbage for two days. The model was actually doing pretty well considering it was trying to learn patterns from random noise and black squares.

**What to actually do**:

Look. At. Your. Data. First.

Before you even think about models:

```python
# Load your data
import pandas as pd
df = pd.read_csv('data.csv')

# Actually look at it
print(df.head(20))  # Not just 5 rows—check more
print(df.describe())  # Statistics for each column
print(df.isnull().sum())  # Missing values?

# Check distributions
import matplotlib.pyplot as plt
df.hist(figsize=(12, 10))
plt.show()

# For images: plot a batch
for i in range(16):
    plt.subplot(4, 4, i+1)
    plt.imshow(images[i])
plt.show()
```

I know, I know, you want to jump straight to the fun part. But trust me, spending 10 minutes looking at your data will save you literal days of debugging later.

**Stuff to watch out for**:
- Missing values where you weren't expecting them
- Completely insane outliers (people aged 250 years, prices of -$500)
- Severe class imbalance (10,000 examples of "normal", 5 examples of "fraud")
- Corrupted or unparseable files that got loaded as garbage
- Data that just... doesn't look right

If something looks weird, it probably is. Fix it now, not after three days of failed training runs.

## Mistake #2: Data Leakage (The Silent Killer)

**The mistake**: Including information in your training data that you won't have when you actually need to make predictions.

**My story**: I built a customer churn prediction model. Got 94% accuracy in cross-validation. I was SO proud. Showed it to my team. They were impressed. Deployed it. Disaster.

In production it performed at basically random chance. Like flipping a coin. What the hell happened?

Took me way too long to figure it out, but eventually I found the problem: I'd included a feature called "days_since_last_login."

Seems reasonable, right? Except... for customers who HAD churned, this number was always huge. Because they'd stopped using the service. The model learned "oh, if days_since_last_login is high, they definitely churned." Which is... technically correct, but also completely useless.

When you're trying to predict if someone WILL churn, you can't use information that only exists AFTER they churn. That's not a prediction. That's just reading the answer key.

**How to not do this**:

For every single feature, ask: "Will I actually have this information at prediction time?"

If the answer is no, or even "maybe not," get rid of it.

Ways people accidentally cheat:
- Using the target (or something that's basically the target) as a feature
- Using information from the future
- Using stuff that only exists after the thing you're trying to predict

This is insidious because your model will look amazing in training and then completely fall apart in production. Your metrics will all look great right up until they don't.

```python
# WRONG: Using information from test set
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)  # This looks at ALL the data!
# Then you split into train/test... but you already cheated

# CORRECT: Only learn from training data
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)  # Just transform, don't refit
```

The test set is supposed to simulate future data you haven't seen. Any operation that looks at the test set is cheating.

## Mistake #3: Not Having a Proper Train/Val/Test Split

**The mistake**: Not having proper data splits, or (worse) checking your test set over and over.

**What I used to do**: Train model. Check test set. "Hmm, only 82%, not good enough." Tweak something. Check test set again. "83%, better but not quite..." Tweak more. Check again. Again. Again.

Seemed fine at the time.

But here's the problem: every time you look at the test set and make a decision based on it, you're kind of... training on it. Not directly, but you're using that information to guide what you do next.

After checking the test set 30 times and making changes based on what you see, your model isn't evaluated on truly unseen data anymore. It's optimized for that specific test set. And then you deploy it and find out your "95% accuracy" was a lie.

**What to do instead**:

You need three sets:

```python
from sklearn.model_selection import train_test_split

# First split: separate out test set
X_temp, X_test, y_temp, y_test = train_test_split(
    X, y, test_size=0.15, random_state=42
)

# Second split: create train and validation sets
X_train, X_val, y_train, y_val = train_test_split(
    X_temp, y_temp, test_size=0.176, random_state=42  # ~15% of total
)

# Now you have: 70% train, 15% validation, 15% test
```

**The actual rules**:
- **Training set**: Train your model on this
- **Validation set**: Check this as much as you want while developing
- **Test set**: Look at this ONCE at the very end. Then never again.

Think of it like school. Training set = your textbook. Validation set = practice problems. Test set = the actual final exam.

You don't study from the final exam. That's cheating. Same idea here. The test set is supposed to tell you how well you'll do on real data you've never seen. If you've already seen it 50 times, it's not really "unseen" anymore.

## Mistake #4: Ignoring Class Imbalance

**The mistake**: Training on imbalanced classes and celebrating your 99% accuracy.

**Story time**: Built a fraud detection model. Got 99.5% accuracy! I was pumped. This was going to save the company so much money. Deployed it on Friday afternoon feeling like a rockstar.

Monday morning: "Hey, uh, your model isn't detecting any fraud. Like, at all. It just says everything is fine."

Shit.

Went back and checked. The model had learned a very clever strategy: just predict "not fraud" for everything. Since only 0.3% of transactions were actually fraudulent, this lazy approach was correct 99.7% of the time.

The model basically went "detecting fraud is hard and I'm rarely right when I try, but if I just say 'looks good!' every time, I'll be correct 99% of the time and everyone will think I'm doing great."

It technically had high accuracy. It was also completely useless.

**What to actually do**:

When your classes are imbalanced (which they almost always are in real problems), accuracy is a trap. Use literally anything else:

```python
from sklearn.metrics import classification_report, confusion_matrix

# Get predictions
y_pred = model.predict(X_test)

# Much better than just accuracy
print(classification_report(y_test, y_pred))

# See exactly where you're failing
print(confusion_matrix(y_test, y_pred))
```

**Strategies for imbalanced data**:

1. **Resampling**: Oversample the minority class or undersample the majority
2. **Class weights**: Tell your model to care more about minority class errors
3. **Different metrics**: Use F1-score, precision, recall, or AUC-ROC
4. **Ensemble methods**: Random forests and XGBoost handle imbalance better

```python
# Example: Using class weights in PyTorch
from torch import nn
import torch

# If class 0 has 1000 examples and class 1 has 100
pos_weight = torch.tensor([1000.0 / 100.0])
criterion = nn.BCEWithLogitsLoss(pos_weight=pos_weight)
```

## Mistake #5: Not Setting Random Seeds

**The mistake**: Not setting random seeds and then going crazy trying to figure out why your results keep changing.

**My descent into madness**: Got amazing results in my notebook one day. 94% accuracy! Wrote it all up in my report with nice tables and everything.

Next day, tried to verify the results before sharing. Ran the same notebook. 89% accuracy. Wait, what?

Ran it again. 91%.

Again. 87%.

Spent the next hour convinced I'd somehow introduced a bug. Checked git diffs. Nothing changed. Restarted kernel. Cleared outputs. Prayed to various deities.

Finally realized: I just... hadn't set any random seeds. The data split was random. The weight initialization was random. Every single run was completely different.

I'd just gotten lucky on that first run and written a whole report about it like those were the real numbers. Whoops.

**Fix it**:

Set your damn random seeds. Not just for other people. For your own sanity.

```python
import random
import numpy as np
import torch

def set_seed(seed=42):
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    # For full reproducibility (slower but deterministic)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False

# Call this at the start of your script
set_seed(42)
```

Also set seeds in specific operations:

```python
# In sklearn
train_test_split(X, y, random_state=42)

# In PyTorch DataLoader
DataLoader(dataset, shuffle=True, generator=torch.Generator().manual_seed(42))
```

Yeah, it's a few extra lines. But the alternative is spending hours debugging problems that aren't actually problems, they're just randomness. Not worth it.

## Bonus Round: Overfitting (And Not Even Noticing)

This one is so common I have to mention it.

Training accuracy: 99%
Validation accuracy: 85%

You: "Pretty good!"

Me: "That's overfitting, my friend."

Your model didn't learn patterns. It memorized the training data. It's like a student who memorized all the practice problems but doesn't actually understand the concepts. Works great on homework, bombs the test.

**Signs of overfitting**:
- Training accuracy much higher than validation accuracy
- Training loss keeps decreasing but validation loss starts increasing
- Model performs great on training data, terrible on anything else

**Quick fixes**:
- Add dropout layers
- Use L2 regularization (weight decay)
- Collect more data
- Use data augmentation
- Early stopping (stop training when validation loss stops improving)

```python
# Example: Adding dropout in PyTorch
class BetterNet(nn.Module):
    def __init__(self):
        super().__init__()
        self.layer1 = nn.Linear(784, 128)
        self.dropout1 = nn.Dropout(0.3)  # Drop 30% of neurons
        self.layer2 = nn.Linear(128, 64)
        self.dropout2 = nn.Dropout(0.3)
        self.layer3 = nn.Linear(64, 10)

    def forward(self, x):
        x = torch.relu(self.layer1(x))
        x = self.dropout1(x)
        x = torch.relu(self.layer2(x))
        x = self.dropout2(x)
        x = self.layer3(x)
        return x
```

## The Pattern

Here's what all these mistakes have in common: they're silent.

Your code runs fine. Your model trains. You get numbers. The numbers look good. Everything seems great.

And then you deploy it and it's a disaster. Or you try to reproduce it and can't. Or you present to stakeholders and someone asks one question that makes your entire analysis fall apart.

The scary part is that you can make all of these mistakes and not know until it's too late. That's what makes them so dangerous.

The solution isn't "be more careful" or "be smarter." It's to build these checks into your workflow automatically:
- Look at your data first, always
- Set random seeds by default
- Use train/val/test splits correctly
- Check multiple metrics
- Question your features

These aren't best practices. They're the bare minimum for not shooting yourself in the foot.

## What I Do Now (That Actually Works)

My current workflow has all these checks baked in:

1. Load data
2. Actually look at the data (histograms, sample images, whatever)
3. Set random seed at the top of the file
4. Split into train/val/test properly
5. Check class distribution
6. Pick metrics that make sense (not just accuracy)
7. Train a simple baseline
8. Check for data leakage
9. Monitor train vs validation metrics
10. Only at the very end: check test set ONCE

It feels like more work upfront. It's not. It's way less work than debugging for three days because you skipped step 2 and didn't notice your data was garbage.

Plus, you know, your models actually work. Which is kind of the point.

---

*Got your own horror stories? I'd love to hear them. Bonus points if they're worse than mine.*
