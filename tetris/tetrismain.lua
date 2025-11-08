#include tetrislib.lua

function _init()
    pokes()
    --srand(53)
	--music(0,1000) 
    init_board()
    init_tetrominoes()
    current_tet = pop_tet(tet_list)
    running = 1

end

timer = 0
timer_aux = 0
function _update()
    if(timer_aux == 30) then
        timer_aux = 0
        timer += 1
    end

    timer_aux += 1

    player_input()

    if running then
        current_tet:gravity(g_force,y0+h)

    end
end

function _draw()
    cls()
    if running==1 then
        print(timer_aux,100,100)
		map()
        g_frames +=1
        --draw_borders(thickness,7)
        draw_board(false)
        current_tet:draw_ghost()
        current_tet:draw_tet()
        draw_tet_buffer(tet_list)
        print("lines:"..total_lines.."", x_tbf, y_tbf+30, 6)
        --if clear_anim.clearing then anim_clear() end
        if g_frames==30 then g_frames=0 end
        draw_borders(thickness,7)
    elseif running==0 then
        print("game over", x_tbf, y_tbf, 7)
        print("lines:"..total_lines.."", x_tbf, y_tbf+10, 7)
        print("restart:z/x", x_tbf, y_tbf+20, 7)
        draw_borders(thickness,7)
        draw_board(true)
    end

end

function draw_borders(t,c) --t is thickness, c is color
 	rectfill(bx0,by0,bx0+2*t+w-1,by0+t-1,c) --upper bar
 	rectfill(bx0,by0+t+h,bx0+2*t+w-1,by0+2*t-1+h,c) --lower bar
 	rectfill(bx0,by0+t,bx0+t-1,by0+t+h,c) --left bar
 	rectfill(bx0+t+w,by0+t,bx0+2*t+w-1,by0+t+h,c) --right bar
    --rect(0,0,127,127,7)
end

rotating = 0
rot_counter = 0
function player_input()

    if running == 1 then
        if btn(⬇️) then
            g_force=high_g
            if btnp(⬆️) then
                --up
            end
                
            if btnp(➡️) then current_tet:move_right(4, 40) end
            if btnp(⬅️) then current_tet:move_left(-4,-10) end

            if btnp(4) and rotating == 0 then 
                current_tet:rotate(false)
                rotating = 1
                rot_counter += 1
            elseif btnp(5) and rotating == 0 then 
                current_tet:rotate(true)
                rotating = 1
                rot_counter += 1
            elseif btn(5) or btn(4) then
                rotating = 1
            else
                rotating = 0
            end

        else
            g_force=default_g_force
            if btnp(⬆️) then
                --up
            end
                
            if btnp(➡️) then current_tet:move_right(4, 40) end
            if btnp(⬅️) then current_tet:move_left(-4,-10) end

            if btnp(4) and rotating == 0 then 
                current_tet:rotate(false)
                rotating = 1
                rot_counter += 1
            elseif btnp(5) and rotating == 0 then 
                current_tet:rotate(true)
                rotating = 1
                rot_counter += 1
            elseif btn(5) or btn(4) then
                rotating = 1
            else
                rotating = 0
            end

        end
    else
        if btnp(4) or btnp(5) then 
            reset_board()
            init_board()
            init_tetrominoes()
            current_tet = pop_tet(tet_list)
            running = 1
        end
    end
end

function pokes()
    poke(0X5F5C, das) 
    poke(0X5F5D, arr) 
end