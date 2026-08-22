local function hl(group, options)
	vim.api.nvim_set_hl(0, group, options)
end

local c = {
	white = "#f7f7ff",
	light_gray = "#E9E9F3",
	gray = "#CDCDD8",
	dark_gray = "#9494A3",
	black = "#1e1d35",

	dark_violet  = "#3a0080",
	violet       = "#8000ff",
	mid_violet   = "#5e00cc",
	indigo       = "#312e81",
	blue         = "#0044cc",
	deep_blue    = "#002288",
}

hl("Normal",       { fg = c.black, bg = c.white })
hl("NormalFloat",  { fg = c.black, bg = c.white })
hl("CursorLine",   { bg = c.light_gray })
hl("Visual",       { fg = c.white, bg = c.dark_gray })
hl("LineNr",       { fg = c.dark_gray })
hl("CursorLineNr", { fg = c.black, bold = true })

hl("Comment",      { fg = c.dark_gray, italic = true })
hl("Constant",     { fg = c.indigo, bold = true })
hl("String",       { fg = c.deep_blue })
hl("Identifier",   { fg = c.mid_violet })
hl("Function",     { fg = c.blue, bold = true })
hl("Keyword",      { fg = c.violet, bold = true })
hl("Whitespace",      { fg = c.gray, bold = true })

hl("Pmenu",        { fg = c.black, bg = c.light_gray })
hl("PmenuSel",     { fg = c.white, bg = c.violet })
hl("BlinkCmpDoc",  { fg = c.black, bg = c.light_gray })
hl("BlinkCmpSignatureHelp", { fg = c.black, bg = c.light_gray })

hl("StatusLine",   { fg = c.black, bg = c.light_gray, reverse = false })
hl("StatusLineNC", { fg = c.dark_gray, bg = c.light_gray, reverse = false })
hl("MsgArea",      { fg = c.black, bg = c.white })
hl("ModeMsg",      { fg = c.dark_violet, bold = true })

hl("NetrwDir",     { fg = c.mid_violet, bold = true })
hl("NetrwClassify", { fg = c.dark_gray })

