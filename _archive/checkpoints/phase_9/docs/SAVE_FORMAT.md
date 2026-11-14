# Save schema v2

Main path is unchanged: `user://lumiblock_save.json`. The helper scripts redirect user:// to `.runtime/AppData/Roaming/Godot/app_userdata/LumiBlock` for development. They do not read real external player profiles.

Envelope: schema=2, app_version=0.2.0, saved_at Unix seconds, checksum SHA-256 hex, data. The field structure is specified in MASTER_IMPLEMENTATION_PROMPT.md section 9 and implemented in core/save_schema.gd. Unknown dictionary fields are retained during validation, including session/tray extensions.

Checksum covers data only. Recursively canonicalize integral floats with magnitude below 2^53 to integers, convert dictionary keys to strings, sort keys lexically, preserve array order, then use compact sorted JSON with full float precision. Verify the same canonicalization before schema coercion/default insertion. Booleans remain booleans. Fractional volumes/time remain floats; integer schema fields are explicitly coerced/clamped.

Write sequence: validate data, encode, write/flush/close .tmp, check FileAccess error, reread/validate/checksum, copy existing valid main to .bak.json, remove main, rename .tmp to main. All filesystem return values are checked. On injected rename failure, copy the backup back to main and report failure; backup remains recoverable even if restoration fails. Corrupt existing files cannot be silently replaced by save_game without recovery. A newer schema disables writing even if the caller skips loading first.

Read sequence: main, then backup. Invalid files are renamed to timestamped .corrupt files. A valid backup emits toast.save_repaired. No readable profile emits toast.save_unreadable after retaining invalid bytes. Newer schema emits toast.save_future and leaves bytes untouched. Quarantine/backup creation failure disables writes rather than deleting original bytes.

Before migrating v1, retain an exact one-time lumiblock_save.v1.bak.json. Map legacy coordinate sets to stable catalog ids, preserve three null-capable slots, merge settings/defaults and coerce numeric values. Discard imprecise engine RNG state: seed from started_at/date, stream index zero. This is the explicitly allowed v1 sequence discontinuity. Pure v2 sessions retain exact u32 RNG state and stream index.

SaveService emits saved, save_failed, and notice(key). Non-forced saves debounce 250ms; AppRoot flushes on pause/focus/close/back and periodically during gameplay. Production AppRoot uses schema2 GameSession directly. The legacy adapter is retained only for archived-prototype compatibility and is excluded with the prototype main scene from exports.

Godot 4.7.2 decimal JSON parsing can shift the final ULP of a fractional double. If reserialized semantic checksum differs, the reader also hashes the exact root data JSON bytes written by the canonical writer. The complete data payload remains covered by SHA-256; unknown fields are not rounded, and altered bytes still fail. A quote/escape/depth-aware extractor cannot confuse nested data keys with the root field. Fractional-tick regression tests exercise both disk and in-memory roundtrips; exact u32 stream state remains unchanged.
