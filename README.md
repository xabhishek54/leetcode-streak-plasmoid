# LeetCode Streak

A lightweight desktop widget (plasmoid) for KDE Plasma 6 that tracks your LeetCode problem-solving streak, daily activity, heatmap grid, and statistics directly on your desktop.
<img width="535" height="480" alt="Screenshot_20260926_101249" src="https://github.com/user-attachments/assets/971f83fe-13c6-4bf7-a4f9-b0f9b82aa8f5" /> <img width="512" height="451" alt="Screenshot_20260926_101203" src="https://github.com/user-attachments/assets/e142790e-ccd6-48ae-abf1-16256e59f10b" /> <img width="532" height="494" alt="Screenshot_20260926_101319" src="https://github.com/user-attachments/assets/75245779-9506-4871-8bd6-9f7a3ba7f974" /> <img width="552" height="480" alt="Screenshot_20260926_101305" src="https://github.com/user-attachments/assets/2aa51e2f-6721-4cec-b7ea-c9c2e9d98a8d" />

## Features

- **Streak Tracking**: Displays current daily streak with automatic reset if no problems were solved today or yesterday.
- **Activity Heatmap**: 56-day aligned grid (14 columns × 4 rows) showing daily submission intensity with hover tooltips.
- **4 Built-in Color Themes**:
  - Midnight Neon (Blue & Cyan)
  - Emerald Cyber (Matrix Green)
  - Sunset Fire (Amber & Orange)
  - Dracula Violet (Purple & Neon)
- **Today's Status Badge**: Quick indicator showing whether today's problem has been completed.
- **Statistics Summary**: Displays total solved count and total active days.
- **Profile Link**: Click the widget header to open your LeetCode profile in your browser.
- **Automatic Fallback Engine**: Uses direct LeetCode GraphQL with API fallback for reliability.

## Installation

### Prerequisites
- KDE Plasma 6.0 or higher
- `kpackagetool6` (included with standard Plasma installation)

### Quick Install
Clone the repository and run the install script:

```bash
git clone https://github.com/xabhishek54/leetcode-streak-plasmoid.git
cd leetcode-streak-plasmoid
./install.sh
```

### Manual Installation
```bash
kpackagetool6 --type Plasma/Applet --install ./package
```

To update an existing installation:
```bash
kpackagetool6 --type Plasma/Applet --upgrade ./package
```

## Adding Widget to Desktop
1. Right-click your desktop and select **Add Widgets...**
2. Search for **LeetCode Streak** and drag it onto your desktop or panel.
3. Right-click the widget, select **Configure LeetCode Streak...**, and enter your LeetCode username.

## Configuration Options

| Option | Description | Default |
| :--- | :--- | :--- |
| Color Theme | Choose between Midnight, Emerald, Sunset, or Dracula themes | Midnight Neon |
| LeetCode Username | Your LeetCode handle (e.g., `lee215`) | None |
| Refresh Interval | Polling frequency in minutes | 30 |
| Glass Opacity | Background translucency (10% - 100%) | 90% |
| Activity Grid | Show or hide the heatmap grid | Enabled |
| Statistics | Show or hide solved totals and active days | Enabled |


## Uninstallation
```bash
./uninstall.sh
```
or via `kpackagetool6`:
```bash
kpackagetool6 --type Plasma/Applet --remove com.custom.leetcode-streak
```

## License
Distributed under the GNU General Public License v3.0 (`GPL-3.0-or-later`).

Developed by [xabhishek54](https://github.com/xabhishek54).
