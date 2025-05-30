#SingleInstance Force
SetTitleMatchMode(2)
CoordMode("Mouse", "Screen")

global GuiCreated := false
global IsRunning := false
global HumanErrorRate := 8
global FatigueLevel := 0
global FatigueDriftRadius := 10
global RandomnessLevel := 50
global DarkMode := false
global ClickCount := 0
global SessionStart := 0
global SessionEnd := 0

global MyGui, StartButton, StopButton
global RandomnessSlider, HumanErrorSlider, FatigueSlider
global StatText, TimeText, NextBreakText, TotalRunText
global Hotkey1Ctrl
global Hotkey1 := "CapsLock"
global prevHotkey1 := ""

global FixedX := 0
global FixedY := 0
global TotalRunTime := 0
global NextBreakTime := 0

CreateGui() {
    global GuiCreated, MyGui, StartButton, StopButton
    global RandomnessSlider, HumanErrorSlider, FatigueSlider
    global StatText, TimeText, Hotkey1Ctrl, NextBreakText, TotalRunText

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

    ; Humanization - improved section
    MyGui.Add("GroupBox", "x10 y120 w350 h140", "Humanization Settings")
    MyGui.Add("Text", "x25 y145 w120 h20", "Randomness (1-100):")
    RandomnessSlider := MyGui.Add("Slider", "x150 y145 w160 h20 Range1-100", 50)
    MyGui.Add("Text", "x25 y175 w120 h20", "Error Rate (0-20):")
    HumanErrorSlider := MyGui.Add("Slider", "x150 y175 w160 h20 Range0-20", 8)
    MyGui.Add("Text", "x25 y205 w120 h20", "Fatigue Drift (1-30):")
    FatigueSlider := MyGui.Add("Slider", "x150 y205 w160 h20 Range1-30", 10)
    MyGui.Add("Text", "x25 y235 w300 h40", "Adjust these to simulate human-like clicking. " 
        . "Higher randomness and error rate increase variability. Fatigue affects click precision.")

    ; Stats
    MyGui.Add("GroupBox", "x10 y340 w350 h120", "Stats")
    StatText := MyGui.Add("Text", "x25 y365 w320 h20", "Not started.")
    TimeText := MyGui.Add("Text", "x25 y390 w320 h20")
    TotalRunText := MyGui.Add("Text", "x25 y415 w320 h20", "Total run time: 0s")
    NextBreakText := MyGui.Add("Text", "x25 y440 w320 h20", "Next break: N/A")

    MyGui.Show("w370 h470")
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

StartSession(*) {
    global IsRunning, ClickCount, SessionStart, SessionEnd
    global RandomnessSlider, HumanErrorSlider, FatigueSlider, StartButton, StopButton
    global FixedX, FixedY, NextBreakTime, TotalRunTime

    if (IsRunning)
        return

    MouseGetPos(&FixedX, &FixedY)
    IsRunning := true
    ClickCount := 0
    SessionStart := A_TickCount
    SessionEnd := 0
    NextBreakTime := RandomInt(60, 180) ; Next break between 1-3 minutes
    TotalRunTime := 0

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
    global IsRunning, RandomnessSlider, HumanErrorSlider, FatigueSlider
    global FatigueLevel, ClickCount
    global RandomnessLevel, HumanErrorRate, FatigueDriftRadius
    global FixedX, FixedY, NextBreakTime

    if (!IsRunning)
        return

    RandomnessLevel := RandomnessSlider.Value
    HumanErrorRate := HumanErrorSlider.Value
    FatigueDriftRadius := FatigueSlider.Value

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

    delay := Gaussian(200, 80 + RandomnessLevel)
    SetTimer(ClickLoop, -Max(delay, 50))

    ; Handle break logic
    global NextBreakTime
    if (NextBreakTime > 0) {
        NextBreakTime -= delay // 1000
        if (NextBreakTime <= 0) {
            Sleep(RandomInt(5000, 15000)) ; Take a break for 5-15 seconds
            NextBreakTime := RandomInt(60, 180)
        }
    }
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
    global IsRunning
    if IsRunning
        StopSession()
    else
        StartSession()
}

CreateGui()
MyGui.OnEvent("Close", (*) => ExitApp())
