# ⏱️ Estimasi vs Realisasi Waktu — FDM Visual Designer
## Format: Kumulatif per Iterasi | Spesifikasi: Revisi 3 Final

> File ini membandingkan estimasi waktu dari spesifikasi dengan waktu aktual pengerjaan.
> Skema pencatatan disempurnakan dengan 5 kategori waktu eksplisit untuk iterasi prospektif.

---

### Standar Konsep Waktu Pengembangan (Prospektif)

Mulai Iterasi 3b, waktu pengembangan dicatat dalam 5 kategori berikut:
1. **Elapsed Time (ET)**: Waktu kalender sejak aktivitas dimulai sampai aktivitas selesai.
2. **Active Agent Execution Time (AAET)**: Waktu yang digunakan agen untuk analisis, implementasi, pengujian, atau tindakan teknis secara aktif.
3. **Human Interaction Time (HIT)**: Waktu yang digunakan Intent Architect (IA) untuk meninjau hasil, uji coba, koreksi, dan mengambil keputusan.
4. **Recovery Time (RT)**: Waktu untuk deteksi, analisis, dan perbaikan error atau context drift.
5. **Documentation and Governance Time (DGT)**: Waktu untuk sinkronisasi RTM, decision log, validation log, dan log governance lainnya.

### Metrik Evaluasi Waktu

* **Actual-to-Estimate Ratio (AER)**:
  $$\text{AER} = \frac{\text{Actual Time}}{\text{Estimated Time}}$$
* **Estimation Error Rate (EER)**:
  $$\text{EER} = \frac{|\text{Estimated Time} - \text{Actual Time}|}{\text{Estimated Time}}$$

---


═══════════════════════════════════════════════════════════════════
## ITERASI 1a — Fondasi Canvas & Two-Node Architecture with Query Vector
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
| **Total Iterasi 1a** | **~7,5 jam** | **11:10** | **13:21** | **2 jam 11 m** | **-5 jam 19 m** | Selesai lebih cepat |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1b — Node Interaction
═══════════════════════════════════════════════════════════════════

| Komponen | Estimasi | Waktu Mulai | Waktu Selesai | Realisasi | Deviasi | Catatan |
|----------|----------|-------------|---------------|-----------|---------|---------|
| Add node (tap to add) | 1 jam | 11:51 | 11:53 | 2 menit | -58 menit | Selesai |
| Select node + highlight | 1 jam | 11:53 | 11:55 | 2 menit | -58 menit | Selesai |
| Drag to move node | 1,5 jam | 11:55 | 11:58 | 3 menit | -87 menit | Selesai |
| Delete node | 0,5 jam | 11:58 | 12:00 | 2 menit | -28 menit | Selesai |
| Edge routing dasar | 2 jam | 12:00 | 12:05 | 5 menit | -115 menit | Selesai |
| Integration test + debug | 2 jam | 12:05 | 12:10 | 5 menit | -115 menit | Selesai |
| **Total Iterasi 1b** | **~8 jam** | **11:51** | **12:10** | **19 menit** | **-7 jam 41 m** | Selesai |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 2a — Property Editor & Form Validation
═══════════════════════════════════════════════════════════════════

| Komponen | Estimasi | Waktu Mulai | Waktu Selesai | Realisasi | Deviasi | Catatan |
|----------|----------|-------------|---------------|-----------|---------|---------|
| Rencana & state mutation | 1,5 jam | 16:55 | 17:00 | 5 menit | -85 menit | Selesai |
| Rombak UI list & dropdown | 2 jam | 17:00 | 17:02 | 2 menit | -118 menit | Selesai |
| E2E test coding & debug | 1,5 jam | 17:02 | 17:04 | 2 menit | -88 menit | Selesai |
| Refaktor input & Key | 0,5 jam | 08:33 | 08:35 | 2 menit | -28 menit | Selesai |
| headed E2E test run | 0,5 jam | 08:35 | 08:38 | 3 menit | -27 menit | Selesai |
| Dokumen & Walkthrough | 0,5 jam | 08:38 | 08:42 | 4 menit | -26 menit | Selesai |
| Perbaikan hit-test SnackBar | 0,5 jam | 08:45 | 09:05 | 20 menit | -10 menit | Selesai |
| **Total Iterasi 2a** | **~6,5 jam** | **16:55** | **09:05** | **38 menit** | **-5 jam 52 m** | Selesai |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 2b — Query Vector & Tipe Data Detail
═══════════════════════════════════════════════════════════════════

| Komponen | Estimasi | Waktu Mulai | Waktu Selesai | Realisasi | Deviasi | Catatan |
|----------|----------|-------------|---------------|-----------|---------|---------|
| Tipe data terkapitalisasi & Enter | 1,5 jam | 16:15 | 16:21 | 6 menit | -84 menit | Selesai |
| Konektor handle terpilih | 1 jam | 16:21 | 16:24 | 3 menit | -57 menit | Selesai |
| Form Query Vector di sidebar | 1,5 jam | 16:24 | 16:27 | 3 menit | -87 menit | Selesai |
| Rendering badge Query Vector canvas | 1 jam | 16:27 | 16:30 | 3 menit | -57 menit | Selesai |
| Pengujian visual ChromeDriver | 0,5 jam | 16:30 | 16:35 | 5 menit | -25 menit | Selesai |
| Revisi visual Structural Node | 0,5 jam | 16:35 | 16:41 | 6 menit | -24 menit | Selesai |
| Verbatim Log & sinkronisasi Git | 0,5 jam | 16:41 | 17:05 | 24 menit | -6 menit | Selesai |
| **Total Iterasi 2b** | **~6 jam** | **16:15** | **17:05** | **50 menit** | **-5 jam 10 m** | Selesai |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 3a — Edge System: Referencing & Denormalization
═══════════════════════════════════════════════════════════════════

| Komponen | Estimasi | Waktu Mulai | Waktu Selesai | Realisasi | Deviasi | Catatan |
|----------|----------|-------------|---------------|-----------|---------|---------|
| Audit deskripsi RTM | 2 jam | 11:18 | 11:21 | 3 menit | -117 menit | Selesai |
| Pengujian visual ChromeDriver | 3 jam | 11:21 | 11:25 | 4 menit | -176 menit | Selesai |
| Sinkronisasi berkas log IIDD | 2 jam | 11:25 | 11:30 | 5 menit | -115 menit | Selesai |
| Investigasi riwayat E2E & chrome issue (Sesi 13) | 1,5 jam | 09:05 | 09:25 | 20 menit | -70 menit | Selesai |
| Koreksi Scheduled Task E2E & test run (Sesi 14) | 1,5 jam | 09:25 | 09:49 | 24 menit | -66 menit | Selesai |
| **Total Iterasi 3a** | **~7 jam** | **11:18** | **09:49** | **56 menit** | **-6 jam 4 m** | Selesai |

---

## Rekap Keseluruhan

| Iterasi | Estimasi | Realisasi | Deviasi | AER | EER |
|---------|----------|-----------|---------|-----|-----|
| 1a | ~7,5 jam | 2 jam 11 m | -5 jam 19 m | 29.1% | 70.9% |
| 1b | ~8 jam | 19 menit | -7 jam 41 m | 4.0% | 96.0% |
| 2a | ~6,5 jam | 38 menit | -5 jam 52 m | 9.7% | 90.3% |
| 2b | ~6 jam | 50 menit | -5 jam 10 m | 13.9% | 86.1% |
| 3a | ~7 jam | 56 menit | -6 jam 4 m | 13.3% | 86.7% |
| 3b | ~6,5 jam | — | — | — | — |
| 4a | ~7 jam | — | — | — | — |
| 4b | ~5,5 jam | — | — | — | — |
| 5a | ~5 jam | — | — | — | — |
| 5b | ~6 jam | — | — | — | — |
| 6a | ~7 jam | — | — | — | — |
| 6b | ~6,5 jam | — | — | — | — |
| **Total (Iterasi Selesai)** | **~35 jam** | **4 jam 54 m** | **-30 jam 6 m** | **14.0%** | **86.0%** |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 3b s.d. 6b — Template Log Waktu (Skema 5 Kategori)
═══════════════════════════════════════════════════════════════════

| Komponen / Aktivitas | Estimasi | Waktu Mulai | Waktu Selesai | ET | AAET | HIT | RT | DGT | Deviasi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|
| [Aktivitas] | | | | | | | | | | |
| **Total Iterasi** | | | | | | | | | | |

*Keterangan Kolom:*
* **ET**: Elapsed Time (Waktu Kalender)
* **AAET**: Active Agent Execution Time
* **HIT**: Human Interaction Time
* **RT**: Recovery Time
* **DGT**: Documentation & Governance Time

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: 2026-07-11*
