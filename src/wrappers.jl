using CEnum
using cif_api_jll

mutable struct cif_container_s end

const cif_container_tp = cif_container_s

function cif_container_free(container)
    ccall((:cif_container_free, libcif), Cvoid, (Ptr{cif_container_tp},), container)
end

function cif_container_destroy(container)
    ccall((:cif_container_destroy, libcif), Cint, (Ptr{cif_container_tp},), container)
end

const cif_frame_tp = cif_container_s

function cif_container_create_frame(container, code, frame)
    ccall((:cif_container_create_frame, libcif), Cint, (Ptr{cif_container_tp}, Ptr{Cint}, Ptr{Ptr{cif_frame_tp}}), container, code, frame)
end

function cif_container_get_frame(container, code, frame)
    ccall((:cif_container_get_frame, libcif), Cint, (Ptr{cif_container_tp}, Ptr{Cint}, Ptr{Ptr{cif_frame_tp}}), container, code, frame)
end

function cif_container_get_all_frames(container, frames)
    ccall((:cif_container_get_all_frames, libcif), Cint, (Ptr{cif_container_tp}, Ptr{Ptr{Ptr{cif_frame_tp}}}), container, frames)
end

mutable struct cif_s end

const cif_tp = cif_s

const cif_block_tp = cif_container_s

mutable struct cif_loop_s end

const cif_loop_tp = cif_loop_s

mutable struct cif_packet_s end

const cif_packet_tp = cif_packet_s

mutable struct cif_pktitr_s end

const cif_pktitr_tp = cif_pktitr_s

mutable struct cif_value_u end

const cif_value_tp = cif_value_u

@cenum cif_kind::UInt32 begin
    CIF_CHAR_KIND = 0
    CIF_NUMB_KIND = 1
    CIF_LIST_KIND = 2
    CIF_TABLE_KIND = 3
    CIF_NA_KIND = 4
    CIF_UNK_KIND = 5
end

const cif_kind_tp = cif_kind

@cenum cif_quoted::UInt32 begin
    CIF_NOT_QUOTED = 0
    CIF_QUOTED = 1
end

const cif_quoted_tp = cif_quoted

struct cif_handler_s
    handle_cif_start::Ptr{Cvoid}
    handle_cif_end::Ptr{Cvoid}
    handle_block_start::Ptr{Cvoid}
    handle_block_end::Ptr{Cvoid}
    handle_frame_start::Ptr{Cvoid}
    handle_frame_end::Ptr{Cvoid}
    handle_loop_start::Ptr{Cvoid}
    handle_loop_end::Ptr{Cvoid}
    handle_packet_start::Ptr{Cvoid}
    handle_packet_end::Ptr{Cvoid}
    handle_item::Ptr{Cvoid}
end

const cif_handler_tp = cif_handler_s

# typedef int ( * cif_parse_error_callback_tp ) ( int code , size_t line , size_t column , const UChar * text , size_t length , void * data )
const cif_parse_error_callback_tp = Ptr{Cvoid}

# typedef void ( * cif_syntax_callback_tp ) ( size_t line , size_t column , const UChar * token , size_t length , void * data )
const cif_syntax_callback_tp = Ptr{Cvoid}

struct cif_parse_opts_s
    prefer_cif2::Cint
    default_encoding_name::Ptr{Cchar}
    force_default_encoding::Cint
    line_folding_modifier::Cint
    text_prefixing_modifier::Cint
    max_frame_depth::Cint
    extra_ws_chars::Ptr{Cchar}
    extra_eol_chars::Ptr{Cchar}
    handler::Ptr{cif_handler_tp}
    whitespace_callback::cif_syntax_callback_tp
    keyword_callback::cif_syntax_callback_tp
    dataname_callback::cif_syntax_callback_tp
    error_callback::cif_parse_error_callback_tp
    user_data::Ptr{Cvoid}
end

struct cif_write_opts_s
    cif_version::Cint
end

struct cif_string_analysis_s
    delim::NTuple{4,Cint}
    length::Cint
    length_first::Cint
    length_last::Cint
    length_max::Cint
    num_lines::Cint
    max_semi_run::Cint
    delim_length::Cuint
    contains_text_delim::Cint
    has_reserved_start::Cint
    has_trailing_ws::Cint
end

function cif_parse(stream, options, cif)
    ccall((:cif_parse, libcif), Cint, (Ptr{Libc.FILE}, Ptr{cif_parse_opts_s}, Ptr{Ptr{cif_tp}}), stream, options, cif)
end

function cif_parse_options_create(opts)
    ccall((:cif_parse_options_create, libcif), Cint, (Ptr{Ptr{cif_parse_opts_s}},), opts)
end

function cif_parse_error_ignore(code, line, column, text, length, data)
    ccall((:cif_parse_error_ignore, libcif), Cint, (Cint, Csize_t, Csize_t, Ptr{Cint}, Csize_t, Ptr{Cvoid}), code, line, column, text, length, data)
end

function cif_parse_error_die(code, line, column, text, length, data)
    ccall((:cif_parse_error_die, libcif), Cint, (Cint, Csize_t, Csize_t, Ptr{Cint}, Csize_t, Ptr{Cvoid}), code, line, column, text, length, data)
end

function cif_write(stream, options, cif)
    ccall((:cif_write, libcif), Cint, (Ptr{Libc.FILE}, Ptr{cif_write_opts_s}, Ptr{cif_tp}), stream, options, cif)
end

function cif_write_options_create(opts)
    ccall((:cif_write_options_create, libcif), Cint, (Ptr{Ptr{cif_write_opts_s}},), opts)
end

function cif_create(cif)
    ccall((:cif_create, libcif), Cint, (Ptr{Ptr{cif_tp}},), cif)
end

function cif_destroy(cif)
    ccall((:cif_destroy, libcif), Cint, (Ptr{cif_tp},), cif)
end

function cif_create_block(cif, code, block)
    ccall((:cif_create_block, libcif), Cint, (Ptr{cif_tp}, Ptr{Cint}, Ptr{Ptr{cif_block_tp}}), cif, code, block)
end

function cif_get_block(cif, code, block)
    ccall((:cif_get_block, libcif), Cint, (Ptr{cif_tp}, Ptr{Cint}, Ptr{Ptr{cif_block_tp}}), cif, code, block)
end

function cif_get_all_blocks(cif, blocks)
    ccall((:cif_get_all_blocks, libcif), Cint, (Ptr{cif_tp}, Ptr{Ptr{Ptr{cif_block_tp}}}), cif, blocks)
end

function cif_walk(cif, handler, context)
    ccall((:cif_walk, libcif), Cint, (Ptr{cif_tp}, Ptr{cif_handler_tp}, Ptr{Cvoid}), cif, handler, context)
end

function cif_container_get_code(container, code)
    ccall((:cif_container_get_code, libcif), Cint, (Ptr{cif_container_tp}, Ptr{Ptr{Cint}}), container, code)
end

function cif_container_assert_block(container)
    ccall((:cif_container_assert_block, libcif), Cint, (Ptr{cif_container_tp},), container)
end

function cif_container_create_loop(container, category, names, loop)
    ccall((:cif_container_create_loop, libcif), Cint, (Ptr{cif_container_tp}, Ptr{Cint}, Ptr{Ptr{Cint}}, Ptr{Ptr{cif_loop_tp}}), container, category, names, loop)
end

function cif_container_get_category_loop(container, category, loop)
    ccall((:cif_container_get_category_loop, libcif), Cint, (Ptr{cif_container_tp}, Ptr{Cint}, Ptr{Ptr{cif_loop_tp}}), container, category, loop)
end

function cif_container_get_item_loop(container, item_name, loop)
    ccall((:cif_container_get_item_loop, libcif), Cint, (Ptr{cif_container_tp}, Ptr{Cint}, Ptr{Ptr{cif_loop_tp}}), container, item_name, loop)
end

function cif_container_get_all_loops(container, loops)
    ccall((:cif_container_get_all_loops, libcif), Cint, (Ptr{cif_container_tp}, Ptr{Ptr{Ptr{cif_loop_tp}}}), container, loops)
end

function cif_container_prune(container)
    ccall((:cif_container_prune, libcif), Cint, (Ptr{cif_container_tp},), container)
end

function cif_container_get_value(container, item_name, val)
    ccall((:cif_container_get_value, libcif), Cint, (Ptr{cif_container_tp}, Ptr{Cint}, Ptr{Ptr{cif_value_tp}}), container, item_name, val)
end

function cif_container_set_value(container, item_name, val)
    ccall((:cif_container_set_value, libcif), Cint, (Ptr{cif_container_tp}, Ptr{Cint}, Ptr{cif_value_tp}), container, item_name, val)
end

function cif_container_remove_item(container, item_name)
    ccall((:cif_container_remove_item, libcif), Cint, (Ptr{cif_container_tp}, Ptr{Cint}), container, item_name)
end

function cif_loop_free(loop)
    ccall((:cif_loop_free, libcif), Cvoid, (Ptr{cif_loop_tp},), loop)
end

function cif_loop_destroy(loop)
    ccall((:cif_loop_destroy, libcif), Cint, (Ptr{cif_loop_tp},), loop)
end

function cif_loop_get_category(loop, category)
    ccall((:cif_loop_get_category, libcif), Cint, (Ptr{cif_loop_tp}, Ptr{Ptr{Cint}}), loop, category)
end

function cif_loop_set_category(loop, category)
    ccall((:cif_loop_set_category, libcif), Cint, (Ptr{cif_loop_tp}, Ptr{Cint}), loop, category)
end

function cif_loop_get_names(loop, item_names)
    ccall((:cif_loop_get_names, libcif), Cint, (Ptr{cif_loop_tp}, Ptr{Ptr{Ptr{Cint}}}), loop, item_names)
end

function cif_loop_add_item(loop, item_name, val)
    ccall((:cif_loop_add_item, libcif), Cint, (Ptr{cif_loop_tp}, Ptr{Cint}, Ptr{cif_value_tp}), loop, item_name, val)
end

function cif_loop_add_packet(loop, packet)
    ccall((:cif_loop_add_packet, libcif), Cint, (Ptr{cif_loop_tp}, Ptr{cif_packet_tp}), loop, packet)
end

function cif_loop_get_packets(loop, iterator)
    ccall((:cif_loop_get_packets, libcif), Cint, (Ptr{cif_loop_tp}, Ptr{Ptr{cif_pktitr_tp}}), loop, iterator)
end

function cif_pktitr_close(iterator)
    ccall((:cif_pktitr_close, libcif), Cint, (Ptr{cif_pktitr_tp},), iterator)
end

function cif_pktitr_abort(iterator)
    ccall((:cif_pktitr_abort, libcif), Cint, (Ptr{cif_pktitr_tp},), iterator)
end

function cif_pktitr_next_packet(iterator, packet)
    ccall((:cif_pktitr_next_packet, libcif), Cint, (Ptr{cif_pktitr_tp}, Ptr{Ptr{cif_packet_tp}}), iterator, packet)
end

function cif_pktitr_update_packet(iterator, packet)
    ccall((:cif_pktitr_update_packet, libcif), Cint, (Ptr{cif_pktitr_tp}, Ptr{cif_packet_tp}), iterator, packet)
end

function cif_pktitr_remove_packet(iterator)
    ccall((:cif_pktitr_remove_packet, libcif), Cint, (Ptr{cif_pktitr_tp},), iterator)
end

function cif_packet_create(packet, names)
    ccall((:cif_packet_create, libcif), Cint, (Ptr{Ptr{cif_packet_tp}}, Ptr{Ptr{Cint}}), packet, names)
end

function cif_packet_get_names(packet, names)
    ccall((:cif_packet_get_names, libcif), Cint, (Ptr{cif_packet_tp}, Ptr{Ptr{Ptr{Cint}}}), packet, names)
end

function cif_packet_set_item(packet, name, value)
    ccall((:cif_packet_set_item, libcif), Cint, (Ptr{cif_packet_tp}, Ptr{Cint}, Ptr{cif_value_tp}), packet, name, value)
end

function cif_packet_get_item(packet, name, value)
    ccall((:cif_packet_get_item, libcif), Cint, (Ptr{cif_packet_tp}, Ptr{Cint}, Ptr{Ptr{cif_value_tp}}), packet, name, value)
end

function cif_packet_remove_item(packet, name, value)
    ccall((:cif_packet_remove_item, libcif), Cint, (Ptr{cif_packet_tp}, Ptr{Cint}, Ptr{Ptr{cif_value_tp}}), packet, name, value)
end

function cif_packet_free(packet)
    ccall((:cif_packet_free, libcif), Cvoid, (Ptr{cif_packet_tp},), packet)
end

function cif_value_create(kind, value)
    ccall((:cif_value_create, libcif), Cint, (cif_kind_tp, Ptr{Ptr{cif_value_tp}}), kind, value)
end

function cif_value_clean(value)
    ccall((:cif_value_clean, libcif), Cvoid, (Ptr{cif_value_tp},), value)
end

function cif_value_free(value)
    ccall((:cif_value_free, libcif), Cvoid, (Ptr{cif_value_tp},), value)
end

function cif_value_clone(value, clone)
    ccall((:cif_value_clone, libcif), Cint, (Ptr{cif_value_tp}, Ptr{Ptr{cif_value_tp}}), value, clone)
end

function cif_value_init(value, kind)
    ccall((:cif_value_init, libcif), Cint, (Ptr{cif_value_tp}, cif_kind_tp), value, kind)
end

function cif_value_init_char(value, text)
    ccall((:cif_value_init_char, libcif), Cint, (Ptr{cif_value_tp}, Ptr{Cint}), value, text)
end

function cif_value_copy_char(value, text)
    ccall((:cif_value_copy_char, libcif), Cint, (Ptr{cif_value_tp}, Ptr{Cint}), value, text)
end

function cif_value_parse_numb(numb, text)
    ccall((:cif_value_parse_numb, libcif), Cint, (Ptr{cif_value_tp}, Ptr{Cint}), numb, text)
end

function cif_value_init_numb(numb, val, su, scale, max_leading_zeroes)
    ccall((:cif_value_init_numb, libcif), Cint, (Ptr{cif_value_tp}, Cdouble, Cdouble, Cint, Cint), numb, val, su, scale, max_leading_zeroes)
end

function cif_value_autoinit_numb(numb, val, su, su_rule)
    ccall((:cif_value_autoinit_numb, libcif), Cint, (Ptr{cif_value_tp}, Cdouble, Cdouble, Cuint), numb, val, su, su_rule)
end

function cif_value_kind(value)
    ccall((:cif_value_kind, libcif), cif_kind_tp, (Ptr{cif_value_tp},), value)
end

function cif_value_is_quoted(value)
    ccall((:cif_value_is_quoted, libcif), cif_quoted_tp, (Ptr{cif_value_tp},), value)
end

function cif_value_set_quoted(value, quoted)
    ccall((:cif_value_set_quoted, libcif), Cint, (Ptr{cif_value_tp}, cif_quoted_tp), value, quoted)
end

function cif_value_get_number(numb, val)
    ccall((:cif_value_get_number, libcif), Cint, (Ptr{cif_value_tp}, Ptr{Cdouble}), numb, val)
end

function cif_value_get_su(numb, su)
    ccall((:cif_value_get_su, libcif), Cint, (Ptr{cif_value_tp}, Ptr{Cdouble}), numb, su)
end

function cif_value_get_text(value, text)
    ccall((:cif_value_get_text, libcif), Cint, (Ptr{cif_value_tp}, Ptr{Ptr{Cint}}), value, text)
end

function cif_value_get_element_count(value, count)
    ccall((:cif_value_get_element_count, libcif), Cint, (Ptr{cif_value_tp}, Ptr{Csize_t}), value, count)
end

function cif_value_get_element_at(value, index, element)
    ccall((:cif_value_get_element_at, libcif), Cint, (Ptr{cif_value_tp}, Csize_t, Ptr{Ptr{cif_value_tp}}), value, index, element)
end

function cif_value_set_element_at(value, index, element)
    ccall((:cif_value_set_element_at, libcif), Cint, (Ptr{cif_value_tp}, Csize_t, Ptr{cif_value_tp}), value, index, element)
end

function cif_value_insert_element_at(value, index, element)
    ccall((:cif_value_insert_element_at, libcif), Cint, (Ptr{cif_value_tp}, Csize_t, Ptr{cif_value_tp}), value, index, element)
end

function cif_value_remove_element_at(value, index, element)
    ccall((:cif_value_remove_element_at, libcif), Cint, (Ptr{cif_value_tp}, Csize_t, Ptr{Ptr{cif_value_tp}}), value, index, element)
end

function cif_value_get_keys(table, keys)
    ccall((:cif_value_get_keys, libcif), Cint, (Ptr{cif_value_tp}, Ptr{Ptr{Ptr{Cint}}}), table, keys)
end

function cif_value_set_item_by_key(table, key, item)
    ccall((:cif_value_set_item_by_key, libcif), Cint, (Ptr{cif_value_tp}, Ptr{Cint}, Ptr{cif_value_tp}), table, key, item)
end

function cif_value_get_item_by_key(table, key, value)
    ccall((:cif_value_get_item_by_key, libcif), Cint, (Ptr{cif_value_tp}, Ptr{Cint}, Ptr{Ptr{cif_value_tp}}), table, key, value)
end

function cif_value_remove_item_by_key(table, key, value)
    ccall((:cif_value_remove_item_by_key, libcif), Cint, (Ptr{cif_value_tp}, Ptr{Cint}, Ptr{Ptr{cif_value_tp}}), table, key, value)
end

function cif_get_api_version(version)
    ccall((:cif_get_api_version, libcif), Cint, (Ptr{Ptr{Cchar}},), version)
end

function cif_u_strdup(str)
    ccall((:cif_u_strdup, libcif), Ptr{Cint}, (Ptr{Cint},), str)
end

function cif_normalize(src, srclen, normalized)
    ccall((:cif_normalize, libcif), Cint, (Ptr{Cint}, Cint, Ptr{Ptr{Cint}}), src, srclen, normalized)
end

function cif_cstr_to_ustr(cstr, srclen, ustr)
    ccall((:cif_cstr_to_ustr, libcif), Cint, (Ptr{Cchar}, Cint, Ptr{Ptr{Cint}}), cstr, srclen, ustr)
end

function cif_analyze_string(str, allow_unquoted, allow_triple_quoted, length_limit, result)
    ccall((:cif_analyze_string, libcif), Cint, (Ptr{Cint}, Cint, Cint, Cint, Ptr{cif_string_analysis_s}), str, allow_unquoted, allow_triple_quoted, length_limit, result)
end

function cif_is_reserved_string(str)
    ccall((:cif_is_reserved_string, libcif), Cint, (Ptr{Cint},), str)
end

# Skipping MacroDefinition: WARN_UNUSED __attribute__ ( ( __warn_unused_result__ ) )

const CIF_OK = 0

const CIF_FINISHED = 1

const CIF_ERROR = 2

const CIF_MEMORY_ERROR = 3

const CIF_INVALID_HANDLE = 4

const CIF_INTERNAL_ERROR = 5

const CIF_ARGUMENT_ERROR = 6

const CIF_MISUSE = 7

const CIF_NOT_SUPPORTED = 8

const CIF_ENVIRONMENT_ERROR = 9

const CIF_CLIENT_ERROR = 10

const CIF_DUP_BLOCKCODE = 11

const CIF_INVALID_BLOCKCODE = 12

const CIF_NOSUCH_BLOCK = 13

const CIF_DUP_FRAMECODE = 21

const CIF_INVALID_FRAMECODE = 22

const CIF_NOSUCH_FRAME = 23

const CIF_CAT_NOT_UNIQUE = 31

const CIF_INVALID_CATEGORY = 32

const CIF_NOSUCH_LOOP = 33

const CIF_RESERVED_LOOP = 34

const CIF_WRONG_LOOP = 35

const CIF_EMPTY_LOOP = 36

const CIF_NULL_LOOP = 37

const CIF_DUP_ITEMNAME = 41

const CIF_INVALID_ITEMNAME = 42

const CIF_NOSUCH_ITEM = 43

const CIF_AMBIGUOUS_ITEM = 44

const CIF_INVALID_PACKET = 52

const CIF_PARTIAL_PACKET = 53

const CIF_DISALLOWED_VALUE = 62

const CIF_INVALID_NUMBER = 72

const CIF_INVALID_INDEX = 73

const CIF_INVALID_BARE_VALUE = 74

const CIF_INVALID_CHAR = 102

const CIF_UNMAPPED_CHAR = 103

const CIF_DISALLOWED_CHAR = 104

const CIF_MISSING_SPACE = 105

const CIF_MISSING_ENDQUOTE = 106

const CIF_UNCLOSED_TEXT = 107

const CIF_OVERLENGTH_LINE = 108

const CIF_DISALLOWED_INITIAL_CHAR = 109

const CIF_WRONG_ENCODING = 110

const CIF_NO_BLOCK_HEADER = 113

const CIF_FRAME_NOT_ALLOWED = 122

const CIF_NO_FRAME_TERM = 123

const CIF_UNEXPECTED_TERM = 124

const CIF_EOF_IN_FRAME = 126

const CIF_RESERVED_WORD = 132

const CIF_MISSING_VALUE = 133

const CIF_UNEXPECTED_VALUE = 134

const CIF_UNEXPECTED_DELIM = 135

const CIF_MISSING_DELIM = 136

const CIF_MISSING_KEY = 137

const CIF_UNQUOTED_KEY = 138

const CIF_MISQUOTED_KEY = 139

const CIF_NULL_KEY = 140

const CIF_TRAVERSE_CONTINUE = 0

const CIF_TRAVERSE_SKIP_CURRENT = -1

const CIF_TRAVERSE_SKIP_SIBLINGS = -2

const CIF_TRAVERSE_END = -3

const CIF_LINE_LENGTH = 2048

const CIF_NAMELEN_LIMIT = CIF_LINE_LENGTH

const cif_uchar_nul = 0

const CIF_SCALARS = cif_uchar_nul

const cif_block_free = cif_container_free

const cif_block_destroy = cif_container_destroy

const cif_block_create_frame = cif_container_create_frame

const cif_block_get_frame = cif_container_get_frame

const cif_block_get_all_frames = cif_container_get_all_frames

const cif_frame_free = cif_container_free

const cif_frame_destroy = cif_container_destroy
