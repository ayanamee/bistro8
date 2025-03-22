--[[

Tetromino : metatable for all tetrominoes

]]
Tetromino = {sprite = 0, x=0, y=0, name='', rotation=0} 
Tetromino.__index = Tetromino

function Tetromino:new(o)
    o = o or {}
    setmetatable(o, self)
    o.rotation=0
    o.x=0
    o.y=0
    return o
end

function init_tetrominoes()

    Tetromino.__index = Tetromino

    I = Tetromino:new({name = "I", sprite = 9})
    O = Tetromino:new({name = "O", sprite = 3})
    J = Tetromino:new({name = "J", sprite = 5})
    L = Tetromino:new({name = "L", sprite = 7})
    S = Tetromino:new({name = "S", sprite = 13})
    Z = Tetromino:new({name = "Z", sprite = 11})
    T = Tetromino:new({name = "T", sprite = 1})

    
    tet_list = {I, O, J, L, S, Z, T}

end

-- function Tetromino:rotate(direction) --direction to rotate 0 is CW/ 1 IS ACCW

-- end


function Tetromino:draw()
    spr(self.sprite, self.x, self.y, 2, 2, flr(self.rotation/2) , self.rotation%2)
end

function Tetromino:move(amount, left_bound, right_bound)
    if self.x+amount<right_bound and self.x+amount>left_bound then
        self.x += amount
    end
    --check for collision etc
end

function Tetromino:gravity(force)
    gravity_buffer+=force
    print("HEY")
    if(gravity_buffer>30) then
        self.y += 4
        gravity_buffer=0
        print("DOWN")
    end
end
