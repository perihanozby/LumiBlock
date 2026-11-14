# Haptics

Patterns are queued by HapticsService without awaiting in gameplay. Requests are throttled to at least 40 ms, respect the in-app toggle, and are a no-op on desktop. Production uses Input.vibrate_handheld(duration_ms, amplitude) only on Android/iOS; the exact signature was verified. Tests inject a clock and recording driver, so no phone is touched by unit/UI tests.

Amplitude may be ignored on hardware without amplitude control; absent vibrators ignore calls. Godot cannot read Android's global touch-feedback switch. The in-app switch is the supported control and enabling it emits a sample tap. Actual vibration strength/feel remains BLOCKED(human device feedback), even if the authorized launch succeeds.
