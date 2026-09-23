# 🚀 ProjectRunner for NodeJS

**A universal, interactive CMD runner and diagnostic script for any NodeJS project on Windows.**

ProjectRunner provides a visually appealing, colorful interactive interface (menu) running entirely within a single `.bat` file. With just a few keystrokes, you can check your development environment status, pull changes from Git, install dependencies, and run your development or production server. All of this works out of the box with zero third-party dependencies—just standard Windows CMD.

<img width="615" height="506" alt="image" src="https://github.com/user-attachments/assets/2fbde43a-c715-4d3b-8791-ad56399efde1" />

---

## ✨ Key Features

*   **Portable and Independent:** Simply copy the single `ProjectRunner.bat` file into the root folder of your NodeJS project, and it works immediately. No installation or complex configuration is required.
*   **Smart Framework Autodetection:** The script automatically reads your `package.json`. If it detects **Vite**, **Next.js**, or **Create React App**, it adapts the start commands (`npm run preview` / `npm run start`), the expected build output folder (`dist` vs. `.next`), and the default browser ports (5173 vs. 3000) on the fly.
*   **Built-in System Diagnostics:** At a glance, colored badges show whether Node.js, npm, and Git are correctly installed, and whether your PowerShell execution policy is configured properly (preventing obscure script failures).
*   **Smarter `.env` Management:** If your project requires environment variables and contains a `.env.example` (or `.sample`), but the actual `.env` file is missing, the script alerts you with a yellow warning badge in the menu. It then offers a one-click option to copy the template and open it in your editor.
*   **Resilience Against ZIP Downloads:** If you download the project from GitHub as a ZIP archive (missing the `.git` folder), the script detects this. Instead of crashing or throwing errors, it gracefully disables the `git pull` option and displays a helpful explanation.
*   **Clean & Reinstall:** With a single press of the `C` key, the script can safely wipe your `node_modules` folder and perform a clean reinstallation of all dependencies. This solves 90% of common NodeJS project issues.

---

## 🚦 Getting Started

1. **Download:** Copy the `ProjectRunner.bat` file into your project folder (next to your `package.json`).
2. **Run:** Double-click `ProjectRunner.bat` in Windows Explorer (or execute it via the terminal) to launch the menu.
3. **Menu Navigation:** Use numbers 1-9 and letters to select actions (e.g., pulling updates, installing, running the server). The menu automatically refreshes and updates its status badges after every action or when a server is terminated (`Ctrl+C`).

---

## ⚙️ Optional Configuration (ProjectRunner.ini)

Although it works perfectly out-of-the-box using autodetection, you can create a `ProjectRunner.ini` file next to the script to override any default behavior.

**Example `ProjectRunner.ini`:**
```ini
[Project]
Title=My Custom Super Project
Subtitle=Development and Production Menu

[Server]
; Override the automatically detected port
DevUrl=http://localhost:8080
ProdUrl=http://localhost:8080
OpenBrowser=true

[Build]
; Override the output directory (normally detected as dist/.next/build)
BuildDir=build

[Commands]
; Override default NPM commands
DevCommand=npm run dev
BuildCommand=npm run build
ProdCommand=npm run preview
InstallCommand=npm install
```

---

## 💡 Tips

*   **Server Termination:** When you start a server (e.g., `Run DEV server`), the CMD window will run it actively. To return to the main menu, don't close the window! Instead, press `Ctrl+C` and confirm the termination (`Y` if prompted). The script will gracefully return you to the menu.
*   **Missing Dependencies:** You will never wonder why your app isn't starting again. The status indicator next to "Run DEV Server" displays a prominent red cross if the `node_modules` folder is missing, letting you know that you need to install dependencies first.

🎉 *Enjoy a smoother and more beautiful project launch experience on Windows!*
