#!/bin/bash

export TOKENIZERS_PARALLELISM=false

GEN_SCRIPT_PATH=generate.py
EVAL_SCRIPT_PATH=evaluate.py
DATA_DIR=/home/work/workspace_bum/FastV/data/MileBench
MODEL_CONFIG_PATH=configs/model_configs.yaml
CUDA_LAUNCH_BLOCKING=0
gpu_num=1
for model in llava-v1.5-7b; do
    for dataset_name in Rouge_OCR_VQA ANLS_DocVQA ALFRED ActionLocalization ActionPrediction ActionSequence CLEVR-Change CharacterOrder CounterfactualInference DocVQA EgocentricNavigation GPR1200 IEdit ImageNeedleInAHaystack MMCoQA MovingAttribute MovingDirection MultiModalQA OCR-VQA ObjectExistence ObjectInteraction ObjectShuffle SceneTransition SlideVQA Spot-the-Diff StateChange TQA TextNeedleInAHaystack WebQA WikiVQA nuscenes; do
        BATCH_SIZE=1
        mkdir -p logs/${model}
        # Start generating
        accelerate launch --config_file ./configs/accelerate_configs.yaml \
            --main_process_port 29500  \
            --num_machines 1 \
            --machine_rank 0 \
            --num_processes ${gpu_num} \
            --deepspeed_multinode_launcher standard \
            \
            ${GEN_SCRIPT_PATH} \
            --data_dir ${DATA_DIR} \
            --dataset_name ${dataset_name}  \
            --model_name ${model} \
            --output_dir outputs \
            --batch-image ${BATCH_SIZE} \
            --model_configs ${MODEL_CONFIG_PATH} \
            --overwrite \
            > logs/${model}/${dataset_name}.log

        # Start evaluating
        python ${EVAL_SCRIPT_PATH} \
            --data-dir ${DATA_DIR} \
            --dataset ${dataset_name} \
            --result-dir outputs/${model} \
            >> logs/${model}/${dataset_name}.log

        # ############################## Combined to 1 image ###########################
        # python ${GEN_SCRIPT_PATH} \
        #     --data_dir ${DATA_DIR} \
        #     --dataset_name ${dataset_name}  \
        #     --model_name ${model} \
        #     --output_dir outputs_combine_1 \
        #     --batch-image ${BATCH_SIZE} \
        #     --model_configs ${MODEL_CONFIG_PATH} \
        #     --overwrite \
        #     --combine_image 1 \
        #     > logs/${model}/${dataset_name}_combine_1.log

        # # Start evaluating
        # python ${EVAL_SCRIPT_PATH} \
        #     --data-dir ${DATA_DIR} \
        #     --dataset ${dataset_name} \
        #     --result-dir outputs_combine_1/${model} \
        #     >> logs/${model}/${dataset_name}_combine_1.log
    done
done


#!/bin/bash

# export TOKENIZERS_PARALLELISM=false

# GEN_SCRIPT_PATH=generate.py
# EVAL_SCRIPT_PATH=evaluate.py
# DATA_DIR=../MileBench
# MODEL_CONFIG_PATH=configs/model_configs.yaml
# CUDA_LAUNCH_BLOCKING=0
# gpu_num=1

# for model in llava-v1.5-7b; do
#     for dataset_name in Rouge_OCR_VQA; do
#         BATCH_SIZE=1
#         mkdir -p logs/${model}
#         # Start generating
#         python ${GEN_SCRIPT_PATH} \
#             --data_dir ${DATA_DIR} \
#             --dataset_name ${dataset_name}  \
#             --model_name ${model} \
#             --output_dir outputs \
#             --batch-image ${BATCH_SIZE} \
#             --model_configs ${MODEL_CONFIG_PATH} \
#             --overwrite \
#             > logs/${model}/${dataset_name}.log

#         # Start evaluating
#         python ${EVAL_SCRIPT_PATH} \
#             --data-dir ${DATA_DIR} \
#             --dataset ${dataset_name} \
#             --result-dir outputs/${model} \
#             >> logs/${model}/${dataset_name}.log

#         # ############################## Combined to 1 image ###########################
#         # python ${GEN_SCRIPT_PATH} \
#         #     --data_dir ${DATA_DIR} \
#         #     --dataset_name ${dataset_name}  \
#         #     --model_name ${model} \
#         #     --output_dir outputs_combine_1 \
#         #     --batch-image ${BATCH_SIZE} \
#         #     --model_configs ${MODEL_CONFIG_PATH} \
#         #     --overwrite \
#         #     --combine_image 1 \
#         #     > logs/${model}/${dataset_name}_combine_1.log

#         # Start evaluating
#         # python ${EVAL_SCRIPT_PATH} \
#         #     --data-dir ${DATA_DIR} \
#         #     --dataset ${dataset_name} \
#         #     --result-dir outputs_combine_1/${model} \
#         #     >> logs/${model}/${dataset_name}_combine_1.log
#     done
# done
