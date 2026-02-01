local HCBframe = nil
local HCBActivateChat = ChatEdit_ActivateChat

if not HCBframe then
    HCBframe = CreateFrame("Button", "HCBframe", UIParent, "UIPanelButtonTemplate")
    HCBframe:SetClampedToScreen(true)
    HCBframe:SetMovable(true)
    HCBframe:EnableMouse(true)
    HCBframe:RegisterForDrag("RightButton")
    HCBframe:SetScript("OnDragStart", HCBframe.StartMoving)
    HCBframe:SetScript("OnDragStop", HCBframe.StopMovingOrSizing)
    HCBframe:SetWidth(24)
    HCBframe:SetHeight(24)
    HCBframe:SetPoint("BOTTOMLEFT", HCBxpos or 0, HCBypos or 0)
    HCBframe.ChatIsShown = true
    HCBframe.ActiveTabs = {[1] = true}
    HCBkeyable = HCBkeyable or false
    HCBchatIsShown = HCBchatIsShown or true
    HCBframe:EnableMouseWheel(true)
end

HCBframe.ToggleKeyable = function(frame)
    if HCBkeyable == false then
        HCBkeyable = true
    else
        HCBkeyable = false
    end
    HCBframe:Paint()
end

HCBframe.Paint = function(frame, text)
    HCBframe:SetAlpha(HCBkeyable and 1.0 or .25)
    HCBframe:SetText(text or "")
end

HCBframe.RestoreDefaults = function(frame)
    HCBkeyable = true
    HCBxpos = 0
    HCBypos = 0
    HCBframe:ClearAllPoints()
    HCBframe:SetPoint("BOTTOMLEFT", HCBxpos, HCBypos)
    HCBframe:Paint()
end

HCBframe.HideChat = function(frame)
    for i = 1, NUM_CHAT_WINDOWS do
        local f = _G["ChatFrame"..i]
        if f then
            if f.isTemporary then
                frame.ActiveTabs[i] = false
            elseif f:IsVisible() then
                frame.ActiveTabs[i] = true
                f:Hide()
            else
                frame.ActiveTabs[i] = false
            end
            f.HCBOverrideShow = f.Show
            f.Show = f.Hide
        end
    end
    
    if GeneralDockManager then
        GeneralDockManager.HCBOverrideShow = GeneralDockManager.Show
        GeneralDockManager.Show = GeneralDockManager.Hide
        GeneralDockManager:Hide()
    end
    
    for i = 1, NUM_CHAT_WINDOWS do
        local f = _G["ChatFrame"..i.."Tab"]
        if f then
            if frame.ActiveTabs[i] == true and f:IsVisible() then
                f:Hide()
            end
            f.HCBOverrideShow = f.Show
            f.Show = f.Hide
        end
    end
    
    if ChatFrameMenuButton then
        ChatFrameMenuButton:Hide()
    end
    
    if QuickJoinToastButton then
        QuickJoinToastButton:Hide()
    end
    
    frame.ChatIsShown = false
end

HCBframe.ShowChat = function(frame)
    if GeneralDockManager then
        GeneralDockManager.Show = GeneralDockManager.HCBOverrideShow
        GeneralDockManager:Show()
    end
    
    if ChatFrameMenuButton then
        ChatFrameMenuButton:Show()
    end
    
    if QuickJoinToastButton then
        QuickJoinToastButton:Show()
    end

    for i = 1, NUM_CHAT_WINDOWS do
        local f = _G["ChatFrame"..i]
        if f then
            f.Show = f.HCBOverrideShow
            if not f.isTemporary and frame.ActiveTabs[i] == true then
                f:Show()
            end
        end
        
        local tab = _G["ChatFrame"..i.."Tab"]
        if tab then
            tab.Show = tab.HCBOverrideShow
            if frame.ActiveTabs[i] == true then
                tab:Show()
            end
        end
    end
    
    frame.ChatIsShown = true
end

HCBframe.ToggleVisible = function(frame)
    if HCBframe.ChatIsShown == false then
        HCBframe:ShowChat()
    else
        HCBframe:HideChat()
    end
    HCBframe:Paint()
end

HCBframe:SetScript("OnMouseUp", function(frame, button)
    if IsControlKeyDown() then
        HCBframe:RestoreDefaults()
    elseif IsShiftKeyDown() then
        HCBframe:ToggleKeyable()
    elseif button == "LeftButton" then
        HCBframe:ToggleVisible()
    end
end)

HCBframe:SetScript("OnMouseWheel", function(frame, delta)
    if IsShiftKeyDown() then
        HCBframe.ToggleKeyable()
    else
        HCBframe.ToggleVisible()
    end
end)

function ChatEdit_ActivateChat(frame)
    if HCBkeyable == true and HCBframe.ChatIsShown == false then
        HCBframe:ToggleVisible()
    end
    HCBActivateChat(frame)
end

function RenderChatOnStartup(frame)
    if HCBchatIsShown == false then
        HCBframe:ToggleVisible()
    end
end

HCBframe:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
HCBframe:RegisterEvent("CHAT_MSG_GUILD")
HCBframe:RegisterEvent("CHAT_MSG_OFFICER")
HCBframe:RegisterEvent("CHAT_MSG_PARTY")
HCBframe:RegisterEvent("CHAT_MSG_PARTY_LEADER")
HCBframe:RegisterEvent("CHAT_MSG_RAID")
HCBframe:RegisterEvent("CHAT_MSG_RAID_LEADER")
HCBframe:RegisterEvent("CHAT_MSG_WHISPER")
HCBframe:RegisterEvent("ADDON_LOADED")
HCBframe:RegisterEvent("PLAYER_LOGOUT")

HCBframe.OnEvent = function(frame, event, ...)
    local eventcolors = {
        CHAT_MSG_BG_SYSTEM_NEUTRAL = "cc6633B",
        CHAT_MSG_GUILD = "66cc00G",
        CHAT_MSG_OFFICER = "66cc00O",
        CHAT_MSG_PARTY = "6666FFP",
        CHAT_MSG_PARTY_LEADER = "6666FFP",
        CHAT_MSG_RAID = "cc6600R",
        CHAT_MSG_RAID_LEADER = "cc6600R",
        CHAT_MSG_WHISPER = "ff00ffW",
    }
    
    if HCBframe.ChatIsShown == false and eventcolors[event] then
        HCBframe:Paint("|cff" .. eventcolors[event] .. "|r")
    elseif event == "ADDON_LOADED" then
        HCBframe:Paint()
        RenderChatOnStartup()
    elseif event == "PLAYER_LOGOUT" then
        HCBchatIsShown = HCBframe.ChatIsShown
    end
end

HCBframe:SetScript("OnEvent", HCBframe.OnEvent)

BINDING_HEADER_HIDECHATBUTTON = "Hide Chat Button"
BINDING_NAME_HCB_TOGGLE = "Toggle Chat Visibility"