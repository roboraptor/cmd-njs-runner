# 🚀 ProjectRunner for NodeJS

**A universal, interactive CMD runner and diagnostic script for any NodeJS project on Windows.**

ProjectRunner provides a visually appealing, colorful interactive menu running entirely within a single `.bat` file. With just a few keystrokes, you can check your development environment status, pull changes from Git, configure `.env`, install dependencies, build production bundles, and run your development or production server. All of this works out of the box with zero third-party dependencies—just standard Windows CMD (with ANSI color support and UTF-8).

<img width="615" height="506" alt="image" src="https://github.com/user-attachments/assets/2fbde43a-c715-4d3b-8791-ad56399efde1" />

---

## ✨ Key Features

*   **Portable and Independent:** Simply copy `ProjectRunner.bat` into the root folder of your NodeJS project and run it. No installation or complex setup is required.
*   **Smart Framework Autodetection:** Automatically reads `package.json` to identify **Vite** (port `5173`, `dist`, `npm run preview`), **Next.js** (port `3000`, `.next`, `npm run start`), **Create React App** (`react-scripts`, port `3000`, `build`, `npm run start`), or generic **NodeJS** projects (port `3000`, checking `.next` / `build` / `dist`).
*   **Built-in System Diagnostics:** Colored status badges show at a glance whether Node.js, npm, and Git are available in `PATH`, and whether your PowerShell Execution Policy is permissive (automatically offering to set `RemoteSigned` for `CurrentUser` if it is `Restricted`).
*   **Smarter `.env` Management:** Checks if `.env` exists. If missing, it detects `.env.example`, `.env.sample`, or `.env.template` and highlights `[!]` in the menu so you can copy a template (or create a blank `.env`) and open it in Notepad. If `.env` already exists, you can view its contents inline or open it in Notepad.
*   **Resilience Against ZIP Downloads:** If the project was downloaded as a ZIP archive without a `.git` folder, ProjectRunner detects this cleanly, shows a `[-]` badge instead of failing, and explains how to update or clone via Git.
*   **Clean Builds & Dependency Recovery:** Running a production build automatically removes the previous build output folder (`dist`, `.next`, `build`, or custom `BuildDir`) beforehand to prevent stale cache artifacts. The `[C]` **Clean & Reinstall** option safely deletes `node_modules` and performs a fresh install.
*   **Automated `.rebuild` Flag Workflow:** Supports automated/remote production rebuilds and restarts via a `.rebuild` trigger file in the project root without opening duplicate browser tabs.
*   **Companion INI Creator (`PR-ini-creator.bat`):** An interactive wizard to import project metadata from `package.json`, create, edit, or preview your `ProjectRunner.ini` configuration.

---

## 🚦 Getting Started & Menu Overview

1. **Download:** Copy `ProjectRunner.bat` (and optionally `PR-ini-creator.bat`) into your project root folder (next to `package.json`).
2. **Run:** Double-click `ProjectRunner.bat` in Windows Explorer or run it from a terminal.
3. **Navigate the Menu:**

| Key | Action | Description |
| :--- | :--- | :--- |
| **`1`** | Check Node.js / npm | Displays installed `node` and `npm` versions and executable path. |
| **`2`** | Check Git environment | Displays Git CLI version, repository state, and active branch (or ZIP notice). |
| **`3`** | PowerShell Execution Policy | Checks `Get-ExecutionPolicy`; sets `RemoteSigned` (`CurrentUser`) if `Restricted`. |
| **`4`** | Pull latest changes | Runs `git pull` (or shows helpful update instructions when `.git` is absent). |
| **`5`** | Install dependencies | Runs the configured install command (default: `npm install`). Uses `npm_config_loglevel=info` by default so package fetch/install progress is visible (overridable via `InstallCommand`). |
| **`6`** | Environment variables (`.env`) | View/edit `.env`, copy from `.env.example`/`.env.sample`/`.env.template`, or create a blank `.env`. |
| **`7`** | Run DEV Server | Opens `DevUrl` in your browser (if enabled) and runs `DevCommand` (`npm run dev`). |
| **`8`** | Build Production | Cleans the existing build folder (`BuildDir`) and runs `BuildCommand` (`npm run build`). |
| **`9`** | Run PROD Server | Verifies `BuildDir` exists, opens `ProdUrl` (if enabled), and runs `ProdCommand`. |
| **`C`** | Clean & Reinstall | Confirms, removes `node_modules`, and runs a fresh install. |
| **`R`** | Refresh & Reload | Re-reads `ProjectRunner.ini` / `package.json` and refreshes all status badges. |
| **`A`** | About ProjectRunner | Displays project info and repository link. |
| **`0` / `Q`** | Exit | Exits ProjectRunner cleanly. |

---

## ⚙️ Configuration & `PR-ini-creator.bat`

ProjectRunner works out of the box via autodetection, or you can override any setting with `ProjectRunner.ini` (also falls back to `runner.ini` if `ProjectRunner.ini` is not present).

### Using `PR-ini-creator.bat`

Run `PR-ini-creator.bat` in your project root for an interactive configuration assistant:

*   **`[1]` Import from `package.json`:** Reads `name` and `description` from `package.json` and generates a starter `ProjectRunner.ini`.
*   **`[2]` Create manually:** Guided prompts for Title, Subtitle, port (`3000`, `5173`, or custom), automatic browser launch, custom build folder, and custom NPM commands.
*   **`[3]` Edit `ProjectRunner.ini`:** Interactively updates an existing `ProjectRunner.ini` (press `Enter` to keep any current value).
*   **`[4]` Show `ProjectRunner.ini`:** Previews how `ProjectRunner.bat` will render your project header and active overrides.

### Example `ProjectRunner.ini`

```ini
[Project]
Title=My Custom Super Project
Subtitle=Development and Production Menu

[Server]
; Override the automatically detected URL/port
DevUrl=http://localhost:8080
ProdUrl=http://localhost:8080
OpenBrowser=true

[Build]
; Override the output directory (auto-detected: dist / .next / build)
BuildDir=build

[Commands]
; Override default commands
DevCommand=npm run dev
BuildCommand=npm run build
ProdCommand=npm run preview
InstallCommand=npm install
```

> **Note:** `ProjectRunner.bat` also recognizes legacy keys `PROJECT_NAME` (alias for `Title`) and `PROJECT_DESC` (alias for `Subtitle`).

---

## 🔄 Automated Rebuild Workflow (`.rebuild` Flag)

When running the production server (`[9]`), ProjectRunner supports an automated rebuild-and-restart loop using a `.rebuild` marker file:

1. Create an empty `.rebuild` file in the project root directory (for example, triggered by a deployment hook, external script, or an in-app admin action) and stop the running production server process.
2. When `ProdCommand` exits, `ProjectRunner.bat` detects `.rebuild` and automatically enters the rebuild sequence instead of returning to the menu.
3. It wipes the previous `BuildDir` cache, runs `BuildCommand`, deletes the `.rebuild` marker file, disables browser launch (`OPEN_BROWSER=false`) so no duplicate tab opens, and immediately restarts `ProdCommand`.
4. If the build fails, `.rebuild` is deleted and the script pauses so you can inspect the build error log.

---

## 💡 Tips

*   **Server Termination:** Dev and prod servers run directly in the active CMD window. To stop a server and return to the menu, press `Ctrl+C` (and confirm `Y` if prompted)—do not close the window.
*   **Hot-Reloading INI Changes:** After editing `ProjectRunner.ini` (manually or via `PR-ini-creator.bat`), press `R` in the main menu to reload the configuration without restarting the script.
*   **Missing Dependencies:** If `node_modules` is missing, `[5]` and `[7]` display a red `[✗]` indicator so you immediately know to install dependencies first.

🎉 *Enjoy a smoother and cleaner NodeJS project workflow on Windows!*
