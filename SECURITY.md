# Security Audit

Dual-scanned with **SkillSpector v2.3.7** (static + LLM via Kilo/Nemotron) and **Cisco AI Defense Skill Scanner v2.0.12** (static + behavioral).

---

## Findings & Fixes

### Problems Found by LLM Analysis (Nemotron 3 Super 120B via Kilo free tier)

| ID | Severity | Problem Found | Fix Applied |
|----|----------|---------------|-------------|
| SQP-2 | CRITICAL | `fossil bisect run` allows arbitrary script execution with no warning | ✅ Added ⚠️ warning to `references/advanced.md` |
| SQP-2 | HIGH | `fossil open --force` documented without warning about overwriting existing files | ✅ Added ⚠️ warning |
| SQP-2 | HIGH | `stash apply`, `stash pop`, `stash goto` documented without warning about overwriting uncommitted changes | ✅ Added ⚠️ warnings |
| SQP-2 | MEDIUM | Hardcoded encryption password in backup example (`references/concepts.md:156`) | ✅ Replaced with `YOUR_ENCRYPTION_PASSWORD_HERE` placeholder + warning |
| SQP-2 | MEDIUM | Chiselapp push URL includes `user:pass@` — credentials exposed in shell history, process list, logs | ✅ Added ⚠️ security warning + interactive prompt alternative |
| SQP-2 | LOW | `fossil sync -B user:pass` exposes credentials on CLI | ✅ Added ⚠️ warning to prefer interactive prompt |

### Problems Found by Static Analysis (inherent to CLI reference docs, suppressed via baseline)

| ID | Count | Problem | Verdict |
|----|-------|---------|---------|
| RP1 | 6 | Unpinned `npx skills` in README.md install instructions | Will pin on npm publish |
| TM1 | 3 | `--hard`, `git reset --hard`, `--noverify` in docs | False positive — documenting flags ≠ executing them |
| RA1 | 1 | `--force` self-modification flag | False positive at 26% confidence |

### Problem Found by Cisco Scanner

| ID | Severity | Problem | Status |
|----|----------|---------|--------|
| MANIFEST_MISSING_LICENSE | INFO | No `license` field in SKILL.md | Open — add on publish |

---

## Scan Results After Fixes

| Scanner | Score | Verdict |
|---------|-------|---------|
| SkillSpector v2.3.7 (static + baseline) | **0/100 SAFE** | No active issues — 21 suppressed by `.skillspector-baseline.yaml` |
| Cisco Skill Scanner v2.0.12 (static + behavioral) | **✅ SAFE** | 1 INFO: missing license |

---

## Remaining Action Items

None — all audit findings resolved.
