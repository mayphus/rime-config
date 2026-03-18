local params = import '../Constants/Keyboard.libsonnet';
local colors = import '../Constants/Colors.libsonnet';
local basicStyle = import 'BasicStyle.libsonnet';
local preedit = import 'Preedit.libsonnet';
local toolbar = import 'Toolbar.libsonnet';
local utils = import 'Utils.libsonnet';

local sixColumnButtonSize = {
  size: { width: '187.5/1125' },
};

local fiveColumnButtonSize = {
  size: { width: '157.5/1125' },
};

local bottomSystemButtonSize = {
  size: { width: '280/1125' },
};

local hintStyle = {
  hintStyle: {
    size: { width: 50, height: 50 },
  },
};

local legendCenter = {
  sideLeft: { x: 0.24, y: 0.28 },
  sideRight: { x: 0.76, y: 0.28 },
  main: { x: 0.50, y: 0.50 },
  finalSingle: { x: 0.50, y: 0.77 },
};

local primaryLegendColor = {
  normalColor: colors.labelColor.primary,
  highlightColor: colors.labelColor.primary,
};

local secondaryLegendColor = {
  normalColor: colors.labelColor.secondary,
  highlightColor: colors.labelColor.secondary,
};

local mainLegendParams = {
  center: legendCenter.main,
} + primaryLegendColor;

local sideLegendParams = {
  center: legendCenter.sideLeft,
  fontSize: 10.5,
} + secondaryLegendColor;

local sideLeftLegendParams = sideLegendParams;
local sideRightLegendParams = {
  center: legendCenter.sideRight,
  fontSize: 10.5,
} + secondaryLegendColor;

local finalLegendParams = {
  center: legendCenter.finalSingle,
  fontSize: 10.5,
} + secondaryLegendColor;

local newMarkedAlphabeticButton(button, isDark=false, extraParams={}) =
  basicStyle.newAlphabeticButton(
    button.name,
    isDark,
    extraParams
    + button.params
    + {
      foregroundStyleName: [
        button.name + 'MainForegroundStyle',
        button.name + 'SideLeftForegroundStyle',
        button.name + 'SideRightForegroundStyle',
        button.name + 'FinalForegroundStyle',
      ],
      uppercasedStateForegroundStyle: [
        button.name + 'MainUppercaseForegroundStyle',
        button.name + 'SideLeftForegroundStyle',
        button.name + 'SideRightForegroundStyle',
        button.name + 'FinalForegroundStyle',
      ],
      capsLockedStateForegroundStyle: [
        button.name + 'MainUppercaseForegroundStyle',
        button.name + 'SideLeftForegroundStyle',
        button.name + 'SideRightForegroundStyle',
        button.name + 'FinalForegroundStyle',
      ],
      foregroundStyle: {
        [button.name + 'MainForegroundStyle']:
          basicStyle.newAlphabeticButtonForegroundStyle(isDark, mainLegendParams + button.params),
        [button.name + 'MainUppercaseForegroundStyle']:
          basicStyle.newAlphabeticButtonForegroundStyle(isDark, mainLegendParams + button.params),
        [button.name + 'SideLeftForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(
            isDark,
            sideLeftLegendParams + { text: button.legend.sideLeft }
          ),
        [button.name + 'SideRightForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(
            isDark,
            sideRightLegendParams + { text: button.legend.sideRight }
          ),
        [button.name + 'FinalForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(isDark, finalLegendParams + { text: button.legend.finals }),
      },
    }
  );

local shuffle17KeyboardLayout = {
  keyboardLayout: [
    {
      HStack: {
        subviews: [
          { Cell: params.keyboard.hpButton.name },
          { Cell: params.keyboard.sh17Button.name },
          { Cell: params.keyboard.zh17Button.name },
          { Cell: params.keyboard.b17Button.name },
          { Cell: params.keyboard.oxvButton.name },
          { Cell: params.keyboard.smButton.name },
        ],
      },
    },
    {
      HStack: {
        subviews: [
          { Cell: params.keyboard.l17Button.name },
          { Cell: params.keyboard.d17Button.name },
          { Cell: params.keyboard.y17Button.name },
          { Cell: params.keyboard.wzButton.name },
          { Cell: params.keyboard.jkButton.name },
          { Cell: params.keyboard.rnButton.name },
        ],
      },
    },
    {
      HStack: {
        subviews: [
          { Cell: params.keyboard.ch17Button.name },
          { Cell: params.keyboard.qGuideButton.name },
          { Cell: params.keyboard.g17Button.name },
          { Cell: params.keyboard.cfButton.name },
          { Cell: params.keyboard.t17Button.name },
          { Cell: params.keyboard.backspaceButton.name },
        ],
      },
    },
    {
      HStack: {
        subviews: [
          { Cell: params.keyboard.numericButton.name },
          { Cell: params.keyboard.spaceButton.name },
          { Cell: params.keyboard.enterButton.name },
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
  + shuffle17KeyboardLayout
  // First Row
  + newMarkedAlphabeticButton(params.keyboard.hpButton, isDark, sixColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.sh17Button, isDark, sixColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.zh17Button, isDark, sixColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.b17Button, isDark, sixColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.oxvButton, isDark, sixColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.smButton, isDark, sixColumnButtonSize + hintStyle)

  // Second Row
  + newMarkedAlphabeticButton(params.keyboard.l17Button, isDark, sixColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.d17Button, isDark, sixColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.y17Button, isDark, sixColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.wzButton, isDark, sixColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.jkButton, isDark, sixColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.rnButton, isDark, sixColumnButtonSize + hintStyle)

  // Third Row
  + newMarkedAlphabeticButton(params.keyboard.ch17Button, isDark, sixColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.qGuideButton, isDark, sixColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.g17Button, isDark, sixColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.cfButton, isDark, sixColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.t17Button, isDark, sixColumnButtonSize + hintStyle)
  + basicStyle.newSystemButton(
    params.keyboard.backspaceButton.name,
    isDark,
    sixColumnButtonSize + params.keyboard.backspaceButton.params,
  )

  // Fourth Row
  + basicStyle.newSystemButton(
    params.keyboard.numericButton.name,
    isDark,
    bottomSystemButtonSize + params.keyboard.numericButton.params,
  )
  + basicStyle.newAlphabeticButton(
    params.keyboard.spaceButton.name,
    isDark,
    params.keyboard.spaceButton.params,
    needHint=false,
  )
  + basicStyle.newSystemButton(
    params.keyboard.enterButton.name,
    isDark,
    bottomSystemButtonSize
    + {
      backgroundStyle: basicStyle.enterButtonBackgroundStyle,
      foregroundStyle: basicStyle.enterButtonForegroundStyle,
    }
    + params.keyboard.enterButton.params,
  );

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
    + basicStyle.returnKeyboardTypeChangedNotification
    + basicStyle.preeditChangedForEnterButtonNotification
    + basicStyle.preeditChangedForSpaceButtonNotification,
}
