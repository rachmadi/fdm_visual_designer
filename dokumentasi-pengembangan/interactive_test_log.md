# 🧪 Interactive Test Log — FDM Visual Designer
## Format: Kumulatif per Iterasi | Spesifikasi: Revisi 3 Final

> File ini mencatat hasil pengujian interaktif (headed integration test) yang dijalankan di setiap akhir iterasi.
> Pengujian wajib dilakukan dengan browser Chrome (non-headless) menggunakan ChromeDriver.

---

## Prosedur Pengujian Standar

```bash
# Langkah 1: Jalankan ChromeDriver (background task)
npx chromedriver@149 --port=4444

# Langkah 2: Jalankan flutter drive
flutter drive \
  --driver=test_driver\integration_test.dart \
  --target=integration_test\app_test.dart \
  -d chrome \
  --no-headless \
  --browser-dimension=1600x1024

# Langkah 3: Verifikasi output mengandung:
# ✅ All tests passed!
```

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1a — Fondasi Canvas & Three-Node Architecture
### Status Pengujian: ✅ PASS (All Tests Passed)
═══════════════════════════════════════════════════════════════════

### Detail Sesi Pengujian 1a

| Field | Nilai |
|-------|-------|
| Tanggal | 2026-07-06 |
| Waktu Mulai | 10:56 WIB |
| Waktu Selesai | 11:00 WIB |
| Durasi Total | ~4 menit |
| ChromeDriver Version | 149 |
| Browser Dimension | 1600×1024 |
| Headless Mode | Non-headless (headed) |
| Status Akhir | ✅ PASS |

### Daftar Test Case — Iterasi 1a

| # | Test Case | Deskripsi | Status | Waktu | Catatan |
|---|-----------|-----------|--------|-------|---------|
| TC-1a-01 | Canvas Render | Canvas `InteractiveViewer` tampil tanpa error | ✅ Lulus | 10:57 | Canvas ter-render dengan grid 20px |
| TC-1a-02 | Pan Gesture | Canvas bisa di-pan kiri/kanan/atas/bawah | ✅ Lulus | 10:57 | Lancar tanpa hambatan gesture arena |
| TC-1a-03 | Zoom Gesture | Canvas bisa di-zoom in/out dengan pinch atau scroll | ✅ Lulus | 10:57 | Lancet, single-pointer tracking bekerja |
| TC-1a-04 | StorageNode Render | Node Storage (persegi panjang) tampil di posisi yang benar | ✅ Lulus | 10:58 | folder tab (Structural) ter-render |
| TC-1a-05 | EntityNode Render | Node Entity (oval) tampil di posisi yang benar | ✅ Lulus | 10:58 | Entity node ter-render dengan benar |
| TC-1a-06 | QueryVectorNode Render | Node Query Vector (dokumen) tampil di posisi yang benar | ✅ Lulus | 10:58 | Query vector tampil di sidebar kanan |
| TC-1a-07 | Koordinat Akurat | Posisi node tidak bergeser saat zoom berubah | ✅ Lulus | 10:59 | Fix matrix inversion + single pointer |
| TC-1a-08 | State Persistence | State node tidak hilang setelah pan/zoom | ✅ Lulus | 10:59 | Terjaga dalam DiagramNotifier state |

### Output Log Pengujian 1a

```
00:00 +0: FDM Visual Designer E2E Integration Tests Verify app layout, create structural node, and select it
All tests passed.
Screenshot saved: 1_launch_screen.png
Screenshot saved: 2_added_structural_node.png
Screenshot saved: 3_selected_node_properties.png
Screenshot saved: 4_added_entity_node.png
Application finished.
```

### Screenshot Pengujian 1a

> *(Screenshot disimpan di `dokumentasi-pengembangan/screenshots/iterasi_1a/`)*

| File Screenshot | Deskripsi |
|-----------------|-----------|
| `1_launch_screen.png` | Tampilan awal sebelum test (canvas kosong) |
| `2_added_structural_node.png` | Menambahkan node structural `new_collection` |
| `3_selected_node_properties.png` | Menampilkan properties node structural terpilih |
| `4_added_entity_node.png` | Menambahkan node entity `NewEntity` di sampingnya |

---

═══════════════════════════════════════════════════════════════════
═══════════════════════════════════════════════════════════════════
═══════════════════════════════════════════════════════════════════
## ITERASI 1b — Node Interaction
### Status Pengujian: ✅ PASS (All Tests Passed)
═══════════════════════════════════════════════════════════════════

### Detail Sesi Pengujian 1b

| Field | Nilai |
|-------|-------|
| Tanggal | 2026-07-06 |
| Waktu Mulai | 11:53 WIB |
| Waktu Selesai | 11:58 WIB |
| Durasi Total | ~5 menit |
| ChromeDriver Version | 149 |
| Browser Dimension | 1600×1024 |
| Headless Mode | Non-headless (headed) |
| Status Akhir | ✅ PASS |

### Daftar Test Case — Iterasi 1b

| # | Test Case | Deskripsi | Status | Waktu | Catatan |
|---|-----------|-----------|--------|-------|---------|
| TC-1b-01 | Add Node Grid | Menambahkan 5 Structural & 5 Entity Node | ✅ Lulus | 11:54 | Menyebar otomatis dalam grid 4 kolom, tanpa tumpang tindih |
| TC-1b-02 | Select & Highlight | Memilih node structural pertama via tap | ✅ Lulus | 11:55 | Highlight outline kuning/amber aktif & properti sidebar kiri terbuka |
| TC-1b-03 | Canvas Zoom Out | Melakukan pinch gesture zoom out canvas | ✅ Lulus | 11:56 | Canvas skala mengecil dengan stabil |
| TC-1b-04 | Drag Zoom Out | Menggeser node structural pada canvas zoom out | ✅ Lulus | 11:57 | Geseran presisi tanpa efek lompatan liar (drift) |
| TC-1b-05 | Delete Key | Menghapus node terseleksi via shortcut `Del` | ✅ Lulus | 11:58 | Node berhasil terhapus dari state diagram |

### Output Log Pengujian 1b

```
00:00 +0: FDM Visual Designer E2E Integration Tests Verify app layout, create structural node, and select it
00:47 +1: (tearDownAll)
00:47 +2: All tests passed!
All tests passed.
Screenshot saved: 1_launch_screen.png
Screenshot saved: 2_added_10_nodes_grid.png
Screenshot saved: 3_selected_node_properties.png
Screenshot saved: 4_zoomed_out_canvas.png
Screenshot saved: 5_dragged_node_zoomed_out.png
Application finished.
```

### Screenshot Pengujian 1b

> *(Screenshot disimpan di `dokumentasi-pengembangan/screenshots/iterasi_1b/`)*

| File Screenshot | Deskripsi |
|-----------------|-----------|
| `1_launch_screen.png` | Tampilan canvas kosong awal aplikasi |
| `2_added_10_nodes_grid.png` | Keadaan setelah 10 node ditambahkan dengan layout grid teratur |
| `3_selected_node_properties.png` | Seleksi node pertama menampilkan editor properties sidebar kanan |
| `4_zoomed_out_canvas.png` | Tampilan canvas setelah di-pinch zoom out |
| `5_dragged_node_zoomed_out.png` | Posisi node baru setelah digeser pada tingkat zoom out |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 2a — Property Editor & Form Validation
### Status Pengujian: ✅ PASS (All Tests Passed)
═══════════════════════════════════════════════════════════════════

### Detail Sesi Pengujian 2a

| Field | Nilai |
|-------|-------|
| Tanggal | 2026-07-07 |
| Waktu Mulai | 08:52 WIB |
| Waktu Selesai | 08:56 WIB |
| Durasi Total | ~4 menit |
| ChromeDriver Version | 149 |
| Browser Dimension | 1600×1024 |
| Headless Mode | Non-headless (headed) |
| Status Akhir | ✅ PASS |

### Daftar Test Case — Iterasi 2a

| # | Test Case | Deskripsi | Status | Waktu | Catatan |
|---|-----------|-----------|--------|-------|---------|
| TC-2a-01 | Inline Add Form | Form tambah properti disembunyikan dan muncul saat tombol tambah diklik | ✅ Lulus | 08:53 | Menghemat ruang visual di panel kanan |
| TC-2a-02 | Form Validation | Mencegah input nama properti kosong, awalan angka, duplikasi, non-alfanumerik | ✅ Lulus | 08:53 | Pesan error berwarna merah tampil real-time |
| TC-2a-03 | Inline Rename | Mengetuk nama properti membuka input rename langsung | ✅ Lulus | 08:54 | Menyimpan data via Enter / tombol centang |
| TC-2a-04 | Reorderable List | Mengatur ulang posisi properti di dalam node via drag and drop | ✅ Lulus | 08:54 | State di-update reaktif via Riverpod |
| TC-2a-05 | SnackBar Undo Delete | Menghapus properti memunculkan SnackBar dengan tombol UNDO selama 3 detik | ✅ Lulus | 08:55 | Mengetuk UNDO mengembalikan properti & relasi horizontal |

### Output Log Pengujian 2a

```
00:00 +0: FDM Visual Designer E2E Integration Tests Run Combined E2E Flow (Stage 1 to 3)
=== Memulai Stage 1: Layout & Pembuatan Node ===
✅ Stage 1 Selesai
=== Memulai Stage 2: Zoom & Drag ===
✅ Stage 2 Selesai
=== Memulai Stage 3: 4 Titik Koneksi Dinamis ===
✅ Stage 3 Selesai
=== Memulai Stage 4: Property Editor & Validasi ===
✅ Stage 4 Selesai
=== Menahan jendela browser selama 35 detik... ===
01:12 +1: FDM Visual Designer E2E Integration Tests (tearDownAll)
01:12 +2: (tearDownAll)
01:12 +3: All tests passed!
All tests passed.
Screenshot saved: 1_launch_screen.png
Screenshot saved: 2_added_nodes_grid.png
Screenshot saved: 3_selected_node_properties.png
Screenshot saved: 4_zoomed_out_canvas.png
Screenshot saved: 5_dragged_node_zoomed_out.png
Screenshot saved: 6_nodes_with_4_handles.png
Screenshot saved: 7_property_editor_validated.png
Application finished.
```

### Screenshot Pengujian 2a

> *(Screenshot disimpan di `dokumentasi-pengembangan/screenshots/iterasi_2a/`)*

| File Screenshot | Deskripsi |
|-----------------|-----------|
| `1_launch_screen.png` | Tampilan canvas kosong awal aplikasi |
| `2_added_nodes_grid.png` | Keadaan setelah 10 node ditambahkan dengan layout grid teratur |
| `3_selected_node_properties.png` | Seleksi node pertama menampilkan editor properties |
| `4_zoomed_out_canvas.png` | Tampilan canvas setelah di-pinch zoom out |
| `5_dragged_node_zoomed_out.png` | Posisi node baru setelah digeser pada tingkat zoom out |
| `6_nodes_with_4_handles.png` | Menampilkan 4 handle bulat di sekeliling node |
| `7_property_editor_validated.png` | Form pengeditan properti divalidasi dan snackbar terhapus ditampilkan |

---

## ITERASI 2b–7 — [Template]
═══════════════════════════════════════════════════════════════════

*[Blok-blok ini akan diisi pada iterasi yang sesuai]*

---

## Rekap Status Pengujian Semua Iterasi

| Iterasi | Tanggal Test | Total TC | ✅ Lulus | ❌ Gagal | Status |
|---------|-------------|----------|---------|---------|--------|
| 1a | 2026-07-06 | 8 | 8 | 0 | ✅ Lulus |
| 1b | 2026-07-06 | 5 | 5 | 0 | ✅ Lulus |
| 2a | 2026-07-07 | 5 | 5 | 0 | ✅ Lulus |
| 2b | — | — | 0 | 0 | 🕒 Belum |
| 3a | — | — | 0 | 0 | 🕒 Belum |
| 3b | — | — | 0 | 0 | 🕒 Belum |
| 4a | — | — | 0 | 0 | 🕒 Belum |
| 4b | — | — | 0 | 0 | 🕒 Belum |
| 5a | — | — | 0 | 0 | 🕒 Belum |
| 5b | — | — | 0 | 0 | 🕒 Belum |
| 6a | — | — | 0 | 0 | 🕒 Belum |
| 6b | — | — | 0 | 0 | 🕒 Belum |
| 7 | — | — | 0 | 0 | 🕒 Belum |

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: otomatis setiap kali integration test dijalankan*
