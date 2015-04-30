inv = require 'fastinv' 
ss = require 'ssItem'
intent = require 'intent'
gs = require 'hump-master.gamestate'
splash = require 'state_splash'

local lg = love.graphics
local font = love.graphics.newFont(30)
local fontsml = love.graphics.newFont(15)
love.graphics.setFont(font)

local as = {}
as.map = lg.newImage('/assets/bgmap.png')
as.emptyslot = lg.newImage('/assets/empty.png')
as.lhand = lg.newImage('/assets/lhand.png')
as.lhandact = lg.newImage('/assets/lhand_act.png')
as.rhand = lg.newImage('/assets/rhand.png')
as.rhandact = lg.newImage('/assets/rhand_act.png')
as.glasses = lg.newImage('/assets/glasses.png')
as.suitstore = lg.newImage('/assets/suitstore.png')
as.suit = lg.newImage('/assets/suit.png')
as.shoes = lg.newImage('/assets/shoes.png')
as.gloves = lg.newImage('/assets/gloves.png')
as.head = lg.newImage('/assets/head.png')
as.mask = lg.newImage('/assets/mask.png')
as.id = lg.newImage('/assets/id.png')
as.belt = lg.newImage('/assets/belt.png')
as.pocket = lg.newImage('/assets/pocket.png')
as.uniform = lg.newImage('/assets/uniform.png')
as.ears = lg.newImage('/assets/ears.png')
as.back = lg.newImage('/assets/back.png')
as.faid = lg.newImage('/assets/firstaid.png')
as.backpack = lg.newImage('/assets/backpack.png')
as.outfit = lg.newImage('/assets/grey.png')
as.card = lg.newImage('/assets/idcard.png')
as.pda = lg.newImage('/assets/pda.png')
as.pen = lg.newImage('/assets/pen.png')
as.goggles = lg.newImage('/assets/goggles.png')
as.galoshes = lg.newImage('/assets/galoshes.png')

as.medbelt = lg.newImage('/assets/medical/medbelt.png')
as.needle = lg.newImage('/assets/medical/needle.png')
as.oxy = lg.newImage('/assets/medical/oxy.png')
as.medpack = lg.newImage('/assets/medical/medpack.png')
as.medshoes = lg.newImage('/assets/medical/shoes.png')
as.biohood = lg.newImage('/assets/medical/biohelm.png')
as.biosuit = lg.newImage('/assets/medical/biosuit.png')
as.earpiece = lg.newImage('/assets/medical/headset.png')
as.medhud = lg.newImage('/assets/medical/medhud.png')
as.medoutfit = lg.newImage('/assets/medical/med.png')
as.medbackpack = lg.newImage('/assets/medical/medibackpack.png')

as.holster = lg.newImage('/assets/holster.png')
as.revolver = lg.newImage('/assets/revolv.png')
as.bonesaw = lg.newImage('/assets/bonesaw.png')

img={}
img.binary = lg.newImage('/assets/bgsplashlogo.png')

game = {}

ground = {}

local lefttexts = {
		"This is a prototype inventory",
		"system to replace the one found",
		"in Space Station 13.",
		" ",
		"The idea is to create a context",
		"sensitive solution that is",
		"controllable from the number",
		"keys.",
		" ",
		"Holding ALT will force items",
		"into a slot, and will also",
		"auto store/equip them in",
		"containers and backpacks.",
		" ",
		"Holding CTRL will force items",
		"To your hand. This will also",
		"allow you to pick up containers",
		"and backbacks.",
		" ",
		"Press x to change active hand.",
		"Press q to auto store held item.",
		"Press e to auto equip held item.",
		"Press z to drop held item"
		}
		
local righttexts = {
		"The four slots below are",
		"context sensitive. you may",
		"change your action intent",
		"by pushing F.",
		" ",
		"This will modify the order of",
		"these slots. They are sorted",
		"by how helpful or harmful the",
		"item is.",
		" ",
		"Try to equip a Bonesaw and ",
		"Medipack to see how this",
		"works.",
		" ",
		"Use the arrow keys to explore",
		"the station. This map is",
		"Ministation and is maintained",
		"by Giacom on Github."  
		}

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
	"box",
	"medical"
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

local mapX = -736
local mapY = 1088

function love.load()
	gs.registerEvents()
	love.graphics.setDefaultFilter("nearest","nearest")
	local modes = love.window.getFullscreenModes(2)
	love.window.setMode(modes[#modes].width,modes[#modes].height,{fullscreen=true,fullscreentype="desktop"})
	
	menulevel = 0
	
	inv.init(types,sizes)
	
	player = inv.new("Player")
	
	simple = player:addSlot(inv.newSlotFolder("Worn:Simple"))
	simple.img = as.glasses
	complex = player:addSlot(inv.newSlotFolder("Worn:Complex"))
	complex.img = as.suit
	body = player:addSlot(ss.newSlot("Body",{"clothing","anysize"},false,true,5,as.uniform,false))
	pack = player:addSlot(ss.newSlot("Back",{"large","backpack","satchel","jetpack","canister","tool","slingable"},true,true,0,as.suitstore,false))
	rucksack = ss.newContainerItem("Rucksack",{"backpack","large"},5,{"anytype","small"},as.backpack)
	pack:addItem(rucksack)
	
	head = simple:addSlot(ss.newSlot("Head",{"helmet","hat","anysize"},false,true,0,as.head,true))
	eyes = simple:addSlot(ss.newSlot("Eyes",{"glasses","visor","anysize"},false,true,0,as.glasses,true))
	hands = simple:addSlot(ss.newSlot("Hands",{"gloves","anysize"},false,true,0,as.gloves,false))
	ears = simple:addSlot(ss.newSlot("Ears",{"earpiece","anysize"},false,true,0,as.ears,true))
	
	bodyexo = complex:addSlot(ss.newSlot("Body external",{"armor","jacket","anysize","canister","slingable"},false,true,0,as.suit,false))
	shoes = complex:addSlot(ss.newSlot("Feet",{"shoes","boots","anysize"},false,true,0,as.shoes,true))
	mask = complex:addSlot(ss.newSlot("Face",{"mask","anysize"},false,true,0,as.mask,true))
	
	hands = inv.new("Hands")
	left = hands:addSlot(ss.newSlot("Left Hand",{"anytype","anysize"},false,false,0,as.lhand,false))
	right = hands:addSlot(ss.newSlot("Right Hand",{"anytype","anysize"},false,false,0,as.rhand,false))
		
	selected = player
	curHand = left
	
	outfit = ss.newContainerItem("Uniform",{"clothing","large"},
		{
			ss.newSlot("Belt",{"belt","canister","anysize"},true,true,10,as.belt,true),
			ss.newSlot("Pocket",{"anytype","small"},true,false,0,as.pocket,true),
			ss.newSlot("Pocket",{"anytype","small"},true,false,0,as.pocket,true),
			ss.newSlot("PDA Clip",{"pda","card","small"},true,true,1,as.id,true),
			ss.newSlot("ID Clip",{"pda","card","small"},true,true,3,as.id,true)
			},
		{},as.outfit
	)
	
	biosuit = ss.newContainerItem("Biosuit",{"armor","large"},
		{
			ss.newSlot("Oxy",{"canister","small"},true,true,10,as.suitstorage,true)
			},
		{},as.biosuit
	)
	
	medoutfit = ss.newContainerItem("Medical Uniform",{"clothing","large"},
		{
			ss.newSlot("Belt",{"belt","canister","anysize"},true,true,10,as.belt,true),
			ss.newSlot("Pocket",{"anytype","small"},true,false,0,as.pocket,true),
			ss.newSlot("Pocket",{"anytype","small"},true,false,0,as.pocket,true),
			ss.newSlot("PDA Clip",{"pda","card","small"},true,true,1,as.id,true),
			ss.newSlot("ID Clip",{"pda","card","small"},true,true,3,as.id,true)
			},
		{},as.medoutfit
	)
	
	idcard = ss.newItem("Scientist ID Card",{"card","small"},as.card,{1,1})
	pda = ss.newItem("Science PDA",{"pda","small"},as.pda,{1,1})
	pen = ss.newItem("Pen",{"tool","small"},as.pen,{0,2})
	faid = ss.newItem("First Aid Kit",{"tool","small"},as.faid,{2,0})
	goggles = ss.newItem("Meson Goggles",{"visor","small"},as.goggles,{1,0})
	galoshes = ss.newItem("Galoshes",{"boots","small"},as.galoshes)
	
	eyes:addItem(goggles)
	shoes:addItem(galoshes)
	
	outfit.slots[2]:addItem(pen)
	outfit.slots[4]:addItem(idcard)
	outfit.slots[5]:addItem(pda)
	rucksack:addItem(faid)
	
	body:addItem(outfit)
	
	context = contextSlots(player,4)
	
	table.insert(inv.ground, ss.newItem("Bio Hood",{"helmet","large"},as.biohood,{2,0}))
	table.insert(inv.ground, ss.newItem("Medical HUD",{"visor","small"},as.medhud,{1,0}))
	table.insert(inv.ground, ss.newItem("Small Oxy",{"canister","small"},as.oxy,{1,0}))
	table.insert(inv.ground, ss.newItem("Medical Shoes",{"shoes","small"},as.medshoes))
	table.insert(inv.ground, ss.newItem("Medbay Headset",{"earpiece","small"},as.earpiece))
	table.insert(inv.ground, ss.newItem("First Aid",{"tool","small"},as.faid,{4,0}))
	table.insert(inv.ground, ss.newItem("Revolver",{"gun","small"},as.revolver,{0,5}))
	table.insert(inv.ground, ss.newItem("Bonesaw",{"medical","large"},as.bonesaw,{2,4}))
	
	medbelt = ss.newContainerItem("Medical Belt",{"belt","large"},
		{
			ss.newSlot("Pouch",{"medical","large"},true,true,5,as.pocket,true),
			ss.newSlot("Pouch",{"medical","small"},true,true,0,as.pocket,true),
			ss.newSlot("Pouch",{"medical","small"},true,true,0,as.pocket,true),
			ss.newSlot("Pouch",{"medical","small"},true,true,0,as.pocket,true)
			},
		{},as.medbelt,{4,0})
		
	holster = ss.newContainerItem("Gunbelt",{"belt","large"},
		{
			ss.newSlot("Holster",{"gun","small"},true,true,8,as.pocket,true),
			ss.newSlot("Pouch",{"anytype","small"},true,false,0,as.pocket,true)
			},
		{},as.holster,{0,4})
	
	medbelt:addItem(ss.newItem("Syringe",{"medical","small"},as.needle,{3,2}))
	medbelt:addItem(ss.newItem("Syringe",{"medical","small"},as.needle),{3,2})
	medbelt:addItem(ss.newItem("Medpack",{"medical","small"},as.medpack,{3,0}))
	
	medisach = ss.newContainerItem("Medical Pack",{"backpack","large"},4,{"anytype","small"},as.medbackpack,{0,0})
		
	table.insert(inv.ground, medbelt)
	table.insert(inv.ground, holster)
	table.insert(inv.ground, medoutfit)
	table.insert(inv.ground, medisach)
	table.insert(inv.ground, biosuit)
	
    local bx,by = (lg.getWidth()/2)-(img.binary:getWidth()/2),(lg.getHeight()/2)-(img.binary:getHeight()/2)

	
	gs.switch(splash.new({
        aa.new({splash.newQuadFlyIn(img.binary,bx,by,1)}),
        aa.new({splash.newImageDisplay(img.binary,bx,by,2)}),
        aa.new({splash.newQuadFlyOut(img.binary,bx,by,1)}),
        }))
end

function freeHand()
	if left.item and right.item then
		return nil
	elseif left.item then
		return right
	elseif left.item then
		return right
	else
		return curHand
	end
end

function swapHand()
	if curHand == left then curHand = right else curHand = left end
end

function contextSlots(inventory,num)
	local context = inv.new("Context")
	local allEmpty = inv.listEmpty(inventory)
	local allFull = inv.listItemSlots(inventory)

	for i,slot in spairs(allFull, function(t,a,b) return t[b].item.intents[intent.state] < t[a].item.intents[intent.state] end) do
		if #context.slots < num and slot.visible and slot.contextual then
			context:addSlot(slot)
			print("added slot to context")
		end
	end
	if #context.slots < num and #allEmpty > 0 then
		for i,slot in spairs(allEmpty, function(t,a,b) return (t[b].viewpriority or 0) < (t[a].viewpriority or 0) end) do
			if #context < num and slot.visible and slot.contextual then
				context:addSlot(slot)
				print("added slot to context")
			end
		end
	end

	return context
end

function mostAccess(inventory)
	local all = inv.listSlots(inventory)
	for i,slot in spairs(all, function(t,a,b) return t[b].viewpriority < t[a].viewpriority end) do
		if slot.visible then
			return slot
		end
	end
	return inventory
end

function calcAccessable(obj)
	local fullList = inv.listSlots(obj)
	local accessable = {}
	for i,slot in ipairs(obj.slots) do
		if slot.visible then
			table.insert(accessable,slot)
		end
	end
	
	for i,slot in spairs(fullList, function(t,a,b) return t[b].viewpriority < t[a].viewpriority end) do
		if #accessable < 8 and slot.visible then
			table.insert(accessable,slot)
		end
	end
	local accessObj = newSlotFolder("Accessable")
	for i,slot in ipairs(accessable) do
		inv.addSlot(accessObj,slot)
	end
	print("accessObj has number of slots "..#accessObj.slots)
	return accessObj
end

function game.keypressed(key)
	local ALT = love.keyboard.isDown('lalt')
	local CTRL = love.keyboard.isDown('lctrl')
	local SHIFT = love.keyboard.isDown('lshift')
	
	if not ALT and not CTRL and not SHIFT then
		--normal non inventory keypress
		moveMap(key)
		--inventory num keypress
		invKeypressed(key)
	elseif ALT then
		ALTKeypressed(key)
	elseif CTRL then
		CTRLKeypressed(key)
	elseif SHIFT then
		--SHIFT keypress
	end	
	context = contextSlots(player,4)
end

function moveMap(key)
	if key == 'up' then mapY = mapY -32 end
	if key == 'down' then mapY = mapY +32 end
	if key == 'left' then mapX = mapX -32 end
	if key == 'right' then mapX = mapX +32 end
end

function slotToHand(slot,force)
	--put current hand item into slot, or if slot is full, leave it in hand
	local taken = slot:takeItem()
	local placed = curHand:addItem(taken,force)
	if placed then slot:addItem(taken) end
end

function groundToHand(force)
	--put current hand item into slot, or if slot is full, leave it in hand
	local taken = table.remove(inv.ground,1)
	local placed = curHand:addItem(taken,force)
	if placed then table.insert(inv.ground,1,taken) end
end

function handToSlot(slot,force)
	--put item in slot from current hand
	local taken = curHand:takeItem()
	local placed = slot:addItem(taken,force)
	if placed then curHand:addItem(taken) end
end

function dropHand()
	--drop current hand item
	curHand:dropItem()
end

function handToContainer(container)
	--put item in slot from current hand
	local taken = curHand:takeItem()
	local placed = container:addItem(taken,force)
	if placed then curHand:addItem(taken) end
end

function handToFolder(folder,force)
	--put item in slot from current hand
	local taken = curHand:takeItem()
	local placed = folder:autoEquip(taken,force)
	if placed then curHand:addItem(taken) end
end

function folderToHand(folder,force)
	--get the first item from the folder
	local itemSlots = folder:listItemSlots()
	if #itemSlots > 0 then
		slotToHand(itemSlots[1],true)
	end
end


function swapWithHand(slot)
	--swap slot and hand or autostow if the hand item wont fit
	local swapped = inv.swapLocations(slot,curHand)
	if not swapped then 
		player:autoStow(curHand:takeItem())
		curHand:addItem(slot:takeItem())
	end
end

function invKeypressed(key)
	local slot = nil
	if type(tonumber(key)) == "number" then
		local numkey = tonumber(key)
		if selected.slots[numkey] then slot = selected.slots[numkey] 
		elseif context.slots[numkey-4] then slot = context.slots[numkey-4] end
	end
	
	if slot then
		--interact with slot as normal
		if slot.type == "folder" then
			selected = slot
			menulevel = 1
		elseif slot.item and slot.item.type == "container" then
			selected = slot.item
			menulevel = 1
		elseif slot.item and curHand.item then
			swapWithHand(slot)
		elseif slot.item and curHand.item == nil then
			slotToHand(slot)
		elseif slot.item == nil and curHand.item then
			handToSlot(slot)
		end
	end
	
	if key == '`' then
		menulevel = 0
		selected = player
	elseif key == 'x' then
		swapHand()
	elseif key == 'f' then
		intent.switch()
	elseif key == 'c' and menulevel == 0 and curHand.item and curHand.item.type == "container" then
		selected = curHand.item
		menulevel = 1
	elseif key == ']' then
		table.insert(inv.ground,table.remove(inv.ground,1))
	elseif key == '[' then
		table.insert(inv.ground,1,table.remove(inv.ground,#inv.ground))
	elseif key == 'z' then
		dropHand()
	elseif key == 't' then
		groundToHand()
	elseif key == 'e' then
		local taken = curHand:takeItem()
		if player:autoEquip(taken) then curHand:addItem(taken) end
	elseif key == 'q' then
		local taken = curHand:takeItem()
		if player:autoStow(taken) then curHand:addItem(taken) end
	end
	
	
		
end

function ALTKeypressed(key)
	--holding alt while interacting with the inventory will ignore whatever is in the slot
	--this means generatlly discarding the slot item to put the hand item
	--in the case of container items it will try to autostow in that object
	--in the case of folders items it will try to autoequip in that object
	local slot = nil
	if type(tonumber(key)) == "number" then
		local numkey = tonumber(key)
		if selected.slots[numkey] then slot = selected.slots[numkey] 
		elseif context.slots[numkey-4] then slot = context.slots[numkey-4] end
	end
	
	if slot then
		--interact with slot as normal
		if slot.type == "folder" then
			--dont open, autoequip
			handToFolder(slot,true)
		elseif slot.item and slot.item.type == "container" then
			--dont open, autostow instead
			handToContainer(slot.item)
		else
			--put from hand to slot, discard slot
			handToSlot(slot,true)
		end
	end
	
end

function CTRLKeypressed(key)
	--holding ctrl will ignore the held item generally meaning you take the targetted item
	--and drop the held item. 
	--in the case of container items it will grab the container item instead of opening it
	local slot = nil
	if type(tonumber(key)) == "number" then
		local numkey = tonumber(key)
		if selected.slots[numkey] then slot = selected.slots[numkey] 
		elseif context.slots[numkey-4] then slot = context.slots[numkey-4] end
	end
	
	if slot then
		--interact with slot as normal
		if slot.type == "folder" then
			--dont open take item from inside folder
			folderToHand(slot)
		elseif slot.item and slot.item.type == "container" then
			--dont open, take instead
			slotToHand(slot,true)
		else
			--put from hand to slot, discard slot
			slotToHand(slot,true)
		end
	end
end

function oldkeypressed(key)
	
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
			if CTRL and #ground > 0 then
				--get closest from ground
				local nextGround = table.remove(ground,1)
				print("get item from ground "..nextGround.name)
				local moved = curHand:addItem(nextGround,true)
				if not moved then table.insert(ground,nextGround) end
			elseif freeHand() and #ground > 0 then
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
						if placed then curHand:addItem(taken) end
					
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

function game.draw()
	local bx,by = (lg.getWidth()/2)-(as.map:getWidth()/2),(lg.getHeight()/2)-(as.map:getHeight()/2)
	lg.draw(as.map,bx-mapX,by-mapY,0,2,2)

	
	local ih = 72
	local scale = ih/as.emptyslot:getWidth()
	local mar = 4
	local mx = lg.getWidth()/2
	local bary = lg.getHeight()-ih-mar
	
	local fourbarlength = ih*4+mar*3
	
	local h1x = mx-ih-(mar/2)
	local h2x = mx+(mar/2)
	
	local b1x = h1x/2 - fourbarlength/2
	local b2x = h2x+ih+(lg.getWidth()-(h2x+ih))/2 - fourbarlength/2
	
	local lhand = as.lhand
	local rhand = as.rhand
	
	
	drawInfoPanel(5,lg.getHeight()/6,lefttexts)
	drawInfoPanel(lg.getWidth()-fontsml:getWidth("allow you to pick up containers")-60,lg.getHeight()/5,righttexts)
	
	intent.draw(mx+ih+6,bary,scale/1.5)
	
	if curHand == left then lhand = as.lhandact else rhand = as.rhandact end
	
	local selectedFound = false
	
	lg.draw(lhand,h1x,bary,0,scale,scale)
	if left.item then 
		if left.item == selected and selected.type == "container" then
			drawOpenContainer(selected,h1x,bary,ih+mar,scale)
			selectedFound = true
		elseif left.item.type == "container" and left == curHand and menulevel == 0 then
			lg.draw(left.item.img or as.faid,h1x,bary,0,scale,scale)
			lg.print('C',h1x+5,bary+5)
		else
			lg.draw(left.item.img or as.faid,h1x,bary,0,scale,scale)
		end
	end
	lg.draw(rhand,h2x,bary,0,scale,scale)
	if right.item then 
		if right.item == selected and selected.type == "container" then
			drawOpenContainer(selected,h2x,bary,ih+mar,scale)
			selectedFound = true
		elseif right.item.type == "container" and right == curHand and menulevel == 0 then
			lg.draw(right.item.img or as.faid,h2x,bary,0,scale,scale)
			lg.print('C',h2x+5,bary+5)
		else
			lg.draw(right.item.img or as.faid,h2x,bary,0,scale,scale)
		end
	end
	
	for i=1,4 do
		local slot = player.slots[i]
		if selected == slot.item then
			drawOpenContainer(slot.item,b1x+(i-1)*(ih+mar),bary,ih+mar,scale)
			selectedFound = true
		elseif selected == slot then		
			if slot.type == "slot" then
				drawSlot(selected,b1x+(i-1)*(ih+mar),bary,scale)
				selectedFound = true
			elseif slot.type == "folder" then
				drawOpenFolder(selected,b1x+(i-1)*(ih+mar),bary,ih+mar,scale)
				selectedFound = true
			end
		else
			drawSlot(slot,b1x+(i-1)*(ih+mar),bary,scale)
			lg.setFont(fontsml)
			if menulevel == 0 then lg.print(i,b1x+(i-1)*(ih+mar)+4,bary+4) end
		end
	end
	
	for i,slot in ipairs(context.slots) do
		drawSlot(slot,b2x+(i-1)*(ih+mar),bary,scale)
		if menulevel == 0 then lg.print(i+4,b2x+(i-1)*(ih+mar)+4,bary+4) end	
	end
	
	if not selectedFound and not (selected == player) then
		if selected.type == "container" then
			drawOpenContainer(selected,h1x,bary-ih-mar,ih+mar,scale)
		elseif selected.type == "folder" then
			drawOpenFolder(selected,h1x,bary-ih-mar,ih+mar,scale)
		end
	end
	
	--lg.print(selected.name,0,0)
	--lg.print(selected.type,0,25)
	--lg.print(tostring(selectedFound),0,50)
	
	drawGround(ih+mar,scale,mx-(ih/2))
end



function drawInfoPanel(x,y,texts)
	

	lg.setColor(3,150,150,200)	
	local w = fontsml:getWidth("allow you to pick up containers")+60
	local lh = (fontsml:getHeight('a')+3)
	local h = (#texts+2)*lh
	lg.rectangle('fill',x,y,w,h)
	lg.setLineWidth(3)
	lg.setColor(33,180,180)
	lg.rectangle('line',x+5,y+5,w-10,h-10)
	
	lg.setColor(255,255,255)
	lg.setLineWidth(1)
	for i,v in ipairs(texts) do
		lg.print(v,x+20,y+(i)*lh)
	end
	
	lg.setColor(255,255,255)
end

function drawGround(ihm,scale,sx)
	for i=2,math.floor(#inv.ground) do
		local v = inv.ground[i] or nil
		if v then
			lg.draw(as.emptyslot,sx+((i-1)*ihm),0,0,scale,scale)
			lg.draw(v.img or as.faid,sx+((i-1)*ihm),0,0,scale,scale)
		end
	end
	for i=1,#inv.ground-1,-1 do
		local v = inv.ground[#inv.ground-i] or nil
		if v then
			local x = sx-((i+1)*ihm)
			lg.draw(as.emptyslot,x,0,0,scale,scale)
			lg.draw(v.img or as.faid,x,0,0,scale,scale)
		end
	end
	local v = inv.ground[1] or nil
	if v then
		lg.draw(as.emptyslot,sx-(ihm/2),0,0,scale,scale)
		lg.draw(v.img or as.faid,sx-(ihm/2),0,0,scale,scale)
		
		lg.setColor(0,0,0)
		lg.setFont(font)
		lg.print(v.name,sx-(font:getWidth(v.name)/2)+2,ihm+2)
		lg.setFont(fontsml)
		local text ="Press t to take item, or [] to move list"
		lg.print(text,sx-(fontsml:getWidth(text)/2)+2,ihm+font:getHeight(v.name)+5+2)
		
		lg.setColor(255,255,255)
		lg.setFont(font)
		lg.print(v.name,sx-(font:getWidth(v.name)/2),ihm)
		lg.setFont(fontsml)
		local text ="Press t to take item, or [] to move list"
		lg.print(text,sx-(fontsml:getWidth(text)/2),ihm+font:getHeight(v.name)+5)
	end
end

function drawSlot(slot,x,y,scale)
	if slot == selected then
		lg.setColor(255,0,0)
	else
		lg.setColor(255,255,255)
	end
	
	if slot.type == "folder" and not (selected == slot) then
		for i=#slot.slots,1,-1 do
			lg.draw(as.back,x,y-(i*4),0,scale,scale)
		end
		--local mostAccess = contextSlots(slot,1)
		if slot.item then 
			lg.draw(as.emptyslot,x,y,0,scale,scale)
			lg.draw(slot.item.img or as.faid,x,y,0,scale,scale)
		else
			local img = slot.img or as.emptyslot
			lg.draw(img,x,y,0,scale,scale)
		end
	elseif slot.item and slot.item.type == "container" then --and not (selected == slot.item) then
		if not (selected == slot.item) then
			for i=#slot.item.slots,1,-1 do
				lg.draw(as.back,x,y-(i*4),0,scale,scale)
			end
		end
	
		if slot.item then 
			lg.draw(as.emptyslot,x,y,0,scale,scale)
			lg.draw(slot.item.img or as.faid,x,y,0,scale,scale)
		else
			local img = slot.img or as.emptyslot
			lg.draw(img,x,y,0,scale,scale)
		end
	elseif slot.type == "slot" then
		
		if slot.item then 
			lg.draw(as.emptyslot,x,y,0,scale,scale)
			lg.draw(slot.item.img or as.faid,x,y,0,scale,scale)
		else
			local img = slot.img or as.emptyslot
			lg.draw(img,x,y,0,scale,scale)
		end
	end
	
	
	
end

function drawOpenFolder(slot,x,y,ihm,scale)
	lg.setColor(255,255,255)
	
	for i=#slot.slots,1,-1 do
		local nslot = slot.slots[i]
		drawSlot(nslot,x,y-(i*ihm),scale)
		lg.print(i,x+4,y-(i*ihm)+4)
	end	
	
	local img2 = slot.img or as.emptyslot
	lg.draw(img2,x,y,0,scale,scale)
	if slot.item then 
		lg.draw(slot.item.img or as.faid,x,y,0,scale,scale)
	end
	lg.print('~',x+4,y+4)
end

function drawOpenContainer(container,x,y,ihm,scale)
	lg.setColor(255,255,255)
	
	for i=#container.slots,1,-1 do
		local nslot = container.slots[i]
		drawSlot(nslot,x,y-(i*ihm),scale)
		lg.print(i,x+4,y-(i*ihm)+4)
	end	
	
	local img2 = as.emptyslot
	lg.draw(img2,x,y,0,scale,scale)
	lg.draw(container.img or as.backpack,x,y,0,scale,scale)
	lg.print('~',x+4,y+4)
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
