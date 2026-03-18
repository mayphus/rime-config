local colors = import 'Colors.libsonnet';
local fonts = import 'Fonts.libsonnet';

local cangjieLegends = {
  a: '日',
  b: '月',
  c: '金',
  d: '木',
  e: '水',
  f: '火',
  g: '土',
  h: '的',
  i: '戈',
  j: '十',
  k: '大',
  l: '中',
  m: '一',
  n: '弓',
  o: '人',
  p: '心',
  q: '手',
  r: '口',
  s: '尸',
  t: '廿',
  u: '山',
  v: '女',
  w: '田',
  x: '止',
  y: '卜',
  z: '片',
};

local flypyLegends = {
  q: 'iu',
  w: 'ei',
  e: 'e',
  r: 'uan',
  t: 'ue\nve',
  y: 'un',
  u: 'sh',
  i: 'ch',
  o: 'uo',
  p: 'ie',
  a: 'a',
  s: 'ong\niong',
  d: 'ai',
  f: 'en',
  g: 'eng',
  h: 'ang',
  j: 'an',
  k: 'ing\nuai',
  l: 'iang\nuang',
  z: 'ou',
  x: 'ia\nua',
  c: 'ao',
  v: 'zh\nui',
  b: 'in',
  n: 'iao',
  m: 'ian',
};

local symbolLegends = {
  q: '1',
  w: '2',
  e: '3',
  r: '4',
  t: '5',
  y: '6',
  u: '7',
  i: '8',
  o: '9',
  p: '0',
  a: '`',
  s: '/',
  d: ':',
  f: ';',
  g: '(',
  h: '[',
  j: '~',
  k: '@',
  l: '"',
  z: ',',
  x: '.',
  c: '#',
  v: '\\',
  b: '?',
  n: '!',
  m: '…',
};

local newLetterButton(name, letter, extraParams={}) = {
  name: name,
  legend: {
    cangjie: cangjieLegends[letter],
    flypy: flypyLegends[letter],
    symbol: symbolLegends[letter],
  },
  params:
    {
      action: { character: letter },
      uppercasedStateAction: { character: std.asciiUpper(letter) },
    } + extraParams,
};

local newShuffleButton(name, code, label, finals, topSymbol='', sideLeft='', sideRight='', extraParams={}) = {
  name: name,
  legend: {
    finals: finals,
    topSymbol: topSymbol,
    sideLeft: sideLeft,
    sideRight: sideRight,
  },
  params:
    {
      action: { character: code },
      uppercasedStateAction: { character: std.asciiUpper(code) },
      text: label,
      fontSize: 18,
    } + extraParams,
};

{
  local root = self,

  preedit: {
    height: 25,
    insets: {
      top: 2,
      left: 4,
    },
    fontSize: fonts.preeditFontSize,
  },

  toolbar: {
    height: 40,
  },

  candidateStyle: {
    highlightBackgroundColor: colors.candidateHighlightColor,
    preferredBackgroundColor: colors.candidateHighlightColor,
    preferredIndexColor: colors.candidateForegroundColor,
    preferredTextColor: colors.candidateForegroundColor,
    preferredCommentColor: colors.candidateForegroundColor,
    indexColor: colors.candidateForegroundColor,
    textColor: colors.candidateForegroundColor,
    commentColor: colors.candidateForegroundColor,
    indexFontSize: fonts.candidateIndexFontSize,
    //indexFontWeight: 'ultraLight',
    textFontSize: fonts.candidateTextFontSize,
    //textFontWeight: 'regular',
    commentFontSize: fonts.candidateCommentFontSize,
    //commentFontWeight: 'black',
  },

  horizontalCandidateStyle:
    {
      insets: {
        top: 8,
        left: 3,
        bottom: 1,
      },
      expandButton: {
        systemImageName: 'chevron.forward',
        normalColor: colors.toolbarButtonForegroundColor,
        highlightColor: colors.toolbarButtonHighlightedForegroundColor,
        fontSize: fonts.candidateStateButtonFontSize,
      },
    },

  verticalCandidateStyle:
    {
      // insets 用于展开候选字后的区域内边距
      // insets: { top: 3, bottom: 3, left: 4, right: 4 },
      bottomRowHeight: 45,
      candidateCollectionStyle: {
        insets: { top: 8, bottom: 8, left: 8, right: 8 },
        backgroundColor: colors.keyboardBackgroundColor,
        maxRows: 5,
        maxColumns: 6,
        separatorColor: colors.candidateSeparatorColor,
      },
      pageUpButton: {
        action: { shortcut: '#verticalCandidatesPageUp' },
        systemImageName: 'chevron.up',
        normalColor: colors.toolbarButtonForegroundColor,
        highlightColor: colors.toolbarButtonHighlightedForegroundColor,
        fontSize: fonts.candidateStateButtonFontSize,
      },
      pageDownButton: {
        action: { shortcut: '#verticalCandidatesPageDown' },
        systemImageName: 'chevron.down',
        normalColor: colors.toolbarButtonForegroundColor,
        highlightColor: colors.toolbarButtonHighlightedForegroundColor,
        fontSize: fonts.candidateStateButtonFontSize,
      },
      returnButton: {
        action: { shortcut: '#candidatesBarStateToggle' },
        systemImageName: 'return',
        normalColor: colors.toolbarButtonForegroundColor,
        highlightColor: colors.toolbarButtonHighlightedForegroundColor,
        fontSize: fonts.candidateStateButtonFontSize,
      },
    },

  keyboard: {
    height: {
      iPhone: {
        portrait: 216,  // 54 * 4
        landscape: 160,  // 40 * 4
      },
      iPad: {
        portrait: 311,  // 64 * 4 + 55
        landscape: 414,  // 86 * 4 + 70
      },
    },

    button: {
      backgroundInsets: {
        iPhone: {
          portrait: { top: 4, left: 3, bottom: 4, right: 3 },
          landscape: { top: 3, left: 3, bottom: 3, right: 3 },
        },
        ipad: {
          portrait: { top: 3, left: 3, bottom: 3, right: 3 },
          landscape: { top: 4, left: 6, bottom: 4, right: 6 },
        },
      },
    },

    // 按键定义
    qButton: newLetterButton('qButton', 'q', { swipeUpAction: { character: '1' } }),
    wButton: newLetterButton('wButton', 'w', { swipeUpAction: { character: '2' } }),
    eButton: newLetterButton('eButton', 'e', {
      swipeUpAction: { character: '3' },
      swipeDownAction: { keyboardType: 'emojis' },
    }),
    rButton: newLetterButton('rButton', 'r', { swipeUpAction: { character: '4' } }),
    tButton: newLetterButton('tButton', 't', { swipeUpAction: { character: '5' } }),
    yButton: newLetterButton('yButton', 'y', { swipeUpAction: { character: '6' } }),
    uButton: newLetterButton('uButton', 'u', { swipeUpAction: { character: '7' } }),
    iButton: newLetterButton('iButton', 'i', { swipeUpAction: { character: '8' } }),
    oButton: newLetterButton('oButton', 'o', { swipeUpAction: { character: '9' } }),
    pButton: newLetterButton('pButton', 'p', {
      swipeUpAction: { character: '0' },
      swipeDownAction: { shortcut: '#showPasteboardView' },
    }),

    // 第二行字母键 (ASDF)
    aButton: newLetterButton('aButton', 'a', {
      // swipeUpAction: { shortcut: '#selectText' },
      swipeUpAction: { character: '`' },
      swipeDownAction: { shortcut: '#中英切换' },
    }),
    sButton: newLetterButton('sButton', 's', {
      swipeUpAction: { character: '/' },
      swipeDownAction: { shortcut: '#toggleScriptView' },
    }),
    dButton: newLetterButton('dButton', 'd', {
      swipeUpAction: { character: ':' },
    }),
    fButton: newLetterButton('fButton', 'f', { swipeUpAction: { character: ';' } }),
    gButton: newLetterButton('gButton', 'g', { swipeUpAction: { character: '(' } }),
    hButton: newLetterButton('hButton', 'h', { swipeUpAction: { character: '[' } }),
    jButton: newLetterButton('jButton', 'j', { swipeUpAction: { character: '~' } }),
    kButton: newLetterButton('kButton', 'k', { swipeUpAction: { character: '@' } }),
    lButton: newLetterButton('lButton', 'l', { swipeUpAction: { character: '"' } }),

    // 第三行字母键 (ZXCV)
    zButton: newLetterButton('zButton', 'z', {
      swipeUpAction: { character: ',' },
      // swipeDownAction: { shortcut: '#redo' },
    }),
    xButton: newLetterButton('xButton', 'x', {
      swipeUpAction: { character: '.' },
    }),
    cButton: newLetterButton('cButton', 'c', {
      swipeUpAction: { character: '#' },
    }),
    vButton: newLetterButton('vButton', 'v', {
      swipeUpAction: { character: '\\' },
    }),
    bButton: newLetterButton('bButton', 'b', { swipeUpAction: { character: '?' } }),
    nButton: newLetterButton('nButton', 'n', { swipeUpAction: { character: '!' } }),
    mButton: newLetterButton('mButton', 'm', { swipeUpAction: { symbol: '…' } }),

    // 亂序17 鍵位（iPhone 版皮肤使用；iPad 暂时保留现有 26 键）
    hpButton: newShuffleButton('hpButton', 'a', 'H P', 'a ia ua', topSymbol='1', extraParams={ swipeUpAction: { character: '1' } }),
    sh17Button: newShuffleButton('sh17Button', 'b', 'Sh', 'en in', topSymbol='2', extraParams={ swipeUpAction: { character: '2' } }),
    zh17Button: newShuffleButton('zh17Button', 'c', 'Zh', 'ang iao', topSymbol='3', extraParams={ swipeUpAction: { character: '3' } }),
    b17Button: newShuffleButton('b17Button', 'd', 'B', 'ao iong', topSymbol='@', extraParams={ swipeUpAction: { character: '@' } }),
    oxvButton: newShuffleButton('oxvButton', 'e', 'X', 'uai uan', topSymbol='*', sideLeft='o', sideRight='v', extraParams={
      fontSize: 19,
      swipeUpAction: { character: '*' },
      swipeDownAction: { keyboardType: 'emojis' },
    }),
    smButton: newShuffleButton('smButton', 'f', 'M S', 'ie uo', topSymbol='#', extraParams={
      swipeUpAction: { character: '#' },
      swipeDownAction: { shortcut: '#toggleScriptView' },
    }),

    l17Button: newShuffleButton('l17Button', 'g', 'L', 'ai ue', topSymbol='4', extraParams={ swipeUpAction: { character: '4' } }),
    d17Button: newShuffleButton('d17Button', 'h', 'D', 'u', topSymbol='5', extraParams={ swipeUpAction: { character: '5' } }),
    y17Button: newShuffleButton('y17Button', 'i', 'Y', 'eng ing', topSymbol='6', extraParams={ swipeUpAction: { character: '6' } }),
    wzButton: newShuffleButton('wzButton', 'j', 'W Z', 'e', topSymbol='0', extraParams={
      swipeUpAction: { character: '0' },
      swipeDownAction: { shortcut: '#showPasteboardView' },
    }),
    jkButton: newShuffleButton('jkButton', 'k', 'J K', 'i', topSymbol='%', extraParams={ swipeUpAction: { character: '%' } }),
    rnButton: newShuffleButton('rnButton', 'l', 'N R', 'an', topSymbol='&', extraParams={ swipeUpAction: { character: '&' } }),

    ch17Button: newShuffleButton('ch17Button', 'm', 'Ch', 'iang ui', topSymbol='7', extraParams={ swipeUpAction: { character: '7' } }),
    qGuideButton: newShuffleButton('qGuideButton', 'n', 'Q~', 'ian uang', topSymbol='8', extraParams={ swipeUpAction: { character: '8' } }),
    g17Button: newShuffleButton('g17Button', 'o', 'G', 'ei un', topSymbol='9', extraParams={ swipeUpAction: { character: '9' } }),
    cfButton: newShuffleButton('cfButton', 'p', 'C F', 'iu ou', topSymbol='!', extraParams={ swipeUpAction: { character: '!' } }),
    t17Button: newShuffleButton('t17Button', 'q', 'T', 'er ong', topSymbol='?', extraParams={ swipeUpAction: { character: '?' } }),

    // 数字键
    oneButton: {
      name: 'oneButton',
      params: {
        action: { character: '1' },
        swipeUpAction: { character: '!' },
      },
    },
    twoButton: {
      name: 'twoButton',
      params: {
        action: { character: '2' },
        swipeUpAction: { character: '@' },
      },
    },
    threeButton: {
      name: 'threeButton',
      params: {
        action: { character: '3' },
        swipeUpAction: { character: '#' },
      },
    },
    fourButton: {
      name: 'fourButton',
      params: {
        action: { character: '4' },
        swipeUpAction: { character: '$' },
      },
    },
    fiveButton: {
      name: 'fiveButton',
      params: {
        action: { character: '5' },
        swipeUpAction: { character: '%' },
      },
    },
    sixButton: {
      name: 'sixButton',
      params: {
        action: { character: '6' },
        swipeUpAction: { character: '^' },
      },
    },
    sevenButton: {
      name: 'sevenButton',
      params: {
        action: { character: '7' },
        swipeUpAction: { character: '&' },
      },
    },
    eightButton: {
      name: 'eightButton',
      params: {
        action: { character: '8' },
        swipeUpAction: { character: '*' },
      },
    },
    nineButton: {
      name: 'nineButton',
      params: {
        action: { character: '9' },
        swipeUpAction: { character: '(' },
      },
    },
    zeroButton: {
      name: 'zeroButton',
      params: {
        action: { character: '0' },
        swipeUpAction: { character: ')' },
      },
    },

    // Stroke Filter Buttons (5 distinct buttons)
    strokeHButton: {
      name: 'strokeHButton',
      params: {
        text: '-', action: { character: '-' }, preeditStateText: '一', preeditStateAction: { text: ';h' }, fontSize: 16
      },
    },
    strokeSButton: {
      name: 'strokeSButton',
      params: {
        text: ':', action: { character: ':' }, preeditStateText: '丨', preeditStateAction: { text: ';s' }, fontSize: 16
      },
    },
    strokePButton: {
      name: 'strokePButton',
      params: {
        text: '…', action: { symbol: '…' }, preeditStateText: '丿', preeditStateAction: { text: ';p' }, fontSize: 16
      },
    },
    strokeNButton: {
      name: 'strokeNButton',
      params: {
        text: '。', action: { symbol: '。' }, preeditStateText: '丶', preeditStateAction: { text: ';n' }, fontSize: 16
      },
    },
    strokeZButton: {
      name: 'strokeZButton',
      params: {
        text: '，', action: { symbol: '，' }, preeditStateText: '乙', preeditStateAction: { text: ';z' }, fontSize: 16
      },
    },

    spaceButton: {
      name: 'spaceButton',
      params: {
        action: 'space',
        swipeUpAction: { shortcut: '#次选上屏' },
        systemImageName: 'space',
        notification: [
          'preeditChangedForSpaceButtonNotification',
        ],
      },
    },

    tabButton: {
      name: 'tabButton',
      params: {
        action: 'tab',
        systemImageName: 'arrow.right.to.line',
      },
    },

    backspaceButton: {
      name: 'backspaceButton',
      params: {
        action: 'backspace',
        repeatAction: 'backspace',
        systemImageName: 'delete.left',
        highlightSystemImageName: 'delete.left.fill',
      },
    },

    shiftButton: {
      name: 'shiftButton',
      params: {
        systemImageName: 'shift',
        action: 'shift',
      },
      uppercasedParams: {
        systemImageName: 'shift.fill',
      },
      capsLockedParams: {
        systemImageName: 'capslock.fill',
      },
    },

    asciiModeButton: {
      name: 'asciiModeButton',
      params: {
        action: { shortcut: '#中英切换' },
        text: '中/英',
      },
    },

    dismissButton: {
      name: 'dismissButton',
      params: {
        action: 'dismissKeyboard',
        systemImageName: 'keyboard.chevron.compact.down',
      },
    },

    enterButton: {
      name: 'enterButton',
      params: {
        action: 'enter',
        text: '$returnKeyType',
        notification: [
          'returnKeyTypeChangedNotification',
          'preeditChangedForEnterButtonNotification',
        ],
      },
    },

    symbolicButton: {
      name: 'symbolicButton',
      params: {
        action: { keyboardType: 'symbolic' },
        text: '#+=',
      },
    },

    numericButton: {
      name: 'numericButton',
      params: {
        action: { keyboardType: 'numeric' },
        systemImageName: 'textformat.123',
        fontSize: 14,
        center: { y: 0.5 },
      },
    },

    pinyinButton: {
      name: 'pinyinButton',
      params: {
        action: { keyboardType: 'pinyin' },
        text: '拼音',
      },
    },

    otherKeyboardButton: {
      name: 'otherKeyboardButton',
      params: {
        action: 'nextKeyboard',
        systemImageName: 'globe',
      },
    },

    // 标点符号键

    // 连接号(减号)
    hyphenButton: {
      name: 'hyphenButton',
      params: {
        action: { character: '-' },
        swipeUpAction: { character: '——' },
      },
    },
    // 斜杠
    forwardSlashButton: {
      name: 'forwardSlashButton',
      params: {
        action: { character: '/' },
        swipeUpAction: { character: '?' },
      },
    },
    // 冒号
    colonButton: {
      name: 'colonButton',
      params: {
        action: { character: ':' },
      },
    },

    // 中文冒号
    chineseColonButton: {
      name: 'chineseColonButton',
      params: {
        action: { symbol: '：' },
      },
    },

    // 分号
    semicolonButton: {
      name: 'semicolonButton',
      params: {
        action: { character: ';' },
      },
    },

    // 中文分号
    chineseSemicolonButton: {
      name: 'chineseSemicolonButton',
      params: {
        action: { symbol: '；' },
        swipeUpAction: { symbol: '：' },
      },
    },

    // 左括号
    leftParenthesisButton: {
      name: 'leftParenthesisButton',
      params: {
        action: { symbol: '(' },
      },
    },

    // 右括号
    rightParenthesisButton: {
      name: 'rightParenthesisButton',
      params: {
        action: { symbol: ')' },
      },
    },

    // 中文左括号
    leftChineseParenthesisButton: {
      name: 'leftChineseParenthesisButton',
      params: {
        action: { symbol: '（' },
      },
    },

    // 中文右括号
    rightChineseParenthesisButton: {
      name: 'rightChineseParenthesisButton',
      params: {
        action: { symbol: '）' },
      },
    },

    // 美元符号
    dollarButton: {
      name: 'dollarButton',
      params: {
        action: { symbol: '$' },
      },
    },

    // 地址符号
    atButton: {
      name: 'atButton',
      params: {
        action: { symbol: '@' },
      },
    },

    // “ 双引号(有方向性的引号)
    leftCurlyQuoteButton: {
      name: 'leftCurlyQuoteButton',
      params: {
        action: { symbol: '“' },
      },
    },
    // ” 双引号(有方向性的引号)
    rightCurlyQuoteButton: {
      name: 'rightCurlyQuoteButton',
      params: {
        action: { symbol: '”' },
      },
    },
    // " 直引号(没有方向性的引号)
    straightQuoteButton: {
      name: 'straightQuoteButton',
      params: {
        action: { symbol: '"' },
      },
    },
    chineseCommaButton: {
      name: 'chineseCommaButton',
      params: {
        action: { symbol: '，' },
        swipeUpAction: { symbol: '《' },
      },
    },
    commaButton: {
      name: 'commaButton',
      params: {
        action: { symbol: ',' },
      },
    },
    chinesePeriodButton: {
      name: 'chinesePeriodButton',
      params: {
        action: { symbol: '。' },
        swipeUpAction: { symbol: '》' },
      },
    },
    periodButton: {
      name: 'periodButton',
      params: {
        action: { character: '.' },
        swipeUpAction: { character: ',' },
      },
    },
    // 顿号(只在中文中使用)
    ideographicCommaButton: {
      name: 'ideographicCommaButton',
      params: {
        action: { symbol: '、' },
        swipeUpAction: { symbol: '|' },
      },
    },
    // 中文问号
    chineseQuestionMarkButton: {
      name: 'questionMarkButton',
      params: {
        action: { symbol: '？' },
      },
    },
    // 英文问号
    questionMarkButton: {
      name: 'questionMarkEnButton',
      params: {
        action: { character: '?' },
      },
    },
    // 中文感叹号
    chineseExclamationMarkButton: {
      name: 'chineseExclamationMarkButton',
      params: {
        action: { symbol: '！' },
      },
    },
    // 英文感叹号
    exclamationMarkButton: {
      name: 'exclamationMarkButton',
      params: {
        action: { character: '!' },
      },
    },
    // ' 直撇号(单引号)
    apostropheButton: {
      name: 'apostropheButton',
      params: {
        action: { character: "'" },
      },
    },
    // 中文左单引号(有方向性的单引号)
    leftSingleQuoteButton: {
      name: 'leftSingleQuoteButton',
      params: {
        action: { symbol: '‘' },
        swipeUpAction: { symbol: '“' },
      },
    },
    // 中文右单引号(有方向性的单引号)
    rightSingleQuoteButton: {
      name: 'rightSingleQuoteButton',
      params: {
        action: { symbol: '’' },
      },
    },
    // 等号
    equalButton: {
      name: 'equalButton',
      params: {
        action: { character: '=' },
        swipeUpAction: { character: '+' },
      },
    },
    leftBracketButton: {
      name: 'leftBracketButton',
      params: {
        action: { symbol: '[' },
      },
    },
    rightBracketButton: {
      name: 'rightBracketButton',
      params: {
        action: { symbol: ']' },
      },
    },

    // 中文左中括号
    leftChineseBracketButton: {
      name: 'leftChineseBracketButton',
      params: {
        action: { symbol: '【' },
        swipeUpAction: { symbol: '「' },
      },
    },

    // 中文右中括号
    rightChineseBracketButton: {
      name: 'rightChineseBracketButton',
      params: {
        action: { symbol: '】' },
        swipeUpAction: { symbol: '」' },
      },
    },

    // 英文左大括号
    leftBraceButton: {
      name: 'leftBraceButton',
      params: {
        action: { symbol: '{' },
      },
    },

    // 英文右大括号
    rightBraceButton: {
      name: 'rightBraceButton',
      params: {
        action: { symbol: '}' },
      },
    },

    // 中文左大括号
    leftChineseBraceButton: {
      name: 'leftChineseBraceButton',
      params: {
        action: { symbol: '｛' },
      },
    },

    // 中文右大括号
    rightChineseBraceButton: {
      name: 'rightChineseBraceButton',
      params: {
        action: { symbol: '｝' },
      },
    },


    // 井号
    hashButton: {
      name: 'hashButton',
      params: {
        action: { symbol: '#' },
      },
    },

    // 百分号
    percentButton: {
      name: 'percentButton',
      params: {
        action: { symbol: '%' },
      },
    },

    // ^符号
    caretButton: {
      name: 'caretButton',
      params: {
        action: { symbol: '^' },
      },
    },

    // '*' 符号
    asteriskButton: {
      name: 'asteriskButton',
      params: {
        action: { character: '*' },
      },
    },

    // + 符号
    plusButton: {
      name: 'plusButton',
      params: {
        action: { character: '+' },
        swipeUpAction: { character: '=' },
      },
    },

    // _ 符号(下划线)
    underscoreButton: {
      name: 'underscoreButton',
      params: {
        action: { symbol: '_' },
      },
    },

    // —— 符号(破折号)
    emDashButton: {
      name: 'emDashButton',
      params: {
        action: { character: '—' },
      },
    },

    // \ 符号(反斜杠)
    backslashButton: {
      name: 'backslashButton',
      params: {
        action: { symbol: '\\' },
      },
    },

    // | 符号(竖线)
    verticalBarButton: {
      name: 'verticalBarButton',
      params: {
        action: { symbol: '|' },
      },
    },

    // ~ 符号
    tildeButton: {
      name: 'tildeButton',
      params: {
        action: { symbol: '~' },
      },
    },

    // < 符号(小于号)
    lessThanButton: {
      name: 'lessThanButton',
      params: {
        action: { symbol: '<' },
      },
    },

    // > 符号(大于号)
    greaterThanButton: {
      name: 'greaterThanButton',
      params: {
        action: { symbol: '>' },
      },
    },

    // 中文左书名号
    leftBookTitleMarkButton: {
      name: 'leftBookTitleMarkButton',
      params: {
        action: { symbol: '《' },
      },
    },

    // 中文右书名号
    rightBookTitleMarkButton: {
      name: 'rightBookTitleMarkButton',
      params: {
        action: { symbol: '》' },
      },
    },

    // € 符号(欧元符号)
    euroButton: {
      name: 'euroButton',
      params: {
        action: { symbol: '€' },
      },
    },

    // £ 符号(英镑符号)
    poundButton: {
      name: 'poundButton',
      params: {
        action: { symbol: '£' },
      },
    },

    // 人民币符号
    rmbButton: {
      name: 'rmbButton',
      params: {
        action: { symbol: '¥' },
      },
    },

    // & 符号(和号)
    ampersandButton: {
      name: 'ampersandButton',
      params: {
        action: { symbol: '&' },
      },
    },

    // · 中点符号
    middleDotButton: {
      name: 'middleDotButton',
      params: {
        action: { symbol: '·' },
      },
    },

    // …… 符号(省略号)
    ellipsisButton: {
      name: 'ellipsisButton',
      params: {
        action: { symbol: '…' },
      },
    },

    // ` 符号(重音符)
    graveButton: {
      name: 'graveButton',
      params: {
        action: { character: '`' },
        swipeUpAction: { character: '~' },
      },
    },

    // ± 符号(正负号)
    plusMinusButton: {
      name: 'plusMinusButton',
      params: {
        action: { symbol: '±' },
      },
    },

    // 「 中文左引号
    leftChineseAngleQuoteButton: {
      name: 'leftChineseAngleQuoteButton',
      params: {
        action: { symbol: '「' },
      },
    },

    // 」 中文右引号
    rightChineseAngleQuoteButton: {
      name: 'rightChineseAngleQuoteButton',
      params: {
        action: { symbol: '」' },
      },
    },
  },
}
