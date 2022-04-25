--[[ HTML
<b>bold</b>, <strong>bold</strong>
<i>italic</i>, <em>italic</em>
<u>underline</u>, <ins>underline</ins>
<s>strikethrough</s>, <strike>strikethrough</strike>, <del>strikethrough</del>
<span class="tg-spoiler">spoiler</span>, <tg-spoiler>spoiler</tg-spoiler>
<b>bold <i>italic bold <s>italic bold strikethrough <span class="tg-spoiler">italic bold strikethrough spoiler</span></s> <u>underline italic bold</u></i> bold</b>
<a href="http://www.example.com/">inline URL</a>
<a href="tg://user?id=123456789">inline mention of a user</a>
<code>inline fixed-width code</code>
<pre>pre-formatted fixed-width code block</pre>
<pre><code class="language-python">pre-formatted fixed-width code block written in the Python programming language</code></pre>
]]

-- Main
local M = {}

-- Locals
local string_format = string.format

-- Helper
local help_format = function(text)

    -- Debug
    if (not text) then
        return "none"
    end

    return text
               :gsub("&", "&amp;")
               :gsub("<", "&lt;")
               :gsub(">", "&gt;")

end

-- Format
function M.format(text)

    return help_format(text)

end

-- Bold
function M.bold(text)

    return "<b>" .. text .. "</b>"

end

-- Italic
function M.italic(text)

    return "<i>" .. text .. "</i>"

end

-- Monospace
function M.monospaced(text)

    return "<code>" .. text .. "</code>"

end

-- Strike
function M:strike(text)

    return "<strike>" .. text .. "</strike>"

end

-- Underline
function M.underline(text)

    return "<u>" .. text .. "</u>"

end

-- Code
function M.code(lang, code)

    return string_format('<pre language="%s">%s</pre>', lang, code)

end

-- URL
function M.url(url, name)

    return string_format('<a href="%s">%s</a>', url, help_format(name))

end

-- User URL
function M.user_url(id, name)

    return string_format('<a href="tg://user?id=%s">%s</a>', id, help_format(name))

end

-- Message URL
function M.message_url(chat, id, name)

    return string_format('<a href="https://t.me/%s/%s">%s</a>', chat, id, help_format(name))

end

-- Spoiler
function M.spoiler(text)

    return help_format(string_format("<tg-spoiler>%s</tg-spoiler>", text))

end

return M