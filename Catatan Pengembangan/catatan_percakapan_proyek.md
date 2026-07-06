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
   * **Perbaikan Penyeretan Berdampingan (Tabrakan ID)**:
     * *Masalah*: Node baru menempel dan ikut terseret bersama node lama ketika ditambahkan berturut-turut.
     * *Penyebab*: Penggunaan ID generator berbasis `millisecondsSinceEpoch` mentah memicu tabrakan ID jika klik terjadi dalam milidetik yang sama atau berturut-turut cepat di web browser.
     * *Solusi*: Memodifikasi ID generator di [sidebar_left.dart](file:///e:/rachmadi/Antigravity/fdm_visual_designer/lib/ui/sidebar_left.dart) dan [state.dart](file:///e:/rachmadi/Antigravity/fdm_visual_designer/lib/core/state.dart) dengan menambahkan suffix acak `_${math.Random().nextInt(1000000)}` untuk menjamin keunikan identitas global node baru.
     * *Hasil*: Seluruh node dapat diseret secara mandiri dan terpisah sempurna. Komit di-*push* ke remote GitHub.
   * **Penyelesaian Konflik Gesture Drag & Pan Canvas (Final — ~1 jam debugging)**:
     * *Masalah*: Menyeret node baru membuat semua node ikut bergeser secara visual di layar, sementara koordinat angka di panel DEBUG COORDINATES tidak berubah. Node baru tidak bisa dipindahkan secara individu.
     * *Penyebab Akar*: `InteractiveViewer` milik Flutter memiliki gesture recognizer internal yang **selalu memenangkan** kompetisi di Flutter Gesture Arena melawan `GestureDetector` pada widget child. Setiap usaha menyeret di atas node selalu dirampas oleh `InteractiveViewer` untuk melakukan canvas panning.
     * *Pendekatan yang Dicoba & Gagal*:
       1. `nodeHoverProvider` + `panEnabled: !isHovering` → Hover state tidak cukup cepat bereaksi.
       2. `panEnabled: !isPanDisabled` berbasis selection state + `onPanStart` → `InteractiveViewer` masih merampas gesture sebelum `onPanStart` sempat dipanggil.
       3. `EagerPanGestureRecognizer` via `RawGestureDetector` yang langsung `resolve(GestureDisposition.accepted)` → `InteractiveViewer` tetap memenangkan arena.
     * *Solusi Final*: **Menghapus `InteractiveViewer` sepenuhnya** dan menggantinya dengan sistem pan/zoom/drag manual berbasis `Listener` (raw pointer events) dan widget `Transform`.
       - `Listener.onPointerDown`: Hit-testing manual untuk menentukan apakah pointer mengenai node (drag node) atau area kosong (pan kanvas).
       - `Listener.onPointerMove`: Menggeser node individual atau menggeser kanvas berdasarkan hasil hit-test.
       - `Listener.onPointerSignal`: Zoom scroll mouse dengan skala terpusat pada posisi pointer.
       - File yang dimodifikasi: [canvas_view.dart](file:///e:/rachmadi/Antigravity/fdm_visual_designer/lib/canvas/canvas_view.dart), [entity_node.dart](file:///e:/rachmadi/Antigravity/fdm_visual_designer/lib/canvas/nodes/entity_node.dart), [structural_node.dart](file:///e:/rachmadi/Antigravity/fdm_visual_designer/lib/canvas/nodes/structural_node.dart), [security_boundary.dart](file:///e:/rachmadi/Antigravity/fdm_visual_designer/lib/canvas/nodes/security_boundary.dart).
     * *Hasil*: Setiap node dapat diseret secara mandiri dan independen. Canvas panning bekerja di area kosong. Zoom scroll mouse berfungsi. Komit di-*push* ke remote GitHub.

## Durasi Sesi Pengembangan & Pengujian

| Tahap | Waktu Mulai (WIB) | Waktu Selesai (WIB) | Durasi |
|---|---|---|---|
| Inisialisasi & Implementasi Inti | 11:10 | 11:40 | ~30 menit |
| Testing E2E & Perbaikan Bug | 11:40 | 12:08 | ~28 menit |
| Penyajian Web & Perbaikan Import JSON | 12:08 | 12:22 | ~14 menit |
| Debugging Masalah Drag Node (ID collision) | 12:22 | 12:37 | ~15 menit |
| Debugging Masalah Drag Node (Gesture Arena) | 12:37 | 13:13 | ~36 menit |
| Pembersihan Kode & Pembaruan Catatan Awal | 13:13 | 13:17 | ~4 menit |
| Pengujian Ulang E2E (tanpa IgnorePointer) & Git Push | 13:17 | 13:21 | ~4 menit |
| **Total Sesi** | **11:10** | **13:21** | **~2 jam 11 menit** |

### Sesi Baru: Deploy Vercel (2026-07-06)

| Tahap | Waktu Mulai (WIB) | Waktu Selesai (WIB) | Durasi |
|---|---|---|---|
| Deploy ke Vercel (fdm-vd.vercel.app) | 10:15 | 10:28 | ~13 menit |
| **Total Sesi Baru** | **10:15** | **10:28** | **~13 menit** |

### Sesi: Penyesuaian Arsitektur Canvas ke Revisi 3 Final (2026-07-06)

**Ringkasan:**
- Membaca dokumen spesifikasi `Spesifikasi_FDM_Visual_Designer_Flutter (Revisi 3 Final).docx` secara menyeluruh.
- Mendeploy aplikasi ke Vercel dengan nama proyek `fdm-vd` dan alias `fdm-vd.vercel.app`.
- Melakukan refaktor `canvas_view.dart`: menghapus arsitektur `Listener` manual dan menggantinya kembali dengan `InteractiveViewer` + `TransformationController` sesuai spesifikasi Revisi 3 Bagian 2.2.
- Kunci implementasi: inversi matriks koordinat (`Matrix4.inverted()`) untuk mengkonversi posisi pointer dari screen-space ke canvas-space, dan penonaktifan `panEnabled`/`scaleEnabled` secara dinamis saat drag node aktif untuk mencegah konflik gesture.
- Menginisialisasi folder `dokumentasi-pengembangan/` dengan 13 file log kumulatif IIDD sesuai Bagian 8 spesifikasi.
- Menambahkan `vector_math: ^2.2.0` sebagai dependensi eksplisit di `pubspec.yaml`.
- Semua 8 unit test WFR lulus. E2E Integration Test lulus (`All tests passed!`).

| Tahap | Waktu Mulai (WIB) | Waktu Selesai (WIB) | Durasi |
|---|---|---|---|
| Baca Spesifikasi Revisi 3 | 10:15 | 10:22 | ~7 menit |
| Deploy ke Vercel (fdm-vd) | 10:22 | 10:28 | ~6 menit |
| Refaktor canvas_view.dart (InteractiveViewer) | 10:29 | 10:34 | ~5 menit |
| Fix lint errors & pub get | 10:34 | 10:36 | ~2 menit |
| Unit test (flutter test) | 10:36 | 10:37 | ~1 menit |
| E2E Integration Test (flutter drive) | 10:37 | 10:40 | ~3 menit |
| Build Web & Deploy Ulang ke Vercel | 10:40 | 10:43 | ~3 menit |
| Pembaruan Catatan & Commit | 10:43 | 10:45 | ~2 menit |
| **Total Sesi** | **10:29** | **10:45** | **~16 menit** |

### Sesi: Perbaikan Bug Multi-Touch Zoom & Penumpukan Spawn Node (2026-07-06)

**Ringkasan:**
- **Analisis Screenshot & Uji Coba**: Menganalisis hasil screenshot E2E secara headless/non-headless dan menemukan bahwa saat menambahkan node, koordinat spawn yang terlalu dekat `(1350–1550)` menyebabkan node saling menumpuk (overlap).
- **Bug Penyeretan Saat Zoom (InteractiveViewer)**: Menemukan bug di mana penyeretan (drag) node bergeser/drift dan berkumpul di kanan bawah kanvas ketika pengguna melakukan zoom-in/zoom-out. Hal ini disebabkan karena:
  1. Kalkulasi delta penyeretan sebelumnya hanya membagi dengan faktor skala (`delta / scale`), sehingga mengabaikan komponen translasi matriks.
  2. Gesture pinch-to-zoom (multitouch) secara keliru memicu event drag pada node ketika salah satu jari menyentuh bounding box node.
- **Solusi Teknis**:
  - Implementasi **Single-Pointer Tracking** dengan `_activePointerId` di `canvas_view.dart`. Hanya pointer pertama yang memulai drag yang diizinkan memindahkan node. Jika pointer kedua/tambahan menyentuh kanvas (pinch-to-zoom), sesi drag langsung dibatalkan via helper `_abortDrag()`.
  - Mengintegrasikan penanganan `onPointerCancel` pada `Listener` untuk pembersihan state drag yang andal.
  - Mengganti spawn posisi acak menjadi **Grid-based Spawn** (layout 4 kolom dengan jarak cell 280x220px) di `sidebar_left.dart` untuk mencegah penumpukan visual.
- **Verifikasi**:
  - Berhasil menjalankan E2E Integration Test headed Chrome (`All tests passed!`).
  - Menyalin dan mendokumentasikan 4 file screenshot hasil uji coba ke dalam `dokumentasi-pengembangan/screenshots/iterasi_1a/`.
  - Berhasil membuild ulang web Flutter dan mendeploy kembali ke Vercel ([fdm-vd.vercel.app](https://fdm-vd.vercel.app)).

| Tahap | Waktu Mulai (WIB) | Waktu Selesai (WIB) | Durasi |
|---|---|---|---|
| Analisis Screenshot & Identifikasi Bug | 10:45 | 10:48 | ~3 menit |
| Fix Drag Delta & Multi-touch Drag Abort | 10:48 | 10:52 | ~4 menit |
| Implementasi Grid-based Spawn Layout | 10:52 | 10:54 | ~2 menit |
| Run Flutter Analyze & Unit Tests | 10:54 | 10:56 | ~2 menit |
| Run Headed E2E Integration Test | 10:56 | 11:00 | ~4 menit |
| Copy Screenshots ke Repositori Dokumentasi | 11:00 | 11:02 | ~2 menit |
| Build Web & Deploy ke Vercel | 11:02 | 11:05 | ~3 menit |
| Pembaruan Dokumentasi IIDD & Commit Git | 11:05 | 11:08 | ~3 menit |
| **Total Sesi** | **10:45** | **11:08** | **~23 menit** |




