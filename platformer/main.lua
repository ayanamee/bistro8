player = {x=60,y=60, vx=0, vy=0, vx0=0,vy0=0, ax=0,ay=0,state="FALLING"}
g = 300
jump_force = 10
current_jump = 1
current_jump2 = 1
jump_enabled = false

function _init()
    player.vy0=0
    player.vy=30
    player.ay = g
end

tick = 0
function _update()
    player_input()
    p_update(1/30)
    tick = (tick==30) and 0 or tick+1
    --player.x = player.x + sin(tick*1/30) * 5
    --player.y = player.y + sin(0.2 + tick*1/30) * 3
end

function _draw()
    cls()
    spr(0,player.x,player.y,1,1,sprite_left)
    draw_floor()
end

function draw_floor()
    for i=0,15 do 
        spr(1,i*8,120)
    end
    print(player.state,0,0,7,sprite_left)
    print("vx: "..player.vx,0,8,7)
    if jump_enabled then print("JUMP",40,0,7) end
end


sprite_left = true
function player_input()
    if(btn(0)) then player.vx =  - 32 end
    if(btn(1)) then player.vx =   32 end
    if(btn(2) and jump_enabled) then jump() end
    if player.vx == 0 then sprite_left = sprite_left 
    elseif player.vx < 0 then sprite_left = true else sprite_left= false end
end

function p_update(delta)
    local vy = player.vy0 + g * delta
    local y = player.y + player.vy0 * delta + 0.5 * g * delta * delta

    local x = player.x + player.vx0 * delta

    player.x = x

    if y < 112 then
        player.y = y
        player.vy = vy
    else
        player.y = 112
        player.vy = 0
    end
    
    if player.state == "JUMPING" then
        if current_jump <= 0 then
            player.state = "FALLING"
        else
            player.y = player.y - jump_force * current_jump
            current_jump -= 0.1
        end
    end
    if player.state == "FALLING" then
        if player.y > 108 then
            jump_enabled = true
            player.state = "GROUNDED"

        elseif player.y >= 112 then
            player.state = "GROUNDED"
            jump_enabled = true
        
        else
            jump_enabled=false
        end
    end
    if player.state == "GROUNDED" then
        --player.vy=0
        jump_enabled = true
        
        player.vx=player.vx*0.7
        if abs(player.vx) < 0.1 then
            player.vx = 0
        end
    end

    player.vy0=player.vy
    player.vx0=player.vx
end

function jump()
    player.state = "JUMPING"
    jump_enabled=false
    current_jump = 1
end
