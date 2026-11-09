# TRAIL WARS — REA-ASSISTED GAMEPLAY RECONSTRUCTION & ROBLOX IMPLEMENTATION

## YOUR MISSION

You are the Lead Reverse-Engineering Researcher, Gameplay Programmer, Roblox Luau Engineer, and Multiplayer Networking Specialist for TRAIL WARS.

We have completed substantial UI development.

**It is now time to implement the actual game.**

Our gameplay reference is **Curve Fever Pro**, which is already installed through Steam on this computer.

I have already installed and configured **Reverse Engineer Anything (REA)** for Codex.

I want you to actively use REA, inspect the installed application files, study documented gameplay videos, investigate the game's relevant runtime behavior, and determine precisely how its core gameplay operates.

Then independently implement equivalent movement, steering, trail, collision, and round mechanics in Roblox Luau.

Do not simply describe how the mechanics could work.

**Build, test, measure, and refine a genuinely playable Roblox implementation.**

Do not extract or redistribute the commercial game's proprietary source or assets. Recover algorithmic behavior through analysis and implement our own code. Do not bypass DRM, anti-cheat, authentication, or other access restrictions.

---

## 1. PROJECT CHECKPOINT

GitHub repository:

https://github.com/nauel3d/trailwars

Gameplay development issue:

https://github.com/nauel3d/trailwars/issues/3

Previously verified UI checkpoint:

`deefc31`

Inspect the current repository and actual HEAD before making changes.

The project already includes:

- Responsive SNAP ARCADE UI prototypes.
- Animated Home demonstration.
- Cosmetic customization and shop demonstrations.
- Animated standings.
- Results animations.
- Modular native Luau components.
- Rojo.
- UI Labs stories.
- Inventory and profile foundations.
- Economy and reward infrastructure.
- Existing deterministic tests.

Preserve everything.

Develop gameplay on a separate Git branch.

Do not rewrite the interface, change the visual direction, enable real purchases, or publish anything.

---

## 2. VERIFY AND USE REA

REA is already installed. Do not reinstall it unnecessarily.

First:

1. Discover the available REA tools and skills.
2. Read the locally installed REA documentation.
3. Review the official REA native-analysis guides and any documented tutorial videos relevant to executable inspection.
4. Verify the native-analysis provider actually available, such as Ghidra, Hopper, or IDA.
5. Determine whether the available REA configuration supports static binary inspection, file/resource inspection, runtime observation, and process attachment.
6. Use only capabilities you actually verify.

Do not invent tool names or claim that REA can perform unsupported operations.

If a particular analysis provider is unavailable, use available alternatives instead of repeatedly attempting a broken setup.

### Find the installed game

Steam App ID: `1133700`

Find the actual installation through Steam's library configuration or installed-game manifest.

Do not assume that Steam is installed on the C: drive.

Identify:

- Installation directory.
- Main executable.
- Relevant DLLs and libraries.
- Game data and resource containers.
- Configuration files.
- Framework or engine used.
- Application version.
- Available debug or diagnostic information.

Create a local inventory of files and formats.

Keep the original installation unchanged.

Do not upload commercial binaries or extracted proprietary resources to GitHub.

---

## 3. DOCUMENTED VIDEO RESEARCH — MANDATORY

Before implementing gameplay, study documented videos showing Curve Fever Pro.

Prioritize:

1. Existing local gameplay recordings.
2. Official gameplay demonstrations.
3. Steam store gameplay videos.
4. Developer tutorials or demonstrations.
5. Credible gameplay footage showing normal matches.
6. Relevant REA tutorial videos for using its analysis workflow.

Record the URL or local path, video title, duration, relevant timestamps, and what each clip demonstrates.

Use frame-by-frame analysis where practical.

Investigate:

- How movement begins.
- Movement speed.
- Turning behavior.
- Steering while holding a key.
- Steering when tapping a key.
- How quickly the core responds.
- Trail shape and width.
- Whether trails begin immediately.
- How sharp turns are handled.
- Self-collision behavior.
- Opponent collision behavior.
- Wall collisions.
- Elimination sequences.
- Countdown.
- Respawning between rounds.
- Camera movement.
- Visual smoothing.
- Round endings.

If footage is insufficient to measure a parameter reliably, mark it unknown instead of guessing.

For quantitative measurements, specify timestamps, frame intervals, units, and uncertainty.

---

## 4. STATIC GAME-FILE INVESTIGATION

Use REA to investigate the relevant installed files.

Start with a broad, read-only overview to determine how the application is structured.

Then narrow the analysis to functions and data involved in actual gameplay.

Investigate, where accessible:

- Movement update functions.
- Position and heading calculations.
- Rotation or angular-velocity calculations.
- Input processing.
- Movement timestep handling.
- Trail data generation.
- Trail storage.
- Trail collision calculations.
- Core collision geometry.
- Boundary detection.
- Elimination rules.
- Match state transitions.
- Spawn and restart behavior.
- Relevant networking boundaries.

For native binaries, use REA's supported function discovery, references, call relationships, disassembly or decompilation capabilities where available.

Trace relevant functions and constants instead of blindly dumping the entire application.

For JavaScript or managed components, use REA's appropriate static-analysis capabilities if the installed game actually contains them.

Identify the probable algorithms and their dependencies.

**Do not assume that finding a constant or function name proves actual runtime behavior.**

Every finding should include:

- Relevant file and location.
- Function or data identifier, where available.
- What the evidence establishes.
- What remains uncertain.
- Confidence level.
- How the behavior can be verified experimentally.

Avoid copying protected implementation text into our Roblox source or public documentation. Produce original algorithms derived from the findings.

---

## 5. RUNTIME INVESTIGATION

Use offline or practice/bot mode where available.

Perform controlled experiments.

Examples:

- Hold left steering for a known duration.
- Hold right steering for a known duration.
- Release both controls.
- Alternate brief steering inputs.
- Attempt a full circle.
- Drive through an existing trail.
- Approach arena boundaries at different angles.
- Test narrow gaps.
- Observe simultaneous collisions.

Compare the resulting footage with static-analysis findings.

When permitted and technically supported, use REA's runtime observation tools to investigate relevant process behavior.

Do not instrument protected live multiplayer or evade the game's security protections.

Avoid repeated broad computer-use sessions.

Stop investigating once the essential parameters are sufficiently understood to build and test a tunable prototype.

---

## 6. CREATE AN EVIDENCE-BASED GAMEPLAY SPECIFICATION

Before coding the gameplay engine, produce:

`research/gameplay-reconstruction/`

Include:

- `video-evidence.md`
- `steam-file-inventory.md`
- `rea-investigation.md`
- `movement-analysis.md`
- `collision-analysis.md`
- `trail-analysis.md`
- `round-rules.md`
- `measurements.csv`
- `unknowns.md`

For every important gameplay parameter, distinguish:

**Measured:** directly supported by observations.

**Recovered:** supported by static analysis or runtime tracing.

**Estimated:** an approximation requiring testing.

**Custom:** a deliberate Trail Wars design decision.

Do not represent estimates as verified values.

The output should describe the behavior well enough to implement and test it independently.

---

## 7. IMPLEMENT THE ROBLOX GAMEPLAY ENGINE

Build original Luau modules covering:

### Movement

- Continuous automatic forward movement.
- Left/right steering.
- Configurable turning speed.
- Smooth heading changes.
- Deterministic fixed-timestep simulation.
- Input press/release behavior.
- Consistent movement across frame rates.

### Trails

- Continuous visible trails.
- Accurate trail geometry.
- Configurable width.
- Efficient segment storage.
- Clean rendering around curves.
- Reliable trail intersections.
- Correct handling of the newest trail segment.

### Collision

- Core-to-trail collision.
- Core-to-wall collision.
- Self-collision.
- Opponent collision.
- High-speed crossing protection.
- Fair simultaneous eliminations.
- Consistent collision results independent of graphics frame rate.

Use mathematical geometry and efficient broad-phase collision queries.

Avoid relying on thousands of physical Parts or `Touched` events.

### Rounds

- Match waiting state.
- Spawn placement.
- Countdown.
- Active round.
- Eliminations.
- Spectating.
- Winner detection.
- Results.
- Rematch.
- Restart.

### Controls

- Keyboard.
- Mobile touch.
- Controller.

Steering must feel immediate and predictable.

Focus particularly on mobile controls.

---

## 8. BUILD A PLAYABLE PROTOTYPE FIRST

Do not jump immediately into complicated matchmaking.

First implement:

**One human player versus several deterministic bots.**

The prototype must demonstrate:

- Actual movement.
- Steering.
- Growing trails.
- Collisions.
- Eliminations.
- Bot behavior.
- Round completion.
- Restart.

Use our existing UI where appropriate.

The Home menu's decorative simulation must remain separate from real gameplay.

Make a recording of the actual Roblox prototype.

Compare movement characteristics against the observed reference gameplay.

Adjust the configurable parameters until the controls and collision behavior meet the documented targets.

Do not claim parity without meaningful comparison tests.

---

## 9. IMPLEMENT MULTIPLAYER

After the local gameplay prototype is genuinely working, implement real multiplayer.

Start with 2–6 players.

Prioritize server authority and responsive local controls.

The server must control:

- True positions.
- Collision outcomes.
- Eliminations.
- Round states.
- Winners.
- Rewards.

Clients should send steering inputs, not authoritative positions or results.

Investigate Roblox's current server-authority and prediction APIs before selecting the networking implementation.

Use prediction/interpolation where appropriate.

Test latency, input loss, disconnects, simultaneous eliminations, and state reconciliation.

Do not trust client-reported victories.

---

## 10. INTEGRATE EXISTING SYSTEMS

Preserve the current SNAP ARCADE visual identity.

Connect real gameplay events to:

- Play.
- Queue.
- Countdown.
- Gameplay HUD.
- Animated standings.
- Elimination.
- Spectator.
- Victory.
- Defeat.
- Results.
- Rematch.
- Player statistics.
- Cosmetic selection.

Rewards must be granted only through verified server results, using the existing authoritative reward and persistence systems.

Do not activate production purchases.

Do not allow gameplay results to be fabricated by client requests.

---

## 11. PERFORMANCE AND TESTING

Run deterministic simulation and geometry tests.

Cover:

- Straight movement.
- Turning radius.
- Self-collision.
- Crossed trails.
- Grazing collisions.
- Head-on contact.
- Simultaneous eliminations.
- Frame-rate independence.
- Large frame delays.
- Multiple players.
- Bot stress tests.
- Invalid remote inputs.
- Network latency.
- Player disconnects.

Profile:

- Simulation CPU time.
- Collision-query cost.
- Rendering time.
- Instance count.
- Trail memory.
- Network bandwidth.
- Mobile performance.

Use representative low-end-device settings where practical.

Actual device tests must be distinguished from Studio emulation.

---

## 12. CREDIT-SAVING WORKFLOW

Use this priority order:

1. Existing reference research.
2. Documented gameplay videos.
3. Local Steam files.
4. Focused REA static investigation.
5. Limited offline runtime verification.
6. Luau source implementation.
7. CLI automated tests.
8. Batched Studio tests.

Avoid repeating the full reference-game UI audit.

Do not spend large amounts of credits investigating cosmetic, social, or monetization features unrelated to gameplay.

Do not repeatedly instrument the process just because REA is available.

Investigate a specific question, record the answer, then move forward.

When an approach fails repeatedly, investigate a better alternative.

Do not force unsuitable implementations.

---

## 13. IMPLEMENTATION MILESTONES

### Milestone A — REA and video investigation

Deliver an evidence-backed explanation of the gameplay mechanics and their approximate or recovered parameters.

### Milestone B — Original Luau simulation

Implement real movement, steering, trails, and collision detection with automated tests.

### Milestone C — Playable local prototype

A real player controls a core against bots in Roblox Studio.

### Milestone D — Multiplayer

Server-authoritative rounds with responsive controls and reliable synchronization.

### Milestone E — UI integration

Connect real match states and results to the existing interface.

### Milestone F — Optimization

Test performance, reliability, mobile responsiveness, and networking.

Commit completed milestones on a dedicated gameplay branch.

Do not force-push or merge without approval.

---

# IMMEDIATE EXECUTION

Begin now.

1. Inspect the current project and latest GitHub history.
2. Verify REA and read its relevant documentation and tutorial material.
3. Locate the Steam installation.
4. Inspect relevant game files.
5. Study documented gameplay videos.
6. Perform focused REA investigations of the gameplay mechanics.
7. Produce the evidence-based specification.
8. Implement the actual Luau movement and collision engine.
9. Create a playable human-versus-bots prototype.
10. Test it and provide actual Roblox gameplay footage.

Do not stop after writing a research report.

Do not waste credits on another UI redesign.

Do not claim to have recovered exact logic without evidence.

**I expect a real, working Trail Wars gameplay prototype informed by careful reverse engineering and measurement—not a theoretical implementation plan.**