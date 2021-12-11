using GameZero
using Colors
using Dates

HEIGHT = 700
WIDTH = 700
BALLNUMS = 15
MAXSPEED = 5
BARLENGTH = 150

remaining = BALLNUMS

ranclr() = RGB(rand(1:255)/255, rand(1:255)/255, rand(1:255)/255)
rancirc() = Circle(rand(0:WIDTH-50), rand(100:HEIGHT-50), 20)
rancpair() = [rancirc(), ranclr(), rand(-5:5, 2), true]
c = map(x -> rancpair(), 1:BALLNUMS)
l = Rect(WIDTH/2-100, HEIGHT-40, BARLENGTH, 30)
time = now()
current = now()

function draw()
    global time, current
    map(x -> x[4] == true && draw(x[1], x[2], fill=true), c)
    draw(l, fill=true)
    current = (remaining == 3 ? current : now())
    txt1 = TextActor("Balls left: $remaining", "impact"; font_size=30, color=[0,0,0,0])
    txt1.pos = (60, 30)
    txt2 = TextActor("Time elapsed: $(round(current-time, Second))", "impact"; font_size=30, color=[0,0,0,0])
    txt2.pos = (60, 60)
    draw(txt1)
    draw(txt2)
end

function update()
    global remaining, time

    remaining == 3 && return
    map(c) do (x)
        x[4] == false && return
        x[1].x += x[3][1]
        x[1].y += x[3][2]
        if x[1].x > 0.95*WIDTH || x[1].x < 2
            x[3][1] = -x[3][1]
        end
        if x[1].y > 0.95*HEIGHT
            x[4] = false
            remaining -= 1
            return
        end
        if x[1].y < 2
            x[3][2] = -x[3][2]
        end
        map(c) do (other)
            if other[1].x != x[1].x
                collide(x[1], other[1]) && collide_circles!(x, other) 
            end
        end
        if collide(x[1], l) 
            pos_a = [x[1].x, x[1].y]
            pos_b = [l.x, l.y]
            x[3] .= normalize.(-(pos_b-pos_a))
        end
    end
end
function on_mouse_move(g::Game, pos) 
    l.x = pos[1]
end


normalize(num, mx) =  sign(num) * min(abs(num), mx)
normalize(num) = normalize(num, MAXSPEED)
function collide_circles!(a, b)
    b[4] == false && return
    a[4] == false && return
    pos_a = [a[1].x, a[1].y]
    pos_b = [b[1].x, b[1].y]
    a[3] .= normalize.(-(pos_b-pos_a))
    b[3] .= normalize.(-(pos_a-pos_b))
end