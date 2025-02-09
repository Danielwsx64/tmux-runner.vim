local Utils = {}

local function str_scape(str)
	return "'" .. str .. "'"
end

function Utils.info(msg)
	vim.cmd("echo " .. str_scape(msg))
end

function Utils.warn(msg)
	vim.cmd("echohl String")
	vim.cmd("echo " .. str_scape(msg))
	vim.cmd("echohl None")
end

function Utils.err(msg)
	vim.cmd("echohl ErrorMsg")
	vim.cmd("echo" .. str_scape(msg))
	vim.cmd("echohl None")
end

function Utils.trim(msg)
	return vim.trim(msg)
end

function Utils.shell_escape(str)
	return str_scape(string.gsub(str, "'", "'\\''"))
end

function Utils.input(msg)
	vim.cmd("echohl String")
	local result = vim.fn.input(msg)

	vim.cmd("echohl None")
	vim.cmd("redraw")
	return result
end

return Utils
