if not AruLib then
    print("|cffff0000AruPortHelper richiede AruLib. Installa AruLib e riavvia.|r")
    return
end

local frame = CreateFrame("Frame", "AruPortHelperFrame", UIParent)
frame:SetSize(300, 200)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0, 0, 0, 0.8)
frame:Hide()

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -10)
title:SetText("AruPortHelper - Stub API Calls")

local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -30)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

local editBox = CreateFrame("EditBox", nil, scrollFrame)
editBox:SetMultiLine(true)
editBox:SetMaxLetters(0)
editBox:SetFontObject(ChatFontNormal)
editBox:SetWidth(260)
editBox:SetHeight(140)
editBox:SetAutoFocus(false)
scrollFrame:SetScrollChild(editBox)

local function UpdateDisplay()
    local lines = {}
    for api, count in pairs(AruLib.unavailable) do
        table.insert(lines, api .. " (" .. count .. " calls)")
    end
    if #lines == 0 then
        editBox:SetText("No stub API calls detected.")
    else
        table.sort(lines)
        editBox:SetText(table.concat(lines, "\n"))
    end
end

local updater = CreateFrame("Frame")
updater:SetScript("OnUpdate", function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    if self.timer >= 1 then
        UpdateDisplay()
        self.timer = 0
    end
end)

SLASH_ARUPORTHELPER1 = "/aph"
SlashCmdList["ARUPORTHELPER"] = function(msg)
    local cmd, rest = msg:match("^(%S*)%s*(.-)$")
    if cmd == "show" then
        frame:Show()
        UpdateDisplay()
    elseif cmd == "hide" then
        frame:Hide()
    elseif cmd == "reset" then
        for api in pairs(AruLib.unavailable) do
            AruLib.unavailable[api] = nil
        end
        UpdateDisplay()
        print("AruPortHelper: counters reset.")
    elseif cmd == "dump" then
        local report = {}
        for api, count in pairs(AruLib.unavailable) do
            table.insert(report, api .. ": " .. count)
        end
        table.sort(report)
        if #report == 0 then
            print("AruPortHelper: No stub API calls detected.")
        else
            print("AruPortHelper - Stub API Report:")
            for _, line in ipairs(report) do
                print("  " .. line)
            end
        end
    else
        print("Usage: /aph [show|hide|reset|dump]")
    end
end
