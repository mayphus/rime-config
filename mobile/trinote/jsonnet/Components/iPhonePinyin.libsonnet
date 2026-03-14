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

local visualQuadrantCenter = {
  upperLeft: { x: 0.31, y: 0.30 },
  lowerLeft: { x: 0.31, y: 0.70 },
  upperRight: { x: 0.69, y: 0.30 },
  lowerRight: { x: 0.69, y: 0.70 },
};

local primaryLegendColor = {
  normalColor: colors.labelColor.primary,
  highlightColor: colors.labelColor.primary,
};

local secondaryLegendColor = {
  normalColor: colors.labelColor.secondary,
  highlightColor: colors.labelColor.secondary,
};

local abcLegendParams = {
  center: visualQuadrantCenter.upperLeft,
  fontSize: 14,
} + primaryLegendColor;

local cangjieLegendParams = {
  center: visualQuadrantCenter.lowerLeft,
  fontSize: 12,
} + primaryLegendColor;

local flypyLegendParams = {
  center: visualQuadrantCenter.upperRight,
  fontSize: 7.25,
} + primaryLegendColor;

local symbolLegendParams = {
  center: visualQuadrantCenter.lowerRight,
  fontSize: 9,
} + secondaryLegendColor;

local newMarkedAlphabeticButton(button, isDark=false, params={}) =
  basicStyle.newAlphabeticButton(
    button.name,
    isDark,
    params
    + button.params
    + {
      foregroundStyleName: [
        button.name + 'AbcForegroundStyle',
        button.name + 'CangjieForegroundStyle',
        button.name + 'FlypyForegroundStyle',
        button.name + 'SymbolForegroundStyle',
      ],
      uppercasedStateForegroundStyle: [
        button.name + 'AbcUppercaseForegroundStyle',
        button.name + 'CangjieForegroundStyle',
        button.name + 'FlypyForegroundStyle',
        button.name + 'SymbolForegroundStyle',
      ],
      capsLockedStateForegroundStyle: [
        button.name + 'AbcUppercaseForegroundStyle',
        button.name + 'CangjieForegroundStyle',
        button.name + 'FlypyForegroundStyle',
        button.name + 'SymbolForegroundStyle',
      ],
      foregroundStyle: {
        [button.name + 'AbcForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(isDark, abcLegendParams + button.params),
        [button.name + 'AbcUppercaseForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(isDark, abcLegendParams + button.params)
          + basicStyle.getKeyboardActionText(button.params, 'uppercasedStateAction'),
        [button.name + 'CangjieForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(isDark, cangjieLegendParams + { text: button.legend.cangjie }),
        [button.name + 'FlypyForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(isDark, flypyLegendParams + { text: button.legend.flypy }),
        [button.name + 'SymbolForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(isDark, symbolLegendParams + { text: button.legend.symbol }),
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
