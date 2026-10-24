"""
    doctor(io::IO=stdout) -> NamedTuple

Print the Julia, VAFT.jl and IMASdd.jl versions, the supported file formats, and
whether optional Python interoperability could be enabled. Returns the same
information as a `NamedTuple`.

`doctor` only inspects the current environment; it never installs packages or
contacts external services.
"""
function doctor(io::IO=stdout)
    info = (
        julia=VERSION,
        vaft=pkgversion(@__MODULE__),
        imasdd=pkgversion(IMASdd),
        hdf5=pkgversion(HDF5),
        formats=supported_formats(),
        # PythonCall is never loaded by VAFT; this only reports whether it is installed.
        pythoncall_installed=Base.find_package("PythonCall") !== nothing,
    )
    println(io, "VAFT.jl environment")
    println(io, "  Julia     : ", info.julia)
    println(io, "  VAFT.jl   : ", info.vaft)
    println(io, "  IMASdd.jl : ", info.imasdd)
    println(io, "  HDF5.jl   : ", info.hdf5)
    println(io, "  Formats   :")
    for (k, v) in pairs(SUPPORTED_FORMATS)
        println(io, "    :", rpad(k, 5), v.description, " (", join(v.extensions, ", "), ") via IMASdd.", v.reader)
    end
    println(io, "  Python    : ", info.pythoncall_installed ?
        "PythonCall.jl installed (VAFT Python interop not yet implemented)" :
        "PythonCall.jl not installed (optional; not required)")
    return info
end
