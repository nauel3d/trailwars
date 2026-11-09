"""Check real Rojo output rather than assuming a JSON map excludes dev code."""
from pathlib import Path
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parent.parent
production = ET.parse(root / "dist" / "TrailWars.rbxlx")
preview = ET.parse(root / "dist" / "TrailWarsPreview.rbxlx")

def names(tree):
    return {element.text for element in tree.findall(".//Properties/string[@name='Name']")}

prod_names, preview_names = names(production), names(preview)
assert "TrailWarsDev" not in prod_names, "Development stories leaked into production"
assert "FoundationTests" not in prod_names, "Tests leaked into production"
assert "_TrailWarsTestFixture" not in prod_names, "Temporary Studio fixture leaked into production"
assert not any(".story" in (name or "") for name in prod_names), "Story module leaked into production"
assert "TrailWarsDev" in preview_names, "Preview is missing development stories"
sources = [element.text or "" for element in production.findall(".//Properties/*[@name='Source']")]
assert not any("_TrailWarsTestFixture" in source for source in sources), "Temporary fixture source leaked"
assert any("ProcessReceipt" in source for source in sources), "Production server source missing"
print("ARTIFACT BOUNDARY: production excludes dev/stories, tests and temporary fixture; preview includes stories")

gameplay = ET.parse(root / "dist" / "TrailWarsMultiplayerGameplay.rbxlx")
gameplay_names = names(gameplay)
assert "Main" not in gameplay_names, "Default UI backend must not run alongside the isolated match adapter"
assert "StudioGameplayTest" not in gameplay_names, "Engine fixture leaked into gameplay build"
print("GAMEPLAY BOUNDARY: isolated adapter; default Main and engine fixtures excluded")

playtest = ET.parse(root / "dist" / "TrailWarsNov10Playtest.rbxlx")
playtest_names = names(playtest)
assert "Nov10Test" not in playtest_names, "Controlled test fixture leaked into playtest"
assert "Main" not in playtest_names, "Production backend must not run alongside mock playtest"
assert "PlaytestMatchService" in playtest_names and "PowerService" in playtest_names
print("PLAYTEST BOUNDARY: integrated powers mode; mock adapter; controlled fixtures excluded")
