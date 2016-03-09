function love.load()
	width, height = love.graphics.getWidth(), love.graphics.getHeight()

	--Adjustable parameters
	PIXELS_PER_METER = height
	N_CUPS = 6
	CUP_LOWER_RADIUS = 2.5 --cm
	CUP_UPPER_RADIUS = 3.5 --cm
	CUP_HEIGHT = 9 --cm
	CUP_ATTACH_Y = 7 --cm
	HOLE_AREA = 0.3 --cm^2
	WHEEL_RADIUS = 25 --cm
	WHEEL_MI = 0.0125 --kg*m^2

	--Display
	SHOW_WHEEL = true
	WHEEL_PANE = {posX = 0.5, posY = 0, sizeX = 0.5, sizeY = 0.7, isPhysical = true}

end

function love.draw()

	if SHOW_WHEEL then -- draw wheel pane
		startPane(WHEEL_PANE)
		love.graphics.setColor(255,255,255)
		love.graphics.circle("fill", 0, 0, 200, 32)
		stopPane(WHEEL_PANE)
	end

end

function startPane(pane)
	if pane.isPhysical then -- scales to real-world units, with +y as up, and center as 0,0
		love.graphics.translate(pane.posX * width + 0.5 * pane.sizeX * width, pane.posY * height + 0.5 * pane.sizeY * height)
		love.graphics.scale(pane.sizeX * width / PIXELS_PER_METER, -pane.sizeY * height / PIXELS_PER_METER)
		love.graphics.setLineWidth(pane.sizeX / PIXELS_PER_METER)
	else -- simply moves and scales GUI
		love.graphics.translate(pane.posX * width, pane.posY * height)
		love.graphics.scale(pane.sizeX, pane.posY)
		love.graphics.setLineWidth(pane.sizeX)
	end
end

function stopPane(pane) -- reverse startPane and then draw a box around the finished pane
	if pane.isPhysical then
		love.graphics.scale(PIXELS_PER_METER / width / pane.sizeX, -PIXELS_PER_METER / height / pane.sizeY)
		love.graphics.translate(-pane.posX * width - 0.5 * pane.sizeX * width, -pane.posY * height - 0.5 * pane.sizeY * height)
	else
		love.graphics.scale(1 / pane.sizeX, 1 / pane.posY)
		love.graphics.translate(-pane.posX * width, -pane.posY * height)
	end
	love.graphics.setLineWidth(1)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("line", pane.posX * width, pane.posY * height, pane.sizeX * width, pane.sizeY * height)
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
y = height - y

end

function love.mousereleased(x,y,b)

end

function drawCup(wheelAngle, fill)
	love.graphics.setColor(255,127,127)
	love.graphics.setLineWidth(4 / PIXELS_PER_METER)
	--love.graphics.
end

vector = {}
