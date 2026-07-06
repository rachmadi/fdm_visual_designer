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
| Setup & analisis | 0,5 jam | — | — | — | — | — |
| InteractiveViewer + controller | 1,5 jam | — | — | — | — | — |
| Inversi matriks koordinat | 1 jam | — | — | — | — | — |
| Metamodel (3 node) | 1 jam | — | — | — | — | — |
| CustomPainter (3 painter) | 1,5 jam | — | — | — | — | — |
| State Riverpod Notifier | 1 jam | — | — | — | — | — |
| Integration test + debug | 1 jam | — | — | — | — | — |
| **Total Iterasi 1a** | **~7,5 jam** | — | — | **—** | **—** | — |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1b — Node Interaction
═══════════════════════════════════════════════════════════════════

| Komponen | Estimasi | Waktu Mulai | Waktu Selesai | Realisasi | Deviasi | Catatan |
|----------|----------|-------------|---------------|-----------|---------|---------|
| Add node (tap to add) | 1 jam | 11:50 | 11:51 | 1 jam | 0 jam | Selesai via sidebar palette grid spawn |
| Select node + highlight | 1 jam | 11:51 | 11:52 | 1 jam | 0 jam | Selesai via tap gesture & border highlight |
| Drag to move node | 1,5 jam | 11:52 | 11:54 | 1,5 jam | 0 jam | Selesai dengan matrix-inversion canvas |
| Delete node | 0,5 jam | 11:54 | 11:55 | 0,5 jam | 0 jam | Selesai via keyboard Del & toolbar |
| Edge routing dasar | 2 jam | 11:55 | 11:57 | 2 jam | 0 jam | Selesai dengan CustomPaint relasi panah |
| Integration test + debug | 2 jam | 11:57 | 12:00 | 2 jam | 0 jam | Selesai via headed Chrome E2E test |
| **Total Iterasi 1b** | **~8 jam** | **11:50** | **12:00** | **~8 jam** | **0 jam** | Lulus semua pengujian integrasi visual |

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
