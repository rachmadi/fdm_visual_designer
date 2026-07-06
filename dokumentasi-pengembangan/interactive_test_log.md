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
### Status Pengujian: 🕒 Belum Dijalankan
═══════════════════════════════════════════════════════════════════

### Detail Sesi Pengujian 1a

| Field | Nilai |
|-------|-------|
| Tanggal | — |
| Waktu Mulai | — |
| Waktu Selesai | — |
| Durasi Total | — |
| ChromeDriver Version | 149 |
| Browser Dimension | 1600×1024 |
| Headless Mode | Non-headless (headed) |
| Status Akhir | 🕒 Belum dijalankan |

### Daftar Test Case — Iterasi 1a

| # | Test Case | Deskripsi | Status | Waktu | Catatan |
|---|-----------|-----------|--------|-------|---------|
| TC-1a-01 | Canvas Render | Canvas `InteractiveViewer` tampil tanpa error | 🕒 | — | — |
| TC-1a-02 | Pan Gesture | Canvas bisa di-pan kiri/kanan/atas/bawah | 🕒 | — | — |
| TC-1a-03 | Zoom Gesture | Canvas bisa di-zoom in/out dengan pinch atau scroll | 🕒 | — | — |
| TC-1a-04 | StorageNode Render | Node Storage (persegi panjang) tampil di posisi yang benar | 🕒 | — | — |
| TC-1a-05 | EntityNode Render | Node Entity (oval) tampil di posisi yang benar | 🕒 | — | — |
| TC-1a-06 | QueryVectorNode Render | Node Query Vector (dokumen) tampil di posisi yang benar | 🕒 | — | — |
| TC-1a-07 | Koordinat Akurat | Posisi node tidak bergeser saat zoom berubah | 🕒 | — | — |
| TC-1a-08 | State Persistence | State node tidak hilang setelah pan/zoom | 🕒 | — | — |

### Output Log Pengujian 1a

```
[Akan diisi dengan output dari flutter drive saat pengujian dijalankan]
```

### Screenshot Pengujian 1a

> *(Screenshot disimpan di `screenshots/iterasi_1a/`)*

| File Screenshot | Deskripsi |
|-----------------|-----------|
| `screenshots/iterasi_1a/test_run_start.png` | Tampilan awal sebelum test |
| `screenshots/iterasi_1a/canvas_pan_zoom.png` | Test pan/zoom canvas |
| `screenshots/iterasi_1a/node_rendering.png` | Test rendering tiga node |
| `screenshots/iterasi_1a/test_run_complete.png` | Hasil akhir semua test lulus |

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1b — Node Interaction
### Status Pengujian: 🕒 Menunggu 1a
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
| 1a | — | 8 | 0 | 0 | 🕒 Belum |
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
