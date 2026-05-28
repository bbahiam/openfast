import os
import shutil
import subprocess

# Prep
for folder in [
#        "windboxes_general_coherence", 
#        "windboxes_iec_coherence", 
#        "windboxes_vk_coherence",
#        "windboxes_no_coherence",
         "windboxes_vk_coherence_2",
        ]:
    for drivetrain in ["FIXED_SPEED", "DYNAMIC"]:
        for seed in range(1,11):
            case_name = f"U07p1_S{seed:02d}"
            #windbox_dir
            current_dir = os.path.dirname(__file__)
            run_dir = os.path.join(current_dir, folder, drivetrain, case_name) 
                                  
            os.makedirs(run_dir)

            shutil.copy(
                os.path.join(current_dir, "_model_template", "DISCON.IN"),
                os.path.join(run_dir, "DISCON.IN"))
            shutil.copy(
                os.path.join(current_dir, "_model_template", "ENFAST.fst"),
                os.path.join(run_dir, case_name+".fst"))
            shutil.copytree(
                os.path.join(current_dir, "_model_template", "components"),
                os.path.join(run_dir, "components"))

            # Change drivetrain mode
            mbdyna_file = os.path.join(run_dir, "components", "MBDyna.yaml")
            cmd = ["sed", "-i", "s/FIXED_SPEED/"+drivetrain+"/", mbdyna_file]
            print(" ".join(cmd))
            subprocess.run(cmd, check=True)
            # Change windbox file
            inflow_wind_file = os.path.join(run_dir, "components", "InflowWind.dat")
            orig_windbox_file = '/home/envision/shared/loads/bmonteiro_conference_paper_2025/windboxes/wind_U07p1_S01/wind_U07p1_S01'
            new_windbox_file = os.path.normpath(os.path.join(current_dir, "..", folder, "wind_"+case_name, "wind_"+case_name))
            cmd = ["sed", "-i", "s@"+orig_windbox_file+"@"+new_windbox_file+"@", inflow_wind_file]
            print(" ".join(cmd))
            subprocess.run(cmd, check=True)
