#SingleInstance Force
SetTitleMatchMode(2)
CoordMode("Mouse", "Screen")

global GuiCreated := false
global IsRunning := false
global HumanErrorRate := 8
global FatigueLevel := 0
global FatigueDriftRadius := 10
global RandomnessLevel := 50
global ClickSpeedPercent := 1.0  ; 1.0 = normal, 1.5 = 50% slower
global MinRuntime := 0
global MaxRuntime := 0
global DarkMode := false
global ClickCount := 0
global SessionStart := 0
global SessionEnd := 0

global MyGui, StartButton, StopButton
global RandomnessSlider, HumanErrorSlider, FatigueSlider
global RandomnessEdit, HumanErrorEdit, FatigueEdit
global ClickSpeedSlider, ClickSpeedEdit
global MinRuntimeSlider, MaxRuntimeSlider, MinRuntimeEdit, MaxRuntimeEdit
global StatText, TimeText, NextBreakText, TotalRunText, RuntimeLimitsText
global Hotkey1Ctrl
global Hotkey1 := "CapsLock"
global prevHotkey1 := ""

global FixedX := 0
global FixedY := 0
global TotalRunTime := 0
global NextBreakTime := 0

; Rhythm variables for humanized click timing
global ClickingRhythm := 0
global RhythmDuration := 0
global RhythmProgress := 0

CreateGui() {
    global GuiCreated, MyGui, StartButton, StopButton
    global RandomnessSlider, HumanErrorSlider, FatigueSlider
    global RandomnessEdit, HumanErrorEdit, FatigueEdit
    global ClickSpeedSlider, ClickSpeedEdit
    global MinRuntimeSlider, MaxRuntimeSlider, MinRuntimeEdit, MaxRuntimeEdit
    global StatText, TimeText, Hotkey1Ctrl, NextBreakText, TotalRunText, RuntimeLimitsText

    if (GuiCreated)
        return

    MyGui := Gui("+Resize +OwnDialogs +AlwaysOnTop", "Super Humanlike Auto-Clicker")
    MyGui.Font := "s10 Segoe UI"
    
    ; Session Controls
    MyGui.Add("GroupBox", "x10 y10 w350 h100", "Session Controls")
    StartButton := MyGui.Add("Button", "x30 y35 w120 h30", "Start [Hotkey]")
    StartButton.OnEvent("Click", StartSession)
    StopButton := MyGui.Add("Button", "x170 y35 w120 h30", "Stop")
    StopButton.OnEvent("Click", StopSession)
    ToggleBtn := MyGui.Add("Button", "x310 y35 w40 h30", "☀️/🌙")
    ToggleBtn.OnEvent("Click", ToggleMode)

    ; Hotkey Customization
    MyGui.Add("Text", "x30 y75 w80 h20", "Hotkey:")
    Hotkey1Ctrl := MyGui.Add("Hotkey", "x110 y75 w80 h20")
    Hotkey1Ctrl.Value := Hotkey1
    SetHotkeysBtn := MyGui.Add("Button", "x200 y75 w40 h20", "Set")
    SetHotkeysBtn.OnEvent("Click", SetCustomHotkeys)

    ; Humanization & Timing
    MyGui.Add("GroupBox", "x10 y120 w350 h230", "Humanization & Timing")

    MyGui.Add("Text", "x25 y145 w120 h20", "Randomness (1-100):")
    RandomnessSlider := MyGui.Add("Slider", "x150 y145 w120 h20 Range1-100", 50)
    RandomnessEdit := MyGui.Add("Edit", "x280 y145 w40 h20 Number", "50")
    RandomnessSlider.OnEvent("Change", (*) => RandomnessEdit.Value := RandomnessSlider.Value)
    RandomnessEdit.OnEvent("Change", (*) => RandomnessSlider.Value := Clamp(RandomnessEdit.Value, 1, 100))

    MyGui.Add("Text", "x25 y175 w120 h20", "Error Rate (0-20):")
    HumanErrorSlider := MyGui.Add("Slider", "x150 y175 w120 h20 Range0-20", 8)
    HumanErrorEdit := MyGui.Add("Edit", "x280 y175 w40 h20 Number", "8")
    HumanErrorSlider.OnEvent("Change", (*) => HumanErrorEdit.Value := HumanErrorSlider.Value)
    HumanErrorEdit.OnEvent("Change", (*) => HumanErrorSlider.Value := Clamp(HumanErrorEdit.Value, 0, 20))

    MyGui.Add("Text", "x25 y205 w120 h20", "Fatigue Drift (1-30):")
    FatigueSlider := MyGui.Add("Slider", "x150 y205 w120 h20 Range1-30", 10)
    FatigueEdit := MyGui.Add("Edit", "x280 y205 w40 h20 Number", "10")
    FatigueSlider.OnEvent("Change", (*) => FatigueEdit.Value := FatigueSlider.Value)
    FatigueEdit.OnEvent("Change", (*) => FatigueSlider.Value := Clamp(FatigueEdit.Value, 1, 30))

    MyGui.Add("Text", "x25 y235 w120 h20", "Click Speed (% slower):")
    ClickSpeedSlider := MyGui.Add("Slider", "x150 y235 w120 h20 Range0-50", 0)
    ClickSpeedEdit := MyGui.Add("Edit", "x280 y235 w40 h20 Number", "0")
    ClickSpeedSlider.OnEvent("Change", (*) => ClickSpeedEdit.Value := ClickSpeedSlider.Value)
    ClickSpeedEdit.OnEvent("Change", (*) => ClickSpeedSlider.Value := Clamp(ClickSpeedEdit.Value, 0, 50))

    ; Runtime in MINUTES
    MyGui.Add("Text", "x25 y265 w120 h20", "Min Runtime (min):")
    MinRuntimeSlider := MyGui.Add("Slider", "x150 y265 w120 h20 Range0-60", 0)
    MinRuntimeEdit := MyGui.Add("Edit", "x280 y265 w40 h20 Number", "0")
    MinRuntimeSlider.OnEvent("Change", (*) => MinRuntimeEdit.Value := MinRuntimeSlider.Value)
    MinRuntimeEdit.OnEvent("Change", (*) => MinRuntimeSlider.Value := Clamp(MinRuntimeEdit.Value, 0, 60))

    MyGui.Add("Text", "x25 y295 w120 h20", "Max Runtime (min):")
    MaxRuntimeSlider := MyGui.Add("Slider", "x150 y295 w120 h20 Range0-60", 0)
    MaxRuntimeEdit := MyGui.Add("Edit", "x280 y295 w40 h20 Number", "0")
    MaxRuntimeSlider.OnEvent("Change", (*) => MaxRuntimeEdit.Value := MaxRuntimeSlider.Value)
    MaxRuntimeEdit.OnEvent("Change", (*) => MaxRuntimeSlider.Value := Clamp(MaxRuntimeEdit.Value, 0, 60))

    MyGui.Add("Text", "x25 y325 w320 h40", "Randomness: More = less robotic. Error Rate: More = more mistakes. Fatigue: More = more drift. Click Speed: Higher = slower.")

    RuntimeLimitsText := MyGui.Add("Text", "x25 y370 w320 h20", "Set min/max run time (0 = off)")

    ; Stats
    MyGui.Add("GroupBox", "x10 y400 w350 h120", "Stats")
    StatText := MyGui.Add("Text", "x25 y425 w320 h20", "Not started.")
    TimeText := MyGui.Add("Text", "x25 y450 w320 h20")
    TotalRunText := MyGui.Add("Text", "x25 y475 w320 h20", "Total run time: 0s")
    NextBreakText := MyGui.Add("Text", "x25 y500 w320 h20", "Next break: N/A")

    MyGui.Show("w370 h540")
    GuiCreated := true
    StopButton.Enabled := false
    SetCustomHotkeys()
}

ToggleMode(*) {
    global DarkMode, MyGui
    DarkMode := !DarkMode
    if (DarkMode) {
        MyGui.BackColor := 0x222222
        MyGui.SetFont("cFFFFFF")
    } else {
        MyGui.BackColor := 0xF0F0F0
        MyGui.SetFont("c000000")
    }
}

Clamp(val, min, max) {
    val := Floor(val)
    if val < min
        return min
    if val > max
        return max
    return val
}

StartSession(*) {
    global IsRunning, ClickCount, SessionStart, SessionEnd
    global RandomnessSlider, HumanErrorSlider, FatigueSlider, ClickSpeedSlider
    global MinRuntimeSlider, MaxRuntimeSlider, StartButton, StopButton
    global FixedX, FixedY, NextBreakTime, TotalRunTime
    global ClickingRhythm, RhythmDuration, RhythmProgress

    if (IsRunning)
        return

    MouseGetPos(&FixedX, &FixedY)
    IsRunning := true
    ClickCount := 0
    SessionStart := A_TickCount
    SessionEnd := 0
    NextBreakTime := RandomInt(60, 180) ; Next break between 1-3 minutes
    TotalRunTime := 0

    ; Reset rhythm for humanized click speed
    Random, ClickingRhythm, 0, 5
    Random, RhythmDuration, 8, 22
    RhythmProgress := 0

    StartButton.Enabled := false
    StopButton.Enabled := true

    SetTimer(ClickLoop, -100)
    SetTimer(UpdateStats, 500)
}

StopSession(*) {
    global IsRunning, SessionEnd, StartButton, StopButton
    
    IsRunning := false
    SessionEnd := A_TickCount

    SetTimer(ClickLoop, 0)
    SetTimer(UpdateStats, 0)

    StartButton.Enabled := true
    StopButton.Enabled := false
}

ClickLoop() {
    global IsRunning, RandomnessSlider, HumanErrorSlider, FatigueSlider, ClickSpeedSlider
    global MinRuntimeSlider, MaxRuntimeSlider
    global FatigueLevel, ClickCount
    global RandomnessLevel, HumanErrorRate, FatigueDriftRadius, ClickSpeedPercent, MinRuntime, MaxRuntime
    global FixedX, FixedY, NextBreakTime, SessionStart
    global ClickingRhythm, RhythmDuration, RhythmProgress

    if (!IsRunning)
        return

    RandomnessLevel := RandomnessSlider.Value
    HumanErrorRate := HumanErrorSlider.Value
    FatigueDriftRadius := FatigueSlider.Value
    ClickSpeedPercent := 1 + (ClickSpeedSlider.Value / 100)
    MinRuntime := MinRuntimeSlider.Value * 60 ; convert to seconds
    MaxRuntime := MaxRuntimeSlider.Value * 60 ; convert to seconds

    elapsed := (A_TickCount - SessionStart) // 1000

    ; Stop if max runtime reached (if set)
    if (MaxRuntime > 0 && elapsed >= MaxRuntime) {
        StopSession()
        return
    }

    ; Always click in a small region around the original starting point
    x1 := FixedX - 10
    y1 := FixedY - 10
    x2 := FixedX + 10
    y2 := FixedY + 10

    tx := RandomInt(x1, x2)
    ty := RandomInt(y1, y2)
    cx1 := RandomInt(x1, x2)
    cy1 := RandomInt(y1, y2)
    cx2 := RandomInt(x1, x2)
    cy2 := RandomInt(y1, y2)

    MoveBezier(tx, ty, cx1, cy1, cx2, cy2)

    Sleep(RandomInt(10, 100 + RandomnessLevel))
    Click("Down")
    Sleep(RandomInt(25, 100))
    Click("Up")
    ClickCount++

    if (RandomInt(1, 100) <= HumanErrorRate) {
        switch RandomInt(1, 3) {
            case 1:
                MouseMove(tx + RandomInt(-5,5), ty + RandomInt(-5,5), 4)
                Sleep(100 + RandomnessLevel)
                MouseMove(tx, ty, 4)
                Sleep(60)
                Click()
            case 2:
                Sleep(60 + RandomnessLevel // 2)
                Click()
            default:
                Sleep(300 + RandomnessLevel)
        }
    }

    FatigueLevel += RandomInt(1, FatigueDriftRadius // 5)
    FatigueLevel := Min(FatigueLevel, 100)

    if (RandomInt(1, 100) < 10 + FatigueLevel // 10)
        Sleep(500 + RandomnessLevel * 2)

    ; Use original script's humanized delay, then apply the click speed percent (slower)
    delay := GetHumanDelay() * ClickSpeedPercent

    ; Handle break logic
    global NextBreakTime
    if (NextBreakTime > 0) {
        NextBreakTime -= delay // 1000
        if (NextBreakTime <= 0) {
            Sleep(RandomInt(5000, 15000)) ; Take a break for 5-15 seconds
            NextBreakTime := RandomInt(60, 180)
        }
    }

    SetTimer(ClickLoop, -Max(delay, 50))
}

GetHumanDelay() {
    global ClickingRhythm, RhythmDuration, RhythmProgress

    BaseClickDelay := 150
    FatigueEffect := 1.0 + (FatigueLevel * 0.01)
    AdjustedBaseDelay := BaseClickDelay * FatigueEffect

    RhythmProgress++
    if (RhythmProgress >= RhythmDuration) {
        Random, ClickingRhythm, 0, 5
        Random, RhythmDuration, 8, 22
        RhythmProgress := 0
    }

    if (ClickingRhythm == 0) {
        Random, Delay, % (AdjustedBaseDelay * 0.8), % (AdjustedBaseDelay * 1.3)
    } else if (ClickingRhythm == 1) {
        Random, Delay, % (AdjustedBaseDelay * 0.7), % (AdjustedBaseDelay * 1.1)
    } else if (ClickingRhythm == 2) {
        Random, Delay, % (AdjustedBaseDelay * 1.2), % (AdjustedBaseDelay * 2.2)
    } else if (ClickingRhythm == 3) {
        Random, Delay, % (AdjustedBaseDelay * 0.5), % (AdjustedBaseDelay * 3.0)
    } else if (ClickingRhythm == 4) {
        if (Mod(RhythmProgress, 3) == 0) {
            Random, Delay, % (AdjustedBaseDelay * 0.4), % (AdjustedBaseDelay * 0.7)
        } else {
            Random, Delay, % (AdjustedBaseDelay * 1.5), % (AdjustedBaseDelay * 2.5)
        }
    } else {
        if (Mod(RhythmProgress, 7) == 0) {
            Random, Delay, % (AdjustedBaseDelay * 2.5), % (AdjustedBaseDelay * 4.0)
        } else {
            Random, Delay, % (AdjustedBaseDelay * 0.9), % (AdjustedBaseDelay * 1.1)
        }
    }
    return Round(Delay)
}

MoveBezier(x2, y2, cx1, cy1, cx2, cy2) {
    MouseGetPos(&x1, &y1)
    steps := 20
    loop steps {
        t := A_Index / steps
        xt := (1-t)**3*x1 + 3*(1-t)**2*t*cx1 + 3*(1-t)*t**2*cx2 + t**3*x2
        yt := (1-t)**3*y1 + 3*(1-t)**2*t*cy1 + 3*(1-t)*t**2*cy2 + t**3*y2
        MouseMove(xt, yt, 1)
        Sleep(5 + RandomInt(0,8))
    }
}

Gaussian(mean, stddev) {
    static haveSpare := false, rand1, rand2
    if (haveSpare) {
        haveSpare := false
        return Floor(mean + stddev * rand2)
    }
    u := Random(0.0, 1.0)
    v := Random(0.0, 1.0)
    s := Sqrt(-2 * Log(u)) * Cos(2 * 3.14159265359 * v)
    rand2 := Sqrt(-2 * Log(u)) * Sin(2 * 3.14159265359 * v)
    rand1 := s
    haveSpare := true
    return Floor(mean + stddev * rand1)
}

RandomInt(min, max) => Random(min, max)

UpdateStats() {
    global ClickCount, SessionStart, SessionEnd, IsRunning, StatText, TimeText
    global TotalRunTime, NextBreakTime, NextBreakText, TotalRunText
    global MinRuntimeSlider, MaxRuntimeSlider

    if (IsRunning) {
        elapsed := (A_TickCount - SessionStart) // 1000
        TotalRunTime += 0.5 ; since UpdateStats runs every 500ms
        TimeText.Value := "Elapsed: " (elapsed//60) "m " Mod(elapsed,60) "s"
        StatText.Value := "Clicks: " ClickCount
        TotalRunText.Value := "Total run time: " Floor(TotalRunTime) "s"
        if (NextBreakTime > 0) {
            NextBreakText.Value := "Next break in: " NextBreakTime "s"
        } else {
            NextBreakText.Value := "No break scheduled"
        }
        minr := MinRuntimeSlider.Value
        maxr := MaxRuntimeSlider.Value
        txt := ""
        if minr > 0
            txt .= "Min: " minr "min  "
        if maxr > 0
            txt .= "Max: " maxr "min"
        if !txt
            txt := "No runtime limits"
        global RuntimeLimitsText
        RuntimeLimitsText.Value := txt
    } else if (SessionEnd) {
        elapsed := (SessionEnd - SessionStart) // 1000
        TimeText.Value := "Session: " (elapsed//60) "m " Mod(elapsed,60) "s"
    }
}

SetCustomHotkeys(*) {
    global Hotkey1, Hotkey1Ctrl, prevHotkey1
    Hotkey1 := Hotkey1Ctrl.Value
    if prevHotkey1
        Hotkey(prevHotkey1, "", "Off")
    if Hotkey1
        Hotkey(Hotkey1, ToggleAutoClicker)
    prevHotkey1 := Hotkey1
}

ToggleAutoClicker(*) {
    global IsRunning, MinRuntimeSlider, SessionStart
    if IsRunning {
        elapsed := (A_TickCount - SessionStart) // 1000
        minr := MinRuntimeSlider.Value * 60
        if minr > 0 && elapsed < minr
            return ; Don't allow stop before min runtime
        StopSession()
    } else {
        StartSession()
    }
}

CreateGui()
MyGui.OnEvent("Close", (*) => ExitApp())
