inv = require('fastinv')

local ss = {}

function ss.newItem(name,types,img,intents)
	local o = inv.newItem(name,types)
	o.img = img
	o.intents = intents
	o.active = false
	o.activate = ss.activate
	return o
end

function ss.newSlot(name,stores,autostow,equiptarget,priority,img,contextual)
	local o = inv.newSlot(name,stores,autostow,equiptarget,priority)
	o.img = img
	o.contextual = contextual
	return o
end

function ss.newContainerItem(name,types,slots,stores,img)
	local o = inv.newItem(name,types)
	o.img = img
	o.type = "container"
	--if given a table, use those slots, otherwise generate a number of slots using stores, otherwise make 3 any slots
	if type(slots) == "table" then
		o.slots = slots
	elseif type(slots) == "number" then
		o.slots = {}
		for i=1,slots do
			inv.addSlot(o,ss.newSlot(name.." s"..i,stores,true,false,0,nil,false))
		end
	else
		o.slots = {}
		for i=1,3 do
			inv.addSlot(o,ss.newSlot(name.." s"..i,{"anysize","anytype"},true,false,0,nil,false))
		end
	end
	o.toggle = inv.toggle
	o.addItem = inv.autoStow
	o.addSlot = inv.addSlot
	return o
end

function ss.activate(self)
	print(self.name.." was activated")
	self.active = not self.active
	return true
end

return ss
