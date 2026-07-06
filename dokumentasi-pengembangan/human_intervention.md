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
| Penambahan Requirement | 0 | — |
| Koreksi Teknis | 0 | — |
| Permintaan Dokumentasi | 1 | Rendah |
| Perubahan Prioritas | 0 | — |
| Pembatalan Fitur | 0 | — |
| **Total** | **2** | — |

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: setiap kali terjadi intervensi*
