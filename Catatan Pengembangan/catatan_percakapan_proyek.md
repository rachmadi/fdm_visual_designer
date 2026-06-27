# Catatan Percakapan Proyek: FDM Visual Designer

## Kronologi Percakapan & Proses Pengembangan

1. **Inisialisasi Folder Proyek**:
   * Menyiapkan folder proyek `fdm_visual_designer`.
   * Mengekstrak dokumen spesifikasi dan panduan notasi dari format `.docx` menggunakan skrip PowerShell kustom.

2. **Perubahan Rencana Teknologi Stack**:
   * Rencana awal menggunakan React/TypeScript + React Flow.
   * User meminta opsi menggunakan **Flutter Web**.
   * Setelah mendiskusikan kelayakan teknis (CustomPainter, InteractiveViewer, dll.), diputuskan untuk bermigrasi sepenuhnya ke Flutter Web.
   * Melakukan pembersihan file React dan menginisialisasi proyek Flutter baru.

3. **Inisialisasi Dependensi & Metamodel**:
   * Memasang dependensi: `flutter_riverpod` dan `file_picker`.
   * Menulis definisi metamodel di `lib/core/metamodel.dart`.

4. **Implementasi State & Validator**:
   * Menulis state notifier menggunakan Riverpod `Notifier` di `lib/core/state.dart`.
   * Menulis mesin validasi semantik di `lib/engine/validator.dart` untuk mengeksekusi 8 Well-Formedness Rules (WFR) secara real-time.

5. **Pengembangan Widget Canvas & Node**:
   * `lib/canvas/canvas_view.dart`: Canvas workspace dengan zoom/pan `InteractiveViewer` dan grid background.
   * `lib/canvas/nodes/structural_node.dart`: Structural Node (Folder Tab) kustom menggunakan CustomPainter.
   * `lib/canvas/nodes/entity_node.dart`: Entity Node (Document Card) dengan properti.
   * `lib/canvas/nodes/security_boundary.dart`: Security Boundary dengan garis putus-putus kustom, access tag, drag & resize handle.
   * `lib/canvas/edges_painter.dart`: EdgesPainter menggambar hierarchy, referencing (*), dan denormalization lines.

6. **Implementasi Serialisasi & Fitur Toolbar/Sidebar**:
   * `lib/export/serializer.dart`: Konversi skema FDM JSON v1 dan dukungan download file web.
   * `lib/ui/toolbar.dart`: Menu toggle mode (Firestore vs RTDB), Undo/Redo, Clear, Import JSON, dan Export (JSON / PNG 2x resolusi).
   * `lib/ui/sidebar_left.dart`: Palette node dan Connection Builder kustom.
   * `lib/panels/sidebar_right.dart`: Edit nama/path node, edit list properti, Query Vector Builder, dan Validation Report.

## Masalah Teknis & Solusi

1. **Uji Coba Pertama Flutter Build Web Mengalami Kegagalan**:
   * **Masalah**: Kesalahan referensi getter `state` pada `DiagramNotifier`. 
     * *Solusi*: Mengubah `StateNotifier` yang sudah usang di Riverpod v3 menjadi `Notifier` modern.
   * **Masalah**: `SystemMouseCursors.resizeUpDownLeftRight` tidak ada di Flutter.
     * *Solusi*: Mengubahnya menjadi `SystemMouseCursors.resizeLeftRight` yang valid.
   * **Masalah**: `LucideIcons.cornerBottomRight` tidak ditemukan.
     * *Solusi*: Menggantinya dengan icon Material bawaan `Icons.open_in_full`.
   * **Masalah**: `lucide_icons` package mengalami error fatal karena mencoba meng-extend kelas `IconData` yang sekarang bernilai `final` di SDK Flutter terbaru.
     * *Solusi*: Menghapus dependensi `lucide_icons` sepenuhnya dan memigrasikan semua widget ke standard Material Icons (`Icons.xxx`). Hal ini menjamin stabilitas jangka panjang dan kompatibilitas SDK.
   * **Masalah**: Kesalahan import path `import '../edges_painter.dart';` di `canvas_view.dart`.
     * *Solusi*: Memperbaikinya ke `import 'edges_painter.dart';` karena berada di folder yang sama.
   * **Masalah**: `NodeType` tidak didefinisikan di `canvas_view.dart`.
     * *Solusi*: Menambahkan `import '../../core/metamodel.dart';`.

2. **Hasil Uji Coba Akhir**:
   * Analisis statis bersih tanpa error.
   * Sukses build produksi web via `flutter build web`.
   * Sukses uji coba unit test via `flutter test` (semua 8 pengujian WFR lulus 100%).

## Iterasi 2: Relasi Horizontal (Referencing & Denormalization)

1. **Pengembangan Interaksi Hubungan (Click-to-Connect)**:
   * Menambahkan state `pendingSourceNodeId`, `pendingSourcePropertyKey`, `connectionMode`, dan `isConnecting` pada `DiagramState` di [state.dart](file:///e:/rachmadi/Antigravity/fdm_visual_designer/lib/core/state.dart).
   * Menulis aksi `startConnection`, `cancelConnection`, dan `completeConnection` untuk mempermudah penyambungan antar node/properti secara interaktif.
   * Menghubungkan output handle di bagian bawah node structural/entity dan handle properti di sisi kanan entity card untuk memicu alur penyambungan.
   * Menambahkan banner panduan interaktif di sidebar kiri (`SidebarLeft`) saat proses penyambungan sedang aktif.

2. **Masalah Teknis & Solusi**:
   * **Masalah**: Kesalahan argumen wajib `path` dan `queryVector` saat pembuatan objek fallback `FDMNode` pada banner sidebar kiri.
     * *Solusi*: Mengganti instansiasi fallback `FDMNode` dengan pengecekan aman `state.nodes.any(...)` menggunakan operator ternary.
   * **Masalah**: Nilai seleksi (`selectedNodeId`, dll.) diatur ulang ke `null` saat memanggil `copyWith` tanpa argumen karena tidak adanya nilai default parameter di tanda tangan metode `copyWith`.
     * *Solusi*: Memperbaiki tanda tangan `copyWith` dengan menambahkan nilai default `= _undefined` untuk parameter yang berkaitan dengan seleksi.

3. **Pengujian E2E non-headless di Browser**:
   * User meminta pengujian fitur yang telah dibuat langsung di browser secara interaktif (non-headless).
   * Membuat skrip driver `test_driver/integration_test.dart` dan skrip pengujian E2E `integration_test/app_test.dart`.
   * Menjalankan ChromeDriver di latar belakang dan mengeksekusi `flutter drive` dengan target browser Chrome.

4. **Masalah Teknis Pengujian & Solusi**:
   * **Masalah**: Terjadi crash `StateError: No element` di `SidebarLeft` saat diagram kosong di awal startup karena memanggil `state.nodes.first` sebagai default sourceNode.
     * *Solusi*: Menambahkan pemeriksaan keamanan `state.nodes.isNotEmpty` dan `state.nodes.any(...)` sebelum memanggil `first` atau `firstWhere`.
   * **Masalah**: Kesalahan rendering `RenderFlex overflowed by 99391 pixels` yang disebabkan oleh penentuan `boundaryMargin` bernilai `double.infinity` pada `InteractiveViewer` serta adanya nested `Scaffold` di `CanvasView` saat berjalan dalam mode testing.
     * *Solusi*: Mengubah `boundaryMargin` menjadi `1000.0` (batas aman panning) dan mengganti `Scaffold` canvas dengan `Container`.
   * **Masalah**: Kesalahan duplicate widget finder di `app_test.dart` karena teks `new_collection` dan `NewEntity` muncul di canvas sekaligus di form edit sidebar kanan saat terpilih.
     * *Solusi*: Menggunakan `.first` pada finder dan menggunakan ekspektasi `findsAtLeastNWidgets(1)`.
   * **Masalah**: Kesalahan rendering `RenderFlex overflowed by 51 pixels` di `Toolbar` karena ukuran layar minimum browser test lebih kecil dari total lebar gabungan tombol toolbar.
     * *Solusi*: Mengurangi fixed horizontal spacing (misal `SizedBox` width 24 menjadi 10) dan margin padding luar agar pas dalam viewport sempit.

5. **Hasil Pengujian Akhir**:
   * Analisis statis bersih (0 error).
   * Seluruh unit test semantik lulus (`flutter test`).
   * **Seluruh E2E Integration Test sukses dijalankan dan lulus 100% di browser Chrome (`All tests passed!`)**.
   * Sinkronisasi repositori ke remote GitHub berhasil dilakukan.

6. **Penyajian di Server Lokal & Penyempurnaan Impor JSON**:
   * Menjalankan server lokal via `npx serve` pada port `5555` agar pengguna dapat memantau dan mencoba aplikasi web secara langsung.
   * **Masalah**: Pengguna mengimpor file data mentah Firebase JSON ekspor (users/products) tetapi tidak terjadi apa-apa karena byte pembacaan file bernilai null di web.
     * *Solusi*: Memperbaiki parameter `FilePicker.pickFiles` dengan menambahkan `withData: true` dan menyusun `Map<String, dynamic>.from(e as Map)` agar terhindar dari platform-specific type cast crash.
   * **Inovasi Cerdas**: Menulis parser fallback reaktif di [serializer.dart](file:///e:/rachmadi/Antigravity/fdm_visual_designer/lib/export/serializer.dart) untuk mendeteksi data mentah Firebase JSON. Jika pengguna mengunggah data database biasa, sistem secara otomatis mengekstrak properti, menentukan tipe data, membuat Structural Node (Koleksi), Entity Node (Dokumen), dan menyusun relasi hierarchy secara dinamis di kanvas.
   * **Hasil**: Tampilan kanvas FDM Designer berhasil ter-load sempurna dan memvisualisasikan data `users` dan `products` langsung di monitor pengguna. Repositori berhasil disinkronkan ke remote GitHub.
