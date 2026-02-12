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
    --p_update(1/30)
    tick = (tick==30) and 0 or tick+1
    player.x = player.x + sin(tick*1/30) * 5
    player.y = player.y + sin(0.2 + tick*1/30) * 3
end

function _draw()
    cls()
    spr(0,player.x,player.y)
    draw_floor()
end

function draw_floor()
    for i=0,15 do 
        spr(1,i*8,120)
    end
end

function player_input()
    if(btn(0)) then player.x = player.x - 2 end
    if(btn(1)) then player.x = player.x + 2 end
    if(btn(2) and jump_enabled) then jump() end
end

function p_update(delta)
    local vy = player.vy0 + g * delta
    local y = player.y + player.vy0 * delta + 0.5 * g * delta * delta

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

        elseif player.y >= 112 then
            player.state = "GROUNDED"
            jump_enabled = true
        
        else
            jump_enabled=false
        end
    end
    if player.state == "GROUNDED" then
        player.vy=0
    end

    player.vy0=player.vy
end

function jump()
    player.state = "JUMPING"
    jump_enabled=false
    current_jump = 1
end
