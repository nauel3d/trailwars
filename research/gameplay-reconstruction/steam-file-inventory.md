# Steam target inventory — 2026-11-09

Read-only filesystem inventory of C:/Program Files (x86)/Steam/steamapps/common/CurveFeverPro. No assets or implementation copied into production. Private filenames, raw source snippets and REA graph records remain under ignored private/.

appmanifest_1133700.acf still declares app 1133700, install CurveFeverPro, build 26292297, StateFlags 4, depot 1133702 manifest 1476631450958622734. Private account owner identifier omitted. Runtime game version 4.3.0 remains prior observed evidence; this static pass did not relaunch or re-read runtime UI.

| Target | Bytes | SHA256 |
| --- | ---: | --- |
| CurveFever.exe | 222032384 | 297ec8ab7b933984139f9e07d3b5f082b8bd1b8e8a55d0d844b62054f6808d9c |
| resources/app.asar | 6749734 | fa36f604e23c74f8d0c8a77bcb90b20fc4460614322e6f9ab8510a37dafe71ac |
| resources/build/assets/app-pNpNNO1T.js | 66435 | 67e91c459da916e8224f4ad266378bedee7974a524fc6fbef2c4daa0b7356bf6 |
| resources/build/assets/PlatformService-zkTPtK_x.js | 7742370 | fcaee093cbf48ccaa625c6a2016ed2f05669276402ebb01eb9eb4d90658ec5d6 |

Executable and ASAR match prior identities. Resources include app.asar.unpacked, assets, build, controller_config, discord_social_sdk and steamworks_sdk. ASAR contains wrapper/native dependencies; gameplay renderer is external under resources/build.

Filesystem walk: 2664 files, 504760539 bytes; this is current walked data, not Steam's manifest SizeOnDisk. Major file extensions: 1927 PNG, 420 SVG, 89 MP3, 58 PAK, 40 NODE, 28 WOFF/WOFF2, 12 DLL. Inventory has sizes and relative names, not per-file hashes for all assets. Full private inventory: private/steam-file-inventory.json; ASAR member metadata: private/asar-inventory.json; external build inventory: private/renderer-file-inventory.json. No bulk extraction occurred.

REA selected-scope directory root digest: 673f7cb3da1fed967491b9567da98887e3b03f0fcf8328d1b667355aa552371f. Parent ev_e37e5570f638d11588023315eb0f5496fa80c7ecc50dbd2ef88c2ff4facbac5b. Selected constants source only; 14 inventoried files remain outside semantic scope. This digest does not independently hash every Steam install file. See rea-investigation.md for capabilities and findings.
