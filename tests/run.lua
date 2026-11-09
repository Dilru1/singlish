-- texlua tests/run.lua   (run from the repository root)
package.path = "tex/?.lua;" .. package.path
local singlish = require("singlish")

local function hex(s)
  local t = {}
  for _, c in utf8.codes(s) do t[#t + 1] = string.format("%04X", c) end
  return table.concat(t, " ")
end

local pass, fail = 0, 0
for line in io.lines("tests/words.tsv") do
  if line ~= "" and not line:match("^#") then
    local input, expected = line:match("^(.-)\t(.*)$")
    local got = singlish.convert(input)
    if got == expected then pass = pass + 1
    else
      fail = fail + 1
      print(("FAIL  %-24s expected %s\n      %-24s got      %s\n      [%s] vs [%s]")
        :format(input, expected, "", got, hex(expected), hex(got)))
    end
  end
end
-- dummy text must be deterministic and pure Sinhala
local p1, p1b = singlish.lipsum_paragraph(1), singlish.lipsum_paragraph(1)
if p1 == p1b and not p1:find("[A-Za-z]") and #singlish.lipsum("2-4") == 3 then
  pass = pass + 1
else
  fail = fail + 1; print("FAIL  lipsum determinism / content")
end
print(("%d passed, %d failed"):format(pass, fail))
os.exit(fail == 0 and 0 or 1)
