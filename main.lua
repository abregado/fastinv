local font = love.graphics.newFont(30)
local fontsml = love.graphics.newFont(15)
love.graphics.setFont(font)


ground = {}

types = {
	"belt",
	"helmet",
	"glasses",
	"visor",
	"gloves",
	"earpiece",
	"gun",
	"backpack",
	"clothing",
	"hat",
	"armor",
	"shoes",
	"boots",
	"tool",
	"pda",
	"satchel",
	"jetpack",
	"card",
	"anytype",
	"mask",
	"canister",
	"ammunition",
	"box"
	}

sizes = {
	"small",
	"large",
	"anysize"
	}
	
intents = {
	{name="help",val=1},
	{name="grab",val=2},
	{name="disarm",val=3},
	{name="harm",val=4}
}

lethalWeapon = {0,1,1,5}
stunWeapon = {0,5,5,2}
improvWeapon = {0,1,1,1}
safeWorkItem = {1,0,0,0}
dangerWorkItem = {1,1,1,1}
lethalWorkItem = {1,1,2,3}
healingItem = {5,2,2,0}
oftenUsed = {2,2,2,2}
defaultUse = {0,0,0,0}


function love.load()

	player = newSlotFolder("Player")
	
	
	--belt = player:addSlot(newSlot("Waist",true,{"anytype","anysize"}))
	--accessory = player:addSlot(newSlotFolder("Accessory"))
	simple = player:addSlot(newSlotFolder("Worn:Simple"))
	complex = player:addSlot(newSlotFolder("Worn:Complex"))
	pack = player:addSlot(newSlot("Back",true,{"large","backpack","satchel","jetpack","canister","tool"},true))
	
	head = simple:addSlot(newSlot("Head",false,{"helmet","hat","anysize"},true))
	eyes = simple:addSlot(newSlot("Eyes",false,{"glasses","visor","anysize"},true))
	--pda = accessory:addSlot(newSlot("PDA clip",true,{"pda","anysize"}))
	--accesscard = accessory:addSlot(newSlot("Card clip",true,{"card","anysize"}))
	
	--pocket1 = simple:addSlot(newSlot("Pocket 1",true,{"anytype","small"}))
	--pocket2 = simple:addSlot(newSlot("Pocket 2",true,{"anytype","small"}))
	hands = simple:addSlot(newSlot("Hands",false,{"gloves","anysize"},true))
	ears = simple:addSlot(newSlot("Ears",false,{"earpiece","anysize"},true))
	
	
	body = complex:addSlot(newSlot("Body",false,{"clothing","anysize"},true,1))
	bodyexo = complex:addSlot(newSlot("Body external",false,{"armor","jacket","anysize","canister"},true))
	shoes = complex:addSlot(newSlot("Feet",false,{"shoes","boots","anysize"},true))
	mask = complex:addSlot(newSlot("Face",false,{"mask","anysize"},true))
	
	
	lefthand = player:addSlot(newSlot("Left Hand",false,{"anytype","anysize"}))
	lefthand.visible = false
	righthand = player:addSlot(newSlot("Right Hand",false,{"anytype","anysize"}))
	righthand.visible = false
		
	selected = calcAccessable(player)
	menulevel = 0
	
	curHand = lefthand
	
	table.insert(ground,newContainerItem("Janitors Outfit",{"clothing","large"},
		{
			newSlot("Belt",true,{"belt","large"},true),
			newSlot("Pocket",true,{"anytype","small"}),
			newSlot("Pocket",true,{"anytype","small"}),
			newSlot("PDA Clip",true,{"pda","card","small"},true,2),
			newSlot("ID Clip",true,{"pda","card","small"},true,2)
			}
	))
	table.insert(ground,newContainerItem("Overalls",{"armor","large"},
		{
			newSlot("Large Pocket",true,{"anytype","large"},true)
			}
	))
	table.insert(ground,newContainerItem("Spacesuit",{"armor","large"},
		{
			newSlot("Small tank",true,{"canister","small"},true),
			newSlot("Magpad",true,{"tool","small"},true,1),
			newSlot("Magpad",true,{"tool","small"},true,1)
			}
	))
	table.insert(ground,newContainerItem("Bandolier",{"jacket","large"},
		{
			newSlot("Holster",true,{"gun","small"},true,1),
			newSlot("Loop",true,{"ammunition","small"},true),
			newSlot("Loop",true,{"ammunition","small"},true),
			newSlot("Loop",true,{"ammunition","small"},true)
			}
	))
	
	table.insert(ground,newContainerItem("Gun Belt",{"belt","large"},
		{
			newSlot("Holster",true,{"gun","small"},true,1),
			newSlot("Ammopouch",true,{"ammunition","small"},true),
			newSlot("Pouch",true,{"anytype","small"},true,1),
			}
	))
	table.insert(ground,newContainerItem("Toolbelt",{"belt","large"},
		{
			newSlot("Loop",true,{"tool","small"},true,1),
			newSlot("Loop",true,{"tool","small"},true,1),
			newSlot("Loop",true,{"tool","small"},true,1),
			newSlot("Loop",true,{"tool","small"},true,1)
			}
	))
	
	table.insert(ground,newItem("Laser Battery",{"ammunition","small"},lethalWeapon))
	table.insert(ground,newItem("Stun Baton",{"weapon","large"},stunWeapon))
	table.insert(ground,newItem("Tazer",{"weapon","small"},stunWeapon))
	table.insert(ground,newItem("Nanobandage",{"tool","small"},healingItem))
	table.insert(ground,newItem("Spacehelmet",{"helmet","large"}))
	table.insert(ground,newItem("Screwdriver",{"tool","small"},improvWeapon))
	table.insert(ground,newItem("Wire Cutters",{"tool","small"},safeWorkItem))
	table.insert(ground,newItem("Multitool",{"tool","small"},safeWorkItem))
	table.insert(ground,newItem("Science Goggles",{"visor","small"}))
	table.insert(ground,newItem("Security Helmet",{"helmet","large"}))
	table.insert(ground,newItem("Captains Outfit",{"clothing","large"}))
	table.insert(ground,newItem("Hardsuit",{"armor","large"}))
	table.insert(ground,newItem("Running Shoes",{"shoes","small"}))
	table.insert(ground,newItem("Magboots",{"boots","large"}))
	table.insert(ground,newItem("Crowbar",{"tool","large"},improvWeapon))
	table.insert(ground,newItem("Laser Rifle",{"gun","large"},lethalWeapon))
	table.insert(ground,newItem("Revolver",{"gun","small"},lethalWeapon))
	table.insert(ground,newItem("Pen",{"tool","small"},improvWeapon))
	table.insert(ground,newItem("Changlings PDA",{"pda","small"}))
	table.insert(ground,newItem("Scientists Access Card",{"card","small"}))
	table.insert(ground,newItem("Janitors Earpiece",{"earpiece","small"}))
	table.insert(ground,newItem("Mop",{"tool","large"}))
	table.insert(ground,newItem("Clowns Gloves",{"gloves","small"}))
	table.insert(ground,newItem("Welder",{"tool","small"},dangerWorkItem))
	table.insert(ground,newItem("Welding Gas",{"tool","small"},safeWorkItem))
	table.insert(ground,newItem("Welding Mask",{"mask","large"},oftenUsed))
	table.insert(ground,newItem("Gas Mask",{"mask","small"}))
	table.insert(ground,newItem("Oxygen Tank",{"canister","large"},oftenUsed))
	table.insert(ground,newItem("Emergency O2 Tank",{"canister","small"},safeWorkItem))
	table.insert(ground,newContainerItem("Rucksack",{"backpack","large"},5,{"anytype","small"}))
	table.insert(ground,newContainerItem("Toolbox",{"box","large"},6,{"tool","anysize"}))
	
	local slotList = listSlots(player)
	print("player has number of slots: "..#slotList)
	for i,v in ipairs(slotList) do
		--print(v.name)
	end

end

function newSlotFolder(name)
	local o = {}
	o.type = "folder"
	o.name = name
	o.viewpriority = 10
	o.visible = true
	o.slots = {}
	o.addSlot = addSlot
	return o
end

function addSlot(self,slot)
	if self.type == "folder" or self.type == "container" then
		table.insert(self.slots,slot)
		return slot
	end
	return false
end

function addItem(self,item,drop)
	local fits, reason = checkFits(self,item)
	
	if fits then
		if drop then
			self:dropItem()
			--print((self.name.." discarded old item to collect "..item.name)
		end
		if self.item == nil then
			print(self.name.." recieved "..item.name)
			self.item = item
			return true, self.name.." recieved item "..item.name
		end
	end
	return false, self.name.." didnt get item "..reason
end

function dropItem(self)
	if self.item then
		print(self.name.." dropped "..self.item.name)
		table.insert(ground,self.item)
		self.item = nil
		return true
	end
	return false
end

function takeItem(self)
	local taken = nil
	if self.item then
		taken = self.item
		self.item = nil
		print(self.name.." lost "..taken.name)
	end
	return taken
end

function checkFits(slot,item)

	--check size first and only continue if size fits
	local slotSize = getFromList(slot.stores,sizes)[1]
	local itemSize = getFromList(item.types,sizes)[1]
	
	if slotSize == "anysize" then 
		--everything is ok
		--print("slotsize was anysize")
	elseif slotSize == itemSize then
		--everything is ok
		--print("slotsize was the same")
	else
		--print( ("slot and item were different",slotSize,itemSize)
	
		return false, item.name.."("..itemSize..") doesnt fit "..slot.name.."("..slotSize..")"
	end
	
	--check item types to make sure all of them fit
	local slotTypes = getFromList(slot.stores,types)
	local itemTypes = getFromList(item.types,types)
	--print(slotTypes[1],slot.name)
	
	
	if #slotTypes == 1 and slotTypes[1] == "anytype" then
		--print(slot.name.." can fit "..slotTypes[1])
	else
		for i,v in ipairs(itemTypes) do
			local thisTypeFits = false
			for j,k in ipairs(slotTypes) do
				if k == v then 
					thisTypeFits = true
					--print(k.." fits into "..v)
				end
			end
			if thisTypeFits == false then 
				--return false as soon as one type fails to fit
				return false, slot.name.." doesnt accept "..v.." items"
			end
		end	
	end
	
	return true, "it fit"
	
end

function getFromList(list,list2)
	local result = {}
	for i,v in ipairs(list) do
		for j,k in ipairs(list2) do
			if v==k then
				table.insert(result,k)
			end
		end
	end
	return result
end

function isInList(list,thing)
	local found = false
	for i,v in ipairs(list) do
		if v == thing then
			index = true
		end
	end
	return found
end

function newSlot(name,autostow,stores,equiptarget,priority)
	local o = {}
	o.type = "slot"
	o.name = name
	o.autostow = autostow
	o.viewpriority = priority or 0
	o.equiptarget = equiptarget or false
	o.stores = stores --array of type strings
	o.item = nil
	o.visible = true
	o.addItem = addItem
	o.dropItem = dropItem
	o.takeItem = takeItem
	return o
end

function newItem(name,types,priorities)
	local o = {}
	o.name = name
	o.priorities = priorities or defaultUse
	o.type = "item"
	o.types = types
	return o
end

function autoStow(item)
	--create complete slotlist that can hold this item
	local slotList = listSlots(player)
	--print("slotlist was "..#slotList.." long")
	local holdableList = {}
	for i,slot in ipairs(slotList) do
		if checkFits(slot,item) and slot.autostow then
			table.insert(holdableList,slot)
		end
	end
	--print("holdablelist was "..#holdableList.." long")
	
	--put it in the slot or return false
	if #holdableList > 0 then 
		local r = math.random(1,#holdableList)
		local targetSlot = holdableList[r]
		return targetSlot:addItem(item)
		 
	else
		return false
	end
			
end

function autoEquip(item)
	--create complete slotlist that can hold this item
	local slotList = listSlots(player)
	--print("slotlist was "..#slotList.." long")
	local holdableList = {}
	for i,slot in ipairs(slotList) do
		if checkFits(slot,item) and slot.equiptarget then
			table.insert(holdableList,slot)
		end
	end
	--print("holdablelist was "..#holdableList.." long")
	
	--put it in the slot or return false
	if #holdableList > 0 then 
		local r = math.random(1,#holdableList)
		local targetSlot = holdableList[r]
		return targetSlot:addItem(item)
		 
	else
		return false
	end
			
end

function listSlots(thing)
	local slotList = {}
	if thing.type == "slot" and thing.visible == true then 
		if thing.item and thing.item.type == "container" then
			local newSlots = listSlots(thing.item)
			for j,k in ipairs(newSlots) do
				table.insert(slotList,k)
			end
		else
			table.insert(slotList,thing)
		end
	elseif thing.type == "folder" then 
		for i,v in ipairs(thing.slots) do
			local newSlots = listSlots(v)
			for j,k in ipairs(newSlots) do
				table.insert(slotList,k)
			end
		end
	elseif thing.type == "container" then 
		for i,v in ipairs(thing.slots) do
			local newSlots = listSlots(v)
			for j,k in ipairs(newSlots) do
				table.insert(slotList,k)
			end
		end
	end
	return slotList
end

function newContainerItem(name,types,slots,stores)
	local o = {}
	o.name = name
	o.type = "container"
	o.types = types
	--if given a table, use those slots, otherwise generate a number of slots using stores, otherwise make 3 any slots
	if type(slots) == "table" then
		o.slots = slots
	elseif type(slots) == "number" then
		o.slots = {}
		for i=1,slots do
			addSlot(o,newSlot(name.." slot",true,stores))
		end
	else
		o.slots = {}
		for i=1,3 do
			addSlot(o,newSlot(name.." slot",true,{"anysize","anytype"}))
		end
	end
	o.addItem = addItem
	o.dropItem = dropItem
	o.takeItem = takeItem
	return o
	
end

function freeHand()
	if lefthand.item and righthand.item then
		return nil
	elseif lefthand.item then
		return righthand
	elseif righthand.item then
		return lefthand
	else
		return curHand
	end
end

function swapHand()
	if curHand == lefthand then curHand = righthand else curHand = lefthand end
end

function swapLocations(slot1,slot2)
	--check slot1 item fits in slot2
	--check slot2 item fits in slot1
	--if true then swap them
	--else return false
	if slot1.item and slot2.item then
		
		local fits1 = checkFits(slot1,slot2.item)
		local fits2 = checkFits(slot2,slot1.item)
		if fits1 and fits2 then
			local taken1 = slot1:takeItem()
			local taken2 = slot2:takeItem()
			slot1:addItem(taken2)
			slot2:addItem(taken1)
			return true
		end
	end
	return false
end

function returnFolders(obj)
	results = {}
	for i,slot in ipairs(obj.slots) do
		if slot.type == "folder" then
			table.insert(results,slot)
		end
	end
	return results
end

function calcAccessable(obj)
	local fullList = listSlots(obj)
	local accessable = {}
	for i,slot in ipairs(obj.slots) do
		if slot.visible then
			table.insert(accessable,slot)
		end
	end
	
	local sortBySlotThenItem = function(t,a,b)
		if t[b].viewpriority == t[a].viewpriority then
			if t[b].item and t[a].item then
				return t[b].item.priorities[intents[1].val] < t[a].item.priorities[intents[1].val]
			elseif t[b].item then
				return t[b].viewpriority
			else
				return t[a].viewpriority
			end
		end
		
		return t[b].viewpriority < t[a].viewpriority 
	end
	
	for i,slot in spairs(fullList, function(t,a,b) return t[b].viewpriority < t[a].viewpriority end) do
		if #accessable < 8 and slot.visible then
			table.insert(accessable,slot)
		end
	end
	local accessObj = newSlotFolder("Accessable")
	for i,slot in ipairs(accessable) do
		addSlot(accessObj,slot)
	end
	print("accessObj has number of slots "..#accessObj.slots)
	return accessObj
end

function love.keypressed(key)
	
	local ALT = love.keyboard.isDown('lalt')
	local CTRL = love.keyboard.isDown('lctrl')
	local SHIFT = love.keyboard.isDown('lshift')
	if key == 'x' and not ALT and not CTRL and not SHIFT then
		--swap selected hand
		swapHand()
		--print( ("swap hand")
	elseif key == 'q' and curHand.item and curHand.item.type == "container" then
		selected = curHand.item
		swapHand()
	elseif key == ';' then
		table.insert(intents,table.remove(intents,1))
	elseif key == 'e' then
		local taken = curHand:takeItem()
		if taken then
			stowed = autoEquip(taken)
			if not stowed then curHand:addItem(taken) end
		end
	elseif key == 'z' then
		curHand:dropItem()
	elseif key == '[' then
		local first = table.remove(ground,1)
		table.insert(ground,first)
	elseif key == ']' then
		local last = table.remove(ground,#ground)
		table.insert(ground,1,last)
	elseif key == '`' then
		if menulevel == 0 then				
			if freeHand() and #ground > 0 then
				--get closest from ground
				local nextGround = table.remove(ground,1)
				print("get item from ground "..nextGround.name)
				local moved = freeHand():addItem(nextGround)
				if not moved then table.insert(ground,nextGround) end
			elseif curHand.item then
				--autostow selected hand item,or keep it in the hand
				print("autostow held item")
				local taken = curHand:takeItem()
				local stowed = autoStow(taken)
				--print(tostring(stowed).." Stowed")
				if not stowed then curHand:addItem(taken) end
			end
		else
			--close selection
			menulevel = 0
			selected = calcAccessable(player)
			--print( ("cancel selection")
		end
	elseif type(tonumber(key)) == "number" then
		key = tonumber(key)
		if selected.slots[key] then
			slot = selected.slots[key]
			--print(slot.name)
			if slot.visible then
				if ALT then
					--drop selected.slot[key] of selected
					--print( ("drop item "..key)
					slot:dropItem()
				elseif CTRL then
					--drop curHand.item
					--force selected.slot[key].item to current hand
					--print( ("force item "..key.." to hand")
					if slot.item and checkFits(curHand,slot.item) then 
						local taken = slot:takeItem()
						curHand:addItem(taken,true) --dont check it, it should always be true
					end
				elseif SHIFT then
					--drop slot[key].item
					--stow selected.curHand.item in slot[key]
					--print( ("clear slot "..key.." and put held item")
					if curHand.item and checkFits(slot,curHand.item) then 
						local taken = curHand:takeItem()
						if taken then slot:addItem(taken,true) end				
					end
				else
					--interact with slot as normal
					if slot.type == "folder" then
						--print( ("moving to folder or container "..key)
						selected = slot
						menulevel = 1
					elseif slot.item and slot.item.type == "container" then
						--print("found a container item, moving to it")
						selected = slot.item
						menulevel = 1
					elseif slot.item and not freeHand() then
						--swap slot and hand or autostow if the hand item wont fit
						--print ("no free hand swap items "..key)
						local swapped = swapLocations(slot,curHand)
						if not swapped then 
							autoStow(curHand:takeItem())
							curHand:addItem(slot:takeItem())
						end
					elseif slot.item and slot.item.type == "item" and freeHand() then
						--put item in curHand or freeHand
						--print( ("putting item "..key.." in free hand")
						freeHand():addItem(slot:takeItem())
					elseif slot.item == nil and curHand.item then
						--put item in slot from current hand
						local taken = curHand:takeItem()
						local placed = slot:addItem(taken)
						if not placed then curHand:addItem(taken) end
					
					else
						--its not an item or a slot or a container best to do nothing
					end
				end
			end
		else
			print("no slot on that number")
		end
	end
	
	if menulevel == 0 then
		selected = calcAccessable(player)
	end
	
end

function love.draw()
	local lg = love.graphics
	lg.setFont(font)
	local h = 25
	lg.setColor(255,255,255)
	lg.print(selected.name,10,h)
	h = h + 5 + font:getHeight()
	for i,slot in ipairs(selected.slots) do
		if slot.visible then
			local text = "("..i..") "..slot.name..":--"
			local itemtext = "Nothing"
			if slot.item then
				itemtext = slot.item.name
			elseif slot.type == "folder" then
				itemtext = "folder"
			elseif slot.type == "container" then
				itemtext = "container"
			end
			local l = font:getWidth(text)
			lg.setColor(255,255,255)
			lg.print(text,0,h)
			lg.setColor(0,255,0)
			lg.print(itemtext,l+15,h)
			h = h + 5 + font:getHeight()
		end
	end
	
	h = lg.getHeight() - font:getHeight()*2 - 20
	
	if curHand == lefthand then lg.setColor(255,255,255) else lg.setColor(255,0,0) end
	text = "Left Hand"
	lg.print(text,0,h)
	lg.setColor(0,255,0)
	local itemtext = "Nothing"
	if lefthand.item then itemtext = lefthand.item.name end 
	local l = font:getWidth(text)
	lg.print(itemtext,l+15,h)
	h = h + 5 + font:getHeight()
	
	if curHand == righthand then lg.setColor(255,255,255) else lg.setColor(255,0,0) end 
	text = "Right Hand"
	lg.print(text,0,h)
	lg.setColor(0,255,0)
	local itemtext = "Nothing"
	if righthand.item then itemtext = righthand.item.name end
	local l = font:getWidth(text)
	lg.print(itemtext,l+15,h)
	h = h + 5 + font:getHeight()
	
	lg.setFont(fontsml)
	h = 0
	lg.setColor(255,255,255)
	lg.print("Items on Ground",lg.getWidth()/4*3,h)
	h = h + 2 + fontsml:getHeight()
	
	for i,v in ipairs(ground) do
		local text = v.name
		local x = lg.getWidth()/4*3
		lg.setColor(125,220,200)
		if i == 1 then 
			text = ">>> "..text.." <<<" 
			x = x - fontsml:getWidth(">>> ")
			lg.setColor(125,245,255)
		end
		lg.print(text,x,h)
		h = h + 2 + fontsml:getHeight()
	end
	
	local x = lg.getWidth()/4*3 - 150
	local y = lg.getHeight() - 150
	for i,v in ipairs(intents) do
		
		if i == 1 then
			lg.setFont(font)
		else
			lg.setFont(fontsml)
		end
		lg.print(v.name,x,y)
		if i == 1 then
			y = y + font:getHeight(v.name) +10
		else
			y = y + fontsml:getHeight(v.name) +5
		end
	end
	
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
