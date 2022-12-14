const ERROR_CODES = Dict(
    0 => "no error",
    1 => "iteration finished",
    2 => "unspecified error",
    3 => "invalid object handle provided",
    4 => "CIF API internal error",
    5 => "invalid function argument",
    6 => "improper CIF API use",
    7 => "feature not supported",
    8 => "wrong or inadequate operating environment",
    9 => "application-directed error",
    11 => "duplicate data block code",
    12 => "invalid data block code",
    13 => "no data block exists for the specified code",
    21 => "duplicate save frame code",
    22 => "invalid save frame code",
    23 => "no save frame exists for the specified code and data block",
    31 => "the specified category does not uniquely identify a loop",
    32 => "the specified category identifier is invalid",
    33 => "no loop is assigned to the specified category",
    34 => "the scalar loop may not be manipulated as requested",
    35 => "the specified item does not belong to the specified loop",
    36 => "loop with no data",
    37 => "loop with no data names",
    41 => "duplicate item name",
    42 => "invalid item name",
    43 => "no item bears the specified name",
    44 => "only one of the specified item's several values is provided",
    52 => "the provided packet object is not valid for the requested operation",
    53 => "too few values in the last packet of a loop",
    62 => "wrong value type for a table index",
    72 => "the specified string could not be parsed as a number",
    73 => "the specified string is not a valid table index",
    74 => "a data value that must be quoted was encountered bare",
    102 => "invalid encoded character",
    103 => "unmappable character",
    104 => "encountered a character that is not allowed to appear in CIF",
    105 => "required whitespace separation was missing",
    106 => "encountered an un-terminated inline quoted string",
    107 => "a multi-line string was not terminated before the end of the file",
    108 => "encountered an input line exceeding the length limit",
    109 => "the first character of the input is disallowed at that position",
    110 => "while parsing CIF 2.0, the character encoding is not UTF-8",
    113 => "non-whitespace was encountered outside any data block",
    122 => "a save frame was encountered, but save frame parsing is disabled",
    123 => "a save frame terminator is missing at the apparent end of a frame",
    124 => "a save frame terminator was encountered where none was expected",
    126 => "the end of the input was encountered inside a save frame",
    132 => "a CIF reserved word was encountered as an unquoted data value",
    133 => "missing data value",
    134 => "unexpected data value",
    135 => "misplaced list or table delimiter",
    136 => "missing list or table delimiter",
    137 => "missing a key for a table entry",
    138 => "an unquoted table key was encountered",
    139 => "encountered a text block used as a table key",
    140 => "a null table key was encountered",
    141 => "a line of a prefixed text field body omitted the prefix"
)

struct CifError <: Exception
    msg::String
end

function checkerror(return_code)
    if return_code != 0
        throw(CifError(ERROR_CODES[return_code]))
    end
end
