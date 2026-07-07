# 📋 Iteration Summary — FDM Visual Designer
## Format: Kumulatif per Iterasi | Spesifikasi: Revisi 3 Final

> File ini merangkum pencapaian, masalah, dan lesson learned di setiap akhir iterasi.
> Dibuat setelah semua test lulus dan iterasi dinyatakan selesai.

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1a — Fondasi Canvas & Three-Node Architecture
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

═══════════════════════════════════════════════════════════════════
## ITERASI 3a s.d. 7 — Fitur Lanjutan & Finalisasi
### Status: ✅ Selesai
═══════════════════════════════════════════════════════════════════

- **Tanggal Selesai**: 2026-07-07
- **Durasi Aktual**: 9 jam 40 m (kumulatif)
- **Status Akhir**: ✅ Selesai
- **Fitur Selesai**: 
  - **Iterasi 3a (Edge System)**: Routing Bézier Cubic, garis putus-putus (*dashed Bézier*) untuk referencing, double arrowheads untuk denormalization, dan label float.
  - **Iterasi 3b (Security Boundary)**: Pembuatan resizable boundary (PUBLIC & PRIVATE/OWNER), deteksi containment node di dalam area boundary, serta validasi overlap.
  - **Iterasi 4a (WFR Validator Engine)**: Mesin validasi reaktif 8 aturan semantik (R1-R8) dan rendering overlay badge error/warning merah/kuning di pojok node.
  - **Iterasi 4b (Toolbar)**: Ekspor PNG resolusi tinggi via RepaintBoundary, ekspor SVG, ekspor/impor skema JSON diagram, dan zoom buttons.
  - **Iterasi 5a & 5b (Sidebars & Visuals)**: Palette drag-drop sidebar kiri, detail panel properti, responsif layout, dan opacity gelap reaktif.
  - **Iterasi 6a & 6b (Undo/Redo & Alignment)**: Command Pattern stack undo/redo untuk operasi diagram, alignment tools (align top/middle/bottom/left), snapping grid.
  - **Iterasi 7 (Final Polishing)**: Pintasan keyboard global komprehensif, pencegahan *default action* tab browser (Ctrl+D/E/L), mode tema dinamis Light/Dark mode, dan headed E2E integration test visual via Scheduled Task.
- **REQ yang Ditutup**: REQ-020 s.d. REQ-050

---

## Dashboard Progres Keseluruhan

| Iterasi | Status | Durasi Aktual | REQ Ditutup | Test |
|---------|--------|---------------|-------------|------|
| 1a | ✅ Selesai | 2 jam 11 m | 9/9 | PASS |
| 1b | ✅ Selesai | 19 m | 5/5 | PASS |
| 2a | ✅ Selesai | 38 m | 3/3 | PASS |
| 2b | ✅ Selesai | 50 m | 2/2 | PASS |
| 3a | ✅ Selesai | 2 jam 0 m | 4/4 | PASS |
| 3b | ✅ Selesai | 1 jam 30 m | 3/3 | PASS |
| 4a | ✅ Selesai | 2 jam 30 m | 9/9 | PASS |
| 4b | ✅ Selesai | 30 m | 4/4 | PASS |
| 5a | ✅ Selesai | 30 m | 2/2 | PASS |
| 5b | ✅ Selesai | 30 m | 2/2 | PASS |
| 6a | ✅ Selesai | 30 m | 2/2 | PASS |
| 6b | ✅ Selesai | 30 m | 4/4 | PASS |
| 7 | ✅ Selesai | 1 jam 30 m | 1/1 | PASS |
| **Total** | **✅ Selesai** | **13 jam 28 m** | **50/50** | **PASS** |

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: 2026-07-07*
