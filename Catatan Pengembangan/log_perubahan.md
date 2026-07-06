# Log Perubahan (Changelog): FDM Visual Designer

Seluruh penambahan, peningkatan, dan perbaikan pada proyek FDM Visual Designer dirangkum di bawah ini.

## [1.0.0] - 2026-06-27

### Added (Penambahan Fitur)
- **Metamodel & Tipe Inti (`lib/core/metamodel.dart`)**:
  - Definisi formal untuk `FDMNode`, `NodeType`, `DataType`, `PropertyNode`, `FDMEdge`, `SecurityBoundary`, `QueryVector`, dan `ValidationResult`.
- **Zustand-like State Manager (`lib/core/state.dart`)**:
  - Mengimplementasikan `DiagramNotifier` (Riverpod `Notifier`) untuk mengelola pembuatan, penghapusan, koordinat drag, properti, boundary, kueri vector, dan riwayat Undo/Redo (menggunakan snapshot stack).
- **Semantics Validation Engine (`lib/engine/validator.dart`)**:
  - Validasi real-time untuk 8 Well-Formedness Rules (R1 hingga R8) yang diikat secara reaktif dengan diagram state.
- **Visualisasi Tiga Node Utama (`lib/canvas/nodes/`)**:
  - `structural_node.dart`: Folder-tab kustom.
  - `entity_node.dart`: rounded-rect card dengan header biru dan list properti.
  - `security_boundary.dart`: kotak arsir putus-putus dengan tag keamanan, drag, dan resize handler.
- **Relasi Horizontal (`lib/canvas/edges_painter.dart`)**:
  - Menggambar garis hierarchy vertikal, dashed line referencing dengan kardinalitas asterisk (*), dan denormalization line dengan arrowhead ganda dan label.
- **Canvas Zoom/Pan Workspace (`lib/canvas/canvas_view.dart`)**:
  - Integrasi `InteractiveViewer`, custom grid painter background, dan `RepaintBoundary` untuk capture gambar.
- **Toolbar & Sidebar Editor (`lib/ui/`, `lib/panels/`)**:
  - `toolbar.dart`: Undo/Redo, clear, toggle mode Firestore/RTDB, import/export.
  - `sidebar_left.dart`: palette node dan custom Relation Builder.
  - `sidebar_right.dart`: properti editor, Query Vector editor (dengan estimasi Composite/Single-Field Index), dan panel Validation Report.
- **Serialisasi FDM Schema v1 (`lib/export/serializer.dart`)**:
  - Ekspor/impor skema diagram FDM ke format JSON.
  - Ekspor gambar resolusi 2x (PNG) memanfaatkan rendering repaint boundary untuk visual publikasi.
- **Validator Unit Tests (`test/validator_test.dart`)**:
  - Menulis 8 unit test terpisah yang memverifikasi setiap aturan validator semantik secara otomatis.

### Fixed (Perbaikan Bug)
- Mengganti import usang dan dependensi `lucide_icons` ke standard Material Icons (`Icons.xxx`) untuk menyelesaikan crash build akibat finalisasi kelas `IconData` pada SDK Flutter terbaru.
- Mengubah pewarnaan `Colors.emerald` yang tidak tersedia menjadi `Colors.green`.
- Memperbaiki class `DiagramNotifier` agar mewarisi `Notifier` (Riverpod) untuk mengatasi error getter `state`.
- Mengubah syntax `FilePicker.platform.pickFiles` menjadi `FilePicker.pickFiles` untuk mencocokkan API static terbaru.
- Menghapus parameter `dense: true` pada widget `Chip` yang tidak didukung.

## [1.1.0] - 2026-06-27 (Iterasi 2)

### Added (Penambahan Fitur)
- **Koneksi Node Interaktif (Click-to-Connect)**:
  - Dukungan alur penyambungan langsung pada canvas menggunakan handle konektor bulat.
  - State tracking pending connection (`pendingSourceNodeId`, `pendingSourcePropertyKey`, `connectionMode`, dan `isConnecting`) pada `DiagramState`.
  - Aksi `startConnection`, `cancelConnection`, dan `completeConnection` di notifier.
  - Banner panduan visual dinamis pada sidebar kiri saat mode penyambungan aktif.
- **Pengujian E2E Otomatis / Integration Testing (`integration_test/app_test.dart` & `test_driver/integration_test.dart`)**:
  - Setup pengujian integration test berbasis Flutter Driver dan ChromeDriver untuk menguji alur interaktif aplikasi secara non-headless di Google Chrome.
- **Smart Database JSON Importer Fallback (`lib/export/serializer.dart`)**:
  - Dukungan fallback cerdas untuk langsung mengimpor data mentah ekspor database Firebase (seperti data Map `users` dan `products`).
  - Sistem mendeteksi koleksi, melakukan inspeksi dokumen pertama untuk menentukan tipe data properti secara otomatis, serta merender Structural Nodes, Entity Nodes, dan hierarchy edges secara dinamis di kanvas.

### Fixed (Perbaikan Bug)
- Mengatasi crash instansiasi objek fallback `FDMNode` pada banner sidebar kiri dengan memanfaatkan pengecekan aman `state.nodes.any(...)`.
- Memperbaiki metode `copyWith` di `DiagramState` agar menggunakan nilai default `= _undefined` untuk menjaga agar seleksi node/boundary tidak terhapus (ter-reset ke `null`) saat parameter tidak dikirimkan.
- **Crash StateError `SidebarLeft` di Awal Aplikasi**: Menambahkan penanganan aman untuk memilih node default ketika daftar node masih kosong agar tidak melempar eksepsi `StateError: No element`.
- **RenderFlex Layout Overflow di Toolbar**: Mengurangi ukuran horizontal spacing dan padding pada `lib/ui/toolbar.dart` agar Toolbar pas sempurna pada ukuran layar minimum tanpa terjadi overflow 51 piksel.
- **RenderFlex Layout Overflow di Canvas (Test Mode)**: Mengubah `boundaryMargin` di `InteractiveViewer` dari `double.infinity` ke `1000.0` serta mengganti nested `Scaffold` di `CanvasView` dengan `Container` agar penentuan batas layout pada testing environment berjalan normal.
- **Perbaikan Pembacaan File Web (Bytes Null)**: Menambahkan opsi `withData: true` pada `FilePicker` dan menggunakan penanganan cast aman `Map<String, dynamic>.from(e as Map)` agar pembacaan byte JSON web tidak bernilai null atau memicu type cast exception di runtime.
- **Pencegahan Tabrakan ID Pembuatan Komponen**: Mengganti format ID generator berbasis milidetik mentah dengan menambahkan nomor acak suffix (`math.Random().nextInt(1000000)`) pada pembuatan node, boundary, dan edge untuk mencegah tabrakan ID (duplicate ID collision) saat ditambahkan berturut-turut secara cepat, yang sebelumnya membuat node baru menempel di node lama.
- **Penyelesaian Konflik Gesture Drag & Pan Canvas (Final)**: Menghapus `InteractiveViewer` sepenuhnya dan menggantinya dengan sistem pan/zoom/drag manual berbasis `Listener` (raw pointer events) dan widget `Transform`. Pendekatan ini menghilangkan konflik gesture arena secara total, karena tidak ada lagi gesture recognizer bawaan yang bersaing dengan event seret node. Hit-testing manual dilakukan untuk menentukan apakah pointer mengenai node (drag node) atau area kosong (pan kanvas). Zoom scroll mouse juga ditangani secara manual.

## [1.2.0] - 2026-07-06

### Added (Penambahan Fitur)
- **Deployment ke Vercel**: Sukses deploy web build produksi ke Vercel dengan domain proyek formal [fdm-vd.vercel.app](https://fdm-vd.vercel.app).

## [1.3.0] - 2026-07-06 (Penyesuaian Revisi 3 Final)

### Changed (Perubahan Arsitektur)
- **Refaktor Canvas Engine ke `InteractiveViewer` + Inversi Matriks**: Menghapus arsitektur `Listener` manual (yang sebelumnya diterapkan untuk menghindari konflik gesture) dan menggantinya dengan kombinasi `InteractiveViewer` + `TransformationController` sesuai spesifikasi Revisi 3 Final Bagian 2.2.
  - Koordinat pointer dari screen-space kini ditransformasi ke canvas-space menggunakan `Matrix4.inverted()` untuk hit-testing node yang akurat.
  - Konflik gesture diatasi dengan menonaktifkan `panEnabled` dan `scaleEnabled` pada `InteractiveViewer` secara dinamis saat drag node aktif, lalu mengaktifkannya kembali saat drag selesai.
  - Grid cell size disesuaikan dari 40px menjadi 20px sesuai spesifikasi (Bagian 2.4).
  - Mode tag (Firestore/RTDB) kini dirender langsung di dalam kanvas sebagai overlay teks berwarna sesuai mode.

### Added (Penambahan)
- **Dependensi `vector_math: ^2.2.0`**: Ditambahkan sebagai dependensi eksplisit di `pubspec.yaml` karena digunakan langsung oleh `canvas_view.dart` untuk operasi `Vector3` dalam inversi matriks koordinat.
- **Folder `dokumentasi-pengembangan/`**: Menginisialisasi 13 file log kumulatif IIDD sesuai Bagian 8 spesifikasi Revisi 3 Final, meliputi: `00_estimasi_waktu.md`, `00_requirement_traceability_matrix.md`, `context_drift_log.md`, `validation_log.md`, `conversation_log.md`, `decision_log.md`, `commit_history.md`, `iteration_summary.md`, `waktu_estimasi_vs_realisasi.md`, `durasi_per_fitur.md`, `human_intervention.md`, `error_log.md`, dan `interactive_test_log.md`.

## [1.3.1] - 2026-07-06 (Perbaikan Bug Zoom & Layout Spawn)

### Fixed (Perbaikan Bug)
- **Bug Penyeretan Saat Zoom (InteractiveViewer)**: Memperbaiki masalah di mana node bergeser secara liar ke kanan bawah kanvas ketika pengguna melakukan pinch-to-zoom atau memindahkan kamera.
  - Implementasi **Single-Pointer Tracking** dengan `_activePointerId` di `canvas_view.dart`. Drag node hanya diproses jika berasal dari pointer pertama. Jika ada pointer tambahan (misalnya dari gesture pinch-to-zoom), sesi drag akan dibatalkan (`_abortDrag()`) sehingga interaksi zoom/pan kamera tidak terganggu.
  - Penambahan `onPointerCancel` pada `Listener` kanvas untuk mereset state drag dengan andal.
- **Penumpukan Posisi Spawn Node (Overlap)**: Mengubah penentuan posisi koordinat spawn node baru dari acak `(1350–1550)` menjadi berbasis **Grid Layout** (4 kolom, masing-masing cell berukuran 280x220px) dengan jitter ringan (±20px) di `sidebar_left.dart`. Hal ini menjamin 10+ node baru yang ditambahkan berurutan tidak saling tumpang tindih secara visual.

