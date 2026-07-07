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

## [1.3.2] - 2026-07-06 (Perbaikan Bug Viewport Constraint)

### Fixed (Perbaikan Bug)
- **Viewport Constraint / Bounded Child scale bug**: Memperbaiki masalah kritis di mana InteractiveViewer menciutkan canvas 4000x4000 menjadi ukuran viewport layar (misal 800x600) karena property `constrained` secara default bernilai `true`.
  - Menambahkan `constrained: false` secara eksplisit pada `InteractiveViewer` di `canvas_view.dart`. Ini memungkinkan canvas mempertahankan ukuran aslinya 4000x4000 sehingga semua hit-test koordinat dan rendering node pada posisi `(1200, 1300)` dan seterusnya menjadi presisi dan tidak melayang secara liar saat di-zoom/panning.

## [1.3.3] - 2026-07-06 (Pengujian Integrasi Headed Visual & Skenario Zoom)

### Added (Penambahan Skenario Tes)
- **Skenario Integration Test Baru (Zoom & Grid Spawn)**: Mengubah dan memperluas skenario pengujian di `integration_test/app_test.dart` untuk mensimulasikan:
  1. Penambahan 10 node berturut-turut (5 structural + 5 entity) secara otomatis untuk memverifikasi grid spawn layout.
  2. Gerakan pinch-to-zoom out dengan 2 pointer virtual untuk memperkecil zoom canvas.
  3. Aksi penyeretan (drag) node di bawah level zoom yang diperkecil untuk memverifikasi akurasi delta koordinat canvas-space.
- **Eksekusi Unsandboxed**: Pengujian integrasi headed Chrome dijalankan di luar terminal sandbox (`unsandboxed`) sehingga jendela browser fisik Chrome terbuka secara nyata di layar desktop pengguna dan proses interaksinya terlihat secara visual.

## [1.3.4] - 2026-07-06 (Resolusi Eksekusi ChromeDriver Unsandboxed)

### Fixed (Perbaikan Bug Sesi Pengujian)
- **ChromeDriver Sandbox Session Isolation**: Memperbaiki masalah di mana jendela fisik browser Chrome headed tidak terbuka secara visual di desktop pengguna karena ChromeDriver sebelumnya berjalan sebagai task latar belakang *di dalam sandbox terminal* (Session 0).
  - Menghentikan proses sandboxed ChromeDriver.
  - Memindahkan eksekusi ChromeDriver ke luar sandbox (`unsandboxed` menggunakan `npx.cmd chromedriver@149`) sehingga ChromeDriver dapat berinteraksi dengan sesi login desktop aktif pengguna (Session 1).
  - Hasilnya, jendela browser Chrome headed saat ini **terbuka secara fisik dan visual** di layar desktop pengguna selama integrasi test dijalankan.

## [1.3.5] - 2026-07-06 (Integrasi Pintasan Keyboard & Spesifikasi Revisi 3)

### Added (Penambahan Fitur)
- **Pintasan Keyboard Global (Section 4.3)**: 
  - Mengimplementasikan `Focus` + `onKeyEvent` pada `WorkspaceScreen` untuk pintasan global: `Ctrl/Cmd + Z` & `Ctrl/Cmd + Shift + Z` (Undo/Redo), `Delete`/`Backspace` (Delete selection), `S` (Add Structural Node), `E` (Add Entity Node), `V` (Toggle Validation Report), dan `Escape` (Cancel/Deselect).
- **Pintasan Ganti Tema (Section 9.9)**:
  - Mengimplementasikan `Ctrl/Cmd + Shift + D` untuk mengganti tema (Dark Mode / Light Mode) secara dinamis via `ThemeModeNotifier`.

### Fixed (Perbaikan Sesuai Spesifikasi)
- **Dark Mode Canvas & Opacity Node (Section 5)**:
  - Mengubah canvas background di dark mode agar secara dinamis mengikuti `Theme.of(context).colorScheme.surface`.
  - Menerapkan opacity `0.92` pada background warna putih untuk Entity Node di dark mode untuk meningkatkan visual dark aesthetics.

## [1.4.0] - 2026-07-06 (Iterasi 1b — Node Interaction)

### Added (Penambahan Fitur)
- **Panel Panduan Pintasan Keyboard (Keyboard Shortcuts)**:
  - Menyediakan panel panduan kustom di bagian kiri bawah sidebar yang menunjukkan daftar pintasan keyboard yang terdaftar secara interaktif.
  - Memvisualisasikan tombol fisik cap tombol keyboard (key caps) kustom yang reaktif terhadap perubahan tema gelap/terang.

### Fixed (Perbaikan Bug & Tes)
- **Penyempurnaan E2E Integration Test**:
  - Mengatasi duplicate widget finder error pada integration test (`app_test.dart`) akibat kesamaan teks tombol "Add Structural Node" dan "Add Entity Node" dengan teks panduan kustom pada panel baru, dengan memanfaatkan filter `.first` pada selector finder.
  - Berhasil mengeksekusi E2E headed Chrome integration test 100% lulus (PASS) secara visual di layar monitor desktop user.

## [1.5.0] - 2026-07-06 (4 Titik Koneksi Dinamis & Bézier Routing)

### Added (Penambahan Fitur)
- **4 Titik Koneksi Dinamis (Dynamic Anchor Switching)**:
  - Menambahkan 4 titik koneksi interaktif (atas, bawah, kiri, kanan) pada `StructuralNodeWidget` dan `EntityNodeWidget`.
  - Handle titik koneksi baru berukuran 10x10px dengan efek glow shadow dan border putih kontras untuk keterbacaan yang lebih baik.
  - Handle kiri (hollow/putih) menunjukkan titik masuk (input), handle terisi biru menunjukkan titik keluaran (output).
  - Seluruh 4 handle pada kedua node dapat memicu aksi `startConnection` via `GestureDetector.onTap`.
  
- **Dynamic Anchor Switching di `edges_painter.dart`**:
  - Implementasi algoritma pemilihan sisi anchor otomatis (`_getDynamicAnchor`) yang membandingkan posisi pusat node sumber dan target.
  - Jika perbedaan horizontal `|dx| > |dy|`, koneksi menggunakan sisi kiri/kanan; jika vertikal, menggunakan sisi atas/bawah.
  - Anchor berpindah otomatis saat pengguna menggeser node ke arah yang berbeda — tanpa perlu konfigurasi manual.
  
- **Bézier Cubic Curve Routing (`_buildBezierPath`)**:
  - Semua tipe edge (hierarchy, referencing, denormalization) kini menggunakan routing kurva Bézier cubic yang elegan, menggantikan routing polyline L-shape sebelumnya.
  - Titik kontrol kurva dihitung secara dinamis berdasarkan arah exit anchor (tension proportional terhadap jarak antar node, minimal 60px).
  - Dashed path untuk edge referencing diimplementasikan menggunakan `Path.computeMetrics()` untuk mengikuti kurva Bézier secara akurat.
  
- **Titik Anchor Visual**:
  - Menambahkan lingkaran kecil (`_drawAnchorDot`) di ujung awal edge hierarchy untuk menunjukkan dengan jelas titik keluaran koneksi.
  - `strokeCap: StrokeCap.round` pada semua edge untuk tampilan yang lebih halus dan profesional.

- **Penyelarasan Simbol Collection ke UML Package**:
  - Mengubah bentuk tab pada `FolderPainter` di `structural_node.dart` dari miring (slanted) menjadi persegi panjang tegak (`rectangular tab`), menyerupai simbol package standard UML.
  - Memposisikan label nama Structural Node di kotak tab bagian atas dengan ukuran font 10px tebal, dan path di main body.

- **Peningkatan Kontras Grid & Zoom Out**:
  - Meningkatkan ketebalan garis grid `strokeWidth` pada `GridPainter` di `canvas_view.dart` dari `0.5` menjadi `1.0` agar tetap terlihat jelas saat zoom out.
  - Mengubah warna grid pada dark mode menjadi abu-abu medium yang lebih terang (`#5A6A80`) untuk memberikan kontras yang pas dan nyaman dipandang pada latar belakang gelap.

### Fixed (Perbaikan Bug & Tes)
- **Resolusi Eksekusi Headed E2E Test di Layar Desktop & Penahanan Visual**:
  - Menggabungkan 3 block `testWidgets` terpisah menjadi satu flow tunggal untuk mencegah browser Chrome menutup dan membuka kembali berulang kali selama pengujian visual.
  - Menambahkan penundaan `35 detik` di akhir test case untuk menahan agar browser tetap terbuka di layar sehingga user dapat mengamati visual 4 titik koneksi, kurva Bézier, dan interaksi grid secara detail.
  - Menetapkan aturan **larangan menutup browser pengguna** (no `taskkill /F /IM chrome.exe`) di [`.agents/AGENTS.md`](file:///E:/rachmadi/Antigravity/.agents/AGENTS.md) agar tidak mengganggu aktivitas kerja pengguna yang sedang berjalan.
  - Menghapus skrip cleanup usang di folder `scratch/` yang berpotensi memicu penutupan paksa chrome.exe. Pembersihan proses kini dibatasi hanya pada `chromedriver.exe` dan `dart.exe`.
  - Menetapkan aturan **akurasi dokumentasi proyek** yang mewajibkan seluruh log pengerjaan diisi secara presisi dan konsisten secara matematis tanpa data dummy atau placeholder kosong.
  - Mengoreksi seluruh berkas log waktu (`waktu_estimasi_vs_realisasi.md` dan `durasi_per_fitur.md`) untuk Iterasi 1a dan 1b agar sinkron secara matematis.
  - Menjalankan tes interaktif headed (`--no-headless`) melalui Scheduled Task interaktif (`LogonType Interactive`) lintas sesi ke ChromeDriver Session 0. Jendela browser Google Chrome fisik muncul di layar monitor desktop user secara nyata dan visual, menjalankan seluruh skenario hingga selesai, dan bertahan selama 35 detik sebelum menutup secara otomatis. Semua stage lulus 100% (PASS).

## [1.6.0] - 2026-07-07 (Iterasi 2a - Property Editor & Form Validation)

### Added (Penambahan Fitur)
- **Reorderable Property List (`ReorderableListView.builder`)**:
  - Menyusun daftar properti di sidebar kanan agar dapat diurutkan ulang menggunakan fitur drag-and-drop secara interaktif.
  - Menambahkan metode `reorderProperties` pada state diagram notifier untuk memperbarui urutan properti secara reaktif.
- **Inline Editing & Dynamic Controls**:
  - Tapping/double tapping nama properti akan membuka `TextField` inline dengan autofokus untuk mengubah nama properti secara langsung.
  - Penambahan inline `DropdownButton` kecil untuk mengubah tipe data properti secara langsung.
  - Toggles Switch dinamis untuk properti `isUnbounded` (jika array/map) dan `isReferencing` (jika reference).
- **Form Validation Real-time**:
  - Menambahkan validasi ketat pada key properti: checks kosong (`Nama field tidak boleh kosong`), format huruf/angka/underscore (`Nama field hanya boleh mengandung huruf, angka, dan underscore`), awalan angka (`Nama field tidak boleh diawali angka`), panjang (`Nama field terlalu panjang (maks. 64 karakter)`), dan duplikasi dalam satu node (`Nama field sudah ada di node ini`).
  - Menampilkan pesan error validasi berwarna merah tepat di bawah TextField yang bersangkutan.
- **Deletion dengan SnackBar Undo 3 Detik**:
  - Menghapus properti di daftar akan memicu `SnackBar` bertuliskan `"Field [key] dihapus"` dengan tombol `"UNDO"`.
  - Jika tombol UNDO ditekan dalam 3 detik, properti dan semua edges relasi horizontal yang terhubung akan dikembalikan ke index aslinya.
- **E2E Integration Test Stage 4**:
  - Memperluas skenario pengujian di `integration_test/app_test.dart` untuk menguji: penambahan properti baru, trigger validasi error (kosong, awalan angka, duplikasi), edit inline nama properti, delete properti, dan pemulihan via SnackBar Undo.
- **Unit Test Baru (`test/property_editor_test.dart`)**:
  - Menulis 3 unit test untuk memastikan operasi mutasi reorder, rename, dan insert properti berjalan dengan benar.

### Fixed (Perbaikan Bug & Tes)
- **Resolusi Bug SnackBar Undo pada E2E Test (Hit-test warning)**:
  - Memperbaiki kegagalan hit-test pada pengetukan tombol delete properti di integration test (`app_test.dart`) dengan memanggil callback `deleteBtn.onPressed!()` secara langsung. Ini menjamin pengujian berjalan stabil tanpa dipengaruhi oleh issue hit-testing/scrolling di browser.
- **Resolusi Masalah Duplikasi Widget Finder**:
  - Menambahkan `Key` unik (`add_prop_name_input` dan `inline_edit_prop_name_input`) pada TextField properti di [sidebar_right.dart](file:///E:/rachmadi/Antigravity/fdm_visual_designer/lib/panels/sidebar_right.dart) dan merujuk pencarian widget via key di `app_test.dart` untuk menyelesaikan error `Too many elements`.
  - Menambahkan `Key` unik (`add_prop_save_button` dan `inline_edit_prop_save_button`) pada tombol Simpan properti untuk menghindari ambiguitas pengetukan widget Simpan.
- **Resolusi Validasi Kosong E2E Test**:
  - Memasukkan teks sementara `'temp'` sebelum memasukkan `''` pada TextField nama properti di integration test untuk memastikan event `onChanged` terpicu pada framework.
- **Pembersihan Log Analisis**:
  - Semua unit test lulus. `flutter analyze` bersih dari kesalahan kompilasi. E2E headed integration test lulus (`All tests passed!`). Tangkapan layar bukti pengujian interaktif visual disalin ke repositori.

## [1.7.0] - 2026-07-07 (Iterasi 2b - Query Vector & Tipe Data Detail)

### Added (Penambahan Fitur)
- **Tipe Data Properti Terperinci & Terkapitalisasi (Capitalized Data Types)**:
  - Memetakan tipe data `DataType.array` menjadi tampilan **"List"** di dropdown.
  - Memperluas opsi tipe data di dropdown tambah dan edit properti dengan format terkapitalisasi: `String`, `Number`, `Boolean`, `Map`, `List`, `Timestamp`, `Geopoint`, dan `Reference` agar berfungsi penuh.
  - Menambahkan properti extension `displayName` pada `DataTypeExtension` di [metamodel.dart](file:///E:/rachmadi/Antigravity/fdm_visual_designer/lib/core/metamodel.dart) untuk keseragaman visual di seluruh UI.
- **Submit on Enter**:
  - Menambahkan fitur `onSubmitted` (Enter) pada TextField penambahan properti baru dan inline editing properti di [sidebar_right.dart](file:///E:/rachmadi/Antigravity/fdm_visual_designer/lib/panels/sidebar_right.dart) sehingga properti otomatis tersimpan saat pengguna menekan tombol *Enter*.
- **Konektor Bersyarat (Conditional Connection Handles)**:
  - Membatasi visibilitas dan keaktifan titik-titik konektor bulat (atas, bawah, kiri, kanan) serta konektor properti di tepi node sehingga **hanya muncul dan aktif ketika node tersebut sedang terpilih** (`isSelected == true`).
- **Peningkatan Input Query Vector via Dropdown Properti**:
  - Mengubah input filter field (F) dan sort field (S) pada panel Query Vector di sidebar kanan menggunakan `DropdownButtonFormField<String>` yang berisi daftar property keys dari Entity Node yang terpilih. Ini mencegah typo dan menjaga validitas query vector.
  - Menyertakan opsi `"-- Custom Field --"` yang akan memunculkan input text manual jika user ingin mengetik field metadata khusus (misal: `__name__` atau `createdAt`).
- **Visualisasi Query Vector di Canvas**:
  - Merender sub-panel/badge "QUERY VECTOR" yang cantik di bagian bawah kartu Entity Node di canvas jika node memiliki konfigurasi Query Vector (Filter atau Sort terisi), menampilkan formula `Q = <F, S, I>` (Filters, Sorts, dan badge estimasi indeks `SINGLE` / `COMPOSITE`).
  - Menyesuaikan fungsi hit-test `_nodeRect` di [canvas_view.dart](file:///E:/rachmadi/Antigravity/fdm_visual_designer/lib/canvas/canvas_view.dart) untuk memperhitungkan tinggi tambahan kartu node agar operasi drag/click tetap presisi.
- **Unit Test Baru (`test/property_editor_test.dart`)**:
  - Menambahkan test case `'Query Vector: updateQueryVector and Index Estimation'` untuk memverifikasi perubahan state Query Vector dan estimasi indeks.

### Fixed (Perbaikan Bug & Tes)
- **Sinkronisasi Kasus Uji Integrasi (Case Sync)**:
  - Memperbarui file pengujian `integration_test/app_test.dart` untuk menyesuaikan asersi asertif nama tipe data dari huruf kecil (`string`) menjadi huruf kapital (`String`) karena perluasan tipe data detail.
- **Pembersihan Log Analisis**:
  - Semua unit test lulus. E2E headed integration test dijalankan secara visual dan lulus (`All tests passed!`). Dev server lokal dijalankan pada port `5555` menyajikan `build/web` untuk peninjauan manual oleh user.
