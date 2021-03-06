#!/bin/bash

#SBATCH -N 2
#SBATCH -t 6:00:00
#SBATCH -p gpu_titanrtx
np=$(($SLURM_NNODES * 4))

module purge
module load 2019
module load OpenMPI/3.1.4-GCC-8.3.0
module load NCCL/2.5.6-CUDA-10.1.243
module list

source ~/virtualenvs/openslide-torch/bin/activate

# Setting ENV variables

# Export MPICC
export MPICC=mpicc
export MPICXX=mpicpc
export HOROVOD_MPICXX_SHOW="mpicxx --showme:link"
export HOROVOD_CUDA_HOME=$CUDA_HOME
export HOROVOD_NCCL_HOME=$EBROOTNCCL
export HOROVOD_WITH_PYTORCH=1 
export PATH=$HOME/virtualenvs/openslide-torch/bin:$PATH
export LD_LIBRARY_PATH=$HOME/virtualenvs/openslide-torch/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$HOME/virtualenvs/openslide-torch/lib:$LD_LIBRARY_PATH
export CPATH=$HOME/virtualenvs/openslide-torch/include:$CPATH



#pip3 install --no-cache-dir --upgrade --force-reinstall horovod
#pip install torch==1.5.1+cu101 torchvision==0.6.1+cu101 -f https://download.pytorch.org/whl/torch_stable.html
#pip install scikit-learn 
#pip install Pillow 
#pip install tqdm 
#pip install six
#pip install opencv-python
#pip install openslide-python
#pip install torchsummary
#pip install scikit-image
 


cd ~/examode/color-information
 

#/nfs/managed_datasets/CAMELYON17/training/center_1/patches_positive_256 
mpirun -map-by ppr:4:node -np 4 -x LD_LIBRARY_PATH -x PATH python -u train_img_horo.py \
 --data custom \
 --slide_format tif \
 --slide_path /nfs/managed_datasets/CAMELYON16/TrainingData/Train_Tumor \
 --bb_downsample 7 \
 --log_image_path experiments/test/ \
 --val_split 0.2 \
 --imagesize 512 \
 --batchsize 1 \
 --val-batchsize 1 \
 --actnorm True \
 --nbits 8 \
 --act swish \
 --update-freq 1 \
 --n-exact-terms 8 \
 --fc-end False \
 --squeeze-first False \
 --factor-out True \
 --save experiments/test \
 --nblocks 16 \
 --vis-freq 500              
 --nepochs 5


mpirun -map-by ppr:4:node -np 8 -x LD_LIBRARY_PATH -x PATH python -u train_img_horo.py \
 --data custom \
 --fp16_allreduce \
 --train_path /home/rubenh/examode/deeplab/CAMELYON16_PREPROCESSING/Radboudumc \
 --valid_path /home/rubenh/examode/deeplab/CAMELYON16_PREPROCESSING/Radboudumc  \
 --imagesize 256 \
 --batchsize 4 \
 --val-batchsize 4 \
 --actnorm True \
 --nbits 8 \
 --act swish \
 --update-freq 1 \
 --n-exact-terms 8 \
 --fc-end False \
 --squeeze-first False \
 --factor-out True \
 --save experiments/Rad_AOEC \
 --nblocks 21 \
 --nclusters 4 \
 --vis-freq 10 \
 --nepochs 5 \
 --resume /home/rubenh/examode/color-information/checkpoints/Radboudumc_8_workers.pth \
 --save_conv True

exit

"""
TRAINING

 mpirun -map-by ppr:4:node -np $np -x LD_LIBRARY_PATH -x PATH python -u train_img_horo.py \
 --data custom \
 --train_path /home/rubenh/examode/deeplab/CAMELYON16_PREPROCESSING/Radboudumc \
 --valid_path /home/rubenh/examode/deeplab/CAMELYON16_PREPROCESSING/Radboudumc \
 --imagesize 256 \
 --batchsize 4 \
 --val-batchsize 4 \
 --actnorm True \
 --nbits 8 \
 --act swish \
 --update-freq 1 \
 --n-exact-terms 8 \
 --factor-out True \
 --save experiments/Radboudumc \
 --nblocks 21 \
 --nclusters 3 \
 --vis-freq 4 \
 --nepochs 10 \
 --lr 1e-3 \
 --idim 128

"""
 
"""

EVALUATION

  mpirun -map-by ppr:4:node -np $np -x LD_LIBRARY_PATH -x PATH python -u train_img_horo.py \
 --data custom \
 --fp16_allreduce \
 --train_path /home/rubenh/examode/deeplab/CAMELYON16_PREPROCESSING/Radboudumc \
 --valid_path /home/rubenh/examode/deeplab/CAMELYON16_PREPROCESSING/AOEC \
 --imagesize 256 \
 --batchsize 1 \
 --val-batchsize 1 \
 --actnorm True \
 --nbits 8 \
 --act swish \
 --update-freq 1 \
 --n-exact-terms 8 \
 --fc-end False \
 --squeeze-first False \
 --factor-out True \
 --save experiments/Radboudumc \
 --nblocks 16 \
 --vis-freq 10 \
 --nepochs 5 \
 --resume /home/rubenh/examode/color-information/experiments/Radboudumc/models/most_recent_4_workers.pth \
 --save_conv True
 
"""
