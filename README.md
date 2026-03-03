# Claude Code Attention Hook (macOS)

A Claude Code hook that blinks the MacBook camera LED and speaks a voice alert whenever the agent needs your input. Never miss a prompt again — even when you're looking away from the terminal.

## What it does

When Claude Code needs your attention (permission prompts, idle prompts, etc.):

1. **Camera LED blinks 5 times** — the green light next to the FaceTime camera flashes on and off
2. **Voice announcement** — macOS text-to-speech says "Your agent needs you" using the Daniel voice

Both happen simultaneously.

## How it works

The camera LED on MacBooks is hardwired to the camera sensor — it can only turn on when the camera is active. There's no API to control it independently. This hook exploits that by briefly capturing a frame with `imagesnap` 5 times in a row, which toggles the LED on and off.

## Prerequisites

- macOS (tested on Apple Silicon MacBooks with notch)
- [Homebrew](https://brew.sh)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

## Installation

### 1. Install imagesnap

```bash
brew install imagesnap
```

### 2. Create the blink script

```bash
mkdir -p ~/.claude/hooks
```

Create `~/.claude/hooks/camera-blink.sh`:

```bash
#!/bin/bash
for _ in 1 2 3 4 5; do
  imagesnap -w 0.5 /tmp/claude-snap.jpg &>/dev/null
  rm -f /tmp/claude-snap.jpg
  sleep 0.5
done
```

Make it executable:

```bash
chmod +x ~/.claude/hooks/camera-blink.sh
```

### 3. Configure the hook

Add this to `~/.claude/settings.json` (create the file if it doesn't exist):

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/camera-blink.sh & say -v Daniel 'Your agent needs you'; wait"
          }
        ]
      }
    ]
  }
}
```

### 4. Grant camera access

The first time the hook fires, macOS will prompt you to grant camera access to your terminal app (Terminal, iTerm2, etc.). Approve it in **System Settings > Privacy & Security > Camera**.

### 5. Reload

Restart your Claude Code session or run `/hooks` to reload the configuration.

## Customization

### Change the number of blinks

Edit `camera-blink.sh` and change the loop range:

```bash
# 3 blinks instead of 5
for _ in 1 2 3; do
```

### Change blink speed

Adjust the warmup (`-w`) and sleep durations. The LED hardware needs at least ~0.5s per cycle to visibly toggle:

```bash
imagesnap -w 0.5 /tmp/claude-snap.jpg &>/dev/null  # LED on duration
sleep 0.5                                            # LED off duration
```

### Change the voice

List available voices:

```bash
say -v '?'
```

Replace `Daniel` in the hook command with any voice name:

```json
"command": "~/.claude/hooks/camera-blink.sh & say -v 'Samantha' 'Your agent needs you'; wait"
```

### Change the message

Replace the text after the voice name:

```json
"command": "~/.claude/hooks/camera-blink.sh & say -v Daniel 'Hey, come back to the terminal'; wait"
```

### Narrow when it fires

By default the hook fires on all notification types. Use a matcher to limit it:

```json
"matcher": "permission_prompt"
```

Available matchers: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`.
