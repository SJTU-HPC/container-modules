help([==[

Description
===========
Rosetta is a comprehensive software suite for modeling macromolecular structures. 
As a flexible, multi-purpose application, it includes tools for structure prediction, 
design, and remodeling of proteins and nucleic acids. Since 1998, Rosetta web servers 
have run billions of structure prediction and protein design simulations, 
and billions or trillions more have been run on supercomputer clusters.

]==])

whatis("Name: rosetta")
whatis("Version: 3.12")


local dir,file_name=splitFileName(myFileName())
local image = pathJoin(dir, myModuleVersion()..".sif")

if (subprocess("if [[ -e " .. image .. " ]]; then echo \"exist\"; else echo \"not\"; fi") == "not\n") then
        LmodError("The container image broken. Contact hpc staff for help.")
end

local all_bin = subprocess("singularity exec " .. image ..  " cat /app_entry")
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

set_shell_function("mpirun", container_launch .. " mpirun " ..  " $@",
                                container_launch .. " mpirun " ..  " $*")

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
