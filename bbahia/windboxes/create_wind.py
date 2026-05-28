import os
import subprocess
import time
import itertools

SBATCH_OPTIONS = """
#SBATCH --job-name turbsim
#SBATCH --mem-per-cpu 1G
#SBATCH --ntasks 96
#SBATCH --cpus-per-task 1
#SBATCH --partition travis
#SBATCH --output slurm.out
"""


TURBSIM_INP = """TurbSim Input File. Valid for TurbSim v2.00
TurbSim Input File. Valid for TurbSim v2.0
---------Runtime Options-----------------------------------
False                   Echo            - Echo input data to <RootName>.ech (flag)
{seed}              RandSeed1       - First random seed  (-2147483648 to 2147483647)
RanLux              RandSeed2       - Second random seed (-2147483648 to 2147483647) for intrinsic pRNG, or an alternative pRNG: "RanLux" or "RNSNLW"
False                WrBHHTP         - Output hub-height turbulence parameters in binary form?  (Generates RootName.bin)
False                WrFHHTP         - Output hub-height turbulence parameters in formatted form?  (Generates RootName.dat)
False                 WrADHH          - Output hub-height time-series data in AeroDyn form?  (Generates RootName.hh)
True                 WrADFF          - Output full-field time-series data in TurbSim/AeroDyn form? (Generates Rootname.bts)
True                 WrBLFF          - Output full-field time-series data in BLADED/AeroDyn form?  (Generates RootName.wnd)
True                WrADTWR         - Output tower time-series data? (Generates RootName.twr)
False               WrHAWCFF        - [Envision addition] Output full-field time-series data in HAWC form?  (Generates RootName.u-bin, RootName.v-bin, RootName.w-bin, RootName.hawc)
False                WrFMTFF         - Output full-field time-series data in formatted (readable) form?  (Generates RootName.u, RootName.v, RootName.w)
False                  WrACT           - Output coherent turbulence time steps in AeroDyn form? (Generates RootName.cts)
2               ScaleIEC        - Scale IEC turbulence models to exact target standard deviation? [0=no additional scaling; 1=use hub scale uniformly; 2=use individual scales]

--------Turbine/Model Specifications-----------------------
64               NumGrid_Z       - Vertical grid-point matrix dimension
64               NumGrid_Y       - Horizontal grid-point matrix dimension
0.01                TimeStep        - Time step [seconds]
600            AnalysisTime    - Length of analysis time series [seconds] (program will add time if necessary: AnalysisTime = MAX(AnalysisTime, UsableTime+GridWidth/MeanHHWS) )
ALL              UsableTime      - Usable length of output time series [seconds] (program will add GridWidth/MeanHHWS seconds)
141                   HubHt           - Hub height [m] (should be > 0.5*GridHeight)
280              GridHeight      - Grid height [m]
280               GridWidth       - Grid width [m] (should be >= 2*(RotorRadius+ShaftLength))
0.0                VFlowAng        - Vertical mean flow (uptilt) angle [degrees]
0                HFlowAng        - Horizontal mean flow (skew) angle [degrees]

--------Meteorological Boundary Conditions-------------------
"USRVKM"                  TurbModel       - Turbulence model ("IECKAI"=Kaimal, "IECVKM"=von Karman, "GP_LLJ", "NWTCUP", "SMOOTH", "WF_UPW", "WF_07D", "WF_14D", "TIDAL", or "NONE")
"unused"                   UserFile  - Name of the file that contains inputs for user-defined spectra or time series inputs (used only for "USRINP" and "TIMESR" models)
"1"                IECstandard     - Number of IEC 61400-x standard (x=1,2, or 3 with optional 61400-1 edition number (i.e. "1-Ed2") )
18.6             IECturbc        - IEC turbulence characteristic ("A", "B", "C" or the turbulence intensity in percent) ("KHTEST" option with NWTCUP model, not used for other models)
"NTM"               IEC_WindType    - IEC turbulence type ("NTM"=normal, "xETM"=extreme turbulence, "xEWM1"=extreme 1-year wind, "xEWM50"=extreme 50-year wind, where x=wind turbine class 1, 2, or 3)
default                       ETMc            - IEC Extreme Turbulence Model "c" parameter [m/s]
USR            WindProfileType - Wind profile type ("JET";"LOG"=logarithmic;"PL"=power law;"H2L"=Log law for TIDAL spectral model;"IEC"=PL on rotor disk, LOG elsewhere; or "default")
"usrvkm.inp"        ProfileFile     - Name of the file that contains input profiles for WindProfileType="USR" and/or TurbModel="USRVKM" [-]
250                      RefHt           - Height of the reference wind speed [m]
7.1                       URef            - Mean (total) wind speed at the reference height [m/s] (or "default" for JET wind profile)
350                    ZJetMax         - Jet height [m] (used only for JET wind profile, valid 70-490 m)
0.0                      PLExp           - Power law exponent [-] (or "default")
default                         Z0              - Surface roughness length [m] (or "default")

--------Non-IEC Meteorological Boundary Conditions------------
default             Latitude        - Site latitude [degrees] (or "default")
0.05              RICH_NO         - Gradient Richardson number
default                UStar           - Friction or shear velocity [m/s] (or "default")
default                   ZI              - Mixing layer depth [m] (or "default")
0e-6                PC_UW           - Hub mean u'w' Reynolds stress (or "default")
0e-6               PC_UV           - Hub mean u'v' Reynolds stress (or "default")
0e-6               PC_VW           - Hub mean v'w' Reynolds stress (or "default")

--------Spatial Coherence Parameters----------------------------
GENERAL               SCMod1           - u-component coherence model ("GENERAL","IEC","API","NONE", or "default")
NONE               SCMod2           - v-component coherence model ("GENERAL","IEC","NONE", or "default")
NONE               SCMod3           - w-component coherence model ("GENERAL","IEC","NONE", or "default")
default              InCDec1         - u-component coherence parameters (e.g. "10.0  0.3e-3" in quotes) (or "default")
12.0 0.0              InCDec2         - v-component coherence parameters (e.g. "10.0  0.3e-3" in quotes) (or "default")
12.0 0.0              InCDec3         - w-component coherence parameters (e.g. "10.0  0.3e-3" in quotes) (or "default")
0               CohExp          - Coherence exponent (or "default")

--------Coherent Turbulence Scaling Parameters-------------------
"unused"            CTEventPath     - Name of the path where event data files are located
"unused"            CTEventFile     - Type of event files ("LES", "DNS", or "RANDOM")
True              Randomize       - Randomize the disturbance scale and locations? (true/false)
1                DistScl         - Disturbance scale (ratio of wave height to rotor disk). (Ignored when Randomize = true.)
0.5                   CTLy            - Fractional location of tower centerline from right (looking downwind) to left side of the dataset. (Ignored when Randomize = true.)
0.5                   CTLz            - Fractional location of hub height from the bottom of the dataset. (Ignored when Randomize = true.)
10000000.0            CTStartTime     - Minimum start time for coherent structures in RootName.cts [seconds]

==================================================
NOTE: Do not add or remove any lines in this file!
==================================================
"""

USRVKM_INP = """---------TurbSim v2.00.* Profile Input File------------------------
Example file using completely made up profiles
-------- User-Defined Profiles (Used only with USR wind profile or USRVKM spectral model) -------------
2 NumUSRz - Number of Heights
1.000 StdScale1 - u-component scaling factor for the input standard deviation
0.001 StdScale2 - v-component scaling factor for the input standard deviation
0.001 StdScale3 - w-component scaling factor for the input standard deviation
-----------------------------------------------------------------------------------
Height    Wind Speed Wind Direction         Standard Deviation     Length Scale
(m)       (m/s)      (deg, cntr-clockwise ) (m/s)                  (m)
-----------------------------------------------------------------------------------
000.0     {wind_speed}         0.0                  {std_dev}           {length_scale}
200.0     {wind_speed}         0.0                  {std_dev}           {length_scale}
"""

wind_speeds = [7.1]
turbulence_intensity = 1/wind_speeds[0] # For std dev = 1
n_seeds = 10

with open("script.sh", "w") as script_file:
    print("#!/bin/bash", file=script_file)
    print(SBATCH_OPTIONS, file=script_file)
    for seed, wind_speed in zip(range(len(wind_speeds)*n_seeds), 
                                itertools.cycle(wind_speeds)):
        dirname = f"wind_U{wind_speed:04.1f}_S{seed//len(wind_speeds)+1:02d}".replace(".", "p")
        print(dirname)
        try:
            os.mkdir(dirname)
        except FileExistsError:
            pass

        with open(os.path.join(dirname, dirname+".inp"), "w") as f:
            f.write(TURBSIM_INP.format(seed=seed))

        with open(os.path.join(dirname, "usrvkm.inp"), "w") as f:
            f.write(USRVKM_INP.format(wind_speed=wind_speed,
                                    std_dev=turbulence_intensity*wind_speed,
                                    length_scale=147))

        my_env = {
            "WINEPREFIX": os.path.expanduser("~/.wine.x64"),
            "WINEARCH": "win64",
        }

        cmd = [
#            "srun",
#            "--ntasks=1",
#            "--chdir="+os.path.realpath(dirname),
#            f"--job-name={dirname}",
#            "--export="+",".join(f"{k}={v}" for k, v in my_env.items()),
#            f"--output={dirname}.out",
#            "--wait=0", #Otherwise a task that finished will trigger a timeout for others
            f"cd {os.path.realpath(dirname)} &&",
	        "/home/envision/bmonteiro/repo/ENFAST/build/build-vkcoherence/TurbSim/TurbSim",
            dirname+".inp",
            "&",
            f"cd {os.getcwd()}",
        ]
        print(" ".join(cmd), file=script_file)
        print("sleep 1", file=script_file)
    print("wait", file=script_file)
    print("wineserver --wait", file=script_file)

subprocess.run(["bash", script_file.name])
