# Daftar Tugas (Task Checklist): FDM Visual Designer

## [1.0.0] - Fondasi Utama (Lengkap & Terverifikasi)

- [x] Inisialisasi Proyek Flutter Web
  - [x] Scaffold folder dan setup file config
  - [x] Menambahkan dependensi Riverpod dan FilePicker
  - [x] Mengatur aset dan icon Material Design
- [x] Metamodel & State Management (Iterasi 1)
  - [x] Menulis tipe data FDM di `lib/core/metamodel.dart`
  - [x] Membangun state diagram notifier dengan stack Undo/Redo di `lib/core/state.dart`
- [x] Tampilan Node & Canvas (Iterasi 1)
  - [x] Implementasi folder-tab `StructuralNodeWidget`
  - [x] Implementasi rounded-card `EntityNodeWidget`
  - [x] Membangun grid workspace `CanvasView` dengan zoom/pan
- [x] Relasi Horizontal & Edges (Iterasi 2)
  - [x] Menggambar relasi hierarchy
  - [x] Menggambar relasi referencing dengan dashed line & asterisk (*)
  - [x] Menggambar relasi denormalization dengan double arrowhead & inline label
  - [x] Membuat relation builder untuk menyambungkan properti ke node target
  - [x] Implementasi interaktif Click-to-Connect menggunakan handle bulat di canvas
  - [x] Penulisan dan eksekusi E2E Integration Testing (non-headless) menggunakan ChromeDriver
- [x] Mesin Validasi 8 Well-Formedness Rules (Iterasi 3)
  - [x] Menulis 8 rule semantik di `lib/engine/validator.dart`
  - [x] Mengintegrasikan validator reaktif dengan Riverpod state
  - [x] Menulis 8 unit test di `test/validator_test.dart` dan lolos `flutter test`
  - [x] Menampilkan badge error/warning di canvas node
- [x] Physical Guardrails & Query Vectors (Iterasi 4)
  - [x] Menambahkan toggles unbounded (⚠️ 1MB) dan high frequency (⚡ >1/s)
  - [x] Merender physical badges otomatis pada node
  - [x] Membuat panel Query Vector & estimator Composite Index di sidebar kanan
- [x] Security Boundaries & Mode RTDB (Iterasi 5)
  - [x] Implementasi resizable `SecurityBoundaryWidget` (PUBLIC & PRIVATE/OWNER)
  - [x] Integrasi rule 6 (validasi overlap boundary)
  - [x] Toggle RTDB mode di toolbar (menonaktifkan alternation rule R1, mengizinkan nested maps)
- [x] Ekspor/Impor & Polishing (Iterasi 6)
  - [x] Ekspor & Impor skema diagram JSON FDM v1 (serta parser pintar fallback impor data database mentah)
  - [x] Ekspor gambar resolusi tinggi 2x (PNG) via RepaintBoundary
  - [x] Menyusun panel lapor kesalahan (Validation Report) di sidebar kanan
  - [x] Memperbaiki seluruh error kompilasi dan sukses build produksi (`flutter build web`)
  - [x] Resolusi Bug Penyeretan Node & Konflik Gesture Arena (Final)
  - [x] Deploy ke Vercel dengan alias fdm-vd.vercel.app
  - [x] Refaktor `canvas_view.dart` ke arsitektur `InteractiveViewer` + inversi matriks sesuai Revisi 3 Final Bagian 2.2
  - [x] Inisialisasi folder `dokumentasi-pengembangan/` dengan 13 file log kumulatif IIDD
  - [x] Perbaikan bug zoom & penyeretan node liar (Multi-touch drag abort & canvas-space delta)
  - [x] Implementasi Grid-based Spawn Layout untuk mencegah penumpukan 10+ node baru
  - [x] Perbaikan bug viewport constraint (constrained: false) untuk menjaga kestabilan posisi node saat di-zoom/panning
  - [x] Eksekusi Unsandboxed Headed E2E Integration Test secara interaktif dan visual di layar desktop user
  - [x] Eksekusi Unsandboxed ChromeDriver untuk memunculkan jendela browser Chrome fisik secara nyata di layar desktop user
  - [x] Implementasi Pintasan Keyboard Global (Ctrl+Z, Ctrl+Shift+Z, Delete/Backspace, S, E, V, Escape)
  - [x] Pencegahan Konflik Pintasan Keyboard dengan Aksi Default Browser (Ctrl+D, Ctrl+E, Ctrl+L)
  - [x] Implementasi Mode Tema Dinamis Light/Dark Mode reaktif (Ctrl+Shift+D) & Opacity Node Gelap
  - [x] Penambahan Panel Panduan Pintasan Keyboard (Keyboard Shortcuts) di sidebar kiri bawah
  - [x] Penyempurnaan E2E Integration Test dengan Finder selektif (.first) untuk mendeteksi tombol palette secara akurat
  - [x] Implementasi 4 titik koneksi (atas, bawah, kiri, kanan) interaktif pada StructuralNode & EntityNode
  - [x] Dynamic Anchor Switching — anchor berpindah otomatis berdasarkan posisi relatif node saat digeser
  - [x] Bézier Cubic Curve Routing untuk semua tipe edge (hierarchy, referencing, denormalization)
  - [x] Dashed Bézier path untuk edge referencing menggunakan Path.computeMetrics()
  - [x] Kustomisasi simbol Structural Node (Collection) menjadi rectangular UML package tab
  - [x] Penempatan label nama Structural Node di kotak tab bagian atas
  - [x] Peningkatan visibilitas & kontras garis grid pada dark mode saat zoom out (strokeWidth = 1.0)

## [1.6.0] - Property Editor & Form Validation (Iterasi 2a - Selesai)

- [x] Rombak UI list properti di sidebar kanan menggunakan `ReorderableListView`
- [x] Implementasi inline editing (TextField & Dropdown) untuk nama dan tipe properti aktif di sidebar
- [x] Implementasi penambahan properti baru menggunakan inline form dengan tombol `+ Tambah property`
- [x] Tambahkan validasi error nama properti (kosong, alfanumerik/underscore, diawali angka, duplikasi, batas 64 karakter)
- [x] Implementasi SnackBar delete dengan tombol Undo berdurasi 3 detik
- [x] Penulisan unit test untuk mutasi state properti (reordering, insertion, renaming)
- [x] Penulisan E2E integration test Stage 4 untuk memverifikasi fungsionalitas pengeditan properti, validasi, dan SnackBar Undo

## Rencana Selanjutnya (Peningkatan Masa Depan)

- [ ] Integrasi Algoritma Auto-Layout otomatis berbasis Dagre (Dart port)
- [ ] Penambahan visual Minimap di sudut kanan bawah canvas
