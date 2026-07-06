# 🏛️ Decision Log — FDM Visual Designer
## Format: Kumulatif per Iterasi | Spesifikasi: Revisi 3 Final

> File ini mencatat seluruh keputusan teknis dan arsitektur penting selama pengembangan.
> Setiap keputusan harus disertai alasan, alternatif yang ditolak, dan dampak implementasi.

---

## Format Entri Keputusan

```
### D-XXX: [Judul Keputusan]
- **Tanggal**: YYYY-MM-DD
- **Dibuat oleh**: [Intent Architect / Agen / Bersama]
- **Konteks**: [Mengapa keputusan ini perlu diambil?]
- **Keputusan**: [Apa yang diputuskan?]
- **Alternatif yang Ditolak**: [Opsi lain yang dipertimbangkan]
- **Alasan Pemilihan**: [Mengapa opsi ini dipilih?]
- **Dampak**: [Dampak terhadap arsitektur / implementasi]
- **Iterasi Terdampak**: [1a, 1b, dst.]
```

---

## ═══════════════════════════════════════════════════════════════════
## ITERASI 1a — Fondasi Canvas & Three-Node Architecture
## ═══════════════════════════════════════════════════════════════════

### D-001: Migrasi Arsitektur Stack Teknologi ke Flutter Web
- **Tanggal**: 2026-06-27
- **Dibuat oleh**: Bersama (Intent Architect & Agen)
- **Konteks**: Rencana awal proyek menggunakan React/TS + React Flow. Intent Architect meminta opsi implementasi lintas platform (mobile-friendly).
- **Keputusan**: Mengubah seluruh platform pengembangan ke Flutter Web dengan kustomisasi kanvas menggunakan CustomPainter dan InteractiveViewer.
- **Alternatif yang Ditolak**: Mempertahankan React Flow (karena keterbatasan porting mobile native kelak).
- **Alasan Pemilihan**: Flutter Web memberikan kemudahan berbagi basis kode yang sama (single codebase) untuk porting aplikasi mobile native di masa mendatang.
- **Dampak**: Pembersihan kode React dan inisialisasi ulang proyek Flutter Web baru.
- **Iterasi Terdampak**: 1a

---

### D-002: Riverpod Notifier untuk State Management
- **Tanggal**: 2026-06-27
- **Dibuat oleh**: Agen
- **Konteks**: Memerlukan state management diagram yang stabil dan modular. Versi Riverpod terbaru mendepresiasi `StateNotifier`.
- **Keputusan**: Menerapkan kelas `Notifier<T>` dari Riverpod v3 modern untuk manajemen data diagram.
- **Alternatif yang Ditolak**: Menggunakan `StateProvider` atau `ChangeNotifier` bawaan.
- **Alasan Pemilihan**: Riverpod `Notifier` menjamin keamanan tipe (type-safety), performa rendering modular, dan kemudahan dalam penulisan aksi state.
- **Dampak**: Penggunaan `ref.watch` dan akses mutable state harus dikelola via Notifier.
- **Iterasi Terdampak**: 1a

---

### D-003: Penggunaan Material Icons Bawaan
- **Tanggal**: 2026-06-27
- **Dibuat oleh**: Agen
- **Konteks**: Dependensi library `lucide_icons` mengalami error fatal saat build karena mencoba meng-extend kelas `IconData` yang bersifat `final` di SDK Flutter terbaru.
- **Keputusan**: Menghapus `lucide_icons` secara total dan menggunakan standard Material Icons bawaan Flutter.
- **Alternatif yang Ditolak**: Mem-patch library Lucide secara manual (tidak berkelanjutan).
- **Alasan Pemilihan**: Menghilangkan risiko dependensi pihak ketiga dan menjamin kelancaran build jangka panjang.
- **Dampak**: Penggunaan kode ikon bermigrasi ke `Icons.*`.
- **Iterasi Terdampak**: 1a

---

### D-004: Inversi Matriks Transformasi Koordinat Canvas
- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Bersama (Spesifikasi Revisi 3 & Agen)
- **Konteks**: Panning/zooming manual dengan Listener mengalami drift offset saat Intent Architect mengeklik atau menyeret node di canvas.
- **Keputusan**: Menggunakan wrapper `InteractiveViewer` bawaan dan mengalikan koordinat pointer dengan inversi matriks transformasi (`Matrix4.inverted()`) untuk mengkonversi dari screen-space ke canvas-space secara akurat.
- **Alternatif yang Ditolak**: Perhitungan offset manual terpisah (tidak akurat).
- **Alasan Pemilihan**: Matematika inversi matriks menjamin konversi posisi pointer yang 100% akurat tanpa drift kumulatif pada tingkat zoom apa pun.
- **Dampak**: Seluruh callback deteksi interaksi node wajib dikonversi via inversi matriks.
- **Iterasi Terdampak**: 1a

---

### D-005: Single-Pointer Tracking untuk Menghindari Konflik Multi-Touch Zoom
- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Agen
- **Konteks**: Saat menggunakan pinch-to-zoom (dua jari), event pointer dari jari kedua memicu deteksi drag node secara salah, membuat node melayang liar.
- **Keputusan**: Hanya memproses drag jika id kursor cocok dengan `_activePointerId` (pointer pertama). Drag dibatalkan otomatis (`_abortDrag()`) jika pointer kedua terdeteksi masuk.
- **Alternatif yang Ditolak**: Menonaktifkan zoom saat kursor berada di atas node (mengurangi navigasi Intent Architect).
- **Alasan Pemilihan**: Standar industri untuk mengutamakan zoom/pan navigasi kanvas saat multi-touch aktif.
- **Dampak**: Zoom/pan stabil dan node tidak lagi melompat liar.
- **Iterasi Terdampak**: 1a

---

### D-006: Grid-Based Spawn Layout
- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Agen
- **Konteks**: Posisi spawn acak awal di tengah memicu penumpukan node-node baru secara berturut-turut.
- **Keputusan**: Merancang grid spawn layout (4 kolom, ukuran cell 280x220px) dengan offset dinamis di `sidebar_left.dart`.
- **Alternatif yang Ditolak**: Spawn di koordinat `(0,0)` statis.
- **Alasan Pemilihan**: Menjamin visualisasi node terdistribusi rapi di area viewport saat ditambahkan.
- **Dampak**: Penambahan 10+ node berjalan teratur dan rapi.
- **Iterasi Terdampak**: 1a

---

### D-007: Area Kanvas Non-Constrained (constrained: false)
- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Agen
- **Konteks**: Parameter `constrained: true` (default) pada `InteractiveViewer` memaksa area kanvas anak (4000x4000) menciut mengikuti layar.
- **Keputusan**: Mengubah parameter secara eksplisit menjadi `constrained: false` pada `InteractiveViewer` di `canvas_view.dart`.
- **Alternatif yang Ditolak**: Menggunakan ukuran canvas kecil (membatasi ruang kerja diagram).
- **Alasan Pemilihan**: Membiarkan kanvas mempertahankan ukuran aslinya sehingga seluruh rendering grid dan koordinat node stabil.
- **Dampak**: Grid kanvas ter-render merata dan koordinat bernilai besar berada di dalam batas hit-test yang valid.
- **Iterasi Terdampak**: 1a

---

### D-008: Global HardwareKeyboard Handler
- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Agen
- **Konteks**: Focus node keyboard pintasan (delete, undo/redo) hilang saat Intent Architect mengeklik kanvas kosong di luar node.
- **Keputusan**: Mendaftarkan handler pintasan keyboard secara terpusat di `WorkspaceScreen` menggunakan `HardwareKeyboard.instance.addHandler`.
- **Alternatif yang Ditolak**: Menggunakan widget `Focus` biasa dengan autofocus (tidak andal di web).
- **Alasan Pemilihan**: `HardwareKeyboard` menangkap event input di tingkat services root, menjamin responsivitas pintasan.
- **Dampak**: Pintasan keyboard selalu responsif di area mana pun.
- **Iterasi Terdampak**: 1a

---

### D-009: Intersepsi Browser KeyDown (Prevent Default)
- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Agen
- **Konteks**: Pintasan diagram (Ctrl+D untuk delete properti, Ctrl+E untuk export) bentrok dengan bookmark dan search bar browser.
- **Keputusan**: Memanggil `event.preventDefault()` menggunakan listener `html.window.onKeyDown`.
- **Alternatif yang Ditolak**: Mengubah pintasan diagram ke tombol non-standar.
- **Alasan Pemilihan**: Menjaga standar User Experience (UX) industri diagram editor.
- **Dampak**: Fungsi tombol bawaan browser diabaikan khusus selama aplikasi FDM terbuka.
- **Iterasi Terdampak**: 1a

---

## ═══════════════════════════════════════════════════════════════════
## ITERASI 1b — Node Interaction & Style Polishing
## ═══════════════════════════════════════════════════════════════════

### D-010: Spline Bézier Cubic Curve untuk Edge Routing
- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Agen
- **Konteks**: Arah panah default berupa garis lurus kaku yang tumpang tindih dengan node, mengurangi kualitas estetika.
- **Keputusan**: Mengubah rumus edges drawing menjadi kurva Bézier cubic (`Path.cubicTo`) dengan menghitung dua titik kontrol proporsional di depan sisi anchor.
- **Alternatif yang Ditolak**: Routing polyline L-shape (terlalu kaku untuk model database non-relasional).
- **Alasan Pemilihan**: Memberikan kesan modern, premium, dan memperjelas arah alur relasi.
- **Dampak**: Tampilan visual edge berlekuk halus dan premium.
- **Iterasi Terdampak**: 1b

---

### D-011: Dynamic Anchor Switching (4 Connection Handles)
- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Agen
- **Konteks**: Ujung edge terkunci pada satu koordinat node saja, sehingga saat node digeser, garis panah menembus bodi node.
- **Keputusan**: Memasang 4 connection handles (atas, bawah, kiri, kanan) dan melakukan kalkulasi jarak terdekat secara dinamis saat node digeser (*Dynamic Anchor Switching*).
- **Alternatif yang Ditolak**: Koordinat anchor statis di tengah node.
- **Alasan Pemilihan**: Menjamin ujung panah selalu menempel rapi di tepi bodi terdekat dari node tetangganya.
- **Dampak**: Fleksibilitas pergeseran node sangat dinamis dan rapi.
- **Iterasi Terdampak**: 1b

---

### D-012: Kustomisasi Simbol Collection menjadi Rectangular UML Package
- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Bersama (Intent Architect & Agen)
- **Konteks**: Simbol structural node (collection) awal menggunakan folder biasa dengan garis miring (slanted). Intent Architect meminta diselaraskan agar serupa simbol package pada UML.
- **Keputusan**: Mengubah path drawing pada `FolderPainter` menjadi tab persegi panjang tegak (`rectangular tab`), memposisikan nama secara absolut di tab atas (10px tebal), dan path di bodi utama.
- **Alternatif yang Ditolak**: Mempertahankan ikon folder miring standar.
- **Alasan Pemilihan**: Konsistensi dengan spesifikasi notasi UML standar industri untuk struktur package/collection.
- **Dampak**: Tampilan visual structural node berubah menjadi simbol package UML yang presisi.
- **Iterasi Terdampak**: 1b

---

### D-013: Peningkatan Ketebalan Grid & Kontras Warna Mode Gelap
- **Tanggal**: 2026-07-06
- **Dibuat oleh**: Agen
- **Konteks**: Grid berukuran `0.5` stroke menghilang total saat canvas di-zoom out, dan garis grid kurang jelas terlihat saat dark mode diaktifkan.
- **Keputusan**: Meningkatkan `strokeWidth` grid ke `1.0` dan mengubah warna grid gelap menjadi abu-abu medium kontras tinggi (`const Color(0xFF5A6A80)`).
- **Alternatif yang Ditolak**: Menggunakan warna grid putih terang (merusak estetika kenyamanan dark mode).
- **Alasan Pemilihan**: Menjaga visibilitas grid pada zoom level rendah tanpa mengorbankan kenyamanan mata dalam mode gelap.
- **Dampak**: Grid tetap terlihat jelas saat di-zoom out pada dark mode.
- **Iterasi Terdampak**: 1b

---

## ═══════════════════════════════════════════════════════════════════
## ITERASI 2a–7 — [Template]
## ═══════════════════════════════════════════════════════════════════

*[Blok-blok ini akan diisi pada iterasi yang sesuai]*

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: otomatis setiap akhir sesi*
