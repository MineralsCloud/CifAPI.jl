abstract type CifContainer <: AbstractDict{String} end
abstract type NestedCifContainer <: CifContainer end
mutable struct Block <: CifContainer
    loop_names::Vector{Vector{String}} #one loop is a list of datanames
    data_values::Dict{String,<:Vector}
    original_file::AbstractPath
end
mutable struct CifBlock{V} <: NestedCifContainer{V}
    save_frames::Dict{String,Block{V}}
    loop_names::Vector{Vector{String}} #one loop is a list of datanames
    data_values::Dict{String,Vector{V}}
    original_file::AbstractPath
end

get_data_values(b::Block) = b.data_values
get_data_values(b::CifBlock) = b.data_values

abstract type CifCollection <: AbstractDict{String} end
struct Cif{T<:CifContainer} <: CifCollection
    header_comments::String
    contents::Dict{String,T}
end

mutable struct Uchar
    string::Ptr{UInt16}
end

function get_block_code(b)
    s = Uchar(0)
    val = cif_container_get_code(b, Ref(s))
    checkerror(val)
    return make_jl_string(s)
end

function get_syntactical_type(t::cif_value_tp_ptr)
    val_type = cif_value_kind(t.handle)
    if val_type == 0 || val_type == 1
        return typeof(t)
    elseif val_type == 2
        cif_list
    elseif val_type == 3
        cif_table
    elseif val_type == 4
        return Nothing
    elseif val_type == 5
        return Missing
    end
end

function cif_list(cv::cif_value_tp_ptr)
    cif_type = cif_value_kind(cv.handle)
    if cif_type != 2
        error("$val is not a cif list value")
    end
    elctptr = Ref{Cint}(0)
    val = cif_value_get_element_count(cv.handle, elctptr)
    if val != 0
        error(ERROR_CODES[val])
    end
    elct = elctptr[]
    so_far = Vector()
    for el_num in 1:elct
        new_element = cif_value_tp_ptr(0)
        val = cif_value_get_element_at(cv.handle, el_num - 1, Ref(new_element))
        if val != 0
            error(ERROR_CODES[val])
        end
        t = get_syntactical_type(new_element)
        if t == cif_value_tp_ptr
            push!(so_far, String(new_element))
        elseif t == cif_list
            push!(so_far, cif_list(new_element))
        elseif t == cif_table
            push!(so_far, cif_table(new_element))
        else
            push!(so_far, t())
        end
    end
    return so_far
end

function cif_table(cv::cif_value_tp_ptr)
    cif_type = cif_value_kind(cv.handle)
    if cif_type != 3
        error("$val is not a cif table value")
    end
    so_far = Dict{String,Any}()
    for el in keys(cv)
        new_val = cv[el]
        t = get_syntactical_type(new_val)
        if t == cif_value_tp_ptr
            so_far[el] = String(new_val)
        elseif t == cif_list
            so_far[el] = cif_list(new_val)
        elseif t == cif_table
            so_far[el] = cif_table(new_val)
        else
            so_far[el] = t()
        end
    end
    return so_far
end

function Base.String(t::cif_value_tp)
    #Get the textual representation
    s = Uchar(0)
    val = cif_value_get_text(t.handle, Ref(s))
    checkerror(val)
    return make_jl_string(s)
end

function destroy!(cif)
    val = cif_destroy(cif.data)
    if val != 0
        error(ERROR_CODES[val])
    end
    return
end

function make_jl_string(s::Uchar)
    n = get_c_length(s.string, -1)  # short for testing
    icu_string = unsafe_wrap(Array{UInt16,1}, s.string, n, own=false)
    return transcode(String, icu_string)
end

function get_c_length(s::Ptr, max=-1)
    # Now loop over the values we have
    n = 1
    b = unsafe_load(s, n)
    while b != 0 && (max == -1 || (max != -1 && n < max))
        n = n + 1
        b = unsafe_load(s, n)
    end
    n = n - 1
    return n
end
