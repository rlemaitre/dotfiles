import unittest

from op_dedupe.grouping import find_groups, group_key, normalize_host
from tests.op_dedupe.fixtures import summary


class GroupingTest(unittest.TestCase):
    def test_normalize_host(self):
        self.assertEqual(normalize_host("https://www.Example.com:8443/login?x=1#a"), "example.com")
        self.assertEqual(normalize_host("example.com/path"), "example.com")
        self.assertEqual(normalize_host(""), "")

    def test_url_key_uses_primary(self):
        s = summary(
            username="Me@Example.com",
            urls=(("https://other.example", False), ("https://example.com", True)),
        )
        self.assertEqual(group_key(s), ("url", "example.com", "me@example.com"))

    def test_title_key_without_url(self):
        s = summary(title="  My   Bank ", username="me", urls=())
        self.assertEqual(group_key(s), ("title", "my bank", "me"))

    def test_url_and_title_never_mix(self):
        with_url = summary(id="a", title="My Bank", username="me", urls=(("https://bank.example", True),))
        without_url = summary(id="b", title="My Bank", username="me", urls=())
        self.assertEqual(find_groups([with_url, without_url]), [])

    def test_no_url_no_username_is_skipped(self):
        self.assertIsNone(group_key(summary(username="", urls=())))

    def test_find_groups_keeps_groups_of_two_or_more(self):
        a = summary(id="a")
        b = summary(id="b", urls=(("https://www.example.com/login", True),))
        alone = summary(id="c", urls=(("https://other.example", True),))
        groups = find_groups([alone, b, a])
        self.assertEqual([[s["id"] for s in g] for g in groups], [["b", "a"]])


if __name__ == "__main__":
    unittest.main()
