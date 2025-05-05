# Experiment 1: Cross-model SLM MoA

## Objective
Test the effectiveness of using multiple SLMs with different reference strategies (small→large, large→small, random) in a MoA setup.

## Setup
- Models: TinyLLaMA, LLaMA-3B, LLaMA-7B
- Dataset: GSM8k
- Prompt Design: [See prompts.md](./prompts.md)
- Aggregation: Simple voting / weighted average

## Metrics
- Accuracy
- Inference Time
- Token Count

## Results
| Setting       | Accuracy | Time (s) | Token Used |
|---------------|----------|----------|-------------|
| Small→Large   | 68.2%    | 4.3      | 1425        |
| Random        | 67.5%    | 4.1      | 1303        |

## Notes
- Aggregation method has large impact.
- Inference time increases rapidly with depth of hierarchy.
