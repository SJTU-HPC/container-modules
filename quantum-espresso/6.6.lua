help([==[
Description
===========
Quantum ESPRESSO is an integrated suite of computer codes for 
electronic structure calculations and materials modeling at the nanoscale. 
It builds on the electronic structure codes PWscf, PHONON, CP90, FPMD, 
and Wannier. It is based on density-functional theory, plane waves, 
and pseudopotentials (both norm-conserving and ultrasoft).
]==])

whatis("Name: espresso")
whatis("Version: 6.6")

-- conflict(myModuleName(), "openmpi", "chroma", "milc", "qmcpack", "relion")

local dir,file_name=splitFileName(myFileName())
local image = pathJoin(dir, myModuleVersion()..".sif")

if (subprocess("if [[ -e " .. image .. " ]]; then echo \"exist\"; else echo \"not\"; fi") == "not\n") then
        LmodError("The container image broken. Contact hpc staff for help.")
end

local entrypoint_args = ""

-- The absolute path to Singularity is needed so it can be invoked on remote
-- nodes without the corresponding module necessarily being loaded.
-- Trim off the training newline.
local singularity = capture("which singularity | head -c -1")

local container_launch = singularity .. " run " .. image .. " " .. entrypoint_args

local all_bin = subprocess("singularity run " .. image ..  " bash -c \" \
                                ls /opt/espresso/bin\"")
local programs = string.gmatch(all_bin, "%S+")

-- Programs to setup in the shell
for program in programs do
        set_shell_function(program, container_launch .. " " .. program .. " $@",
	                            container_launch .. " " .. program .. " $*")
end

set_shell_function("mpirun", container_launch .. " mpirun " ..  " $@",
                                container_launch .. " mpirun " ..  " $*")

-- setup srun for slurm user
set_shell_function("srun", 
        "if [[ $1 == \"--mpi=pmi2\" ]]; then \
                /usr/bin/srun --mpi=pmi2" .. " " .. container_launch .. " " .. " ${@:2}; \
        else \
                /usr/bin/srun ${@:1}; \
        fi",
        "if [[ $1 == \"--mpi=pmi2\" ]]; then \
                /usr/bin/srun --mpi=pmi2" .. " " .. container_launch .. " " .. " ${*:2}; \
        else \
                /usr/bin/srun ${@:1}; \
        fi")
