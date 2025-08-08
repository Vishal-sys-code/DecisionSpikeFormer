#!/bin/bash
model_type_list=("pssa") # pssa, tssa, dt
env_list=("hopper" "walker2d" "halfcheetah")
dataset_list=("medium-replay" "medium-expert" "medium")
cuda=0
lr=1e-4  # {1e-3, 1e-4}
max_iters=20
embed_dim=256  # {128,256}


for model_type in "${model_type_list[@]}";
do
  setting_name="gym_$model_type"
  log_dir="results/${setting_name}_lr${lr}_iters${max_iters}_dim${embed_dim}"
  echo $log_dir
  num_steps_per_iter=1000
  warmup_steps=$((max_iters*num_steps_per_iter/10)) # for cosine lr scheduler
  # 创建日志文件夹
  mkdir -p $log_dir
  for dataset in "${dataset_list[@]}";
  do
      for env in "${env_list[@]}";
      do
          echo $cuda
          echo $env-$dataset-$model_type
          nohup bash -c "CUDA_VISIBLE_DEVICES=$cuda python -u experiment.py \
            --env=$env \
            --dataset=$dataset \
            --model_type=$model_type \
            --batch_size=64 \
            --embed_dim=$embed_dim \
            --warmup_steps=$warmup_steps \
            --max_iters=$max_iters \
            --learning_rate=$lr \
            --setting_name=$setting_name \
            --num_steps_per_iter=$num_steps_per_iter \
            --num_eval_episodes=10 \
            > ./$log_dir/$env-$dataset-$model_type.log 2>&1" &
      done
  done
done
