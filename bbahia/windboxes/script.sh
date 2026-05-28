#!/bin/bash

#SBATCH --job-name turbsim
#SBATCH --mem-per-cpu 1G
#SBATCH --ntasks 96
#SBATCH --cpus-per-task 1
#SBATCH --partition travis
#SBATCH --output slurm.out

cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2/wind_U07p1_S01 && /home/envision/bmonteiro/repo/ENFAST/build/build-vkcoherence/TurbSim/TurbSim wind_U07p1_S01.inp & cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2
sleep 1
cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2/wind_U07p1_S02 && /home/envision/bmonteiro/repo/ENFAST/build/build-vkcoherence/TurbSim/TurbSim wind_U07p1_S02.inp & cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2
sleep 1
cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2/wind_U07p1_S03 && /home/envision/bmonteiro/repo/ENFAST/build/build-vkcoherence/TurbSim/TurbSim wind_U07p1_S03.inp & cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2
sleep 1
cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2/wind_U07p1_S04 && /home/envision/bmonteiro/repo/ENFAST/build/build-vkcoherence/TurbSim/TurbSim wind_U07p1_S04.inp & cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2
sleep 1
cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2/wind_U07p1_S05 && /home/envision/bmonteiro/repo/ENFAST/build/build-vkcoherence/TurbSim/TurbSim wind_U07p1_S05.inp & cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2
sleep 1
cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2/wind_U07p1_S06 && /home/envision/bmonteiro/repo/ENFAST/build/build-vkcoherence/TurbSim/TurbSim wind_U07p1_S06.inp & cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2
sleep 1
cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2/wind_U07p1_S07 && /home/envision/bmonteiro/repo/ENFAST/build/build-vkcoherence/TurbSim/TurbSim wind_U07p1_S07.inp & cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2
sleep 1
cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2/wind_U07p1_S08 && /home/envision/bmonteiro/repo/ENFAST/build/build-vkcoherence/TurbSim/TurbSim wind_U07p1_S08.inp & cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2
sleep 1
cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2/wind_U07p1_S09 && /home/envision/bmonteiro/repo/ENFAST/build/build-vkcoherence/TurbSim/TurbSim wind_U07p1_S09.inp & cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2
sleep 1
cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2/wind_U07p1_S10 && /home/envision/bmonteiro/repo/ENFAST/build/build-vkcoherence/TurbSim/TurbSim wind_U07p1_S10.inp & cd /home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes_vk_coherence_2
sleep 1
wait
wineserver --wait
