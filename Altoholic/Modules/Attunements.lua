--[[
    Lua 5.1 Copyright (C) 1994-2006 Lua.org, PUC-Rio
]]

local L = AceLibrary("AceLocale-2.2"):new("Altoholic")
local V = Altoholic.vars
local WHITE		= "|cFFFFFFFF"
local GREEN		= "|cFF00FF00"
local TEAL		= "|cFF00FF9A"
local YELLOW	= "|cFFFFFF00"
local ORANGE	= "|cFFFF7F00"


local attunements = {
	{	id = "0",     name = "Dungeons", collapsed = false },
	{   id = "7046",  name = "Maraudon Princess", item = "The Scepter of Celebras"   },
	{   id = "5505", name = "Scholomance", item = "The Key to Scholomance" },
	{   id = "40316", name = "Karazan Crypt (A)", item = "Karazan Crypt Key" },
	{   id = "40309", name = "Karazan Crypt (H)", item = "Karazan Crypt Key" },

	{   id = "0",     name = "Raids" , collapsed = false },
	{   id = "4743",  name = "Upper BRS", item = "Seal of Ascension" },
	{	id = "7848",  name = "Molten Core", item = ""  },
	{	id = "6502",  name = "Onyxia's Lair", item = "Drakefire Amulet"  },
	{	id = "7761",  name = "Blackwing Lair", item = "" },
	{   id = "40962", name = "Emerald Sanctum", item = "Gemstone of Ysera" },
	{   id = "9378",  name = "Naxxramas", item = "" },
	{   id = "40829", name = "Upper Karazan", item = "Upper Karazen Tower Key" },

	{   id = "0",     name = "Boss organ turn ins", collapsed = false },
	{	id = "7496",  name = "Onyxia's Head (A)",  item = "" },
	{	id = "7491",  name = "Onyxia's Head (H)",  item = "" },
	{	id = "8183",  name = "The Heart of Hakkar", item = "" },
	{   id = "8791",  name = "The Head of Ossirian", item = "" },
	{	id = "7781",  name = "Head of Nefarian (A)",  item = "" },
	{	id = "7783",  name = "Head of Nefarian (H)",  item = "" },
	{	id = "8802",  name = "Eye of C'thun",  item = "" },
	{	id = "40963",  name = "Head of Solnius",  item = "" },
	{	id = "41038",  name = "The Claw of Erennius",  item = "" },

}

function Altoholic:Attunements_Update()

	local VisibleLines = 11
	local frame = "AltoAttunements"
	local entry = frame.."Entry"
	-- ** draw class icons **
	local i = 1

	local byLevel = Altoholic:Get_Sorted_Character_List(V.faction, V.realm)
	for _, CharacterName in byLevel do
		-- DEFAULT_CHAT_FRAME:AddMessage("Handling "..CharacterName)
		local c = self.db.account.data[V.faction][V.realm].char[CharacterName]
		local itemName = "AltoAttunementsClassesItem" .. i;
		local itemButton = getglobal(itemName);
		-- Only buttons for 10 columns defined; so we stop when buttons stop being defined
		if itemButton == nil then break end
		itemButton:SetScript("OnEnter", Altoholic_Attunements_OnEnter)
		itemButton:SetScript("OnLeave", function(self) AltoTooltip:Hide() end)
		itemButton:SetScript("OnClick", Altoholic_Equipment_OnClick)
		local tc = self.ClassInfo[ self.Classes[c.class] ].texcoord
		local itemTexture = getglobal(itemName .. "IconTexture")
		itemTexture:SetTexture(self.classicon);
		itemTexture:SetTexCoord(tc[1], tc[2], tc[3], tc[4]);
		itemTexture:SetWidth(36);
		itemTexture:SetHeight(36);
		itemTexture:SetAllPoints(itemButton);
		itemButton.CharName = CharacterName
		getglobal(itemName):Show()
		i = i + 1
	end
	while i <= 10 do
		getglobal("AltoAttunementsClassesItem" .. i):Hide()
		getglobal("AltoAttunementsClassesItem" .. i).CharName = nil
		i = i + 1
	end

	getglobal(entry .. "1"):Show()
	getglobal(entry .. "1"):SetID(0)
	-- ** draw factions **
	local offset = FauxScrollFrame_GetOffset(getglobal(frame.."ScrollFrame"));
	local DisplayedCount = 0
	local VisibleCount = 0
	local DrawAttuneGroup
	i=1
	for lineno, line in attunements do
		if line["id"] == "0" then
			DrawAttuneGroup = not line.collapsed
		end
		-- DEFAULT_CHAT_FRAME:AddMessage("Processing "..ORANGE..line.id .. " " .. YELLOW .. line.name .. WHITE.." draw="..(DrawAttuneGroup and "yes" or "no"))
		if offset > 0 or DisplayedCount >= VisibleLines then
			-- hidden line; just update counters. Lines that are no headers don't
			-- count if the header is collapsed.
			if line["id"] == "0" or DrawAttuneGroup then
				VisibleCount = VisibleCount + 1
				offset = offset - 1
			end
		else
			if line.id == "0" then
				if line.collapsed then
					getglobal(entry..i.."Collapse"):SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				else
					getglobal(entry..i.."Collapse"):SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
				end
				getglobal(entry..i.."Collapse"):Show()
				getglobal(entry..i.."Name"):SetText(line.name)
				getglobal(entry..i.."Name"):SetJustifyH("LEFT")
				getglobal(entry..i.."Name"):SetPoint("TOPLEFT", 25, 0)
				getglobal(entry..i):SetID(lineno)
				getglobal(entry..i):Show()
				for j=1, 10 do		-- hide the 10 characters
					itemButton = getglobal(entry.. i .. "Item" .. j);
					itemButton.CharName = nil
					itemButton:Hide()
				end
				i = i + 1
				VisibleCount = VisibleCount + 1
				DisplayedCount = DisplayedCount + 1
			elseif DrawAttuneGroup then
				getglobal(entry..i.."Collapse"):Hide()
				getglobal(entry..i.."Name"):SetText(WHITE .. line.name)
				getglobal(entry..i.."Name"):SetJustifyH("RIGHT")
				getglobal(entry..i.."Name"):SetPoint("TOPLEFT", 15, 0)
				local j = 1
				for _, CharacterName in byLevel do
					c = self.db.account.data[V.faction][V.realm].char[CharacterName]
					local itemName = entry.. i .. "Item" .. j;
					local itemButton = getglobal(itemName);
                    if itemButton == nil then break end
					if c.CompletedQuests and c.CompletedQuests[line.id] then
						getglobal(itemName .. "Name"):SetText("ok")
						itemButton.CharName = CharacterName
						itemButton:Show()
					else
						itemButton.CharName = nil
						itemButton:Hide()
					end
					j = j + 1
				end
				-- DEFAULT_CHAT_FRAME:AddMessage("Line "..i.." has attunement line "..lineno)
				getglobal(entry..i):SetID(lineno)
				getglobal(entry..i):Show()
				i = i + 1
				VisibleCount = VisibleCount + 1
				DisplayedCount = DisplayedCount + 1
			end
		end
	end
	while i <= VisibleLines do
		getglobal(entry..i):SetID(0)
		getglobal(entry..i):Hide()
		i = i + 1
	end
	FauxScrollFrame_Update(getglobal(frame.."ScrollFrame"), VisibleCount, VisibleLines, 41);

end

function Altoholic:Attunements_Toggle(id)
	-- DEFAULT_CHAT_FRAME:AddMessage("rowID is "..id)
	attunements[id].collapsed = not attunements[id].collapsed
end

function Altoholic_Attunements_OnEnter()
    if not this then return end
	local rowID = this:GetParent():GetID()
	if rowID == 0 then		-- class icon
		V.CurrentFaction = V.faction
		V.CurrentRealm = V.realm
		Altoholic:DrawCharacterTooltip(this.CharName)
		return
	end
	local r = Altoholic.db.account.data[V.faction][V.realm]
	-- DEFAULT_CHAT_FRAME:AddMessage("rowID is "..rowID)
	local attune = attunements[rowID]
	local charName = this.CharName
	local c = Altoholic.db.account.data[V.faction][V.realm].char[charName]

	AltoTooltip:SetOwner(this, "ANCHOR_LEFT");
	AltoTooltip:ClearLines();
	AltoTooltip:AddLine(Altoholic:GetClassColor(c.class) .. charName .. WHITE .. " @ " .. V.realm, 1, 1, 1);
	AltoTooltip:AddLine("completed this quest (id "..attune.id .. ")",1,1,1);
	if (attune.item and attune.item ~= "") then
		AltoTooltip:AddLine(TEAL .. attune.item, 1, 1, 1);
	else
		AltoTooltip:AddLine("No item needed", 1, 1, 1);
	end
	AltoTooltip:Show();
end

function Altoholic_Attunements_OnClick()
end
