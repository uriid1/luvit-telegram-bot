------------------------------
-- Sumple Anti spam module
------------------------------
local M = {}

-- Command spam detector
function M.spam_detector(t_anti_spam, message)
    
    -- 
    if (message.callback_query) then
        return
    end

    -- Local var
    local id         = message.from.id
    local chat_id    = message.chat.id
    local message_id = message.message_id
    local first_name = message.from.first_name
    local date       = message.date

    -- User link
    local p_user

    -- Add user
    if (t_anti_spam.users[id] == nil) then
        t_anti_spam.users[id]            = {}
        t_anti_spam.users[id].message_id = {}
        t_anti_spam.users[id].count      = 0
        t_anti_spam.users[id].date       = date
        t_anti_spam.users[id].mute       = false
        t_anti_spam.users[id].informing  = false

        -- Link for user
        p_user = t_anti_spam.users[id]

        -- Add first message 
        table.insert(t_anti_spam.users[id].message_id, message_id)
    else
        -- User link
        p_user = t_anti_spam.users[id]
    end

    -- If user in mute
    if p_user.mute then
        if (date - p_user.date < t_anti_spam.setting.mute_sec) then
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
            t_anti_spam.users[id] = nil
        end
    end

    return false
    
end

return M