inv = require 'fastinv' 

local lg = love.graphics
local font = love.graphics.newFont(30)
local fontsml = love.graphics.newFont(15)
love.graphics.setFont(font)

local as = {}
--as.map = lg.newImage('/assets/bgmap.png')
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
as.outfit = lg.newImage('/assets/whiteoutfit.png')
as.card = lg.newImage('/assets/idcard.png')
as.pda = lg.newImage('/assets/pda.png')
as.pen = lg.newImage('/assets/pen.png')
as.lighter = lg.newImage('/assets/lighter.png')


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
	love.graphics.setDefaultFilter("nearest","nearest")
	inv.init(types,sizes)
	
	player = inv.new("Player")
	
	simple = player:addSlot(inv.newSlotFolder("Worn:Simple"))
	simple.img = as.glasses
	complex = player:addSlot(inv.newSlotFolder("Worn:Complex"))
	complex.img = as.suit
	body = player:addSlot(inv.newSlot("Body",{"clothing","anysize"},false,true,1))
	body.img = as.uniform
	pack = player:addSlot(inv.newSlot("Back",{"large","backpack","satchel","jetpack","canister","tool","slingable"},true,true))
	pack.img = as.suitstore
	rucksack = inv.newContainerItem("Rucksack",{"backpack","large"},5,{"anytype","small"})
	rucksack.img = as.backpack
	pack:addItem(rucksack)
	
	head = simple:addSlot(inv.newSlot("Head",{"helmet","hat","anysize"},false,true))
	head.img = as.head
	eyes = simple:addSlot(inv.newSlot("Eyes",{"glasses","visor","anysize"},false,true))
	eyes.img = as.glasses
	hands = simple:addSlot(inv.newSlot("Hands",{"gloves","anysize"},false,true))
	hands.img = as.gloves
	ears = simple:addSlot(inv.newSlot("Ears",{"earpiece","anysize"},false,true))
	ears.img = as.ears
	
	bodyexo = complex:addSlot(inv.newSlot("Body external",{"armor","jacket","anysize","canister","slingable"},false,true))
	bodyexo.img = as.suit
	shoes = complex:addSlot(inv.newSlot("Feet",{"shoes","boots","anysize"},false,true))
	shoes.img = as.shoes
	mask = complex:addSlot(inv.newSlot("Face",{"mask","anysize"},false,true))
	mask.img = as.mask
	
	hands = inv.new("Hands")
	left = hands:addSlot(inv.newSlot("Left Hand",{"anytype","anysize"},false))
	left.img = as.lhand
	right = hands:addSlot(inv.newSlot("Right Hand",{"anytype","anysize"},false))
	right.img = as.rhand
		
	selected = player
	curHand = left
	
	outfit = inv.newContainerItem("Uniform",{"clothing","large"},
		{
			inv.newSlot("Belt",{"belt","large"},true,true),
			inv.newSlot("Pocket",{"anytype","small"},true),
			inv.newSlot("Pocket",{"anytype","small"},true),
			inv.newSlot("PDA Clip",{"pda","card","small"},true,true,2),
			inv.newSlot("ID Clip",{"pda","card","small"},true,true,2)
			}
	)
	outfit.img = as.outfit
	outfit.slots[1].img = as.belt
	outfit.slots[2].img = as.pocket
	outfit.slots[3].img = as.pocket
	outfit.slots[4].img = as.id
	outfit.slots[5].img = as.id
	
	idcard = inv.newItem("Scientist ID Card",{"card","small"})
	idcard.img = as.card
	pda = inv.newItem("Science PDA",{"pda","small"})
	pda.img = as.pda
	pen = inv.newItem("Pen",{"tool","small"})
	pen.img = as.pen
	lighter = inv.newItem("Lighter",{"tool","small"})
	lighter.img = as.lighter
	
	outfit.slots[2]:addItem(pen)
	outfit.slots[3]:addItem(lighter)
	outfit.slots[4]:addItem(idcard)
	outfit.slots[5]:addItem(pda)
	
	body:addItem(outfit)
	
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

function love.keypressed(key)
	local ALT = love.keyboard.isDown('lalt')
	local CTRL = love.keyboard.isDown('lctrl')
	local SHIFT = love.keyboard.isDown('lshift')
	
	if not (ALT and CTRL and SHIFT) then
		--normal non inventory keypress
		--inventory num keypress
		invKeypressed(key)
	elseif ALT then
		--ALT keypress
	elseif CTRL then
		--CTRL keypress
	elseif SHIFT then
		--SHIFT keypress
	end	
end

function handToSlot(slot)
	--put current hand item into slot, or if slot is full, leave it in hand
	local taken = slot:takeItem()
	local placed = curHand:addItem(taken)
	if placed then slot:addItem(taken) end
end

function slotToHand(slot)
	--put item in slot from current hand
	local taken = curHand:takeItem()
	local placed = slot:addItem(taken)
	if placed then curHand:addItem(taken) end
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
		if selected.slots[numkey] then slot = selected.slots[numkey] end
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
		elseif slot.item and slot.item.type == "item" and curHand.item == nil then
			handToSlot(slot)
		elseif slot.item == nil and curHand.item then
			slotToHand(slot)
		end
	end
	
	if key == '`' then
		menulevel = 0
		selected = player
	elseif key == 'x' then
		swapHand()
	elseif key == 'e' then
		local taken = curHand:takeItem()
		if player:autoEquip(taken) then curHand:addItem(taken) end
	elseif key == 'q' then
		local taken = curHand:takeItem()
		if player:autoStow(taken) then curHand:addItem(taken) end
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

function love.draw()
	--local bx,by = (lg.getWidth()/2)-(as.map:getWidth()/2),(lg.getHeight()/2)-(as.map:getHeight()/2)
	--lg.draw(as.map,bx,by)
	
	local ih = 48
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
	if curHand == left then lhand = as.lhandact else rhand = as.rhandact end
	
	lg.draw(lhand,h1x,bary,0,scale,scale)
	if left.item then 
		lg.draw(left.item.img or as.faid,h1x,bary,0,scale,scale)
	end
	lg.draw(rhand,h2x,bary,0,scale,scale)
	if right.item then 
		lg.draw(right.item.img or as.faid,h2x,bary,0,scale,scale)
	end
	
	for i=1,4 do
		local slot = player.slots[i]
		if selected == slot.item then
			drawOpenContainer(slot,b1x+(i-1)*(ih+mar),bary,ih+mar,scale)
		elseif selected == slot then		
			if slot.type == "slot" then
				drawSlot(selected,b1x+(i-1)*(ih+mar),bary,scale)
			elseif slot.type == "folder" then
				drawOpenFolder(selected,b1x+(i-1)*(ih+mar),bary,ih+mar,scale)
			end
		else
			drawSlot(slot,b1x+(i-1)*(ih+mar),bary,scale)
			lg.setFont(fontsml)
			if menulevel == 0 then lg.print(i,b1x+(i-1)*(ih+mar)+4,bary+4) end
		end
	end
	
	for i=1,4 do
		lg.draw(as.emptyslot,b2x+(i-1)*(ih+mar),bary,0,scale,scale)
			
	end
	
	--if not selected == player then
		
	--end
	
	
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
	end
	
	if slot.item and slot.item.type == "container" and not (selected == slot.item) then
		for i=#slot.item.slots,1,-1 do
			lg.draw(as.back,x,y-(i*4),0,scale,scale)
		end
	end
	
	
	local img = slot.img or as.emptyslot
	lg.draw(img,x,y,0,scale,scale)
	if slot.item then 
		lg.draw(slot.item.img or as.faid,x,y,0,scale,scale)
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

function drawOpenContainer(slot,x,y,ihm,scale)
	lg.setColor(255,255,255)
	
	for i=#slot.item.slots,1,-1 do
		local nslot = slot.item.slots[i]
		drawSlot(nslot,x,y-(i*ihm),scale)
		lg.print(i,x+4,y-(i*ihm)+4)
	end	
	
	local img2 = slot.img or as.emptyslot
	lg.draw(img2,x,y,0,scale,scale)
	lg.draw(slot.item.img or as.backpack,x,y,0,scale,scale)
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
