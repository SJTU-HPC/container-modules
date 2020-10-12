help([==[

Description
===========
Large-scale Atomic/Molecular Massively Parallel Simulator (LAMMPS) is a
software application designed for molecular dynamics simulations. It has
potentials for solid-state materials (metals, semiconductor), soft matter
(biomolecules, polymers) and coarse-grained or mesoscopic systems. It can be
used to model atoms or, more generically, as a parallel particle simulator at
the atomic, meso, or continuum scale.

Usage
================
 # in slurm batch scripts
 module load lammps/2020
 srun --mpi=pmi2 lmp ...
]==])

whatis("Name: lammps")
whatis("Version: 15Jun2020")
whatis("Description: Large-scale Atomic/Molecular Massively Parallel Simulator (LAMMPS) is a software application designed for molecular dynamics simulations. It has potentials for solid-state materials (metals, semiconductor), soft matter (biomolecules, polymers) and coarse-grained or mesoscopic systems. It can be used to model atoms or, more generically, as a parallel particle simulator at the atomic, meso, or continuum scale.")
whatis("URL: https://ngc.nvidia.com/catalog/containers/hpc:lammps")

add_property("arch", "gpu")

-- conflict(myModuleName(), "openmpi", "chroma", "milc", "qmcpack", "relion")

local dir,file_name=splitFileName(myFileName())
local image = pathJoin(dir, myModuleVersion()..".sif")

if (subprocess("if [[ -e " .. image .. " ]]; then echo \"exist\"; else echo \"not\"; fi") == "not\n") then
        LmodError("The container image broken. Contact hpc staff for help.")
end

-- local image = "/lustre/share/img/hpc/hpc-app-container_lammps-2020.sif"
local programs = {"lmp", "mpirun"}
local entrypoint_args = ""

-- The absolute path to Singularity is needed so it can be invoked on remote
-- nodes without the corresponding module necessarily being loaded.
-- Trim off the training newline.
local singularity = capture("which singularity | head -c -1")

local container_launch = singularity .. " run --nv " .. image .. " " .. entrypoint_args

-- Multinode support
setenv("OMPI_MCA_orte_launch_agent", container_launch .. " orted")

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
