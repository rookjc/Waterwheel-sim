--assumptions: cyclindrical cups, vertical acceleration doesn't affect flow rate, water doesn't add to overall moment of inertia
--             cups don't rotate away from vertical orientation, drops don't affect wheel velocity, water comes out of spout at 0 m/s

-- *** is significant number

function love.load()
	width, height = love.graphics.getWidth(), love.graphics.getHeight()
	setup()
end

function setup()
	--Adjustable parameters
	PIXELS_PER_METER = height*0.9
	AUTOPLAY = true
	RECORD_DATA = true
	STORE_MODE = false
	N_DATA_FRAMES = 8000
	Y_AXIS_SCALE = 7
	X_AXIS_SCALE = 120
	TIME_SCALE = 1
	PUMP_ON = true
	DROPS = true -- applies only to drops {} and not spoutDrops {}
	N_CUPS = 6
	SPOKES = 3
	WATER_LEVEL = 40 --cm (how far the water level is below the center of the wheel)
	CUP_RADIUS = 3.2 --cm ***
	CUP_HEIGHT = 12.7 --cm ***
	MIN_CUP_FILL = 6 --cm^3
	CUP_ATTACH_Y = 9.5 --cm (how high up the nail is on the cup)
	HOLE_AREA = 0.087 --cm^2 ***
	WHEEL_RADIUS = 22.5 --cm ***
	WHEEL_MI = 800 --kg*cm^2 ***
	WHEEL_DRAG = 0.7 --ratio each second ***
	WATER_DENSITY = 0.001 --kg/cm^3
	GRAVITY = 981 --cm/s^2
	SPOUT_RADIUS = 0.7 --cm
	SPOUT_HEIGHT = 40 --cm above wheel center
	PUMP_ROF = 80 --cm^3 / s ***

	--Display
	SHOW_WHEEL = true
	SHOW_GRAPH = false
	WHEEL_PANE = {posX = 0, posY = 0, sizeX = 1, sizeY = 1, isPhysical = true}
	GRAPH_PANE = {posX = 0, posY = 0, sizeX = 1, sizeY = 1, isPhysical = false}

	--Updating quantities
	wheelRotation = 0 --rad
	wheelVelocity = 0.5 --rad/s
	cupFills = {}
	drops = {}
	spoutDrops = {}
	data = {}
	data2 = {}
	dataTimes = {}
	dataFrame = 1
	runTime = 0

	--Initialization
	for i = 1, N_CUPS do
		cupFills[i] = MIN_CUP_FILL
	end
	--cupFills[1] = 0
	CUP_CS_AREA = math.pi * CUP_RADIUS ^ 2
	CUP_VOLUME = CUP_HEIGHT * CUP_CS_AREA
	width2 = width
	height2 = height
	DIV_ANGLE = 2 * math.pi / N_CUPS

	--Modification controls
	PROPERTIES = {"HOLE_AREA", "WHEEL_DRAG", "PUMP_ROF", "Y_AXIS_SCALE"}
	UNITS = {"cm^2", "", "cm^3 / s", "rad / s"}
	STEPS = {0.04, 0.1, 5, 1}
	property = 1
	propDispTime = 0
	holding = false
	baseRot = 0

end

function writeData()
	AUTOPLAY = false
	local path = os.date("%c")
	path = string.sub(path, 1, 2) .. "-" .. string.sub(path, 4, 5) .. "-" .. string.sub(path, 7, 8) .."_"
	.. string.sub(path, 10, 11) .. "-" .. string.sub(path, 13, 14) .. "-" .. string.sub(path, 16, 17)
	path = "C:/Users/jrook_000/OneDrive/codeprojects/Waterwheel/data/angvel_" .. path .. ".csv"
	local dat = ""
	for i = 1, N_DATA_FRAMES do
		dat = dataX(i) .. "," .. dataY(i) .. "," .. dataZ(i) .. "\n" .. dat
	end
	io.output(path)
	io.write(dat)
	AUTOPLAY = true
end

function love.draw()

	if SHOW_WHEEL then -- draw wheel pane
		startPane(WHEEL_PANE)
		love.graphics.setColor(127,127,127)
		love.graphics.rectangle("fill", -SPOUT_RADIUS, SPOUT_HEIGHT, 2 * SPOUT_RADIUS, height2 / 2 - SPOUT_HEIGHT)
		love.graphics.polygon("fill", -SPOUT_RADIUS * 2, SPOUT_HEIGHT, 0, SPOUT_HEIGHT + SPOUT_RADIUS * 4, SPOUT_RADIUS * 2, SPOUT_HEIGHT)
		love.graphics.setColor(127,127,255,127)
		love.graphics.rectangle("fill", -width2 / 2, -height2 / 2, width2, height2 / 2 - WATER_LEVEL)

		-- draw drops (two classifications: from spout (which could fill a cup) and 'dead' (for animation only))
		for a, b in ipairs(spoutDrops) do
			love.graphics.circle("fill", 0, b.posY, b.radius, 4)
		end

		if DROPS then
			for a, b in ipairs(drops) do
				love.graphics.circle("fill", b.posX, b.posY, b.radius, 4)
			end
		end

		-- wheel itself, with cups and all that
		love.graphics.setColor(255,255,255)
		love.graphics.rotate(wheelRotation)
		love.graphics.circle("line", 0, 0, WHEEL_RADIUS, 32)
		for i = 1, SPOKES do
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

	if SHOW_GRAPH then --draw graph pane
		startPane(GRAPH_PANE)
		love.graphics.setColor(255,255,255)
		love.graphics.print("Angular velocity vs. time", 5, 5)
		love.graphics.line(width2 * 0.95, height2 / 20, width2 * 0.95, height2 * 0.95)
		love.graphics.line(width2 / 20, height2 / 2, width2 * 0.95, height2 / 2)
		love.graphics.print(Y_AXIS_SCALE .. " rad/s", width2 * 0.95 - 55, height2 / 20 - 6)
		love.graphics.print(-Y_AXIS_SCALE .. " rad/s", width2 * 0.95 - 55, height2 * 0.95 - 6)
		love.graphics.print(-X_AXIS_SCALE .. " s", width2 / 20, height2 / 2 + 2)

		love.graphics.setColor(127,255,127)
		love.graphics.translate(width2 * (0.95 - 0.9 / X_AXIS_SCALE * runTime), height2 / 2)
		local xScale = width2 * 0.9 / X_AXIS_SCALE
		local yScale = height2 * 0.9 / Y_AXIS_SCALE
		local lastX = dataX(1) * xScale
		local lastY = dataY(1) * yScale
		for i = 2, N_DATA_FRAMES do
			local nextX = dataX(i) * xScale
			local nextY = dataY(i) * yScale
			love.graphics.line(lastX, -lastY, nextX, -nextY)
			lastX = nextX
			lastY = nextY
		end
		love.graphics.translate(-width2 * (0.95 - 0.9 / X_AXIS_SCALE * runTime), -height2 / 2)
		stopPane(GRAPH_PANE)

	end

	if propDispTime > 0 then
		love.graphics.setColor(63,63,63)
		love.graphics.rectangle("fill", 10, 10, 200, 75)
		love.graphics.setColor(255,255,255)
		love.graphics.print(PROPERTIES[property] .. ": " .. _G[PROPERTIES[property]] .. " " .. UNITS[property], 20, 39)
	end

end

function dataX(i) -- time
	return dataTimes[(dataFrame - i - 1) % N_DATA_FRAMES + 1] or 0
end

function dataY(i) -- angular velocity
	return data[(dataFrame - i - 1) % N_DATA_FRAMES + 1] or 0
end

function dataZ(i) -- rotation
	return data2[(dataFrame - i - 1) % N_DATA_FRAMES + 1] or 0
end

function startPane(pane)
	love.graphics.push()
	if pane.isPhysical then -- scales to real-world units (cm), with +y as up, and center as 0,0
		love.graphics.translate(pane.posX * width + 0.5 * pane.sizeX * width, pane.posY * height + 0.5 * pane.sizeY * height)
		love.graphics.scale(PIXELS_PER_METER / pane.sizeX / 100, -PIXELS_PER_METER / pane.sizeX / 100)
		width2 = width * pane.sizeX * 100 / PIXELS_PER_METER
		height2 = height * pane.sizeY * 100 / PIXELS_PER_METER
		love.graphics.setLineWidth(pane.sizeX / PIXELS_PER_METER)
	else -- simply moves and scales GUI
		love.graphics.translate(pane.posX * width, pane.posY * height)
		love.graphics.scale(pane.sizeX, pane.sizeY)
		width2 = width * pane.sizeX
		height2 = height * pane.sizeY
		love.graphics.setLineWidth(pane.sizeX)
	end
end

function stopPane(pane) -- reverse startPane and then draw a box around the finished pane
	love.graphics.pop()
	love.graphics.setLineWidth(1)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("line", pane.posX * width, pane.posY * height, pane.sizeX * width, pane.sizeY * height)
end

function love.update(dt)
	if propDispTime > 0 then
		propDispTime = propDispTime - dt
	end
	if AUTOPLAY then
		ud(dt)
	elseif holding then
		wheelVelocity = 0
		wheelRotation = math.atan2(height / 2 - love.mouse.getY(), love.mouse.getX() - width / 2) + baseRot
	end
end


function ud(dt)
	if love.keyboard.isDown("f") then
		print(math.floor(1 / dt), math.floor(dt * 1000 + 0.5) / 1000)
	end
	dt = dt * TIME_SCALE
	runTime = runTime + dt
	--move drops and stuff
	local fillCup = N_CUPS - (math.ceil((wheelRotation + DIV_ANGLE / 2 - math.pi / 2) / DIV_ANGLE) - 1) % N_CUPS
	local underSpout = math.abs(math.cos(math.pi * 2 * fillCup / N_CUPS + wheelRotation) * WHEEL_RADIUS) < CUP_RADIUS
	local fillY = math.sin(DIV_ANGLE * fillCup + wheelRotation) * WHEEL_RADIUS - CUP_ATTACH_Y + cupFills[fillCup] / CUP_CS_AREA

	for i = #spoutDrops, 1, -1 do
		local b = spoutDrops[i]
		b.velY = b.velY - GRAVITY * dt
		b.posY = b.posY + b.velY * dt
		if b.checkFill then
			if b.posY < fillY then
				if underSpout then
					cupFills[fillCup] = math.min(cupFills[fillCup] + spoutDrops[i].volume, CUP_VOLUME)
					table.remove(spoutDrops, i)
				else
					b.checkFill = false
				end
			end
		elseif b.posY < -WATER_LEVEL then
			table.remove(spoutDrops, i)
		end
	end

	if DROPS then
		for i = #drops, 1, -1 do
			local b = drops[i]
			b.velY = b.velY - GRAVITY * dt
			b.posX = b.posX + b.velX * dt
			b.posY = b.posY + b.velY * dt
			if b.posY < -WATER_LEVEL then
				table.remove(drops, i)
			end
		end
	end

	if PUMP_ON then
		local volume = PUMP_ROF * dt
		table.insert(spoutDrops, {posY = SPOUT_HEIGHT, velY = 0, volume = volume, radius = math.pow(volume, 1/3), checkFill = true})
	end

	--wheel kinematics and cup draining
	local torque = 0
	for i = 1, N_CUPS do
		local angLocCos = math.cos(math.pi * 2 * i / N_CUPS + wheelRotation)
		if cupFills[i] > MIN_CUP_FILL then
			local flowVelocity = math.sqrt(2 * GRAVITY * cupFills[i] / CUP_CS_AREA)
			cupFills[i] = cupFills[i] - flowVelocity * HOLE_AREA * dt
			if DROPS then
				local angLocSin = math.sin(math.pi * 2 * i / N_CUPS + wheelRotation)
				table.insert(drops, {posX = angLocCos * WHEEL_RADIUS, posY = angLocSin * WHEEL_RADIUS - CUP_ATTACH_Y,
									 velX = -angLocSin * WHEEL_RADIUS * wheelVelocity, velY = angLocCos * WHEEL_RADIUS * wheelVelocity - flowVelocity,
									 radius = math.pow(flowVelocity * HOLE_AREA * dt, 1/3)})
			end
		end
		torque = torque - angLocCos * cupFills[i] * WATER_DENSITY * GRAVITY * WHEEL_RADIUS
	end
	if not holding then
		local wheelAcceleration = torque / WHEEL_MI
		wheelVelocity = wheelAcceleration * dt + wheelVelocity * WHEEL_DRAG ^ dt -- approximate a 'drag' by exponentially decreasing the velocity
		wheelRotation = (wheelRotation + wheelVelocity * dt)--[[ % (2 * math.pi)]]
	else -- the user has control of manually moving / spinning the wheel
		local newWR = math.atan2(height / 2 - love.mouse.getY(), love.mouse.getX() - width / 2) + baseRot
		wheelVelocity = (newWR - wheelRotation) / dt
		wheelRotation = newWR
	end

	if RECORD_DATA then -- record data
		data[dataFrame] = wheelVelocity
		data2[dataFrame] = wheelRotation
		dataTimes[dataFrame] = runTime
		dataFrame = dataFrame % N_DATA_FRAMES + 1
		if STORE_MODE and dataFrame == 1 then
			writeData()
			love.event.quit()
		end
	end
end

function love.keypressed(key)
	if key == "s" then
		ud(0.05)
	elseif key == " " then
		PUMP_ON = not PUMP_ON
	elseif key == "g" then
		holding = false
		SHOW_WHEEL = not SHOW_WHEEL
		SHOW_GRAPH = not SHOW_GRAPH
	elseif key == "d" then
		RECORD_DATA = not RECORD_DATA
	elseif key == "w" then
		writeData()
	elseif key == "p" then
		AUTOPLAY = not AUTOPLAY
	elseif key == "escape" then
		love.event.quit()
	elseif key == "r" and (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
		AUTOPLAY = false
		setup()
	elseif key == "left" then
		property = property % #PROPERTIES + 1
		propDispTime = 3
	elseif key == "right" then
		property = (property - 2) % #PROPERTIES + 1
		propDispTime = 3
	elseif key == "up" then
		_G[PROPERTIES[property]] = _G[PROPERTIES[property]] + STEPS[property]
		propDispTime = 3
	elseif key == "down" then
		_G[PROPERTIES[property]] = _G[PROPERTIES[property]] - STEPS[property]
		propDispTime = 3
	end
end

function love.mousepressed(x,y,b)
	if SHOW_WHEEL then
		holding = true
		baseRot = wheelRotation - math.atan2(height / 2 - y, x - width / 2)
	end
end

function love.mousereleased(x,y,b)
	holding = false
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
