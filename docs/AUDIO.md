# Original generated audio

All WAVs are original, synthesized in `tools/synth_audio.gd`, with no downloaded samples or third-party audio. Source format is PCM16, mono, 32 kHz. Fixed seeds make synthesis repeatable. Short events use pentatonic glass bells, sine ticks and a decaying swept thud; levels are normalized after two-millisecond edge fades to -6/-9 dBFS. The 48-second pad/pluck loop is normalized to -12 dBFS and circularly crossfaded, then imported as looping IMA-ADPCM.

AudioService owns eight reusable SFX players and one Music player on explicit buses. It uses explicit resource paths, so exported `.remap` files do not break discovery. Toggles/volumes change real buses, enabling SFX plays a sample, sliders sample on release, and application pause suspends music. No network or downloaded sample is used. These generated assets may be distributed with LumiBlock; no third-party audio attribution is required.

Structural peak, length, format and seam checks are automated. Sound quality remains BLOCKED(human listening); generated audio has not been claimed pleasing or approved.
