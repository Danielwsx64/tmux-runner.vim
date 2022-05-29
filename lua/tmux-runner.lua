local nvim_create_user_command = vim.api.nvim_create_user_command
local cmd = vim.cmd

local Tmux = require("tmux-runner.tmux")
local Utils = require("tmux-runner.utils")

local Self = { display_pane_numbers = true }

local function define_commands()
	nvim_create_user_command("VtrAttachToPane", function(opts)
		Self.prompt_attach_to_pane(opts.args)
	end, { nargs = "*" })

	nvim_create_user_command("VtrSendCommand", function(opts)
		Self.send_command(opts.args)
	end, { nargs = "*" })

	-- TODO: I need this for using vim-test plugin
	cmd([[
		function! VtrSendCommand(command, ...)
			 call v:lua.require("tmux-runner").send_command(a:command)
		endfunction
	]])
end

function Self.send_command(command, panel_number)
	Tmux.run_shell(command, panel_number)
end

function Self.prompt_attach_to_pane(pane)
	local pane_number = tonumber(pane)

	if pane_number then
		return Tmux.set_pane(pane_number)
	end

	local pane_count = Tmux.panes_count()

	if pane_count == 1 then
		return Utils.warn("No pane to attach")
	end

	if pane_count == 2 then
		return Tmux.set_pane(Tmux.alt_pane())
	end

	if Self.display_pane_numbers then
		Tmux.display_panes()
	end

	local selected_pane = tonumber(Utils.input("Attach to wich pane? #"))

	if not selected_pane then
		Utils.warn("No pane specified. Cancelling.")
		return
	end

	Tmux.set_pane(selected_pane)
end

function Self.setup()
	Tmux.setup()
	define_commands()
end

return Self
