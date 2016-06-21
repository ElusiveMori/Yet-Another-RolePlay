// Source: http://www.hiveworkshop.com/threads/accessing-memory-from-the-script-its-time-of-the-revolution.279262/

library Memory initializer Init requires Typecast

// Variables must be public so they have undecorated names
globals
    integer teamScore // Memory array
    integer index     // Desired address
    integer bestScore // Returned value
    integer teamCount // Used to crash the Jass VM. Never use this variable!
    trigger MemReader = CreateTrigger()
endglobals

/* This code will change in the future, but the syntax will be the same
   Memory[i] returns the contents of memory at the address (i*4).
   Always pass the address you want to read divided by 4 !!! */

struct Memory
    static method operator [] takes integer address returns integer
        set index = address
        call TriggerEvaluate(MemReader)
        return bestScore
    endmethod

    static method operator []= takes integer address, integer value returns nothing
        return //not implemented
    endmethod
endstruct

private function Nothing takes nothing returns nothing
    return
endfunction

// Functions that take arguments normally can't be used as code.
//# +nosemanticerror
private function Init takes nothing returns nothing
    set teamScore = C2I(function Nothing)-8
    call TriggerAddCondition(MemReader, Condition(I2C(1648+C2I(function MeleeTournamentFinishNowRuleA))))
endfunction

endlibrary