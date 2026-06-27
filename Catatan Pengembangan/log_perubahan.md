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
