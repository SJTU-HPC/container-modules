help([==[
Description
===========
PyTorch is a GPU accelerated tensor computational framework with a Python front
end. Functionality can be easily extended with common Python libraries such as
NumPy, SciPy, and Cython. Automatic differentiation is done with a tape-based
system at both a functional and neural network layer level. This functionality
brings a high level of flexibility and speed as a deep learning framework and
provides accelerated NumPy-like functionality.
More information
================
 - NGC: https://ngc.nvidia.com/catalog/containers/nvidia:pytorch
]==])

whatis("Name: PyTorch")
whatis("Version: 20.01-py3")
whatis("Description: PyTorch is a GPU accelerated tensor computational framework with a Python front end. Functionality can be easily extended with common Python libraries such as NumPy, SciPy, and Cython. Automatic differentiation is done with a tape-based system at both a functional and neural network layer level. This functionality brings a high level of flexibility and speed as a deep learning framework and provides accelerated NumPy-like functionality.")
whatis("URL: https://ngc.nvidia.com/catalog/containers/nvidia:pytorch")

-- conflict(myModuleName(), "rapidsai", "tensorflow")

local dir,file_name=splitFileName(myFileName())
local image = pathJoin(dir, myModuleVersion()..".sif")

if (subprocess("if [[ -e " .. image .. " ]]; then echo \"exist\"; else echo \"not\"; fi") == "not\n") then
        LmodError("The container image broken. Contact hpc staff for help.")
end

local programs = {"python", "python3", "conda", "pip", "tensorboard"}
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
