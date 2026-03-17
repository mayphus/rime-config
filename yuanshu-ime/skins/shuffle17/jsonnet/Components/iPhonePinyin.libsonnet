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

local rowSideSystemButtonSize = {
  size: { width: '168.75/1125' },
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
  initials: { x: 0.24, y: 0.24 },
  code: { x: 0.76, y: 0.22 },
  main: { x: 0.50, y: 0.44 },
  finalSingle: { x: 0.50, y: 0.76 },
  finalDoubleTop: { x: 0.50, y: 0.69 },
  finalDoubleBottom: { x: 0.50, y: 0.81 },
};

local primaryLegendColor = {
  normalColor: colors.labelColor.primary,
  highlightColor: colors.labelColor.primary,
};

local secondaryLegendColor = {
  normalColor: colors.labelColor.secondary,
  highlightColor: colors.labelColor.secondary,
};

local hasMultipleFinalLines(button) = std.length(std.split(button.legend.finals, '\n')) > 1;
local finalLines(button) = std.split(button.legend.finals, '\n');
local finalLineOne(button) = finalLines(button)[0];
local finalLineTwo(button) = if hasMultipleFinalLines(button) then finalLines(button)[1] else '';

local mainLegendParams = {
  center: legendCenter.main,
} + primaryLegendColor;

local initialsLegendParams = {
  center: legendCenter.initials,
  fontSize: 10.5,
} + primaryLegendColor;

local finalTopLegendParams(button) = {
  center: if hasMultipleFinalLines(button) then legendCenter.finalDoubleTop else legendCenter.finalSingle,
  fontSize: if hasMultipleFinalLines(button) then 8.5 else 10.5,
} + primaryLegendColor;

local finalBottomLegendParams(button) = {
  center: if hasMultipleFinalLines(button) then legendCenter.finalDoubleBottom else legendCenter.finalSingle,
  fontSize: if hasMultipleFinalLines(button) then 8.5 else 10.5,
} + primaryLegendColor;

local codeLegendParams = {
  center: legendCenter.code,
  fontSize: 9.5,
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
        button.name + 'InitialsForegroundStyle',
        button.name + 'FinalTopForegroundStyle',
        button.name + 'FinalBottomForegroundStyle',
        button.name + 'CodeForegroundStyle',
      ],
      uppercasedStateForegroundStyle: [
        button.name + 'MainUppercaseForegroundStyle',
        button.name + 'InitialsForegroundStyle',
        button.name + 'FinalTopForegroundStyle',
        button.name + 'FinalBottomForegroundStyle',
        button.name + 'CodeForegroundStyle',
      ],
      capsLockedStateForegroundStyle: [
        button.name + 'MainUppercaseForegroundStyle',
        button.name + 'InitialsForegroundStyle',
        button.name + 'FinalTopForegroundStyle',
        button.name + 'FinalBottomForegroundStyle',
        button.name + 'CodeForegroundStyle',
      ],
      foregroundStyle: {
        [button.name + 'MainForegroundStyle']:
          basicStyle.newAlphabeticButtonForegroundStyle(isDark, mainLegendParams + button.params),
        [button.name + 'MainUppercaseForegroundStyle']:
          basicStyle.newAlphabeticButtonForegroundStyle(isDark, mainLegendParams + button.params),
        [button.name + 'InitialsForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(isDark, initialsLegendParams + { text: button.legend.initials }),
        [button.name + 'FinalTopForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(
            isDark,
            finalTopLegendParams(button) + { text: if hasMultipleFinalLines(button) then finalLineOne(button) else '' }
          ),
        [button.name + 'FinalBottomForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(
            isDark,
            finalBottomLegendParams(button) + { text: if hasMultipleFinalLines(button) then finalLineTwo(button) else button.legend.finals }
          ),
        [button.name + 'CodeForegroundStyle']:
          basicStyle.newAlphabeticButtonSwipeForegroundStyle(isDark, codeLegendParams + { text: button.legend.code }),
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
          { Cell: params.keyboard.asciiModeButton.name },
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
  + basicStyle.newSystemButton(
    params.keyboard.asciiModeButton.name,
    isDark,
    rowSideSystemButtonSize
    + {
      bounds: { width: '151/168.75', alignment: 'left' },
    }
    + params.keyboard.asciiModeButton.params,
  )
  + newMarkedAlphabeticButton(params.keyboard.ch17Button, isDark, fiveColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.qGuideButton, isDark, fiveColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.g17Button, isDark, fiveColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.cfButton, isDark, fiveColumnButtonSize + hintStyle)
  + newMarkedAlphabeticButton(params.keyboard.t17Button, isDark, fiveColumnButtonSize + hintStyle)
  + basicStyle.newSystemButton(
    params.keyboard.backspaceButton.name,
    isDark,
    rowSideSystemButtonSize
    + {
      bounds: { width: '151/168.75', alignment: 'right' },
    }
    + params.keyboard.backspaceButton.params,
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
