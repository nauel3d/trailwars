# Interaction, motion and sound

The intended feeling is tactile, immediate and encouraging. Research principles are in research-summary.md. Timings below are design hypotheses for testing, not measured Nintendo timings or proven retention improvements.

| Trigger | Proposed motion | Duration / easing | Reduced motion / sound |
|---|---|---|---|
| Hover | slight face lightening; no whole-screen movement | 80ms Quad Out | immediate tint; no hover sound |
| Focus change | cream/plum double outline; 1 short highlight | 90ms Quad Out | immediate outline; optional soft cue, max 6/s |
| Pointer/controller press | face moves 2px down, bevel depth reduces, label follows | immediate–45ms Quad Out | immediate displacement or tint; one quiet click |
| Release / activate | return to rest, at most 2% local overshoot | 110ms Back Out, overshoot capped | 60ms return/no bounce; one activation cue |
| Open root screen | old screen fades while new panel settles by 8px | 140ms Quad Out | 60ms crossfade / immediate |
| Close dialog | fade + 4px retreat; restore focus after cleanup | 100ms Quad In | immediate close |
| Tab selection | selected border and underline transfer | 90ms Quad Out | immediate; short optional select cue |
| Item selection | preview crossfade + selected check | 100ms Quad Out | immediate; no repeated sparkle loop |
| Equip submitted | label “Equipping…”; no success tick yet | static progress state | same; no loop sound |
| Equip confirmed | one checkmark settle, rim emphasis, visible “Equipped” | 160ms, 2% maximum scale | static check + text; single soft confirmation |
| Purchase success | confirmed ownership replaces price; balance updates once | 180ms highlight | immediate data, short optional confirmation |
| Purchase failed | stable warning icon + useful action; no shaking whole dialog | 100ms fade | immediate; gentle low cue, no harsh buzzer |
| Currency change | exact final number, one small emphasis | 140ms, optional count ≤250ms | immediate exact number; never animate a pending grant |
| Loading / queue | three dots / small ring on state changes | low-frequency ≤1Hz if needed | static glyph + text, no loop audio |
| Elimination | short localized “Out this round”; arena remains visible | 180ms fade | immediate text; mild cue |
| Victory | one core flourish + title settle, 8–12 tiny accents maximum | 450ms, then still | static flourish; one ≤700ms original cue |
| Defeat | placement settles; Play again remains available | 180ms Quad Out | immediate, encouraging neutral cue |
| Reward confirmation | confirmed rows reveal in ≤400ms total, skippable | 120ms per row, capped | all rows visible immediately |
| Toast | enter without obscuring interaction | 100ms fade | immediate; passive info ≥4s, actionable error persistent |

## Cancellation and concurrency

One tween per property owner. New input cancels/replaces the old tween from current value. Press, focus and selection are orthogonal states; pointer leave cannot erase selected/equipped status. Unmount cancels every owned tween/connection. Input release, canceled touch and focus loss reset pressed visuals and steering intent. Navigation starts on activation, not after an animation finishes.

## Sound contract

Only original/licensed Trail Wars sounds after approval. No Nintendo samples. Four cue families suffice: focus/select, activate, confirm, gentle warning; one outcome flourish for victory. Respect saved sound volume and platform sound-off context; UI remains fully understandable muted. No every-frame or every-hover cue. ≤3 concurrent UI voices, suppress repeated cue within 80ms, warnings rate-limited and paired with readable text. These are initial budgets to test for fatigue, not established performance facts.

Do not add background menu music until supplied/approved. Existing audio preferences persist, but current sound assets are absent. This presentation's motion board is a storyboard, not an implemented or acoustically tested system.
