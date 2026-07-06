# 🙋 Human Intervention Log — FDM Visual Designer
## Format: Kumulatif per Sesi | Spesifikasi: Revisi 3 Final

> File ini mencatat semua intervensi yang dilakukan pengguna selama sesi pengembangan.
> Intervensi adalah perubahan arah, koreksi, permintaan pengulangan, atau keputusan yang mengubah jalannya implementasi.

---

## Definisi Intervensi

**Intervensi** adalah setiap tindakan pengguna yang:
- Mengubah rencana atau arah implementasi yang sedang berjalan
- Meminta agen mengulangi atau membatalkan langkah
- Memberikan koreksi teknis atau arsitektur
- Menambah atau menghapus requirement di tengah iterasi
- Meminta penundaan atau percepatan jadwal

---

## Tabel Intervensi Pengguna

| No | Tanggal | Waktu | Iterasi | Deskripsi Intervensi | Dampak | Jenis |
|----|---------|-------|---------|----------------------|--------|-------|
| 1 | 2026-06-27 | 11:15 | Pra-1a | Pengguna meminta migrasi dari React/TypeScript ke **Flutter Web** di tengah inisialisasi proyek | Pembersihan total file React; reinisialisasi proyek Flutter; penyusunan ulang rencana implementasi | Perubahan Stack |
| 2 | 2026-07-06 | 10:30 | 1a (Setup) | Pengguna meminta pembuatan 13 file log dokumentasi IIDD sesuai spesifikasi Revisi 3 Final sebelum implementasi dimulai | Pembuatan folder `dokumentasi-pengembangan/` dan 13 file log; menunda implementasi kode utama | Permintaan Dokumentasi |
| 3 | 2026-07-06 | 10:45 | 1a | Pengguna melaporkan bug zoom drift di mana 10 node berkumpul di kanan bawah saat di-zoom | Memperbaiki matrix inversi delta drag, membatalkan drag jika terdeteksi multi-touch, dan menonaktifkan constraint InteractiveViewer | Koreksi Teknis |
| 4 | 2026-07-06 | 11:04 | 7 | Pengguna mengidentifikasi headed browser tidak muncul secara fisik di desktop | Memindahkan eksekusi ChromeDriver dan `flutter drive` menjadi `unsandboxed` agar tampil secara nyata | Koreksi Teknis |
| 5 | 2026-07-06 | 11:30 | 7 | Pengguna melaporkan pintasan keyboard tidak berfungsi dan berbenturan dengan browser | Mendaftarkan handler `HardwareKeyboard` global dan mencegat event browser default pada `keydown` | Koreksi Teknis |
| 6 | 2026-07-06 | 16:12 | 1b | Pengguna meminta kustomisasi simbol collection menyerupai UML package dan grid diperjelas warnanya pada dark mode | Mengubah FolderPainter menjadi rectangular UML package tab dan grid menjadi strokeWidth = 1.0 (Color 0xFF5A6A80) | Perubahan Desain |
| 7 | 2026-07-06 | 16:20 | 1b | Pengguna meminta penempatan label structural node diletakkan di kotak bagian atas | Memposisikan nama structural node secara absolut di tab persegi atas dan path di bagian main body | Perubahan Desain |
| 8 | 2026-07-06 | 16:24 | 1b | Pengguna menegaskan larangan menutup browser pengguna (tidak boleh taskkill chrome.exe) | Menghapus skrip cleanup usang dan membatasi cleanup hanya pada chromedriver.exe/dart.exe | Koreksi Teknis |
| 9 | 2026-07-06 | 16:34 | 1b | Pengguna menegaskan pentingnya akurasi dan konsistensi seluruh berkas dokumentasi log | Mengoreksi data log waktu dan log context drift agar sinkron secara matematis | Koreksi Teknis |
| 10 | 2026-07-06 | 16:35 | 1b | Pengguna meminta perbaikan baris kosong di tabel RTM yang memecah visual table | Menghapus baris kosong pemecah format pada berkas RTM | Koreksi Teknis |
| 11 | 2026-07-06 | 16:37 | 1b | Pengguna melaporkan data log context drift belum diisi dengan benar | Menulis ulang context_drift_log.md sesuai spesifikasi Bagian 8.3 | Koreksi Teknis |
| 12 | 2026-07-06 | 16:41 | 1b | Pengguna meminta penggantian istilah \"pengguna\" menjadi \"Intent Architect\" di context drift log | Mengganti seluruh terminologi pengguna/user menjadi Intent Architect | Koreksi Teknis |
| 13 | 2026-07-06 | 16:43 | 1b | Pengguna meminta conversation log dibuat lengkap sejak hari pertama | Menulis ulang conversation_log.md mulai dari sesi 27 Juni 2026 | Koreksi Teknis |
| 14 | 2026-07-06 | 16:46 | 1b | Pengguna meminta decision log dibuat lengkap sejak hari pertama | Menulis ulang decision_log.md mulai dari sesi 27 Juni 2026 | Koreksi Teknis |

---

## Legenda Jenis Intervensi

| Jenis | Keterangan |
|-------|------------|
| Perubahan Stack | Perubahan teknologi atau framework utama |
| Perubahan Arsitektur | Perubahan desain sistem atau pola implementasi |
| Penambahan Requirement | REQ baru yang tidak ada di spesifikasi awal |
| Koreksi Teknis | Agen melakukan kesalahan dan pengguna meminta perbaikan |
| Permintaan Dokumentasi | Permintaan membuat/memperbarui dokumen |
| Perubahan Prioritas | Mengubah urutan iterasi atau fitur |
| Pembatalan Fitur | Fitur yang direncanakan dibatalkan |
| Lainnya | Intervensi yang tidak masuk kategori di atas |

---

## Ringkasan Statistik Intervensi

| Jenis | Jumlah | Dampak Rata-rata |
|-------|--------|------------------|
| Perubahan Stack | 1 | Tinggi |
| Perubahan Arsitektur | 0 | — |
| Perubahan Desain | 2 | Sedang |
| Penambahan Requirement | 0 | — |
| Koreksi Teknis | 10 | Sedang |
| Permintaan Dokumentasi | 1 | Rendah |
| Perubahan Prioritas | 0 | — |
| Pembatalan Fitur | 0 | — |
| **Total** | **14** | — |

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: setiap kali terjadi intervensi*
