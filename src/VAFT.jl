"""
    VAFT

Julia-native interface to the Versatile Analysis Framework for Tokamak (VAFT).

IMAS data is represented with the native types of
[IMASdd.jl](https://github.com/ProjectTorreyPines/IMASdd.jl); VAFT.jl does not
define its own IDS schema or serializers.
"""
module VAFT

import HDF5
import IMASdd

export load_imas, doctor

include("io.jl")
include("diagnostics.jl")

end # module VAFT
