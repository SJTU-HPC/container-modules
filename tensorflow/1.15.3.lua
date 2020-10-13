help([==[
Description
===========
TensorFlow is an open-source software library for numerical computation using
data flow graphs. Nodes in the graph represent mathematical operations, while
the graph edges represent the multidimensional data arrays (tensors) that flow
between them. This flexible architecture lets you deploy computation to one or
more CPUs or GPUs in a desktop, server, or mobile device without rewriting
code.
]==])

whatis("Name: TensorFlow")
whatis("Version: 20.08-tf1-py3")

add_property("arch", "gpu")

-- conflict(myModuleName(), "rapidsai", "tensorflow")

local dir,file_name=splitFileName(myFileName())
local image = pathJoin(dir, myModuleVersion()..".sif")

if (subprocess("if [[ -e " .. image .. " ]]; then echo \"exist\"; else echo \"not\"; fi") == "not\n") then
        LmodError("The container image broken. Contact hpc staff for help.")
end

local programs = {"python", "python3", "pip", "tensorboard"}
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
