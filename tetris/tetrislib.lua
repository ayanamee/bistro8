
--board variables
h = 20*6
w = 10*6
thickness=2
bx0= 10
by0= 0
x0= bx0+thickness
y0= by0+thickness
bg_color = 0


x_tbf = bx0 + w + 2*thickness + 4
y_tbf = by0

--tetromino variables
speed = 1
current_tet = {}
ghost = {}

--gravity
gravity_buffer = 0
default_g_force = 1
high_g = 31
g_force = default_g_force
coyote_buffer = 0

right_buffer=0
right_force=6
left_buffer=0
left_force=6
buffer_limit=10

das_buffer = 0
das_limit = 3
das_force = 4

das=5
arr=1

--animations
clear_anim={clearing=false, frames=0, }

--Game States
g_frames=0
running = 0

total_lines = 0

board = {}

Tetromino = {sprite = 0, cs=1, shape={}, x=x0, y=y0, idx=1, idy=1, name='', flipx=false, flipy=false, alive=1, color=0} 
Tetromino.__index = Tetromino

function log(text, ow)
    printh(text, "log", ow)
end


function init_board()
    for i=-3, 20,1 do
        board[i]={}
        for j=1, 10 do
            board[i][j] = {full = 0, x=x0+6*(j-1),y=y0+6*(i-1), color = 0}
        end
    end
end

function draw_board(game_over)
    local c = 0
    local c1, c2 = 0
    for i=1, 20 do
        for j=1, 10 do
            if board[i][j].full == 1 then
                c = board[i][j].color    
                if game_over then c=13 end
                rectfill(board[i][j].x, board[i][j].y, board[i][j].x+5, 5+board[i][j].y, c)
            else
                c = 0
                c1 = (i)%2
                c2 = (j)%2
                if c1==1 and c2==1 then c = 5 end
                rectfill(board[i][j].x, board[i][j].y, board[i][j].x, board[i][j].y, c)
            end
        end
        print(i,board[i][1].x-10,board[i][1].y,8)

    end

end



function Tetromino:new(o)
    o = o or {}
    setmetatable(o, self)
    o.cs=1
    o.rotation=1
    o.idx=1
    o.idy=1
    alive=1
    flipx=false
    flipy=false
    return o
end

function Tetromino:new_I()
    local I = Tetromino:new({name = "I", sprite = 9,
    shape={ {{2,1}, {2,2}, {2,3}, {2,4}},
            {{1,3}, {2,3}, {3,3}, {4,3}},
            {{3,1}, {3,2}, {3,3}, {3,4}},
            {{1,2}, {2,2}, {3,2}, {4,2}},
            }, color=12})
    I.idx = 4
    I.idy = 0
    return I
end

function Tetromino:new_O()
    O = Tetromino:new({name = "O", sprite = 3,
    shape={ {{1,2}, {1,3}, {2,2}, {2,3}},
            {{1,2}, {1,3}, {2,2}, {2,3}},
            {{1,2}, {1,3}, {2,2}, {2,3}},
            {{1,2}, {1,3}, {2,2}, {2,3}},
            }, color=10})
    O.idx = 4
    O.idy = 0
    return O
end

function Tetromino:new_J()
    J = Tetromino:new({name = "J", sprite = 5,
    shape={ {{1,1}, {2,1}, {2,2}, {2,3}},
            {{1,2}, {1,3}, {2,2}, {3,2}},
            {{2,1}, {2,2}, {2,3}, {3,3}},
            {{1,2}, {2,2}, {3,2}, {3,1}},  
            }, color=1})
    J.idx = 4
    J.idy = 0
    return J
end

function Tetromino:new_L()
    L = Tetromino:new({name = "L", sprite = 7,
    shape={ {{1,3}, {2,1}, {2,2}, {2,3}},
            {{1,2}, {2,2}, {3,2}, {3,3}},
            {{2,1}, {2,2}, {2,3}, {3,1}},
            {{1,1}, {1,2}, {2,2}, {3,2}},      
            }, color=9})
    L.idx = 4
    L.idy = 0
    return L
end

function Tetromino:new_S()
    S = Tetromino:new({name = "S", sprite = 11,
    shape={ {{1,2}, {1,3}, {2,1}, {2,2}},
            {{1,2}, {2,2}, {2,3}, {3,3}},
            {{2,2}, {2,3}, {3,1}, {3,2}},
            {{1,1}, {2,1}, {2,2}, {3,2}},  
            }, color=11})
    S.idx = 4
    S.idy = 0
    return S
end

function Tetromino:new_Z()
    Z = Tetromino:new({name = "Z", sprite = 13,
    shape={ {{1,1}, {1,2}, {2,2}, {2,3}},
            {{1,3}, {2,2}, {2,3}, {3,2}},
            {{2,1}, {2,2}, {3,2}, {3,3}},
            {{1,2}, {2,1}, {2,2}, {3,1}}, 
         }, color=8})
    Z.idx = 4
    Z.idy = 0
    return Z
end

function Tetromino:new_T()
    T = Tetromino:new({name = "T", sprite = 1,
    shape={ {{1,2}, {2,1}, {2,2}, {2,3}},
            {{1,2}, {2,2}, {3,2}, {2,3}},
            {{2,1}, {2,2}, {2,3}, {3,2}},
            {{1,2}, {2,1}, {2,2}, {3,2}}, 
         }, color=14})
    T.idx = 4
    T.idy = 0
    return T
end



function init_tetrominoes()

    Tetromino.__index = Tetromino


    
    tet_list = {index=2, tcount=7}
    
    insert_tet_bag(tet_list)



    dead_tets = {}
end

-- function Tetromino:rotate(direction) --direction to rotate 0 is CW/ 1 IS ACCW

-- end


function Tetromino:draw()
    --spr(self.sprite, self.x, self.y, 2, 2, self.flipx , self.flipy)
    spr(self.sprite, self.x, board[self.idy][self.idx].y, 2, 2, self.flipx , self.flipy)
    -- for i=1, 4 do
    --     a = self.shape[i][2] - 1 + self.x
    --     b = self.shape[i][1] - 1 + board[self.idy][self.idx].y

    --     pset(a,b, 15)
    -- end

end


function Tetromino:draw_tet()
    local a, b, xx, yy
    for i=1, 4 do
        a = self.shape[self.cs][i][2] + self.idx - 1
        b = self.shape[self.cs][i][1] + self.idy - 1 

        if b < 0 then goto ignore end
        xx = board[b][a].x
        yy = board[b][a].y

        rectfill(xx,yy,xx+5,yy+5,self.color)
        ::ignore::
    end
end


function Tetromino:draw_ghost()
    tmp_y = self.idy
    log("y="..self.idy, true)

    for j = tmp_y ,19,1 do
        tmp_y = j
        if j >= 20 then
            break
        end
        if self:check_collision(self.cs,self.idx,j+1) then
            break
        end
        tmp_y = j
    end
    
    log("tmp_y="..tmp_y)

    local a, b, xx, yy
    for i=1, 4 do
        a = self.shape[self.cs][i][2] + self.idx - 1
        b = self.shape[self.cs][i][1] + tmp_y - 1 

        if b < 0 then goto ignore end
        xx = board[b][a].x
        yy = board[b][a].y

        rectfill(xx,yy,xx+5,yy+5,6)
        ::ignore::
    end
end



function Tetromino:move_right(amount, right_bound)
    if self.alive==1 then
        if not self:check_collision(self.cs, self.idx+1, self.idy) then
            self.x += amount
            self.idx +=1
        end
    end
end

function Tetromino:move_left(amount, left_bound)
    if self.alive==1 then
        if not self:check_collision(self.cs,self.idx-1, self.idy) then
            self.x += amount
            self.idx -=1
        end
    end
end

function Tetromino:rotate(clockwise)
    local aux = 0
    if clockwise then aux=1 else aux=-1 end
    next_rot = self.cs+aux
    if next_rot == 5 then next_rot = 1 end
    if next_rot == 0 then next_rot = 4 end


    if self.alive == 1 then
        if not self:check_collision(next_rot, self.idx, self.idy) then
            self.cs= next_rot
        end
    end

end


function Tetromino:gravity(force, lower_bound)
    if self.alive==1 then
        gravity_buffer+=force
        if(gravity_buffer>30) then
            if self.idy == 20 or self:check_collision(self.cs,self.idx, self.idy+1) then
                coyote_buffer+=1
                if (coyote_buffer>=15) then
                    self:kill_tet()
                    if running==1 then current_tet=pop_tet(tet_list) end
                    if running==0 then return end
                    coyote_buffer = 0
                end
            else
                self.idy +=1
                gravity_buffer=0
            end
        end
    end
end


function check_rows(rows)

    local aux = 0

    rows_to_clear = {}
    n=0

    for i,r in pairs(rows) do
        for c=1, 10 do
            if board[r][c].full == 1 then
                aux+=1
            end
        end
        if aux == 10 then
            add(rows_to_clear,r)
            n+=1
        end
        aux=0
    end

    if n>0 then
        clear_rows(rows_to_clear,n)
        if n>=4 then
            sfx(4)
        else
            sfx(3)
        end
    end
end

function contains(table,value)
    for _,v in pairs(table) do
        if(v==value) then
            return true
        end
    end
    return false
end

function Tetromino:kill_tet()
    self.alive = 0
    add(dead_tets, self)
    rows={}
    for i=4,1,-1  do
        local a = self.shape[self.cs][i][2] + self.idx - 1
        local b = self.shape[self.cs][i][1] + self.idy - 1
        board[b][a].full = 1
        board[b][a].color = self.color
        if b<=0 then 
            running=0 
            log("game over")
            log(running)
            return
        end
        if not contains(rows,b) then add(rows,b) end
    end
    check_rows(rows)
end

function insert_tet(tet_list) --inserts a new random tetromino at tet_list[index]

    local index = tet_list.tcount + 2
    local rd = flr(rnd(7))
    local t

    if rd == 0 then t = Tetromino:new_I()
    elseif rd == 1 then t = Tetromino:new_O() 
    elseif rd == 2 then t = Tetromino:new_J() 
    elseif rd == 3 then t = Tetromino:new_L() 
    elseif rd == 4 then t = Tetromino:new_S() 
    elseif rd == 5 then t = Tetromino:new_Z() 
    elseif rd == 6 then t = Tetromino:new_T() end

    add(tet_list, t)

    tet_list.tcount +=1
end

function insert_tet_bag(tet_list)
    local index = tet_list.tcount + 2
    local rd
    local t
    local bag = {0,1,2,3,4,5,6}

    for i = 6,0,1 do
        rd = flr(rnd(7))
        bag[i], bag[rd] = bag[rd], bag[i]
    end

    for i = 0, 6, 1 do
        rd = bag[i]

        if rd == 0 then t = Tetromino:new_I()
        elseif rd == 1 then t = Tetromino:new_O() 
        elseif rd == 2 then t = Tetromino:new_J() 
        elseif rd == 3 then t = Tetromino:new_L() 
        elseif rd == 4 then t = Tetromino:new_S() 
        elseif rd == 5 then t = Tetromino:new_Z() 
        elseif rd == 6 then t = Tetromino:new_T() end

        add(tet_list, t)
        tet_list.tcount +=1
    end
end

function pop_tet(tet_list)  -- inserts + pops a tet from the list
    insert_tet_bag(tet_list)
    if tet_list[tet_list.index]!=0 then
        tet_list.index+=1
        var = tet_list[tet_list.index]
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

function draw_tet_buffer(tet_list)

    local next_tet = tet_list[tet_list.index+1]

    local a, b, xx, yy

    --rect(x_tbf, y_tbf, x_tbf+24, y_tbf+ 18, 5)

    print("next", x_tbf, y_tbf, 6)

    for i=1, 4 do
        a = next_tet.shape[1][i][2] - 1
        b = next_tet.shape[1][i][1]

        xx = x_tbf + a*6
        yy = y_tbf + 4 + b*6

        rectfill(xx,yy,xx+5,yy+5, next_tet.color)
    end
    --spr(next_tet.sprite, xx, yy, 2, 2)

end


function clear_rows(rows, n) -- é preciso modificar esta funçao para dar clear das ultimas N linhas
    total_lines += n
    last_row = rows[1]
    --send last row and n to global variables to animate
    for r=last_row,n+1,-1 do
        for j=1, 10 do
            board[r][j].full = board[r-n][j].full
            board[r][j].color= board[r-n][j].color
        end
    end
    for rn=n, 1,-1 do
        for j=1, 10 do
            board[rn][j].full = 0
            board[rn][j].color= 0 
        end
    end
end

function reset_board()
    for i=1, 20 do
        for j=1, 10 do
            board[i][j].full = 0
            board[i][j].color= 0 
        end
    end
    total_lines = 0
end

function Tetromino:check_collision(cs, new_idx, new_idy)
    for i=1, 4 do
        a = self.shape[cs][i][2] + new_idx - 1
        b = self.shape[cs][i][1] + new_idy - 1 

        if b > 20 or a < 1 or a > 10 then
            return true 
        end

        if board[b][a].full == 1 then
            return true
        end
    end
    return false
end