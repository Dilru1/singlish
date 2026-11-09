# singlish — type සිංහල phonetically in LuaLaTeX

Version 0.2.0 (2026-11-09) · LPPL 1.3c · **the mapping may still change**

Write `\singlish{mama}` in LaTeX source and get **මම** in the PDF (just like typing with Helakuru). The package converts Helakuru-style romanised ("Singlish") input to Sinhala Unicode and typesets it with a proper OpenType Sinhala font.

```latex
\documentclass{article}
\usepackage[font=abhaya, headfont=noto-sans, sinhalanames]{singlish}
\title{\singlish{siigiriya}}
\begin{document}
\maketitle
\section{\singlish{haezdinviima}}           % heading in Noto Sans Sinhala
\singlish{shrii laxkaava}                    % ශ්‍රී ලංකාව, body in Abhaya Libre

\begin{singlishtext}
thaarakaa thuLa sidhu vana nyaShtika prathikriyaa
\end{singlishtext}

\silipsum[1-2]                               % Sinhala dummy text
\end{document}
```

Compile with **LuaLaTeX** (on Overleaf: Menu → Compiler → LuaLaTeX, or add the `latexmkrc` file from [`overleaf/`](overleaf/)).

## Package options

| Option | Meaning | Default |
| --- | --- | --- |
| `font=` | Sinhala font for body text: a short name (below) or any font name | `noto-sans` |
| `headfont=` | Sinhala font for the title and all section headings | same as `font` |
| `scale=` | Size of body Sinhala, relative (`1.1` = 10% larger) | `1` |
| `headscale=` | The same for headings | `1` |
| `sinhalanames` | Contents, Figure, Table, References… printed in Sinhala (පටුන, රූපය, වගුව, ආශ්‍රිත ග්‍රන්ථ…) | off |

The body text **size** itself is the usual class option: `\documentclass[11pt]{article}`.

## Commands

| Command | What it does |
| --- | --- |
| `\singlish{text}` | Convert and typeset in the Sinhala font. Robust: works in `\section{}`, captions, etc. |
| `\sing{text}` | Short form of `\singlish` |
| `\begin{singlishtext} ... \end{singlishtext}` | Convert every line of a whole passage. Start the text on the line after `\begin`. |
| `\lat{text}` | Latin text inside Sinhala, left unconverted |
| `\singlishraw{text}` | Convert only, no font change |
| `\singlishsetfont[opts]{font}` | Change the body Sinhala font mid-document (short name or any font name) |
| `\singlishsetheadfont[opts]{font}` | Change the heading font mid-document |
| `\singlishheading` | Put in a custom heading format (e.g. titlesec) to use the heading font there |
| `\silipsum[2-4]` | Sinhala dummy text, like `\lipsum` (meaningless pseudo-words; paragraph *n* is always the same). `\silipsum*` runs paragraphs together |

TeX commands, math (`$...$`, `\(...\)`, `\[...\]`) and comments pass through untouched. Arguments of `\cite`, `\ref`, `\label`, `\url`, `\textcolor`, `\si`, `\SI`, `\lat` and similar commands are never converted.

## Fonts

| Option | Font | License |
| --- | --- | --- |
| `font=noto-sans` (default) | Noto Sans Sinhala | OFL |
| `font=noto-serif` | Noto Serif Sinhala | OFL |
| `font=abhaya` | Abhaya Libre | OFL |
| `font=yaldevi` | Yaldevi | OFL |
| `font=gemunu` | Gemunu Libre | OFL |
| `font=iskoola` | Iskoola Pota (Windows only) | proprietary |
| `font={Any Font}` | any installed Sinhala font | |

Each known font is already scaled to sit well beside Latin text (`scale=`). Abhaya Libre and Noto Sans Sinhala (Regular and Bold, OFL) are included in [`fonts/`](fonts/). The others are free from [Google Fonts](https://fonts.google.com/?subset=sinhala).

#For a known font, files next to your document are used first: with `font=abhaya`, the package #looks for `AbhayaLibre-Regular.ttf` and `AbhayaLibre-Bold.ttf` in the project folder, then for #an installed *Abhaya Libre*. File stems: `NotoSansSinhala`, `NotoSerifSinhala`, `AbhayaLibre`, #`Yaldevi`, `GemunuLibre`.

## Typing guide (summary)

| Type | Get | | Type | Get |
| --- | --- | --- | --- | --- |
| `a aa ae aee` | අ ආ ඇ ඈ | | `k K g G` | ක ඛ ග ඝ |
| `i ii u uu` | ඉ ඊ උ ඌ | | `ch C j J` | ච ඡ ජ ඣ |
| `e ee ai` | එ ඒ ඓ | | `t T d D N` | ට ඨ ඩ ඪ ණ |
| `o oo au` | ඔ ඕ ඖ | | `th Th dh Dh n` | ත ථ ද ධ න |
| `R` | ඍ / ෘ | | `p P b B m` | ප ඵ බ භ ම |
| `x` | ං | | `y r l L v` | ය ර ල ළ ව |
| `H` | ඃ | | `sh S s h f` | ශ ෂ ස හ ෆ |
| `zg zj zD zd zb` | ඟ ඦ ඬ ඳ ඹ | | `Ng Ny GN` | ඞ ඤ ඥ |

- A consonant without a vowel gets hal kirima: `amma` → අම්ම
- Consonant + `y` / `r` → yansaya / rakaransaya automatically: `vidhyaava` → විද්‍යාව, `prashnaya` → ප්‍රශ්නය
- `^` joins letters: `Dhar^maya` → ධර්‍මය (repaya), `k^Sa` → ක්‍ෂ
- `|` separates letters and prints nothing: `k|ya` → ක්ය
- Already-Sinhala Unicode text passes through unchanged.

The full mapping is in [`doc/mapping.md`](doc/mapping.md); every rule is checked by [`tests/words.tsv`](tests/words.tsv).

## Command line

```sh
texlua tex/singlish.lua "shrii laxkaava"     # ශ්‍රී ලංකාව
texlua tex/singlish.lua < input.txt          # convert a file line by line
```

## Installing before it is on CTAN

Copy `tex/singlish.sty` and `tex/singlish.lua` next to your `.tex` file.

**Overleaf:** upload `singlish.sty`, `singlish.lua`, `latexmkrc` and the four `.ttf` files from `fonts/` to the project's main folder, then use `\usepackage[font=abhaya, headfont=noto-sans]{singlish}`. A ready-made project is in [`overleaf/`](overleaf/): upload its zip via *New Project → Upload Project*.

## Development

```sh
make test      # run the transliteration test suite
make sample    # build doc/singlish-sample.pdf
make ctan      # build singlish.zip for CTAN upload
```

When changing the mapping, add the affected words to `tests/words.tsv` first. Never change what an existing input produces in a minor release.

## License

Copyright © 2026 Dehiwalage Don Dilruwan. This work may be distributed and/or modified under the conditions of the LaTeX Project Public License version 1.3c or later. The fonts in `fonts/` are separate works distributed under the SIL Open Font License 1.1 and their license files are next to them.
