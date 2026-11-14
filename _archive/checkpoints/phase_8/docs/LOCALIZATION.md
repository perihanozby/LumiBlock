> Historical prototype report. This is not current-session acceptance evidence. See [CODEX_PROGRESS.md](CODEX_PROGRESS.md) and [ACCEPTANCE_MATRIX.md](ACCEPTANCE_MATRIX.md) for the current implementation and executed results.

# Localization

The current CSV contains five canonical keys across all 16 target locales: `en`, `tr`, `es`, `pt-BR`, `fr`, `de`, `it`, `ja`, `ko`, `zh-CN`, `ar`, `hi`, `id`, `vi`, `ru`, and `th`. Generated Godot translation resources are present for each locale. The remaining player-facing labels in `scripts/main.gd` still need migration to keys, followed by RTL layout validation for Arabic and native-speaker review.

