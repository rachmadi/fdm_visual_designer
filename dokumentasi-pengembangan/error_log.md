# 🐛 Error Log — FDM Visual Designer
## Format: Kumulatif per Iterasi | Spesifikasi: Revisi 3 Final

> File ini mencatat semua error yang ditemukan selama pengembangan beserta resolusinya.
> Termasuk compile error, runtime error, test failure, dan logic error.

---

## Cara Mengisi

```
### E-XXX: [Judul Error]
- **Iterasi**: 
- **Tanggal**: 
- **Jenis Error**: Compile / Runtime / Test / Logic
- **Lokasi**: file:line
- **Pesan Error**: (paste pesan error asli)
- **Penyebab Root**: 
- **Langkah Resolusi**: 
- **Waktu Resolusi**: 
- **Status**: ✅ Resolved / ⚠️ Workaround / ❌ Open
```

---

═══════════════════════════════════════════════════════════════════
## PRE-ITERASI — Error Sesi Sebelumnya (Referensi)
### Sumber: log_pengembangan_iterasi.md
═══════════════════════════════════════════════════════════════════

### E-001: StateNotifier Tidak Kompatibel Riverpod v3

- **Iterasi**: Pra-1a
- **Tanggal**: 2026-06-27
- **Jenis Error**: Compile
- **Lokasi**: `lib/core/state.dart`
- **Pesan Error**: `Getter 'state' tidak dikenali oleh compiler pada DiagramNotifier`
- **Penyebab Root**: Pewarisan `StateNotifier` (Riverpod v2) tidak kompatibel dengan Riverpod v3
- **Langkah Resolusi**: Mengganti pewarisan ke kelas `Notifier` Riverpod modern yang lebih stabil
- **Waktu Resolusi**: ~15 menit
- **Status**: ✅ Resolved

---

### E-002: Lucide Icons — IconData Final Class

- **Iterasi**: Pra-1a
- **Tanggal**: 2026-06-27
- **Jenis Error**: Compile
- **Lokasi**: Semua widget yang menggunakan `lucide_icons`
- **Pesan Error**: `Kelas IconData dideklarasikan sebagai final pada SDK Flutter terbaru sehingga tidak bisa di-extend`
- **Penyebab Root**: Package `lucide_icons` mencoba meng-extend `IconData` yang kini berstatus `final`
- **Langkah Resolusi**: Hapus dependensi `lucide_icons` dari `pubspec.yaml`; migrasi ke Material Icons `Icons.xxx`
- **Waktu Resolusi**: ~20 menit
- **Status**: ✅ Resolved

---

### E-003: SystemMouseCursors.resizeUpDownLeftRight Tidak Terdefinisi

- **Iterasi**: Pra-1a
- **Tanggal**: 2026-06-27
- **Jenis Error**: Compile
- **Lokasi**: `lib/features/canvas/security_boundary.dart`
- **Pesan Error**: `The getter 'resizeUpDownLeftRight' isn't defined for the class 'SystemMouseCursors'`
- **Penyebab Root**: Cursor tersebut tidak tersedia di versi SDK yang digunakan
- **Langkah Resolusi**: Diubah menjadi `SystemMouseCursors.resizeLeftRight`
- **Waktu Resolusi**: ~5 menit
- **Status**: ✅ Resolved

---

### E-004: FilePicker.platform.pickFiles — Static Method Error

- **Iterasi**: Pra-1a
- **Tanggal**: 2026-06-27
- **Jenis Error**: Compile
- **Lokasi**: `lib/features/toolbar/toolbar.dart`
- **Pesan Error**: `Getter 'platform' tidak ditemukan pada FilePicker`
- **Penyebab Root**: API FilePicker berubah; `platform` bukan getter yang valid
- **Langkah Resolusi**: Mengubah ke pemanggilan `FilePicker.pickFiles` (static method langsung)
- **Waktu Resolusi**: ~10 menit
- **Status**: ✅ Resolved

---

### E-005: Chip Widget — Parameter `dense` Tidak Dikenali

- **Iterasi**: Pra-1a
- **Tanggal**: 2026-06-27
- **Jenis Error**: Compile
- **Lokasi**: `lib/features/sidebar/sidebar_right.dart`
- **Pesan Error**: `Named parameter 'dense' isn't defined`
- **Penyebab Root**: Widget `Chip` di Flutter tidak memiliki parameter `dense`
- **Langkah Resolusi**: Menghapus parameter `dense: true` dari konstruktor `Chip`
- **Waktu Resolusi**: ~5 menit
- **Status**: ✅ Resolved

---

### E-006: Colors.emerald Tidak Terdefinisi

- **Iterasi**: Pra-1a
- **Tanggal**: 2026-06-27
- **Jenis Error**: Compile
- **Lokasi**: `lib/features/sidebar/sidebar_left.dart`
- **Pesan Error**: `Getter 'emerald' isn't defined for the class 'Colors'`
- **Penyebab Root**: `Colors.emerald` tidak ada di Material Colors Flutter
- **Langkah Resolusi**: Diubah ke `Colors.green.shade100`
- **Waktu Resolusi**: ~5 menit
- **Status**: ✅ Resolved

---

### E-007: Import Path canvas_view.dart — Relative Path Salah

- **Iterasi**: Pra-1a
- **Tanggal**: 2026-06-27
- **Jenis Error**: Compile
- **Lokasi**: `lib/features/canvas/canvas_view.dart`
- **Pesan Error**: `Target of URI doesn't exist: 'edges_painter.dart'`
- **Penyebab Root**: Relative path import tidak sesuai dengan struktur folder aktual
- **Langkah Resolusi**: Memperbaiki path import dan menambahkan `import '../../core/metamodel.dart'`
- **Waktu Resolusi**: ~10 menit
- **Status**: ✅ Resolved

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1a — Fondasi Canvas & Three-Node Architecture
═══════════════════════════════════════════════════════════════════

### E-008: Matrix4.translate Deprecation & translateByDouble Positional Argument Error

- **Iterasi**: 1a
- **Tanggal**: 2026-07-06
- **Jenis Error**: Compile
- **Lokasi**: `lib/canvas/canvas_view.dart:71`
- **Pesan Error**: `Too few positional arguments: 4 required, 2 given`
- **Penyebab Root**: Method `translateByDouble` memerlukan 3 argumen posisional (x, y, z), sedangkan kami hanya memasukkan 2 argumen untuk memindahkan viewport di bidang 2D.
- **Langkah Resolusi**: Mengubah pemanggilan menjadi `Matrix4.translationValues(x, y, 0.0)` yang lebih aman dan terhindar dari deprecation.
- **Waktu Resolusi**: ~5 menit
- **Status**: ✅ Resolved

---

### E-009: Node Drift & Berkumpul di Kanan Bawah saat Zoom

- **Iterasi**: 1a
- **Tanggal**: 2026-07-06
- **Jenis Error**: Logic
- **Lokasi**: `lib/canvas/canvas_view.dart`
- **Pesan Error**: Node tidak berada di posisi semula dan berpindah liar ke kanan bawah saat melakukan pinch-to-zoom / scroll zoom.
- **Penyebab Root**: 
  1. Delta penyeretan node hanya membagi koordinat screen-space dengan `scale` (mengabaikan translasi matriks).
  2. Gesture pinch-to-zoom menggunakan dua pointer (multitouch) yang memicu deteksi drag node karena salah satu pointer menyentuh area node.
- **Langkah Resolusi**: 
  - Melakukan konversi posisi pointer sebelum dan sesudah menggunakan inversi matriks (`_screenToCanvas`).
  - Mengimplementasikan `_activePointerId` untuk membatasi drag hanya pada satu pointer (single touch), dan membatalkan drag (`_abortDrag()`) jika terdeteksi pointer tambahan (pinch-to-zoom gesture).
- **Waktu Resolusi**: ~15 menit
- **Status**: ✅ Resolved

---

### E-010: Penumpukan Posisi Spawn Node Baru (Overlap)

- **Iterasi**: 1a
- **Tanggal**: 2026-07-06
- **Jenis Error**: Logic
- **Lokasi**: `lib/ui/sidebar_left.dart`
- **Pesan Error**: Penambahan beberapa node secara beruntun menyebabkan node baru menumpuk di koordinat yang sama.
- **Penyebab Root**: Posisi spawn acak awal `(1350–1550)` tidak mengecek keberadaan node lain.
- **Langkah Resolusi**: Mengganti sistem posisi spawn acak menjadi **Grid-based Layout** (4 kolom x baris ke bawah, cell 280x220px) dengan variasi jitter ringan (±20px) berdasarkan jumlah node yang ada.
- **Waktu Resolusi**: ~5 menit
- **Status**: ✅ Resolved

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1b–7 — [Template]
═══════════════════════════════════════════════════════════════════

*[Blok-blok ini akan diisi pada iterasi yang sesuai]*

---

## Ringkasan Error per Jenis

| Jenis Error | Total | Resolved | Workaround | Open |
|-------------|-------|----------|------------|------|
| Compile | 8 | 8 | 0 | 0 |
| Runtime | 0 | 0 | 0 | 0 |
| Test Failure | 0 | 0 | 0 | 0 |
| Logic | 2 | 2 | 0 | 0 |
| **Total** | **10** | **10** | **0** | **0** |

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: otomatis setiap kali error ditemukan*

