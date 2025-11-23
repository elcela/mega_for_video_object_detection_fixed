##############################################
# Stage 1 — Download models using Python 3.12
##############################################
FROM python:3.12-slim AS downloader

# WORKDIR /download_stage
WORKDIR /download_stage

# Install gdown
RUN pip install --upgrade pip && pip install gdown

# Copy your download.py and run it
COPY download.py .
RUN python download.py

##############################################
# Stage 2 — Build MEGA environment (Python 3.7 + Conda)
##############################################
FROM continuumio/miniconda3:latest

# Build args
ARG GPU=false

# Create MEGA environment with Python 3.7
RUN conda create --name MEGA python=3.7 -y

# Switch to the conda environment for all following commands
SHELL ["conda", "run", "-n", "MEGA", "/bin/bash", "-c"]

# Install pip and core Python deps
RUN conda install ipython pip -y && \
    pip install ninja yacs cython matplotlib tqdm opencv-python scipy

# PyTorch + torchvision installation
RUN conda install pytorch==1.2.0 torchvision==0.4.0 cudatoolkit=10.0 -c pytorch
# RUN if [ "$GPU" = "true" ] ; then \
#         conda install pytorch==1.2.0 torchvision==0.4.0 cudatoolkit=10.0 -c pytorch ; \
#     else \
#         conda install pytorch==1.2.0 torchvision==0.4.0 cpuonly -c pytorch ; \
#     fi

# Set working directory
WORKDIR /opt/mega

# Install system build tools (needed for compiling C extensions)
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential gcc g++ python3-dev libffi-dev git pkg-config \
        libgl1-mesa-glx libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install cocoapi
RUN git clone https://github.com/cocodataset/cocoapi.git && \
    cd cocoapi/PythonAPI && python setup.py build_ext install

# Install cityscapes scripts
RUN git clone https://github.com/mcordts/cityscapesScripts.git && \
    cd cityscapesScripts && python setup.py build_ext install

# Install apex
RUN git clone https://github.com/NVIDIA/apex.git && \
    cd apex && \
    git checkout 4a8c4ac088b6f84a10569ee89db3a938b48922b4 && \
    python setup.py build_ext install

# Install mega.pytorch
RUN git clone https://github.com/Scalsol/mega.pytorch.git && \
    cd mega.pytorch && \
    python setup.py build develop && \
    sed -i "611s/.*/                image, s, (int(x), int(y)), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2/" demo/predictor.py

# changes needed to run on CPU only systems
RUN if [ "$GPU" = "false" ]; then \
        sed -i '28s/.*/_C.MODEL.DEVICE = "cpu"/' /opt/mega/mega.pytorch/mega_core/config/defaults.py && \
        sed -i '19s/.*/    return int(os.environ.get("OMPI_COMM_WORLD_SIZE") or 0)/' /opt/mega/mega.pytorch/mega_core/utils/distributed.py && \
        sed -i '33s/.*/    return int(os.environ.get("OMPI_COMM_WORLD_LOCAL_SIZE") or 0)/' /opt/mega/mega.pytorch/mega_core/utils/distributed.py && \
        sed -i '40s/.*/    return int(os.environ.get("OMPI_UNIVERSE_SIZE") or 0)/' /opt/mega/mega.pytorch/mega_core/utils/distributed.py && \
        sed -i '76s/.*/_GPUS = []/' /opt/mega/mega.pytorch/mega_core/utils/distributed.py; \
    fi

# Pillow version fix
RUN pip install 'pillow<7.0.0'

# Copy pre-downloaded model files into container
COPY --from=downloader /download_stage /opt/mega/mega.pytorch/

# Set working directory to mega.pytorch to be able to run commands directly
WORKDIR /opt/mega/mega.pytorch

# Set bash terminal as entrypoint to accept all possible user commands
ENTRYPOINT [ "bash" ]