---
title: "Build Your First ML Model: A No-BS Guide"
date: 2025-11-18
draft: false
description: "Forget toy examples with perfect data. Let's build a real ML model from scratch—complete with messy data, actual decisions you'll have to make, and code that you can run today. This is what building ML actually looks like."
keywords: ["machine learning tutorial", "build ML model", "first ML project", "PyTorch tutorial", "image classification", "practical machine learning", "ML for beginners"]
tags: ["machine-learning", "tutorial", "hands-on", "pytorch", "beginner-friendly"]
categories: ["AI/ML", "Tutorials"]
sitemap:
  priority: 0.8
---

Most ML tutorials start with MNIST (handwritten digits) or some perfectly cleaned dataset. That's fine for learning, but it doesn't teach you what building a real model actually feels like. Real projects have messy data, unclear requirements, and a dozen decisions you have to make without clear "right" answers.

So let's build something real: a model that can classify images of different types of vehicles. We'll use a subset of real data, deal with actual problems that come up, and make real decisions along the way.

By the end, you'll have a working model and—more importantly—you'll understand the process of building one.

## What You'll Need

Before we start, make sure you have:

```bash
pip install torch torchvision numpy matplotlib pillow scikit-learn
```

And a basic understanding of Python. You don't need to be an expert, but you should be comfortable with functions, loops, and basic concepts.

## Step 1: Get Some Data

We'll use the CIFAR-10 dataset, which has 60,000 small images across 10 categories: airplanes, cars, birds, cats, deer, dogs, frogs, horses, ships, and trucks.

Why CIFAR-10? Because it's:
- Real images (not synthetic)
- Small enough to train quickly (even without a GPU)
- Complex enough to be interesting
- Already cleaned (we'll mess it up ourselves for realism)

```python
import torch
import torchvision
import torchvision.transforms as transforms
import matplotlib.pyplot as plt
import numpy as np

# Download the data
transform = transforms.Compose([
    transforms.ToTensor(),  # Convert images to tensors
    transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))  # Normalize
])

trainset = torchvision.datasets.CIFAR10(
    root='./data',
    train=True,
    download=True,
    transform=transform
)

testset = torchvision.datasets.CIFAR10(
    root='./data',
    train=False,
    download=True,
    transform=transform
)
```

First decision: Why normalize the images? Because neural networks train better when inputs are roughly centered around zero. The `(0.5, 0.5, 0.5)` values are the mean and standard deviation for each color channel. This transformation maps pixel values from [0, 1] to approximately [-1, 1].

## Step 2: Actually Look at Your Data

This seems obvious, but I can't count how many times I've seen people skip this step.

```python
classes = ('plane', 'car', 'bird', 'cat', 'deer',
           'dog', 'frog', 'horse', 'ship', 'truck')

# Function to show an image
def imshow(img):
    img = img / 2 + 0.5  # Unnormalize
    npimg = img.numpy()
    plt.imshow(np.transpose(npimg, (1, 2, 0)))
    plt.show()

# Get some random training images
dataloader = torch.utils.data.DataLoader(
    trainset, batch_size=16, shuffle=True
)
dataiter = iter(dataloader)
images, labels = next(dataiter)

# Show images
imshow(torchvision.utils.make_grid(images))
print('Labels:', ' '.join(f'{classes[labels[j]]}' for j in range(16)))
```

Look at those images. Are they what you expected? Are any corrupted? This is your sanity check.

## Step 3: Split Your Data Properly

CIFAR-10 comes pre-split into train and test sets, but we need a validation set too.

```python
from torch.utils.data import random_split

# Split training data into train and validation
train_size = int(0.85 * len(trainset))
val_size = len(trainset) - train_size

train_dataset, val_dataset = random_split(
    trainset,
    [train_size, val_size],
    generator=torch.Generator().manual_seed(42)  # Reproducibility!
)

# Create data loaders
trainloader = torch.utils.data.DataLoader(
    train_dataset, batch_size=64, shuffle=True, num_workers=2
)
valloader = torch.utils.data.DataLoader(
    val_dataset, batch_size=64, shuffle=False, num_workers=2
)
testloader = torch.utils.data.DataLoader(
    testset, batch_size=64, shuffle=False, num_workers=2
)

print(f'Training samples: {len(train_dataset)}')
print(f'Validation samples: {len(val_dataset)}')
print(f'Test samples: {len(testset)}')
```

Second decision: Why batch_size=64? It's a balance. Larger batches train faster but use more memory. Smaller batches can sometimes generalize better. 64 is a reasonable default.

## Step 4: Define Your Model

Let's build a simple CNN (Convolutional Neural Network). CNNs are the standard for image tasks because they're designed to recognize spatial patterns.

```python
import torch.nn as nn
import torch.nn.functional as F

class SimpleCNN(nn.Module):
    def __init__(self):
        super(SimpleCNN, self).__init__()
        # Convolutional layers
        self.conv1 = nn.Conv2d(3, 32, 3, padding=1)  # 3 input channels (RGB), 32 output
        self.conv2 = nn.Conv2d(32, 64, 3, padding=1)
        self.conv3 = nn.Conv2d(64, 128, 3, padding=1)

        # Pooling layer
        self.pool = nn.MaxPool2d(2, 2)

        # Fully connected layers
        self.fc1 = nn.Linear(128 * 4 * 4, 512)
        self.fc2 = nn.Linear(512, 10)  # 10 classes

        # Dropout for regularization
        self.dropout = nn.Dropout(0.3)

    def forward(self, x):
        # Conv block 1
        x = self.pool(F.relu(self.conv1(x)))  # 32x32 -> 16x16
        # Conv block 2
        x = self.pool(F.relu(self.conv2(x)))  # 16x16 -> 8x8
        # Conv block 3
        x = self.pool(F.relu(self.conv3(x)))  # 8x8 -> 4x4

        # Flatten
        x = x.view(-1, 128 * 4 * 4)

        # Fully connected layers
        x = self.dropout(F.relu(self.fc1(x)))
        x = self.fc2(x)
        return x

model = SimpleCNN()
print(model)
```

This architecture is simple but effective:
- **Conv layers** extract features (edges, shapes, patterns)
- **Pooling** reduces spatial dimensions
- **Dropout** prevents overfitting
- **Fully connected layers** make the final classification

Third decision: Why 3 conv layers? Honestly? It's a starting point. You might need more for complex tasks or fewer for simple ones. This is where experimentation comes in.

## Step 5: Training Setup

Now we need to define how the model will learn.

```python
import torch.optim as optim

# Move model to GPU if available
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
model = model.to(device)
print(f'Training on: {device}')

# Loss function and optimizer
criterion = nn.CrossEntropyLoss()  # Standard for classification
optimizer = optim.Adam(model.parameters(), lr=0.001)  # Adam is a good default

# Learning rate scheduler (optional but helpful)
scheduler = optim.lr_scheduler.ReduceLROnPlateau(
    optimizer, mode='min', factor=0.5, patience=3, verbose=True
)
```

Fourth decision: Why Adam optimizer? It's generally more forgiving than SGD and requires less hyperparameter tuning. The learning rate of 0.001 is a standard starting point.

## Step 6: The Training Loop

Here's where the actual learning happens:

```python
def train_model(model, trainloader, valloader, epochs=20):
    best_val_loss = float('inf')
    train_losses = []
    val_losses = []

    for epoch in range(epochs):
        # Training phase
        model.train()
        running_loss = 0.0

        for i, (inputs, labels) in enumerate(trainloader):
            inputs, labels = inputs.to(device), labels.to(device)

            # Zero the gradients
            optimizer.zero_grad()

            # Forward pass
            outputs = model(inputs)
            loss = criterion(outputs, labels)

            # Backward pass
            loss.backward()
            optimizer.step()

            running_loss += loss.item()

            # Print progress every 100 batches
            if i % 100 == 99:
                print(f'[Epoch {epoch+1}, Batch {i+1}] loss: {running_loss/100:.3f}')
                running_loss = 0.0

        # Validation phase
        model.eval()
        val_loss = 0.0
        correct = 0
        total = 0

        with torch.no_grad():
            for inputs, labels in valloader:
                inputs, labels = inputs.to(device), labels.to(device)
                outputs = model(inputs)
                loss = criterion(outputs, labels)
                val_loss += loss.item()

                _, predicted = torch.max(outputs.data, 1)
                total += labels.size(0)
                correct += (predicted == labels).sum().item()

        val_loss = val_loss / len(valloader)
        val_acc = 100 * correct / total

        print(f'Epoch {epoch+1}: Val Loss: {val_loss:.3f}, Val Acc: {val_acc:.2f}%')

        # Save best model
        if val_loss < best_val_loss:
            best_val_loss = val_loss
            torch.save(model.state_dict(), 'best_model.pth')
            print('Saved new best model!')

        # Adjust learning rate
        scheduler.step(val_loss)

        train_losses.append(running_loss)
        val_losses.append(val_loss)

    return train_losses, val_losses

# Train the model
train_losses, val_losses = train_model(model, trainloader, valloader, epochs=20)
```

This is a lot of code, but here's what it does:
1. Loop through epochs
2. For each epoch, loop through training batches
3. Make predictions, calculate loss, update weights
4. After each epoch, check validation performance
5. Save the model if it's the best so far

## Step 7: Evaluate on Test Set

Only after training is completely done do we check the test set:

```python
# Load the best model
model.load_state_dict(torch.load('best_model.pth'))
model.eval()

correct = 0
total = 0
class_correct = [0] * 10
class_total = [0] * 10

with torch.no_grad():
    for inputs, labels in testloader:
        inputs, labels = inputs.to(device), labels.to(device)
        outputs = model(inputs)
        _, predicted = torch.max(outputs, 1)

        total += labels.size(0)
        correct += (predicted == labels).sum().item()

        # Per-class accuracy
        for i in range(len(labels)):
            label = labels[i]
            class_correct[label] += (predicted[i] == label).item()
            class_total[label] += 1

print(f'Overall Test Accuracy: {100 * correct / total:.2f}%')
print('\nPer-class accuracy:')
for i in range(10):
    acc = 100 * class_correct[i] / class_total[i]
    print(f'{classes[i]}: {acc:.2f}%')
```

If you've followed along, you should get around 70-75% accuracy. That's pretty good for a simple model!

## Step 8: See Where It Fails

Let's look at some mistakes:

```python
def show_predictions(model, dataloader, num_images=8):
    model.eval()
    images, labels = next(iter(dataloader))
    images, labels = images.to(device), labels.to(device)

    outputs = model(images)
    _, predicted = torch.max(outputs, 1)

    # Find some mistakes
    mistakes = (predicted != labels).nonzero(as_tuple=True)[0]

    if len(mistakes) > 0:
        plt.figure(figsize=(15, 3))
        for idx, i in enumerate(mistakes[:num_images]):
            plt.subplot(1, num_images, idx+1)
            img = images[i].cpu()
            img = img / 2 + 0.5
            plt.imshow(np.transpose(img, (1, 2, 0)))
            plt.title(f'True: {classes[labels[i]]}\nPred: {classes[predicted[i]]}')
            plt.axis('off')
        plt.show()

show_predictions(model, testloader)
```

This shows you where the model is confused. Often you'll find it confuses cats and dogs, or trucks and cars—mistakes that make sense.

## What's Next?

You've just built a working image classifier. It's not state-of-the-art, but it's real.

**Ways to improve it**:
- Add more conv layers
- Use data augmentation (flip, rotate images)
- Try transfer learning with pretrained models
- Adjust hyperparameters (learning rate, batch size)
- Train for more epochs

**More importantly**, you now understand the workflow:
1. Get data
2. Split it properly
3. Build a model
4. Train while monitoring validation performance
5. Evaluate on test set once

This process applies whether you're classifying images, predicting stock prices, or detecting fraud. The specifics change, but the workflow stays the same.

## The Real Lesson

Building ML models isn't about knowing the perfect architecture or the best hyperparameters. It's about:
- Understanding what you're trying to do
- Checking your assumptions
- Iterating on what works
- Debugging when things fail

You'll make mistakes. Your first model will probably underperform. You'll spend hours debugging stupid errors. That's normal. That's the process.

The difference between someone who's good at ML and someone who isn't isn't intelligence or math skills. It's the willingness to iterate, debug, and learn from what doesn't work.

Now go build something. Start simple, make sure it works, then make it better.

---

*Code not working? Find a bug? Let me know—I'm always happy to help debug.*
