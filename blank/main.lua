mode = "move"
grid_size = 4
grid_px_size = 8
grid_px_scale = 2
grid = {}
margin = 10
x_margin = 30
y_margin = 15
spacing = 1 
crs = {i = 1, j=1, sprite=1}
bag = {}

blank_cell_count = 2

blank_cell = {sprite=6}
red_mark = {sprite=2}
blue_mark = {sprite = 3}
yellow_mark = {sprite =4}
green_mark = {sprite =5}

adjacent = {{-1,0}, {1,0}, {0,-1},{0,1}}


placed_marks = 0

turn = 0

function _init()
    menuitem(1, "god mode", function() if mode ~= "god" then mode = "god" else mode = "move" end end)
    create_grid()
    bag = {"blue",  "red",  "green", "yellow"}
    bag.count = 4
    bag.idx = 1
    bag.current_mark = bag[bag.idx]

    fill_grid_heuristic()
end

function _update()
    handle_input()
end

function _draw()
    cls()
    rect(0,0,127,127,5)
    rect(x_margin,y_margin,x_margin+spacing*grid_size+grid_size*grid_px_scale*grid_px_size,y_margin+spacing*(grid_size+1)+(1+grid_size)*grid_px_scale*grid_px_size,5)
    rect(x_margin,1+y_margin+spacing*grid_size+grid_size*grid_px_scale*grid_px_size,x_margin+spacing*grid_size+grid_size*grid_px_scale*grid_px_size,y_margin+spacing*(grid_size+1)+(1+grid_size)*grid_px_scale*grid_px_size,5)


    draw_grid()
    draw_cursor()
    draw_bag()
    print(mode,110,2,5)
    if mode == "move" then
        print("z -> place mark", 2,114,5)
        print("x -> mark mode", 2,120,5)
    elseif mode =="mark" then
        print("z -> place mark", 2,114,5)
        print("x -> move mode", 2,120,5)
    elseif mode == "god" then
        print("z -> clear grid", 2,114,5)
        -- print("x -> move mode", 2,120)
        print("x -> fill grid", 2, 120,5)
    end
    print("turn:"..turn, 2, 2,5)
    -- print("marks:"..placed_marks, 40, 2,5)
    
end

function handle_input()
    if mode == "move" then
        if btnp(4) then try_place_mark(crs.i,crs.j,bag.current_mark) end
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
        if btnp(⬅️) then 
            if (bag.idx > 1) then
                bag.idx -= 1
            else
                bag.idx = bag.count
            end
            bag.current_mark = bag[bag.idx]
        end
    elseif mode=="god" then
        if btnp(4) then clear_grid() end
        -- if btnp(5) then mode = "move" end
        if btnp(5) then fill_grid_heuristic() end
    end

end

function advance_turn()
    update_board()
    turn+=1
end

function try_place_mark(i,j,mark)
    if grid[i][j].mark == "none" then
        grid[i][j].mark = mark
        grid[i][j].sprite = get_sprite(mark)
        placed_marks +=1 
        advance_turn()
        return true
    end
    return false
end

function try_spawn_mark(i,j,mark)
    if grid[i][j].mark == "none" and grid[i][j].spawning then
        grid[i][j].mark = mark
        grid[i][j].sprite = get_sprite(mark)
        grid[i][j].spawning = false
        return true
    end
    return false
end


function create_grid()
    local x,y
    local id = 0
    for i=1, grid_size do
        grid[i] = {}
        for j=1, grid_size do
            x = x_margin + (i-1)*grid_px_size*grid_px_scale + spacing*i
            y = y_margin + (j-1)*grid_px_size*grid_px_scale + spacing*j
            grid[i][j]={id = id, sprite=6, x0=x, y0=y, mark="none", exploding=false, spawning = false}
            id+=1
        end
    end
end

function get_sprite(mark)
    if mark=="red" then return red_mark.sprite end
    if mark=="blue" then return blue_mark.sprite end
    if mark=="yellow" then return yellow_mark.sprite end
    if mark=="green" then return green_mark.sprite end
    if mark=="none" then return blank_cell.sprite end
end

function fill_grid()

    for i=1, grid_size do
        for j=1, grid_size do
            roll = flr(rnd(5))
            if roll==0 then current_mark = "red" end 
            if roll==1 then current_mark = "blue" end
            if roll==2 then current_mark = "yellow" end
            if roll==3 then current_mark = "green" end
            if roll==4 then current_mark = "none" end
            grid[i][j].mark = current_mark
            if current_mark ~= "none" then grid[i][j].sprite = get_sprite(current_mark) end
        end
    end
end

function fill_grid_heuristic()

    total = grid_size*grid_size

    grid_bag = {}

    for i=1, blank_cell_count do
        grid_bag[i] = "none"
    end

    for i=(blank_cell_count+1), total do
        roll = flr(rnd(4))
        if roll==0 then grid_bag[i] = "red" end 
        if roll==1 then grid_bag[i] = "blue" end
        if roll==2 then grid_bag[i] = "yellow" end
        if roll==3 then grid_bag[i] = "green" end
    end
    
    shuffle_table(grid_bag)

    n=1
    for i=1, grid_size do
        for j=1, grid_size do
            
            local m = grid_bag[n]

            if m ~= "none" then grid[i][j].sprite = get_sprite(m) end
            
            grid[i][j].mark =m
            n+=1
        end
    end
end

function shuffle_table(t)
    for i = #t, 2, -1 do
        local j = flr(rnd(i)) +1
        t[i], t[j] = t[j], t[i]
    end
end

function clear_grid()
    for i=1, grid_size do
        for j=1, grid_size do
            grid[i][j].mark = "none"
            grid[i][j].sprite = blank_cell.sprite
        end
    end
    placed_marks = 0
    turn = 0
end

function update_board()
    for i=1, grid_size do
        for j=1, grid_size do
            if grid[i][j].mark == "blue" then update_blue_mark(i,j) end
        end
    end

    trigger_explosions()

    for i=1, grid_size do
        for j=1, grid_size do
            if grid[i][j].mark == "red" then update_red_mark(i,j) end
        end
    
    end
    trigger_explosions()

    for i=1, grid_size do
        for j=1, grid_size do
            if grid[i][j].mark == "green" then update_green_mark(i,j) end
        end
    end

    for i=1, grid_size do
        for j=1, grid_size do
            if grid[i][j].mark == "yellow" then update_yellow_mark(i,j) end
        end
    end
    trigger_explosions()

    trigger_spawns()
end




function update_red_mark(i,j)
    
    for _,delta in ipairs(adjacent) do
        if i+delta[1] > 0 and i+delta[1] <= grid_size and j+delta[2] > 0 and j+delta[2] <= grid_size then
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

    for y=1,grid_size do
        if grid[i][y].mark == "blue" and y~=j then
            grid[i][j].exploding = false 
            return
        end
    end

    for x=1,grid_size do
        if grid[x][j].mark == "blue" and x~=i then
            grid[i][j].exploding = false 
            return
        end
    end

    -- for _,delta in ipairs(adjacent) do
    --     if i+delta[1] > 0 and i+delta[1] <= grid_size and j+delta[2] > 0 and j+delta[2] <= grid_size then
    --         if grid[i+delta[1]][j+delta[2]].mark ~= "none" and not grid[i+delta[1]][j+delta[2]].exploding then
    --             grid[i][j].exploding = false
    --         end
    --     end
    -- end

end 


function update_green_mark(i,j)

    log("updating green")
    for _,delta in ipairs(adjacent) do
        log(delta)
        if i+delta[1] > 0 and i+delta[1] <= grid_size and j+delta[2] > 0 and j+delta[2] <= grid_size then
            if grid[i+delta[1]][j+delta[2]].mark == "none" then
                grid[i+delta[1]][j+delta[2]].spawning = true 
                return
            end
        end
    end

    log("")

end


function update_yellow_mark(i,j)

    if i>1 and j>1 then
        if grid[i-1][j-1].mark == "yellow" then
            grid[i][j].exploding = true 
        end
    end

    if i<grid_size and j>1 then
        if grid[i+1][j-1].mark == "yellow" then
            grid[i][j].exploding = true 
        end
    end
    
    if i>1 and j<grid_size then
        if grid[i-1][j+1].mark == "yellow" then
            grid[i][j].exploding = true 
        end
    end
    
    if i<grid_size and j<grid_size then
        if grid[i+1][j+1].mark == "yellow" then
            grid[i][j].exploding = true 
        end
    end

end

function trigger_spawns()
    for i=1, grid_size do
        for j=1, grid_size do
            try_spawn_mark(i,j,"green") 
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

-- function draw_bag()
--     local i = 1
--     local mark_sprite = 1
--     local xx = grid[1][1].x0
--     local yy = margin + grid_size*grid_px_size*grid_px_scale + spacing*(grid_size+1)
--     local diff = grid_px_size*grid_px_scale
--     rect(xx, yy, xx + diff - 1, yy + diff - 1, 6)
--     rect(xx+diff+spacing, yy, xx + 2 * diff - 1 + spacing, yy + diff - 1, 5)
--     rect(xx+2*(diff+spacing), yy, xx + 3 * diff - 1 + 2*spacing, yy + diff - 1, 5)
--     rect(xx+3*(diff+spacing), yy, xx + 4 * diff - 1 + 3*spacing, yy + diff - 1, 5)

--     if bag[i] == "red" then mark_sprite = 2 end
--     if bag[i] == "blue" then mark_sprite = 3 end
--     if bag[i] == "yellow" then mark_sprite = 4 end
--     if bag[i] == "green" then mark_sprite = 5 end

--     sspr(xx)

--     for i=1,4 do
--         color = (i==1) and 6 or 5
--         rect(xx + (i-1) * (diff+spacing) , yy, xx + i * diff + (i-1) * spacing - 1, yy + diff - 1, color)

--         local index = (bag.idx+i-2)%4+1
        
--         if bag[index] == "red" then mark_sprite = 2 end
--         if bag[index] == "blue" then mark_sprite = 3 end
--         if bag[index] == "yellow" then mark_sprite = 4 end
--         if bag[index] == "green" then mark_sprite = 5 end
        
--         sspr(mark_sprite*grid_px_size, 0, 8, 8, xx + (i-1) * (diff+spacing) , yy,diff,diff )
        
--     end
    
-- end

function draw_bag()
    local i = 1
    local mark_sprite = 1
    local xx = grid[1][1].x0
    local yy = y_margin + grid_size*grid_px_size*grid_px_scale + spacing*(grid_size+1)
    local diff = grid_px_size*grid_px_scale
    -- rect(xx, yy, xx + diff - 1, yy + diff - 1, 5)
    -- rect(xx+diff+spacing, yy, xx + 2 * diff - 1 + spacing, yy + diff - 1, 5)
    -- rect(xx+2*(diff+spacing), yy, xx + 3 * diff - 1 + 2*spacing, yy + diff - 1, 5)
    -- rect(xx+3*(diff+spacing), yy, xx + 4 * diff - 1 + 3*spacing, yy + diff - 1, 5)

    
    for i=1,4 do
        color = (i==bag.idx) and 6 or 5

        local index = get_sprite(bag[i])
        if (i==bag.idx) then
            rect(xx + (i-1) * (diff+spacing)-1 , yy, xx + i * diff + (i-1) * spacing , yy + diff , color)
        end
        sspr(index*grid_px_size, 0, 8, 8, xx + (i-1) * (diff+spacing) , yy,diff,diff )
    end



end

function log(txt, ow)
    ow = ow or false 
    printh(txt,'debug.txt',ow)
end