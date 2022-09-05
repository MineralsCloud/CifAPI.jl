mutable struct cif_tp_ptr
    handle::Ptr{cif_tp}
end

mutable struct cif_container_tp_ptr
    handle::Ptr{cif_container_tp}  # *cif_block_tp
end

mutable struct cif_loop_tp_ptr
    handle::Ptr{cif_loop_tp}
end

mutable struct cif_value_tp_ptr
    handle::Ptr{cif_value_tp}
end
