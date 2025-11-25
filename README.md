# MEGA Installation Helper

Automated setup for the CVPR-2020 "Memory Enhanced Global-Local Aggregation (MEGA)" repository

This repository provides a clean, fully functional, and up-to-date installation workflow for the official MEGA video object detection codebase.

**Original code:** https://github.com/Scalsol/mega.pytorch  
**Paper:** *Memory Enhanced Global-Local Aggregation for Video Object Detection*, CVPR 2020

The goal of this repository is to allow any user to install MEGA without dependency errors using a single automated script.

This repository does **not** contain the original MEGA source code.  
Instead, it automates all steps needed to download and prepare the official repository.

---

## Features

- Fully automated setup script (`setup.sh`)
- Compatible with modern systems
- Fixes installation issues related to:
  - PyTorch version incompatibilities
  - Apex build errors
  - COCO API and Cityscapes installation
  - OpenCV drawing bug in `demo/predictor.py`
- Clean and reproducible Conda environment creation
- Includes a helper script to download pretrained models

---

## Repository Structure

```
├── setup.sh       # Full automated installation
├── download.py    # Download pretrained MEGA & baseline models
└── README.md
```

---

## Installation

### 1. Clone this repository

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
```

### 2. Run the automated installer

This will:
- Create a Conda environment (MEGA)
- Install Python 3.7
- Install PyTorch 1.2.0 + CUDA toolkit
- Install all MEGA dependencies (COCO API, Cityscapes, Apex…)
- Clone the original MEGA repository
- Apply required code patches

Run:

```bash
bash setup.sh
```

**Expected duration:** 5–10 minutes depending on the computer.

After completion, your system is fully prepared to run MEGA.

---


## Run the Docker Container

Navigate to the root directory containing the `Dockerfile` and create the Docker Image. Depending on if a GPU is available or not, set the `GPU` variable in line 22. Use the platform flag to imitate a platform when working on not supported platforms, such as Macbook ARM (use `--platform=linux/amd64`). Use the `-t`flag to provide the image with a title and a tag:
```
docker build 
--platform=<platform to imitate>
-t <image name>:<image tag> .
```

When the image was successfully created, create a Docker Container out of it:
```
docker run 
--platform=<platform to imitate>
-it 
# shared input directory
-v <host directory>:<container directory> 
# shared output directory
-v <host directory>:<container directory> 
<image name>:<image tag>
```
Again, a platform can be imitated. Use the `-v`flag to define shared directories between host and container, such as:
```
-v /Users/user/frames_to_process:/data/input
-v /Users/user/frames_processed:/data/output
```
...for defining a directory with input for the models and a directory to define where outputs should be stored.\
After the `docker run` command, the terminal of the container opens after some seconds, permitting to perform operations in the environment (e. g. use models).



## Running the Demo

### 1. Navigate to the MEGA folder

```bash
cd mega.pytorch
```

### 2. Activate the MEGA enviroment

```bash
conda activate MEGA
```


### 3. Use the models

```bash
python demo/demo.py base configs/vid_R_101_C4_1x.yaml R_101.pth --suffix ".JPEG" --visualize-path datasets/image_folder --output-folder visualization --output-video
```

### Command Arguments

| Argument | Description |
|----------|-------------|
| `base` | Selects the BASE model mode (single-frame baseline). You may replace it with `mega` to use the MEGA model. |
| `configs/vid_R_101_C4_1x.yaml` | Path to the configuration file that defines the model architecture, dataset settings, and runtime parameters (`configs/vid_R_101_C4_1x.yaml` or `configs/MEGA/vid_R_101_C4_MEGA_1x.yaml`) |
| `R_101.pth` | Path to the model weights file (pretrained checkpoint). Must match the model type (`R_101.pth` or `MEGA_R_101.pth`). The weights should be in the `mega.pytorch` folder |
| `--suffix ".JPEG"` | File extension of the input images. For videos it should also be set as `".JPEG"` |
| `--visualize-path datasets/image_folder` | Directory containing the input images. Frames will be processed in alphabetical order. If a video wants to be processed, indicate only one video per iteration |
| `--output-folder visualization` | Directory where output visualization videos will be saved |
| `--output-video` | If set, the visualization is saved as a video instead of individual frames |
| `--video` | If set, the input is a video instead of a folder of images |

---

## Citation

If you use MEGA in academic work, please cite the original paper:

```bibtex
@inproceedings{chen20mega,
    Author = {Chen, Yihong and Cao, Yue and Hu, Han and Wang, Liwei},
    Title = {Memory Enhanced Global-Local Aggregation for Video Object Detection},
    Conference = {CVPR},
    Year = {2020}
}
```

---

## Contact

- For issues related to the MEGA codebase, please refer to the [original repository](https://github.com/Scalsol/mega.pytorch)
- For issues related to this automated installer, please open an issue in this repository