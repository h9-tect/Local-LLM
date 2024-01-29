FROM nvidia/cuda:12.1.1-devel-ubuntu22.04
RUN --mount=type=cache,target=/var/cache/cuda/apt,sharing=locked \
    apt-get update --fix-missing  && apt-get upgrade -y && \
    apt-get install -y --fix-missing --no-install-recommends git build-essential gcc g++ portaudio19-dev ffmpeg libportaudio2 libasound-dev python3 python3-pip gcc wget ocl-icd-opencl-dev opencl-headers clinfo libclblast-dev libopenblas-dev pkg-config ninja-build && \
    apt-get install -y gcc-10 g++-10 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 10 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 10 && \
    mkdir -p /etc/OpenCL/vendors && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd && \ 
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    python3 -m pip install --upgrade pip --no-cache-dir
WORKDIR /app
ENV HOST 0.0.0.0
ENV CUDA_DOCKER_ARCH=all
ENV LLAMA_CUBLAS=1
COPY download.py .
RUN --mount=type=cache,target=/var/cache/models,sharing=locked \
    python3 download.py
COPY requirements.txt .
RUN python3 -m pip install cmake scikit-build setuptools --no-cache-dir && \
    CMAKE_ARGS="-DLLAMA_BLAS=on" python3 -m pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8091
RUN chmod +x start.sh
ENTRYPOINT ["sh", "-c", "./start.sh"]