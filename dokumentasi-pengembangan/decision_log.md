# 🏛️ Decision Log — FDM Visual Designer
## Format: Kumulatif per Iterasi | Spesifikasi: Revisi 3 Final

> File ini mencatat seluruh keputusan teknis dan arsitektur penting selama pengembangan.
> Setiap keputusan harus disertai alasan, alternatif yang ditolak, dan dampak implementasi.

---

## Format Entri Keputusan

```
### D-XXX: [Judul Keputusan]
- **Tanggal**: YYYY-MM-DD
- **Dibuat oleh**: [Pengguna / Agen / Bersama]
- **Konteks**: [Mengapa keputusan ini perlu diambil?]
- **Keputusan**: [Apa yang diputuskan?]
- **Alternatif yang Ditolak**: [Opsi lain yang dipertimbangkan]
- **Alasan Pemilihan**: [Mengapa opsi ini dipilih?]
- **Dampak**: [Dampak terhadap arsitektur / implementasi]
- **Iterasi Terdampak**: [1a, 1b, dst.]
```

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1a — Fondasi Canvas & Three-Node Architecture
### Tanggal: 2026-07-06
═══════════════════════════════════════════════════════════════════

### D-001: Gunakan `InteractiveViewer` + Inversi Matriks

- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Spesifikasi Revisi 3 Final (dikonfirmasi pengguna)
- **Konteks**: Diperlukan mekanisme pan/zoom yang akurat untuk canvas diagram. Pendekatan awal menggunakan `GestureDetector` + `Listener` manual menghasilkan offset koordinat yang tidak akurat saat zoom level berubah, terutama saat mendeteksi posisi tap pada node.
- **Keputusan**: Gunakan `InteractiveViewer` bawaan Flutter sebagai wrapper canvas utama. Transformasi koordinat dari screen-space ke canvas-space dilakukan dengan **inversi matriks transformasi** (`Matrix4.tryInvert`) yang diperoleh dari `TransformationController`.
- **Alternatif yang Ditolak**:
  - `GestureDetector` manual dengan offset kalkulasi manual
  - `Listener` manual dengan state `_scale` dan `_offset` terpisah
- **Alasan Pemilihan**: `InteractiveViewer` menyediakan built-in bounded pan/zoom yang smooth, dan inversi matriks adalah satu-satunya cara yang matematis benar untuk mengkonversi koordinat saat zoom berubah tanpa drift kumulatif.
- **Dampak**: Semua gesture handler (tap, drag) harus mengkonversi koordinat menggunakan `_transformationController.toScene(localPosition)` atau ekuivalen inversi matriks sebelum diproses.
- **Iterasi Terdampak**: 1a, 1b, dan semua iterasi yang melibatkan gesture pada canvas

---

### D-002: Revert dari Manual `Listener` ke `InteractiveViewer`

- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Agen (berdasarkan deteksi context drift dari spesifikasi)
- **Konteks**: Pada iterasi sebelumnya (sebelum Revisi 3), pernah ada percobaan mengganti `InteractiveViewer` dengan arsitektur manual menggunakan `Listener` widget dan state `_scale`/`_offset` custom. Ini menyebabkan berbagai bug: (1) koordinat node bergeser saat zoom, (2) edge rendering tidak sinkron, (3) boundary containment check gagal.
- **Keputusan**: Kembalikan seluruh arsitektur canvas ke `InteractiveViewer` + `TransformationController` sesuai spesifikasi Revisi 3 Final. Hapus semua kode sisa `Listener` manual yang tidak sesuai spesifikasi.
- **Alternatif yang Ditolak**:
  - Mempertahankan arsitektur `Listener` manual dengan perbaikan parsial
  - Hybrid approach (sebagian `InteractiveViewer`, sebagian manual)
- **Alasan Pemilihan**: Konsistensi dengan spesifikasi Revisi 3 adalah prioritas utama. Arsitektur hybrid akan menciptakan technical debt yang sulit di-debug.
- **Dampak**: Refactoring `canvas_view.dart` dan `canvas_controller.dart`. Semua koordinat gesture harus menggunakan `_transformationController.toScene()`.
- **Iterasi Terdampak**: 1a (dan retroaktif membatalkan semua kode Listener manual sebelumnya)

---

### D-003: Gunakan Riverpod `Notifier` (bukan `StateNotifier`)

- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Agen (error kompilasi)
- **Konteks**: `StateNotifier` dari Riverpod v2 tidak kompatibel dengan Riverpod v3 yang digunakan proyek ini. Getter `state` tidak dikenali oleh compiler.
- **Keputusan**: Gunakan kelas `Notifier<T>` dari Riverpod v3 untuk semua state notifier diagram.
- **Alternatif yang Ditolak**: Downgrade Riverpod ke v2 (risiko ketidakcocokan API lain)
- **Alasan Pemilihan**: Mengikuti API Riverpod versi terbaru lebih sustainable untuk jangka panjang.
- **Dampak**: Semua `StateNotifier` diganti dengan `Notifier`; `ref` dan `state` diakses secara berbeda.
- **Iterasi Terdampak**: 1a dan semua iterasi yang menggunakan state management

---

### D-004: Ganti `lucide_icons` dengan Material Icons

- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Agen (error kompilasi)
- **Konteks**: Package `lucide_icons` meng-extend kelas `IconData` yang dideklarasikan sebagai `final` di SDK Flutter terbaru, menyebabkan compile error.
- **Keputusan**: Hapus dependensi `lucide_icons`, gunakan `Icons.xxx` dari Material Icons bawaan Flutter.
- **Alternatif yang Ditolak**: Fork `lucide_icons` dan patch secara manual
- **Alasan Pemilihan**: Material Icons sudah cukup lengkap dan tidak menambah dependensi eksternal yang berisiko.
- **Dampak**: Semua icon di toolbar dan sidebar menggunakan `Icons.*`
- **Iterasi Terdampak**: 1a, semua iterasi yang melibatkan UI icon

---

### D-005: Single-Pointer Tracking untuk Menghindari Konflik Multi-Touch Zoom

- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Agen (perbaikan bug zoom)
- **Konteks**: Saat menggunakan pinch-to-zoom (dua jari) pada area canvas yang memiliki node, event pointer dari jari kedua dapat secara keliru memicu deteksi drag node. Ini menyebabkan node tergeser liar ke pojok bawah kanvas karena perubahan scale yang cepat dan pergerakan multi-pointer.
- **Keputusan**: Implementasi **Single-Pointer Tracking** dengan `_activePointerId` di `canvas_view.dart`. Drag node hanya diproses jika pointer id cocok dengan yang memulai (`_activePointerId`). Jika pointer kedua menyentuh kanvas, sesi drag langsung dibatalkan (`_abortDrag()`) sehingga pengguna dapat melakukan pinch-to-zoom dengan aman tanpa memicu drag.
- **Alternatif yang Ditolak**:
  - Menonaktifkan zoom saat kursor berada di atas node (mengurangi kemudahan navigasi).
  - Menyaring event drag berdasarkan jarak perpindahan minimum (masih rentan terpicu saat pinch cepat).
- **Alasan Pemilihan**: Membatalkan drag saat multi-touch adalah pendekatan standar dalam diagram editor untuk memprioritaskan navigasi canvas (zoom/pan) saat lebih dari satu jari aktif.
- **Dampak**: Navigasi zoom/pan stabil dan node tidak lagi melompat/drift.
- **Iterasi Terdampak**: 1a

---

### D-006: Grid-Based Spawn Layout untuk Mencegah Overlap Node

- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Agen (laporan bug overlap)
- **Konteks**: Posisi spawn node acak awal `(1350–1550)` membuat node yang ditambahkan berturut-turut saling menumpuk (overlap) secara visual, mengganggu keterbacaan diagram.
- **Keputusan**: Gunakan **Grid-based Spawn Layout** (4 kolom, ukuran cell 280x220px) dengan jitter ringan (±20px) di `sidebar_left.dart` berdasarkan jumlah node yang sudah ada di kanvas.
- **Alternatif yang Ditolak**: Spawn di koordinat statis `(0,0)` (tidak terlihat oleh viewport awal).
- **Alasan Pemilihan**: Menjamin node terdistribusi dengan rapi dan otomatis saat ditambahkan, langsung berada dalam jangkauan viewport utama.
- **Dampak**: Penambahan 10+ node berjalan lancar tanpa overlap visual.
- **Iterasi Terdampak**: 1a

---

*[Tambahkan keputusan baru di bawah ini saat iterasi 1a berlangsung]*


---

═══════════════════════════════════════════════════════════════════
## ITERASI 1b — [Template]
═══════════════════════════════════════════════════════════════════

*[Blok ini akan diisi saat Iterasi 1b dimulai]*

---

═══════════════════════════════════════════════════════════════════
## ITERASI 2a–7 — [Template]
═══════════════════════════════════════════════════════════════════

*[Blok-blok ini akan diisi pada iterasi yang sesuai]*

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: otomatis setiap akhir sesi*
