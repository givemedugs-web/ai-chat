# ai-chat

## Universal Modder (`universal-modder.html`)

A self-contained, single-file web app for modding/patching any file — 100% local, nothing leaves your browser.

**How to use:** open `universal-modder.html` in any browser (double-click it).

Features:
- Drag & drop (or browse) any text-based file: HTML, JS, CSS, JSON, TXT, MD…
- Create **mods** as find→replace patches (plain text or regex, global / first-only, ignore-case)
- **Inject** code snippets at the end of a file, plus one-click presets (inject `<script>`, inject `<style>`, change title, strip comments)
- Toggle, reorder, delete mods — patches re-apply deterministically from the baseline every time
- Export/import your mod collection as `.umod.json` files (shareable mod packs)
- Live match-count badges, diff summary vs. original, activity log
- Download the modified file as `name.modded.ext`, or reset back to the original anytime
- "Load demo file" button to try it instantly with a sample game file

## Game Fusion (`game-fusion.html`)

A self-contained, single-file web app that **combines two HTML games into one** playable fusion — 100% local, nothing leaves your browser.

**How to use:** open `game-fusion.html` in any browser (double-click it).

Features:
- Load any two single-file HTML games via drag & drop or browse (or use the built-in demo games: Snake + Click Frenzy)
- Three fusion modes:
  - 🪟 **Split-screen** — both games side by side in one page, with an adjustable divider ratio
  - 🗂 **Tabbed switcher** — flip instantly between the two games with tabs
  - 🧪 **Script Remix** (advanced) — inject Game B's JavaScript (or your own custom script) directly into Game A's page so both scripts share one world
- Each game runs in a sandboxed iframe so they can't crash each other (except in Remix mode, by design)
- Custom labels for each game; live stage preview with activity log
- Copy the fused HTML to clipboard, or download it as a standalone `fused-game.html` — **or as a ZIP package** (`fused-game.zip` containing the fused game, both original source games, and a README) via the format dropdown
- 🖥 **Game Scanner** — scan a folder on your PC (browser sandbox: you pick the folder, nothing is uploaded) to auto-discover HTML game files by looking for game signals (`<canvas>`, `requestAnimationFrame`, score/game keywords); load any hit straight into slot A or B with one click. "Quick scan" pre-points the picker at common folders (Downloads/Documents/Games/Desktop). Falls back to the directory-picker input on browsers without the File System API. You can play/share the output anywhere
- 🪟 **Full-PC library scan (Windows)** — press **"⬇ Download scanner.zip"** in the Game Scanner card (no fusion needed; the same scanner is also bundled inside `fused-game.zip`). Unzip and double-click `scan-games.bat`: it detects installed games from **Steam** (registry + `appmanifest_*.acf` incl. extra library folders), **Epic Games** (`*.item` manifests), and **itch.io** (crumbs/downloads.json + butler apps), plus HTML games in Documents/Desktop/Downloads, and writes `game-library.json`. Press **"Import game-library.json"** in the app — every detected game appears grouped by platform with one-click **→ A / → B** buttons (HTML entries upload instantly; native Steam/Epic/itch entries show their install path). Everything stays 100% local.