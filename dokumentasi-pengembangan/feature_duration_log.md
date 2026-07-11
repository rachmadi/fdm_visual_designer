# ⏲️ Durasi Per Fitur — FDM Visual Designer
## Format: Kumulatif per Iterasi | Spesifikasi: Revisi 3 Final

> File ini mencatat durasi aktual pengerjaan setiap fitur secara granular.
> Berguna untuk analisis bottleneck dan GOR (Governance Overhead Ratio).

---

### Kode Kategori Governance (GOV)

Mulai Iterasi 3b, aktivitas yang berhubungan dengan tata kelola proyek (governance) diberi kode khusus:
- `GOV-RTM`: Sinkronisasi/update matriks keterlacakan requirement (RTM).
- `GOV-DECISION`: Update log keputusan desain/teknis.
- `GOV-DRIFT`: Update log penyimpangan dan proposal agen.
- `GOV-VALIDATION`: Update log verifikasi/validasi hasil test.
- `GOV-INTEGRITY`: Eksekusi Cross-Artifact Integrity Check.
- `GOV-CONVERSATION`: Update log kronologi percakapan.
- `GOV-SYNC`: Sinkronisasi akhir seluruh berkas log IIDD & Git.

### Metrik Tata Kelola

* **Governance Overhead Ratio (GOR)**:
  $$\text{GOR} = \frac{\text{Governance Time}}{\text{Total Development Time}}$$

---

## Cara Mengisi

Catat waktu mulai, selesai, dan kategori setiap fitur/komponen saat dikerjakan.
Kalkulasi durasi dan GOR secara otomatis di akhir iterasi.

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1a — Fondasi Canvas & Two-Node Architecture with Query Vector
═══════════════════════════════════════════════════════════════════

| # | Fitur / Komponen | File Utama | Mulai | Selesai | Durasi | Kesulitan | Catatan |
|---|-----------------|-----------|-------|---------|--------|-----------|---------|
| 1 | Setup project & dependencies | `pubspec.yaml` | 11:10 (June 27) | 11:40 (June 27) | 30m | Rendah | Selesai |
| 2 | `TransformationController` setup | `canvas_view.dart` | 10:29 (July 6) | 10:34 (July 6) | 5m | Sedang | Selesai |
| 3 | `InteractiveViewer` wrapper | `canvas_view.dart` | 10:34 (July 6) | 10:36 (July 6) | 2m | Rendah | Selesai |
| 4 | Inversi matriks koordinat screen→canvas | `canvas_view.dart` | 11:12 (July 6) | 11:14 (July 6) | 2m | Tinggi | Kritis |
| 5 | Metamodel `StorageNode` | `metamodel.dart` | 11:40 (June 27) | 11:50 (June 27) | 10m | Rendah | Selesai |
| 6 | Metamodel `EntityNode` | `metamodel.dart` | 11:50 (June 27) | 12:00 (June 27) | 10m | Rendah | Selesai |
| 7 | Metamodel Query Vector | `metamodel.dart` | 12:00 (June 27) | 12:08 (June 27) | 8m | Rendah | Selesai |
| 8 | `StorageNodePainter` | `structural_node.dart` | 12:08 (June 27) | 12:18 (June 27) | 10m | Sedang | Selesai |
| 9 | `EntityNodePainter` | `entity_node.dart` | 12:18 (June 27) | 12:28 (June 27) | 10m | Sedang | Selesai |
| 10 | `QueryVectorPainter (Badge visual pada EntityNode)` | `entity_node.dart` | 12:28 (June 27) | 12:37 (June 27) | 9m | Sedang | Selesai |
| 11 | Riverpod `DiagramNotifier` | `state.dart` | 12:37 (June 27) | 13:13 (June 27) | 36m | Sedang | Selesai |
| 12 | Unit test fondasi | `test/foundation_test.dart` | 13:13 (June 27) | 13:21 (June 27) | 8m | Rendah | Selesai |
| 13 | Integration test headed 1a | `integration_test/app_test.dart` | 11:25 (July 6) | 11:51 (July 6) | 26m | Sedang | Selesai |
| — | **TOTAL ITERASI 1a** | — | — | — | **~3,0 jam** | — | — |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1b — Node Interaction
═══════════════════════════════════════════════════════════════════

| # | Fitur / Komponen | File Utama | Mulai | Selesai | Durasi | Kesulitan | Catatan |
|---|-----------------|-----------|-------|---------|--------|-----------|---------|
| 1 | Tap to add node | `sidebar_left.dart` | 11:51 (July 6) | 11:53 (July 6) | 2m | Sedang | Selesai |
| 2 | Tap to select + highlight | `canvas_view.dart` | 11:53 (July 6) | 11:55 (July 6) | 2m | Sedang | Selesai |
| 3 | Drag to move node | `canvas_view.dart` | 11:55 (July 6) | 11:58 (July 6) | 3m | Tinggi | Selesai |
| 4 | Delete selected node | `canvas_view.dart` | 11:58 (July 6) | 12:00 (July 6) | 2m | Rendah | Selesai |
| 5 | Edge routing (garis lurus) | `edges_painter.dart` | 12:00 (July 6) | 12:05 (July 6) | 5m | Sedang | Selesai |
| 6 | Integration test headed 1b | `integration_test/app_test.dart` | 12:05 (July 6) | 12:10 (July 6) | 5m | Sedang | Selesai |
| — | **TOTAL ITERASI 1b** | — | — | — | **~0,6 jam** | — | — |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 2a — Property Editor & Form Validation
═══════════════════════════════════════════════════════════════════

| # | Fitur / Komponen | File Utama | Mulai | Selesai | Durasi | Kesulitan | Catatan |
|---|-----------------|-----------|-------|---------|--------|-----------|---------|
| 1 | reorderProperties & insertPropertyAt | `state.dart` | 16:55 (July 6) | 17:00 (July 6) | 5m | Sedang | State mutations |
| 2 | ReorderableListView properti | `sidebar_right.dart` | 17:00 (July 6) | 17:02 (July 6) | 2m | Sedang | UI layout |
| 3 | E2E integration test Stage 4 | `app_test.dart` | 17:02 (July 6) | 17:04 (July 6) | 2m | Sedang | E2E setup |
| 4 | Fix empty textfield & unique Keys | `sidebar_right.dart` | 08:33 (July 7) | 08:35 (July 7) | 2m | Tinggi | Bug fix |
| 5 | Visual headed E2E test run | `app_test.dart` | 08:35 (July 7) | 08:38 (July 7) | 3m | Sedang | All passed |
| 6 | Dokumen & Walkthrough | — | 08:38 (July 7) | 08:42 (July 7) | 4m | Rendah | Selesai |
| 7 | Fix hit-test SnackBar Undo (Sesi 9) | `app_test.dart` | 08:45 (July 7) | 09:05 (July 7) | 20m | Tinggi | bypass hit-test menggunakan onPressed langsung |
| — | **TOTAL ITERASI 2a** | — | — | — | **38m** | — | — |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 2b — Query Vector & Tipe Data Detail
═══════════════════════════════════════════════════════════════════

| # | Fitur / Komponen | File Utama | Mulai | Selesai | Durasi | Kesulitan | Catatan |
|---|-----------------|-----------|-------|---------|--------|-----------|---------|
| 1 | Dropdown tipe data terkapitalisasi & onSubmitted (Enter) | `sidebar_right.dart` | 16:15 (July 7) | 16:21 (July 7) | 6m | Sedang | UI / Keystrokes |
| 2 | Sembunyikan handle konektor saat node tidak terpilih | `structural_node.dart`, `entity_node.dart` | 16:21 (July 7) | 16:24 (July 7) | 3m | Sedang | Kondisi rendering |
| 3 | Panel konfigurasi Query Vector (Filter & Sort) | `sidebar_right.dart` | 16:24 (July 7) | 16:27 (July 7) | 3m | Tinggi | Integrasi Riverpod |
| 4 | Render panel/badge visual Query Vector di canvas | `entity_node.dart`, `canvas_view.dart` | 16:27 (July 7) | 16:30 (July 7) | 3m | Sedang | CustomPaint & layout |
| 5 | Pengujian E2E & visual headed ChromeDriver | `app_test.dart` | 16:30 (July 7) | 16:35 (July 7) | 5m | Tinggi | Headed Scheduled Task |
| 6 | Revisi FolderPainter Structural Node (rounded + pemisah) | `structural_node.dart` | 16:35 (July 7) | 16:41 (July 7) | 6m | Sedang | CustomPainter path |
| 7 | Verbatim Log formal & sinkronisasi commit log | `commit_history.md`, `catatan_percakapan_verbatim.md` | 16:41 (July 7) | 17:05 (July 7) | 24m | Sedang | Dokumentasi otomatis |
| — | **TOTAL ITERASI 2b** | — | — | — | **50m** | — | — |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 3a — Edge System: Referencing & Denormalization
═══════════════════════════════════════════════════════════════════

| # | Fitur / Komponen | File Utama | Mulai | Selesai | Durasi | Kesulitan | Catatan |
|---|-----------------|-----------|-------|---------|--------|-----------|---------|
| 1 | Audit deskripsi RTM & crosscheck spesifikasi | `requirement_traceability_matrix.md` | 11:18 (July 8) | 11:21 (July 8) | 3m | Rendah | Selesai |
| 2 | Pengujian visual E2E ChromeDriver & scheduled task | `app_test.dart` | 11:21 (July 8) | 11:25 (July 8) | 4m | Sedang | Selesai |
| 3 | Sinkronisasi berkas log IIDD | — | 11:25 (July 8) | 11:30 (July 8) | 5m | Rendah | Selesai |
| 4 | Investigasi riwayat E2E & chrome issue (Sesi 13) | `headed_test.log` | 09:05 (July 9) | 09:25 (July 9) | 20m | Tinggi | Investigasi Session 0 vs Session 1 |
| 5 | Koreksi Scheduled Task E2E & test run (Sesi 14) | `run_headed_test.ps1` | 09:25 (July 9) | 09:49 (July 9) | 24m | Sedang | Lolos 100% (All tests passed!) |
| — | **TOTAL ITERASI 3a** | — | — | — | **56m** | — | — |

---

## ═══════════════════════════════════════════════════════════════════
## ITERASI 3b s.d. 6b — Template Log Durasi (Prospektif Skema Baru)
## ═══════════════════════════════════════════════════════════════════

| # | Fitur / Komponen | Kategori/Code | File Utama | Mulai | Selesai | Durasi | Kesulitan | Catatan |
|---|-----------------|---------------|------------|-------|---------|--------|-----------|---------|
| 1 | [Contoh Fitur] | GOV-RTM | — | 10:00 | 10:10 | 10m | Rendah | Contoh |
| — | **TOTAL ITERASI** | — | — | — | — | **0m** | — | — |
| — | **Total Governance** | — | — | — | — | **0m** | — | **GOR: 0%** |

---

## Analisis Fitur Paling Time-Consuming

| Rank | Fitur | Durasi | Iterasi | Catatan |
|------|-------|--------|---------|---------|
| 1 | Penanganan Multi-touch Zoom & Bounded Viewport | ~2.5 jam | 1a | Menyelesaikan bug pergeseran liar koordinat saat gesture cubit |
| 2 | Inversi Matriks Koordinat Screen-to-Canvas | ~1.5 jam | 1a | Formulasi matematis konversi posisi tap agar bebas drift |
| 3 | Pintasan Keyboard Global & Intersepsi Browser | ~1.5 jam | 2b | Mencegah default action browser agar pintasan web berfungsi stabil |

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: 2026-07-11*
