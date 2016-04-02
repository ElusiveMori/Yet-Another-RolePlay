library StringLib initializer Init
    globals
        integer STRING_INDEX_NONE       = -1
        string  STRING_INVALID_SEGMENT  = ""

        private hashtable ht_hash
        
        private key KEY_ASCII
        private key KEY_UTF8
    endglobals
    
    struct StringSegments
        private string s
        private integer sLen
        private string delim
        private integer dLen
        private integer pos
        
        private integer count
        
        private method calculateCount takes nothing returns nothing
            local integer i = .pos
            local integer prev = .pos
            
            set .count = 0
            
            if .dLen == 0 or .sLen == 0 then
                return
            endif
            
            // calculate the count beforehand
            loop
                if i >= .sLen then
                    if i - prev > 0 then
                        set .count = .count + 1
                    endif
                    exitwhen true
                endif
                
                if SubString(.s, i, i+.dLen) == .delim then
                    if i - prev > 0 then
                        // a valid token
                        set .count = .count + 1
                        set i = i + .dLen
                        set prev = i    
                    endif
                    set i = i + .dLen
                    set prev = i
                else
                    set i = i + 1
                endif
            endloop
        endmethod
        
        public static method create takes string s, string delim returns StringSegments
            local StringSegments seg = .allocate()
            set seg.s = s
            set seg.pos = 0
            set seg.sLen = StringLength(s)
            set seg.delim = delim
            set seg.dLen = StringLength(delim)
            
            call seg.calculateCount()
            return seg
        endmethod
        
        public method countSegments takes nothing returns integer
            return .count
        endmethod
        
        public method hasMoreSegments takes nothing returns boolean
            return .count > 0
        endmethod

        public method nextSegment takes nothing returns string
            local integer i = .pos
            local string str

            if .count <= 0 then
                return STRING_INVALID_SEGMENT
            endif
            
            loop
                loop
                    set str = SubString(.s, i, i+.dLen)
                    exitwhen str == .delim
                    exitwhen str == ""
                    exitwhen str == null
                    set i = i + 1
                endloop
                if i-.pos > 0 then
                    // return segment only if it has contents
                    set str = SubString(.s, .pos, i)
                    set .pos = i // don't skip the delimiter right now.
                    set .count = .count - 1 // decrement the count
                    
                    exitwhen true
                endif
                // continue until valid segments come out
                set .pos = i+.dLen
                set i = .pos
            endloop

            return str
        endmethod

        public method nextSegmentEx takes string delim returns string
            set .delim = delim
            set .dLen = StringLength(delim)
            call .calculateCount()
            return .nextSegment()
        endmethod
    endstruct

    function StringTrimLeft takes string str returns string
        local string s
        local integer left
        local integer right

        if str == null then
            return null
        endif

        set left = 0
        set right = StringLength(str)

        loop
            exitwhen left >= right
            set s = SubString(str, left, left+1)
            exitwhen s != " " and s != "\n" and s != "\r" and s != "\t"
            set left = left + 1
        endloop

        return SubString(str, left, right)
    endfunction

    function StringTrimRight takes string str returns string
        local string s
        local integer right

        if str == null then
            return null
        endif

        set right = StringLength(str)

        loop
            exitwhen right <= 0
            set s = SubString(str, right-1, right)
            exitwhen s != " " and s != "\n" and s != "\r" and s != "\t"
            set right = right - 1
        endloop

        return SubString(str, 0, right)
    endfunction

    function StringTrim takes string str returns string
        local string s
        local integer left
        local integer right

        if str == null then
            return null
        endif

        set left = 0
        set right = StringLength(str)

        loop
            exitwhen left >= right
            set s = SubString(str, left, left+1)
            exitwhen s != " " and s != "\n" and s != "\r" and s != "\t"
            set left = left + 1
        endloop

        loop
            exitwhen right <= left
            set s = SubString(str, right-1, right)
            exitwhen s != " " and s != "\n" and s != "\r" and s != "\t"
            set right = right - 1
        endloop

        return SubString(str, left, right)
    endfunction

    function StringIndexOf takes string source, string toFind, boolean caseSensitive returns integer
        local integer length = StringLength(source)
        local integer toFindLen = StringLength(toFind)
        local integer i = 0

        if not caseSensitive then
            // case-insensitive search
            set source = StringCase(source, true)
            set toFind = StringCase(toFind, true)
        endif
        
        loop
            exitwhen i + toFindLen > length
            if SubString(source, i, i + toFindLen) == toFind then
                return i
            endif
            set i = i + 1
        endloop

        return STRING_INDEX_NONE
    endfunction

    function StringIndexOfReverse takes string source, string toFind, boolean caseSensitive returns integer
        local integer toFindLen = StringLength(toFind)
        local integer i = StringLength(source) - toFindLen
        
        if not caseSensitive then
            // case-insensitive search
            set source = StringCase(source, true)
            set toFind = StringCase(toFind, true)
        endif

        loop
            exitwhen i < 0
            if SubString(source, i, i + toFindLen) == toFind then
                return i
            endif
            set i = i - 1
        endloop

        return STRING_INDEX_NONE
    endfunction
    
    function StringReplace takes string source, string old, string new, boolean caseSensitive returns string
        local integer ri = 0
        local integer li = 0
        local integer length = StringLength(source)
        local integer oldLength = StringLength(old)
        local string result = ""
        local string compare = source
        
        if not caseSensitive then
            // case-insensitive search
            set old = StringCase(old, true)
            set compare = StringCase(source, true)
        endif
        
        loop
            exitwhen ri >= length
            if SubString(compare, ri, ri+oldLength) == old then
                // found the match!
                set result = result + SubString(source, li, ri) + new
                set ri = ri + oldLength
                set li = ri
            else
                set ri = ri + 1
            endif
        endloop
        
        set result = result + SubString(source, li, length)
        
        return result
    endfunction
    
    function StringHashCS takes string s returns integer
        local integer ri = 0
        local integer li = 0
        local integer length = StringLength(s)
        local string result = ""
        local string ss
        
        loop
            exitwhen ri >= length
            set ss = SubString(s, ri, ri+1)
            if ss == "\\" then
                set result = result + SubString(s, li, ri) + "\\\\"
                
                set ri = ri + 1
                set li = ri
            elseif StringCase(ss, false) != ss then
                // this is a uppercase character; make it different.
                set result = result + SubString(s, li, ri) + "\\" + ss
                
                set ri = ri + 1
                set li = ri
            else
                set ri = ri + 1
            endif
        endloop
        
        set result = result + SubString(s, li, length)
        
        return StringHash(result)
    endfunction

    function IsStringAscii takes string s returns boolean
        local integer i = 0
        local integer len = StringLength(s)

        loop
            exitwhen i >= len
            // current implementation of StringHashCS guarantees using StringHash works in this context
            // since StringHash result is subset of StringHashCS results for characters up to 0x7F.
            if not HaveSavedInteger(ht_hash, KEY_ASCII, StringHash(SubString(s,i,i+1))) then
                return false
            endif
            set i = i + 1
        endloop
        return true
    endfunction

    function StringAsciiAt takes string s, integer index returns integer
        return LoadInteger(ht_hash, KEY_ASCII, StringHashCS(SubString(s,index,index+1)))
    endfunction

    function StringLengthUtf8 takes string s returns integer
        // calculates proper length of the string in terms of UTF-8 characters.
        local integer i = 0
        local integer len = StringLength(s)
        local integer actualLen = 0
        local integer width

        loop
            exitwhen i >= len
            set width = LoadInteger(ht_hash, KEY_UTF8, StringHash(SubString(s,i,i+1)))
            if width > 0 then
                set actualLen = actualLen + 1
                set i = i + width
            else
                debug call BJDebugMsg("StringLengthUtf8 warning: supplied string is invalid!")
                return len
            endif
        endloop

        return actualLen
    endfunction
    
    function IsStringValidUtf8 takes string s returns boolean
        local integer i = 0
        local integer len = StringLength(s)
        local integer width
    
        if s == null then
            return false
        endif

        loop
            exitwhen i >= len
            set width = LoadInteger(ht_hash, KEY_UTF8, StringHash(SubString(s,i,i+1)))
            if width <= 0 then
                return false
            endif
            set i = i + width
        endloop
        
        return true
    endfunction

    private function InitAsciiHash takes nothing returns nothing
        call SaveInteger(ht_hash, KEY_ASCII, -1187441752,   1)
        call SaveInteger(ht_hash, KEY_ASCII, 1394816653,    2)
        call SaveInteger(ht_hash, KEY_ASCII, 1315431429,    3)
        call SaveInteger(ht_hash, KEY_ASCII, 784919188,     4)
        call SaveInteger(ht_hash, KEY_ASCII, 748266476,     5)
        call SaveInteger(ht_hash, KEY_ASCII, 1285056042,    6)
        call SaveInteger(ht_hash, KEY_ASCII, -1736724759,   7)
        call SaveInteger(ht_hash, KEY_ASCII, -145620903,    8)
        call SaveInteger(ht_hash, KEY_ASCII, 149274451,     9)
        call SaveInteger(ht_hash, KEY_ASCII, 1188730162,    10)
        call SaveInteger(ht_hash, KEY_ASCII, -1640706678,   11)
        call SaveInteger(ht_hash, KEY_ASCII, 688136737,     12)
        call SaveInteger(ht_hash, KEY_ASCII, -1200132991,   13)
        call SaveInteger(ht_hash, KEY_ASCII, -478531815,    14)
        call SaveInteger(ht_hash, KEY_ASCII, -531179111,    15)
        call SaveInteger(ht_hash, KEY_ASCII, 37034828,      16)
        call SaveInteger(ht_hash, KEY_ASCII, -478078515,    17)
        call SaveInteger(ht_hash, KEY_ASCII, 1036153450,    18)
        call SaveInteger(ht_hash, KEY_ASCII, 1211942047,    19)
        call SaveInteger(ht_hash, KEY_ASCII, 1540972262,    20)
        call SaveInteger(ht_hash, KEY_ASCII, 1736584905,    21)
        call SaveInteger(ht_hash, KEY_ASCII, -1242301218,   22)
        call SaveInteger(ht_hash, KEY_ASCII, 117437270,     23)
        call SaveInteger(ht_hash, KEY_ASCII, -1264404286,   24)
        call SaveInteger(ht_hash, KEY_ASCII, -1865310487,   25)
        call SaveInteger(ht_hash, KEY_ASCII, -1140988821,   26)
        call SaveInteger(ht_hash, KEY_ASCII, 142609959,     27)
        call SaveInteger(ht_hash, KEY_ASCII, -1178686164,   28)
        call SaveInteger(ht_hash, KEY_ASCII, 135849431,     29)
        call SaveInteger(ht_hash, KEY_ASCII, -1584298261,   30)
        call SaveInteger(ht_hash, KEY_ASCII, -1815690774,   31)
        call SaveInteger(ht_hash, KEY_ASCII, -1636555145,   32)
        call SaveInteger(ht_hash, KEY_ASCII, 1987317120,    33)
        call SaveInteger(ht_hash, KEY_ASCII, 633424007,     34)
        call SaveInteger(ht_hash, KEY_ASCII, 2450395,       35)
        call SaveInteger(ht_hash, KEY_ASCII, 533837621,     36)
        call SaveInteger(ht_hash, KEY_ASCII, -38766579,     37)
        call SaveInteger(ht_hash, KEY_ASCII, 560338319,     38)
        call SaveInteger(ht_hash, KEY_ASCII, -1415544861,   39)
        call SaveInteger(ht_hash, KEY_ASCII, -200806104,    40)
        call SaveInteger(ht_hash, KEY_ASCII, -139998735,    41)
        call SaveInteger(ht_hash, KEY_ASCII, -173398357,    42)
        call SaveInteger(ht_hash, KEY_ASCII, 1974230908,    43)
        call SaveInteger(ht_hash, KEY_ASCII, 768817686,     44)
        call SaveInteger(ht_hash, KEY_ASCII, 2000040631,    45)
        call SaveInteger(ht_hash, KEY_ASCII, -270641191,    46)
        call SaveInteger(ht_hash, KEY_ASCII, 1838906452,    47)
        call SaveInteger(ht_hash, KEY_ASCII, -242600650,    48)
        call SaveInteger(ht_hash, KEY_ASCII, 1132341824,    49)
        call SaveInteger(ht_hash, KEY_ASCII, -647782241,    50)
        call SaveInteger(ht_hash, KEY_ASCII, -854572045,    51)
        call SaveInteger(ht_hash, KEY_ASCII, -680649701,    52)
        call SaveInteger(ht_hash, KEY_ASCII, -943650483,    53)
        call SaveInteger(ht_hash, KEY_ASCII, -671760605,    54)
        call SaveInteger(ht_hash, KEY_ASCII, 349230650,     55)
        call SaveInteger(ht_hash, KEY_ASCII, -1894922563,   56)
        call SaveInteger(ht_hash, KEY_ASCII, -1474492777,   57)
        call SaveInteger(ht_hash, KEY_ASCII, -1856883613,   58)
        call SaveInteger(ht_hash, KEY_ASCII, 283059908,     59)
        call SaveInteger(ht_hash, KEY_ASCII, -1959921300,   60)
        call SaveInteger(ht_hash, KEY_ASCII, 345613672,     61)
        call SaveInteger(ht_hash, KEY_ASCII, -1934701018,   62)
        call SaveInteger(ht_hash, KEY_ASCII, -1417475472,   63)
        call SaveInteger(ht_hash, KEY_ASCII, -2038820497,   64)
        call SaveInteger(ht_hash, KEY_ASCII, 1146790149,    65)
        call SaveInteger(ht_hash, KEY_ASCII, 1384166606,    66)
        call SaveInteger(ht_hash, KEY_ASCII, -725325753,    67)
        call SaveInteger(ht_hash, KEY_ASCII, -584388050,    68)
        call SaveInteger(ht_hash, KEY_ASCII, 412518583,     69)
        call SaveInteger(ht_hash, KEY_ASCII, -1345963440,   70)
        call SaveInteger(ht_hash, KEY_ASCII, -1284887430,   71)
        call SaveInteger(ht_hash, KEY_ASCII, -1583570888,   72)
        call SaveInteger(ht_hash, KEY_ASCII, -1237254502,   73)
        call SaveInteger(ht_hash, KEY_ASCII, -481405949,    74)
        call SaveInteger(ht_hash, KEY_ASCII, 486973866,     75)
        call SaveInteger(ht_hash, KEY_ASCII, -505384836,    76)
        call SaveInteger(ht_hash, KEY_ASCII, -2093990458,   77)
        call SaveInteger(ht_hash, KEY_ASCII, 2020834255,    78)
        call SaveInteger(ht_hash, KEY_ASCII, -177844388,    79)
        call SaveInteger(ht_hash, KEY_ASCII, 1723470677,    80)
        call SaveInteger(ht_hash, KEY_ASCII, 1254020812,    81)
        call SaveInteger(ht_hash, KEY_ASCII, 1767232362,    82)
        call SaveInteger(ht_hash, KEY_ASCII, 942926582,     83)
        call SaveInteger(ht_hash, KEY_ASCII, -949618489,    84)
        call SaveInteger(ht_hash, KEY_ASCII, 1893189801,    85)
        call SaveInteger(ht_hash, KEY_ASCII, -1794448918,   86)
        call SaveInteger(ht_hash, KEY_ASCII, -1620990925,   87)
        call SaveInteger(ht_hash, KEY_ASCII, 1834526017,    88)
        call SaveInteger(ht_hash, KEY_ASCII, 619915202,     89)
        call SaveInteger(ht_hash, KEY_ASCII, 1128511080,    90)
        call SaveInteger(ht_hash, KEY_ASCII, 465101845,     91)
        call SaveInteger(ht_hash, KEY_ASCII, -1519517876,   92)
        call SaveInteger(ht_hash, KEY_ASCII, 1290016498,    93)
        call SaveInteger(ht_hash, KEY_ASCII, 842508002,     94)
        call SaveInteger(ht_hash, KEY_ASCII, 1860810866,    95)
        call SaveInteger(ht_hash, KEY_ASCII, -1597441783,   96)
        call SaveInteger(ht_hash, KEY_ASCII, -1587459251,   97)
        call SaveInteger(ht_hash, KEY_ASCII, -1676716706,   98)
        call SaveInteger(ht_hash, KEY_ASCII, -1559655710,   99)
        call SaveInteger(ht_hash, KEY_ASCII, -1663695754,   100)
        call SaveInteger(ht_hash, KEY_ASCII, 597637742,     101)
        call SaveInteger(ht_hash, KEY_ASCII, 789744696,     102)
        call SaveInteger(ht_hash, KEY_ASCII, 558654156,     103)
        call SaveInteger(ht_hash, KEY_ASCII, -1626575360,   104)
        call SaveInteger(ht_hash, KEY_ASCII, 635090976,     105)
        call SaveInteger(ht_hash, KEY_ASCII, -1613012308,   106)
        call SaveInteger(ht_hash, KEY_ASCII, 636889825,     107)
        call SaveInteger(ht_hash, KEY_ASCII, -1692768153,   108)
        call SaveInteger(ht_hash, KEY_ASCII, 722102341,     109)
        call SaveInteger(ht_hash, KEY_ASCII, 695269389,     110)
        call SaveInteger(ht_hash, KEY_ASCII, 804913722,     111)
        call SaveInteger(ht_hash, KEY_ASCII, 849994952,     112)
        call SaveInteger(ht_hash, KEY_ASCII, 849344742,     113)
        call SaveInteger(ht_hash, KEY_ASCII, 801764373,     114)
        call SaveInteger(ht_hash, KEY_ASCII, 756959634,     115)
        call SaveInteger(ht_hash, KEY_ASCII, 824983937,     116)
        call SaveInteger(ht_hash, KEY_ASCII, -1023211619,   117)
        call SaveInteger(ht_hash, KEY_ASCII, 942949714,     118)
        call SaveInteger(ht_hash, KEY_ASCII, -541832965,    119)
        call SaveInteger(ht_hash, KEY_ASCII, -1449975558,   120)
        call SaveInteger(ht_hash, KEY_ASCII, -34188414,     121)
        call SaveInteger(ht_hash, KEY_ASCII, -1960837124,   122)
        call SaveInteger(ht_hash, KEY_ASCII, -344136570,    123)
        call SaveInteger(ht_hash, KEY_ASCII, 442407315,     124)
        call SaveInteger(ht_hash, KEY_ASCII, -914066048,    125)
        call SaveInteger(ht_hash, KEY_ASCII, -1920327611,   126)
        call SaveInteger(ht_hash, KEY_ASCII, -1894364130,   127)
    endfunction

    private function InitUtf8Hash takes nothing returns nothing
        call SaveInteger(ht_hash, KEY_UTF8, -1187441752,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 1394816653,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 1315431429,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 784919188,      1)
        call SaveInteger(ht_hash, KEY_UTF8, 748266476,      1)
        call SaveInteger(ht_hash, KEY_UTF8, 1285056042,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -1736724759,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -145620903,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 149274451,      1)
        call SaveInteger(ht_hash, KEY_UTF8, 1188730162,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -1640706678,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 688136737,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -1200132991,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -478531815,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -531179111,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 37034828,       1)
        call SaveInteger(ht_hash, KEY_UTF8, -478078515,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 1036153450,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 1211942047,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 1540972262,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 1736584905,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -1242301218,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 117437270,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -1264404286,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1865310487,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1140988821,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 142609959,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -1178686164,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 135849431,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -1584298261,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1815690774,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1636555145,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 1987317120,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 633424007,      1)
        call SaveInteger(ht_hash, KEY_UTF8, 2450395,        1)
        call SaveInteger(ht_hash, KEY_UTF8, 533837621,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -38766579,      1)
        call SaveInteger(ht_hash, KEY_UTF8, 560338319,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -1415544861,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -200806104,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -139998735,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -173398357,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 1974230908,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 768817686,      1)
        call SaveInteger(ht_hash, KEY_UTF8, 2000040631,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -270641191,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 1838906452,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -242600650,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 1132341824,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -647782241,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -854572045,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -680649701,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -943650483,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -671760605,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 349230650,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -1894922563,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1474492777,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1856883613,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 283059908,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -1959921300,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 345613672,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -1934701018,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1417475472,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -2038820497,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 1146790149,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 1384166606,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -725325753,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -584388050,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 412518583,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -1345963440,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1284887430,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1583570888,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1237254502,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -481405949,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 486973866,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -505384836,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -2093990458,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 2020834255,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -177844388,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 1723470677,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 1254020812,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 1767232362,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 942926582,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -949618489,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 1893189801,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -1794448918,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1620990925,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 1834526017,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 619915202,      1)
        call SaveInteger(ht_hash, KEY_UTF8, 1128511080,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 465101845,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -1519517876,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 1290016498,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 842508002,      1)
        call SaveInteger(ht_hash, KEY_UTF8, 1860810866,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -1597441783,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1587459251,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1676716706,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1559655710,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1663695754,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 597637742,      1)
        call SaveInteger(ht_hash, KEY_UTF8, 789744696,      1)
        call SaveInteger(ht_hash, KEY_UTF8, 558654156,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -1626575360,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 635090976,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -1613012308,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 636889825,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -1692768153,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 722102341,      1)
        call SaveInteger(ht_hash, KEY_UTF8, 695269389,      1)
        call SaveInteger(ht_hash, KEY_UTF8, 804913722,      1)
        call SaveInteger(ht_hash, KEY_UTF8, 849994952,      1)
        call SaveInteger(ht_hash, KEY_UTF8, 824983937,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -1023211619,    1)
        call SaveInteger(ht_hash, KEY_UTF8, 942949714,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -541832965,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -1449975558,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -34188414,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -1960837124,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -344136570,     1)
        call SaveInteger(ht_hash, KEY_UTF8, 442407315,      1)
        call SaveInteger(ht_hash, KEY_UTF8, -914066048,     1)
        call SaveInteger(ht_hash, KEY_UTF8, -1920327611,    1)
        call SaveInteger(ht_hash, KEY_UTF8, -1894364130,    1)

        call SaveInteger(ht_hash, KEY_UTF8, -821046842,     2)
        call SaveInteger(ht_hash, KEY_UTF8, 1965576605,     2)
        call SaveInteger(ht_hash, KEY_UTF8, 159638553,      2)
        call SaveInteger(ht_hash, KEY_UTF8, 1976614787,     2)
        call SaveInteger(ht_hash, KEY_UTF8, 172358365,      2)
        call SaveInteger(ht_hash, KEY_UTF8, -1487094743,    2)
        call SaveInteger(ht_hash, KEY_UTF8, 852857962,      2)
        call SaveInteger(ht_hash, KEY_UTF8, -1499360152,    2)
        call SaveInteger(ht_hash, KEY_UTF8, 388578373,      2)
        call SaveInteger(ht_hash, KEY_UTF8, -466619119,     2)
        call SaveInteger(ht_hash, KEY_UTF8, -580057007,     2)
        call SaveInteger(ht_hash, KEY_UTF8, -443785825,     2)
        call SaveInteger(ht_hash, KEY_UTF8, -635169143,     2)
        call SaveInteger(ht_hash, KEY_UTF8, -1421069964,    2)
        call SaveInteger(ht_hash, KEY_UTF8, -1232080964,    2)
        call SaveInteger(ht_hash, KEY_UTF8, -1195283317,    2)
        call SaveInteger(ht_hash, KEY_UTF8, -1145431583,    2)
        call SaveInteger(ht_hash, KEY_UTF8, 1065729488,     2)
        call SaveInteger(ht_hash, KEY_UTF8, 2057488321,     2)
        call SaveInteger(ht_hash, KEY_UTF8, -42326540,      2)
        call SaveInteger(ht_hash, KEY_UTF8, 2092530722,     2)
        call SaveInteger(ht_hash, KEY_UTF8, 701044297,      2)
        call SaveInteger(ht_hash, KEY_UTF8, -2016087502,    2)
        call SaveInteger(ht_hash, KEY_UTF8, 50775334,       2)
        call SaveInteger(ht_hash, KEY_UTF8, -1236243595,    2)
        call SaveInteger(ht_hash, KEY_UTF8, 379765120,      2)
        call SaveInteger(ht_hash, KEY_UTF8, 1483819556,     2)
        call SaveInteger(ht_hash, KEY_UTF8, 154860577,      2)
        call SaveInteger(ht_hash, KEY_UTF8, -1222483548,    2)
        call SaveInteger(ht_hash, KEY_UTF8, 847928083,      2)

        call SaveInteger(ht_hash, KEY_UTF8, -643770102,     3)
        call SaveInteger(ht_hash, KEY_UTF8, 1697315672,     3)
        call SaveInteger(ht_hash, KEY_UTF8, 152013319,      3)
        call SaveInteger(ht_hash, KEY_UTF8, -1048766234,    3)
        call SaveInteger(ht_hash, KEY_UTF8, 1817785734,     3)
        call SaveInteger(ht_hash, KEY_UTF8, 1772290269,     3)
        call SaveInteger(ht_hash, KEY_UTF8, 224611159,      3)
        call SaveInteger(ht_hash, KEY_UTF8, -941949360,     3)
        call SaveInteger(ht_hash, KEY_UTF8, -1964233184,    3)
        call SaveInteger(ht_hash, KEY_UTF8, -1853905496,    3)
        call SaveInteger(ht_hash, KEY_UTF8, -2147421637,    3)
        call SaveInteger(ht_hash, KEY_UTF8, -1324312884,    3)
        call SaveInteger(ht_hash, KEY_UTF8, -576610362,     3)
        call SaveInteger(ht_hash, KEY_UTF8, 1790768057,     3)
        call SaveInteger(ht_hash, KEY_UTF8, -2099350373,    3)
        call SaveInteger(ht_hash, KEY_UTF8, -1266365587,    3)

        call SaveInteger(ht_hash, KEY_UTF8, 1316854887,     4)
        call SaveInteger(ht_hash, KEY_UTF8, -2027516833,    4)
        call SaveInteger(ht_hash, KEY_UTF8, 1910426181,     4)
        call SaveInteger(ht_hash, KEY_UTF8, 760701047,      4)
    endfunction

    private function Init takes nothing returns nothing
        set ht_hash = InitHashtable()

        call InitAsciiHash()
        call InitUtf8Hash()
    endfunction
endlibrary