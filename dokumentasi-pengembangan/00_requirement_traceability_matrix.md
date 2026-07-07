# 📊 Requirement Traceability Matrix (RTM)
## FDM Visual Designer — Spesifikasi Revisi 3 Final

> Matriks ini memetakan setiap requirement ke iterasi implementasi, status pengerjaan, dan file implementasi terkait.
> Status diperbarui di setiap akhir iterasi.

---

## Legend Status

| Simbol | Keterangan |
|--------|------------|
| 🕒 | Belum dimulai |
| 🔄 | Sedang dikerjakan |
| ✅ | Selesai & terverifikasi |
| ❌ | Ditolak / Tidak diimplementasi |
| ⚠️ | Perlu perhatian / Partial |

---

## Matriks Ketertelusuran Requirement

| No | ID Req | Deskripsi Requirement | Iterasi | Status | File Implementasi |
|----|--------|-----------------------|---------|--------|-------------------|
| 1 | REQ-001 | Canvas interaktif menggunakan `InteractiveViewer` untuk pan & zoom | 1a | ✅ Selesai | `lib/canvas/canvas_view.dart` |
| 2 | REQ-002 | Transformasi koordinat menggunakan inversi matriks (bukan listener manual) | 1a | ✅ Selesai | `lib/canvas/canvas_view.dart` |
| 3 | REQ-003 | Metamodel `StorageNode` dengan properti: id, label, type, position | 1a | ✅ Selesai | `lib/core/metamodel.dart` |
| 4 | REQ-004 | Metamodel `EntityNode` dengan properti: id, label, fields, position | 1a | ✅ Selesai | `lib/core/metamodel.dart` |
| 5 | REQ-005 | Metamodel `QueryVectorNode` dengan properti: id, label, vectors, position | 1a | ✅ Selesai | `lib/core/metamodel.dart` |
| 6 | REQ-006 | `CustomPainter` untuk rendering node Storage (persegi panjang berlabel) | 1a | ✅ Selesai | `lib/canvas/nodes/structural_node.dart` |
| 7 | REQ-007 | `CustomPainter` untuk rendering node Entity (oval/elips berlabel) | 1a | ✅ Selesai | `lib/canvas/nodes/entity_node.dart` |
| 8 | REQ-008 | `CustomPainter` untuk rendering node Query Vector (dokumen berlabel) | 1a | ✅ Selesai | `lib/canvas/nodes/entity_node.dart` |
| 9 | REQ-009 | State management menggunakan Riverpod `StateNotifier` / `Notifier` | 1a | ✅ Selesai | `lib/core/state.dart` |
| 10 | REQ-010 | Menambahkan node baru ke canvas via tap pada area kosong | 1b | ✅ Selesai | `lib/ui/sidebar_left.dart` |
| 11 | REQ-011 | Menyeleksi node dengan tap; tampilkan highlight selection | 1b | ✅ Selesai | `lib/canvas/canvas_view.dart` |
| 12 | REQ-012 | Memindahkan node dengan drag gesture | 1b | ✅ Selesai | `lib/canvas/canvas_view.dart` |
| 13 | REQ-013 | Menghapus node yang terseleksi via tombol Delete atau toolbar | 1b | ✅ Selesai | `lib/core/state.dart` |
| 14 | REQ-014 | Edge routing dasar antara dua node (garis lurus dengan arrow) | 1b | ✅ Selesai | `lib/canvas/edges_painter.dart` |
| 15 | REQ-015 | Property Panel untuk Entity Node: tambah, edit, hapus field | 2a | ✅ Selesai | `lib/panels/sidebar_right.dart` |
| 16 | REQ-016 | Property Panel untuk Storage Node: konfigurasi tipe, label, path | 2a | ✅ Selesai | `lib/panels/sidebar_right.dart` |
| 17 | REQ-017 | Validasi form properti: nama field tidak boleh kosong | 2a | ✅ Selesai | `lib/panels/sidebar_right.dart` |
| 18 | REQ-018 | Property Panel untuk Query Vector Node: edit vector queries | 2b | ✅ Selesai | `lib/panels/sidebar_right.dart` |
| 19 | REQ-019 | Dukungan tipe properti: String, Number, Boolean, Map, List, Timestamp | 2b | ✅ Selesai | `lib/core/metamodel.dart` |
| 20 | REQ-020 | Edge tipe Referencing: garis panah dengan label "ref" | 3a | ✅ Selesai | `lib/canvas/edges_painter.dart` |
| 21 | REQ-021 | Edge tipe Denormalized: garis panah putus-putus dengan label "den" | 3a | ✅ Selesai | `lib/canvas/edges_painter.dart` |
| 22 | REQ-022 | Edge tipe Embedding: garis tebal solid dengan label "emb" | 3a | ✅ Selesai | `lib/canvas/edges_painter.dart` |
| 23 | REQ-023 | Routing kurva Bézier untuk edge agar tidak saling menimpa | 3a | ✅ Selesai | `lib/canvas/edges_painter.dart` |
| 24 | REQ-024 | Security Boundary: gambar area boundary dengan klik-drag | 3b | ✅ Selesai | `lib/ui/sidebar_left.dart` |
| 25 | REQ-025 | Security Boundary: resize handle di sudut dan tepi | 3b | ✅ Selesai | `lib/canvas/nodes/security_boundary.dart` |
| 26 | REQ-026 | Security Boundary: deteksi node yang berada di dalam area | 3b | ✅ Selesai | `lib/core/state.dart` |
| 27 | REQ-027 | WFR R1: Alternasi ketat Firestore (SN → EN → SN) | 4a | ✅ Selesai | `lib/engine/validator.dart` |
| 28 | REQ-028 | WFR R2: Target referencing harus ada dan bertipe Entity Node | 4a | ✅ Selesai | `lib/engine/validator.dart` |
| 29 | REQ-029 | WFR R3: Source property key dari Denormalized harus terdefinisi | 4a | ✅ Selesai | `lib/engine/validator.dart` |
| 30 | REQ-030 | WFR R4: Dynamic path harus menggunakan prefix `$` atau kurung kurawal | 4a | ✅ Selesai | `lib/engine/validator.dart` |
| 31 | REQ-031 | WFR R5: Query Vector mereferensikan properti yang terdefinisi | 4a | ✅ Selesai | `lib/engine/validator.dart` |
| 32 | REQ-032 | WFR R6: Peringatan partial overlap pada Security Boundary | 4a | ✅ Selesai | `lib/engine/validator.dart` |
| 33 | REQ-033 | WFR R7: Peringatan fisik — tipe kompleks tak berbatas (limit 1MB) | 4a | ✅ Selesai | `lib/engine/validator.dart` |
| 34 | REQ-034 | WFR R8: Peringatan fisik — high frequency writes (>1/s) | 4a | ✅ Selesai | `lib/engine/validator.dart` |
| 35 | REQ-035 | Overlay pesan error/warning pada node yang tidak valid | 4a | ✅ Selesai | `lib/canvas/nodes/entity_node.dart` |
| 36 | REQ-036 | Ekspor diagram ke format PNG resolusi tinggi | 4b | ✅ Selesai | `lib/canvas/canvas_view.dart` |
| 37 | REQ-037 | Ekspor diagram ke format SVG | 4b | ✅ Selesai | `lib/ui/toolbar.dart` |
| 38 | REQ-038 | Ekspor/Impor diagram ke format JSON | 4b | ✅ Selesai | `lib/core/state.dart` |
| 39 | REQ-039 | Zoom controls: zoom in, zoom out, reset, fit-to-screen | 4b | ✅ Selesai | `lib/ui/toolbar.dart` |
| 40 | REQ-040 | Highlight node saat hover (warna border berubah) | 5a | ✅ Selesai | `lib/canvas/canvas_view.dart` |
| 41 | REQ-041 | Animasi transisi saat node dipilih (scale/fade) | 5a | ✅ Selesai | `lib/canvas/canvas_view.dart` |
| 42 | REQ-042 | Sidebar kiri: palette untuk drag-and-drop node ke canvas | 5b | ✅ Selesai | `lib/ui/sidebar_left.dart` |
| 43 | REQ-043 | Sidebar kanan: detail panel untuk node yang terseleksi | 5b | ✅ Selesai | `lib/panels/sidebar_right.dart` |
| 44 | REQ-044 | Undo stack: Command Pattern untuk semua aksi destructive | 6a | ✅ Selesai | `lib/core/state.dart` |
| 45 | REQ-045 | Redo stack: kembalikan aksi yang di-undo | 6a | ✅ Selesai | `lib/core/state.dart` |
| 46 | REQ-046 | Multi-select node dengan Ctrl+Click atau rubber-band selection | 6b | ✅ Selesai | `lib/core/state.dart` |
| 47 | REQ-047 | Group move: pindahkan semua node yang terseleksi sekaligus | 6b | ✅ Selesai | `lib/core/state.dart` |
| 48 | REQ-048 | Alignment tools: align left, center, right, top, middle, bottom | 6b | ✅ Selesai | `lib/ui/toolbar.dart` |
| 49 | REQ-049 | Grid snap: node terkunci ke grid saat dipindahkan | 6b | ✅ Selesai | `lib/ui/toolbar.dart` |
| 50 | REQ-050 | Headed integration test lulus untuk semua fitur sebelum rilis | 7 | ✅ Selesai | `integration_test/app_test.dart` |

---

## Ringkasan Status RTM

| Iterasi | Total REQ | ✅ Selesai | 🔄 Berjalan | 🕒 Belum |
|---------|-----------|-----------|------------|---------|
| 1a | 9 | 9 | 0 | 0 |
| 1b | 5 | 5 | 0 | 0 |
| 2a | 3 | 3 | 0 | 0 |
| 2b | 2 | 2 | 0 | 0 |
| 3a | 4 | 4 | 0 | 0 |
| 3b | 3 | 3 | 0 | 0 |
| 4a | 9 | 9 | 0 | 0 |
| 4b | 4 | 4 | 0 | 0 |
| 5a | 2 | 2 | 0 | 0 |
| 5b | 2 | 2 | 0 | 0 |
| 6a | 2 | 2 | 0 | 0 |
| 6b | 4 | 4 | 0 | 0 |
| 7 | 1 | 1 | 0 | 0 |
| **Total** | **50** | **50** | **0** | **0** |

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: 2026-07-07*
