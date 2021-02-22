help([==[

Description
===========
Ncview is a visual browser for netCDF format files. Typically you would
 use ncview to get a quick and easy, push-button look at your netCDF 
 files. You can view simple movies of the data, view along various 
 dimensions, take a look at the actual data values, change color maps, 
 invert the data, etc. It runs on UNIX platforms under X11, R4 or higher. 
 For more information, check out the README file; you can also see a 
 representative screen image (GIF, 66K) of ncview in action.
]==])

whatis("Name: Ncview")
whatis("Version: 2.1.2")


local dir,file_name=splitFileName(myFileName())
local image = pathJoin(dir, myModuleVersion()..".sif")

if (subprocess("if [[ -e " .. image .. " ]]; then echo \"exist\"; else echo \"not\"; fi") == "not\n") then
        LmodError("The container image broken. Contact hpc staff for help.")
end


local programs = {"ncview"}
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
