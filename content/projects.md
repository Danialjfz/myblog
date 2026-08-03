---
title: "Projects | Danial Jafarzadeh Jazi"
date: 2025-08-08
draft: false
description: "Selected projects by Danial Jafarzadeh Jazi: a GPT language model built from scratch in PyTorch, and GPU performance engineering of GEMM kernels in CUDA."
keywords: ["Danial Jafarzadeh projects", "GPT from scratch", "CUDA GEMM optimization", "GPU performance engineering", "PyTorch transformer"]
sitemap:
  priority: 0.7
---

## Projects

### GPT Language Model from Scratch

2025 · Python, PyTorch, tiktoken · [Code](https://github.com/Danialjfz/GPT-Language-Model)

- **Problem:** Understand transformer language models end to end by implementing every component rather than relying on high-level abstractions.
- **Approach:** Built a complete GPT-2-style decoder-only transformer (~124M parameters, 12 layers, 12 heads) from scratch in PyTorch: multi-head causal self-attention, learned positional embeddings, GELU feed-forward blocks, plus end-to-end tokenization, training, and inference scripts. Training pipeline uses AdamW with cosine LR schedule and warmup, gradient clipping, mixed-precision (BF16), and periodic checkpointing.
- **Outcome:** Validation perplexity ~3.0 on Shakespeare, with coherent autoregressive generation via temperature and top-k sampling.

### GPU Performance Engineering: Opti-GEMM

2025 – Ongoing · C++, CUDA, CMake, Nsight Compute · [Code](https://github.com/Danialjfz/Opti-GEMM)

- **Problem:** Understand where GPU performance actually comes from by optimizing General Matrix Multiply (GEMM), the core primitive of deep learning workloads.
- **Approach:** Systematic kernel optimization from a naive global-memory implementation through shared-memory tiling, register blocking, and warp-level primitives, profiled with Nsight Compute against cuBLAS baselines.
- **Outcome:** Cross-architecture benchmarking on Tesla T4 (Turing) and P100 (Pascal), documenting a 5× speedup via manual shared-memory tiling on cache-less Pascal vs. hardware-cached Turing.

---

If a project here overlaps with your work or you want to compare approaches, [reach out by email](mailto:danialj999@gmail.com).
