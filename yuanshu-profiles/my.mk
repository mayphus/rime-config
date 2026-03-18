# my-yuanshu.mk

# Desktop Schemas (from workspace root)
ROOT_SCHEMAS := cangjie6 cangjie5 flypy jyut6ping3

# Yuanshu App Schemas (from yuanshu-config)
YUANSHU_SCHEMAS := flypy_ice shuffle17_ice

# Patches (.custom.yaml files from yuanshu-config)
YUANSHU_CUSTOM_PATCHES := cangjie5 cangjie6 flypy flypy_ice jyut6ping3 shuffle17_ice

# Which jsonnet skins to compile
PROFILE_SKINS := quadharmonic shuffle17

# Any extra loose files needed without defining a schema
EXTRA_ROOT_FILES := luna_pinyin.dict.yaml terra_pinyin.dict.yaml zhuyin.yaml
