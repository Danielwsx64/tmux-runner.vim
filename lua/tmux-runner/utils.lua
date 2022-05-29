local trim = vim.trim
local cmd = vim.cmd
local input = vim.fn.input

local Utils = {}

local function str_scape(str)
	return "'" .. str .. "'"
end

function Utils.info(msg)
	cmd("echo " .. str_scape(msg))
end

function Utils.warn(msg)
	cmd("echohl String")
	cmd("echo " .. str_scape(msg))
	cmd("echohl None")
end

function Utils.err(msg)
	cmd("echohl ErrorMsg")
	cmd("echo" .. str_scape(msg))
	cmd("echohl None")
end

function Utils.trim(msg)
	return trim(msg)
end

function Utils.shell_escape(str)
	return str_scape(string.gsub(str, "'", "'\\''"))
end

function Utils.input(msg)
	cmd("echohl String")
	local result = input(msg)
	cmd("echohl None")
	cmd("redraw")
	return result
end

return Utils
