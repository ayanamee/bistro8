
--board variables
h = 20*4
w = 10*4
thickness=2
bx0= 1
by0= 1
x0= bx0+thickness
y0= by0+thickness

bg_color = 0

--tetromino variables
speed = 1
current_tet = {}

--gravity
gravity_buffer = 0
default_g_force = 2
high_g = 30
g_force = default_g_force

--Game States
running = 0

board = {}

Tetromino = {sprite = 0, shape={}, x=x0, y=y0, idx=1, idy=1, name='', flipx=false, flipy=false, alive=1} 
Tetromino.__index = Tetromino


function init_board()
    for i=1, 20 do
        board[i]={}
        for j=1, 10 do
            board[i][j] = {full = 0, x=x0+4*(j-1),y=y0+4*(i-1)}
        end
    end
end

function draw_board()
    for i=1, 20 do
        for j=1, 10 do
            --rectfill(board[i][j].x, board[i][j].y, board[i][j].x+3, 3+board[i][j].y,  5+ (i+j)%2)
            rectfill(board[i][j].x, board[i][j].y, board[i][j].x+3, 3+board[i][j].y, 1+ board[i][j].full)
        
        end
    end

end



function Tetromino:new(o)
    o = o or {}
    setmetatable(o, self)
    o.rotation=1
    o.idx=1
    o.idy=1
    alive=1
    flipx=false
    flipy=false
    return o
end

function init_tetrominoes()

    Tetromino.__index = Tetromino

    I = Tetromino:new({name = "I", sprite = 9, 
    shape={ {1,1}, {1,2}, {1,3}, {1,4}  }})

    O = Tetromino:new({name = "O", sprite = 3,
    shape={ {1,1}, {1,2}, {2,1}, {2,2} }})

    J = Tetromino:new({name = "J", sprite = 5,
    shape={ {1,1}, {2,1}, {2,2}, {2,3} }})

    L = Tetromino:new({name = "L", sprite = 7,
    shape={ {1,3}, {2,1}, {2,2}, {2,3} }})

    S = Tetromino:new({name = "S", sprite = 13,
    shape={ {1,2}, {1,3}, {2,1}, {2,2} }})

    Z = Tetromino:new({name = "Z", sprite = 11,
    shape={ {1,1}, {1,2}, {2,2}, {2,3} }})

    T = Tetromino:new({name = "T", sprite = 1,
    shape={ {1,2}, {2,1}, {2,2}, {2,3} }})

    
    tet_list = {index=1, I, O, J, L, S, Z, T}
    dead_tets = {}
end

-- function Tetromino:rotate(direction) --direction to rotate 0 is CW/ 1 IS ACCW

-- end


function Tetromino:draw()
    --spr(self.sprite, self.x, self.y, 2, 2, self.flipx , self.flipy)
    spr(self.sprite, self.x, board[self.idy][self.idx].y, 2, 2, self.flipx , self.flipy)
    print(self.idy, 0,0, 12)
end

function Tetromino:move(amount, left_bound, right_bound)
    if self.alive==1 then
        if self.x+amount<=right_bound and self.x+amount>=left_bound then
            self.x += amount
            
        end
    end
    --check for collision etc
end

function Tetromino:move_right(amount, right_bound)
    if self.alive==1 then
        if self.x+amount<=right_bound then
            if not self:check_collision(self.idx+1, self.idy) then
                self.x += amount
                self.idx +=1
            end
        end
    end
end

function Tetromino:move_left(amount, left_bound)
    if self.alive==1 then
        if self.x+amount>=left_bound then
            if not self:check_collision(self.idx-1, self.idy) then
                self.x += amount
                self.idx -=1
            end
        end
    end
end


function Tetromino:gravity(force, lower_bound)
    if self.alive==1 then
        gravity_buffer+=force
        if(gravity_buffer>30) then
            if self.idy == 19 or self:check_collision(self.idx, self.idy+1) then
                self:kill_tet()
                current_tet=pop_tetromino(tet_list)
            else
                self.idy +=1
                gravity_buffer=0
            end
        end
    end
end

function Tetromino:kill_tet()
    self.alive =0
    add(dead_tets, self)
    for i=1, 4 do
        local a = self.shape[i][2] + self.idx - 1
        local b = self.shape[i][1] + self.idy - 1
        board[b][a].full = 1
    end
end


function pop_tetromino(tet_list)
    if tet_list[tet_list.index]!=0 then
        tet_list.index+=1
        var = tet_list[tet_list.index]
        var:spawn_tet()
        return var
    end
end

function draw_dead_tets()

    if next(dead_tets) == nil then
        return
    end
    for i,tet in pairs(dead_tets) do
        tet:draw()
    end 
end

function Tetromino:spawn_tet()

    for i=1, 4 do
        local a = self.shape[i][1]
        local b = self.shape[i][2]
        --board[a][b].full = 2
    end

end

function update_board()

    for i=1, 20 do
        for j=1, 10 do
            local x = board[i][j].x
            local y = board[i][j].y
            c = pget(x,y)
            if c != 0 and board[i][j].full !=2 then
                board[i][j].full = 1
            end
        end
    end

end

function Tetromino:check_collision(new_idx, new_idy)
    for i=1, 4 do
        a = self.shape[i][2] + new_idx - 1
        b = self.shape[i][1] + new_idy - 1 

        if b < 1 or b > 20 or a < 1 or a > 10 then
            return true 
        end

        if board[b][a].full == 1 then
            return true
        end
    end
    return false
end