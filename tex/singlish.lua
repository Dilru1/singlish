-- singlish.lua -- phonetic (Singlish) to Sinhala Unicode transliteration
-- Part of the singlish package.
-- Copyright (C) 2026 Dilruwan
-- This work may be distributed and/or modified under the conditions of the
-- LaTeX Project Public License, either version 1.3c of this license or any
-- later version. The latest version of this license is in
-- https://www.latex-project.org/lppl.txt
--
-- Usable standalone:   texlua singlish.lua "mama amma"   ->  මම අම්ම

local M = {}
M.version = "0.2.0"
M.date    = "2026/11/09"

local HAL = "\u{0DCA}"   -- ්  al-lakuna (hal kirima)
local ZWJ = "\u{200D}"

---------------------------------------------------------------------------
-- Mapping tables (see the mapping specification in doc/)
---------------------------------------------------------------------------

-- vowel key -> { independent letter, dependent sign }
local VOWELS = {
  a   = { "අ", ""  },
  aa  = { "ආ", "ා" },
  ae  = { "ඇ", "ැ" },  A  = { "ඇ", "ැ" },
  aee = { "ඈ", "ෑ" },  AA = { "ඈ", "ෑ" },
  i   = { "ඉ", "ි" },
  ii  = { "ඊ", "ී" },
  u   = { "උ", "ු" },
  uu  = { "ඌ", "ූ" },
  e   = { "එ", "ෙ" },
  ee  = { "ඒ", "ේ" },
  ai  = { "ඓ", "ෛ" },
  o   = { "ඔ", "ො" },
  oo  = { "ඕ", "ෝ" },
  au  = { "ඖ", "ෞ" },
  R   = { "ඍ", "ෘ" },
  RR  = { "ඎ", "ෲ" },
}

local CONSONANTS = {
  -- velar
  k = "ක", K = "ඛ", kh = "ඛ", g = "ග", G = "ඝ", gh = "ඝ", Ng = "ඞ", zg = "ඟ",
  -- palatal
  ch = "ච", C = "ඡ", chh = "ඡ", j = "ජ", J = "ඣ", jh = "ඣ",
  Ny = "ඤ", GN = "ඥ", zj = "ඦ",
  -- retroflex
  t = "ට", T = "ඨ", d = "ඩ", D = "ඪ", N = "ණ", zD = "ඬ",
  -- dental
  th = "ත", Th = "ථ", dh = "ද", Dh = "ධ", n = "න", zd = "ඳ",
  -- labial
  p = "ප", P = "ඵ", ph = "ඵ", b = "බ", B = "භ", bh = "භ", m = "ම", zb = "ඹ",
  -- others
  y = "ය", r = "ර", l = "ල", L = "ළ", v = "ව", w = "ව",
  sh = "ශ", S = "ෂ", Sh = "ෂ", s = "ස", h = "හ", f = "ෆ",
}

local SIGNS = { x = "ං", H = "ඃ" }

local YA, RA = "ය", "ර"

M.vowels, M.consonants, M.signs = VOWELS, CONSONANTS, SIGNS

-- TeX commands whose first N braced arguments (and any [..] options before
-- them) are copied verbatim instead of being transliterated.
M.protected = {
  lat = 1, cite = 1, citep = 1, citet = 1, ref = 1, eqref = 1, pageref = 1,
  label = 1, url = 1, href = 1, includegraphics = 1, input = 1, include = 1,
  begin = 1, ["end"] = 1, textcolor = 1, color = 1, hspace = 1, vspace = 1,
  ensuremath = 1, si = 1, SI = 2, unit = 1, num = 1, ce = 1,
  usepackage = 1, documentclass = 1, newcommand = 2, renewcommand = 2,
}

---------------------------------------------------------------------------
-- helpers
---------------------------------------------------------------------------

local function longest(tbl, s, i, maxlen)
  for len = maxlen, 1, -1 do
    local key = s:sub(i, i + len - 1)
    if #key == len and tbl[key] then return key, tbl[key] end
  end
end

local function is_letter(c) return c:match("^[A-Za-z@]$") ~= nil end

-- copy a balanced {...} group starting at i (s:sub(i,i) == "{"); returns new i
local function copy_group(s, i, out, open, close)
  open, close = open or "{", close or "}"
  local depth, j = 0, i
  while j <= #s do
    local c = s:sub(j, j)
    if c == "\\" then
      out[#out + 1] = s:sub(j, j + 1); j = j + 2
    else
      if c == open then depth = depth + 1
      elseif c == close then depth = depth - 1 end
      out[#out + 1] = c; j = j + 1
      if depth == 0 then return j end
    end
  end
  return j
end

---------------------------------------------------------------------------
-- the converter
---------------------------------------------------------------------------
-- state.math is kept across calls so a math span may cover several lines
-- (used by the line-by-line `sinhala' environment).

function M.new_state() return { math = false } end

function M.convert(s, state)
  state = state or M.new_state()
  local out, i, n = {}, 1, #s
  local pending = nil          -- consonant waiting for a vowel

  local function flush()       -- consonant with no vowel -> hal kirima
    if pending then out[#out + 1] = pending .. HAL; pending = nil end
  end

  while i <= n do
    local c = s:sub(i, i)

    -- ---------------------------------------------------------- math mode
    if state.math then
      if c == "\\" then
        local nxt = s:sub(i + 1, i + 1)
        out[#out + 1] = c .. nxt; i = i + 2
        if (state.math == "\\(" and nxt == ")") or
           (state.math == "\\[" and nxt == "]") then state.math = false end
      elseif c == "$" then
        if state.math == "$$" and s:sub(i + 1, i + 1) == "$" then
          out[#out + 1] = "$$"; i = i + 2; state.math = false
        elseif state.math == "$" then
          out[#out + 1] = "$"; i = i + 1; state.math = false
        else out[#out + 1] = c; i = i + 1 end
      else
        out[#out + 1] = c; i = i + 1
      end

    -- ---------------------------------------------------------- TeX syntax
    elseif c == "$" then
      flush()
      if s:sub(i + 1, i + 1) == "$" then state.math = "$$"; out[#out + 1] = "$$"; i = i + 2
      else state.math = "$"; out[#out + 1] = "$"; i = i + 1 end

    elseif c == "%" then                  -- comment: copy rest verbatim
      flush(); out[#out + 1] = s:sub(i); i = n + 1

    elseif c == "\\" then
      flush()
      local nxt = s:sub(i + 1, i + 1)
      if nxt == "(" or nxt == "[" then
        state.math = "\\" .. nxt; out[#out + 1] = "\\" .. nxt; i = i + 2
      elseif is_letter(nxt) then
        local j = i + 1
        while j <= n and is_letter(s:sub(j, j)) do j = j + 1 end
        local name = s:sub(i + 1, j - 1)
        out[#out + 1] = s:sub(i, j - 1); i = j
        local nargs = M.protected[name]
        if nargs then
          -- copy optional star, spaces, [..] options and N braced arguments
          local copied = 0
          while i <= n do
            local d = s:sub(i, i)
            if d == "*" or d == " " then out[#out + 1] = d; i = i + 1
            elseif d == "[" then i = copy_group(s, i, out, "[", "]")
            elseif d == "{" and copied < nargs then
              i = copy_group(s, i, out); copied = copied + 1
            else break end
            if copied == nargs and s:sub(i, i) ~= "{" then break end
          end
        end
      else                                  -- control symbol: \\ \, \% ...
        out[#out + 1] = s:sub(i, i + 1); i = i + 2
      end

    -- ---------------------------------------------------------- separator
    elseif c == "|" then
      flush(); i = i + 1

    elseif c == "^" then                   -- explicit conjunct / repaya
      if pending and longest(CONSONANTS, s, i + 1, 3) then
        out[#out + 1] = pending .. HAL .. ZWJ; pending = nil
      else
        flush()
      end
      i = i + 1

    -- ---------------------------------------------------------- letters
    else
      local ck, cons = longest(CONSONANTS, s, i, 3)
      local vk, vow  = longest(VOWELS, s, i, 3)
      if ck then
        if pending then
          if (cons == YA and pending ~= RA) or (cons == RA and pending ~= RA) then
            out[#out + 1] = pending .. HAL .. ZWJ   -- yansaya / rakaransaya
          else
            out[#out + 1] = pending .. HAL
          end
        end
        pending = cons; i = i + #ck
      elseif vk then
        if pending then out[#out + 1] = pending .. vow[2]; pending = nil
        else out[#out + 1] = vow[1] end
        i = i + #vk
      elseif SIGNS[c] then
        if pending then out[#out + 1] = pending; pending = nil end
        out[#out + 1] = SIGNS[c]; i = i + 1
      else
        flush(); out[#out + 1] = c; i = i + 1   -- digits, punctuation, UTF-8
      end
    end
  end
  flush()
  return table.concat(out)
end

---------------------------------------------------------------------------
-- Sinhala dummy text (like lipsum): pseudo-words built from syllables.
-- The text is meaningless by design. Paragraph n is always the same text,
-- on every engine and every run, so layouts are reproducible.
---------------------------------------------------------------------------

local L_CONS = { "ක","ග","ච","ජ","ට","ඩ","ණ","ත","ද","න","ප","බ","ම",
                 "ය","ර","ල","ව","ස","හ","ළ","ශ","ධ","භ","ඳ","ඹ" }
local L_SIGN = { "", "", "", "", "ා","ා","ි","ි","ු","ෙ","ේ","ී","ො","ැ","ෝ","ූ" }
local L_INIT = { "අ","ආ","ඉ","උ","එ","ඔ" }

local function lcg(seed)            -- small deterministic generator
  local state = (seed * 7919 + 104729) % 2147483647
  return function(n)                -- integer in 1..n
    state = (state * 48271) % 2147483647
    return state % n + 1
  end
end

local function lipsum_word(rnd)
  local w, syl = {}, rnd(3) + (rnd(3) == 1 and 1 or 0)   -- 1..4 syllables
  if rnd(6) == 1 then w[#w + 1] = L_INIT[rnd(#L_INIT)]; syl = syl - 1 end
  for _ = 1, math.max(syl, 1) do
    w[#w + 1] = L_CONS[rnd(#L_CONS)] .. L_SIGN[rnd(#L_SIGN)]
  end
  local r = rnd(10)                 -- common word endings
  if r <= 2 then w[#w + 1] = "න්" elseif r == 3 then w[#w + 1] = "ක්"
  elseif r == 4 then w[#w + 1] = "ය" elseif r == 5 then w[#w + 1] = "ම" end
  return table.concat(w)
end

function M.lipsum_paragraph(n)
  local rnd, sentences = lcg(n), {}
  for _ = 1, 4 + rnd(4) do                     -- 5..8 sentences
    local words = {}
    for k = 1, 5 + rnd(9) do                   -- 6..14 words
      words[k] = lipsum_word(rnd)
      if k > 2 and rnd(9) == 1 then words[k] = words[k] .. "," end
    end
    words[#words] = words[#words]:gsub(",$", "")
    sentences[#sentences + 1] = table.concat(words, " ") .. "."
  end
  return table.concat(sentences, " ")
end

-- spec as in the lipsum package: "n" = paragraph n, "a-b" = paragraphs a..b
function M.lipsum(spec)
  local a, b = tostring(spec):match("^%s*(%d+)%s*%-%s*(%d+)%s*$")
  if not a then a = tostring(spec):match("^%s*(%d+)%s*$"); b = a end
  a, b = tonumber(a) or 1, tonumber(b) or 1
  local paras = {}
  for n = a, b do paras[#paras + 1] = M.lipsum_paragraph(n) end
  return paras
end

---------------------------------------------------------------------------
-- TeX interface
---------------------------------------------------------------------------

-- \singlish{...}: argument arrives detokenized
function M.print(s)
  tex.sprint(M.convert(s))
end

-- \silipsum[spec] / \silipsum*[spec] (star: no \par, one running paragraph)
function M.print_lipsum(spec, star)
  local paras = M.lipsum(spec)
  for k, p in ipairs(paras) do
    if k > 1 then tex.sprint(star and " " or "\\par ") end
    tex.sprint(p)
  end
end

-- `singlishtext' environment: transliterate source lines until \end{singlishtext}
local env_state, env_depth = nil, 0
local function line_filter(line)
  local stop = line:find("\\end%s*{singlishtext}")
  if stop then
    local head, tail = line:sub(1, stop - 1), line:sub(stop)
    M.stop_env()
    return M.convert(head, env_state) .. tail
  end
  return M.convert(line, env_state)
end

function M.start_env()
  env_state = M.new_state()
  luatexbase.add_to_callback("process_input_buffer", line_filter, "singlish")
end

function M.stop_env()
  if luatexbase.in_callback("process_input_buffer", "singlish") then
    luatexbase.remove_from_callback("process_input_buffer", "singlish")
  end
end

---------------------------------------------------------------------------
-- command line use: texlua singlish.lua "text"
---------------------------------------------------------------------------
if arg and arg[0] and arg[0]:match("singlish%.lua$") and not (tex and tex.sprint) then
  if #arg == 0 then
    for line in io.lines() do print(M.convert(line)) end
  else
    print(M.convert(table.concat(arg, " ")))
  end
end

return M
