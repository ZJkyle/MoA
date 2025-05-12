# Mixture-of-Agents (MoA)

[![License](https://img.shields.io/badge/License-Apache_2.0-green.svg)](LICENSE)
[![arXiv](https://img.shields.io/badge/ArXiv-2406.04692-b31b1b.svg)](https://arxiv.org/abs/2406.04692)

<img alt="MoA architecture" src="./assets/moa.jpg">

<p align="center">
  <a href="#overview"><strong>Overview</strong></a> ·
  <a href="#quickstart-moa-in-50-loc"><strong>Quickstart</strong></a> ·
  <a href="#multi-layer-moa-example"><strong>Advanced example</strong></a> ·
  <a href="#interactive-cli-demo"><strong>Interactive CLI Demo</strong></a>
  ·
  <a href="#evaluation"><strong>Evaluation</strong></a>
  ·
  <a href="#results"><strong>Results</strong></a>
  .
  <a href="#credits"><strong>Credits</strong></a>
</p>

## Quickstart: MoA & Multi-layer MoA
1. Install the Together Python library: `pip install together`
2. Get your [Together API Key](https://api.together.xyz/settings/api-keys) & export it: `export TOGETHER_API_KEY=`
3. Run the python file: `python moa.py`

* for Multi-layer MoA run 
```python
python advanced-moa.py
```
* for Interactive CLI Demo
Run the script: `python bot.py`

## Evaluation

MoA provide scripts to quickly reproduce some of the results, such as evaluations of [AlpacaEval](https://github.com/tatsu-lab/alpaca_eval),
[MT-Bench](https://github.com/lm-sys/FastChat), and [FLASK](https://github.com/kaistAI/FLASK).

### AlpacaEval 2
#### Preparation
```bash
# setup api keys
export TOGETHER_API_KEY=<TOGETHER_API_KEY>
export OPENAI_API_KEY=<OPENAI_API_KEY>
export HUGGINGFACE_TOKEN=<HUGGINGFACE_TOKEN>

# login 
huggingface-cli login

# install alpaca requirements
cd alpaca_eval
pip install -e .
pip install -r requirements.txt
```
#### Generate Outputs for single model and MoA 
```
Single output
`./alpaca_eval/scripts/generate_outputs_single.sh deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B`
deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B
mistralai/Mistral-7B-Instruct-v0.1
Qwen/Qwen2.5-7B-Instruct
meta-llama/Meta-Llama-3-8B-Instruct

slef-MoA  
# reference model
./vllm_server.sh --model deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B --port 8000 --gpu 0
./vllm_server.sh --model deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B --port 8001 --gpu 1
./vllm_server.sh --model deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B --port 8002 --gpu 2 
# aggregator model
./vllm_server.sh --model deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B --port 8003 --gpu 3

# Check server
ps aux | grep vllm.entrypoints.openai.api_server
# stop server
./stop_vllm.sh 8000

# generate output
python3 alpaca_eval/generate_for_alpaca_eval_vllm.py

# Run vllm-annotator
alpaca_eval \
    --model_outputs /app/alpaca_eval/my_results/DeepSeek-R1-Distill-Qwen-1.5B/model_outputs.json \
    --reference_outputs /app/alpaca_eval/results/gpt4_1106_preview/model_outputs.json \
    --annotators_config /app/alpaca_eval/vllm_annotator.yaml \
    --output_path leaderboard_results

```

#### Run AlpacaEval 2
```
bash run_eval_alpaca_eval.sh
```


### Results

<div align="center">
  <img src="assets/alpaca_and_mtbench.png" alt="alpaca_mtbench" style="width: 100%; display: block; margin-left: auto; margin-right: auto;" />
  <br>
</div>

We achieved top positions on both the AlpacaEval 2.0 leaderboard and MT-Bench. Notably, on AlpacaEval 2.0, using solely open-source models, we achieved a margin of 7.6% absolute improvement from 57.5% (GPT-4 Omni) to 65.1% (MoA).

<div align="center">
  <img src="assets/flask.png" alt="flask" style="width: 50%; display: block; margin-left: auto; margin-right: auto;" />
  <br>
</div>

FLASK offers fine-grained evaluation of models across multiple dimensions. Our MoA method significantly outperforms the original Qwen1.5-110B-Chat on harmlessness, robustness, correctness, efficiency, factuality, commonsense, insightfulness, completeness. Additionally, MoA also outperforms GPT-4 Omni in terms of correctness, factuality, insightfulness, completeness, and metacognition.

Please feel free to contact us if you have difficulties in reproducing the results.

## Credits

Notably, this work was made possible by the collaborative spirit and contributions of active organizations in the AI field. We appreciate the efforts of Meta AI, Mistral AI, Microsoft, Alibaba Cloud, and DataBricks for developing the Llama 3, Mixtral, WizardLM 2, Qwen 1.5, and DBRX models. Additionally, we extend our gratitude to Tatsu Labs, LMSYS, and KAIST AI for developing the AlpacaEval, MT-Bench, and FLASK evaluation benchmarks.

## License

This project is licensed under the Apache 2.0 License - see the LICENSE file for details.

## Citation

If you find this work helpful, please consider citing:

```bibtex
@article{wang2024mixture,
  title={Mixture-of-Agents Enhances Large Language Model Capabilities},
  author={Wang, Junlin and Wang, Jue and Athiwaratkun, Ben and Zhang, Ce and Zou, James},
  journal={arXiv preprint arXiv:2406.04692},
  year={2024}
}
```
