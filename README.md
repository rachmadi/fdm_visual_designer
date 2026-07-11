# 🎨 FDM Visual Designer

Aplikasi berbasis web untuk merancang skema Firebase Database (Firestore & Realtime Database) menggunakan pemodelan visual interaktif yang taat aturan WFR (Well-Formedness Rules). Built with **Flutter Web** and **Riverpod**.

*   **URL Aplikasi Live**: [https://fdm-vd.vercel.app](https://fdm-vd.vercel.app)
*   **Repositori GitHub**: [https://github.com/rachmadi/fdm_visual_designer](https://github.com/rachmadi/fdm_visual_designer)

---

## 🚀 Fitur Utama
*   **Workspace Kanvas Interaktif**: Workspace 4000x4000px dengan zoom/pan smooth (`InteractiveViewer`) dan rendering grid dinamis.
*   **Two-Node Architecture with Query Vector**: Representasi node kustom untuk `StorageNode` (UML Package) dan `EntityNode` (Document Card), di mana query vector diintegrasikan sebagai properti di dalam Entity Node.
*   **Edge Routing Bézier & Dynamic Anchor**: Garis relasi melengkung (Bézier Cubic) dengan pendeteksian sisi anchor terdekat (Dynamic Anchor Switching).
*   **8 Well-Formedness Rules Engine**: Sistem validasi semantik real-time yang memverifikasi integritas database non-relasional.
*   **Firestore & Realtime Database Mode**: Toggle tema visual reaktif dan keyboard shortcuts komprehensif.

---

## 📊 Indeks Dokumentasi Pengembangan (IIDD)

Seluruh berkas dokumentasi log pengembangan proyek dapat diakses langsung melalui tautan indeks relatif berikut:

### 📋 Perencanaan & Ringkasan Progres
*   [time_estimation.md](dokumentasi-pengembangan/time_estimation.md) — Rangkuman estimasi waktu pengerjaan per iterasi sesuai spesifikasi.
*   [estimated_vs_actual_time.md](dokumentasi-pengembangan/estimated_vs_actual_time.md) — Perbandingan matematis estimasi vs durasi pengerjaan riil.
*   [feature_duration_log.md](dokumentasi-pengembangan/feature_duration_log.md) — Log pencatatan durasi detail per fitur secara granular.
*   [iteration_summary.md](dokumentasi-pengembangan/iteration_summary.md) — Ringkasan pencapaian dan *lesson learned* di setiap akhir iterasi.

### 🎯 Requirements & Keputusan Desain
*   [requirement_traceability_matrix.md](dokumentasi-pengembangan/requirement_traceability_matrix.md) — Matriks ketertelusuran requirement (RTM) dari spesifikasi ke kode implementasi.
*   [decision_log.md](dokumentasi-pengembangan/decision_log.md) — Log keputusan arsitektural dan desain teknis penting sepanjang proyek.
*   [context_drift_log.md](dokumentasi-pengembangan/context_drift_log.md) — Pencatatan penyimpangan (drift) spesifikasi awal (Bagian A & B).

### 💬 Riwayat & Aktivitas Sesi
*   [conversation_log.md](dokumentasi-pengembangan/conversation_log.md) — Log percakapan kronologis antara Intent Architect dan Agen sejak hari pertama.
*   [verbatim_conversation_log.md](dokumentasi-pengembangan/verbatim_conversation_log.md) — Log percakapan verbatim word-for-word lengkap antara Intent Architect dan Agen sejak awal proyek.
*   [iave_dataset.md](dokumentasi-pengembangan/iave_dataset.md) — Derived dataset penelitian tata kelola AI berbasis episode (IAVE).
*   [human_intervention.md](dokumentasi-pengembangan/human_intervention.md) — Log pencatatan intervensi, koreksi, dan keputusan Intent Architect.
*   [commit_history.md](dokumentasi-pengembangan/commit_history.md) — Log riwayat commit git kumulatif per iterasi.

### 🧪 Pengujian & Validasi
*   [validation_log.md](dokumentasi-pengembangan/validation_log.md) — Hasil audit validasi (analyze, unit test, integration test).
*   [interactive_test_log.md](dokumentasi-pengembangan/interactive_test_log.md) — Log hasil pengujian headed integration test interaktif di browser.
*   [error_log.md](dokumentasi-pengembangan/error_log.md) — Daftar error, bug runtime/compile, dan langkah resolusinya.
*   [documentation_corrections.md](dokumentasi-pengembangan/documentation_corrections.md) — Log perbaikan dokumentasi historis.

---

## 🛠️ Menjalankan Secara Lokal

1.  Pastikan SDK Flutter sudah terpasang.
2.  Jalankan perintah berikut untuk mengunduh packages:
    ```bash
    flutter pub get
    ```
3.  Jalankan aplikasi di browser:
    ```bash
    flutter run -d chrome
    ```

---

## 🧪 Prosedur Headed Integration Test (Uji Coba Visual)

Pengujian interaktif visual dijalankan dengan langkah berikut:

1.  Jalankan ChromeDriver 149 (sesuai browser Chrome terinstall) pada port 4444:
    ```bash
    npx chromedriver@149 --port=4444
    ```
2.  Jalankan suite pengujian visual:
    ```bash
    flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome --no-headless --browser-dimension=1600x1024
    ```
