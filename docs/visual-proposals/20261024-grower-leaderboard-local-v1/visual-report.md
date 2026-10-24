# Bazal’s Pocket Garden visual validation

- Manifest: `R:\_projekty\Bazal's Pocket Garden\.agents\skills\how-to-grow-validation\references\visual-cases.json`
- Report-only override: `false`
- Result: `FAILED`

| Case | Mode | Status | Mean abs. error | RMSE | Changed ratio |
| --- | --- | --- | ---: | ---: | ---: |
| room | report | reported | 71.298 | 95.429 | 94.934% |
| locked-slots | report | reported | 72.166 | 89.161 | 97.980% |
| hud | gate | passed | 0.000 | 0.000 | 0.000% |
| navigation | gate | passed | 0.000 | 0.000 | 0.000% |
| storage | gate | passed | 0.000 | 0.000 | 0.000% |
| shop | gate | passed | 0.063 | 1.627 | 0.194% |
| measurement | gate | passed | 0.534 | 8.225 | 0.629% |
| detail-realtime | gate | passed | 0.032 | 1.073 | 0.086% |
| guide-explain | gate | passed | 0.501 | 3.555 | 2.463% |
| guide-celebrate | gate | passed | 0.494 | 3.516 | 2.468% |
| guide-warning | gate | passed | 0.545 | 3.689 | 2.697% |
| feedback-water | gate | passed | 0.072 | 1.613 | 0.226% |
| feedback-growth | gate | passed | 0.078 | 1.676 | 0.250% |
| feedback-coins | gate | passed | 0.000 | 0.000 | 0.000% |
| feedback-unlock | report | reported | 48.427 | 73.116 | 83.948% |
| screen-transition | report | reported | 44.288 | 67.911 | 80.950% |
| phase163-feedback-unlock-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase163-screen-transition-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase149-player-room-exact-target | gate | passed | 1.364 | 12.579 | 1.693% |
| phase150-greenhouse-approved-target | report | reported | 47.830 | 73.236 | 78.127% |
| phase151-rack-approved-target | report | reported | 69.814 | 92.620 | 97.108% |
| phase151-detail-approved-target | report | reported | 87.232 | 113.857 | 97.233% |
| phase152-storage-approved-target | report | reported | 82.111 | 106.288 | 96.514% |
| phase153-shop-approved-target | report | reported | 71.269 | 96.166 | 93.005% |
| phase154-measurement-approved-target | report | reported | 85.072 | 110.808 | 98.722% |
| phase155-herbarium-approved-target | report | reported | 91.411 | 116.101 | 93.505% |
| phase161-daily-challenge-approved-target | report | reported | 80.254 | 106.212 | 94.884% |
| phase162-cosmetic-showroom-approved-target | report | reported | 49.536 | 72.159 | 79.682% |
| phase163-rack-locked-planter-approved-target | report | reported | 75.652 | 98.602 | 97.798% |
| phase151-rack-runtime-approved | report | reported | 51.843 | 77.923 | 83.953% |
| phase151-detail-runtime-approved | gate | passed | 0.032 | 1.073 | 0.086% |
| phase152-storage-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase153-shop-runtime-approved | gate | passed | 0.073 | 1.902 | 0.214% |
| phase154-measurement-runtime-approved | gate | passed | 0.656 | 8.600 | 0.769% |
| phase155-herbarium-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase160-player-room-clean-floor-runtime-approved | report | reported | 65.056 | 89.039 | 97.702% |
| phase162-cosmetic-showroom-runtime-approved | gate | failed | 14.092 | 35.358 | 26.980% |
| phase158-player-room-empty-runtime-approved | gate | passed | 1.110 | 11.339 | 1.437% |
| phase158-player-room-sparse-runtime-approved | report | reported | 64.019 | 87.960 | 97.470% |
| phase158-player-room-phone-save-runtime-approved | report | reported | 63.907 | 88.064 | 97.467% |
| phase158-player-room-full-runtime-approved | report | reported | 65.116 | 89.079 | 97.725% |
| phase159-player-room-cloche-runtime-approved | gate | passed | 1.121 | 11.344 | 1.470% |
| phase159-player-room-full-cloche-runtime-approved | report | reported | 65.116 | 89.080 | 97.726% |
| phase161-daily-challenge-active-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase161-daily-challenge-completed-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase161-daily-challenge-ready-queue-full-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase161-daily-challenge-claimed-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase161-daily-challenge-unavailable-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase163-rack-runtime-approved | gate | passed | 0.142 | 4.541 | 0.139% |
| phase167-player-room-clean-floor-runtime-approved | gate | passed | 1.130 | 11.364 | 1.500% |
| phase167-player-room-sparse-runtime-approved | gate | passed | 1.112 | 11.335 | 1.442% |
| phase167-player-room-phone-save-runtime-approved | gate | passed | 1.111 | 11.336 | 1.444% |
| phase167-player-room-full-runtime-approved | gate | passed | 1.117 | 11.370 | 1.450% |
| phase167-player-room-full-cloche-runtime-approved | gate | passed | 1.124 | 11.349 | 1.480% |

## room

Full deterministic plant rack compared with the approved rack target.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\room\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\room\heatmap.png`
- Reference SHA-256: `807e405c5294c90e22fa67cbe42d490243b9391fc95daac198e09138d12cf327`
- Actual SHA-256: `09a7ee6bb372c66e61893cbe4953d452c73760dfcc6105353c7c31400a6a87b6`

## locked-slots

Level-one locked-slot layout compared with the approved mockup.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\locked-slots\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\locked-slots\heatmap.png`
- Reference SHA-256: `20eda23ede9412d56a156303b9e670caa6032f06e53f1b25287edb7deee9af69`
- Actual SHA-256: `c2eaac240a301e782d2737a5f9015d0ee3ba13ca67bfaa3f9d0bb51376d69830`

## hud

Approved Phase 4 code-native comic HUD with dynamic values masked.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\hud\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\hud\heatmap.png`
- Reference SHA-256: `cc4a0954d7f0169f5cdd322ec6c6542d28a266e86e217cfafd9067f28c44b1ff`
- Actual SHA-256: `cc4a0954d7f0169f5cdd322ec6c6542d28a266e86e217cfafd9067f28c44b1ff`

## navigation

Approved Phase 4 four-card comic mobile navigation.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\navigation\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\navigation\heatmap.png`
- Reference SHA-256: `d61ccdffe4cb033457cfbfb9731b8d32a7042674b67b1a75017434430fbddad4`
- Actual SHA-256: `d61ccdffe4cb033457cfbfb9731b8d32a7042674b67b1a75017434430fbddad4`

## storage

Approved Phase 5 storage cards and four-step processing flow.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\storage\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\storage\heatmap.png`
- Reference SHA-256: `0b586a48521d75131cf6791a410b496b4470d8fbeed6b83513ff39d824c65a43`
- Actual SHA-256: `0b586a48521d75131cf6791a410b496b4470d8fbeed6b83513ff39d824c65a43`

## shop

Approved Phase 5 mobile shop item cards and purchase controls.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\shop\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\shop\heatmap.png`
- Reference SHA-256: `fbc1f1218e881deeadd91cb2b37254ddeb7339d27fbc52b496b105dfcb127fa6`
- Actual SHA-256: `b27ee7229342ea8845297024bf30d573e401c29973a95a6de2362ac8270d06c2`

## measurement

Approved Phase 5 live metrics, comic graph, and knowledge panel.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\measurement\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\measurement\heatmap.png`
- Reference SHA-256: `ab8a819b9b659553682196996fc0a9857e78d512bfb45980806a2ec224133987`
- Actual SHA-256: `278d06526eaf02d9f7c94339b3beb22b88f0e8fa63bd96fd726f91012c29065c`

## detail-realtime

User-approved RC61 plant detail with the current painted scale, saucer and sill grounding; historical references remain preserved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\detail-realtime\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\detail-realtime\heatmap.png`
- Reference SHA-256: `5c7304b3f587933858257fea2a868d40916fc3d90a76af801d0b916a1c5405a0`
- Actual SHA-256: `43a585fef95fe0eff08752837598c7e8a8210a574ba293842126f0da27aea53c`

## guide-explain

User-approved Phase 184 RC59 Professor Bazal explain state over the approved current rack and compact dock; the modal behavior is unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\guide-explain\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\guide-explain\heatmap.png`
- Reference SHA-256: `2027d46b210e4c42d9d250f0041e36bbea039ef30e089312ba208da9c0c52cc8`
- Actual SHA-256: `0635691cd3cd9d85a69ec25ac1cab5bc23d2f8afecb92f205700be0e5be2ddf1`

## guide-celebrate

User-approved Phase 184 RC59 Professor Bazal celebration state over the approved current rack and compact dock; the modal behavior is unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\guide-celebrate\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\guide-celebrate\heatmap.png`
- Reference SHA-256: `69317dfafd6cbe621ecd54a8b30e8a70933d023385468a962280673e98bf092d`
- Actual SHA-256: `e2072acc0823d0bc424341d849769900f5af7d97ea8e29cfafc9b78919348a4c`

## guide-warning

User-approved Phase 184 RC59 Professor Bazal warning state over the approved current rack and compact dock; the modal behavior is unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\guide-warning\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\guide-warning\heatmap.png`
- Reference SHA-256: `9d98bad4856e249690ba7d3d59e06aea6a83c6dc7d381981d11055f67eb44bfe`
- Actual SHA-256: `628463f5ec794963e901166790fa549b9c876fa136e35f8f69bc7125f7a824b8`

## feedback-water

User-approved RC61 watering feedback over the current plant detail; historical references remain preserved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\feedback-water\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\feedback-water\heatmap.png`
- Reference SHA-256: `99b0707e8dcc4657b8532cd1d6d1e29a91471c888252147ae6e78d757a4c6fd3`
- Actual SHA-256: `2ec4ce0ae218f25f36be61c67d65caf1431b23d977c4efff4f533da295946fe0`

## feedback-growth

User-approved RC61 growth feedback over the current plant detail; historical references remain preserved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\feedback-growth\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\feedback-growth\heatmap.png`
- Reference SHA-256: `1955e09e044a4ad880c502248392c53fea19fa05e980e73e67450a8e8e619a47`
- Actual SHA-256: `9317753f728a1f7fc81c73ab76ea0ee83e12c690a762935f34aa0fcc0ffac7e2`

## feedback-coins

Approved Phase 7 shared coin reward feedback effect.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\feedback-coins\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\feedback-coins\heatmap.png`
- Reference SHA-256: `a55296069b2753ebb328d8c37316890dd6fe08bfc76eda7dbe3282afba11b7af`
- Actual SHA-256: `a55296069b2753ebb328d8c37316890dd6fe08bfc76eda7dbe3282afba11b7af`

## feedback-unlock

Historical approved rack-slot unlock feedback over the Phase 151 painted rack. Preserved append-only and superseded by the Phase 163 runtime gate.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\feedback-unlock\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\feedback-unlock\heatmap.png`
- Reference SHA-256: `8de514088c0d91d1522be222b7ab86b29171075d1f1bd3c8546f798ee7508a9d`
- Actual SHA-256: `40b08a036b76c39f6b2aff69379a196fd47e3e57ed805b7816e091691246811b`
- Threshold findings: mean_abs_error=48.426735 > 4.000000; rmse=73.115752 > 12.000000; changed_ratio=0.839482 > 0.060000

## screen-transition

Historical approved directional cyan-gold mobile transition over the Phase 151 painted rack. Preserved append-only and superseded by the Phase 163 runtime gate.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\screen-transition\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\screen-transition\heatmap.png`
- Reference SHA-256: `7c360396115c2180eeb04a129f1191c30508d262b00ab4a2b5096a0cfc430704`
- Actual SHA-256: `2c35520479492a6172068e4310855957a8068856f01ddce47f3e132c23e5b05e`
- Threshold findings: mean_abs_error=44.288271 > 4.000000; rmse=67.911171 > 12.000000; changed_ratio=0.809501 > 0.060000

## phase163-feedback-unlock-runtime-approved

User-approved Phase 184 RC59 rack-slot unlock feedback over the current rack and compact dock. The effect is unchanged; the historical Phase 163 reference remains preserved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase163-feedback-unlock-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase163-feedback-unlock-runtime-approved\heatmap.png`
- Reference SHA-256: `104b2977ffa366127ef18e75b5f56bf8253c374bf28741f473f37d4fb892af1b`
- Actual SHA-256: `40b08a036b76c39f6b2aff69379a196fd47e3e57ed805b7816e091691246811b`

## phase163-screen-transition-runtime-approved

User-approved Phase 184 RC59 cyan-gold screen transition over the current rack and compact dock. The effect is unchanged; the historical Phase 163 reference remains preserved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase163-screen-transition-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase163-screen-transition-runtime-approved\heatmap.png`
- Reference SHA-256: `213e2238af35107b6f903344b469642917a532ae0a9021632ad48dbc56120713`
- Actual SHA-256: `2c35520479492a6172068e4310855957a8068856f01ddce47f3e132c23e5b05e`

## phase149-player-room-exact-target

User-designated exact Phase 149 room composition, normalized to the content area between the global HUD and navigation.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase149-player-room-exact-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase149-player-room-exact-target\heatmap.png`
- Reference SHA-256: `3e223d3ee195f2dd8fb685b391714767978b86ec352cabada303eea003f4daa5`
- Actual SHA-256: `157ca6a05e96f0f8113bb93ed1f53bd593181cbac71642cdaf697e3df9bd8005`

## phase150-greenhouse-approved-target

User-approved Phase 150 painted greenhouse composition, normalized from its 864x1544 content reference to the live content area. This intentionally remains report-only because the reference bakes one concrete crop state while the live view stays dynamic.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase150-greenhouse-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase150-greenhouse-approved-target\heatmap.png`
- Reference SHA-256: `0a780e8c4a707966ed694c7933a15ee5a61b5ed04e88179687d4f46940de2eb2`
- Actual SHA-256: `50c4c9ec381dacb0d24db9f817152c7d81e404c3feba08983086e9768ecd43a1`

## phase151-rack-approved-target

User-approved Phase 151 painted rack concept. It remains report-only because the concept bakes one level and plant state; the separately approved real runtime render is gated below.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase151-rack-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase151-rack-approved-target\heatmap.png`
- Reference SHA-256: `7540369ad83e2dcb0a707052c649e8c0e919d621086b970985ea891eff02697c`
- Actual SHA-256: `ba0fc5b595d9ee5c785ce3657289123b82d374aed2f007ab4cd917cabe18f8a4`

## phase151-detail-approved-target

User-approved Phase 151 painted detail concept. It remains report-only while the separately approved real runtime render is gated below.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase151-detail-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase151-detail-approved-target\heatmap.png`
- Reference SHA-256: `599283f38afd50cfc6d121613f9687e15707cdf56ed1de6fe743765727bcafde`
- Actual SHA-256: `43a585fef95fe0eff08752837598c7e8a8210a574ba293842126f0da27aea53c`

## phase152-storage-approved-target

User-approved Phase 152 painted storage concept. It remains report-only because its inventory values are baked; the separately approved real runtime render is gated below.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase152-storage-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase152-storage-approved-target\heatmap.png`
- Reference SHA-256: `d19d7ea1fdc95ae7a69289b555363f0e104fbe029911e46335bdcce567292d28`
- Actual SHA-256: `6c4f4047668fd493e4fbbb0d7b994ec27fd894008f08e5786071d2e80e4188c0`

## phase153-shop-approved-target

User-approved Phase 153 painted botanical shop composition. Report-only until the user reviews the real dynamic Godot render; prices, stock and category state remain dynamic.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase153-shop-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase153-shop-approved-target\heatmap.png`
- Reference SHA-256: `5a69e32d9ba3ee96feb911f653c4f21cb41d972af5f6599da173eb0dea41d972`
- Actual SHA-256: `61551c27f2a0f306b98dc32af8f5bdf3141846474af650e728e4ac666bf8bff4`

## phase154-measurement-approved-target

User-approved Phase 154 painted botanical measurement composition. It remains report-only because the separately approved real runtime render is gated below; all ten sensor values, the 72-hour graph, guidance and scrolling remain dynamic.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase154-measurement-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase154-measurement-approved-target\heatmap.png`
- Reference SHA-256: `d690acb3d1bcf174f856e7d72498f976991879e24714f9bb1a68d81b5ab46ffb`
- Actual SHA-256: `555205e8cecc5e9c7bf17319e8342cc67331b640bcedc984284c9995fea0f37b`

## phase155-herbarium-approved-target

User-approved Phase 155 painted herbarium composition. Report-only until the user reviews the actual dynamic Godot render; all eleven species, mastery progress, descriptions, rewards, handover replay and vertical scrolling remain live.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase155-herbarium-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase155-herbarium-approved-target\heatmap.png`
- Reference SHA-256: `9aba0f190f2acfc3c7795616b8e9a6c0e2f3805c10b3f0bdc8fc6a9cfdd4c697`
- Actual SHA-256: `1a4c2610265de56e71a509606861edf9673b540016fd7b524197c1ff9d65d2a5`

## phase161-daily-challenge-approved-target

User-approved Phase 161 painted Daily Challenge composition. Report-only until the user reviews the actual layered Godot render; all fourteen challenge types, weather, target availability, status, rewards and pack count remain dynamic.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase161-daily-challenge-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase161-daily-challenge-approved-target\heatmap.png`
- Reference SHA-256: `7972356773a32026e400c97c27df4f70881723f50b2e74e28a010d696a12533e`
- Actual SHA-256: `30696dba6edbe50afafcd11fbbd827039be1d15b5613eb4220a7ff1074906af2`

## phase162-cosmetic-showroom-approved-target

User-approved Phase 162 painted Cosmetic Showroom composition. Report-only until the user reviews the actual layered Godot render; all four themes, wallet values, purchase and selection states, research lock and scrolling remain live.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase162-cosmetic-showroom-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase162-cosmetic-showroom-approved-target\heatmap.png`
- Reference SHA-256: `bc524f1d2c3111630385256481a4acb04cc51d99c2e4cf342d7fa468c3fc5dc0`
- Actual SHA-256: `b767ddd11d3cfdf6902d2810e9516828e1a2357fca6a7cc292ef4108b6478618`

## phase163-rack-locked-planter-approved-target

User-approved Phase 163 painted rack composition with one shared compact locked-planter master and one shared grow-light master. Report-only until the user reviews the actual dynamic Godot render; all ten slots, levels, plant states, care, lights and interactions remain live.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase163-rack-locked-planter-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase163-rack-locked-planter-approved-target\heatmap.png`
- Reference SHA-256: `bd906524ed677fb996098578e3efbed3f19c797ac8078cbc8c7db86aeb1bc349`
- Actual SHA-256: `ba0fc5b595d9ee5c785ce3657289123b82d374aed2f007ab4cd917cabe18f8a4`

## phase151-rack-runtime-approved

Historical exact dynamic Godot rack render approved after Phase 151. Preserved report-only after the user explicitly approved the superseding Phase 163 locked-planter and grow-light runtime.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase151-rack-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase151-rack-runtime-approved\heatmap.png`
- Reference SHA-256: `d02b55e159c0b90622185bb0a6b45e2d35bb0712d8cf50b9a2dee9edad103d90`
- Actual SHA-256: `ba0fc5b595d9ee5c785ce3657289123b82d374aed2f007ab4cd917cabe18f8a4`
- Threshold findings: mean_abs_error=51.843165 > 4.000000; rmse=77.922570 > 12.000000; changed_ratio=0.839528 > 0.060000

## phase151-detail-runtime-approved

Exact RC61 dynamic Godot plant detail explicitly approved by the user; the Phase 151 reference remains preserved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase151-detail-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase151-detail-runtime-approved\heatmap.png`
- Reference SHA-256: `5c7304b3f587933858257fea2a868d40916fc3d90a76af801d0b916a1c5405a0`
- Actual SHA-256: `43a585fef95fe0eff08752837598c7e8a8210a574ba293842126f0da27aea53c`

## phase152-storage-runtime-approved

Exact dynamic Godot painted storage render explicitly approved by the user after Phase 152 implementation.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase152-storage-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase152-storage-runtime-approved\heatmap.png`
- Reference SHA-256: `6c4f4047668fd493e4fbbb0d7b994ec27fd894008f08e5786071d2e80e4188c0`
- Actual SHA-256: `6c4f4047668fd493e4fbbb0d7b994ec27fd894008f08e5786071d2e80e4188c0`

## phase153-shop-runtime-approved

Exact dynamic Godot painted shop render explicitly approved by the user after Phase 153 implementation.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase153-shop-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase153-shop-runtime-approved\heatmap.png`
- Reference SHA-256: `624018d76a496c5f8908324f1f1e3f9cfbcb4c71a23022db29f3cff2103d64b7`
- Actual SHA-256: `61551c27f2a0f306b98dc32af8f5bdf3141846474af650e728e4ac666bf8bff4`

## phase154-measurement-runtime-approved

Exact dynamic Godot painted Measurement render explicitly approved by the user after Phase 154 implementation.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase154-measurement-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase154-measurement-runtime-approved\heatmap.png`
- Reference SHA-256: `73c7841758773fd827a42d9712dd495014be61fde8853cedcc0052b941660030`
- Actual SHA-256: `555205e8cecc5e9c7bf17319e8342cc67331b640bcedc984284c9995fea0f37b`

## phase155-herbarium-runtime-approved

Exact dynamic Godot painted Herbarium render explicitly approved by the user for RC61.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase155-herbarium-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase155-herbarium-runtime-approved\heatmap.png`
- Reference SHA-256: `1a4c2610265de56e71a509606861edf9673b540016fd7b524197c1ff9d65d2a5`
- Actual SHA-256: `1a4c2610265de56e71a509606861edf9673b540016fd7b524197c1ff9d65d2a5`

## phase160-player-room-clean-floor-runtime-approved

Historical Exact dynamic Godot painted Player Room clean-floor render explicitly approved by the user after Phase 160 implementation. Preserved report-only after the user approved the Phase 167 repaired room rack; superseded by phase167-player-room-clean-floor-runtime-approved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase160-player-room-clean-floor-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase160-player-room-clean-floor-runtime-approved\heatmap.png`
- Reference SHA-256: `a0a7d7d1a4120320fc0084af65429e9f997ac9cad29e51decf20278869363bd2`
- Actual SHA-256: `1728f80400507e78288ceba9129202e1d5a4ec70c9c6a2daab8b98e2a4787697`
- Threshold findings: mean_abs_error=65.056314 > 4.000000; rmse=89.038988 > 12.000000; changed_ratio=0.977016 > 0.060000

## phase162-cosmetic-showroom-runtime-approved

Exact dynamic Godot painted Cosmetic Showroom selected-state render explicitly approved by the user after Phase 162 implementation.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase162-cosmetic-showroom-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase162-cosmetic-showroom-runtime-approved\heatmap.png`
- Reference SHA-256: `410dbea6fad1337ebb657bda2f0a0f7fa466e80b42ce5bec228a67cfca562dc7`
- Actual SHA-256: `b767ddd11d3cfdf6902d2810e9516828e1a2357fca6a7cc292ef4108b6478618`
- Threshold findings: mean_abs_error=14.091654 > 4.000000; rmse=35.357709 > 12.000000; changed_ratio=0.269796 > 0.060000

## phase158-player-room-empty-runtime-approved

Exact empty 0/20 Player Room Godot render explicitly approved by the user after the Phase 158 compositing repair.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase158-player-room-empty-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase158-player-room-empty-runtime-approved\heatmap.png`
- Reference SHA-256: `cd94031182f3c48f2da44e8dc571f0a90259ddb60c66498b7fb57f94b4a723b4`
- Actual SHA-256: `8ac984e3a1e2df0f6479ef8c35e25e54384fc664f85faf8dc6fd32a82c8ffb26`

## phase158-player-room-sparse-runtime-approved

Historical Exact sparse 4/20 Player Room Godot render explicitly approved by the user after the Phase 158 compositing repair. Preserved report-only after the user approved the Phase 167 repaired room rack; superseded by phase167-player-room-sparse-runtime-approved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase158-player-room-sparse-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase158-player-room-sparse-runtime-approved\heatmap.png`
- Reference SHA-256: `d5ad610b315cc4baa2f5adf8539eace3e3bd4b6553582768dbd362b89428da27`
- Actual SHA-256: `80b60c76e892213ce6066a58749e292e6a72d9e22d45e6e39dc2c0ffdcf312e9`
- Threshold findings: mean_abs_error=64.019315 > 4.000000; rmse=87.960223 > 12.000000; changed_ratio=0.974699 > 0.060000

## phase158-player-room-phone-save-runtime-approved

Historical Exact sanitized phone-save 10/20 Player Room Godot render explicitly approved by the user after the Phase 158 compositing repair. Preserved report-only after the user approved the Phase 167 repaired room rack; superseded by phase167-player-room-phone-save-runtime-approved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase158-player-room-phone-save-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase158-player-room-phone-save-runtime-approved\heatmap.png`
- Reference SHA-256: `cf100a3653df0f30ee0f6728db58001ffc91e797e321a6abbc5fac0112dba93b`
- Actual SHA-256: `bb218234dd2d4f27881f122df6160013353c66a9fcf07fe13ade4ea808187459`
- Threshold findings: mean_abs_error=63.906561 > 4.000000; rmse=88.063926 > 12.000000; changed_ratio=0.974667 > 0.060000

## phase158-player-room-full-runtime-approved

Historical Exact full 20/20 Player Room Godot render with the enlarged Phase 159 cloche explicitly approved by the user. Preserved report-only after the user approved the Phase 167 repaired room rack; superseded by phase167-player-room-full-runtime-approved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase158-player-room-full-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase158-player-room-full-runtime-approved\heatmap.png`
- Reference SHA-256: `42804f92f7dc9b278511364e091498f9585458abb2da367d1eb6bec9feaa1f87`
- Actual SHA-256: `fdc887c5bf2de8d035c990a2eb286bba2139bdc9835f3ce401555e4a10dc8071`
- Threshold findings: mean_abs_error=65.115749 > 4.000000; rmse=89.079177 > 12.000000; changed_ratio=0.977252 > 0.060000

## phase159-player-room-cloche-runtime-approved

Exact Player Room Godot render containing only the Phase 159 botanical cloche at the user-approved 115 percent scale.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase159-player-room-cloche-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase159-player-room-cloche-runtime-approved\heatmap.png`
- Reference SHA-256: `efe3b6f6e9880612b8ffe6eef1476d10f6a22f849fed31165c4af0e04e554725`
- Actual SHA-256: `22d1f928470073c4335bf4a70ce71cb4b6032e5f5cfc6cfcdc50074c3d53cb18`

## phase159-player-room-full-cloche-runtime-approved

Historical Exact full Player Room Godot render with the Phase 159 botanical cloche at the user-approved 115 percent scale. Preserved report-only after the user approved the Phase 167 repaired room rack; superseded by phase167-player-room-full-cloche-runtime-approved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase159-player-room-full-cloche-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase159-player-room-full-cloche-runtime-approved\heatmap.png`
- Reference SHA-256: `42804f92f7dc9b278511364e091498f9585458abb2da367d1eb6bec9feaa1f87`
- Actual SHA-256: `564e60b6dd75382bc5aea30c183edf4a9438938753e02cc2b929e6121ac31445`
- Threshold findings: mean_abs_error=65.116251 > 4.000000; rmse=89.079853 > 12.000000; changed_ratio=0.977262 > 0.060000

## phase161-daily-challenge-active-runtime-approved

Exact active Daily Challenge Godot render explicitly approved by the user for RC61.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase161-daily-challenge-active-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase161-daily-challenge-active-runtime-approved\heatmap.png`
- Reference SHA-256: `30696dba6edbe50afafcd11fbbd827039be1d15b5613eb4220a7ff1074906af2`
- Actual SHA-256: `30696dba6edbe50afafcd11fbbd827039be1d15b5613eb4220a7ff1074906af2`

## phase161-daily-challenge-completed-runtime-approved

Exact completed Daily Challenge Godot render explicitly approved by the user for RC61.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase161-daily-challenge-completed-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase161-daily-challenge-completed-runtime-approved\heatmap.png`
- Reference SHA-256: `b7f5d4a9373c076b9e16fbbe669bacc9779bacfbc9b4f9a4ec88f92da0146aba`
- Actual SHA-256: `b7f5d4a9373c076b9e16fbbe669bacc9779bacfbc9b4f9a4ec88f92da0146aba`

## phase161-daily-challenge-ready-queue-full-runtime-approved

Exact ready Daily Challenge with a full botanical-pack queue explicitly approved by the user for RC61.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase161-daily-challenge-ready-queue-full-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase161-daily-challenge-ready-queue-full-runtime-approved\heatmap.png`
- Reference SHA-256: `211247ec03ac49bd5719dd9461054951902caca37849c436508dd1a073c6fa6b`
- Actual SHA-256: `211247ec03ac49bd5719dd9461054951902caca37849c436508dd1a073c6fa6b`

## phase161-daily-challenge-claimed-runtime-approved

Exact claimed Daily Challenge Godot render explicitly approved by the user for RC61.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase161-daily-challenge-claimed-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase161-daily-challenge-claimed-runtime-approved\heatmap.png`
- Reference SHA-256: `f19994e9ee885bc9b09c7a1d1c8e6462cdf4480d501265f63b02e0aed51bab21`
- Actual SHA-256: `f19994e9ee885bc9b09c7a1d1c8e6462cdf4480d501265f63b02e0aed51bab21`

## phase161-daily-challenge-unavailable-runtime-approved

Exact unavailable-target Daily Challenge Godot render explicitly approved by the user for RC61.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase161-daily-challenge-unavailable-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase161-daily-challenge-unavailable-runtime-approved\heatmap.png`
- Reference SHA-256: `bae3cd4ffcfcea595265bc7a8b6b0a7b47182868caff426d3c69d3379bb79180`
- Actual SHA-256: `bae3cd4ffcfcea595265bc7a8b6b0a7b47182868caff426d3c69d3379bb79180`

## phase163-rack-runtime-approved

Exact Phase 184 RC59 dynamic Godot rack explicitly approved by the user with the later Phase 171 grounding and Phase 183 compact dock; the Phase 163 reference remains preserved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase163-rack-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase163-rack-runtime-approved\heatmap.png`
- Reference SHA-256: `9bf2e2dfaae18c00dd9fac0f53727353840b9604db3e9cb216aef0e441c03757`
- Actual SHA-256: `ba0fc5b595d9ee5c785ce3657289123b82d374aed2f007ab4cd917cabe18f8a4`

## phase167-player-room-clean-floor-runtime-approved

User-approved Phase 167 repaired room rack artwork in the inherited clean-floor fixture. The approved room render is recorded separately; fixture state, crop, masks and thresholds are unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase167-player-room-clean-floor-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase167-player-room-clean-floor-runtime-approved\heatmap.png`
- Reference SHA-256: `63dac160e77aed823118c92d19a9f39a9672e971174ee2bc5ab48695ad204290`
- Actual SHA-256: `1728f80400507e78288ceba9129202e1d5a4ec70c9c6a2daab8b98e2a4787697`

## phase167-player-room-sparse-runtime-approved

User-approved Phase 167 repaired room rack artwork in the inherited sparse fixture. The approved room render is recorded separately; fixture state, crop, masks and thresholds are unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase167-player-room-sparse-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase167-player-room-sparse-runtime-approved\heatmap.png`
- Reference SHA-256: `19ab2173d2a1d8a9ba3c9e7b5bf848650c9d0902ef50eed6804fa3a623722aac`
- Actual SHA-256: `80b60c76e892213ce6066a58749e292e6a72d9e22d45e6e39dc2c0ffdcf312e9`

## phase167-player-room-phone-save-runtime-approved

User-approved Phase 167 repaired room rack artwork in the inherited phone-save fixture. The approved room render is recorded separately; fixture state, crop, masks and thresholds are unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase167-player-room-phone-save-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase167-player-room-phone-save-runtime-approved\heatmap.png`
- Reference SHA-256: `55ac1daeea306c1f1ae0042388506c42046dfccbe772dda4617a48628b14975e`
- Actual SHA-256: `bb218234dd2d4f27881f122df6160013353c66a9fcf07fe13ade4ea808187459`

## phase167-player-room-full-runtime-approved

User-approved Phase 167 repaired room rack artwork in the inherited full fixture. The approved room render is recorded separately; fixture state, crop, masks and thresholds are unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase167-player-room-full-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase167-player-room-full-runtime-approved\heatmap.png`
- Reference SHA-256: `92f986c9a12d8c956b4fb6643cec0ed4a101644cd2e420392fb0d17fb4c916ed`
- Actual SHA-256: `fdc887c5bf2de8d035c990a2eb286bba2139bdc9835f3ce401555e4a10dc8071`

## phase167-player-room-full-cloche-runtime-approved

User-approved Phase 167 repaired room rack artwork in the inherited full-cloche fixture. The approved room render is recorded separately; fixture state, crop, masks and thresholds are unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase167-player-room-full-cloche-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261024-123520Z\phase167-player-room-full-cloche-runtime-approved\heatmap.png`
- Reference SHA-256: `107136155f2ccd6cc15c1c4d6c306d6aa07d8aa5013f48169ff1b078c779f953`
- Actual SHA-256: `564e60b6dd75382bc5aea30c183edf4a9438938753e02cc2b929e6121ac31445`
