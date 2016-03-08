function love.load()
width, height = love.graphics.getWidth, love.graphics.getHeight
PIXELS_PER_METER = height()

--Adjustable parameters
N_CUPS = 6
CUP_LOWER_RADIUS = 2.5 --cm
CUP_UPPER_RADIUS = 3.5 --cm
CUP_HEIGHT = 9 --cm
HOLE_AREA = 0.3 --cm^2
WHEEL_RADIUS = 25 --cm
WHEEL_MI = 0.0125 --kg*m^2

end

function love.draw()
love.graphics.setLineWidth(1 / PIXELS_PER_METER)

end

function love.update(dt)
	if autoplay then
		ud(dt)
	end
end


function ud(dt)


end

function love.keypressed(key)
	if key == "s" then
		ud(0.1)
	end
end

function love.mousepressed(x,y,b)
y = height() - y

end

function love.mousereleased(x,y,b)

end

vector = {}
