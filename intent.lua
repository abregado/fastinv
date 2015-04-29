local lg = love.graphics

it = {}

it.intents = {
	"help",
	"harm"
	}
	
it.state = 1

it.helpimg = lg.newImage('/assets/help.png')
it.harmimg = lg.newImage('/assets/harm.png')

function it.switch()
	if it.state == 1 then
		it.state = 2 
	else
		it.state = 1
	end
end

function it.draw(x,y,scale)
	lg.setColor(255,255,255)
	local ih = it.helpimg:getWidth()*scale
	lg.draw(it.helpimg,x,y,0,scale,scale)
	lg.draw(it.harmimg,x+ih,y,0,scale,scale)
	if it.state == 1 then
		lg.setColor(0,255,0)
	else
		lg.setColor(255,0,0)
	end
	lg.setLineWidth(4)
	lg.rectangle("line",x+((it.state-1)*ih),y,ih,ih)
	lg.setLineWidth(1)
	lg.setColor(255,255,255)
end


return it
