local Utils = require("tmux-runner.utils")

local Tmux = {
	current_pane = -1,
	vim_pane = -1,
	major_orientation = nil,
}

local function send_command(command)
	return io.popen("tmux " .. command):read("a")
end

local function send_keys(keys, pane_number)
	local prefix = "tmux send-keys -t " .. pane_number .. " "

	io.popen(prefix .. keys)
end

local function run_shell_command(command, pane_number)
	send_keys(Utils.shell_escape(command) .. " Enter", pane_number)
end

local function info(message)
	return send_command("display-message -p '#{" .. message .. "}'")
end

local function bool_info(message, target)
	local result = send_command("display-message -p -F '#{" .. message .. "}' -t " .. target)

	if tonumber(result) == 1 then
		return true
	else
		return false
	end
end

local function get_panes()
	local panes = {}

	for pane in string.gmatch(send_command("list-panes"), "(%d+):") do
		table.insert(panes, tonumber(pane))
	end

	return panes
end

local function is_valid_pane(pane_number)
	local panes = get_panes()

	for i = 1, #panes do
		if pane_number == panes[i] then
			return true
		end
	end

	return false
end

local function is_pane_available(pane_number)
	return pane_number ~= Tmux.vim_pane and is_valid_pane(pane_number)
end

local function current_major_orientation()
	local layout = info("window_layout")

	if string.match(layout, "[[{]") == "{" then
		return "vertical"
	else
		return "horizontal"
	end
end

local function active_pane()
	return tonumber(info("pane_index"))
end

local function is_in_copy_mode(pane_number)
	local session_name = Utils.trim(info("session_name"))
	local window_index = Utils.trim(info("window_index"))

	local target = session_name .. ":" .. window_index .. "." .. pane_number

	return bool_info("pane_in_mode", target)
end

local function quit_copy_mode(pane_number)
	if is_in_copy_mode(pane_number) then
		send_keys("q", pane_number)
	end
end

function Tmux.panes_count()
	return tonumber(info("window_panes"))
end

function Tmux.display_panes()
	send_command("display-panes")
end

function Tmux.set_pane(pane_number)
	if is_pane_available(pane_number) then
		Tmux.current_pane = pane_number
		Tmux.major_orientation = current_major_orientation()

		Utils.info("Attached to pane #" .. pane_number)
	else
		Utils.err("Invalid pane number: " .. pane_number)
	end
end

function Tmux.alt_pane()
	local panes = get_panes()
	for i = 1, #panes do
		if panes[i] ~= Tmux.vim_pane then
			return panes[i]
		end
	end
end

function Tmux.run_shell(command, pane_number)
	local pane_to_run = pane_number or Tmux.current_pane

	if not is_pane_available(pane_to_run) then
		Utils.err("Specified panel is not available anymore")
		return
	end

	quit_copy_mode(pane_to_run)
	run_shell_command(command, pane_to_run)
end

function Tmux.setup()
	Tmux.vim_pane = active_pane()
end

return Tmux
