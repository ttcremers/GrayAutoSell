--[[
	GrayAutoSell
	Revision: $Id$
	Version: 0.1.4
	By: Thomas T. Cremers <ttcremers@gmail.com> 7-7-2017

	This is an addon for World of Warcraft that automatically sells poor 
	gray items in your bags as soon as you open a merchant dialog. It's
	developed specifically for patch 1.12 (vanilla wow) 

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]

-- If set to true logs debugging info to the chat window if  
-- marchant window opens and doesn't actually sell the item
local DEBUG = false
local SELL  = true

-- FILA pool of gray items in bag location ({bagnr, slotnr})
grayItemPool = {}

-- Reusable frame for timed FILA pool processing (Frames don't know of GC)
local poolRunnerFrame = CreateFrame("Frame");

-- We don't want to kill the game client by a sell DOS
-- Time (seconds) between sell of every gray item. 
local sellDelay = 0.2

-- Process the pool on a timer until it's empty
local function poolRunner()
	debug("Pool runner started at: "..GetTime());
    local endTime = GetTime() + sellDelay;

    poolRunnerFrame:SetScript("OnUpdate", function()
        
		if ( endTime < GetTime() ) then

			-- Pop an from the pool
			local e = table.remove(grayItemPool)

			-- If we have an item process it otherwise stop the runner
			if e then
				debug("Processing, bag: "..e.bag.." slot: "..e.slot)

				-- We don't want to go out every time to collect gray items
				if SELL then
					-- Use with a merchant window open will sell the item
					UseContainerItem(e.bag, e.slot);					
				else
					debug("NOT SOLD, SELL=false")
				end
			else -- Pool exausted stop the runner				
            	poolRunnerFrame:SetScript("OnUpdate", nil);
				debug("Pool runner finished at: "..GetTime());
			end

        end

    end);
end

function caInit()
	-- Notify the user that we're doing something 
    DEFAULT_CHAT_FRAME:AddMessage("Loading GrayAutoSell v0.1.4 'I supply only the finest goods!'");
	
	-- Listen for merchant interaction (window opening)
	this:RegisterEvent("MERCHANT_SHOW");
end

function caEvent()
	if event=="MERCHANT_SHOW" then

		-- Loop over all bagslots and push gray items into the pool
		for bag = 0, NUM_BAG_SLOTS do
			for slot = 1, GetContainerNumSlots(bag) do
				local itemLink = GetContainerItemLink(bag, slot)
				
				if itemLink ~= nil then
					local _, _, itemID = strfind(itemLink, "item:(%d+):")
					local name, _, rarity, _, _, _, _, _, _ = GetItemInfo(itemID)
					
					-- Rarity of 0 means this is a gray item
					if rarity == 0 then
						debug("Poor item found: "..name)
						
						-- Gray item found insert it into the pool
						table.insert(grayItemPool, {bag = bag, slot = slot})																		
					end
			
				end			
			end
		end
		
		debug("Gray items found in bag: " .. table.getn(grayItemPool));		
		-- Start pool runner
		poolRunner();

	end
end

function debug(text)
	if DEBUG then
		DEFAULT_CHAT_FRAME:AddMessage(text)
	end
end
