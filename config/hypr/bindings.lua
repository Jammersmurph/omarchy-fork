-- Jammarchy's application layout replaces these Quattro defaults.
for _, keys in ipairs({
  "SUPER + RETURN",
  "SUPER + ALT + RETURN",
  "SUPER + SHIFT + F",
  "SUPER + SHIFT + B",
  "SUPER + S",
  "SUPER + G",
  "SUPER + O",
  "SUPER + SLASH",
  "SUPER + SHIFT + S",
  "SUPER + SHIFT + A",
  "SUPER + C",
  "SUPER + SHIFT + G",
  "SUPER + ALT + G",
  "SUPER + SPACE",
  "SUPER + ALT + SPACE",
  "SUPER + SHIFT + code:201",
}) do
  hl.unbind(keys)
end

o.bind("SUPER + RETURN", "Terminal", { omarchy = "terminal" })
o.bind("SUPER + ALT + RETURN", "Tmux", "omarchy-launch-terminal tmux new")
o.bind("SUPER + SHIFT + F", "File manager", { omarchy = "nautilus" })
o.bind("SUPER + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + B", "Browser (private)", { omarchy = "browser --private" })
o.bind("SUPER + M", "Music", { omarchy = "spotify" })
o.bind("SUPER + N", "Editor", { omarchy = "editor" })
o.bind("SUPER + S", "Activity", { tui = "btop" })
o.bind("SUPER + D", "Docker", { tui = "lazydocker" })
o.bind("SUPER + G", "Signal", { omarchy = "signal" })
o.bind("SUPER + O", "Obsidian", { launch = "obsidian", focus = "^obsidian$" })
o.bind("SUPER + SLASH", "Passwords", { omarchy = "1password" })
o.bind("SUPER + SHIFT + S", "Sober", { launch = "flatpak run org.vinegarhq.Sober" })

o.bind("SUPER + A", "ChatGPT", { webapp = "https://chatgpt.com" })
o.bind("SUPER + SHIFT + A", "Grok", { webapp = "https://grok.com" })
o.bind("SUPER + C", "Wi-Fi", { tui = "impala" })
o.bind("SUPER + E", "Email", { webapp = "https://app.hey.com" })
o.bind("SUPER + Y", "YouTube", { webapp = "https://youtube.com/", focus = true })
o.bind("SUPER + SHIFT + G", "WhatsApp", {
  webapp = "https://web.whatsapp.com/",
  focus = true,
})
o.bind("SUPER + ALT + G", "Google Messages", {
  webapp = "https://messages.google.com/web/conversations",
  focus = true,
})
o.bind("SUPER + SHIFT + T", "Tailscale", "omarchy-shell omarchy.tailscale toggle")

o.bind("SUPER + SPACE", "Launch apps", "omarchy-menu toggle apps")
o.bind("SUPER + ALT + SPACE", "Jammarchy menu", "omarchy-menu toggle root")
o.bind("SUPER + SHIFT + code:201", "Jammarchy menu", "omarchy-menu toggle root")
