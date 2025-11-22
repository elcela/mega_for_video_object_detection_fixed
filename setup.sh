# preparation
conda create --name DOWNLOADS -y python=3.12
source activate DOWNLOADS

conda install --yes pip

pip install gdown

python download.py

conda deactivate

# first, make sure that your conda is setup properly with the right environment
# for that, check that `which conda`, `which pip` and `which python` points to the
# right path. From a clean conda env, this is what you need to do

# actual script
conda create --name MEGA -y python=3.7
source activate MEGA

# this installs the right pip and dependencies for the fresh python
conda install --yes ipython pip

# mega and coco api dependencies
pip install ninja yacs cython matplotlib tqdm opencv-python scipy

# follow PyTorch installation in https://pytorch.org/get-started/locally/
# we give the instructions for CUDA 10.0
conda install --yes pytorch==1.2.0 torchvision==0.4.0 cudatoolkit=10.0 -c pytorch

export INSTALL_DIR=$PWD

# install pycocotools
cd $INSTALL_DIR
git clone https://github.com/cocodataset/cocoapi.git
cd cocoapi/PythonAPI
python setup.py build_ext install

# install cityscapesScripts
cd $INSTALL_DIR
git clone https://github.com/mcordts/cityscapesScripts.git
cd cityscapesScripts/
python setup.py build_ext install

# install apex
cd $INSTALL_DIR
git clone https://github.com/NVIDIA/apex.git
cd apex
git checkout 4a8c4ac088b6f84a10569ee89db3a938b48922b4
# fix exchange line 910 to fix apex typing error
# sed -i "910s/.*/parallel = None/" apex/setup.py
python setup.py build_ext install

# # install PyTorch Detection
cd $INSTALL_DIR
git clone https://github.com/Scalsol/mega.pytorch.git
cd mega.pytorch

# # the following will install the lib with
# # symbolic links, so that you can modify
# # the files if you want and won't need to
# # re-build it
python setup.py build develop

# # change this line to avoid an opencv error
sed -i "611s/.*/                image, s, (int(x), int(y)), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2/" demo/predictor.py

pip install 'pillow<7.0.0'

unset INSTALL_DIR


# python demo/demo.py base configs/vid_R_101_C4_1x.yaml R_101.pth --suffix ".JPEG"\
# --visualize-path datasets/image_folder \
# --output-folder visualization --output-video
