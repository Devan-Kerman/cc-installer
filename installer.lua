-- read json from URL
function decodeURL(url)
	if url then
		local con = http.get(url)
		if con then
			return decode(con.readAll())
		else
			error("Unable to access: " .. url)
		end
	else
		error("Invalid URL!")
	end
end

-- base 64 parser
-- decoding
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
function dec(data)
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
		if (x == '=') then return '' end
		local r,f='',(b:find(x)-1)
		for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
		return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then return '' end
		local c=0
		for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
			return string.char(c)
	end))
end

-- json parser
------------------------------------------------------------------ utils
local controls = {["\n"]="\\n", ["\r"]="\\r", ["\t"]="\\t", ["\b"]="\\b", ["\f"]="\\f", ["\""]="\\\"", ["\\"]="\\\\"}
local whites = {['\n']=true; ['\r']=true; ['\t']=true; [' ']=true; [',']=true; [':']=true}

function removeWhite(str)
	while whites[str:sub(1, 1)] do
		str = str:sub(2)
	end
	return str
end

------------------------------------------------------------------ decoding
local decodeControls = {}
for k,v in pairs(controls) do
	decodeControls[v] = k
end

function parseBoolean(str)
	if str:sub(1, 4) == "true" then
		return true, removeWhite(str:sub(5))
	else
		return false, removeWhite(str:sub(6))
	end
end

function parseNull(str)
	return nil, removeWhite(str:sub(5))
end

local numChars = {['e']=true; ['E']=true; ['+']=true; ['-']=true; ['.']=true}
function parseNumber(str)
	local i = 1
	while numChars[str:sub(i, i)] or tonumber(str:sub(i, i)) do
		i = i + 1
	end
	local val = tonumber(str:sub(1, i - 1))
	str = removeWhite(str:sub(i))
	return val, str
end

function parseString(str)
	str = str:sub(2)
	local s = ""
	while str:sub(1,1) ~= "\"" do
		local next = str:sub(1,1)
		str = str:sub(2)
		assert(next ~= "\n", "Unclosed string")

		if next == "\\" then
			local escape = str:sub(1,1)
			str = str:sub(2)

			next = assert(decodeControls[next..escape], "Invalid escape character")
		end

		s = s .. next
	end
	return s, removeWhite(str:sub(2))
end

function parseArray(str)
	str = removeWhite(str:sub(2))

	local val = {}
	local i = 1
	while str:sub(1, 1) ~= "]" do
		local v = nil
		v, str = parseValue(str)
		val[i] = v
		i = i + 1
		str = removeWhite(str)
	end
	str = removeWhite(str:sub(2))
	return val, str
end

function parseObject(str)
	str = removeWhite(str:sub(2))

	local val = {}
	while str:sub(1, 1) ~= "}" do
		local k, v = nil, nil
		k, v, str = parseMember(str)
		val[k] = v
		str = removeWhite(str)
	end
	str = removeWhite(str:sub(2))
	return val, str
end

function parseMember(str)
	local k = nil
	k, str = parseValue(str)
	local val = nil
	val, str = parseValue(str)
	return k, val, str
end

function parseValue(str)
	local fchar = str:sub(1, 1)
	if fchar == "{" then
		return parseObject(str)
	elseif fchar == "[" then
		return parseArray(str)
	elseif tonumber(fchar) ~= nil or numChars[fchar] then
		return parseNumber(str)
	elseif str:sub(1, 4) == "true" or str:sub(1, 5) == "false" then
		return parseBoolean(str)
	elseif fchar == "\"" then
		return parseString(str)
	elseif str:sub(1, 4) == "null" then
		return parseNull(str)
	end
	return nil
end

function decode(str)
	str = removeWhite(str)
	t = parseValue(str)
	return t
end

-- decoding

function readGithubFile(url)
	local returned = decodeURL(url)
	if returned["encoding"] == "base64" then
		return dec(returned["content"])
	else
	    error(string.format("Unknown encoding: %s", returned["encoding"]))
	end
end

function startInstall(username, repository, branchName)
    if(username == "help") then
        print("installer <username> <repository>")
        print("installer <username> <repository> <branchName>")
        return true
    end

    -- validate entries
    if branchName == nil then branchName = "master" end
    if repository == nil or username == nil then error("No username and/or repository") end

    -- download file tree from github api
    local response = decodeURL(string.format("https://api.github.com/repos/%s/%s/git/trees/%s?recursive=1", username, repository, branchName))
    if response["message"] then
        error(response["message"])
    else
        print("Repository found!")
    end

    local tree = response["tree"]
    local config = nil
    -- find the installer config
    for i, v in pairs(tree) do
        if v["path"] == "installer.json" then
            -- read config
            print("found config!")
            config = decode(readGithubFile(v["url"]))
        end
    end

    -- verify config
    if config == nil then
        print("no config found! using defaults...")
        config = {}
        config["src"] = "src"
        config["dependents"] = {}
    end

    sourceDirectory = config["src"]
    print("Source directory: " .. sourceDirectory)
    for i, v in pairs(tree) do
        print(v["path"])
        if v["type"] == "blob" and v["path"]:find(sourceDirectory) == 1 then
            local path = v["path"]:sub(sourceDirectory:len() + 1)
            print("Installing " .. path)
            local file = fs.open(path, "w")
            file.write(readGithubFile(v["url"]))
            file.close()
        end
    end

    for i, v in pairs(config["dependents"]) do
        startInstall(v[1], v[2], v[3])
    end
end

-- installer
user,repo,branch = ...
print("Installing...")
startInstall(user, repo, branch)