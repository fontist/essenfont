# sources/

Third-party fonts used as glyph donors when building essenfont.

## What lives here

```
sources/
├── manifest.yml              # donor font registry (label, file, license, sha256, covers)
├── README.md                 # this file
├── fonts/                    # actual .ttf/.otf/.ttc files (gitignored — see below)
│   ├── NotoSans-Regular.ttf
│   ├── NotoSansCJK-Regular.ttc
│   ├── FSung-1.ttf           # local-only (Taiwan MOE 全宋體)
│   ├── Lentariso-Regular.otf
│   ├── Kedebideri-Regular.ttf
│   ├── NotoSerifTaiYo.ttf    # local-only (translationcommons.org pre-release)
│   ├── UniHieroglyphica.ttf
│   ├── EgyptianText-Regular.ttf
│   ├── BabelStonePseudographica.ttf
│   ├── Symbola.ttf
│   ├── NotoEmoji-Regular.ttf
│   ├── NotoSansMath-Regular.ttf
│   ├── NotoMusic-Regular.ttf
│   ├── NotoSansTangut-Regular.ttf
│   ├── NotoSansSharada-Regular.ttf
│   ├── NotoSansTolongSiki-Regular.ttf
│   └── LastResortHE-Regular.ttf
└── licenses/                 # each donor's OFL/license file (gitignored)
    ├── NotoSans-OFL.txt
    ├── FSung-OFL.txt
    └── ...
```

## `fonts/` is gitignored

Font files are NOT committed to the essenfont repo:

- They can be large (NotoSansCJK is 18MB; NotoSans full is 8MB)
- They are redistributed under OFL which requires attribution but
  allows free redistribution — keeping them out of git keeps the
  repo lean and makes license auditing easier
- The build script verifies each donor's sha256 against `manifest.yml`

## Acquiring donors

### Auto-downloadable (via ucode fetch fonts)

```bash
# In the ucode repo:
cd /path/to/ucode
bundle exec ucode fetch fonts

# Then copy to essenfont:
cp /path/to/ucode/data/fonts/*.ttf /path/to/essenfont/sources/fonts/
cp /path/to/ucode/data/fonts/*.otf /path/to/essenfont/sources/fonts/
cp /path/to/ucode/data/fonts/*.ttc /path/to/essenfont/sources/fonts/
```

ucode's `config/specialist_fonts.yml` declares each specialist's
download URL + sha256. ucode downloads + verifies automatically.

### Manual (path_local_only entries)

These donors are not available via URL (proprietary distribution
channels, pre-release, or academic sources):

| Donor | Acquisition |
|---|---|
| `fsung-1` (Taiwan MOE 全宋體) | User must download from the Taiwan MOE website; place at `sources/fonts/FSung-1.ttf` |
| `noto-serif-tai-yo` | Pre-release Noto variant; contact translationcommons.org maintainers; place at `sources/fonts/NotoSerifTaiYo.ttf` |

The build script verifies sha256 against `manifest.yml` to ensure
the user supplied the expected version.

## The manifest file

See `manifest.yml` (TODO.essenfont/08 for the spec). Each entry
declares:

- `label` — stable identifier used in ucode's universal-set manifest
- `file` — relative path under `sources/fonts/`
- `family` + `style` + `version` — human-readable metadata
- `license` — must be OFL, Apache, MIT, BSD, CC0, UFL, Bitstream,
  GUST, or CC-BY. Proprietary fonts are rejected at build time.
- `sha256` — content hash for verification
- `url` + `url_extract_member` (optional) — download URL + which
  file to extract from the downloaded archive
- `path_local_only` (optional) — true if the donor must be supplied
  manually
- `font_index` (optional, TTC only) — which face to use
- `covers` — list of Unicode block IDs this donor covers (informational)
- `notes` — free-text rationale

## License enforcement

The build refuses to use any donor with a license not in the OFL-
compatible allowlist. This ensures essenfont's output is
redistributable under OFL.

A `LICENSE-SOURCES.md` is auto-generated per release, listing every
donor's license + attribution. Included alongside the final TTF in
GitHub Releases.

## Adding a new donor

1. Download the font to `sources/fonts/<filename>`
2. Compute sha256: `shasum -a 256 sources/fonts/<filename>`
3. Add an entry to `manifest.yml`
4. Re-run ucode's universal-set build to record per-cp coverage
   for the new donor
5. Test the build: `ruby scripts/stitch.rb`
