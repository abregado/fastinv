inv = require 'fastinv'

function love.load()
	--select the itemtypes that the inventory system knows about
	inv.init({"anytype","fluffy","scary","blue"},{"anysize","small","large"})
	--quickly create generic inventory structure
	inv1 = inv.new("Bundle",{"Hat",{"Slot 1","Slot 2","Slot 3","Slot 4"},"Feet"})
	--modify individual slots directly
	sack = inv1.slots[2]
	sack.name = "(1) Sack"
	--add new slots after creation
	bag = inv1:addSlot(inv.new("(2) Bag",{"Slot 1","Slot 2","Slot 3"}))
	--add items to slots	
	ruby = inv.newItem("Ruby")
	bag.slots[1]:addItem(ruby)
	
end

function love.draw()
	inv1:draw()
end

function love.keypressed(key)
	if key == '1' then sack:toggle() end
	if key == '2' then bag:toggle() end
	if key == 'v' then
		if inv1.draw == inv.draw then inv1.draw = inv.drawVert 
		elseif inv1.draw == inv.drawVert then inv1.draw = inv.draw end
	end
end
