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
## ITERASI 1b — Node Interaction
### Status Pengujian: 🕒 Menunggu 1b
═══════════════════════════════════════════════════════════════════

*[Blok ini akan diisi saat Iterasi 1b selesai]*

---

═══════════════════════════════════════════════════════════════════
## ITERASI 2a–7 — [Template]
═══════════════════════════════════════════════════════════════════

*[Blok-blok ini akan diisi pada iterasi yang sesuai]*

---

## Rekap Status Pengujian Semua Iterasi

| Iterasi | Tanggal Test | Total TC | ✅ Lulus | ❌ Gagal | Status |
|---------|-------------|----------|---------|---------|--------|
| 1a | 2026-07-06 | 8 | 8 | 0 | ✅ Lulus |
| 1b | — | — | 0 | 0 | 🕒 Belum |
| 2a | — | — | 0 | 0 | 🕒 Belum |
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
