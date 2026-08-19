# Bazal’s Pocket Garden — comic botanical style bible

Status: approved production direction, version 1, 2026-08-11.

## Visual identity

Bazal’s Pocket Garden uses original high-energy Western cartoon game art. The world is a cheerful improvised botanical workshop: bright daylight, bold silhouettes, playful hand-drawn irregularity and immediate mobile readability.

The supplied reference screenshots define only broad visual qualities. Never copy their characters, weapons, monsters, logos, compositions or recognisable UI assets.

Core traits:

- strong dark navy-black contour;
- crisp cel-shaded colour blocks;
- one hard shadow family and one bright highlight family;
- exaggerated but readable proportions;
- saturated clean colours and minimal surface noise;
- chunky comic UI with simple pseudo-depth;
- plants show personality through silhouette and motion, never through faces;
- the guide character carries facial expression and humour.

Avoid ornate fantasy filigree, luxury card-game framing, realistic rendering, anime, pixel art, 3D-render appearance, brown dominance and grey grading.

## Semantic palette

| Role | Primary | Dark/shadow | Highlight |
| --- | --- | --- | --- |
| Ink and contour | `#17212B` | `#0B1118` | — |
| Information / water | `#27BDE2` | `#087A9C` | `#C9F7FF` |
| Growth / health | `#91DC18` | `#347F16` | `#E7FF73` |
| Locked / magic | `#8B55D9` | `#4C2C86` | `#D9B8FF` |
| Action / attention | `#FF861C` | `#B64019` | `#FFD06A` |
| Reward | `#FFD51E` | `#B76B08` | `#FFF5A3` |
| Danger | `#F0443B` | `#941E28` | `#FFAAA0` |
| Text-safe cream | `#FFF0C6` | `#D7A85A` | `#FFFBE9` |
| Structural wood only | `#A45A2B` | `#5D2E22` | `#E59B49` |

Do not use colour as decoration alone. The same state keeps the same semantic colour on every screen.

## Shape and rendering rules

- At the 432 × 960 logical viewport, hero silhouettes use a 3–4 px contour, UI frames 3 px and internal details 1.5–2 px.
- Light always comes from upper left.
- A material receives at most one dominant shadow colour and one dominant highlight colour.
- Corners are clipped or hand-rounded, not ornate.
- Wood appears only where it is structurally meaningful: shelves, workshop boards and crates.
- Icons use the same front three-quarter perspective and fill 72–82% of their safe square.
- Text is rendered by Godot. Generated assets never contain baked labels or pseudo-text.
- Czech diacritics are mandatory for every selected font.

## Plant and pot rules

- Plants remain botanically recognisable at phone size.
- Leaves may be exaggerated, asymmetrical and elastic, but never receive eyes or mouths.
- The pot and plant form one readable sprite for rack-scale use.
- Pot colour can identify a slot family; gameplay state is communicated by badges and effects, not by recolouring the plant.
- Dry or unhealthy states use posture and restrained tinting. Never turn the whole plant grey.

## UI component rules

Every component supplies `normal`, `pressed`, `disabled`, `selected` and, where applicable, `locked` states.

- Normal: clear base colour, dark contour, upper-left highlight and compact lower-right shadow.
- Pressed: 94–96% scale, highlight reduced, content shifted down by 1–2 logical pixels.
- Selected: lime contour plus one short yellow-green flash. No permanent glow cloud.
- Locked: purple cover or badge with a yellow lock; readable silhouette before text.
- Disabled: reduce saturation and contrast, but keep text readable.

## Motion language

Motion must feel elastic and purposeful rather than continuous and noisy.

| Event | Duration | Motion |
| --- | ---: | --- |
| Idle plant | 2.8–4.2 s loop | 0.8–1.8° sway and 0.5–1% breathing scale |
| Button press | 0.20–0.28 s | compress to 95%, return with `TRANS_BACK` |
| Slot selection | 0.30–0.38 s | 103–105% pop, lime contour, one settling bounce |
| Water | 0.65–0.85 s | six outlined drops, two splashes, short plant bounce |
| Growth | 0.70–0.90 s | squash/stretch, eight leaf motes, lime burst |
| Unlock | 0.65–0.80 s | lock shake, cover pop, yellow burst and settle |
| Reward | 0.55–0.80 s | item flies to HUD with arc, rotation and scale settle |

Animation remains deterministic when paused. Screenshot capture freezes fixed states; only narrow changing-value or effect regions may be masked.

## Effect budgets

- At most 12 prominent particles for a single interaction.
- At most one additive glow layer per component.
- No permanent full-screen bloom.
- Effects must preserve the contour and silhouette of the affected object.
- Water is cyan, growth is lime, unlock/reward is yellow, magic is purple and danger is red.

## Asset production contract

1. Start from approved project reference images and this document.
2. Generate or draw one modular asset at a time.
3. Use a flat removable chroma background when alpha is required.
4. Remove the key locally, inspect alpha edges and keep the chroma source beside the runtime derivative.
5. Store versioned files; never overwrite an approved source silently.
6. Import in Godot, validate at the actual phone scale and test every interaction state.
7. Promote a capture to an approved regression reference only after explicit user approval.

## Approved version-1 sources

- Direction mockup: `docs/art_direction/comic_botanical_room_direction_v1.png`.
- Mature basil chroma source: `assets/plants/comic/basil_mature_chroma_v1.png`.
- Mature basil runtime alpha: `assets/plants/comic/basil_mature_v1.png`.

The direction mockup is not a runtime screen texture. It defines hierarchy, shape language and palette only.

The mature basil was generated with the built-in ImageGen workflow using the three user-provided screenshots as style references and the approved room mockup as a project reference. The prompt required an original, face-free mature basil, teal pot, bold contour, crisp cel shading, no text, no copied characters and a flat magenta removal background.

## First vertical-slice acceptance

The initial playable slice is complete only when:

- the selected mature rack slot uses the new comic basil;
- the plant detail uses the same asset rather than an unrelated redraw;
- idle sway, button/action bounce, water, growth sparkle and unlock feedback remain functional;
- effects use the semantic palette and outlined comic rendering;
- the full regression suite passes;
- deterministic room and locked-slot captures are produced without changing approved references.
