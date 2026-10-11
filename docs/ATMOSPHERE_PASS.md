# Afternoon atmosphere — first pass

Goal: bring some shader-inspired warmth and depth to the existing pixel-art world without changing camera zoom or adding expensive real-time lights.

- One static, low-opacity canvas shader adds broad warm light bands and a subtle cool edge tint. The interface stays above this pass.
- World-space layered canopy shadows sit above the ground and below Y-sorted scenery. They are built once, with no per-frame script or particles.
- Destination approaches use seeded roadside planting pockets earlier along the route. Existing road and object clearance rules remain intact.
- This is not 3D lighting, bloom, water reflection or volumetric lighting. Those require separate, visually reviewed work and phone performance testing.

Next: replace stretches of undifferentiated grass with authored trail-side clearings, little rock/flower compositions and occasional landmarks. Evaluate stronger lighting and local water highlights separately; preserve the original palette and readable walking routes.

Verification: 41 gameplay checks passed; all 1176 road cells connected, with no water crossings or unexpected solid scenery on roads. Real-device performance still needs testing.

## Water and lighting follow-up

Reference reviewed: [Complementary Shaders official gallery](https://www.complementary.dev/shaders/), including its Unbound/Reimagined comparison, warm sunset, water and underwater examples. Reimagined is the closer conceptual fit: preserve the source game's visual identity while improving lighting. No reference assets or shader code were copied.

The new pass replaces the tint overlay with actual screen-color processing: modest contrast, cooler dark tones, warmer highlights, and four neighboring samples for restrained bright-pixel glow. This is an inexpensive bloom approximation, not physical illumination. Stronger world-space canopy shadows remain anchored to trees.

Water has its own material, with world-aligned pixel highlights, broad sky-colored tonal variation and low-amplitude animated ripples. Both open water and shoreline underlay share the shader. It does not reflect actual scenery or distort the sprites, paths or UI.

Six trail-side compositions combine matching flowers with existing rock, log or mushroom assets. Decorations avoid the road and its adjacent cells; larger props also respect existing-object clearance. These are visual discoveries, not new interaction systems.

The countdown renders after the screen effect and remains unchanged. Camera zoom is unchanged. Browser idle comparisons tolerate small ripple-color changes while still checking for player/camera motion. A real phone check remains necessary before claiming mobile performance.

Final verification: 41/41 gameplay and 18/18 browser checks passed; all 1176 path cells remain connected. Portrait reviews are saved as `tests/evidence/lighting-pond.png`, `lighting-creek.png` and `lighting-roadside.png`. The temporary review-position callback exists only in an untracked local review export, not the published game.

Performance limitation: an isolated software-WebGL sample measured approximately 70 ms mean frame time in both portrait and desktop, with p95 83/100 ms. That is slower than earlier recorded samples; those were not a same-session paired comparison. Do not describe this pass as verified smooth on mobile. Test on the target phone and consider reducing or disabling neighboring-sample glow if the stronger effect causes noticeable lag.
