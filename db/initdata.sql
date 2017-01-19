insert into qtypes(qtype, sequence, grade, semester, qtypestr, name_zh, name_en) values
    (0x04, 1, 1, 1,
      'x+y:1',
      '10以内加法',
      'addition within 10'),
    (0x05, 2, 1, 1,
      'x-y:1',
      '10以内减法',
      'subtraction within 10'),
    (0x08, 3, 1, 1,
      'x+y:2',
      '20以内不进位加法',
      'carry-save addition within 20'),
    (0x09, 4, 1, 1,
      'x-y:2',
      '20以内不退位减法',
      'subtraction without abdication within 20'),
    (0x0C, 5, 1, 1,
      'x+y:3',
      '20以内进位加法',
      'addition with carry within 20'),
    (0x0D, 6, 1, 1,
      'x-y:3',
      '20以内退位减法',
      'subtraction with abdication within 20'),
    (0x90, 7, 1, 1,
      'x+y+z:1',
      '10以内连加',
      'continuous addition within 10'),
    (0x95, 8, 1, 1,
      'x-y-z:1',
      '10以内连减',
      'continuous subtraction within 10'),
    (0x91, 9, 1, 1,
      'x-y+z:1',
      '10以内减加',
      'subtraction and addition within 10'),
    (0x94, 10, 1, 1,
      'x+y-z:1',
      '10以内加减',
      'addition and subtraction within 10'),
    (0xA0, 11, 1, 1,
      'x+y+z:2',
      '20以内连加',
      'continuous addition within 20'),
    (0xA5, 12, 1, 1,
      'x-y-z:2',
      '20以内连减',
      'continuous subtraction within 20'),
    (0xA1, 13, 1, 1,
      'x-y+z:2',
      '20以内减加',
      'subtraction and addition within 20'),
    (0xA4, 14, 1, 1,
      'x+y-z:2',
      '20以内加减',
      'addition and subtraction within 20'),
    (0x10, 15, 1, 2,
      'x+y:4',
      '100以内不进位加整10数',
      'carry-save addition of whole 10 within 100'),
    (0x11, 16, 1, 2,
      'x-y:4',
      '100以内不退位减整10数',
      'subtraction without abdication of whole 10 within 100'),
    (0x14, 17, 1, 2,
      'x+y:5',
      '100以内不进位加一位数',
      'carry-save addition of single digit within 100'),
    (0x15, 18, 1, 2,
      'x-y:5',
      '100以内不退位减一位数',
      'subtraction without abdication of single digit within 100'),
    (0x18, 19, 1, 2,
      'x+y:6',
      '100以内进位加一位数',
      'addition with carry of single digit within 100'),
    (0x19, 20, 1, 2,
      'x-y:6',
      '100以内退位减一位数',
      'subtraction with abdication of single digit within 100'),
    (0x1C, 21, 1, 2,
      'x+y:7',
      '100以内不进位加两位数',
      'carry-save addition of double-digit within 100'),
    (0x1D, 22, 1, 2,
      'x-y:7',
      '100以内不退位减两位数',
      'subtraction without abdication of double-digit within 100'),
    (0x20, 23, 1, 2,
      'x+y:8',
      '100以内进位加两位数',
      'addition with carry of double-digit within 100'),
    (0x21, 24, 1, 2,
      'x-y:8',
      '100以内退位减两位数',
      'subtraction with abdication of double-digit within 100'),
    (0xB0, 25, 1, 2,
      'x+y+z:3',
      '100以内连加',
      'continuous addition within 100'),
    (0xB5, 26, 1, 2,
      'x-y-z:3',
      '100以内连减',
      'continous subtraction within 100'),
    (0x02, 27, 2, 1,
      'x*y',
      '表内乘法',
      'multiplication within table'),
    (0x03, 28, 2, 1,
      'x/y',
      '表内除法',
      'division within table'),
    (0x8A, 29, 2, 1,
      'x*y*z',
      '表内连乘',
      'continuous multiplication within table'),
    (0x8F, 30, 2, 1,
      'x/y/z',
      '表内连除',
      'continuous division within table'),
    (0x8B, 31, 2, 1,
      'x/y*z',
      '表内除乘',
      'division and multiplication within table'),
    (0x8E, 32, 2, 1,
      'x*y/z',
      '表内乘除',
      'multiplication and division within table'),
    (0x92, 33, 2, 1,
      'x*y+z:1',
      '乘不进位加两步',
      'multiplication and carry-save addition'),
    (0x98, 34, 2, 1,
      'x+y*z:1',
      '不进位加乘两步',
      'carry-save addition and multiplication'),
    (0x96, 35, 2, 1,
      'x*y-z:1',
      '乘不退位减两步',
      'multiplication and subtraction without abdication'),
    (0x99, 36, 2, 1,
      'x-y*z:1',
      '不退位减乘两步',
      'subtraction without abdication and multiplication'),
    (0xA2, 37, 2, 1,
      'x*y+z:2',
      '乘进位加两步',
      'multiplication and addition with carry'),
    (0xA8, 38, 2, 1,
      'x+y*z:2',
      '进位加乘两步',
      'addition with carry and multiplication'),
    (0xA6, 39, 2, 1,
      'x*y-z:2',
      '乘退位减两步',
      'multiplication and subtraction with abdication'),
    (0xA9, 40, 2, 1,
      'x-y*z:2',
      '退位减乘两步',
      'subtraction with abdication and multiplication'),
    (0x93, 41, 2, 1,
      'x/y+z:1',
      '除不进位加两步',
      'division and carry-save addition'),
    (0x9C, 42, 2, 1,
      'x+y/z:1',
      '不进位加除两步',
      'carry-save addition and division'),
    (0x87, 43, 2, 1,
      'x/y-z',
      '除不退位减两步',
      'division and subtraction without abdication'),
    (0x9D, 44, 2, 1,
      'x-y/z:1',
      '不退位减除两步',
      'subtraction without abdication and division'),
    (0xA3, 45, 2, 1,
      'x/y+z:2',
      '除进位加两步',
      'division and addition with carry'),
    (0xAC, 46, 2, 1,
      'x+y/z:2',
      '进位加除两步',
      'addition with carry and division'),
    (0xAD, 47, 2, 1,
      'x-y/z:2',
      '退位减除两步',
      'subtraction with abdication and division'),
    (0x64, 48, 2, 2,
      'x+y:9/10',
      '整百数加法',
      'addition of whole 100'),
    (0x65, 49, 2, 2,
      'x-y:9/10',
      '整百数减法',
      'subtraction of whole 100'),
    (0x68, 50, 2, 2,
      'x+y:a/10',
      '整百整十数不进位加法',
      'carry-save addition of whole 100 and whole 10'),
    (0x6C, 51, 2, 2,
      'x+y:b/10',
      '整百整十数进位加法',
      'addition with carry of whole 100 and whole 10'),
    (0x69, 52, 2, 2,
      'x-y:a/10',
      '整百整十数不退位减法',
      'subtraction without abdication of whole 100 and whole 10'),
    (0x6D, 53, 2, 2,
      'x-y:b/10',
      '整百整十数退位减法',
      'subtraction with abdication of whole 100 and whole 10');

