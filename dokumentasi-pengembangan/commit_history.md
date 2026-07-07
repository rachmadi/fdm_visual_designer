# ðŸ“ Commit History â€” FDM Visual Designer
## Format: Kumulatif per Iterasi | Spesifikasi: Revisi 3 Final

> File ini mencatat seluruh riwayat commit Git yang dilakukan selama pengembangan.
> Format mengikuti Conventional Commits (feat, fix, refactor, test, docs, chore).

---

## Konvensi Commit Message

\\\
<type>(<scope>): <deskripsi singkat>

[Deskripsi opsional]

[Footer/Breaking change opsional]
\\\

**Tipe yang digunakan:**
- \eat\ â€” Fitur baru
- \ix\ â€” Perbaikan bug
- \efactor\ â€” Refactoring tanpa perubahan fungsional
- \	est\ â€” Penambahan atau perbaikan test
- \docs\ â€” Perubahan dokumentasi saja
- \chore\ â€” Perubahan build, config, atau tooling

---

â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
## Riwayat Git Commit Proyek (Iterasi 1a s.d. Iterasi 7)
â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

| Hash | Tanggal | Author | Pesan Commit |
|------|---------|--------|--------------|
| `da4cd06` | 2026-07-07 | Antigravity | docs: synchronize commit_history.md with all recent commits |
| `7409a10` | 2026-07-07 | Antigravity | docs: restore all Agen planning and thought details in verbatim log while keeping clean formatting |
| `c950ff6` | 2026-07-07 | Antigravity | docs: format verbatim conversation log to remove system XML tags and isolate final dialog messages |
| `b558b75` | 2026-07-07 | Antigravity | docs: generate complete verbatim conversation log between IA and Agen from project start |
| `e05723f` | 2026-07-07 | Antigravity | docs: update changelog and conversation log with structural node visual revision and Vercel deployment details |
| `d4dfbdf` | 2026-07-07 | Antigravity | feat: implement query vector visual controls, custom capitalized data types, conditional connection handles, and structural node layout separation |
| `eb58dd3` | 2026-07-07 | Antigravity | feat(iter-2b): implement query vector dropdowns, conditional handles, enter submit, and visual canvas query vector badge |
| `cb00cd1` | 2026-07-07 | Antigravity | fix: ignore global shortcuts when typing in a TextField and clean unused fields/variables |
| `1c4432b` | 2026-07-07 | Antigravity | docs & test: update documentation and fix E2E integration test for Iteration 2a |
| `d33af1a` | 2026-07-07 | Antigravity | chore: fix SnackBar test assertion and finalize E2E integration test script |
| `9435be6` | 2026-07-07 | Antigravity | feat: implement property editor, ReorderableListView, input validation and SnackBar Undo (Iterasi 2a) |
| `cfea623` | 2026-07-06 | Antigravity | docs: correct project name and change IIDD index links to relative paths in README.md |
| `ef254b5` | 2026-07-06 | Antigravity | docs: rewrite README.md to serve as a project guide and IIDD documentation index |
| `039e355` | 2026-07-06 | Antigravity | docs: replace all occurrences of pengguna/user with Intent Architect in all IIDD log files |
| `20708b6` | 2026-07-06 | Antigravity | docs: populate validation_log.md and correct dates and durasi in iteration_summary.md for Iterasi 1a and 1b |
| `73c1f8b` | 2026-07-06 | Antigravity | docs(intervention): update human_intervention.md with all new interventions (total 14) |
| `a168e56` | 2026-07-06 | Antigravity | docs(decision): rewrite decision_log.md to include all key technical decisions from day one (June 27) onwards |
| `6462d90` | 2026-07-06 | Antigravity | docs(conversation): fully rewrite conversation_log.md to include all sessions from day one (June 27) onwards |
| `1c155f2` | 2026-07-06 | Antigravity | docs(drift): replace 'pengguna/user' with 'Intent Architect' in context_drift_log.md |
| `ec47412` | 2026-07-06 | Antigravity | docs(drift): fully rewrite context_drift_log.md using the exact format and tables from the Revisi 3 specifications |
| `fa4a93f` | 2026-07-06 | Antigravity | docs(documentation-pengembangan): fill in context drift CD-001 with canvas architecture details and join RTM table rows |
| `11c415c` | 2026-07-06 | Antigravity | docs: add project-wide documentation accuracy rules and record Sesi 6 activities |
| `94628fd` | 2026-07-06 | Antigravity | docs(documentation-pengembangan): correct waktu_estimasi_vs_realisasi.md component duration mapping to be mathematically consistent |
| `befeb6f` | 2026-07-06 | Antigravity | docs(documentation-pengembangan): update iteration duration and feature duration tables for Iterasi 1a and 1b |
| `bdb2ea2` | 2026-07-06 | Antigravity | feat(structural_node): refactor collection shape to UML package and place label inside tab; style(canvas): increase contrast and stroke width of dark mode grid lines for improved zoom-out visibility; test(app_test): merge E2E tests into a single flow to prevent browser restarts and add 35s hold delay; docs(agents): add rule to forbid user browser force-kills during headed tests |
| `96765f0` | 2026-07-06 | Antigravity | docs: start Iteration 1b (Node Interaction) in RTM and iteration summary |
| `2a4fa97` | 2026-07-06 | Antigravity | docs: add technical note on 4-sided dynamic connection anchors for future iterations |
| `8510f9c` | 2026-07-06 | Antigravity | feat: add Keyboard Shortcuts guide panel in sidebar left |
| `c6db36d` | 2026-07-06 | Antigravity | docs: revert iterations 1b-7 back to pending in IIDD logs to align with current Iteration 1a focus |
| `0b1118f` | 2026-07-06 | Antigravity | docs: finalize IIDD logs for human interventions, decisions, errors, and test logs |
| `1e7dd72` | 2026-07-06 | Antigravity | docs: update requirement traceability matrix and summary files with actual completed progress |
| `cf84058` | 2026-07-06 | Antigravity | fix: resolve browser shortcuts conflict and register global keyboard handler |
| `f43ba7a` | 2026-07-06 | Antigravity | docs: update development notes for shortcuts and dark mode session |
| `b795425` | 2026-07-06 | Antigravity | fix: finalize keyboard shortcuts and dark mode specifications in main and entity node |
| `d40e667` | 2026-07-06 | Antigravity | fix: finalize scheduled interactive headed E2E test session |

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: 2026-07-07*
