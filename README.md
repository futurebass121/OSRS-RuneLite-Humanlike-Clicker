# RuneLite Human AutoClicker

A human-like auto clicker for Old School RuneScape.  
I’ve gotten a few 99s with this already and thought I’d upload it here in case anyone else finds it useful.

---

## Features

- **Human-like mouse movement:** Moves the mouse with Bezier curves and random delays, so it doesn’t look like a robot.
- **Randomness & error simulation:** Sliders to mess with how random or “human” it acts, including mistakes and hand fatigue.
- **Break system:** Takes random breaks so it’s not just clicking forever (shows you when the next break is coming).
- **Live stats:** See how many clicks, how long it’s been running, and when the next break will be.
- **Customizable hotkey:** Pick your own start/stop key (default: CapsLock).
- **Simple region:** Clicks in a small area around where you started it, so it’s not always pixel-perfect.

---

## How I Used This Script

- **99 Agility:**  
  Used this in Brimhaven Agility Dungeon on three accounts. Start the script with your mouse over the floor spikes. You’ll want the Detached Camera plugin on RuneLite so the screen doesn’t move around.

- **99 Thieving:**  
  For Knights of Ardougne, I’d find a splashing world and lower the camera so I couldn’t miss the knight. Turn on Entity Hider so the knight doesn’t disappear for a tick and mess up the clicking.

---

## How To Use

1. Download and install [AutoHotkey v2](https://www.autohotkey.com/download/).
2. Copy the script (`.ahk` file) from this repo.
3. Open RuneLite and log in to your OSRS account.
4. (For Brimhaven) Use the Detached Camera plugin.
5. Put your mouse where you want the script to click (like the obstacle or the knight).
6. Run the script.
7. Set your hotkey in the GUI (default: CapsLock).
8. Adjust the humanization sliders and inputs if you want.
9. Press your hotkey to start/stop.

**Tip:**  
Start the script with your mouse already over the thing you want to click. It’ll click in a small area around that spot, not just one pixel.

---

## Humanization Settings Explained

This script tries to act like a real person, not a robot. The settings below help you fine-tune how “human” your clicks look and feel:

- **Randomness**  
  *How much the click timing and position varies.*  
  - **Low value:** Clicks are nearly the same every time (robotic).
  - **High value:** Clicks are more unpredictable (like a distracted or tired human).

- **Error Rate**  
  *How often the script intentionally makes mistakes, like missing the target or double-clicking.*  
  - **0:** Never messes up.
  - **Higher values:** Sometimes clicks the wrong spot, double-clicks, or pauses awkwardly—just like a real player zoning out or misclicking.

- **Fatigue Drift**  
  *Simulates your hand getting tired and drifting off target over time.*  
  - **Low value:** Mouse stays on target.
  - **High value:** Mouse drifts more, like your hand is getting lazy or tired after a while.

- **Click Speed (% slower)**  
  *Makes every click take longer, as if you’re getting tired or distracted.*  
  - **0%:** Original (fastest) speed.
  - **100%:** Twice as slow as the original speed.
  - **Tip:** If you want to play it safe, use a higher value for less “bot-like” clicking.

- **Breaks**  
  The script will automatically take random breaks (5–15 seconds every 1–3 minutes) to mimic a real person pausing for a drink, a stretch, or to answer a message.

---

### Recommended Settings

- For **maximum safety**: Use higher randomness, a small error rate, and some fatigue drift. Set click speed to at least 20–30% slower than default.
- For **maximum speed**: Lower randomness, error, and fatigue, and keep click speed at 0%. (But this is more bot-like and riskier!)

---

## Disclaimer

- This script is for educational and personal use only.
- Use at your own risk!
- Jagex doesn’t allow automation; even human-like bots can get banned.
- I’m not responsible for bans or anything else that happens to your account.

---
