-- globals for bindings
BINDING_HEADER_TTELL = "TTell";
BINDING_NAME_TELLTARGET = "Whisper Target";

-- slash commands
SlashCmdList["TTELL_TELLTARGET"] = function(message)
    TTell_TellTarget(message);
end
SLASH_TTELL_TELLTARGET1 = "/tt";
SLASH_TTELL_TELLTARGET2 = "/wt";

SlashCmdList["TTELL_RETELL"] = function(message)
    TTell_ReTell(message);
end
SLASH_TTELL_RETELL1 = "/rt";
SLASH_TTELL_RETELL2 = "/rtt";

local function TTell_OnSpacePressed(editBox)
    local editBoxText = strlower(editBox:GetText());

    -- optimization
    if (editBoxText:sub(1, 1) ~= "/" or editBoxText:len() > 5) then
        return;
    end

    -- match commands
    if (editBoxText:match("^/[tw]t $")) then
        TTell_TellTarget();
    elseif (editBoxText:match("^/rtt? $")) then
        TTell_ReTell();
    end
end

-- hook ChatEdit_OnSpacePressed function
hooksecurefunc("ChatEdit_OnSpacePressed", TTell_OnSpacePressed);

local function TTell_GetSelectedChatFrame()
    if (SELECTED_CHAT_FRAME.editBox:IsShown()) then
        return SELECTED_CHAT_FRAME;
    end

    -- floating SELECTED_CHAT_FRAME bug
    for i = 0, NUM_CHAT_WINDOWS do
        local chatFrame = getglobal("ChatFrame" .. i);
        if (chatFrame ~= nil and chatFrame.editBox:IsShown()) then
            --print("SELECTED_CHAT_FRAME should be ChatFrame" .. i .. " was ChatFrame" .. SELECTED_CHAT_FRAME:GetID());
            return chatFrame;
        end
    end
end

local function TTell_AddOnMessage(message)
    local chatFrame = TTell_GetSelectedChatFrame();

    chatFrame:AddMessage("|c440099ff[TTell]|cff00ffff " .. message);
end

local function TTell_GetTargetName()
    local name, realm = UnitName("target");

    if (realm ~= nil and realm:len() > 0) then
        --local realm = realm:gsub("%s", "");
        return string.join("-", name, realm);
    end

    return name;
end

local function TTell_NewMessage(tellTarget, message)
    if (message == nil) then
        local editBox = TTell_GetSelectedChatFrame().editBox;

        editBox:SetAttribute("tellTarget", tellTarget);
        editBox:SetAttribute("chatType", "WHISPER");
        editBox.setText = 1;
        editBox.text = "";
        editBox:SetFocus();

        ChatEdit_UpdateHeader(editBox);
    else
        SendChatMessage(message, "WHISPER", GetDefaultLanguage("player"), tellTarget);
        ChatEdit_SetLastToldTarget(tellTarget);
    end
end

function TTell_TellTarget(message)
    if (UnitIsPlayer("target") and UnitIsFriend("player", "target")) then
        local tellTarget = TTell_GetTargetName();
        TTell_NewMessage(tellTarget, message);
    else
        TTell_AddOnMessage("missing or invalid target.");
    end
end

function TTell_ReTell(message)
    local lastTold = ChatEdit_GetLastToldTarget();
    if (lastTold ~= "") then
        TTell_NewMessage(lastTold, message);
    else
        TTell_AddOnMessage("no previous tell target.");
    end
end
