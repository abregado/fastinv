local aa = require('attackAnim')
local lg = require('love.graphics')
local vl = require('/hump-master/vector-light')
local tween = require 'tween'
local gs = require ('hump-master.gamestate')

local flyupFont = lg.newFont(40)
local underbarFont = lg.newFont(20)
local barColor = {255,255,255}
local fontColor = {0,0,0}

local trans = {}

function trans.new(animations)
    local state = {}
    
    state.animRegister = {}
    state.from = nil
    
    state.draw = trans.draw
    state.update = trans.update
    state.keypressed = trans.keypressed
    state.mousepressed = trans.mousepressed
    state.enter = trans.enter
    state.addToRegister = trans.addToRegister
    
    for i,v in ipairs(animations) do
        state:addToRegister(v)
    end
    
    return state
end

function trans:addToRegister(anim,force)
    if force then
        table.insert(self.animRegister,1,anim)
    else
        table.insert(self.animRegister,anim)
    end
end

function trans:draw()
    
    if self.animRegister[1] and self.animRegister[1].isAnim then
        self.animRegister[1]:draw()
    end
    
end

function trans:update(dt)
    if self.animRegister[1] then
        local complete = self.animRegister[1]:updateMovement(dt)
        if complete then 
            table.remove(self.animRegister,1) 
        end
    else
       gs.switch(game)
    end
end

function trans:keypressed()
    if self.animRegister[1] then
        table.remove(self.animRegister,1)
    end
end

function trans:mousepressed()
    if self.animRegister[1] then
        table.remove(self.animRegister,1)
    end
end

function trans:enter(from)
    self.from = from
end

function trans.newFadeout(text,startY,bad)
    local o = {}
    o.draw = function(self)
        
        local alpha = self.alpha
        if alpha > 255 then alpha = 255 end
        
        local topH = lg.getHeight()/2*self.perc
        local botY = lg.getHeight()-(lg.getHeight()/2*self.perc)
        if bad then lg.setColor(255,0,0,alpha/4) else lg.setColor(0,0,255,alpha/4) end
        lg.rectangle("fill",0,0,lg.getWidth(),topH)
        lg.rectangle("fill",0,botY,lg.getWidth(),lg.getHeight())
        
        local fontHeight = flyupFont:getHeight(self.text)
        local fontWidth = flyupFont:getWidth(self.text)
        
        
        lg.setColor(barColor[1],barColor[2],barColor[3],alpha)
        lg.rectangle("fill",0,self.y-10,lg.getWidth(),fontHeight+20)
        
        lg.setColor(fontColor[1],fontColor[2],fontColor[3],alpha)
        lg.setFont(flyupFont)
        lg.print(self.text,self.x+lg.getWidth()/2-(fontWidth/2),self.y)

        
    end
    o.text = text
    o.x = 0
    o.y = startY or lg:getHeight()/2
    o.alpha = 512
    o.perc = 1
    o.tween = tween.new(1.5,o,{alpha=0},'inQuad')
    
    return o
end


function trans.newFlyup(text,endY,bad)
    local o = {}
    o.draw = function(self)
        local topH = lg.getHeight()/2*self.perc
        local botY = lg.getHeight()-(lg.getHeight()/2*self.perc)
        if bad then lg.setColor(255,0,0,255/4) else lg.setColor(0,0,255,255/4) end
        lg.rectangle("fill",0,0,lg.getWidth(),topH)
        lg.rectangle("fill",0,botY,lg.getWidth(),lg.getHeight())
        
        
        local fontHeight = flyupFont:getHeight(self.text)
        local fontWidth = flyupFont:getWidth(self.text)
        
        lg.setColor(barColor)
        lg.rectangle("fill",0,self.y-10,lg.getWidth(),fontHeight+20)
        
        lg.setColor(fontColor)
        lg.setFont(flyupFont)
        lg.print(self.text,self.x+lg.getWidth()/2-(fontWidth/2),self.y)

        
    end
    o.text = text
    o.x = 0
    o.y = lg.getHeight()
    o.perc = 0
    o.tween = tween.new(0.5,o,{y=endY or -100,perc=1},'linear')
    
    return o
end

function trans.newUnderbar(text,endY,bad)
    local o = {}
    o.draw = function(self)
        
        local fontHeight = underbarFont:getHeight(self.text)
        local fontWidth = underbarFont:getWidth(self.text)
        
        lg.setColor(barColor)
        lg.rectangle("fill",0,self.y-10,lg.getWidth(),fontHeight+20)
        
        lg.setColor(fontColor)
        lg.setFont(underbarFont)
        lg.print(self.text,self.x+lg.getWidth()/2-(fontWidth/2),self.y)
        
        if bad then lg.setColor(255,0,0,60) else lg.setColor(0,0,255,60) end
        lg.rectangle("fill",0,self.y+fontHeight+10,lg:getWidth(),1000)
        
    end
    o.text = text
    o.x = 0
    o.y = lg.getHeight()+40
    o.tween = tween.new(3,o,{y=endY or -60},'outQuad')
    
    return o
end

function trans.newImageFadeIn(img,x,y,fadeTime)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255,self.alpha)
        lg.draw(self.img,self.x,self.y,0,1,1,centered and self.img:getWidth()/2,centered and self.img:getHeight()/2)
    end
    o.alpha = 0
    o.x = x
    o.y = y
    o.img = img
    o.tween = tween.new(fadeTime,o,{alpha = 255},'outQuad')
    
    return o
end

function trans.newImageFadeOut(img,x,y,fadeTime)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255,self.alpha)
        lg.draw(self.img,self.x,self.y,0,1,1,centered and self.img:getWidth()/2,centered and self.img:getHeight()/2)
    end
    o.alpha = 255
    o.x = x
    o.y = y
    o.img = img
    o.tween = tween.new(fadeTime,o,{alpha = 0},'outQuad')
    
    return o
end

function trans.newImageDisplay(img,x,y,waitTime,centered,scale)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255)
        lg.draw(self.img,self.x,self.y,0,self.scale,self.scale)
    end
    o.timer = 0
    o.scale = scale
    o.x = x
    o.y = y
    if centered then
        o.x,o.y = o.x+img:getWidth()/2, o.y+img:getHeight()/2
    end
    o.img = img
    o.tween = tween.new(waitTime,o,{timer = 100},'linear')
    
    return o
end

function trans.newQuadFlyIn(img,ox,oy,flyTime)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255)
        for i,v in ipairs(self.quads) do
            local x = (v.sx*(self.completion))+v.tx
            local y = (v.sy*(self.completion))+v.ty
            lg.draw(self.img,v.quad,x,y)
        end
    end
    o.completion = 10
    o.x = ox
    o.y = oy
    o.img = img
    o.quads = {}
    local tw,th = 25,10
    for i=1, tw do
        for v=1,th do
            local w,h = img:getWidth()/tw,img:getHeight()/th
            local x,y = math.floor(w*(i-1)),math.floor(h*(v-1))
            local newChunk = {quad=lg.newQuad(x,y,w,h,o.img:getWidth(),o.img:getHeight()),tx=x+ox,ty=y+oy,sx=math.random(-10,10),sy=math.random(-100,100)}
            table.insert(o.quads,newChunk)
        end
    end
    o.tween = tween.new(flyTime,o,{completion = 0},'outQuart')
    
    return o
end

function trans.newQuadFlyOut(img,ox,oy,flyTime)
    local o = {}
    o.draw = function(self)
        lg.setColor(255,255,255,self.alpha)
        for i,v in ipairs(self.quads) do
            local x = (v.sx*(self.completion))+v.tx
            local y = (v.sy*(self.completion))+v.ty
            lg.draw(self.img,v.quad,x,y)
        end
    end
    o.completion = 0
    o.alpha = 255
    o.x = ox
    o.y = oy
    o.img = img
    o.quads = {}
    local tw,th = 25,10
    for i=1, tw do
        for v=1,th do
            local w,h = img:getWidth()/tw,img:getHeight()/th
            local x,y = math.floor(w*(i-1)),math.floor(h*(v-1))
            local newChunk = {quad=lg.newQuad(x,y,w,h,o.img:getWidth(),o.img:getHeight()),tx=x+ox,ty=y+oy,sx=math.random(-10,10),sy=math.random(-100,100)}
            table.insert(o.quads,newChunk)
        end
    end
    o.tween = tween.new(flyTime,o,{completion = 100,alpha = 0},'outQuart')
    
    return o
end




return trans
