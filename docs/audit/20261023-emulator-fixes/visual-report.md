# Bazal’s Pocket Garden visual validation

- Manifest: `R:\_projekty\Bazal's Pocket Garden\.agents\skills\how-to-grow-validation\references\visual-cases.json`
- Report-only override: `false`
- Result: `FAILED`

| Case | Mode | Status | Mean abs. error | RMSE | Changed ratio |
| --- | --- | --- | ---: | ---: | ---: |
| room | report | reported | 71.292 | 95.421 | 94.926% |
| locked-slots | report | reported | 72.166 | 89.161 | 97.980% |
| hud | gate | passed | 0.000 | 0.000 | 0.000% |
| navigation | gate | passed | 0.000 | 0.000 | 0.000% |
| storage | gate | passed | 0.000 | 0.000 | 0.000% |
| shop | gate | passed | 0.094 | 2.280 | 0.288% |
| measurement | gate | passed | 0.584 | 8.418 | 0.790% |
| detail-realtime | gate | passed | 0.062 | 1.777 | 0.187% |
| guide-explain | gate | passed | 0.501 | 3.555 | 2.463% |
| guide-celebrate | gate | passed | 0.494 | 3.516 | 2.468% |
| guide-warning | gate | passed | 0.545 | 3.689 | 2.697% |
| feedback-water | gate | passed | 0.134 | 2.731 | 0.414% |
| feedback-growth | gate | passed | 0.153 | 2.899 | 0.469% |
| feedback-coins | gate | passed | 0.000 | 0.000 | 0.000% |
| feedback-unlock | report | reported | 48.427 | 73.116 | 83.948% |
| screen-transition | report | reported | 44.288 | 67.911 | 80.950% |
| phase163-feedback-unlock-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase163-screen-transition-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase149-player-room-exact-target | gate | passed | 1.373 | 12.616 | 1.700% |
| phase150-greenhouse-approved-target | report | reported | 47.830 | 73.235 | 78.127% |
| phase151-rack-approved-target | report | reported | 69.823 | 92.632 | 97.108% |
| phase151-detail-approved-target | report | reported | 87.234 | 113.859 | 97.233% |
| phase152-storage-approved-target | report | reported | 82.111 | 106.288 | 96.514% |
| phase153-shop-approved-target | report | reported | 71.268 | 96.164 | 93.004% |
| phase154-measurement-approved-target | report | reported | 85.072 | 110.808 | 98.721% |
| phase155-herbarium-approved-target | report | reported | 91.411 | 116.101 | 93.505% |
| phase161-daily-challenge-approved-target | report | reported | 80.254 | 106.212 | 94.884% |
| phase162-cosmetic-showroom-approved-target | report | reported | 49.536 | 72.159 | 79.682% |
| phase163-rack-locked-planter-approved-target | report | reported | 75.676 | 98.635 | 97.799% |
| phase151-rack-runtime-approved | report | reported | 51.836 | 77.914 | 83.953% |
| phase151-detail-runtime-approved | gate | passed | 0.062 | 1.777 | 0.187% |
| phase152-storage-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase153-shop-runtime-approved | gate | passed | 0.105 | 2.479 | 0.315% |
| phase154-measurement-runtime-approved | gate | passed | 0.698 | 8.732 | 0.895% |
| phase155-herbarium-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase160-player-room-clean-floor-runtime-approved | report | reported | 65.054 | 89.036 | 97.702% |
| phase162-cosmetic-showroom-runtime-approved | gate | failed | 14.092 | 35.358 | 26.980% |
| phase158-player-room-empty-runtime-approved | gate | passed | 1.117 | 11.372 | 1.443% |
| phase158-player-room-sparse-runtime-approved | report | reported | 64.016 | 87.956 | 97.470% |
| phase158-player-room-phone-save-runtime-approved | report | reported | 63.902 | 88.058 | 97.467% |
| phase158-player-room-full-runtime-approved | report | reported | 65.113 | 89.075 | 97.725% |
| phase159-player-room-cloche-runtime-approved | gate | passed | 1.118 | 11.363 | 1.445% |
| phase159-player-room-full-cloche-runtime-approved | report | reported | 65.113 | 89.076 | 97.726% |
| phase161-daily-challenge-active-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase161-daily-challenge-completed-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase161-daily-challenge-ready-queue-full-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase161-daily-challenge-claimed-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase161-daily-challenge-unavailable-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase163-rack-runtime-approved | gate | passed | 0.000 | 0.000 | 0.000% |
| phase167-player-room-clean-floor-runtime-approved | gate | passed | 1.123 | 11.360 | 1.462% |
| phase167-player-room-sparse-runtime-approved | gate | passed | 1.118 | 11.370 | 1.446% |
| phase167-player-room-phone-save-runtime-approved | gate | passed | 1.119 | 11.371 | 1.448% |
| phase167-player-room-full-runtime-approved | gate | passed | 1.118 | 11.361 | 1.451% |
| phase167-player-room-full-cloche-runtime-approved | gate | passed | 1.121 | 11.355 | 1.456% |

## room

Full deterministic plant rack compared with the approved rack target.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\room\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\room\heatmap.png`
- Reference SHA-256: `807e405c5294c90e22fa67cbe42d490243b9391fc95daac198e09138d12cf327`
- Actual SHA-256: `729c14c6efea13be117202ce7b7e75d0e1081263cb8a19f4d9104a63fae88079`

## locked-slots

Level-one locked-slot layout compared with the approved mockup.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\locked-slots\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\locked-slots\heatmap.png`
- Reference SHA-256: `20eda23ede9412d56a156303b9e670caa6032f06e53f1b25287edb7deee9af69`
- Actual SHA-256: `c9611ccbe3dcb04bd8b3de1feefeced14447a08d285936791b1e4b05ec7a5129`

## hud

Approved Phase 4 code-native comic HUD with dynamic values masked.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\hud\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\hud\heatmap.png`
- Reference SHA-256: `cc4a0954d7f0169f5cdd322ec6c6542d28a266e86e217cfafd9067f28c44b1ff`
- Actual SHA-256: `cc4a0954d7f0169f5cdd322ec6c6542d28a266e86e217cfafd9067f28c44b1ff`

## navigation

Approved Phase 4 four-card comic mobile navigation.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\navigation\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\navigation\heatmap.png`
- Reference SHA-256: `d61ccdffe4cb033457cfbfb9731b8d32a7042674b67b1a75017434430fbddad4`
- Actual SHA-256: `d61ccdffe4cb033457cfbfb9731b8d32a7042674b67b1a75017434430fbddad4`

## storage

Approved Phase 5 storage cards and four-step processing flow.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\storage\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\storage\heatmap.png`
- Reference SHA-256: `0b586a48521d75131cf6791a410b496b4470d8fbeed6b83513ff39d824c65a43`
- Actual SHA-256: `0b586a48521d75131cf6791a410b496b4470d8fbeed6b83513ff39d824c65a43`

## shop

Approved Phase 5 mobile shop item cards and purchase controls.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\shop\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\shop\heatmap.png`
- Reference SHA-256: `fbc1f1218e881deeadd91cb2b37254ddeb7339d27fbc52b496b105dfcb127fa6`
- Actual SHA-256: `666c65358d5d5990f0bcea60f06501d9a3347f236f0e0b3c1eb1f785eb6965c8`

## measurement

Approved Phase 5 live metrics, comic graph, and knowledge panel.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\measurement\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\measurement\heatmap.png`
- Reference SHA-256: `ab8a819b9b659553682196996fc0a9857e78d512bfb45980806a2ec224133987`
- Actual SHA-256: `fc6b7ebd9350e9be9f338923e95597072c8c28ebcdaa0c8c78ff06b442652e36`

## detail-realtime

User-approved RC61 plant detail with the current painted scale, saucer and sill grounding; historical references remain preserved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\detail-realtime\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\detail-realtime\heatmap.png`
- Reference SHA-256: `5c7304b3f587933858257fea2a868d40916fc3d90a76af801d0b916a1c5405a0`
- Actual SHA-256: `68da495cf87c1fb322276cda6501b89555174e2eb787a3b58e477195056b37f0`

## guide-explain

User-approved Phase 184 RC59 Professor Bazal explain state over the approved current rack and compact dock; the modal behavior is unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\guide-explain\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\guide-explain\heatmap.png`
- Reference SHA-256: `2027d46b210e4c42d9d250f0041e36bbea039ef30e089312ba208da9c0c52cc8`
- Actual SHA-256: `0635691cd3cd9d85a69ec25ac1cab5bc23d2f8afecb92f205700be0e5be2ddf1`

## guide-celebrate

User-approved Phase 184 RC59 Professor Bazal celebration state over the approved current rack and compact dock; the modal behavior is unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\guide-celebrate\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\guide-celebrate\heatmap.png`
- Reference SHA-256: `69317dfafd6cbe621ecd54a8b30e8a70933d023385468a962280673e98bf092d`
- Actual SHA-256: `e2072acc0823d0bc424341d849769900f5af7d97ea8e29cfafc9b78919348a4c`

## guide-warning

User-approved Phase 184 RC59 Professor Bazal warning state over the approved current rack and compact dock; the modal behavior is unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\guide-warning\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\guide-warning\heatmap.png`
- Reference SHA-256: `9d98bad4856e249690ba7d3d59e06aea6a83c6dc7d381981d11055f67eb44bfe`
- Actual SHA-256: `628463f5ec794963e901166790fa549b9c876fa136e35f8f69bc7125f7a824b8`

## feedback-water

User-approved RC61 watering feedback over the current plant detail; historical references remain preserved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\feedback-water\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\feedback-water\heatmap.png`
- Reference SHA-256: `99b0707e8dcc4657b8532cd1d6d1e29a91471c888252147ae6e78d757a4c6fd3`
- Actual SHA-256: `f4ba0b89e0a0c483379a0801200818acb6ceaa9b4a4f61d51707a5d809852edd`

## feedback-growth

User-approved RC61 growth feedback over the current plant detail; historical references remain preserved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\feedback-growth\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\feedback-growth\heatmap.png`
- Reference SHA-256: `1955e09e044a4ad880c502248392c53fea19fa05e980e73e67450a8e8e619a47`
- Actual SHA-256: `f72e80db03509c3080ecb10e4eccdf7bda7774ea4b000373544b5946673e509b`

## feedback-coins

Approved Phase 7 shared coin reward feedback effect.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\feedback-coins\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\feedback-coins\heatmap.png`
- Reference SHA-256: `a55296069b2753ebb328d8c37316890dd6fe08bfc76eda7dbe3282afba11b7af`
- Actual SHA-256: `a55296069b2753ebb328d8c37316890dd6fe08bfc76eda7dbe3282afba11b7af`

## feedback-unlock

Historical approved rack-slot unlock feedback over the Phase 151 painted rack. Preserved append-only and superseded by the Phase 163 runtime gate.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\feedback-unlock\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\feedback-unlock\heatmap.png`
- Reference SHA-256: `8de514088c0d91d1522be222b7ab86b29171075d1f1bd3c8546f798ee7508a9d`
- Actual SHA-256: `05c4ef46881c4369ce531ca280acfb32d3b35665a3f888c33ca6af2a253be7b0`
- Threshold findings: mean_abs_error=48.426735 > 4.000000; rmse=73.115752 > 12.000000; changed_ratio=0.839482 > 0.060000

## screen-transition

Historical approved directional cyan-gold mobile transition over the Phase 151 painted rack. Preserved append-only and superseded by the Phase 163 runtime gate.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\screen-transition\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\screen-transition\heatmap.png`
- Reference SHA-256: `7c360396115c2180eeb04a129f1191c30508d262b00ab4a2b5096a0cfc430704`
- Actual SHA-256: `070070a0def7beb3592a32a6e9676468cbf49500867b5810e8719543b115b874`
- Threshold findings: mean_abs_error=44.288271 > 4.000000; rmse=67.911171 > 12.000000; changed_ratio=0.809501 > 0.060000

## phase163-feedback-unlock-runtime-approved

User-approved Phase 184 RC59 rack-slot unlock feedback over the current rack and compact dock. The effect is unchanged; the historical Phase 163 reference remains preserved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase163-feedback-unlock-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase163-feedback-unlock-runtime-approved\heatmap.png`
- Reference SHA-256: `104b2977ffa366127ef18e75b5f56bf8253c374bf28741f473f37d4fb892af1b`
- Actual SHA-256: `05c4ef46881c4369ce531ca280acfb32d3b35665a3f888c33ca6af2a253be7b0`

## phase163-screen-transition-runtime-approved

User-approved Phase 184 RC59 cyan-gold screen transition over the current rack and compact dock. The effect is unchanged; the historical Phase 163 reference remains preserved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase163-screen-transition-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase163-screen-transition-runtime-approved\heatmap.png`
- Reference SHA-256: `213e2238af35107b6f903344b469642917a532ae0a9021632ad48dbc56120713`
- Actual SHA-256: `070070a0def7beb3592a32a6e9676468cbf49500867b5810e8719543b115b874`

## phase149-player-room-exact-target

User-designated exact Phase 149 room composition, normalized to the content area between the global HUD and navigation.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase149-player-room-exact-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase149-player-room-exact-target\heatmap.png`
- Reference SHA-256: `3e223d3ee195f2dd8fb685b391714767978b86ec352cabada303eea003f4daa5`
- Actual SHA-256: `b8bc2b43e6e1ce33d1536220a69fc2b639934cc8aff4755d19d1ff30f961c54f`

## phase150-greenhouse-approved-target

User-approved Phase 150 painted greenhouse composition, normalized from its 864x1544 content reference to the live content area. This intentionally remains report-only because the reference bakes one concrete crop state while the live view stays dynamic.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase150-greenhouse-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase150-greenhouse-approved-target\heatmap.png`
- Reference SHA-256: `0a780e8c4a707966ed694c7933a15ee5a61b5ed04e88179687d4f46940de2eb2`
- Actual SHA-256: `e12c96563269007c4d30123dbef817d085cb07392aebfebf10dfc7fdbc45ba5a`

## phase151-rack-approved-target

User-approved Phase 151 painted rack concept. It remains report-only because the concept bakes one level and plant state; the separately approved real runtime render is gated below.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase151-rack-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase151-rack-approved-target\heatmap.png`
- Reference SHA-256: `7540369ad83e2dcb0a707052c649e8c0e919d621086b970985ea891eff02697c`
- Actual SHA-256: `9bf2e2dfaae18c00dd9fac0f53727353840b9604db3e9cb216aef0e441c03757`

## phase151-detail-approved-target

User-approved Phase 151 painted detail concept. It remains report-only while the separately approved real runtime render is gated below.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase151-detail-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase151-detail-approved-target\heatmap.png`
- Reference SHA-256: `599283f38afd50cfc6d121613f9687e15707cdf56ed1de6fe743765727bcafde`
- Actual SHA-256: `68da495cf87c1fb322276cda6501b89555174e2eb787a3b58e477195056b37f0`

## phase152-storage-approved-target

User-approved Phase 152 painted storage concept. It remains report-only because its inventory values are baked; the separately approved real runtime render is gated below.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase152-storage-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase152-storage-approved-target\heatmap.png`
- Reference SHA-256: `d19d7ea1fdc95ae7a69289b555363f0e104fbe029911e46335bdcce567292d28`
- Actual SHA-256: `6c4f4047668fd493e4fbbb0d7b994ec27fd894008f08e5786071d2e80e4188c0`

## phase153-shop-approved-target

User-approved Phase 153 painted botanical shop composition. Report-only until the user reviews the real dynamic Godot render; prices, stock and category state remain dynamic.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase153-shop-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase153-shop-approved-target\heatmap.png`
- Reference SHA-256: `5a69e32d9ba3ee96feb911f653c4f21cb41d972af5f6599da173eb0dea41d972`
- Actual SHA-256: `4081324ef518d2e4c27fcc6256937255d092112df6687e6ae4bc5c89f4b9cf4b`

## phase154-measurement-approved-target

User-approved Phase 154 painted botanical measurement composition. It remains report-only because the separately approved real runtime render is gated below; all ten sensor values, the 72-hour graph, guidance and scrolling remain dynamic.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase154-measurement-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase154-measurement-approved-target\heatmap.png`
- Reference SHA-256: `d690acb3d1bcf174f856e7d72498f976991879e24714f9bb1a68d81b5ab46ffb`
- Actual SHA-256: `1b821ac6b84f1403320460674480a3a8f5c10d79df68b0e0a979809dbd0c0ca4`

## phase155-herbarium-approved-target

User-approved Phase 155 painted herbarium composition. Report-only until the user reviews the actual dynamic Godot render; all eleven species, mastery progress, descriptions, rewards, handover replay and vertical scrolling remain live.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase155-herbarium-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase155-herbarium-approved-target\heatmap.png`
- Reference SHA-256: `9aba0f190f2acfc3c7795616b8e9a6c0e2f3805c10b3f0bdc8fc6a9cfdd4c697`
- Actual SHA-256: `1a4c2610265de56e71a509606861edf9673b540016fd7b524197c1ff9d65d2a5`

## phase161-daily-challenge-approved-target

User-approved Phase 161 painted Daily Challenge composition. Report-only until the user reviews the actual layered Godot render; all fourteen challenge types, weather, target availability, status, rewards and pack count remain dynamic.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase161-daily-challenge-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase161-daily-challenge-approved-target\heatmap.png`
- Reference SHA-256: `7972356773a32026e400c97c27df4f70881723f50b2e74e28a010d696a12533e`
- Actual SHA-256: `30696dba6edbe50afafcd11fbbd827039be1d15b5613eb4220a7ff1074906af2`

## phase162-cosmetic-showroom-approved-target

User-approved Phase 162 painted Cosmetic Showroom composition. Report-only until the user reviews the actual layered Godot render; all four themes, wallet values, purchase and selection states, research lock and scrolling remain live.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase162-cosmetic-showroom-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase162-cosmetic-showroom-approved-target\heatmap.png`
- Reference SHA-256: `bc524f1d2c3111630385256481a4acb04cc51d99c2e4cf342d7fa468c3fc5dc0`
- Actual SHA-256: `b767ddd11d3cfdf6902d2810e9516828e1a2357fca6a7cc292ef4108b6478618`

## phase163-rack-locked-planter-approved-target

User-approved Phase 163 painted rack composition with one shared compact locked-planter master and one shared grow-light master. Report-only until the user reviews the actual dynamic Godot render; all ten slots, levels, plant states, care, lights and interactions remain live.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase163-rack-locked-planter-approved-target\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase163-rack-locked-planter-approved-target\heatmap.png`
- Reference SHA-256: `bd906524ed677fb996098578e3efbed3f19c797ac8078cbc8c7db86aeb1bc349`
- Actual SHA-256: `9bf2e2dfaae18c00dd9fac0f53727353840b9604db3e9cb216aef0e441c03757`

## phase151-rack-runtime-approved

Historical exact dynamic Godot rack render approved after Phase 151. Preserved report-only after the user explicitly approved the superseding Phase 163 locked-planter and grow-light runtime.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase151-rack-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase151-rack-runtime-approved\heatmap.png`
- Reference SHA-256: `d02b55e159c0b90622185bb0a6b45e2d35bb0712d8cf50b9a2dee9edad103d90`
- Actual SHA-256: `9bf2e2dfaae18c00dd9fac0f53727353840b9604db3e9cb216aef0e441c03757`
- Threshold findings: mean_abs_error=51.835806 > 4.000000; rmse=77.913573 > 12.000000; changed_ratio=0.839528 > 0.060000

## phase151-detail-runtime-approved

Exact RC61 dynamic Godot plant detail explicitly approved by the user; the Phase 151 reference remains preserved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase151-detail-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase151-detail-runtime-approved\heatmap.png`
- Reference SHA-256: `5c7304b3f587933858257fea2a868d40916fc3d90a76af801d0b916a1c5405a0`
- Actual SHA-256: `68da495cf87c1fb322276cda6501b89555174e2eb787a3b58e477195056b37f0`

## phase152-storage-runtime-approved

Exact dynamic Godot painted storage render explicitly approved by the user after Phase 152 implementation.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase152-storage-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase152-storage-runtime-approved\heatmap.png`
- Reference SHA-256: `6c4f4047668fd493e4fbbb0d7b994ec27fd894008f08e5786071d2e80e4188c0`
- Actual SHA-256: `6c4f4047668fd493e4fbbb0d7b994ec27fd894008f08e5786071d2e80e4188c0`

## phase153-shop-runtime-approved

Exact dynamic Godot painted shop render explicitly approved by the user after Phase 153 implementation.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase153-shop-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase153-shop-runtime-approved\heatmap.png`
- Reference SHA-256: `624018d76a496c5f8908324f1f1e3f9cfbcb4c71a23022db29f3cff2103d64b7`
- Actual SHA-256: `4081324ef518d2e4c27fcc6256937255d092112df6687e6ae4bc5c89f4b9cf4b`

## phase154-measurement-runtime-approved

Exact dynamic Godot painted Measurement render explicitly approved by the user after Phase 154 implementation.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase154-measurement-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase154-measurement-runtime-approved\heatmap.png`
- Reference SHA-256: `73c7841758773fd827a42d9712dd495014be61fde8853cedcc0052b941660030`
- Actual SHA-256: `1b821ac6b84f1403320460674480a3a8f5c10d79df68b0e0a979809dbd0c0ca4`

## phase155-herbarium-runtime-approved

Exact dynamic Godot painted Herbarium render explicitly approved by the user for RC61.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase155-herbarium-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase155-herbarium-runtime-approved\heatmap.png`
- Reference SHA-256: `1a4c2610265de56e71a509606861edf9673b540016fd7b524197c1ff9d65d2a5`
- Actual SHA-256: `1a4c2610265de56e71a509606861edf9673b540016fd7b524197c1ff9d65d2a5`

## phase160-player-room-clean-floor-runtime-approved

Historical Exact dynamic Godot painted Player Room clean-floor render explicitly approved by the user after Phase 160 implementation. Preserved report-only after the user approved the Phase 167 repaired room rack; superseded by phase167-player-room-clean-floor-runtime-approved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase160-player-room-clean-floor-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase160-player-room-clean-floor-runtime-approved\heatmap.png`
- Reference SHA-256: `a0a7d7d1a4120320fc0084af65429e9f997ac9cad29e51decf20278869363bd2`
- Actual SHA-256: `0ce47951a313a7cbeaa12ec9b013c4a0c082aee3cc2623cad210dee0c04b24a1`
- Threshold findings: mean_abs_error=65.054161 > 4.000000; rmse=89.036430 > 12.000000; changed_ratio=0.977018 > 0.060000

## phase162-cosmetic-showroom-runtime-approved

Exact dynamic Godot painted Cosmetic Showroom selected-state render explicitly approved by the user after Phase 162 implementation.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase162-cosmetic-showroom-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase162-cosmetic-showroom-runtime-approved\heatmap.png`
- Reference SHA-256: `410dbea6fad1337ebb657bda2f0a0f7fa466e80b42ce5bec228a67cfca562dc7`
- Actual SHA-256: `b767ddd11d3cfdf6902d2810e9516828e1a2357fca6a7cc292ef4108b6478618`
- Threshold findings: mean_abs_error=14.091654 > 4.000000; rmse=35.357709 > 12.000000; changed_ratio=0.269796 > 0.060000

## phase158-player-room-empty-runtime-approved

Exact empty 0/20 Player Room Godot render explicitly approved by the user after the Phase 158 compositing repair.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase158-player-room-empty-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase158-player-room-empty-runtime-approved\heatmap.png`
- Reference SHA-256: `cd94031182f3c48f2da44e8dc571f0a90259ddb60c66498b7fb57f94b4a723b4`
- Actual SHA-256: `bfeec0d2d3dc819f34f9fc0c8dce8e4a9f5ebe290ec868fbf1bbdb6b569a0e6c`

## phase158-player-room-sparse-runtime-approved

Historical Exact sparse 4/20 Player Room Godot render explicitly approved by the user after the Phase 158 compositing repair. Preserved report-only after the user approved the Phase 167 repaired room rack; superseded by phase167-player-room-sparse-runtime-approved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase158-player-room-sparse-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase158-player-room-sparse-runtime-approved\heatmap.png`
- Reference SHA-256: `d5ad610b315cc4baa2f5adf8539eace3e3bd4b6553582768dbd362b89428da27`
- Actual SHA-256: `5802a9b75671cb71f2b5aa2fc5e9090ff92ab7e12e3e1adc8c122d9f4e656ac8`
- Threshold findings: mean_abs_error=64.015967 > 4.000000; rmse=87.955648 > 12.000000; changed_ratio=0.974696 > 0.060000

## phase158-player-room-phone-save-runtime-approved

Historical Exact sanitized phone-save 10/20 Player Room Godot render explicitly approved by the user after the Phase 158 compositing repair. Preserved report-only after the user approved the Phase 167 repaired room rack; superseded by phase167-player-room-phone-save-runtime-approved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase158-player-room-phone-save-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase158-player-room-phone-save-runtime-approved\heatmap.png`
- Reference SHA-256: `cf100a3653df0f30ee0f6728db58001ffc91e797e321a6abbc5fac0112dba93b`
- Actual SHA-256: `71d4ef19ed3ac658c18dd431932d0b63d54fe4f860753d5026c66d301cc96dbb`
- Threshold findings: mean_abs_error=63.902024 > 4.000000; rmse=88.058278 > 12.000000; changed_ratio=0.974672 > 0.060000

## phase158-player-room-full-runtime-approved

Historical Exact full 20/20 Player Room Godot render with the enlarged Phase 159 cloche explicitly approved by the user. Preserved report-only after the user approved the Phase 167 repaired room rack; superseded by phase167-player-room-full-runtime-approved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase158-player-room-full-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase158-player-room-full-runtime-approved\heatmap.png`
- Reference SHA-256: `42804f92f7dc9b278511364e091498f9585458abb2da367d1eb6bec9feaa1f87`
- Actual SHA-256: `975c652320593e1f709285ed0c21fb5c61211963e8f5f53b0f3bee51fc80bfa4`
- Threshold findings: mean_abs_error=65.112935 > 4.000000; rmse=89.075232 > 12.000000; changed_ratio=0.977247 > 0.060000

## phase159-player-room-cloche-runtime-approved

Exact Player Room Godot render containing only the Phase 159 botanical cloche at the user-approved 115 percent scale.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase159-player-room-cloche-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase159-player-room-cloche-runtime-approved\heatmap.png`
- Reference SHA-256: `efe3b6f6e9880612b8ffe6eef1476d10f6a22f849fed31165c4af0e04e554725`
- Actual SHA-256: `56eebb5765f24fa6280c05328bbe2b6a32a444a8837b001cac99f0cec677daee`

## phase159-player-room-full-cloche-runtime-approved

Historical Exact full Player Room Godot render with the Phase 159 botanical cloche at the user-approved 115 percent scale. Preserved report-only after the user approved the Phase 167 repaired room rack; superseded by phase167-player-room-full-cloche-runtime-approved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase159-player-room-full-cloche-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase159-player-room-full-cloche-runtime-approved\heatmap.png`
- Reference SHA-256: `42804f92f7dc9b278511364e091498f9585458abb2da367d1eb6bec9feaa1f87`
- Actual SHA-256: `f2aa5bd8a8c139cfc7ed5df305f1e423d28f91209669d94619b2d0885940ddd4`
- Threshold findings: mean_abs_error=65.113137 > 4.000000; rmse=89.076016 > 12.000000; changed_ratio=0.977259 > 0.060000

## phase161-daily-challenge-active-runtime-approved

Exact active Daily Challenge Godot render explicitly approved by the user for RC61.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase161-daily-challenge-active-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase161-daily-challenge-active-runtime-approved\heatmap.png`
- Reference SHA-256: `30696dba6edbe50afafcd11fbbd827039be1d15b5613eb4220a7ff1074906af2`
- Actual SHA-256: `30696dba6edbe50afafcd11fbbd827039be1d15b5613eb4220a7ff1074906af2`

## phase161-daily-challenge-completed-runtime-approved

Exact completed Daily Challenge Godot render explicitly approved by the user for RC61.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase161-daily-challenge-completed-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase161-daily-challenge-completed-runtime-approved\heatmap.png`
- Reference SHA-256: `b7f5d4a9373c076b9e16fbbe669bacc9779bacfbc9b4f9a4ec88f92da0146aba`
- Actual SHA-256: `b7f5d4a9373c076b9e16fbbe669bacc9779bacfbc9b4f9a4ec88f92da0146aba`

## phase161-daily-challenge-ready-queue-full-runtime-approved

Exact ready Daily Challenge with a full botanical-pack queue explicitly approved by the user for RC61.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase161-daily-challenge-ready-queue-full-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase161-daily-challenge-ready-queue-full-runtime-approved\heatmap.png`
- Reference SHA-256: `211247ec03ac49bd5719dd9461054951902caca37849c436508dd1a073c6fa6b`
- Actual SHA-256: `211247ec03ac49bd5719dd9461054951902caca37849c436508dd1a073c6fa6b`

## phase161-daily-challenge-claimed-runtime-approved

Exact claimed Daily Challenge Godot render explicitly approved by the user for RC61.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase161-daily-challenge-claimed-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase161-daily-challenge-claimed-runtime-approved\heatmap.png`
- Reference SHA-256: `f19994e9ee885bc9b09c7a1d1c8e6462cdf4480d501265f63b02e0aed51bab21`
- Actual SHA-256: `f19994e9ee885bc9b09c7a1d1c8e6462cdf4480d501265f63b02e0aed51bab21`

## phase161-daily-challenge-unavailable-runtime-approved

Exact unavailable-target Daily Challenge Godot render explicitly approved by the user for RC61.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase161-daily-challenge-unavailable-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase161-daily-challenge-unavailable-runtime-approved\heatmap.png`
- Reference SHA-256: `bae3cd4ffcfcea595265bc7a8b6b0a7b47182868caff426d3c69d3379bb79180`
- Actual SHA-256: `bae3cd4ffcfcea595265bc7a8b6b0a7b47182868caff426d3c69d3379bb79180`

## phase163-rack-runtime-approved

Exact Phase 184 RC59 dynamic Godot rack explicitly approved by the user with the later Phase 171 grounding and Phase 183 compact dock; the Phase 163 reference remains preserved.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase163-rack-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase163-rack-runtime-approved\heatmap.png`
- Reference SHA-256: `9bf2e2dfaae18c00dd9fac0f53727353840b9604db3e9cb216aef0e441c03757`
- Actual SHA-256: `9bf2e2dfaae18c00dd9fac0f53727353840b9604db3e9cb216aef0e441c03757`

## phase167-player-room-clean-floor-runtime-approved

User-approved Phase 167 repaired room rack artwork in the inherited clean-floor fixture. The approved room render is recorded separately; fixture state, crop, masks and thresholds are unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase167-player-room-clean-floor-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase167-player-room-clean-floor-runtime-approved\heatmap.png`
- Reference SHA-256: `63dac160e77aed823118c92d19a9f39a9672e971174ee2bc5ab48695ad204290`
- Actual SHA-256: `0ce47951a313a7cbeaa12ec9b013c4a0c082aee3cc2623cad210dee0c04b24a1`

## phase167-player-room-sparse-runtime-approved

User-approved Phase 167 repaired room rack artwork in the inherited sparse fixture. The approved room render is recorded separately; fixture state, crop, masks and thresholds are unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase167-player-room-sparse-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase167-player-room-sparse-runtime-approved\heatmap.png`
- Reference SHA-256: `19ab2173d2a1d8a9ba3c9e7b5bf848650c9d0902ef50eed6804fa3a623722aac`
- Actual SHA-256: `5802a9b75671cb71f2b5aa2fc5e9090ff92ab7e12e3e1adc8c122d9f4e656ac8`

## phase167-player-room-phone-save-runtime-approved

User-approved Phase 167 repaired room rack artwork in the inherited phone-save fixture. The approved room render is recorded separately; fixture state, crop, masks and thresholds are unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase167-player-room-phone-save-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase167-player-room-phone-save-runtime-approved\heatmap.png`
- Reference SHA-256: `55ac1daeea306c1f1ae0042388506c42046dfccbe772dda4617a48628b14975e`
- Actual SHA-256: `71d4ef19ed3ac658c18dd431932d0b63d54fe4f860753d5026c66d301cc96dbb`

## phase167-player-room-full-runtime-approved

User-approved Phase 167 repaired room rack artwork in the inherited full fixture. The approved room render is recorded separately; fixture state, crop, masks and thresholds are unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase167-player-room-full-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase167-player-room-full-runtime-approved\heatmap.png`
- Reference SHA-256: `92f986c9a12d8c956b4fb6643cec0ed4a101644cd2e420392fb0d17fb4c916ed`
- Actual SHA-256: `975c652320593e1f709285ed0c21fb5c61211963e8f5f53b0f3bee51fc80bfa4`

## phase167-player-room-full-cloche-runtime-approved

User-approved Phase 167 repaired room rack artwork in the inherited full-cloche fixture. The approved room render is recorded separately; fixture state, crop, masks and thresholds are unchanged.

- Comparison: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase167-player-room-full-cloche-runtime-approved\comparison.png`
- Heatmap: `R:\_projekty\Bazal's Pocket Garden\.godot\validation\20261023-155438Z\phase167-player-room-full-cloche-runtime-approved\heatmap.png`
- Reference SHA-256: `107136155f2ccd6cc15c1c4d6c306d6aa07d8aa5013f48169ff1b078c779f953`
- Actual SHA-256: `f2aa5bd8a8c139cfc7ed5df305f1e423d28f91209669d94619b2d0885940ddd4`
