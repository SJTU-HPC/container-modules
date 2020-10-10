help([==[
Description
===========
GROMACS is a molecular dynamics application designed to simulate Newtonian
equations of motion for systems with hundreds to millions of particles. GROMACS
is designed to simulate biochemical molecules like proteins, lipids, and
nucleic acids that have a lot of complicated bonded interactions. More info on
GROMACS can be found at http://www.gromacs.org/
More information
================
 - NGC: https://ngc.nvidia.com/catalog/containers/hpc:gromacs
]==])

whatis("Name: gromacs")
whatis("Version: 2020.2")
whatis("Description: GROMACS is a molecular dynamics application designed to simulate Newtonian equations of motion for systems with hundreds to millions of particles. GROMACS is designed to simulate biochemical molecules like proteins, lipids, and nucleic acids that have a lot of complicated bonded interactions. More info on GROMACS can be found at http://www.gromacs.org/")
whatis("URL: https://ngc.nvidia.com/catalog/containers/hpc:gromacs")

-- conflict(myModuleName(), "openmpi", "chroma", "milc", "qmcpack", "relion")

local dir,file_name=splitFileName(myFileName())
local image = pathJoin(dir, myModuleVersion()..".sif")

if (subprocess("if [[ -e " .. image .. " ]]; then echo \"exist\"; else echo \"not\"; fi") == "not\n") then
        LmodError("The container image broken. Contact hpc staff for help.")
end

local programs = {"mpirun", "gmx", "gmx_mpi"}
local entrypoint_args = ""

-- The absolute path to Singularity is needed so it can be invoked on remote
-- nodes without the corresponding module necessarily being loaded.
-- Trim off the training newline.
local singularity = capture("which singularity | head -c -1")

local container_launch = singularity .. " run " .. image .. " " .. entrypoint_args

-- Programs to setup in the shell
for i,program in pairs(programs) do
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
