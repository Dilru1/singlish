# singlish mapping specification — v0.1 (draft, not frozen)

## Principles

1. **Longest match wins.** Keys of 3, then 2, then 1 characters are tried. `th` is ත, never ට + h.
2. **Case-sensitive.** Capitals give aspirated or retroflex variants (`K` ඛ, `N` ණ, `L` ළ).
3. **t/d are retroflex, th/dh are dental**: `t` ට, `th` ත, `d` ඩ, `dh` ද.
4. **Vowel length is explicit.** `a` short, `aa` long: `thaaththaa` → තාත්තා.
5. **A consonant with no vowel gets hal kirima (්).** `amma` → අම්ම.
6. **`|` is a silent separator.** `k|ra` → ක්ර.

## Vowels

| Input | Independent | Sign | Example |
| --- | --- | --- | --- |
| `a` | අ | — | `mama` → මම |
| `aa` | ආ | ා | `amaa` → අමා |
| `ae`, `A` | ඇ | ැ | `aeta` → ඇට |
| `aee`, `AA` | ඈ | ෑ | `kaeema` → කෑම |
| `i` | ඉ | ි | `ira` → ඉර |
| `ii` | ඊ | ී | `shrii` → ශ්‍රී |
| `u` | උ | ු | `udhaya` → උදය |
| `uu` | ඌ | ූ | `muuNa` → මූණ |
| `e` | එ | ෙ | `eka` → එක |
| `ee` | ඒ | ේ | `mee` → මේ |
| `ai` | ඓ | ෛ | `kaiya` → කෛය |
| `o` | ඔ | ො | `oya` → ඔය |
| `oo` | ඕ | ෝ | `koo` → කෝ |
| `au` | ඖ | ෞ | `kau` → කෞ |
| `R` | ඍ | ෘ | `kRSi` → කෘෂි |
| `RR` | ඎ | ෲ | rare |

## Consonants

| Group | Plain | Aspirated | Nasal | Prenasalised |
| --- | --- | --- | --- | --- |
| Velar | `k` ක · `g` ග | `K`/`kh` ඛ · `G`/`gh` ඝ | `Ng` ඞ | `zg` ඟ |
| Palatal | `ch` ච · `j` ජ | `C`/`chh` ඡ · `J`/`jh` ඣ | `Ny` ඤ · `GN` ඥ | `zj` ඦ |
| Retroflex | `t` ට · `d` ඩ | `T` ඨ · `D` ඪ | `N` ණ | `zD` ඬ |
| Dental | `th` ත · `dh` ද | `Th` ථ · `Dh` ධ | `n` න | `zd` ඳ |
| Labial | `p` ප · `b` බ | `P`/`ph` ඵ · `B`/`bh` භ | `m` ම | `zb` ඹ |

Others: `y` ය · `r` ර · `l` ල · `L` ළ · `v`/`w` ව · `sh` ශ · `S`/`Sh` ෂ · `s` ස · `h` හ · `f` ෆ

## Special signs and conjuncts

| Form | Input | Emits | Example |
| --- | --- | --- | --- |
| Hal kirima | consonant, no vowel | C + ් | `amma` → අම්ම |
| Anusvara | `x` | ං | `laxkaava` → ලංකාව |
| Visarga | `H` | ඃ | `dhuHkha` → දුඃඛ |
| Yansaya (auto) | consonant + `y` | C + ් + ZWJ + ය | `vidhyaava` → විද්‍යාව |
| Rakaransaya (auto) | consonant + `r` | C + ් + ZWJ + ර | `prashnaya` → ප්‍රශ්නය |
| Repaya (opt-in) | `r^` + consonant | ර + ් + ZWJ + C | `Dhar^maya` → ධර්‍මය |
| Conjunct (opt-in) | consonant `^` consonant | C + ් + ZWJ + C | `k^Sa` → ක්‍ෂ |
| Plain hal + ya/ra | separator between | C + ් + ය | `k\|ya` → ක්ය |

- After `r`, `y` and `r` give plain ර්ය / ර්ර (no yansaya on ර).
- Without `^`, `rm` gives ර්ම (`karmaya` → කර්මය).
- Touching letters are not in v0.1.

## Pass-through

TeX control sequences, math, comments, Unicode Sinhala, digits and punctuation are copied unchanged. The first argument of these commands is never converted: `\lat \cite \citep \citet \ref \eqref \pageref \label \url \href \includegraphics \input \include \begin \end \textcolor \color \hspace \vspace \ensuremath \si \num \unit \ce` (and both arguments of `\SI`).

## Open questions before v1.0

- Match Helakuru's keys exactly where they differ (`x`, `z` prefix, `Ny`/`GN`/`Ng`)?
- Automatic ං and sanyaka (`lankaava`, `sanda`) without special keys?
- Keep aliases (`w`, `kh`, `A`...)?
- Is `|` the right separator (it collides with `tabular` column specs only outside `\singlish`)?
- Sinhala digits, touching letters, Pali letters: v1 or later?
