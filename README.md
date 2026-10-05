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