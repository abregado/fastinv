local vl = require('hump-master/vector-light')
local lg = love.graphics
local tween = require 'tween'

local flyupFont = lg.newFont(40)
local underbarFont = lg.newFont(20)
local barColor = {255,255,255}
local fontColor = {0,0,0}

aa = {}

function aa.new(animGroup)
    local o = {}
    
    o.animObjs = {}
    
    for i,v in ipairs(animGroup or {}) do
        aa.addAnimObj(o,v)
    end
    
    o.isAnim = true
    
    o.updateMovement = aa.updateAnim
    o.draw = aa.draw
    
    return o
end

function aa.addAnimObj(self,ao)
    table.insert(self.animObjs,ao)
end



function aa.newAnimObj(x,y)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255,255-(self.off*2))
        local offset = img.skull:getWidth()/2
        lg.draw(img.skull,x-offset,y-self.off-offset)
    end
    o.off = 0
    o.x = x
    o.y = y
    o.tween = tween.new(0.8,o,{off=128},'inQuad')
    
    return o
end

function aa.newHitAnim(x,y)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255,255-(self.off*2))
        local offset = img.hit:getWidth()/2
        lg.draw(img.hit,x-offset,y-self.off-offset)
    end
    o.off = 0
    o.x = x
    o.y = y
    o.tween = tween.new(0.8,o,{off=128},'inQuad')
    
    return o
end

function aa.newShootAnim(x,y,tx,ty,icon)
    local o = {}
    o.draw = function(self)
        lg.setLineWidth(3)
        lg.setColor(255,255,255)
        lg.circle("fill",self.x,self.y,10,10)
        lg.line(self.x,self.y,self.tx,self.ty)
        lg.setLineWidth(1)
    end
    o.perc = 0
    o.x = x
    o.y = y
    o.tx = tx
    o.ty = ty
    o.tween = tween.new(0.5,o,{x=tx,y=ty},'linear')
    
    return o
end

function aa.newIconShootAnim(x,y,tx,ty,icon,scale)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255)
        local ox,oy = self.icon:getWidth()/2,self.icon:getHeight()/2
        lg.draw(self.icon,self.x,self.y,self.angle,self.scale,self.scale,ox,oy)
    end
    o.perc = 0
    o.icon = icon
    o.x = x
    o.scale = scale or 1.5
    o.y = y
    o.tx = tx
    o.ty = ty
    o.angle = vl.angleTo(x-tx,y-ty)-(math.pi/4)
    o.tween = tween.new(0.5,o,{x=tx,y=ty},'linear')
    
    return o
end

function aa.newIconThrowAnim(x,y,tx,ty,icon,scale)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255)
        local ox,oy = self.icon:getWidth()/2,self.icon:getHeight()/2
        lg.draw(self.icon,self.x,self.y,self.angle,self.scale,self.scale,ox,oy)
    end
    o.perc = 0
    o.icon = icon
    o.x = x
    o.y = y
    o.scale = scale or 1.5
    o.tx = tx
    o.ty = ty
    o.angle = 0
    o.tween = tween.new(0.5,o,{x=tx,y=ty,angle=math.pi*2},'linear')
    
    return o
end

function aa.newHurtAnim(x,y)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255,255-(self.off*2))
        local offset = img.heart:getWidth()/2
        lg.draw(img.heart,x-offset,y-self.off-offset)
    end
    o.off = 0
    o.x = x
    o.y = y
    o.tween = tween.new(0.8,o,{off=128},'inQuad')
    
    return o
end

function aa.newRisingIconAnim(x,y,float,icon)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255,255-(self.off*2))
        local offset = icon:getWidth()/2
        lg.draw(icon,x-offset,y-self.off-offset)
    end
    o.off = 0
    o.x = x
    o.y = y
    o.tween = tween.new(0.8,o,{off=float},'inQuad')
    
    return o
end

function aa.updateAnim(self,dt)
    local complete = true
    for i,v in ipairs(self.animObjs) do
        if not v.tween:update(dt) then complete = false end
    end
    return complete
end

function aa.draw(self)
    for i,v in ipairs(self.animObjs) do
        v:draw()
    end
end

function aa.newToasterCome(text,font)
    local o = {}
    o.draw = function(self)
        local flyupFont = font or flyupFont
        
        local fontHeight = flyupFont:getHeight(self.text)
        local fontWidth = flyupFont:getWidth(self.text)
        
        lg.setColor(barColor)
        lg.rectangle("fill",0,self.y,lg.getWidth(),fontHeight+20)
        
        lg.setColor(fontColor)
        lg.setFont(flyupFont)
        lg.print(self.text,self.x+lg.getWidth()/2-(fontWidth/2),self.y+10)
         
    end
    o.text = text
    o.x = 0
    o.y = 0-flyupFont:getHeight(text)-20
    o.tween = tween.new(0.5,o,{y=0},'outQuad')
    
    return o
end

function aa.newToasterWait(text,wait,font)
    local o = {}
    o.draw = function(self)
        local flyupFont = font or flyupFont
        
        local fontHeight = flyupFont:getHeight(self.text)
        local fontWidth = flyupFont:getWidth(self.text)
        
        lg.setColor(barColor)
        lg.rectangle("fill",0,self.y,lg.getWidth(),fontHeight+20)
        
        lg.setColor(fontColor)
        lg.setFont(flyupFont)
        lg.print(self.text,self.x+lg.getWidth()/2-(fontWidth/2),self.y+10)
         
    end
    o.text = text
    o.x = 0
    o.blank = 0
    o.y = 0
    o.tween = tween.new(wait,o,{blank=10},'outQuad')
    
    return o
end

function aa.newToasterGo(text,font)
    local o = {}
    o.draw = function(self)
        
        local flyupFont = font or flyupFont
        
        local fontHeight = flyupFont:getHeight(self.text)
        local fontWidth = flyupFont:getWidth(self.text)
        
        lg.setColor(barColor)
        lg.rectangle("fill",0,self.y,lg.getWidth(),fontHeight+20)
        
        lg.setColor(fontColor)
        lg.setFont(flyupFont)
        lg.print(self.text,self.x+lg.getWidth()/2-(fontWidth/2),self.y+10)
        
    end
    o.text = text
    o.x = 0
    o.y = 0
    o.tween = tween.new(0.2,o,{y=0-flyupFont:getHeight(text)-20},'outQuad')
    
    return o
end



return aa
