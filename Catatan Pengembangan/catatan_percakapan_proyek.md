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
