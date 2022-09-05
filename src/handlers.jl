mutable struct cif_builder_context
    actual_cif::Dict{String,<:CifContainer}
    block_stack::Array{<:CifContainer}
    filename::AbstractPath
    verbose::Bool
end

handle_cif_start(a, b)::Cint = 0

handle_cif_end(a, b)::Cint = 0

handle_block_start(a::cif_container_tp_ptr, b)::Cint = begin
    blockname = get_block_code(a)
    if b.verbose
        println("New blockname $(blockname)")
    end
    newblock = Block()
    newblock.original_file = b.filename
    push!(b.block_stack, newblock)
    return 0
end

function handle_block_end(a::cif_container_tp_ptr, b::cif_builder_context)::Cint
    # Remove missing values
    all_names = keys(get_data_values(b.block_stack[end]))
    # Length > 1 dealt with already
    all_names = filter(x -> length(get_data_values(b.block_stack[end])[x]) == 1, all_names)
    # Remove any whose first and only entry is 'missing'
    drop_names = filter(x -> ismissing(get_data_values(b.block_stack[end])[x][1]), all_names)
    # println("Removing $drop_names from block")
    [delete!(b.block_stack[end], x) for x in drop_names]
    # and finish off
    blockname = get_block_code(a)
    if b.verbose
        println("Block is finished: $blockname")
    end
    b.actual_cif[blockname] = pop!(b.block_stack)
    return 0
end

function handle_frame_start(a::cif_container_tp_ptr, b)::Cint
    blockname = get_block_code(a)
    if b.verbose
        println("Frame started: $blockname")
    end
    newblock = Block()
    newblock.original_file = b.filename
    b.block_stack[end] = CifBlock(b.block_stack[end])
    push!(b.block_stack, newblock)
    return 0
end

function handle_frame_end(a, b)::Cint
    # Remove missing values
    all_names = keys(get_data_values(b.block_stack[end]))
    # Length > 1 dealt with already
    all_names = filter(x -> length(get_data_values(b.block_stack[end])[x]) == 1, all_names)
    # Remove any whose first and only entry is 'missing'
    drop_names = filter(x -> ismissing(get_data_values(b.block_stack[end])[x][1]), all_names)
    [delete!(b.block_stack[end], x) for x in drop_names]
    final_frame = pop!(b.block_stack)
    blockname = get_block_code(a)
    b.block_stack[end].save_frames[blockname] = final_frame
    if b.verbose
        println("Frame $blockname is finished")
    end
    return 0
end

handle_loop_start(a, b)::Cint = 0

function handle_loop_end(a::Ptr{cif_loop_tp}, b)::Cint
    if b.verbose
        println("Loop header $(keys(a))")
    end
    # ignore missing values
    loop_names = lowercase.(keys(a))
    not_missing = filter(x -> any(y -> !ismissing(y), get_data_values(b.block_stack[end])[x]), loop_names)
    create_loop!(b.block_stack[end], not_missing)
    # and remove the data
    missing_ones = setdiff(Set(loop_names), not_missing)
    #println("Removing $missing_ones from loop")
    [delete!(b.block_stack[end], x) for x in missing_ones]
    return 0
end

handle_packet_start(a, b)::Cint = 0

handle_packet_end(a, b)::Cint = 0

function handle_item(a::Ptr{UInt16}, b::cif_value_tp_ptr, c)::Cint
    a_as_uchar = Uchar(a)
    val = ""
    keyname = make_jl_string(a_as_uchar)
    if c.verbose
        println("Processing name $keyname")
    end
    current_block = c.block_stack[end]
    syntax_type = get_syntactical_type(b)
    if syntax_type == cif_value_tp_ptr
        val = String(b)
    elseif syntax_type == cif_list
        val = cif_list(b)
    elseif syntax_type == cif_table
        val = cif_table(b)
    elseif syntax_type == Nothing
        val = nothing
    elseif syntax_type == Missing
        val = missing
    else
        error("")
    end
    if c.verbose
        if !ismissing(val) && val !== nothing
            println("With value $val")
        elseif ismissing(val)
            println("With value ?")
        else
            println("With value .")
        end
    end
    lc_keyname = lowercase(keyname)
    if !(lc_keyname in keys(get_data_values(current_block)))
        get_data_values(current_block)[lc_keyname] = [val]
    else
        push!(get_data_values(current_block)[lc_keyname], val)
    end
    return 0
end

default_options(path; verbose=false) = begin
    handle_cif_start_c = @cfunction(handle_cif_start, Cint, (cif_tp_ptr, Ref{cif_builder_context}))
    handle_cif_end_c = @cfunction(handle_cif_end, Cint, (cif_tp_ptr, Ref{cif_builder_context}))
    handle_block_start_c = @cfunction(handle_block_start, Cint, (cif_container_tp_ptr, Ref{cif_builder_context}))
    handle_block_end_c = @cfunction(handle_block_end, Cint, (cif_container_tp_ptr, Ref{cif_builder_context}))
    handle_frame_start_c = @cfunction(handle_frame_start, Cint, (cif_container_tp_ptr, Ref{cif_builder_context}))
    handle_frame_end_c = @cfunction(handle_frame_end, Cint, (cif_container_tp_ptr, Ref{cif_builder_context}))
    handle_loop_start_c = @cfunction(handle_loop_start, Cint, (cif_loop_tp_ptr, Ref{cif_builder_context}))
    handle_loop_end_c = @cfunction(handle_loop_end, Cint, (Ptr{cif_loop_tp}, Ref{cif_builder_context}))
    handle_packet_start_c = @cfunction(handle_packet_start, Cint, (Ptr{cif_packet_tp}, Ref{cif_builder_context}))
    handle_packet_end_c = @cfunction(handle_packet_end, Cint, (Ptr{cif_packet_tp}, Ref{cif_builder_context}))
    handle_item_c = @cfunction(handle_item, Cint, (Ptr{UInt16}, cif_value_tp_ptr, Ref{cif_builder_context}))
    handlers = cif_handler_tp(
        handle_cif_start_c,
        handle_cif_end_c,
        handle_block_start_c,
        handle_block_end_c,
        handle_frame_start_c,
        handle_frame_end_c,
        handle_loop_start_c,
        handle_loop_end_c,
        handle_packet_start_c,
        handle_packet_end_c,
        handle_item_c,
    )
    context = cif_builder_context(Dict(), CifContainer[], path, verbose)
    p_opts = cif_parse_opts_s(0, C_NULL, 0, 1, 1, 1, C_NULL, C_NULL, Ref(handlers), C_NULL, C_NULL, C_NULL, C_NULL, context)
    return p_opts
end


