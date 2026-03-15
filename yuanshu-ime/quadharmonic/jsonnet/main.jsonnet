local iPhoneNumeric = import 'Components/iPhoneNumeric.libsonnet';
local iPhonePinyin = import 'Components/iPhonePinyin.libsonnet';
local iPhoneSymbolic = import 'Components/iPhoneSymbolic.libsonnet';
local iPadPinyin = import 'Components/iPadPinyin.libsonnet';
local iPadNumeric = import 'Components/iPadNumeric.libsonnet';

local pinyinPortraitFileName = 'pinyinPortrait';
local lightPinyinPortraitFileContent = iPhonePinyin.new(isDark=false, isPortrait=true);
local darkPinyinPortraitFileContent = iPhonePinyin.new(isDark=true, isPortrait=true);

local pinyinLandscapeFileName = 'pinyinLandscape';
local lightPinyinLandscapeFileContent = iPhonePinyin.new(isDark=false, isPortrait=false);
local darkPinyinLandscapeFileContent = iPhonePinyin.new(isDark=true, isPortrait=false);

local numericPortraitFileName = 'numericPortrait';
local lightNumericPortraitFileContent = iPhoneNumeric.new(isDark=false, isPortrait=true);
local darkNumericPortraitFileContent = iPhoneNumeric.new(isDark=true, isPortrait=true);

local numericLandscapeName = 'numericLandscape';
local lightNumericLandscapeFileContent = iPhoneNumeric.new(isDark=false, isPortrait=false);
local darkNumericLandscapeFileContent = iPhoneNumeric.new(isDark=true, isPortrait=false);

local symbolicPortraitFileName = 'symbolicPortrait';
local lightSymbolicPortraitFileContent = iPhoneSymbolic.new(isDark=false, isPortrait=true);
local darkSymbolicPortraitFileContent = iPhoneSymbolic.new(isDark=true, isPortrait=true);

local symbolicLandscapeName = 'symbolicLandscape';
local lightSymbolicLandscapeFileContent = iPhoneSymbolic.new(isDark=false, isPortrait=false);
local darkSymbolicLandscapeFileContent = iPhoneSymbolic.new(isDark=true, isPortrait=false);

local iPadPinyinPortraitName = 'iPadPinyinPortrait';
local lightIpadPinyinPortraitContent = iPadPinyin.new(isDark=false, isPortrait=true);
local darkIpadPinyinPortraitContent = iPadPinyin.new(isDark=true, isPortrait=true);

local iPadPinyinLandscapeName = 'iPadPinyinLandscape';
local lightIpadPinyinLandscapeContent = iPadPinyin.new(isDark=false, isPortrait=false);
local darkIpadPinyinLandscapeContent = iPadPinyin.new(isDark=true, isPortrait=false);

local iPadNumericPortraitName = 'iPadNumericPortrait';
local lightIpadNumericPortraitContent = iPadNumeric.new(isDark=false, isPortrait=true);
local darkIpadNumericPortraitContent = iPadNumeric.new(isDark=true, isPortrait=true);

local iPadNumericLandscapeName = 'iPadNumericLandscape';
local lightIpadNumericLandscapeContent = iPadNumeric.new(isDark=false, isPortrait=false);
local darkIpadNumericLandscapeContent = iPadNumeric.new(isDark=true, isPortrait=false);

local config = {
  pinyin: {
    iPhone: {
      portrait: pinyinPortraitFileName,
      landscape: pinyinLandscapeFileName,
    },
    iPad: {
      portrait: iPadPinyinPortraitName,
      landscape: iPadPinyinLandscapeName,
      floating: pinyinPortraitFileName,
    },
  },
  numeric: {
    iPhone: {
      portrait: numericPortraitFileName,
      landscape: numericLandscapeName,
    },
    iPad: {
      portrait: iPadNumericPortraitName,
      landscape: iPadNumericLandscapeName,
      floating: numericPortraitFileName,
    },
  },

  // 符号键盘
  symbolic: {
    iPhone: {
      portrait: symbolicPortraitFileName,
      landscape: symbolicLandscapeName,
    },
    iPad: {
      portrait: iPadPinyinPortraitName,
      landscape: iPadPinyinLandscapeName,
      floating: symbolicPortraitFileName,
    },
  },
};

{
  'config.yaml': config,

  // 输出为原始对象，jsonnet -m 会把它们写成 JSON。
  // JSON 是 YAML 的子集，元書可直接读取，同时避免 std.toString 产生的外层字符串包裹。
  ['light/' + pinyinPortraitFileName + '.yaml']: lightPinyinPortraitFileContent,
  ['dark/' + pinyinPortraitFileName + '.yaml']: darkPinyinPortraitFileContent,
  ['light/' + pinyinLandscapeFileName + '.yaml']: lightPinyinLandscapeFileContent,
  ['dark/' + pinyinLandscapeFileName + '.yaml']: darkPinyinLandscapeFileContent,

  ['light/' + numericPortraitFileName + '.yaml']: lightNumericPortraitFileContent,
  ['dark/' + numericPortraitFileName + '.yaml']: darkNumericPortraitFileContent,
  ['light/' + numericLandscapeName + '.yaml']: lightNumericLandscapeFileContent,
  ['dark/' + numericLandscapeName + '.yaml']: darkNumericLandscapeFileContent,

  ['light/' + symbolicPortraitFileName + '.yaml']: lightSymbolicPortraitFileContent,
  ['dark/' + symbolicPortraitFileName + '.yaml']: darkSymbolicPortraitFileContent,
  ['light/' + symbolicLandscapeName + '.yaml']: lightSymbolicLandscapeFileContent,
  ['dark/' + symbolicLandscapeName + '.yaml']: darkSymbolicLandscapeFileContent,

  ['light/' + iPadPinyinPortraitName + '.yaml']: lightIpadPinyinPortraitContent,
  ['dark/' + iPadPinyinPortraitName + '.yaml']: darkIpadPinyinPortraitContent,
  ['light/' + iPadPinyinLandscapeName + '.yaml']: lightIpadPinyinLandscapeContent,
  ['dark/' + iPadPinyinLandscapeName + '.yaml']: darkIpadPinyinLandscapeContent,

  ['light/' + iPadNumericPortraitName + '.yaml']: lightIpadNumericPortraitContent,
  ['dark/' + iPadNumericPortraitName + '.yaml']: darkIpadNumericPortraitContent,
  ['light/' + iPadNumericLandscapeName + '.yaml']: lightIpadNumericLandscapeContent,
  ['dark/' + iPadNumericLandscapeName + '.yaml']: darkIpadNumericLandscapeContent,
}
