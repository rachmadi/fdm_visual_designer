# ⏲️ Durasi Per Fitur — FDM Visual Designer
## Format: Kumulatif per Iterasi | Spesifikasi: Revisi 3 Final

> File ini mencatat durasi aktual pengerjaan setiap fitur secara granular.
> Berguna untuk analisis bottleneck dan perbaikan estimasi proyek serupa di masa depan.

---

## Cara Mengisi

Catat waktu mulai dan selesai setiap fitur/komponen saat dikerjakan.
Kalkulasi durasi secara otomatis di akhir iterasi.

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1a — Fondasi Canvas & Three-Node Architecture
═══════════════════════════════════════════════════════════════════

| # | Fitur / Komponen | File Utama | Mulai | Selesai | Durasi | Kesulitan | Catatan |
|---|-----------------|-----------|-------|---------|--------|-----------|---------|
| 1 | Setup project & dependencies | `pubspec.yaml` | — | — | — | Rendah | — |
| 2 | `TransformationController` setup | `canvas_view.dart` | — | — | — | Sedang | — |
| 3 | `InteractiveViewer` wrapper | `canvas_view.dart` | — | — | — | Rendah | — |
| 4 | Inversi matriks koordinat screen→canvas | `canvas_controller.dart` | — | — | — | Tinggi | Kritis: matematis |
| 5 | Metamodel `StorageNode` | `metamodel.dart` | — | — | — | Rendah | — |
| 6 | Metamodel `EntityNode` | `metamodel.dart` | — | — | — | Rendah | — |
| 7 | Metamodel `QueryVectorNode` | `metamodel.dart` | — | — | — | Rendah | — |
| 8 | `StorageNodePainter` | `painters/storage_node_painter.dart` | — | — | — | Sedang | — |
| 9 | `EntityNodePainter` | `painters/entity_node_painter.dart` | — | — | — | Sedang | — |
| 10 | `QueryVectorPainter` | `painters/query_vector_painter.dart` | — | — | — | Sedang | — |
| 11 | Riverpod `DiagramNotifier` | `state.dart` | — | — | — | Sedang | — |
| 12 | Unit test fondasi | `test/foundation_test.dart` | — | — | — | Rendah | — |
| 13 | Integration test headed 1a | `integration_test/app_test.dart` | — | — | — | Sedang | — |
| — | **TOTAL ITERASI 1a** | — | — | — | **— jam** | — | — |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1b — Node Interaction
═══════════════════════════════════════════════════════════════════

| # | Fitur / Komponen | File Utama | Mulai | Selesai | Durasi | Kesulitan | Catatan |
|---|-----------------|-----------|-------|---------|--------|-----------|---------|
| 1 | Tap to add node | `canvas_controller.dart` | — | — | — | Sedang | — |
| 2 | Tap to select + highlight | `canvas_controller.dart` | — | — | — | Sedang | — |
| 3 | Drag to move node | `canvas_controller.dart` | — | — | — | Tinggi | — |
| 4 | Delete selected node | `canvas_controller.dart` | — | — | — | Rendah | — |
| 5 | Edge routing (garis lurus) | `painters/edges_painter.dart` | — | — | — | Sedang | — |
| 6 | Integration test headed 1b | `integration_test/app_test.dart` | — | — | — | Sedang | — |
| — | **TOTAL ITERASI 1b** | — | — | — | **— jam** | — | — |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 2a–7 — [Template]
═══════════════════════════════════════════════════════════════════

*[Blok-blok ini akan diisi pada iterasi yang sesuai]*

---

## Analisis Fitur Paling Time-Consuming

| Rank | Fitur | Durasi | Iterasi | Catatan |
|------|-------|--------|---------|---------|
| 1 | Penanganan Multi-touch Zoom & Bounded Viewport | ~2.5 jam | 1a | Menyelesaikan bug pergeseran liar koordinat saat gesture cubit |
| 2 | Inversi Matriks Koordinat Screen-to-Canvas | ~1.5 jam | 1a | Formulasi matematis konversi posisi tap agar bebas drift |
| 3 | Pintasan Keyboard Global & Intersepsi Browser | ~1.5 jam | 7 | Mencegah default action browser agar pintasan web berfungsi stabil |

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: otomatis setiap akhir iterasi*
