# Grower progress bloom v2

Generated with the built-in OpenAI `image_gen` tool on 2026-09-21 as a new versioned asset. The original v1 PNG remains unchanged.

## Files

- `legendary_progress_bloom_v2_tiered_source.png` — original generated RGB source.
- `legendary_progress_bloom_v2_tiered.png` — derived RGBA production sprite.
- `legendary_progress_bloom_v2_level10_open_source.png` — generated RGB level-10 edit with the closed central bud removed.
- `legendary_progress_bloom_v2_level10_open.png` — derived RGBA level-10 sprite used after the final transition.

The built-in generator rendered a checkerboard into the RGB source despite three explicit transparent-background requests. The production sprite therefore removes only connected and isolated neutral checker pixels while preserving the generated plant. The source is retained for audit and recovery.

## Design contract

- Preserve the v1 magical flower species, glossy painted finish, dark green outline, emerald foliage, warm highlights, planted bulb and coral/gold/turquoise/cream palette.
- Use one continuous taller stem with visually separated branch layers for progressive bottom-to-top reveal.
- Level 1 keeps the existing sprouting seed and renders at the exact height of level 2.
- Levels 2–8 reveal a new branch, bud or flower accent at every step.
- Level 9 ends in a restrained closed bud and short exposed stem.
- During the level 9 to 10 animation, the closed central bud crossfades away while the complete oversized legendary crown appears and remains.
- No UI, text, numbers, pot, soil patch, watermark or second plant.
