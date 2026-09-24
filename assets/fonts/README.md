# Bundled fonts

All three families are licensed under the SIL Open Font License 1.1. Each
licence ships next to its files.

| Family | Files | Source | Licence |
|---|---|---|---|
| Alexandria (UI) | `Alexandria-Light.ttf` (300), `-Regular` (400), `-Medium` (500) | `google/fonts` `ofl/alexandria/Alexandria[wght].ttf` @ `fffdadf0` (upstream: github.com/Gue3bara/Alexandria) | `Alexandria-OFL.txt` |
| Scheherazade New (athkar) | `ScheherazadeNew-Regular.ttf`, `-Medium.ttf` | `google/fonts` `ofl/scheherazadenew` @ `df5c4a17` (SIL Global) | `ScheherazadeNew-OFL.txt` |
| Amiri Quran (optional Quranic script) | `AmiriQuran-Regular.ttf` | `google/fonts` `ofl/amiriquran` | `AmiriQuran-OFL.txt` |

## Why the Alexandria files are instances

Alexandria is published only as a variable font. Flutter doesn't reliably
drive the `wght` axis from `FontWeight`, so the three weights the design uses
are pinned as static instances of the official variable font:

```bash
pip install fonttools
fonttools varLib.instancer 'Alexandria[wght].ttf' wght=300 --update-name-table -o Alexandria-Light.ttf
fonttools varLib.instancer 'Alexandria[wght].ttf' wght=400 --update-name-table -o Alexandria-Regular.ttf
fonttools varLib.instancer 'Alexandria[wght].ttf' wght=500 --update-name-table -o Alexandria-Medium.ttf
```

The glyphs are unchanged and there are no Reserved Font Names, so the family
name stays "Alexandria".
