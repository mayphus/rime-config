# `shuffle17` / `亂序17` Schema Plan

## Goal

Create a real Rime schema for the `亂序17` input method, not just a visual skin.

This plan treats `shuffle17` as the internal ASCII-safe repo name and `亂序17` as the user-facing name.

## Feasibility Verdict

`亂序17` is feasible in Rime.

Reason:

- Rime explicitly supports custom schema design through `speller/algebra`, which is the same mechanism already used for double-pinyin schemes.
- `落格十七` is documented as a layout-and-scheme pair descended from `乱序17键双拼`, with fixed rules like two presses per syllable, merged initial keys, and a zero-initial guide key.
- Existing Rime projects already expose `乱序17` as a selectable spelling scheme, which means this is not a theoretical edge case.

## External References

- Rime schema design and spelling algebra:
  [RimeWithSchemata](https://github.com/rime/home/wiki/RimeWithSchemata)
- Official `落格十七` concept page:
  [什么是 落格十七？](https://docs.logcg.com/concept/whatis17key/)
- Official `落格十七` keyboard-layout page:
  [界面调整 / 键盘布局](https://docs.logcg.com/ui-ios/pian-hao/above/)
- Evidence of an existing Rime-based implementation path:
  [amzxyz/rime_wanxiang](https://github.com/amzxyz/rime_wanxiang)

## What The Docs Confirm

From the official `落格十七` docs:

- `落格十七` is a descendant of `乱序17键双拼`.
- One syllable is normally entered with two key presses.
- Some keys merge multiple initials, for example `wz`.
- Bare vowels such as `a`, `en`, `ao` use `q~` as a zero-initial guide key.
- `zh`, `ch`, and `sh` have dedicated keys.
- The layout is a paired layout+scheme, not just a display skin.
- Example input: `落格` is entered as `l,ms,g,wz`.
- Auxiliary-code behavior exists, but it is optional and can be deferred.

## Local Repo Constraints

Relevant local files:

- Existing double-pinyin schema:
  [flypy_ice.schema.yaml](/Users/mayphus/Library/Rime/yuanshu-ime/flypy_ice.schema.yaml)
- Existing copied skin scaffold:
  [README.md](/Users/mayphus/Library/Rime/yuanshu-ime/skins/shuffle17/README.md)
- Current keyboard layout implementation:
  [iPhonePinyin.libsonnet](/Users/mayphus/Library/Rime/yuanshu-ime/skins/shuffle17/jsonnet/Components/iPhonePinyin.libsonnet)
- Current key-definition file:
  [Keyboard.libsonnet](/Users/mayphus/Library/Rime/yuanshu-ime/skins/shuffle17/jsonnet/Constants/Keyboard.libsonnet)

The repo already proves two important things:

- We can build a custom Rime schema by copying and adapting `flypy_ice`.
- We can build a non-26-key on-screen keyboard because the layout is manually assembled in Jsonnet rather than generated from a fixed template.

## Core Design Decision

Do not make the schema use visible key legends such as `wz`, `ms`, `q~`, `hp`, or `hq` as raw input codes.

Use a separate internal one-character alphabet for the 17 physical keys.

Recommended approach:

- Assign each physical key a stable internal code such as `a` through `q`.
- Let the skin display the visible legends, for example `wz` or `q~`.
- Let each on-screen key emit exactly one internal code character.
- Let `speller/algebra` map full pinyin syllables into those internal code sequences.

Why this is the right design:

- Rime `speller/alphabet` is simplest when each physical key emits one unique character.
- Visible legends like `wz` and `ms` are labels, not good storage keys.
- Some visible labels share left letters or contain punctuation, which would create collisions or awkward edge cases if used directly as the schema alphabet.
- This cleanly separates UI layout from input encoding logic.

## Proposed File Layout

Phase 1 should add these files:

- `yuanshu-ime/shuffle17_ice.schema.yaml`
- `yuanshu-ime/shuffle17_ice.custom.yaml`

Optional support files if the mapping grows complex:

- `yuanshu-ime/shuffle17.mapping.yaml`
- `yuanshu-ime/shuffle17.tests.md`

Phase 1 does not require a new dictionary file.

The schema should continue to reuse the existing `rime_ice` dictionary and `cangjie6` reverse lookup, just like the current `flypy_ice` path.

## Proposed Schema Shape

The new schema should be cloned from `flypy_ice` and then simplified toward `亂序17`.

Recommended top-level shape:

```yaml
schema:
  schema_id: shuffle17_ice
  name: 亂序17
  version: "0.1"
  dependencies:
    - cangjie6

engine:
  processors:
    - ascii_composer
    - recognizer
    - key_binder
    - speller
    - punctuator
    - selector
    - navigator
    - express_editor
  segmentors:
    - ascii_segmentor
    - matcher
    - abc_segmentor
    - punct_segmentor
    - fallback_segmentor
  translators:
    - punct_translator
    - reverse_lookup_translator
    - script_translator
  filters:
    - simplifier
    - uniquifier

speller:
  alphabet: abcdefghijklmnopq
  delimiter: " '"
  algebra:
    # full pinyin -> internal 17-key codes

translator:
  dictionary: rime_ice
  prism: shuffle17_ice

reverse_lookup:
  dictionary: cangjie6
```

## Phase 1 Scope

Phase 1 should implement only the base `亂序17` input rule set:

- base 17-key layout
- two-key syllable input
- zero-initial guide behavior
- dedicated `zh`, `ch`, `sh`
- candidate output using existing dictionaries
- reverse lookup using existing `cangjie6`

Phase 1 should not implement:

- 自然码辅码
- 小牛辅码
- app-specific point/sweep auto-generation behavior
- any alternative layout variants

These are valid future extensions, but they should not block the first working schema.

## Required Mapping Table

Before implementation, we need one authoritative transcription of the official 17-key chart.

This table should be filled from the official layout image before writing algebra:

| key_id | internal_code | visible_label | initial_group | final_group | notes |
| --- | --- | --- | --- | --- | --- |
| K01 | a | `HP` | `h, p` | `a, ia, ua` | |
| K02 | b | `Sh` | `sh` | `en, in` | |
| K03 | c | `Zh` | `zh` | `ang, iao` | |
| K04 | d | `B` | `b` | `ao, iong` | |
| K05 | e | `o X v` | `x` | `o, v, uai, uan` | `v` maps to `ü` |
| K06 | f | `SM` | `s, m` | `ie, uo` | matches `ms` in the documented `落格` example |
| K07 | g | `L` | `l` | `ai, ue` | |
| K08 | h | `D` | `d` | `u` | |
| K09 | i | `Y` | `y` | `eng, ing` | |
| K10 | j | `WZ` | `w, z` | `e` | |
| K11 | k | `JK` | `j, k` | `i` | |
| K12 | l | `RN` | `r, n` | `an` | |
| K13 | m | `Ch` | `ch` | `iang, ui` | |
| K14 | n | `Q~` | `q` | `ian, uang` | `~` acts as the zero-initial guide key |
| K15 | o | `G` | `g` | `ei, un` | |
| K16 | p | `CF` | `c, f` | `iu, ou` | |
| K17 | q | `T` | `t` | `er, ong` | |

## Algebra Strategy

Once the 17-key table is transcribed, implement the schema in three stages.

### Stage 1: Normalize Full Pinyin

Normalize full pinyin syllables the same way a double-pinyin schema does:

- support `j/q/x + u -> v` style handling where needed
- handle `zh`, `ch`, `sh` as explicit initials
- handle bare-vowel syllables with a zero-initial marker

This is the same class of transformation already shown in Rime’s spelling-algebra documentation and in the current `flypy_ice` schema.

### Stage 2: Map Initials To Internal Key Codes

For example:

- `w` and `z` would both map to the same internal code for the `wz` key
- `zh`, `ch`, `sh` would each map to their dedicated internal keys
- the zero-initial guide would map to the internal code of the `q~` key

### Stage 3: Map Finals To Internal Key Codes

Each final or final-group must map to one internal key code according to the official 17-key chart.

Examples we already know from docs:

- `a` uses the visible `hp` key
- bare-vowel syllables use the `q~` guide key as the first press

## Validation Plan

After the table is transcribed and the schema is implemented, verify with explicit examples.

Minimum tests:

- `落格` should follow the documented example sequence.
- Bare-vowel cases like `a`, `ao`, `en` should require the zero-initial guide key.
- `zh`, `ch`, `sh` syllables should resolve through dedicated keys.
- Merged-initial keys like `wz` should accept both initials.
- The schema should still produce candidates through `rime_ice`.

Suggested test list:

- `落` / `格`
- `a`
- `ao`
- `en`
- `zhong`
- `chi`
- `shi`
- one `w`-initial syllable
- one `z`-initial syllable

## Skin Plan

Once the schema exists, the `shuffle17` skin can become a real companion skin.

Skin tasks:

- replace the current copied 26-key layout with a real 17-key layout
- display visible legends from the official chart
- keep punctuation, tool buttons, and mode switching consistent with existing skins
- make each visible key emit one internal code character, not the printed legend

This is why the schema and skin should be built together, but in separate layers.

## Recommended Order Of Work

1. Transcribe the official 17-key chart into the mapping table above.
2. Add `yuanshu-ime/shuffle17_ice.schema.yaml` as a copy of `flypy_ice.schema.yaml`.
3. Replace Xiaohe algebra with `亂序17` algebra using internal key codes.
4. Verify the schema with a small fixed test list.
5. Rework `skins/shuffle17` into a true 17-key keyboard.
6. Add export support for packaging `shuffle17.cskin`.
7. Only after that, consider 自然码辅码 or 小牛辅码.

## Current Blocker

One blocker remains before implementation:

We still need a complete transcription of the official 17-key layout image into a machine-readable table.

The docs we could access confirm the rules and several concrete keys, but they do not expose the full 17-key chart as plain text.
