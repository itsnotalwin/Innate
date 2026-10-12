# INNATE starting map: research and production audit

**Reviewed:** 12 October 2026  
**Scope:** the 154 × 104 tile outdoor starting map, its walking routes, landmarks, and opening view. This is a map and exploration pass; it does not add quests, dialogue, gathering, or other game systems.

## Research summary

The useful comparison is not a raw count of trees or props. Strong top-down maps organize movement around a readable route spine, recognizable places, and small discoveries that give each walk a reason to continue. Open grass still matters: it creates visual rest and lets major compositions read. The goal is to shape that open space, not carpet it.

| Reference | What it does well | What INNATE should take from it |
| --- | --- | --- |
| **Stardew Valley — Pelican Town** | A similarly broad top-down town is built from distinct everyday destinations, with paths connecting the farm, forest, beach, and mountain. The creator’s own update says he expanded the town by nearly 400% to give buildings room and add touches that made it feel more alive. | Keep INNATE’s roomy 154 × 104 canvas, but make routes and small scenes feel authored. A large footprint only earns its size when places have distinct identities and the walks connect them. Stardew’s quests, residents, forage, and secrets are gameplay systems; this project currently has visual destinations only. [ConcernedApe’s map update](https://www.stardewvalley.net/dev-update-18/), [Pelican Town locations](https://wiki.stardewvalley.net/Pelican_Town) |
| **Animal Crossing — town and island spaces** | Nintendo’s developers describe the world as a place shaped by repeated player routines; earlier town design even let paths wear into the grass where players walked most. New Horizons later gives players direct control over terrain and paths. | Let the routes feel like they belong to the landscape. Distinguish a maintained cottage lane, a meadow track, and a waterside trail through edges and set dressing, while keeping all three equally walkable. INNATE is authored rather than player-terraformable, so it needs that variation up front. [Iwata Asks: Animal Crossing: City Folk](https://iwataasks.nintendo.com/interviews/wii/accf/0/1/), [Nintendo’s New Horizons overview](https://www.nintendo.com/en-gb/News/2019/June/See-what-the-island-life-has-in-store-for-you-in-Animal-Crossing-New-Horizons--1588039.html) |
| **Eastward — pixel-art adventure spaces** | It is a useful art-direction comparison for dense, memorable pixel compositions and local points of interest. Its screenshots show how small props and distinct foreground clusters make a short walk feel like a place. It is a different game, camera, and genre, so its density is not a target for INNATE. | Concentrate detail into small roadside scenes and destination thresholds. Avoid uniformly increasing every sprite; INNATE’s cottage, meadow, pond, orchard, mushroom grove, and creek need their own silhouettes and breathing room. [Eastward visual reference](https://www.play-asia.com/eastward-english/13/70etll) |
| **Blasphemous — world-flow iteration** | The level designer describes starting with a readable early route, introducing branches later, then revising a branch after players chose a harder route by mistake. The studio also used shortcuts to remove repetitive detours. | Make the first few minutes legible before asking players to remember several routes. Keep our direct cottage shortcuts, but dress them so they read as intentional scenic lanes and record them in the layout source. [Level designer interview](https://www.gamedeveloper.com/design/how-i-blasphemous-i-level-design-iterates-on-classic-metroidvanias) |
| **Nintendo level-design guidance** | Nintendo’s Mario and Kirby developers describe designing for first-time players, teaching through the environment, and using visible landmarks and a guided camera to make direction understandable. | The cottage should frame the opening, the first fork should be easy to read, and the wayfinder should sit where the player naturally reaches a choice. Keep the camera zoom unchanged; improve the spawn framing and path-side visual cues instead. [Iwata Asks: New Super Mario Bros.](https://iwataasks.nintendo.com/interviews/wii/nsmb/1/4/), [Kirby developer interview](https://www.nintendo.com/en-gb/News/2022/March/Ask-the-Developer-Vol-4-Kirby-and-the-Forgotten-Land-2187039.html) |
| **GDC level-design practice** | GDC speakers discuss landmarks, looping paths, visual breadcrumbs, and the way art can communicate where to go. They also point out that a path or landmark can still fail for some players, so observation matters. | Test whether a first-time player notices the cottage, recognizes the fork, and can return to the hub. Treat the walkthrough as evidence; do not assume a connected route graph alone proves intuitive navigation. [GDC level-design roundtable](https://www.gamedeveloper.com/design/gdc-2018-level-design-workshop-an-expert-roundtable-q-a), [GDC environmental storytelling](https://www.gdcvault.com/play/1012647) |

## INNATE versus the references

### What is already strong

- The map aspect ratio is **1.48:1**, close to the supplied **1.50:1** reference image.
- A cottage hub, readable loop, five distinct destinations, a river running the map’s east side, two crossings, and a central green give the map a sound structure.
- The whole painted path network is connected. The traversal audit finds every free cell reachable and all six destination probes reachable.
- The walk from the actual player spawn to each destination is now measured rather than estimated from the hub: cottage **1.5 s**, meadow **11.5 s**, mushroom grove **12.8 s**, orchard **10.2 s**, pond **8.8 s**, creek **18.6 s**. These use the 72 px/s movement speed and a tile-path distance estimate; they are not a substitute for a first-time-player study.
- There are **307 seeded lawn discoveries** plus authored destination and roadside scenes. The lawn pass keeps a minimum gap between props, preserves road margins, and leaves broad grass openings.

### What still separates it from a finished starting map

- The destinations are visually distinct, but most currently have no interaction or activity. They are scenic stops, not yet gameplay destinations. That is a content-scope gap, not something foliage alone can solve.
- The map had two cottage shortcuts in code but not in the layout data or route drawing. Their paths also had much less destination-specific roadside scenery than the original area spurs.
- On a wide first view, the cottage roof sat partly above the top edge. The default camera centered directly on the player and clipped the cottage roof in the first view.
- Current measurements prove route connectivity, collision clearance, and rendering in Chromium; they do **not** establish that new players understand the layout, nor do they measure real-phone frame rate.
- INNATE is somewhat larger than Pelican Town by tile count (16,016 vs. 13,200), while having fewer structures and systemic points of interest. Keep its empty grass where it creates a deliberate vista; spend additional content effort on the routes and thresholds that lead to the five named scenes.

## Changes in this pass

1. Placed the spawn on the east approach to the cottage and shifted the camera target north-west so the full cottage frames the opening view at the unchanged default zoom.
2. Moved both shortcut polylines into `tools/world_layout.json`, the source of truth for authored paths.
3. Applied the area’s foliage gradient to the mushroom and orchard shortcuts so their scenery progresses toward each destination instead of stopping at the old path branches.
4. Changed the route audit to start from the actual player spawn and report shortcut dressing as well as destination reachability.
5. Updated the map route-plan drawing to show the current route network, destinations, player start, and measured walks.

## Production sign-off checklist

- [x] All destinations connect to the spawn.
- [x] No disconnected or water-covered path cells.
- [x] No solid scenery blocking the painted lanes.
- [x] The two shortcuts have their own graduated scenery.
- [x] Cottage, paths, and landmarks use one art direction and retain open sightlines.
- [ ] Watch a new player explore without coaching: confirm they find the first fork, understand the wayfinder, and can return to the cottage.
- [ ] Test on the intended iPhone/Android devices; browser touch emulation and software WebGL are not device performance measurements.
- [ ] When this becomes a full game rather than a visual exploration prototype, give each destination a reason to visit and a small payoff.

## Sources

- [GDC: Level Design Workshop, expert roundtable](https://www.gamedeveloper.com/design/gdc-2018-level-design-workshop-an-expert-roundtable-q-a)
- [GDC: What Happened Here? Environmental Storytelling](https://www.gdcvault.com/play/1012647)
- [Game Developer: Level Design — Understanding a Level](https://www.gamedeveloper.com/design/level-design-understanding-a-level)
- [Game Developer: Blasphemous world-flow iteration](https://www.gamedeveloper.com/design/how-i-blasphemous-i-level-design-iterates-on-classic-metroidvanias)
- [ConcernedApe: Stardew Valley Dev Update #18](https://www.stardewvalley.net/dev-update-18/)
- [Stardew Valley Wiki: Pelican Town](https://wiki.stardewvalley.net/Pelican_Town)
- [Nintendo: Iwata Asks — New Super Mario Bros.](https://iwataasks.nintendo.com/interviews/wii/nsmb/1/4/)
- [Nintendo: Ask the Developer — Kirby and the Forgotten Land](https://www.nintendo.com/en-gb/News/2022/March/Ask-the-Developer-Vol-4-Kirby-and-the-Forgotten-Land-2187039.html)
- [Nintendo: Animal Crossing: New Horizons developer introduction](https://www.nintendo.com/en-gb/News/2019/June/See-what-the-island-life-has-in-store-for-you-in-Animal-Crossing-New-Horizons--1588039.html)
