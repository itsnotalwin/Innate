# Afternoon atmosphere — first pass

Goal: bring some shader-inspired warmth and depth to the existing pixel-art world without changing camera zoom or adding expensive real-time lights.

- One static, low-opacity canvas shader adds broad warm light bands and a subtle cool edge tint. The interface stays above this pass.
- World-space layered canopy shadows sit above the ground and below Y-sorted scenery. They are built once, with no per-frame script or particles.
- Destination approaches use seeded roadside planting pockets earlier along the route. Existing road and object clearance rules remain intact.
- This is not 3D lighting, bloom, water reflection or volumetric lighting. Those require separate, visually reviewed work and phone performance testing.

Next: replace stretches of undifferentiated grass with authored trail-side clearings, little rock/flower compositions and occasional landmarks. Evaluate stronger lighting and local water highlights separately; preserve the original palette and readable walking routes.

Verification: 41 gameplay checks passed; all 1176 road cells connected, with no water crossings or unexpected solid scenery on roads. Real-device performance still needs testing.
