from pathlib import Path
import unittest
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
CT_PATH = ROOT / "FIFA_17_Cheat_Table.CT"


class PlayerEditorGuiTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tree = ET.parse(CT_PATH)
        cls.root = cls.tree.getroot()

    def _entry_by_description(self, description):
        for entry in self.root.findall(".//CheatEntry"):
            desc = entry.findtext("Description")
            if desc == description:
                return entry
        self.fail(f"Missing cheat entry {description!r}")

    def test_attribute_tracer_gui_is_openable_and_metadata_driven(self):
        entry = self._entry_by_description('"Open Player Editor GUI"')
        script = entry.findtext("AssemblerScript") or ""

        expected_snippets = [
            "Players Editor",
            "createForm(false)",
            "Load Current Player",
            "Apply Changes",
            "Reload",
            "statusLabel",
            "playerEditorFields",
            'label = "PlayerOVR"',
            'controlName = "PlayerOVREdit"',
            "editable = false",
            'label = "Acceleration"',
            'controlName = "AccelerationEdit"',
            'variableType = vtDword',
            'baseSymbol = "ptrNotEditable"',
            'baseSymbol = "ptrPlayer"',
            "resolver = \"ptrNotEditable\"",
            "resolver = \"pointerChain\"",
            "offsets = {0x42 * 8}",
            "offsets = {0x20, 0, 0x5b * 8, 0x68}",
            "resolvePtrNotEditableAddress",
            "resolvePointerChainAddress",
            "getAddressSafe(field.baseSymbol)",
            "if baseAddress == nil or baseAddress == 0 then",
            "return tableBase + field.offsets[1], nil",
            "readInteger(address)",
            "writeInteger(write.address, write.value)",
            "Value for ",
            " must be between ",
            "setReadOnlyStyle",
            "control.Font.Color = 0x00000000",
            "readBack = readInteger(write.address)",
            "before = readInteger(address)",
            "label = field.label",
            '" from " .. tostring(lastWrite.before) .. " to " .. tostring(readBack)',
        ]

        missing = [snippet for snippet in expected_snippets if snippet not in script]
        self.assertEqual([], missing)


if __name__ == "__main__":
    unittest.main()
