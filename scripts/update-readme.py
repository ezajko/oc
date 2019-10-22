#!/usr/bin/env python3
"""
Read prompts from deploy.yml and update README
"""

import yaml
from io import StringIO
from shutil import move
from pprint import pprint as pp


def read_section(markdown, section_name):
    section = []
    gen = iter(markdown)
    for line in gen:
        if line.startswith("# %s" % section_name):
            while True:
                section.append(line)
                line = next(gen)
                if line.startswith("# "):
                    break
    return section


questions = yaml.full_load(open("questions.yml"))
s = StringIO()
print(
    """|name|prompt|default|choices|help|
|---|---|---|---|---|""",
    file=s,
)
for q in questions:
    q.setdefault("default", "")
    q["choices"] = ", ".join(q.get("choices", []))
    q["help"] = q.get("help", "").replace("\n", "<br/>")
    print("|{name}|{prompt}|{default}|{choices}|{help}".format_map(q), file=s)

with open("README.md", "r") as readme, open("README.md.tmp", "w") as tmp:
    for line in readme:
        tmp.write(line)
        if line.startswith("# Questions"):
            while not line.startswith("# "):
                print(line)
                line = next(readme)
    tmp.write(s.getvalue())
move("README.md.tmp", "README.md")
