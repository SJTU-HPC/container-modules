help([==[

Description
===========
GNU Octave is software featuring a high-level programming language, 
primarily intended for numerical computations. Octave helps in solving 
linear and nonlinear problems numerically, and for performing other 
numerical experiments using a language that is mostly compatible with MATLAB. 
It may also be used as a batch-oriented language. Since it is part of the 
GNU Project, it is free software under the terms of the GNU General Public License.

]==])

whatis("Name: octave")
whatis("Version: 5.2.0")
whatis("Description: GNU Octave is software featuring a high-level programming language, ")
whatis("URL: https://hub.docker.com/r/chengshenggan/ood-container")

-- conflict(myModuleName(), "openmpi", "chroma", "milc", "qmcpack", "relion")

local dir,file_name=splitFileName(myFileName())
local image = pathJoin(dir, myModuleVersion()..".sif")

if (subprocess("if [[ -e " .. image .. " ]]; then echo \"exist\"; else echo \"not\"; fi") == "not\n") then
        LmodError("The container image broken. Contact hpc staff for help.")
end

local programs = {"octave"}
local entrypoint_args = ""

-- The absolute path to Singularity is needed so it can be invoked on remote
-- nodes without the corresponding module necessarily being loaded.
-- Trim off the training newline.
local singularity = capture("which singularity | head -c -1")

local container_launch = singularity .. " run " .. image .. " " .. entrypoint_args

-- Multinode support
setenv("OMPI_MCA_orte_launch_agent", container_launch .. " orted")

-- Programs to setup in the shell
for i,program in pairs(programs) do
        set_shell_function(program, container_launch .. " " .. program .. " $@",
	                            container_launch .. " " .. program .. " $*")
end