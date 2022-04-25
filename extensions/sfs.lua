local M = {}

-- Luvit FS
local fs = require "fs"

-- Read File
function M.read_file(path, callback)

	fs.open(path, "r", function(err, fd)
		if err then
			callback(err, nil)
			return
		end
		fs.stat(path, function(err, stat)
			if err then
				callback(err, nil)
				return
			end
			fs.read(fd, stat.size, function(err, data)
				if err then
					callback(err, nil)
					return
				end
				fs.close(fd, function(err)
					if err then
						callback(err, nil)
						return
					end
					callback(nil, data)
				end)
			end)
		end)
	end)

end

-- Write
function M.write_file(path, flag, wdata, callback)

	fs.open(path, flag, function(err, fd)
		if err then
			callback(err)
			return
		end
		fs.write(fd, 0, wdata, function(err)
			if err then
				callback(err)
				return
			end
			fs.close(fd, function(err)
				if err then
					callback(err)
					return
				end
				callback(nil)
			end)
		end)
	end)

end

return M