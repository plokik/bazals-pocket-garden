# ImageGen provenance

Built-in ImageGen was used, not the CLI/API fallback. Existing production art was supplied as identity reference only and was not overwritten.

## Initial new asset prompt

Reference: `assets/plants/comic/basil_mature_v1.png` from the main project.

> Create ONE new game production asset, a basil plant in a ceramic pot, on a truly transparent alpha background. Use the supplied existing game sprite only as reference for the identity: face-free lush basil, teal ceramic pot with a small leaf emblem. Art direction update: premium cozy illustrated botanical mobile game, softly hand-painted gouache, clean carefully cut alpha edges, readable rounded leaf silhouettes, subtle painterly detail, natural fresh basil greens, muted deep sage-teal pot, warm terracotta saucer. Less glossy, less neon, much finer contours than the reference. Warm sunlight from upper left, soft self-shadow, charming but botanically recognizable basil, no faces. Full plant and entire pot and shallow saucer, all intact with generous transparent margin, straight-on slight view from above, centered balanced asymmetrical canopy. Lower leaves finish above the pot rim with a few thin visible stems. Plant canopy occupies upper 65%, pot and saucer lower 35%. Pot and saucer sit firmly on same horizontal baseline. No environment, no ground plane, no cast shadow beyond a tiny soft contact shadow, no UI, no text, no watermark, no extra objects. High-quality professional standalone 2D hand-painted game sprite; portrait 3:4 composition. Keep image quiet and elegant, not photorealistic or 3D.

Output `exec-bae7c679-8e3d-43e7-a584-ab9fb59367b2.png` had a baked checkerboard (RGB, not RGBA). This rejected source remains in the generation archive only.

## Corrective edit prompt

Reference/edit target: the first generated image.

> Edit this exact illustrated basil asset. Preserve the plant, every leaf, ceramic pot, leaf emblem, shallow saucer, proportions, composition and soft painted style. Replace ALL of the gray checkerboard background with a perfectly flat solid PURE WHITE (#FFFFFF) background, including all tiny holes between leaves and stems. Remove the tiny stray gray marks in the upper left margin. Absolutely no checkerboard and no gray squares anywhere. Pure white opaque background, no transparency visualization. Keep the full plant with intact tip leaves and full saucer in frame. This is a clean product asset on pure white for runtime multiply compositing. Do not add text or any other elements.

Output `exec-c2afe00f-2bd7-480c-98ea-19950b0180b5.png` was copied unchanged to `assets/basil-painted-v1.png`. The first multiply-composited preview allowed background bars to show through the leaves. The final preview instead removes the white matte at render time, leaving the stored PNG unchanged.
