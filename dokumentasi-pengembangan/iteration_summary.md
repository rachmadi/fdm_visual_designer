# 📋 Iteration Summary — FDM Visual Designer
## Format: Kumulatif per Iterasi | Spesifikasi: Revisi 3 Final

> File ini merangkum pencapaian, masalah, dan lesson learned di setiap akhir iterasi.
> Dibuat setelah semua test lulus dan iterasi dinyatakan selesai.

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1a — Fondasi Canvas & Two-Node Architecture with Query Vector
### Status: ✅ Selesai
═══════════════════════════════════════════════════════════════════

- **Tanggal Mulai**: 2026-06-27
- **Tanggal Selesai**: 2026-07-06
- **Durasi Aktual**: 2 jam 11 m
- **Status Akhir**: ✅ Selesai
- **Fitur Selesai**: Fondasi InteractiveViewer, inversi matriks delta drag, dan 3 metamodel dasar.
- **REQ yang Ditutup**: REQ-001 s.d. REQ-009
- **Lesson Learned**: InteractiveViewer dengan `constrained: false` mempertahankan ukuran rendering child.

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1b — Node Interaction
### Status: ✅ Selesai
═══════════════════════════════════════════════════════════════════

- **Tanggal Mulai**: 2026-07-06
- **Tanggal Selesai**: 2026-07-06
- **Status Akhir**: ✅ Selesai
- **Durasi Aktual**: 19 m
- **Target**: Add, Select, Move, Delete Node, dan Edge routing dasar.
- **Hasil Utama**: 
  - Fungsionalitas pembuatan node (SN & EN) via sidebar palette dengan grid-based spawn layout.
  - Penyeretan/geser node yang stabil pada semua tingkat zoom menggunakan matriks inversi canvas space.
  - Seleksi node via tap dengan outline highlight kuning/amber.
  - Penghapusan node terseleksi via Keyboard Shortcuts (`Del`) atau toolbar.
- **REQ yang Ditutup**: REQ-010 s.d. REQ-014

---

═══════════════════════════════════════════════════════════════════
## ITERASI 2a — Property Editor & Form Validation
### Status: ✅ Selesai
═══════════════════════════════════════════════════════════════════

- **Tanggal Mulai**: 2026-07-06
- **Tanggal Selesai**: 2026-07-07
- **Status Akhir**: ✅ Selesai
- **Durasi Aktual**: 38 m
- **Target**: Rombak UI list properti dengan ReorderableListView, edit inline nama/tipe, form tambah properti inline, real-time validation error, dan SnackBar Delete dengan Undo 3 detik.
- **REQ yang Ditutup**: REQ-015 s.d. REQ-017

---

═══════════════════════════════════════════════════════════════════
## ITERASI 2b — Query Vector & Tipe Data Detail
### Status: ✅ Selesai
═══════════════════════════════════════════════════════════════════

- **Tanggal Mulai**: 2026-07-07
- **Tanggal Selesai**: 2026-07-07
- **Status Akhir**: ✅ Selesai
- **Durasi Aktual**: 50 m
- **Target**: Dropdown tipe data terkapitalisasi penuh, submission dengan Enter, penyembunyian konektor handle, form konfigurasi Query Vector, render badge Query Vector di canvas, dan visualisasi estimasi index.
- **REQ yang Ditutup**: REQ-018 s.d. REQ-019
- **Lesson Learned**: CustomPainter untuk garis pemisah Structural Node membagi area tab atas dengan badan bawah secara dinamis tanpa mengganggu hit-test.

---

## ITERASI 3a — Edge System: Referencing & Denormalization
═══════════════════════════════════════════════════════════════════

- **Tanggal Mulai**: 2026-07-08
- **Tanggal Selesai**: 2026-07-08
- **Status Akhir**: ✅ Selesai
- **Durasi Aktual**: 56 m
- **Target**: Penyelarasan notasi garis panah putus-putus referencing dengan asterisk (*), garis tebal double arrowhead denormalisasi dengan label nama field, Bézier routing, dan dynamic anchor switching.
- **REQ yang Ditutup**: REQ-020 s.d. REQ-023
- **Lesson Learned**: Penyelarasan dini terhadap Panduan Notasi Visual mencegah implementasi fitur menyimpang (seperti Embedding edge) yang berpotensi merusak spesifikasi skema diagram JSON.

#### Cross-Artifact Integrity Check (Iterasi 3a)

| Artefak | Item yang Dicek | Nilai Sebelum | Nilai Sesudah | Hasil | Commit Perbaikan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `iteration_summary.md` | Durasi Aktual Iterasi 3a | `0 m` | `56 m` | `PASS` | `6dd902f` |
| `requirement_traceability_matrix.md` | Status REQ-024 s.d. REQ-026 | `🕒 Belum dimulai` | `Partially Implemented` (dengan catatan gap) | `PASS` | `6dd902f` |
| `requirement_traceability_matrix.md` | Status REQ-027 s.d. REQ-034 | `🕒 Belum dimulai` | `Technically Validated` (lulus unit test) | `PASS` | `6dd902f` |
| `requirement_traceability_matrix.md` | Status REQ-035, REQ-036, REQ-038 | `🕒 Belum dimulai` | `Implemented` / `Implemented (dengan gap)` | `PASS` | `6dd902f` |
| `README.md` & log-log IIDD | Nama Arsitektur Node | `Three-Node Architecture` | `Two-Node Architecture with Query Vector` | `PASS` | `6dd902f` |
| `interactive_test_log.md` | Tautan Screenshot | `file:///C:/Users/...` | `screenshots/iterasi_3a/...` (tautan relatif) | `PASS` | `6dd902f` |

*Integrity Check Hasil*: **`PASS`**

---

## ITERASI 3b s.d. 6b — Template Iter Summary (Skema Baru)
═══════════════════════════════════════════════════════════════════

- **Tanggal Mulai**: YYYY-MM-DD
- **Tanggal Selesai**: YYYY-MM-DD
- **Durasi Aktual (Skema Baru)**:
  - Elapsed Time (ET):
  - Active Agent Execution Time (AAET):
  - Human Interaction Time (HIT):
  - Recovery Time (RT):
  - Documentation & Governance Time (DGT):
- **Status Akhir**: ✅ Selesai
- **Fitur Selesai**:
- **REQ yang Ditutup**:
- **Lesson Learned**:

#### Cross-Artifact Integrity Check (Iterasi X)
* [ ] Status iterasi konsisten di RTM, Estimated/Actual Time, dan Iter Summary.
* [ ] Jumlah requirement konsisten di RTM dan Iter Summary.
* [ ] Durasi menggunakan definisi waktu yang sama di semua log.
* [ ] Requirement berstatus selesai memiliki bukti di Validation Log.
* [ ] Decision ID konsisten dengan Decision Log.
* [ ] Intervention ID konsisten dengan Human Intervention Log.
* [ ] Drift ID konsisten dengan Context Drift Log.
* [ ] Tidak terdapat iterasi/requirement fiktif di luar spesifikasi resmi.
* **Integrity Check**: `PASS` / `FAIL` (Catatan jika FAIL: )

---

## Dashboard Progres Keseluruhan

| Iterasi | Status | Durasi Aktual | REQ Ditutup | Test |
|---------|--------|---------------|-------------|------|
| 1a | ✅ Selesai | 2 jam 11 m | 9/9 | PASS |
| 1b | ✅ Selesai | 19 m | 5/5 | PASS |
| 2a | ✅ Selesai | 38 m | 3/3 | PASS |
| 2b | ✅ Selesai | 50 m | 2/2 | PASS |
| 3a | ✅ Selesai | 56 m | 4/4 | PASS |
| 3b | 🕒 Belum | — | 0/3 | — |
| 4a | 🕒 Belum | — | 0/9 | — |
| 4b | 🕒 Belum | — | 0/4 | — |
| 5a | 🕒 Belum | — | 0/2 | — |
| 5b | 🕒 Belum | — | 0/2 | — |
| 6a | 🕒 Belum | — | 0/2 | — |
| 6b | 🕒 Belum | — | 0/5 | — |
| **Total** | **⚠️ Partial** | **4 jam 54 m** | **23/50** | **PASS** |

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: 2026-07-11*
