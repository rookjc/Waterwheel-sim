function love.load()
	width, height = love.graphics.getWidth(), love.graphics.getHeight()

	--Adjustable parameters
	PIXELS_PER_METER = height*0.7
	AUTOPLAY = true
	N_CUPS = 6
	SPOKES = 4
	CUP_LOWER_RADIUS = 2.5 --cm
	CUP_UPPER_RADIUS = 3.5 --cm
	CUP_HEIGHT = 9 --cm
	CUP_ATTACH_Y = 7 --cm
	HOLE_AREA = 0.3 --cm^2
	WHEEL_RADIUS = 25 --cm
	WHEEL_MI = 0.0125 --kg*m^2
	WHEEL_DRAG = 0.9 --ratio each second

	--Display
	SHOW_WHEEL = true
	WHEEL_PANE = {posX = 0.2, posY = 0, sizeX = 0.8, sizeY = 0.9, isPhysical = true}

	--Updating quantities
	wheelRotation = 0 --rad
	wheelVelocity = 1 --rad/s

end

function love.draw()

	if SHOW_WHEEL then -- draw wheel pane
		startPane(WHEEL_PANE)
		love.graphics.setColor(255,255,255)
		love.graphics.rotate(wheelRotation)
		love.graphics.circle("line", 0, 0, WHEEL_RADIUS, 32)
		for i=1, SPOKES do
			local attachX = math.cos(math.pi * i / SPOKES) * WHEEL_RADIUS
			local attachY = math.sin(math.pi * i / SPOKES) * WHEEL_RADIUS
			love.graphics.line(attachX, attachY, -attachX, -attachY)
		end
		for i=1, N_CUPS do
			drawCup(math.pi * 2 * i / N_CUPS, 0)
		end
		love.graphics.rotate(-wheelRotation)
		stopPane(WHEEL_PANE)
	end

end

function startPane(pane)
	if pane.isPhysical then -- scales to real-world units (cm), with +y as up, and center as 0,0
		love.graphics.translate(pane.posX * width + 0.5 * pane.sizeX * width, pane.posY * height + 0.5 * pane.sizeY * height)
		love.graphics.scale(PIXELS_PER_METER / pane.sizeX / 100, -PIXELS_PER_METER / pane.sizeX / 100)
		love.graphics.setLineWidth(pane.sizeX / PIXELS_PER_METER)
	else -- simply moves and scales GUI
		love.graphics.translate(pane.posX * width, pane.posY * height)
		love.graphics.scale(pane.sizeX, pane.posY)
		love.graphics.setLineWidth(pane.sizeX)
	end
end

function stopPane(pane) -- reverse startPane and then draw a box around the finished pane
	if pane.isPhysical then
		love.graphics.scale(100 * pane.sizeX / PIXELS_PER_METER, -100 * pane.sizeX / PIXELS_PER_METER)
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
	if AUTOPLAY then
		ud(dt)
	end
end


function ud(dt)
	--wheel kinematics
	wheelVelocity = wheelVelocity * WHEEL_DRAG ^ dt -- approximate a 'drag' by exponentially decreasing the velocity
	wheelRotation = (wheelRotation + wheelVelocity * dt) % (2 * math.pi)
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

function drawCup(angleLocation, fill)
	love.graphics.setColor(255,127,127)
	love.graphics.translate(math.cos(angleLocation) * WHEEL_RADIUS, math.sin(angleLocation) * WHEEL_RADIUS)
	love.graphics.rotate(-wheelRotation)
	love.graphics.line(-CUP_UPPER_RADIUS, CUP_HEIGHT - CUP_ATTACH_Y, -CUP_LOWER_RADIUS, -CUP_ATTACH_Y,
	                   CUP_LOWER_RADIUS, -CUP_ATTACH_Y, CUP_UPPER_RADIUS, CUP_HEIGHT - CUP_ATTACH_Y)
	love.graphics.rotate(wheelRotation)
	love.graphics.translate(-math.cos(angleLocation) * WHEEL_RADIUS, -math.sin(angleLocation) * WHEEL_RADIUS)
end

vector = {}
