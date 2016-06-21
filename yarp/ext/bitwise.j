/* Provides the binary AND, OR and XOR operations, using natives
   and memory reading. This should be faster than all alternatives
   that use math operations and/or arrays */

// Source: http://www.hiveworkshop.com/threads/accessing-memory-from-the-script-its-time-of-the-revolution.279262/

library Bitwise requires Memory, Version

globals
    constant gametype GAME_TYPE_ALL = ConvertGameType(0xFFFFFFFF)
endglobals

function GetGameTypeSupported takes nothing returns integer
    return Memory[Memory[Memory[GameState]/4+12]/4+12]
endfunction

function BitwiseNot takes integer i returns integer
    return 0xFFFFFFFF - i
endfunction

function BitwiseOr takes integer a, integer b returns integer
    call SetGameTypeSupported(GAME_TYPE_ALL, false)
    call SetGameTypeSupported(ConvertGameType(a), true)
    call SetGameTypeSupported(ConvertGameType(b), true)
    return GetGameTypeSupported()
endfunction

function BitwiseAnd takes integer a, integer b returns integer
    call SetGameTypeSupported(GAME_TYPE_ALL, false)
    call SetGameTypeSupported(ConvertGameType(a), true)
    call SetGameTypeSupported(ConvertGameType(BitwiseNot(b)), false)
    return GetGameTypeSupported()
endfunction

function BitwiseXor takes integer a, integer b returns integer
    local integer i
    call SetGameTypeSupported(GAME_TYPE_ALL, false)
    call SetGameTypeSupported(ConvertGameType(a), true)
    call SetGameTypeSupported(ConvertGameType(b), false)
    set i = GetGameTypeSupported()
    call SetGameTypeSupported(ConvertGameType(b), true)
    call SetGameTypeSupported(ConvertGameType(a), false)
    call SetGameTypeSupported(ConvertGameType(i), true)
    return GetGameTypeSupported()
endfunction

endlibrary
 