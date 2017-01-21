-- qtypetuples (sequence, qtype, grade, semester, qtypestr, name_zh, name_en)
local QT = {
    ['sequence'] = 1,
    ['qtype'] = 2,
    ['grade'] = 3,
    ['semester'] = 4,
    ['qtypestr'] = 5,
    ['name_zh'] = 6,
    ['name_en'] = 7,
    {1,  0x04, 1, 1, 'x+y:1',    '10以内加法',            'addition within 10'},
    {2,  0x05, 1, 1, 'x-y:1',    '10以内减法',            'subtraction within 10'},
    {3,  0x08, 1, 1, 'x+y:2',    '20以内不进位加法',      'carry-save addition within 20'},
    {4,  0x09, 1, 1, 'x-y:2',    '20以内不退位减法',      'subtraction without abdication within 20'},
    {5,  0x0C, 1, 1, 'x+y:3',    '20以内进位加法',        'addition with carry within 20'},
    {6,  0x0D, 1, 1, 'x-y:3',    '20以内退位减法',        'subtraction with abdication within 20'},
    {7,  0x90, 1, 1, 'x+y+z:1',  '10以内连加',            'continuous addition within 10'},
    {8,  0x95, 1, 1, 'x-y-z:1',  '10以内连减',            'continuous subtraction within 10'},
    {9,  0x91, 1, 1, 'x-y+z:1',  '10以内减加',            'subtraction and addition within 10'},
    {10, 0x94, 1, 1, 'x+y-z:1',  '10以内加减',            'addition and subtraction within 10'},
    {11, 0xA0, 1, 1, 'x+y+z:2',  '20以内连加',            'continuous addition within 20'},
    {12, 0xA5, 1, 1, 'x-y-z:2',  '20以内连减',            'continuous subtraction within 20'},
    {13, 0xA1, 1, 1, 'x-y+z:2',  '20以内减加',            'subtraction and addition within 20'},
    {14, 0xA4, 1, 1, 'x+y-z:2',  '20以内加减',            'addition and subtraction within 20'},
    {15, 0x10, 1, 2, 'x+y:4',    '100以内不进位加整十数', 'carry-save addition of whole 10 within 100'},
    {16, 0x11, 1, 2, 'x-y:4',    '100以内不退位减整十数', 'subtraction without abdication of whole 10 within 100'},
    {17, 0x14, 1, 2, 'x+y:5',    '100以内不进位加一位数', 'carry-save addition of single digit within 100'},
    {18, 0x15, 1, 2, 'x-y:5',    '100以内不退位减一位数', 'subtraction without abdication of single digit within 100'},
    {19, 0x18, 1, 2, 'x+y:6',    '100以内进位加一位数',   'addition with carry of single digit within 100'},
    {20, 0x19, 1, 2, 'x-y:6',    '100以内退位减一位数',   'subtraction with abdication of single digit within 100'},
    {21, 0x1C, 1, 2, 'x+y:7',    '100以内不进位加两位数', 'carry-save addition of double-digit within 100'},
    {22, 0x1D, 1, 2, 'x-y:7',    '100以内不退位减两位数', 'subtraction without abdication of double-digit within 100'},
    {23, 0x20, 1, 2, 'x+y:8',    '100以内进位加两位数',   'addition with carry of double-digit within 100'},
    {24, 0x21, 1, 2, 'x-y:8',    '100以内退位减两位数',   'subtraction with abdication of double-digit within 100'},
    {25, 0xB0, 1, 2, 'x+y+z:3',  '100以内连加',           'continuous addition within 100'},
    {26, 0xB5, 1, 2, 'x-y-z:3',  '100以内连减',           'continous subtraction within 100'},
    {27, 0x02, 2, 1, 'x*y',      '表内乘法',              'multiplication within table'},
    {28, 0x03, 2, 1, 'x/y',      '表内除法',              'division within table'},
    {29, 0x8A, 2, 1, 'x*y*z',    '表内连乘',              'continuous multiplication within table'},
    {30, 0x8F, 2, 1, 'x/y/z',    '表内连除',              'continuous division within table'},
    {31, 0x8B, 2, 1, 'x/y*z',    '表内除乘',              'division and multiplication within table'},
    {32, 0x8E, 2, 1, 'x*y/z',    '表内乘除',              'multiplication and division within table'},
    {33, 0x92, 2, 1, 'x*y+z:1',  '乘不进位加两步',        'multiplication and carry-save addition'},
    {34, 0x98, 2, 1, 'x+y*z:1',  '不进位加乘两步',        'carry-save addition and multiplication'},
    {35, 0x96, 2, 1, 'x*y-z:1',  '乘不退位减两步',        'multiplication and subtraction without abdication'},
    {36, 0x99, 2, 1, 'x-y*z:1',  '不退位减乘两步',        'subtraction without abdication and multiplication'},
    {37, 0xA2, 2, 1, 'x*y+z:2',  '乘进位加两步',          'multiplication and addition with carry'},
    {38, 0xA8, 2, 1, 'x+y*z:2',  '进位加乘两步',          'addition with carry and multiplication'},
    {39, 0xA6, 2, 1, 'x*y-z:2',  '乘退位减两步',          'multiplication and subtraction with abdication'},
    {40, 0xA9, 2, 1, 'x-y*z:2',  '退位减乘两步',          'subtraction with abdication and multiplication'},
    {41, 0x93, 2, 1, 'x/y+z:1',  '除不进位加两步',        'division and carry-save addition'},
    {42, 0x9C, 2, 1, 'x+y/z:1',  '不进位加除两步',        'carry-save addition and division'},
    {43, 0x87, 2, 1, 'x/y-z',    '除不退位减两步',        'division and subtraction without abdication'},
    {44, 0x9D, 2, 1, 'x-y/z:1',  '不退位减除两步',        'subtraction without abdication and division'},
    {45, 0xA3, 2, 1, 'x/y+z:2',  '除进位加两步',          'division and addition with carry'},
    {46, 0xAC, 2, 1, 'x+y/z:2',  '进位加除两步',          'addition with carry and division'},
    {47, 0xAD, 2, 1, 'x-y/z:2',  '退位减除两步',          'subtraction with abdication and division'},
    {48, 0x64, 2, 2, 'x+y:9/10', '整百数加法',            'addition of whole 100'},
    {49, 0x65, 2, 2, 'x-y:9/10', '整百数减法',            'subtraction of whole 100'},
    {50, 0x68, 2, 2, 'x+y:a/10', '整百整十数不进位加法',  'carry-save addition of whole 100 and whole 10'},
    {51, 0x6C, 2, 2, 'x+y:b/10', '整百整十数进位加法',    'addition with carry of whole 100 and whole 10'},
    {52, 0x69, 2, 2, 'x-y:a/10', '整百整十数不退位减法',  'subtraction without abdication of whole 100 and whole 10'},
    {53, 0x6D, 2, 2, 'x-y:b/10', '整百整十数退位减法',    'subtraction with abdication of whole 100 and whole 10'},
}

local qtsequences = {}
local qtypes = {}
for i=1,#QT do
    local qt = QT[i]
    qtsequences[qt[QT.name_zh]] = i
    qtsequences[qt[QT.name_en]] = i
    qtsequences[qt[QT.qtype]]   = i

    qtypes[qt[QT.name_zh]] = qt[QT.qtype]
    qtypes[qt[QT.name_en]] = qt[QT.qtype]
    qtypes[i]              = qt[QT.qtype]
end

local _M = {}
_M.qtsequences = qtsequences
_M.qtypes = qtypes

return _M
