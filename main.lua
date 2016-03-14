--assumptions: cyclindrical cups, vertical acceleration doesn't affect flow rate, water doesn't add to overall moment of inertia
--             cups don't rotate away from vertical orientation

function love.load()
	width, height = love.graphics.getWidth(), love.graphics.getHeight()

	--Adjustable parameters
	PIXELS_PER_METER = height*0.9
	AUTOPLAY = true
	N_CUPS = 6
	SPOKES = 3
	WATER_LEVEL = 40 --cm (how far the water level is below the center of the wheel)
	CUP_RADIUS = 3 --cm
	CUP_HEIGHT = 9 --cm
	MIN_CUP_FILL = 6 --cm^3
	CUP_ATTACH_Y = 7 --cm (how high up on the cup the nail is)
	HOLE_AREA = 0.3 --cm^2
	WHEEL_RADIUS = 25 --cm
	WHEEL_MI = 800 --kg*cm^2
	WHEEL_DRAG = 0.9 --ratio each second
	WATER_DENSITY = 0.001 --kg/cm^3
	GRAVITY = 980 --cm/s^2

	--Display
	SHOW_WHEEL = true
	WHEEL_PANE = {posX = 0, posY = 0, sizeX = 1, sizeY = 1, isPhysical = true}

	--Updating quantities
	wheelRotation = 0 --rad
	wheelVelocity = 0 --rad/s
	cupFills = {}

	--Initialization
	for i = 1, N_CUPS do
		cupFills[i] = 120
	end
	cupFills[1] = 0
	CUP_CS_AREA = math.pi * CUP_RADIUS ^ 2
	CUP_VOLUME = CUP_HEIGHT * CUP_CS_AREA
	width2 = width
	height2 = height

end

function love.draw()

	if SHOW_WHEEL then -- draw wheel pane
		startPane(WHEEL_PANE)
		love.graphics.setColor(127,127,255,127)
		love.graphics.rectangle("fill", -width2 / 2, -height2 / 2, width2, height2 / 2 - WATER_LEVEL)
		love.graphics.setColor(255,255,255)
		love.graphics.rotate(wheelRotation)
		love.graphics.circle("line", 0, 0, WHEEL_RADIUS, 32)
		for i=1, SPOKES do
			local attachX = math.cos(math.pi * i / SPOKES) * WHEEL_RADIUS
			local attachY = math.sin(math.pi * i / SPOKES) * WHEEL_RADIUS
			love.graphics.line(attachX, attachY, -attachX, -attachY)
		end
		love.graphics.setLineWidth(4 * love.graphics.getLineWidth())
		for i=1, N_CUPS do
			drawCup(math.pi * 2 * i / N_CUPS, cupFills[i])
		end
		love.graphics.rotate(-wheelRotation)
		stopPane(WHEEL_PANE)
	end

end

function startPane(pane)
	if pane.isPhysical then -- scales to real-world units (cm), with +y as up, and center as 0,0
		love.graphics.translate(pane.posX * width + 0.5 * pane.sizeX * width, pane.posY * height + 0.5 * pane.sizeY * height)
		love.graphics.scale(PIXELS_PER_METER / pane.sizeX / 100, -PIXELS_PER_METER / pane.sizeX / 100)
		width2 = width * pane.sizeX * 100 / PIXELS_PER_METER
		height2 = height * pane.sizeY * 100 / PIXELS_PER_METER
		love.graphics.setLineWidth(pane.sizeX / PIXELS_PER_METER)
	else -- simply moves and scales GUI
		love.graphics.translate(pane.posX * width, pane.posY * height)
		love.graphics.scale(pane.sizeX, pane.posY)
		love.graphics.setLineWidth(pane.sizeX)
	end
end

function stopPane(pane) -- reverse startPane and then draw a box around the finished pane
	if pane.isPhysical then
		love.graphics.scale(pane.sizeX * 100 / PIXELS_PER_METER, -pane.sizeY * 100 / PIXELS_PER_METER)
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
	local torque = 0
	for i = 1, N_CUPS do
		torque = torque - math.cos(math.pi * 2 * i / N_CUPS + wheelRotation) * 	cupFills[i] * WATER_DENSITY * GRAVITY * WHEEL_RADIUS
	end
	local wheelAcceleration = torque / WHEEL_MI
	wheelVelocity = wheelAcceleration * dt + wheelVelocity * WHEEL_DRAG ^ dt -- approximate a 'drag' by exponentially decreasing the velocity
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
	love.graphics.translate(math.cos(angleLocation) * WHEEL_RADIUS, math.sin(angleLocation) * WHEEL_RADIUS)
	love.graphics.rotate(-wheelRotation)
	love.graphics.setColor(255,127,127,127)
	love.graphics.rectangle("fill", -CUP_RADIUS, -CUP_ATTACH_Y, 2 * CUP_RADIUS, CUP_HEIGHT)

	love.graphics.setColor(127,127,255,127)
	love.graphics.rectangle("fill", -CUP_RADIUS, -CUP_ATTACH_Y, 2 * CUP_RADIUS, fill / CUP_CS_AREA)

	love.graphics.setColor(255,0,0)
	love.graphics.line(-CUP_RADIUS, CUP_HEIGHT - CUP_ATTACH_Y, -CUP_RADIUS, -CUP_ATTACH_Y,
	                   CUP_RADIUS, -CUP_ATTACH_Y, CUP_RADIUS, CUP_HEIGHT - CUP_ATTACH_Y)

	love.graphics.setColor(255,255,255)
	love.graphics.circle("fill", 0, 0, 0.5, 6)
	love.graphics.rotate(wheelRotation)
	love.graphics.translate(-math.cos(angleLocation) * WHEEL_RADIUS, -math.sin(angleLocation) * WHEEL_RADIUS)
end
