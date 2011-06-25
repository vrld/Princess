function love.conf(t)
	t.title = "Princess"
	t.author = "vrld"
	t.identity = "Princess"
	t.version = 0
	t.console = false
	t.screen.width = 1024 -- 16:9, bitches
	t.screen.height = 576
	t.screen.fullscreen = false
	t.screen.vsync = true
	t.screen.fsaa = 0
	t.modules.joystick = true
	t.modules.audio = true
	t.modules.keyboard = true
	t.modules.event = true
	t.modules.image = true
	t.modules.graphics = true
	t.modules.timer = true
	t.modules.mouse = true
	t.modules.sound = true
	t.modules.physics = true
end
