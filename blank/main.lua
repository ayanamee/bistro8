mode = "move"
grid_size = 4
grid_px_size = 8
grid_px_scale = 2
grid = {}
margin = 16
spacing = 1 
crs = {i = 1, j=1, sprite=1}
bag = {}

blank_cell = {sprite=0}
red_mark = {sprite=2}
blue_mark = {sprite = 3}
yellow_mark = {sprite =4}
green_mark = {sprite =5}

adjacent = {{-1,0}, {1,0}, {0,-1},{0,1}}


placed_marks = 0


function _init()
    menuitem(1, "god mode", function() if mode ~= "god" then mode = "god" else mode = "move" end end)
    create_grid()
    bag = {"blue",  "red",  "green", "yellow"}
    bag.count = 4
    bag.idx = 1
    bag.current_mark = bag[bag.idx]
end

function _update()
    handle_input()
end

function _draw()
    cls()
    rect(0,0,127,127)
    draw_grid()
    draw_cursor()
    draw_bag()
    print(mode,110,2)
    if mode == "move" then
        print("z -> advance turn", 2,114)
        print("x -> mark mode", 2,120)
    elseif mode =="mark" then
        print("z -> place mark", 2,114)
        print("x -> move mode", 2,120)
    elseif mode == "god" then
        print("z -> clear grid", 2,114)
        -- print("x -> move mode", 2,120)
        print("x -> fill grid", 2, 120)
    end
    print("marks:"..placed_marks, 2, 2)
end

function handle_input()
    if mode == "move" then
        if btnp(4) then advance_turn() end
        if btnp(5) then mode = "mark" end
        if btnp(⬅️) then crs.i = (crs.i >1) and crs.i-1 or 1 end --left
        if btnp(➡️) then crs.i = (crs.i <grid_size) and crs.i+1 or grid_size end --right
        if btnp(⬆️) then crs.j = (crs.j >1) and crs.j-1 or 1 end --up
        if btnp(⬇️) then crs.j = (crs.j <grid_size) and crs.j+1 or grid_size end --down
    elseif mode=="mark" then
        if btnp(4) then try_place_mark(crs.i,crs.j,bag.current_mark) end
        if btnp(5) then mode = "move" end
        if btnp(➡️) then 
            if (bag.idx < bag.count) then
                bag.idx += 1
            else
                bag.idx = 1
            end
            bag.current_mark = bag[bag.idx]
        end
    elseif mode=="god" then
        if btnp(4) then clear_grid() end
        -- if btnp(5) then mode = "move" end
        if btnp(5) then fill_grid() end
    end

end

function advance_turn()
    update_board()
end

function try_place_mark(i,j,mark)
    if grid[i][j].mark == "none" then
        grid[i][j].mark = mark
        grid[i][j].sprite = get_sprite(mark)
        placed_marks +=1 
    end
end


function create_grid()
    local x,y
    local id = 0
    for i=1, grid_size do
        grid[i] = {}
        for j=1, grid_size do
            x = margin + (i-1)*grid_px_size*grid_px_scale + spacing*i
            y = margin + (j-1)*grid_px_size*grid_px_scale + spacing*j
            grid[i][j]={id = id, sprite=0, x0=x, y0=y, mark="none", exploding=false}
            id+=1
        end
    end
end

function get_sprite(mark)
    if mark=="red" then return red_mark.sprite end
    if mark=="blue" then return blue_mark.sprite end
    if mark=="yellow" then return yellow_mark.sprite end
    if mark=="green" then return green_mark.sprite end
end

function fill_grid()
    for i=1, grid_size do
        for j=1, grid_size do
            roll = flr(rnd(4))
            if roll==0 then current_mark = "red" end 
            if roll==1 then current_mark = "blue" end
            if roll==2 then current_mark = "yellow" end
            if roll==3 then current_mark = "green" end
            grid[i][j].mark = current_mark
            grid[i][j].sprite = get_sprite(current_mark)
        end
    end
end

function clear_grid()
    for i=1, grid_size do
        for j=1, grid_size do
            grid[i][j].mark = nil
        end
    end
    placed_marks = 0
end

function update_board()
    for i=1, grid_size do
        for j=1, grid_size do
            if grid[i][j].mark == "red" then update_red_mark(i,j) end
            if grid[i][j].mark == "blue" then update_blue_mark(i,j) end
            if grid[i][j].mark == "green" then update_green_mark(i,j) end
        end
    end
    trigger_explosions()
end




function update_red_mark(i,j)
    
    for _,delta in ipairs(adjacent) do
        if i+delta[1] > 0 and i+delta[1] < grid_size and j+delta[2] > 0 and j+delta[2] < grid_size then
            if grid[i+delta[1]][j+delta[2]].mark == "red" then
                grid[i+delta[1]][j+delta[2]].exploding = true
                grid[i][j].exploding = true
            end
        end
    end

    -- if i>1 and grid[i-1][j].mark == "red" then 
    --     grid[i-1][j].exploding = true
    --     grid[i][j].exploding = true
    -- end
    -- if i<grid_size and grid[i+1][j].mark == "red" then 
    --     grid[i+1][j].exploding = true
    --     grid[i][j].exploding = true
    -- end
    -- if j>1 and grid[i][j-1].mark == "red" then 
    --     grid[i][j-1].exploding = true
    --     grid[i][j].exploding = true
    -- end
    -- if j<grid_size and grid[i][j+1].mark == "red" then 
    --     grid[i][j+1].exploding = true
    --     grid[i][j].exploding = true
    -- end

    if grid[i][j].exploding then
        if i>1 then grid[i-1][j].exploding = true end
        if i<grid_size then grid[i+1][j].exploding = true end
        if j>1 then grid[i][j-1].exploding = true end
        if j<grid_size then grid[i][j+1].exploding = true end
    end

end

function update_blue_mark(i,j)

    grid[i][j].exploding = true

    for _,delta in ipairs(adjacent) do
        if i+delta[1] > 0 and i+delta[1] < grid_size and j+delta[2] > 0 and j+delta[2] < grid_size then
            if grid[i+delta[1]][j+delta[2]].mark ~= "none" and not grid[i+delta[1]][j+delta[2]].exploding then
                grid[i][j].exploding = false
            end
        end
    end

end 


function update_green_mark(i,j)

    for _,delta in ipairs(adjacent) do
        if i+delta[1] > 0 and i+delta[1] < grid_size and j+delta[2] > 0 and j+delta[2] < grid_size then
            if grid[i+delta[1]][j+delta[2]].mark == "none" then
                try_place_mark(i+delta[1],j+delta[2], "green")
            end
        end
    end


end


function trigger_explosions()
    for i=1, grid_size do
        for j=1, grid_size do
            if grid[i][j].exploding then
                grid[i][j].mark = "none"
                grid[i][j].sprite = blank_cell.sprite
                grid[i][j].exploding = false
            end
        end
    end
end

function draw_grid()
    for i=1, grid_size do
        for j=1, grid_size do
            ---spr(grid[i][j].sprite,grid[i][j].x0,grid[i][j].y0,)
            sspr(8*grid[i][j].sprite,0, grid_px_size, grid_px_size,grid[i][j].x0,grid[i][j].y0,grid_px_size*grid_px_scale,grid_px_size*grid_px_scale)
        end
    end
end

function draw_cursor()
    -- spr(crs.sprite,grid[crs.i][crs.j].x0,grid[crs.i][crs.j].y0)
    sspr(8,0,grid_px_size,grid_px_size,grid[crs.i][crs.j].x0,grid[crs.i][crs.j].y0, grid_px_size*grid_px_scale,grid_px_size*grid_px_scale)
end

function draw_bag()
    local i = 1
    local mark_sprite = 1
    local xx = grid[1][1].x0
    local yy = margin + grid_size*grid_px_size*grid_px_scale + spacing*(grid_size+1)
    local diff = grid_px_size*grid_px_scale
    rect(xx, yy, xx + diff - 1, yy + diff - 1, 6)
    rect(xx+diff+spacing, yy, xx + 2 * diff - 1 + spacing, yy + diff - 1, 5)
    rect(xx+2*(diff+spacing), yy, xx + 3 * diff - 1 + 2*spacing, yy + diff - 1, 5)
    rect(xx+3*(diff+spacing), yy, xx + 4 * diff - 1 + 3*spacing, yy + diff - 1, 5)

    if bag[i] == "red" then mark_sprite = 2 end
    if bag[i] == "blue" then mark_sprite = 3 end
    if bag[i] == "yellow" then mark_sprite = 4 end
    if bag[i] == "green" then mark_sprite = 5 end

    sspr(xx)

    for i=1,4 do
        color = (i==1) and 6 or 5
        rect(xx + (i-1) * (diff+spacing) , yy, xx + i * diff + (i-1) * spacing - 1, yy + diff - 1, color)

        local index = (bag.idx+i-2)%4+1
        
        if bag[index] == "red" then mark_sprite = 2 end
        if bag[index] == "blue" then mark_sprite = 3 end
        if bag[index] == "yellow" then mark_sprite = 4 end
        if bag[index] == "green" then mark_sprite = 5 end
        
        sspr(mark_sprite*grid_px_size, 0, 8, 8, xx + (i-1) * (diff+spacing) , yy,diff,diff )
        
    end
    
end

function zip(a,b)


end