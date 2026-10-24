"""
    SUPPORTED_FORMATS

File formats `load_imas` can read, keyed by the `format` symbol. Each entry gives
the file extensions recognized by automatic detection, the IMASdd.jl reader that
does the work, and a short description.
"""
const SUPPORTED_FORMATS = (
    json=(extensions=(".json",), reader=:json2imas, description="OMAS/IMAS JSON"),
    h5i=(extensions=(".h5", ".hdf5"), reader=:h5i2imas, description="IMAS tensorized HDF5"),
    hdf=(extensions=(".h5", ".hdf5"), reader=:hdf2imas, description="OMAS hierarchical HDF5"),
)

"""
    supported_formats() -> Vector{Symbol}

Return the `format` values accepted by [`load_imas`](@ref).
"""
supported_formats() = collect(keys(SUPPORTED_FORMATS))

"""
    UnsupportedFormatError(path, format)

Thrown by [`load_imas`](@ref) when a file's format cannot be determined or is not
supported. `format` is the requested format symbol, or `nothing` when automatic
detection from the file extension failed.
"""
struct UnsupportedFormatError <: Exception
    path::String
    format::Union{Symbol,Nothing}
end

function Base.showerror(io::IO, e::UnsupportedFormatError)
    if e.format === nothing
        print(io, "UnsupportedFormatError: cannot infer an IMAS file format from the extension of \"", e.path, "\"")
    else
        print(io, "UnsupportedFormatError: format `:", e.format, "` is not supported (file \"", e.path, "\")")
    end
    print(io, ". Supported formats: ")
    join(io, ("`:$k` ($(v.description); $(join(v.extensions, ", ")))" for (k, v) in pairs(SUPPORTED_FORMATS)), ", ")
    print(io, ". Pass `format=` explicitly for files with other extensions.")
end

"""
    IMASLoadError(path, format, cause)

Thrown by [`load_imas`](@ref) when the IMASdd.jl reader fails. The original
exception is kept in `cause`.
"""
struct IMASLoadError <: Exception
    path::String
    format::Symbol
    cause::Any
end

function Base.showerror(io::IO, e::IMASLoadError)
    print(io, "IMASLoadError: failed to read \"", e.path, "\" as `:", e.format, "` (",
        SUPPORTED_FORMATS[e.format].description, ")\nCaused by: ")
    showerror(io, e.cause)
end

# Tensorized (h5i) files flatten IDS paths into `&`-separated dataset names inside
# one group per IDS (e.g. `equilibrium/time_slice[]&AOS_SHAPE`). IMASdd.is_h5i (8.6)
# only inspects the top level and requires a `.h5` extension, so it misses files
# written by IMASdd.imas2h5i; check the IDS groups as well.
function _is_h5i(path::AbstractString)
    HDF5.h5open(path, "r") do file
        for name in keys(file)
            occursin('&', name) && return true
            obj = file[name]
            obj isa HDF5.Group && any(n -> occursin('&', n), keys(obj)) && return true
        end
        return false
    end
end

function _detect_format(path::AbstractString)
    ext = lowercase(splitext(path)[2])
    if ext in SUPPORTED_FORMATS.json.extensions
        return :json
    elseif ext in SUPPORTED_FORMATS.hdf.extensions
        return _is_h5i(path) ? :h5i : :hdf
    else
        throw(UnsupportedFormatError(path, nothing))
    end
end

_read(::Val{:json}, path; kw...) = IMASdd.json2imas(path; kw...)
_read(::Val{:h5i}, path; kw...) = IMASdd.h5i2imas(path; kw...)
_read(::Val{:hdf}, path; kw...) = IMASdd.hdf2imas(path; kw...)

"""
    load_imas(path; format=:auto, kw...) -> IMASdd.dd

Read a local IMAS-compatible file and return the native IMASdd.jl data structure.

`format` is one of `:auto`, `:json`, `:h5i` (IMAS tensorized HDF5) or `:hdf` (OMAS
hierarchical HDF5). With `:auto`, `.json` files are read as JSON and `.h5`/`.hdf5`
files are inspected to tell tensorized from hierarchical HDF5.

Remaining keyword arguments are passed unchanged to the IMASdd.jl reader
(`IMASdd.json2imas`, `IMASdd.h5i2imas` or `IMASdd.hdf2imas`). Data are returned as
stored: units and coordinate conventions are not converted.

Throws `ArgumentError` if `path` is not a file, [`UnsupportedFormatError`](@ref)
if the format is unknown, and [`IMASLoadError`](@ref) if the reader fails.

# Example
```julia
dd = load_imas("equilibrium.json")
dd.equilibrium.time_slice[1].global_quantities.ip
```
"""
function load_imas(path::AbstractString; format::Symbol=:auto, kw...)
    isfile(path) || throw(ArgumentError("IMAS file not found: \"$path\""))
    if format === :auto
        format = _detect_format(path)
    elseif !haskey(SUPPORTED_FORMATS, format)
        throw(UnsupportedFormatError(path, format))
    end
    try
        return _read(Val(format), path; kw...)
    catch err
        err isa InterruptException && rethrow()
        throw(IMASLoadError(path, format, err))
    end
end
