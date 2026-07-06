# 📋 Estimasi Waktu Pengerjaan — FDM Visual Designer
## Berdasarkan: Spesifikasi Revisi 3 Final

> Dokumen ini merangkum estimasi waktu per iterasi berdasarkan spesifikasi proyek FDM Visual Designer (Revisi 3 Final).
> Estimasi disesuaikan dengan kompleksitas fitur, jumlah widget, dan cakupan pengujian integrasi.

---

## Tabel Estimasi Waktu Per Iterasi

| No | Iterasi | Fokus Utama | Estimasi Waktu | Catatan |
|----|---------|-------------|----------------|---------|
| 1 | **Iterasi 1a** | Fondasi Canvas & Three-Node Architecture (InteractiveViewer, CustomPainter, Metamodel Dasar) | ~7,5 jam | Fondasi paling kritis — meliputi setup InteractiveViewer + matriks inversi |
| 2 | **Iterasi 1b** | Node Interaction: Add, Select, Move, Delete; Edge Routing Dasar | ~8 jam | Termasuk gesture detection & state management Riverpod |
| 3 | **Iterasi 2a** | Property Panel: Entity Node & Storage Node; Dynamic Property CRUD | ~6,5 jam | Form validation & bidirectional data binding |
| 4 | **Iterasi 2b** | Property Panel: Query Vector Node; Map/List type support | ~6 jam | Nested property editor & rendering kompleks |
| 5 | **Iterasi 3a** | Edge System: Referencing, Denormalized, Embedding edges; tipe label | ~7 jam | Rendering kurva Bezier & label floating |
| 6 | **Iterasi 3b** | Security Boundary: Draw, Resize, Node Containment, Label | ~6,5 jam | Deteksi overlap & containment logic |
| 7 | **Iterasi 4a** | WFR Validator Engine: 8 aturan semantik (R1–R8); Overlay pesan error | ~7 jam | Algoritma validasi graf & rendering overlay |
| 8 | **Iterasi 4b** | Toolbar: Export PNG/SVG, Import/Export JSON, Zoom Controls | ~5,5 jam | File I/O & rendering resolusi tinggi |
| 9 | **Iterasi 5a** | Visual Feedback: Highlight, Hover, Selection State; Animasi transisi | ~5 jam | Micro-animation & state visual feedback |
| 10 | **Iterasi 5b** | Sidebar Kiri: Palette Node; Sidebar Kanan: Detail Panel; Layout responsif | ~6 jam | Layout adaptif & drag-drop dari palette |
| 11 | **Iterasi 6a** | Undo/Redo Stack; Command Pattern; History Panel | ~7 jam | Command stack & memento pattern |
| 12 | **Iterasi 6b** | Multi-select; Group Move; Alignment Tools; Grid Snap | ~6,5 jam | Algoritma alignment & snapping |
| 13 | **Iterasi 7** | Pengujian Integrasi Final, Polishing UI, Dokumentasi Akhir | ~8 jam | Full integration test + dokumentasi teknis lengkap |

---

## Ringkasan Total Estimasi

| Kategori | Total Estimasi |
|----------|----------------|
| **Total Estimasi Keseluruhan** | **~87 jam** |
| Fase Fondasi (Iterasi 1a–1b) | ~15,5 jam |
| Fase Core Features (Iterasi 2a–4b) | ~38,5 jam |
| Fase Polish & Advanced (Iterasi 5a–6b) | ~24,5 jam |
| Fase Finalisasi (Iterasi 7) | ~8 jam |

---

## Catatan Metodologi Estimasi

- Estimasi waktu mencakup: analisis, implementasi, debugging, pengujian unit, dan pengujian integrasi headed.
- Setiap iterasi wajib lulus **headed (non-headless) integration test** sebelum dinyatakan selesai.
- Waktu aktual dicatat di `waktu_estimasi_vs_realisasi.md` dan `durasi_per_fitur.md`.
- Buffer tambahan (~20%) tidak termasuk dalam estimasi di atas untuk menjaga estimasi tetap optimistis.

---

*Dokumen ini dibuat: 2026-07-06 | Spesifikasi: Revisi 3 Final*
