help([==[

Description
===========
OVITO is a scientific visualization and analysis software for atomistic
and particle simulation data. It helps scientists gain better insights
into materials phenomena and physical processes. The program is freely
available for all major platforms under an open source license.
It has served in a growing number of computational simulation studies
as a powerful tool to analyze, understand and illustrate simulation results.
]==])

whatis("Name: OVITO")
whatis("Version: Basic 3.2.1")

-- conflict(myModuleName(), "openmpi", "chroma", "milc", "qmcpack", "relion")

local dir,file_name=splitFileName(myFileName())
local image = pathJoin(dir, myModuleVersion()..".sif")

if (subprocess("if [[ -e " .. image .. " ]]; then echo \"exist\"; else echo \"not\"; fi") == "not\n") then
        LmodError("The container image broken. Contact hpc staff for help.")
end

-- local image = "/lustre/share/singularity/modules/ovito/2020-ovito.sif"
local programs = {"ovito"}
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
