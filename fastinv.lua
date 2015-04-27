local fastinv = {}

local font = love.graphics.newFont(30)
local fontsml = love.graphics.newFont(15)


function fastinv.init(itemtypes,sizes)
	fastinv.itemtypes = itemtypes or {"anytype"}
	fastinv.sizes = sizes or {"anysize"}
end

function fastinv.new(name,structure)
	local o = fastinv.newSlotFolder(name)
	for i,v in ipairs(structure) do
		if type(v) == 'table' then 
			o:addSlot(fastinv.new(name.." next",v))
		else
			o:addSlot(fastinv.newSlot(v))
		end
	end
	return o
end

--creates a new slot folder. These are just slots which have slots
function fastinv.newSlotFolder(name)
	local o = {}
	o.type = "folder"
	o.name = name
	o.viewpriority = 10
	o.visible = true
	o.slots = {}
	o.addSlot = fastinv.addSlot
	o.draw = fastinv.draw
	o.toggle = fastinv.toggle
	return o
end

--creates a new Slot entity. Slots only contain items
function fastinv.newSlot(name,stores,autostow,equiptarget,priority)
	local o = {}
	o.type = "slot"
	o.name = name
	o.autostow = autostow
	o.viewpriority = priority or 0
	o.equiptarget = equiptarget or false
	o.stores = stores or {"anytype","anysize"}
	o.item = nil
	o.visible = true
	o.addItem = fastinv.addItem
	o.dropItem = fastinv.dropItem
	o.takeItem = fastinv.takeItem
	o.draw = fastinv.draw
	return o
end

--creates a new Item entity. Items are only stored in slots
function fastinv.newItem(name,types,priorities)
	local o = {}
	o.name = name
	o.priorities = priorities or {}
	o.type = "item"
	o.types = types or {}
	return o
end

--create new Container item. These are items which have slots, so can store other items.
function fastinv.newContainerItem(name,types,slots,stores)
	local o = fastinv.newItem(name,types or {})
	o.type = "container"
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
	o.draw = fastinv.draw
	o.toggle = fastinv.toggle
	return o
end

function fastinv.toggle(self)
	for i,v in ipairs(self.slots) do
		v.visible = not v.visible
	end
end

function fastinv.addSlot(self,slot)
	if self.type == "folder" or self.type == "container" then
		table.insert(self.slots,slot)
		return slot
	end
	return false
end

function fastinv.addItem(self,item,drop)
	local fits, reason = fastinv.checkFits(self,item)
	
	if fits then
		if drop then
			self:dropItem()
			--print((self.name.." discarded old item to collect "..item.name)
		end
		if self.item == nil then
			print(self.name.." recieved "..item.name)
			self.item = item
			return nil
		end
	end
	return item
end

--removes item from a slot, adding it to the passed array or destroying it
function fastinv.dropItem(self,ground)
	if self.item then
		if ground then table.insert(ground,self.item) end
		self.item = nil
		return true
	end
	return false
end

--removes item from a slot and returns it
function fastinv.takeItem(self)
	local taken = nil
	if self.item then
		taken = self.item
		self.item = nil
	end
	return taken
end

--compares an item and a slot and returns if it can fit
function fastinv.checkFits(slot,item)
	--check size first and only continue if size fits
	local slotSize = fastinv.getFromList(slot.stores,fastinv.sizes)[1]
	local itemSize = fastinv.getFromList(item.types,fastinv.sizes)[1]
	if slotSize == "anysize" then 
		--everything is ok
		print(slot.name.." slotsize was anySize "..slotSize)
	elseif slotSize == itemSize then
		--everything is ok
		print(item.name.." itemsize "..itemSize.." "..slot.name.." slotsize "..slotSize)
	else
		--print( ("slot and item were different",slotSize,itemSize)
	
		return false, item.name.."("..itemSize..") doesnt fit "..slot.name.."("..slotSize..")"
	end
	--check item types to make sure all of them fit
	local slotTypes = fastinv.getFromList(slot.stores,fastinv.itemtypes)
	local itemTypes = fastinv.getFromList(item.types,fastinv.itemtypes)
	--print(slotTypes[1],slot.name)
	if #slotTypes == 1 and slotTypes[1] == "anytype" then
		--print(slot.name.." can fit "..slotTypes[1])
		return true, slot.name.." slottype is anytype "..slotTypes[1]
	else
		print("comparing slot and item types")
		return checkAllAreIn(slotTypes,itemTypes), "all item types were contained in slottypes"	
	end
	print(item.name.." itemtype "..itemTypes[1].." "..slot.name.." slotTypes "..slotTypes[1])
	return false, "failed during type comparison"
end

--LOGIC: used for checkFits()
local function checkAllAreIn(full,sample)
	local allExist = true
	for i,v in ipairs(sample) do
		local thisOneExists = false
		for j,k in ipairs(full) do
			if k==v then thisOneExists = true end
		end
		if not thisOneExists then allExist = false end
	end
	return allExist
		
end

--LOGIC: returns the intersection of list1 and list2
function fastinv.getFromList(list,list2)
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

--LOGIC: checks if thing is in list of things
local function isInList(list,thing)
	local found = false
	for i,v in ipairs(list) do
		if v == thing then
			index = true
		end
	end
	return found
end





--searchs an inventory and adds item to an autostow slot, returns the item if it did not fit
function fastinv.autoStow(self,item)
	--create complete slotlist that can hold this item
	local slotList = fastinv.listSlots(player)
	--print("slotlist was "..#slotList.." long")
	local holdableList = {}
	for i,slot in ipairs(slotList) do
		if fastinv.checkFits(slot,item) and slot.autostow then
			table.insert(holdableList,slot)
		end
	end
	--print("holdablelist was "..#holdableList.." long")
	
	--put it in the slot or return false
	if #holdableList > 0 then 
		local r = math.random(1,#holdableList)
		local targetSlot = holdableList[r]
		local remain = targetSlot:addItem(item)
		return remain
	else
		return item
	end
	
		
end

--searches and inventory and adds item to an autoequip slot, returns the item if it did not fit
function fastinv.autoEquip(self,item)
	--create complete slotlist that can hold this item
	local slotList = fastinv.listSlots(player)
	--print("slotlist was "..#slotList.." long")
	local holdableList = {}
	for i,slot in ipairs(slotList) do
		if fastinv.checkFits(slot,item) and slot.equiptarget then
			table.insert(holdableList,slot)
		end
	end
	--print("holdablelist was "..#holdableList.." long")
	
	--put it in the slot or return false
	if #holdableList > 0 then 
		local r = math.random(1,#holdableList)
		local targetSlot = holdableList[r]
		local remain = targetSlot:addItem(item)
		return remain
	else
		return item
	end
			
end

--get all slots of an inventory
function fastinv.listSlots(thing)
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

--get all items in an inventory
function fastinv.listItems(self)
	local allSlots = fastinv.listSlots(self)
	local allItems = {}
	for i,slot in ipairs(allSlots) do
		if slot.item then
			table.insert(allItems,slot.item)
		end
	end
	return allItems
end

--when passed two slots, their contents will be swapped if possible
function fastinv.swapLocations(slot1,slot2)
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

--LOGIC: returns a list of slot Folders in the object
local function returnFolders(obj)
	results = {}
	for i,slot in ipairs(obj.slots) do
		if slot.type == "folder" then
			table.insert(results,slot)
		end
	end
	return results
end

function fastinv.draw(self,x,y)
	local lg = love.graphics
	lg.setFont(font)
	local h = y or 25
	local x = x or 15
	lg.setColor(255,255,255)
	--lg.print(self.name,10,h)
	--h = h + 5 + font:getHeight()
	for i,slot in ipairs(self.slots) do
		if slot.visible then
			local text = "-"..slot.name..": "
			local itemtext = "Nothing"
			if slot.item then
				itemtext = slot.item.name
			elseif slot.type == "folder" then
				itemtext = "folder ("..#slot.slots.." slots)"
				
			elseif slot.type == "container" then
				itemtext = "container"
			end
			local l = font:getWidth(text)
			lg.setColor(255,255,255)
			lg.print(text,x,h)
			lg.setColor(0,255,0)
			lg.print(itemtext,l+15+x,h)
			h = h + 5 + font:getHeight()
			if slot.type == "folder" then
				h = fastinv.draw(slot,x + 50,h)
			end
		end
	end	
	return h
end

function fastinv.drawVert(self,x,y)
	local lg = love.graphics
	lg.setFont(font)
	local y = y or 25
	local x = x or 15
	for i,slot in ipairs(self.slots) do
		if slot.visible then
			if slot.type == "folder" then
				lg.setColor(125,220,200)
			else
				lg.setColor(255,255,255)
			end
			lg.rectangle("fill",x,y,64,64)
			lg.setFont(fontsml)
			local ox = 32 - (fontsml:getWidth(slot.name)/2 )
			local oy = 32 - (fontsml:getHeight()/2)
			lg.setColor(0,0,0)
			lg.print(slot.name,x+ox,y+oy)
			if slot.item then fastinv.drawItem(x,y) end
			
			if slot.type == "folder" then
				y = fastinv.drawHori(slot,x+64+5,y)
			end
			y = y + 5 + 64
		end
	end	
	return y
end

function fastinv.drawHori(self,x,y)
	local lg = love.graphics
	lg.setFont(font)
	local y = y or 25
	local x = x or 15
	--lg.print(self.name,10,h)
	--h = h + 5 + font:getHeight()
	for i,slot in ipairs(self.slots) do
		if slot.visible then
			if slot.type == "folder" then
				lg.setColor(125,220,200)
			else
				lg.setColor(255,255,255)
			end
			lg.rectangle("fill",x,y,64,64)
			lg.setFont(fontsml)
			local ox = 32 - (fontsml:getWidth(slot.name)/2 )
			local oy = 32 - (fontsml:getHeight()/2)
			lg.setColor(0,0,0)
			lg.print(slot.name,x+ox,y+oy)
			if slot.item then fastinv.drawItem(slot.item,x,y) end
			x = x + 5 + 64
		end
	end	
	return y
end

function fastinv.drawItem(self,x,y)
	local lg = love.graphics
	lg.setColor(255,220,125)
	lg.rectangle("fill",x+5,y+5,64-10,64-10)
	local ox = x + 32 - (fontsml:getWidth(self.name)/2 )
	local oy = y + 32 - (fontsml:getHeight()/2)
	lg.setFont(fontsml)
	lg.setColor(0,0,0)
	lg.print(self.name,ox,oy)
end



local function spairs(t, order)
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



return fastinv
