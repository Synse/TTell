-- binding variables
BINDING_HEADER_TTELL = "TTell"
BINDING_NAME_TELLTARGET = "Whisper Target"

-- local variables
local version = GetAddOnMetadata("TTell", "Version");

function TTell_OnLoad(self)
	-- register slash commands
	SlashCmdList["TTELL_TELLTARGET"] = function(message)
		TTell_TellTarget(message);
	end
	SLASH_TTELL_TELLTARGET1 = "/tt"
	SLASH_TTELL_TELLTARGET2 = "/wt"

	SlashCmdList["TTELL_RETELL"] = function(message)
		TTell_ReTell(message);
	end
	SLASH_TTELL_RETELL1 = "/rt"

	-- hook editBox OnSpacePressed
	hooksecurefunc("ChatEdit_OnSpacePressed", TTell_OnSpacePressed);

	-- register events
	--self:RegisterEvent("ADDON_LOADED"); -- currently only used for debugging
end

function TTell_OnEvent(self, event, ...)
	if (event == "ADDON_LOADED") then
		local addonName = select(1, ...);
		if (addonName == "TTell") then
			TTell_AddOnMessage("version " .. version .. " loaded.");
		end
		return
	end
end

function TTell_OnSpacePressed()
	local editBoxText = strlower(DEFAULT_CHAT_FRAME.editBox:GetText());

	-- prevent unnecessary matching attempts
	if (editBoxText:sub(1, 1) ~= "/"  or editBoxText:len() > 4) then
		return
	end

	-- search for a match
	if (editBoxText:match("^/[tw]t $")) then
		TTell_TellTarget();
	elseif (editBoxText:match("^/rt $")) then
		TTell_ReTell();
	else
		return
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

function TTell_NewMessage(tellTarget, message)
	if (message == nil) then
		DEFAULT_CHAT_FRAME.editBox:Hide();
		DEFAULT_CHAT_FRAME.editBox:SetAttribute("chatType", "WHISPER");
		DEFAULT_CHAT_FRAME.editBox:SetAttribute("tellTarget", tellTarget);
		if (not DEFAULT_CHAT_FRAME.editBox:IsShown()) then
			DEFAULT_CHAT_FRAME.editBox:Show();
			DEFAULT_CHAT_FRAME.editBox.setText = 1;
			DEFAULT_CHAT_FRAME.editBox.text = "";
		end
	else
		SendChatMessage(message, "WHISPER", GetDefaultLanguage("player"), tellTarget);
		ChatEdit_SetLastToldTarget(tellTarget);
	end
end

function TTell_GetTargetName()
	local name, realm = UnitName("target");
	if (realm ~= nil) then
		local realm = realm:gsub("%s", "");
		return string.join("-", name, realm);
	end
	return name;
end

function TTell_AddOnMessage(message)
	DEFAULT_CHAT_FRAME:AddMessage("|c440099ff[TTell]|cff00ffff " .. message);
end