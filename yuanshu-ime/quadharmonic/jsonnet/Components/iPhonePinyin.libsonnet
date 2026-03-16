local params = import '../Constants/Keyboard.libsonnet';
local colors = import '../Constants/Colors.libsonnet';
local basicStyle = import 'BasicStyle.libsonnet';
local preedit = import 'Preedit.libsonnet';
local toolbar = import 'Toolbar.libsonnet';
local utils = import 'Utils.libsonnet';

local portraitNormalButtonSize = {
  size: { width: '112.5/1125' },
};

local hintStyle = {
  hintStyle: {
    size: { width: 50, height: 50 },
  },
};

local legendCenter = {
  cangjie: { x: 0.37, y: 0.34 },
  zhuyinSingle: { x: 0.72, y: 0.34 },
  zhuyinDoubleTop: { x: 0.72, y: 0.24 },
  zhuyinDoubleBottom: { x: 0.72, y: 0.43 },
  zhuyinTripleTop: { x: 0.72, y: 0.16 },
  zhuyinTripleMiddle: { x: 0.72, y: 0.29 },
  zhuyinTripleBottom: { x: 0.72, y: 0.42 },
  flypySingle: { x: 0.50, y: 0.74 },
  flypyDoubleTop: { x: 0.50, y: 0.68 },
  flypyDoubleBottom: { x: 0.50, y: 0.79 },
};

local primaryLegendColor = {
  normalColor: colors.labelColor.primary,
  highlightColor: colors.labelColor.primary,
};

local secondaryLegendColor = {
  normalColor: colors.labelColor.secondary,
  highlightColor: colors.labelColor.secondary,
};

local hasMultipleFlypyLines(button) = std.length(std.split(button.legend.flypy, '\n')) > 1;
local flypyLines(button) = std.split(button.legend.flypy, '\n');
local flypyLineOne(button) = flypyLines(button)[0];
local flypyLineTwo(button) = if hasMultipleFlypyLines(button) then flypyLines(button)[1] else '';

local zhuyinLines(button) =
  if button.legend.hsuZhuyin == '' then
    []
  else
    std.split(button.legend.hsuZhuyin, '\n');

local zhuyinLineCount(button) = std.length(zhuyinLines(button));
local zhuyinLine(button, idx) = if idx < zhuyinLineCount(button) then zhuyinLines(button)[idx] else '';

local cangjieLegendParams = {
  center: legendCenter.cangjie,
  fontSize: 15.5,
} + secondaryLegendColor;

local flypyTopLegendParams(button) = {
  center: if hasMultipleFlypyLines(button) then legendCenter.flypyDoubleTop else legendCenter.flypySingle,
  fontSize: if hasMultipleFlypyLines(button) then 7.25 else 12,
} + primaryLegendColor;

local flypyBottomLegendParams(button) = {
  center: if hasMultipleFlypyLines(button) then legendCenter.flypyDoubleBottom else legendCenter.flypySingle,
  fontSize: if hasMultipleFlypyLines(button) then 7.25 else 12,
} + primaryLegendColor;

local zhuyinSingleLegendParams = {
  center: legendCenter.zhuyinSingle,
  fontSize: 10.5,
} + primaryLegendColor;

local zhuyinDoubleTopLegendParams = {
  center: legendCenter.zhuyinDoubleTop,
  fontSize: 8.25,
} + primaryLegendColor;

local zhuyinDoubleBottomLegendParams = {
  center: legendCenter.zhuyinDoubleBottom,
  fontSize: 8.25,
} + primaryLegendColor;

local zhuyinTripleTopLegendParams = {
  center: legendCenter.zhuyinTripleTop,
  fontSize: 7,
} + primaryLegendColor;

local zhuyinTripleMiddleLegendParams = {
  center: legendCenter.zhuyinTripleMiddle,
  fontSize: 7,
} + primaryLegendColor;

local zhuyinTripleBottomLegendParams = {
  center: legendCenter.zhuyinTripleBottom,
  fontSize: 7,
} + primaryLegendColor;

local zhuyinTopText(button) =
  if zhuyinLineCount(button) == 2 || zhuyinLineCount(button) == 3 then
    zhuyinLine(button, 0)
  else
    '';

local zhuyinMiddleText(button) =
  if zhuyinLineCount(button) == 1 then
    zhuyinLine(button, 0)
  else if zhuyinLineCount(button) == 3 then
    zhuyinLine(button, 1)
  else
    '';

local zhuyinBottomText(button) =
  if zhuyinLineCount(button) == 2 then
    zhuyinLine(button, 1)
  else if zhuyinLineCount(button) == 3 then
    zhuyinLine(button, 2)
  else
    '';

local zhuyinTopLegendParams(button) =
  if zhuyinLineCount(button) == 3 then
    zhuyinTripleTopLegendParams
  else
    zhuyinDoubleTopLegendParams;

local zhuyinMiddleLegendParams(button) =
  if zhuyinLineCount(button) == 3 then
    zhuyinTripleMiddleLegendParams
  else
    zhuyinSingleLegendParams;

local zhuyinBottomLegendParams(button) =
  if zhuyinLineCount(button) == 3 then
    zhuyinTripleBottomLegendParams
  else
    zhuyinDoubleBottomLegendParams;

local newMarkedAlphabeticButton(button, isDark=false, params={}) =
  basicStyle.newAlphabeticButton(
    button.name,
    isDark,
    params
    + button.params
    + {
      foregroundStyleName: [
        button.name + 'CangjieForegroundStyle',
        button.name + 'ZhuyinTopForegroundStyle',
        button.name + 'ZhuyinMiddleForegroundStyle',
        button.name + 'ZhuyinBottomForegroundStyle',
        button.name + 'FlypyTopForegroundStyle',
        button.name + 'FlypyBottomForegroundStyle',
      ],
      uppercasedStateForegroundStyle: [
        button.name + 'CangjieForegroundStyle',
        button.name + 'ZhuyinTopForegroundStyle',
        button.name + 'ZhuyinMiddleForegroundStyle',
        button.name + 'ZhuyinBottomForegroundStyle',
        button.name + 'FlypyTopForegroundStyle',
        button.name + 'FlypyBottomForegroundStyle',
      ],
      capsLockedStateForegroundStyle: [
        button.name + 'CangjieForegroundStyle',
        button.name + 'ZhuyinTopForegroundStyle',
        button.name + 'ZhuyinMiddleForegroundStyle',
        button.name + 'ZhuyinBottomForegroundStyle',
        button.name + 'FlypyTopForegroundStyle',
        button.name + 'FlypyBottomForegroundStyle',
      ],
      foregroundStyle: {
        [button.name + 'CangjieForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(isDark, cangjieLegendParams + { text: button.legend.cangjie }),
        [button.name + 'ZhuyinTopForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(isDark, zhuyinTopLegendParams(button) + { text: zhuyinTopText(button) }),
        [button.name + 'ZhuyinMiddleForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(isDark, zhuyinMiddleLegendParams(button) + { text: zhuyinMiddleText(button) }),
        [button.name + 'ZhuyinBottomForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(isDark, zhuyinBottomLegendParams(button) + { text: zhuyinBottomText(button) }),
        [button.name + 'FlypyTopForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(isDark, flypyTopLegendParams(button) + { text: if hasMultipleFlypyLines(button) then flypyLineOne(button) else '' }),
        [button.name + 'FlypyBottomForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(isDark, flypyBottomLegendParams(button) + { text: if hasMultipleFlypyLines(button) then flypyLineTwo(button) else button.legend.flypy }),
      },
    }
  );

// 标准26键布局
local alphabeticKeyboardLayout = {
  keyboardLayout: [
    {
      HStack: {
        subviews: [
          {
            Cell: params.keyboard.qButton.name,
          },
          {
            Cell: params.keyboard.wButton.name,
          },
          {
            Cell: params.keyboard.eButton.name,
          },
          {
            Cell: params.keyboard.rButton.name,
          },
          {
            Cell: params.keyboard.tButton.name,
          },
          {
            Cell: params.keyboard.yButton.name,
          },
          {
            Cell: params.keyboard.uButton.name,
          },
          {
            Cell: params.keyboard.iButton.name,
          },
          {
            Cell: params.keyboard.oButton.name,
          },
          {
            Cell: params.keyboard.pButton.name,
          },
        ],
      },
    },
    {
      HStack: {
        subviews: [
          {
            Cell: params.keyboard.aButton.name,
          },
          {
            Cell: params.keyboard.sButton.name,
          },
          {
            Cell: params.keyboard.dButton.name,
          },
          {
            Cell: params.keyboard.fButton.name,
          },
          {
            Cell: params.keyboard.gButton.name,
          },
          {
            Cell: params.keyboard.hButton.name,
          },
          {
            Cell: params.keyboard.jButton.name,
          },
          {
            Cell: params.keyboard.kButton.name,
          },
          {
            Cell: params.keyboard.lButton.name,
          },
        ],
      },
    },
    {
      HStack: {
        subviews: [
          {
            Cell: params.keyboard.shiftButton.name,
          },
          {
            Cell: params.keyboard.zButton.name,
          },
          {
            Cell: params.keyboard.xButton.name,
          },
          {
            Cell: params.keyboard.cButton.name,
          },
          {
            Cell: params.keyboard.vButton.name,
          },
          {
            Cell: params.keyboard.bButton.name,
          },
          {
            Cell: params.keyboard.nButton.name,
          },
          {
            Cell: params.keyboard.mButton.name,
          },
          {
            Cell: params.keyboard.backspaceButton.name,
          },
        ],
      },
    },
    {
      HStack: {
        subviews: [
          {
            Cell: params.keyboard.numericButton.name,
          },
          {
            Cell: params.keyboard.spaceButton.name,
          },
          {
            Cell: params.keyboard.enterButton.name,
          },
        ],
      },
    },
  ],
};


local newKeyLayout(isDark=false, isPortrait=true) =
  local keyboardHeight = if isPortrait then params.keyboard.height.iPhone.portrait else params.keyboard.height.iPhone.landscape;
  {
    keyboardHeight: keyboardHeight,
    keyboardStyle: utils.newBackgroundStyle(style=basicStyle.keyboardBackgroundStyleName),
  }
  + alphabeticKeyboardLayout
  // First Row
  + newMarkedAlphabeticButton(params.keyboard.qButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.wButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.eButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.rButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.tButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.yButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.uButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.iButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.oButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.pButton, isDark, portraitNormalButtonSize + hintStyle)

  // Second Row
  + newMarkedAlphabeticButton(
    params.keyboard.aButton,
    isDark,
    {
      size:
        { width: '168.75/1125' },
      bounds:
        { width: '111/168.75', alignment: 'right' },
    } + hintStyle,
  )
  + newMarkedAlphabeticButton(params.keyboard.sButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.dButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.fButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.gButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.hButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.jButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.kButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(
    params.keyboard.lButton,
    isDark,
    {
      size:
        { width: '168.75/1125' },
      bounds:
        { width: '111/168.75', alignment: 'left' },
    } + hintStyle
  )

  // Third Row
  + basicStyle.newSystemButton(
    params.keyboard.shiftButton.name,
    isDark,
    {
      size:
        { width: '168.75/1125' },
      bounds:
        { width: '151/168.75', alignment: 'left' },
    }
    + params.keyboard.shiftButton.params
    + {
      uppercasedStateForegroundStyle: params.keyboard.shiftButton.name + 'UppercasedForegroundStyle',
    }
    + {
      capsLockedStateForegroundStyle: params.keyboard.shiftButton.name + 'CapsLockedForegroundStyle',
    }
  )
  + {
    [params.keyboard.shiftButton.name + 'UppercasedForegroundStyle']:
      basicStyle.newImageSystemButtonForegroundStyle(isDark, params.keyboard.shiftButton.uppercasedParams),
    [params.keyboard.shiftButton.name + 'CapsLockedForegroundStyle']:
      basicStyle.newImageSystemButtonForegroundStyle(isDark, params.keyboard.shiftButton.capsLockedParams),
  }

  + newMarkedAlphabeticButton(params.keyboard.zButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.xButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.cButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.vButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.bButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.nButton, isDark, portraitNormalButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.mButton, isDark, portraitNormalButtonSize + hintStyle)
  + basicStyle.newSystemButton(
    params.keyboard.backspaceButton.name,
    isDark,
    {
      size:
        { width: '168.75/1125' },
      bounds:
        { width: '151/168.75', alignment: 'right' },
    } + params.keyboard.backspaceButton.params,
  )

  // Fourth Row
  + basicStyle.newSystemButton(
    params.keyboard.numericButton.name,
    isDark,
    {
      size:
        { width: '280/1125' },
    } + params.keyboard.numericButton.params
  )

  + basicStyle.newAlphabeticButton(
    params.keyboard.spaceButton.name,
    isDark,
    params.keyboard.spaceButton.params,
    needHint=false
  )
  + basicStyle.newSystemButton(
    params.keyboard.enterButton.name,
    isDark,
    {
      size: { width: '280/1125' },
      backgroundStyle: basicStyle.enterButtonBackgroundStyle,
      foregroundStyle: basicStyle.enterButtonForegroundStyle,
    } + params.keyboard.enterButton.params
  )
;

{
  new(isDark, isPortrait):
    local insets = if isPortrait then params.keyboard.button.backgroundInsets.iPhone.portrait else params.keyboard.button.backgroundInsets.iPhone.landscape;

    local extraParams = {
      insets: insets,
    };

    preedit.new(isDark)
    + toolbar.new(isDark)
    + basicStyle.newKeyboardBackgroundStyle(isDark)
    + basicStyle.newAlphabeticButtonBackgroundStyle(isDark, extraParams)
    + basicStyle.newAlphabeticButtonHintStyle(isDark)
    + basicStyle.newSystemButtonBackgroundStyle(isDark, extraParams)
    + basicStyle.newBlueButtonBackgroundStyle(isDark, extraParams)
    + basicStyle.newBlueButtonForegroundStyle(isDark, params.keyboard.enterButton.params)
    + basicStyle.newAlphabeticHintBackgroundStyle(isDark, { cornerRadius: 10 })
    + newKeyLayout(isDark, isPortrait)
    + basicStyle.newEnterButtonForegroundStyle(isDark, params.keyboard.enterButton.params)
    + basicStyle.newCommitCandidateForegroundStyle(isDark, { text: '选定' })
    // Notifications
    + basicStyle.returnKeyboardTypeChangedNotification
    + basicStyle.preeditChangedForEnterButtonNotification
    + basicStyle.preeditChangedForSpaceButtonNotification,
}
