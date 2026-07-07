# ⏱️ Estimasi vs Realisasi Waktu — FDM Visual Designer
## Format: Kumulatif per Iterasi | Spesifikasi: Revisi 3 Final

> File ini membandingkan estimasi waktu dari spesifikasi dengan waktu aktual pengerjaan.
> Analisis deviasi digunakan untuk memperbaiki estimasi iterasi berikutnya.

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1a — Fondasi Canvas & Three-Node Architecture
═══════════════════════════════════════════════════════════════════

| Komponen | Estimasi | Waktu Mulai | Waktu Selesai | Realisasi | Deviasi | Catatan |
|----------|----------|-------------|---------------|-----------|---------|---------|
| Setup & analisis | 0,5 jam | 11:10 | 11:40 | 30 menit | 0 menit | Selesai |
| InteractiveViewer + controller | 1,5 jam | 11:40 | 12:10 | 30 menit | -60 menit | Selesai |
| Inversi matriks koordinat | 1 jam | 12:10 | 12:30 | 20 menit | -40 menit | Selesai |
| Metamodel (3 node) | 1 jam | 12:30 | 12:45 | 15 menit | -45 menit | Selesai |
| CustomPainter (3 painter) | 1,5 jam | 12:45 | 13:00 | 15 menit | -75 menit | Selesai |
| State Riverpod Notifier | 1 jam | 13:00 | 13:12 | 12 menit | -48 menit | Selesai |
| Integration test + debug | 1 jam | 13:12 | 13:21 | 9 menit | -51 menit | Selesai |
| **Total Iterasi 1a** | **~7,5 jam** | **11:10** | **13:21** | **2 jam 11 m** | **-5 jam 19 m** | Selesai lebih cepat dari estimasi |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1b — Node Interaction
═══════════════════════════════════════════════════════════════════

| Komponen | Estimasi | Waktu Mulai | Waktu Selesai | Realisasi | Deviasi | Catatan |
|----------|----------|-------------|---------------|-----------|---------|---------|
| Add node (tap to add) | 1 jam | 11:51 | 11:53 | 2 menit | -58 menit | Selesai via sidebar palette grid spawn |
| Select node + highlight | 1 jam | 11:53 | 11:55 | 2 menit | -58 menit | Selesai via tap gesture & border highlight |
| Drag to move node | 1,5 jam | 11:55 | 11:58 | 3 menit | -87 menit | Selesai dengan matrix-inversion canvas |
| Delete node | 0,5 jam | 11:58 | 12:00 | 2 menit | -28 menit | Selesai via keyboard Del & toolbar |
| Edge routing dasar | 2 jam | 12:00 | 12:05 | 5 menit | -115 menit | Selesai dengan CustomPaint relasi panah |
| Integration test + debug | 2 jam | 12:05 | 12:10 | 5 menit | -115 menit | Selesai via headed Chrome E2E test |
| **Total Iterasi 1b** | **~8 jam** | **11:51** | **12:10** | **19 menit** | **-7 jam 41 m** | Lulus semua pengujian integrasi visual |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 2a — Property Editor & Form Validation
═══════════════════════════════════════════════════════════════════

| Komponen | Estimasi | Waktu Mulai | Waktu Selesai | Realisasi | Deviasi | Catatan |
|----------|----------|-------------|---------------|-----------|---------|---------|
| Rencana & state mutation | 1,5 jam | 16:55 | 17:00 | 5 menit | -85 menit | Selesai |
| Rombak UI list & dropdown | 2 jam | 17:00 | 17:02 | 2 menit | -118 menit | Selesai |
| E2E test coding & debug | 1,5 jam | 17:02 | 17:04 | 2 menit | -88 menit | Pause kuota |
| Refaktor input & Key | 0,5 jam | 08:33 | 08:35 | 2 menit | -28 menit | Selesai |
| headed E2E test run | 0,5 jam | 08:35 | 08:38 | 3 menit | -27 menit | All passed |
| Dokumen & Walkthrough | 0,5 jam | 08:38 | 08:42 | 4 menit | -26 menit | Selesai |
| **Total Iterasi 2a** | **~6,5 jam** | **16:55** | **08:42** | **18 menit** | **-6 jam 12 m** | Selesai sangat cepat karena reuse state |

---

## ═══════════════════════════════════════════════════════════════════
## ITERASI 2b–7 — [Template]
## ═══════════════════════════════════════════════════════════════════

*[Blok-blok ini akan diisi pada iterasi yang sesuai]*

---

## Rekap Keseluruhan

| Iterasi | Estimasi | Realisasi | Deviasi | Akurasi |
|---------|----------|-----------|---------|---------|
| 1a | ~7,5 jam | 2 jam 11 m | -5 jam 19 m | 29.1% |
| 1b | ~8 jam | 19 menit | -7 jam 41 m | 4.0% |
| 2a | ~6,5 jam | 18 menit | -6 jam 12 m | 4.6% |
| 2b | ~6 jam | — | — | — |
| 3a | ~7 jam | — | — | — |
| 3b | ~6,5 jam | — | — | — |
| 4a | ~7 jam | — | — | — |
| 4b | ~5,5 jam | — | — | — |
| 5a | ~5 jam | — | — | — |
| 5b | ~6 jam | — | — | — |
| 6a | ~7 jam | — | — | — |
| 6b | ~6,5 jam | — | — | — |
| 7 | ~8 jam | — | — | — |
| **Total** | **~87 jam** | **2 jam 48 m** | **-19 jam 12 m** | **12.7%** |

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: 2026-07-07*
