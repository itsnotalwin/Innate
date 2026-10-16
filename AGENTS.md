# INNATE — project agent guide

- Branch: develop on `main` only; temporary branches require an explicit need.
- Game engine: Godot 4.6.3 Standard; web export uses `tools/web_shell.html`.
- Read `PROJECT.md` and the nearest folder `CONTEXT.md` before modifying code.
- Every maintained code folder requires `CONTEXT.md`; visual/UI folders also require `DESIGN.md` and a genuine screenshot of the running UI. Do not invent screenshot evidence.
- Preserve third-party art notices and license files. Hiding an in-game credit does not cancel applicable license terms.
- Treat experimental maps as acceptable for iteration; verify that automated export and deployment succeed, and clearly report remaining test gaps.
- Never force-push, overwrite concurrent changes, or claim deployment success without evidence.
