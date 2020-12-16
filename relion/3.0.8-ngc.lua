help([==[

Description
===========
RELION (for REgularized LIkelihood OptimizatioN) implements an empirical
Bayesian approach for analysis of electron cryo-microscopy (Cryo-EM).
Specifically it provides methods of refinement of singular or multiple 3D
reconstructions as well as 2D class averages. RELION is an important tool in
the study of living cells.
]==])

whatis("Name: relion")
whatis("Version: 3.0.8")

add_property("arch", "gpu")

-- conflict(myModuleName(), "openmpi", "chroma", "milc", "qmcpack", "relion")

local dir,file_name=splitFileName(myFileName())
local image = pathJoin(dir, myModuleVersion()..".sif")

if (subprocess("if [[ -e " .. image .. " ]]; then echo \"exist\"; else echo \"not\"; fi") == "not\n") then
        LmodError("The container image broken. Contact hpc staff for help.")
end

local all_bin = subprocess("singularity exec " .. image ..  " ls /usr/local/relion/bin")
local programs = string.gmatch(all_bin, "%S+")
local entrypoint_args = ""

-- The absolute path to Singularity is needed so it can be invoked on remote
-- nodes without the corresponding module necessarily being loaded.
-- Trim off the training newline.
local singularity = capture("which singularity | head -c -1")

local container_launch = singularity .. " run --nv " .. image .. " " .. entrypoint_args

-- Multinode support
setenv("OMPI_MCA_orte_launch_agent", container_launch .. " orted")

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
