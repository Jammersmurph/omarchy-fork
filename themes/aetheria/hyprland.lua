hl.config({
  general = {
    col = {
      active_border = "rgb(e20342) rgb(c8e967) 45deg",
      inactive_border = "rgb(2a153c)",
    },
  },

  decoration = {
    dim_modal = true,
    dim_around = 0.4,
    dim_special = 0.4,
    dim_inactive = true,
    dim_strength = 0.4,
  },
})

hl.curve("aetheriaFastSpatial", { type = "bezier", points = { { 0.42, 1.67 }, { 0.21, 0.90 } } })
hl.curve("aetheriaSlowSpatial", { type = "bezier", points = { { 0.39, 1.29 }, { 0.35, 0.98 } } })
hl.curve("aetheriaDefaultSpatial", { type = "bezier", points = { { 0.38, 1.21 }, { 0.22, 1.00 } } })
hl.curve("aetheriaEmphasizedDecel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("aetheriaEmphasizedAccel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("aetheriaMenuDecel", { type = "bezier", points = { { 0.1, 1 }, { 0, 1 } } })
hl.curve("aetheriaMenuAccel", { type = "bezier", points = { { 0.52, 0.03 }, { 0.72, 0.08 } } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "aetheriaEmphasizedDecel", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "aetheriaEmphasizedDecel", style = "popin 90%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "aetheriaEmphasizedDecel", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "aetheriaEmphasizedDecel" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2.7, bezier = "aetheriaEmphasizedDecel", style = "popin 93%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2.4, bezier = "aetheriaMenuAccel", style = "popin 94%" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 0.5, bezier = "aetheriaMenuDecel" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.7, bezier = "aetheriaMenuAccel" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "aetheriaMenuDecel", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 2.8, bezier = "aetheriaEmphasizedDecel", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 1.2, bezier = "aetheriaEmphasizedAccel", style = "slidevert" })

o.bind(
  "SUPER + ALT + BACKSPACE",
  "Toggle dimming",
  "bash $HOME/.local/state/omarchy/current/theme/dimming.sh"
)
