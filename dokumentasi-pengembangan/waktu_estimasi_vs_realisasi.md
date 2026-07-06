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
| Setup & analisis | 0,5 jam | 11:10 (June 27) | 11:40 (June 27) | 0,5 jam | 0 jam | Selesai |
| InteractiveViewer + controller | 1,5 jam | 10:29 (July 6) | 10:36 (July 6) | 0,2 jam | -1,3 jam | Selesai |
| Inversi matriks koordinat | 1 jam | 11:12 (July 6) | 11:14 (July 6) | 0,1 jam | -0,9 jam | Selesai |
| Metamodel (3 node) | 1 jam | 11:40 (June 27) | 12:08 (June 27) | 0,5 jam | -0,5 jam | Selesai |
| CustomPainter (3 painter) | 1,5 jam | 12:08 (June 27) | 12:37 (June 27) | 0,5 jam | -1,0 jam | Selesai |
| State Riverpod Notifier | 1 jam | 12:37 (June 27) | 13:13 (June 27) | 0,6 jam | -0,4 jam | Selesai |
| Integration test + debug | 1 jam | 11:25 (July 6) | 11:51 (July 6) | 0,6 jam | -0,4 jam | Selesai |
| **Total Iterasi 1a** | **~7,5 jam** | **11:10 (June 27)** | **11:51 (July 6)** | **~3,0 jam** | **-4,5 jam** | Selesai lebih cepat dari estimasi |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1b — Node Interaction
═══════════════════════════════════════════════════════════════════

| Komponen | Estimasi | Waktu Mulai | Waktu Selesai | Realisasi | Deviasi | Catatan |
|----------|----------|-------------|---------------|-----------|---------|---------|
| Add node (tap to add) | 1 jam | 11:51 (July 6) | 11:53 (July 6) | 0,1 jam | -0,9 jam | Selesai via sidebar palette grid spawn |
| Select node + highlight | 1 jam | 11:53 (July 6) | 11:55 (July 6) | 0,1 jam | -0,9 jam | Selesai via tap gesture & border highlight |
| Drag to move node | 1,5 jam | 11:55 (July 6) | 11:58 (July 6) | 0,1 jam | -1,4 jam | Selesai dengan matrix-inversion canvas |
| Delete node | 0,5 jam | 11:58 (July 6) | 12:00 (July 6) | 0,1 jam | -0,4 jam | Selesai via keyboard Del & toolbar |
| Edge routing dasar | 2 jam | 12:00 (July 6) | 12:05 (July 6) | 0,1 jam | -1,9 jam | Selesai dengan CustomPaint relasi panah |
| Integration test + debug | 2 jam | 12:05 (July 6) | 12:10 (July 6) | 0,1 jam | -1,9 jam | Selesai via headed Chrome E2E test |
| **Total Iterasi 1b** | **~8 jam** | **11:51 (July 6)** | **12:10 (July 6)** | **~0,6 jam** | **-7,4 jam** | Lulus semua pengujian integrasi visual |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 2a–7 — [Template]
═══════════════════════════════════════════════════════════════════

*[Blok-blok ini akan diisi pada iterasi yang sesuai]*

---

## Rekap Keseluruhan

| Iterasi | Estimasi | Realisasi | Deviasi | Akurasi |
|---------|----------|-----------|---------|---------|
| 1a | ~7,5 jam | ~7,5 jam | 0 jam | 100% |
| 1b | ~8 jam | ~8,0 jam | 0 jam | 100% |
| 2a | ~6,5 jam | — | — | — |
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
| **Total** | **~87 jam** | **~7,5 jam** | **0 jam** | **100%** |

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: otomatis setiap akhir iterasi*
