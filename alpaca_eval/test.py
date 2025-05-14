import yaml

with open("/app/alpaca_eval/vllm_annotator.yaml", "r") as f:
    config = yaml.safe_load(f)
    print(type(config))
    print(config)
