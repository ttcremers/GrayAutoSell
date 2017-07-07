--[[
	GrayAutoSell
	Revision: $Id$
	Version: 0.1.0
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
DEBUG = false

function caInit()
	-- Notify the user that we're doing something 
    DEFAULT_CHAT_FRAME:AddMessage("Loading GrayAutoSell");

	-- Listen for merchant interaction (window opening)
	this:RegisterEvent("MERCHANT_SHOW");
end

function caEvent()
	if event=="MERCHANT_SHOW" then
		for bag = 0,0 do
			for slot = 1, GetContainerNumSlots(bag) do
				local itemLink = GetContainerItemLink(bag, slot)
				
				if itemLink ~= nil then
					local _, _, itemID = strfind(itemLink, "item:(%d+):")
					local name, _, rarity, _, _, _, _, _, _ = GetItemInfo(itemID)
					
					-- Rarity of 0 means this is a gray item
					if rarity == 0 then
						debug("Poor item found: "..name)
						
						-- Auto sells the item when merchant window is open
						if not DEBUG then
							UseContainerItem(bag,slot)
						else
							debug("NOT SOLD: debug enabled")
						end
					end
			
				end			
			end
		end
	end
end

function debug(text)
	if DEBUG then
		DEFAULT_CHAT_FRAME:AddMessage(text)
	end
end