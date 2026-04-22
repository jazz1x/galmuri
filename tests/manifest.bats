#!/usr/bin/env bats
# tests/manifest.bats — plugin / marketplace / skill manifest schema checks.
#
# Every assertion here is a regression guard against an install failure
# that actually shipped to main:
#   - PR #3:  skills field was an array of {name,path}
#   - PR #4:  plugin.json used 'homepage' instead of 'repository'
#   - PR #5:  SKILL.md frontmatter names contained 'galmuri:' prefix
# Do not relax these without reproducing the original failure first.

load "$BATS_TEST_DIRNAME/setup.bash"

@test "plugin.json is valid JSON" {
  run python3 -m json.tool "$REPO_ROOT/.claude-plugin/plugin.json"
  [ "$status" -eq 0 ]
}

@test "plugin.json has required fields" {
  run python3 -c "
import json
d = json.load(open('$REPO_ROOT/.claude-plugin/plugin.json'))
for k in ('name', 'version', 'description', 'skills'):
    assert k in d, f'missing: {k}'
"
  [ "$status" -eq 0 ]
}

@test "plugin.json skills field is a directory path string" {
  run python3 -c "
import json, os
d = json.load(open('$REPO_ROOT/.claude-plugin/plugin.json'))
s = d['skills']
assert isinstance(s, str), f'skills must be a string path, got {type(s).__name__}'
assert s.startswith('./'), f'skills must start with ./, got {s!r}'
assert os.path.isdir(os.path.join('$REPO_ROOT', s)), f'skills dir missing: {s}'
"
  [ "$status" -eq 0 ]
}

@test "plugin.json uses 'repository' not 'homepage'" {
  run python3 -c "
import json
d = json.load(open('$REPO_ROOT/.claude-plugin/plugin.json'))
assert 'homepage' not in d, \"'homepage' is not a recognized plugin field — use 'repository'\"
assert 'repository' in d, 'repository field missing'
"
  [ "$status" -eq 0 ]
}

@test "plugin.json version is SemVer" {
  run python3 -c "
import json, re
v = json.load(open('$REPO_ROOT/.claude-plugin/plugin.json'))['version']
assert re.fullmatch(r'\d+\.\d+\.\d+', v), f'not SemVer: {v}'
"
  [ "$status" -eq 0 ]
}

@test "marketplace.json is valid JSON" {
  run python3 -m json.tool "$REPO_ROOT/.claude-plugin/marketplace.json"
  [ "$status" -eq 0 ]
}

@test "marketplace.json plugins[].source starts with './'" {
  run python3 -c "
import json
d = json.load(open('$REPO_ROOT/.claude-plugin/marketplace.json'))
for i, p in enumerate(d['plugins']):
    s = p.get('source')
    assert isinstance(s, str) and s.startswith('./'), f'plugins[{i}].source invalid: {s!r}'
"
  [ "$status" -eq 0 ]
}

@test "marketplace.json plugin version matches plugin.json version" {
  run python3 -c "
import json
pj = json.load(open('$REPO_ROOT/.claude-plugin/plugin.json'))
mj = json.load(open('$REPO_ROOT/.claude-plugin/marketplace.json'))
for p in mj['plugins']:
    if p['name'] == pj['name'] and 'version' in p:
        assert p['version'] == pj['version'], f\"version drift: plugin.json={pj['version']} marketplace.json={p['version']}\"
"
  [ "$status" -eq 0 ]
}

@test "every skill directory has a SKILL.md with valid frontmatter" {
  run python3 -c "
import os, re
root = '$REPO_ROOT/skills'
bad = []
for name in sorted(os.listdir(root)):
    sdir = os.path.join(root, name)
    if not os.path.isdir(sdir): continue
    path = os.path.join(sdir, 'SKILL.md')
    if not os.path.isfile(path):
        bad.append(f'{name}: missing SKILL.md'); continue
    head = open(path).read(2000)
    if not head.startswith('---\n'):
        bad.append(f'{name}: no frontmatter'); continue
    fm = head.split('---\n', 2)[1]
    for k in ('name:', 'version:', 'description:'):
        if k not in fm:
            bad.append(f'{name}: missing {k}')
    m = re.search(r'^version:\s*(\S+)', fm, re.M)
    if m and not re.fullmatch(r'\d+\.\d+\.\d+', m.group(1)):
        bad.append(f'{name}: version not SemVer ({m.group(1)})')
    n = re.search(r'^name:\s*(\S+)', fm, re.M)
    if n:
        nv = n.group(1)
        if ':' in nv:
            bad.append(f'{name}: frontmatter name contains colon ({nv})')
        if nv != name:
            bad.append(f'{name}: frontmatter name ({nv}) != directory ({name})')
assert not bad, bad
"
  [ "$status" -eq 0 ]
}

@test "README.md and README.ko.md heading structures match" {
  run bash "$REPO_ROOT/scripts/i18n-sync-check.sh" "$REPO_ROOT/README.md"
  [ "$status" -eq 0 ]
}

@test "every SKILL.md description declares Triggers for auto-invocation" {
  run python3 -c "
import os, re
root = '$REPO_ROOT/skills'
bad = []
for name in sorted(os.listdir(root)):
    path = os.path.join(root, name, 'SKILL.md')
    if not os.path.isfile(path): continue
    head = open(path).read(2000)
    if not head.startswith('---\n'): continue
    fm = head.split('---\n', 2)[1]
    desc_match = re.search(r'description:([\s\S]*?)(?=\n\w+:|$)', fm)
    desc = desc_match.group(1) if desc_match else ''
    if 'Triggers:' not in desc:
        bad.append(f'{name}: description missing Triggers: line')
assert not bad, bad
"
  [ "$status" -eq 0 ]
}

@test "every SKILL.md documents a natural-language fallback for missing args" {
  # Regression guard for the conversational-entry contract: when a user
  # invokes a skill bare, the skill must ask in plain language (not error
  # out on a missing flag). The fallback example lives in SKILL.md prose.
  # Heuristic: each SKILL.md body must contain at least one '예:' or 'e.g.'
  # sample phrase tied to an ask, and must reference the user-facing
  # question explicitly (ends with '?').
  run python3 -c "
import os, re
root = '$REPO_ROOT/skills'
bad = []
for name in sorted(os.listdir(root)):
    path = os.path.join(root, name, 'SKILL.md')
    if not os.path.isfile(path): continue
    body = open(path).read()
    # Strip frontmatter
    if body.startswith('---\n'):
        body = body.split('---\n', 2)[2]
    has_question = '?' in body
    has_example = ('예:' in body) or ('e.g.' in body) or ('예시' in body)
    if not (has_question and has_example):
        bad.append(f'{name}: missing conversational fallback (question={has_question}, example={has_example})')
assert not bad, bad
"
  [ "$status" -eq 0 ]
}
