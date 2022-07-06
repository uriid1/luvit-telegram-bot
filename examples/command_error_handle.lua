--[[ Instruction
1) Set bot token, url, cert, port 
2) run luvit command_error_handle
--]]

-- Luvit func
local path = require("path")

-- Bot
local bot = require(path.join("..", "core", "bot")):setToken("123456789:AABBCCDDEEFFFFGGHHKKLL")
bot.debug = true

-- Options
local URL   = "https://255.255.255.255/" .. bot.token
local CERT  = "/my/cool/path/PUBLIC.pem"
local PORT  = 5000

-- Event get message
bot.event.onGetMessageText = function(message)
        
    -- Send message
    bot:sendMessage({
        text = message.text;
        chat_id = message.chat.id;
    })

end


-------------------------
-- Event error handling
-------------------------
local error_cmd = [[

[Error Info]
{error}

[User Info]
Fname: {first_name}
ID: {user_id}
Text: {text}

[Chat info]
Chat ID: {chat_id} 

]]

bot.event.onCommandErrorHandle = function(error, message)
    
    print(
        error_cmd:gsub("{error}",      error, 1)
                 :gsub("{first_name}", message.from.first_name, 1)
                 :gsub("{user_id}",    message.from.id, 1)
                 :gsub("{text}",       message.text, 1)
                 :gsub("{chat_id}",    message.chat.id, 1)
    )

end


------------------------
-- Command with error
-- CMD: /error
------------------------
bot.cmd["/error"] = function()

    foo()

end


-- Run bot
-- Enable webhook
bot:startWebHook({
    token       = bot.token;
    port        = PORT;
    url         = URL;
    certificate = CERT;

    -- Optional
    drop_pending_updates = true;
})