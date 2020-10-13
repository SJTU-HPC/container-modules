help([==[

Description
===========
Scilab is free and open source software for numerical computation providing 
a powerful computing environment for engineering and scientific applications.
]==])

whatis("Name: scilab")
whatis("Version: 6.1.0")

local dir,file_name=splitFileName(myFileName())
local image = pathJoin(dir, myModuleVersion()..".sif")

if (subprocess("if [[ -e " .. image .. " ]]; then echo \"exist\"; else echo \"not\"; fi") == "not\n") then
        LmodError("The container image broken. Contact hpc staff for help.")
end

local programs = {"scilab", "scilab-cli"}
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