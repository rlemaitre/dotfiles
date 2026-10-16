import subprocess
import unittest
from unittest import mock

from op_dedupe import opcli


class OpcliTest(unittest.TestCase):
    def test_edit_error_does_not_quote_op_stderr(self):
        failed = subprocess.CompletedProcess(args=[], returncode=1, stdout="", stderr='invalid value "SECRET-9"\n')
        with mock.patch("op_dedupe.opcli.subprocess.run", return_value=failed):
            with self.assertRaises(opcli.OpError) as caught:
                opcli.edit_item("item-1", "v-private", {"fields": []})
        self.assertNotIn("SECRET-9", str(caught.exception))
        self.assertIn("exit 1", str(caught.exception))

    def test_edit_sends_json_on_stdin_not_in_arguments(self):
        ok = subprocess.CompletedProcess(args=[], returncode=0, stdout="{}", stderr="")
        with mock.patch("op_dedupe.opcli.subprocess.run", return_value=ok) as run:
            opcli.edit_item("item-1", "v-private", {"fields": [{"value": "SECRET-9"}]})
        args, kwargs = run.call_args
        self.assertNotIn("SECRET-9", " ".join(args[0]))
        self.assertIn("SECRET-9", kwargs["input"])


if __name__ == "__main__":
    unittest.main()
