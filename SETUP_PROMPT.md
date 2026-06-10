# Setup Prompt — paste into Claude Code on any new device

Copy the block below into a fresh Claude Code session on the new machine.

---

```
Set up my Claude Code universal kit on this machine.

1. Clone my kit (private repo — gh auth login first if gh isn't authenticated):
     git clone https://github.com/sidhartha8011/claude-universal-kit.git ~/.claude/universal-kit
   If ~/.claude/universal-kit already exists, git pull instead.

2. Run the bootstrap:
     chmod +x ~/.claude/universal-kit/*.sh
     ~/.claude/universal-kit/bootstrap.sh
   This clones the four source libraries (anthropics/skills, wshobson/agents,
   affaan-m/ecc, awesome-claude-code) into ~/.claude/skills/, symlinks the
   kit's agents and skills into ~/.claude/agents and ~/.claude/skills,
   installs the slash commands (/onboard /task /build /genesis /rootcause
   /ship) into ~/.claude/commands/, and regenerates AGENT_INDEX.md with
   this machine's paths.

3. Verify: list ~/.claude/agents (expect ~17 symlinks), ~/.claude/commands
   (expect 6 kit commands), and confirm AGENT_INDEX.md has 170+ entries.

4. Tell me what was installed and remind me to restart Claude Code so the
   slash commands register.

If anything fails (missing git/gh, clone errors), fix it yourself where
possible and report what you did.
```

---

## Keeping devices in sync

After changing the kit on any machine:

    cd ~/.claude/universal-kit && git add -A && git commit -m "update kit" && git push

On other machines:

    cd ~/.claude/universal-kit && git pull && ./bootstrap.sh
