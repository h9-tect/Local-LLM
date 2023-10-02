import sys
import os
import requests


def get_model(model_url="TheBloke/Mistral-7B-OpenOrca-GGUF", quant_type="Q4_K_M"):
    model_name = model_url.split("/")[-1].replace("-GGUF", "").lower()
    file_path = f"models/{model_name}.{quant_type}.gguf"
    if os.path.exists(file_path):
        return file_path
    if not os.path.exists("models"):
        os.makedirs("models")
    url = (
        model_url
        if "https://" in model_url
        else f"https://huggingface.co/{model_url}/resolve/main/{model_name}.{quant_type}.gguf"
    )
    with requests.get(url, stream=True, allow_redirects=True) as r:
        r.raise_for_status()
        with open(file_path, "wb") as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)
    return file_path


if __name__ == "__main__":
    model_url = (
        sys.argv[1] if len(sys.argv) > 1 else "TheBloke/Mistral-7B-OpenOrca-GGUF"
    )
    quant_type = sys.argv[2] if len(sys.argv) > 2 else "Q4_K_M"
    model_path = get_model(model_url, quant_type)
    print(model_path)
