help([==[

Description
===========
OpenFOAM (for "Open-source Field Operation And Manipulation") is a C++ toolbox
for the development of customized numerical solvers, and pre-/post-processing utilities
for the solution of continuum mechanics problems, most prominently including
computational fluid dynamics (CFD).

Usage
================
 # in slurm batch scripts
 module load openfoam/2020
 srun --mpi=pmi2 simpleFoam ...
]==])

whatis("Name: openfoam")
whatis("Version: v6")
whatis("Description: Open-source Field Operation And Manipulation (OpenFoam) is a software application designed for computational fluid dynamics")
whatis("URL: https://hub.docker.com/r/chengshenggan/hpc-app-container")

-- conflict(myModuleName(), "openmpi", "chroma", "milc", "qmcpack", "relion")

local dir,file_name=splitFileName(myFileName())
local image = pathJoin(dir, myModuleVersion()..".sif")

if (subprocess("if [[ -e " .. image .. " ]]; then echo \"exist\"; else echo \"not\"; fi") == "not\n") then
        LmodError("The container image broken. Contact hpc staff for help.")
end

local all_bin = subprocess("singularity run " .. image ..  " bash -c \" \
                                ls /opt/OpenFOAM-6/platforms/linux64GccDPInt32Opt/bin && \
                                cd /opt/OpenFOAM-6/wmake && find * -maxdepth 0 -type f -executable && \
                                ls /opt/OpenFOAM-6/bin\"")
local programs = string.gmatch(all_bin, "%S+")

local entrypoint_args = ""

-- The absolute path to Singularity is needed so it can be invoked on remote
-- nodes without the corresponding module necessarily being loaded.
-- Trim off the training newline.
local singularity = capture("which singularity | head -c -1")

local container_launch = singularity .. " run " .. image .. " " .. entrypoint_args

-- Programs to setup in the shell
for program in programs do
        set_shell_function(program, container_launch .. " " .. program .. " $@",
	                            container_launch .. " " .. program .. " $*")
end

-- setup srun for slurm user
set_shell_function("srun", 
        "if [[ $1 == \"--mpi=pmi2\" ]]; then \
                /usr/bin/srun --mpi=pmi2" .. " " .. container_launch .. " " .. " ${@:2}; \
        else \
                echo \"Error! Please use srun --mpi=pmi2 ... launch your job.\"; \
        fi",
        "if [[ $1 == \"--mpi=pmi2\" ]]; then \
                /usr/bin/srun --mpi=pmi2" .. " " .. container_launch .. " " .. " ${*:2}; \
        else \
                echo \"Error! Please use srun --mpi=pmi2 ... launch your job.\";  \
        fi")
