------------------------------
-- Sumple Anti spam module
------------------------------
local M = {}

-- Command spam detector
function M.spam_detector(t_anti_spam, message)
        
    -- Locals
    local chat_id    = 0
    local user_id    = 0
    local first_name = ""
    local message_id = 0
    local date       = 0

    -- inline callback
    if message.callback_query then
        chat_id    = message.callback_query.message.chat.id
        user_id    = message.callback_query.from.id
        first_name = message.callback_query.from.first_name
        message_id = message.callback_query.message.message_id
        date       = os.time()
    else
        -- Default message
        chat_id    = message.chat.id
        user_id    = message.from.id
        first_name = message.from.first_name
        message_id = message.message_id
        date       = message.date
    end

    -- User link
    local p_user

    -- Add user
    if (t_anti_spam.users[user_id] == nil) then
        t_anti_spam.users[user_id]            = {}
        t_anti_spam.users[user_id].message_id = {}
        t_anti_spam.users[user_id].count      = 0
        t_anti_spam.users[user_id].date       = date
        t_anti_spam.users[user_id].mute       = false
        t_anti_spam.users[user_id].informing  = false

        -- Link for user
        p_user = t_anti_spam.users[user_id]

        -- Add first message 
        table.insert(t_anti_spam.users[user_id].message_id, message_id)
    else
        -- User link
        p_user = t_anti_spam.users[user_id]
    end

    -- If user in mute
    if p_user.mute then
        if (date - p_user.date < t_anti_spam.setting.mute_second) then
            -- Mute
            return true
        else
            -- Un mute
            p_user.mute = false
        end
    end

    --
    local offset_time = date - p_user.date 
    table.insert(p_user.message_id, message_id)

    -- Update date
    p_user.date = date

    -- 
    if (offset_time <= t_anti_spam.setting.time) then
        p_user.count = p_user.count + 1

        -- Delete all user message and mute user
        if (p_user.count == t_anti_spam.setting.count) then
            -- Set mute
            p_user.mute = true
            return true
        end
    else
        if (#p_user.message_id > t_anti_spam.setting.count) then
            t_anti_spam.users[user_id] = nil
        end
    end

    return false
    
end

return M