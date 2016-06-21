/* Provides detection of the game version and initializes all
   version-specific addresses. Currently supported versions
   are 1.26 and 1.27, windows only. My goal is to support all
   versions since 1.24b at windows, and 1.27a on Mac. */

// Source: http://www.hiveworkshop.com/threads/accessing-memory-from-the-script-its-time-of-the-revolution.279262/

library Version initializer Init requires Memory

globals
    integer A
    integer array l__A
    integer GameBase
    integer GameState
    integer pUnitData
    integer pAbilityData
endglobals

private function ImLazy takes nothing returns nothing
    set l__A[1] = 1
endfunction

private function Typecast takes nothing returns nothing
    local integer A
endfunction

//# +nosemanticerror
private function A2I takes nothing returns integer
    return l__A
    return 0
endfunction

function Init26 takes nothing returns nothing
    set GameBase = Memory[A2I()/4]/4-0x254418
    set GameState = GameBase+0x2AD97D
    set pUnitData = GameBase+0x2AD11E
    set pAbilityData = GameBase+0x2ACF99
endfunction

function Init27 takes nothing returns nothing
    set GameBase = Memory[A2I()/4]/4-0x298ECC
    set GameState = GameBase+0x2F908E
    set pUnitData = GameBase+0x2FB123
    set pAbilityData = GameBase+0x2FB351
endfunction

private function Init takes nothing returns nothing
    local integer i
    call ImLazy()
    set i = Memory[A2I()/4]
    set i = i - Memory[i/4]
    if i == 2586768 then
        call Init27()
    elseif i == 5205600 then
        call Init26()
    else
        call BJDebugMsg("Unsupported version. All memory access is disabled")
        call DestroyTrigger(MemReader)
        set MemReader = null
    endif
endfunction

endlibrary