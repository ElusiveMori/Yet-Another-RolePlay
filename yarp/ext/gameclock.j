library GameClock initializer Init
    //============================================================================================
    // GameClock library (Version 1.02)
    //   by Pyrogasm (4/14/09)
    //
    // - The purpose of this library is to give a standardized platform for tracking
    //   the current duration of a game using a global timer and TimerGetElapsed().
    //
    // - The output can either be a real number (with which you may do whatever you
    //   want), or a string in the format HH:MM:SS.
    //
    // - The boolean "Exact" determines if the output should be the full elapsed time,
    //   or if it should be truncated, showing the time as a clock would.
    //
    // - If you know that you will only ever use exact or truncated values, you can
    //   shorten GetElapsedGameTime into one line to make it inline-friendly and save
    //   yourself a few nanoseconds of code execution.
    //
    // - Version 1.00: Release
    // - Version 1.01: Removed some documentation, removed unnecessary loops, altered
    //                 GAME_LENGTH
    // - Version 1.02: Inlined CreateTimer() call, removed example library
    //============================================================================================

    globals
        private constant real GAME_LENGTH = 72000.00 //20 hours
        private constant real GAME_SPEED = 1.00 //Might be changed if game speed is altered with UI files

        //The point of no return
        private timer Clock = CreateTimer()
    endglobals

    function GetElapsedGameTime takes boolean Exact returns real
        local real E = TimerGetElapsed(Clock)*GAME_SPEED

        if not Exact then
            set E = R2I(E)
        endif

        return E
    endfunction

    function GetElapsedGameTimeString takes boolean Exact returns string
        local real E = TimerGetElapsed(Clock)*GAME_SPEED
        local integer H = 0
        local integer M = 0
        local string S
        
        set H = R2I(E/3600.00)
        set E = E-3600.00*H

        set M = R2I(E/60.00)
        set E = E-60.00*M


        if H < 10 then
            set S = "0" + I2S(H) + ":"
        else
            set S = I2S(H) + ":"
        endif

        if M < 10 then
            set S = S + "0" + I2S(M) + ":"
        else
            set S = I2S(M) + ":"
        endif

        if E < 10 then
            set S = S + "0"
        endif

        if Exact then
            set S = S + R2S(E)
        else
            set S = S + I2S(R2I(E))
        endif


        return S
    endfunction


    private function Init takes nothing returns nothing
        call TimerStart(Clock, GAME_LENGTH, false, null)
    endfunction
endlibrary