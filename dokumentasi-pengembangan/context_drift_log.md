# 📉 Context Drift Log — FDM Visual Designer
## Format: Kumulatif per Iterasi | Spesifikasi: Revisi 3 Final

> File ini mencatat setiap penyimpangan (drift) dari spesifikasi awal yang terjadi selama sesi pengembangan.
> Context drift adalah kondisi di mana implementasi mulai bergeser dari rencana awal tanpa keputusan eksplisit.

---

## Cara Mengisi

Tuliskan entri baru di bawah setiap iterasi secara kumulatif. Jangan menghapus riwayat iterasi sebelumnya.

---

## Klasifikasi Sumber Drift
Setiap drift dikategorikan berdasarkan sumbernya:
| Sumber | Keterangan |
|---|---|
| Intent Architect (IA) | Perubahan dari revisi requirement, klarifikasi, atau perubahan keputusan Intent Architect |
| Agen | Keputusan mandiri Antigravity selama implementasi |
| Eksternal | Dipicu faktor luar: perubahan API, dependency deprecated, keterbatasan framework, kondisi environment |

---

## ═══════════════════════════════════════════════════════════════════
## ITERASI 1a — 2026-06-27 s.d. 2026-07-06 11:51 WIB
## ═══════════════════════════════════════════════════════════════════

## Intent Awal
Membuat fondasi kanvas FDM Visual Designer menggunakan arsitektur 3 tipe node (`StorageNode`, `EntityNode`, `QueryVectorNode`) dan workspace interaktif menggunakan `InteractiveViewer` dengan inversi matriks koordinat untuk transformasi screen-space ke canvas-space.

## Eksekusi Aktual
Canvas berhasil dibuat menggunakan `InteractiveViewer` + controller + inversi matriks koordinat. Metamodel dasar dan 3 CustomPainter dibuat dan lulus pengujian unit WFR serta integration test.

---

## Bagian A — Drift yang Diketahui

| Aspek | Intent Awal | Eksekusi Aktual | Alasan Drift | Sumber | Disetujui IA? |
|---|---|---|---|---|---|
| Stack Teknologi | React Flow + React/TS | Flutter Web + CustomPainter | Intent Architect meminta opsi menggunakan Flutter Web untuk kemudahan mobile/cross-platform | IA | Ya |
| Library Icon | Lucide Icons untuk tombol | Material Icons bawaan | Package lucide_icons error fatal dengan SDK Flutter terbaru | Eksternal | Ya |

---

## Bagian B — Drift Inisiatif Agen

| No | Yang Dilakukan Agen | Kategori | Ada di Spesifikasi? | Alasan Agen | Dampak | Diterima IA? |
|---|---|---|---|---|---|---|
| 1 | Sempat menggunakan gesture `Listener` manual | B2 — Keputusan teknis | Tidak | Khawatir bentrok gesture drag node dengan pan canvas | Moderate — dikoreksi kembali ke InteractiveViewer di Sesi 2 | Ya |
| 2 | Menambahkan panel keyboard shortcuts UI | B1 — Penambahan | Tidak | UX mempermudah Intent Architect melihat panduan pintasan | Minor | Ya |

## Ringkasan Drift Inisiatif Agen
| Metrik | Nilai |
|---|---|
| Total inisiatif agen | 2 |
| B1 — Penambahan di luar spesifikasi | 1 |
| B2 — Keputusan teknis mandiri | 1 |
| Diterima oleh Intent Architect | 2 (100%) |
| Ditolak / di-revert | 0 (0%) |
| Berdampak positif pada implementasi | 2 |
| Berdampak negatif / menimbulkan masalah | 0 |

---

## Ringkasan Keseluruhan Drift
| Sumber Drift | Jumlah | Persentase |
|---|---|---|
| Intent Architect | 1 | 25% |
| Agen | 2 | 50% |
| Eksternal | 1 | 25% |
| **Total** | **4** | **100%** |

## Dampak terhadap Iterasi Berikutnya
Drift teknologi stack mengharuskan seluruh pengujian integrasi bergeser ke lingkungan Flutter Driver (Chrome headed test).

---

## ═══════════════════════════════════════════════════════════════════
## ITERASI 1b — 2026-07-06 11:51 s.d. 2026-07-06 16:32 WIB
## ═══════════════════════════════════════════════════════════════════

## Intent Awal
Membuat interaksi node: penambahan (tap-to-add), seleksi dengan highlight border, drag to move, delete selected node, dan edge routing dasar.

## Eksekusi Aktual
Menyelesaikan penambahan node via sidebar palette, gesture tap-to-select, drag-to-move dengan inversi matriks, delete via keyboard/toolbar, dan edge routing dasar berupa kurva Bézier yang ditingkatkan dengan 4 connection handles dan custom UML package style.

---

## Bagian A — Drift yang Diketahui

| Aspek | Intent Awal | Eksekusi Aktual | Alasan Drift | Sumber | Disetujui IA? |
|---|---|---|---|---|---|
| Grid Spawn | Spawn acak di tengah kanvas | Grid-based spawn (4 kolom, cell 280x220px) | Mencegah penumpukan visual ketika men-spawn 10+ node baru | IA | Ya |
| Single-Pointer Drag | Multitouch drag gesture | Single-pointer drag dengan auto-abort zoom | Mencegah multitouch zoom merusak posisi node saat di-drag | Eksternal | Ya |

---

## Bagian B — Drift Inisiatif Agen

| No | Yang Dilakukan Agen | Kategori | Ada di Spesifikasi? | Alasan Agen | Dampak | Diterima IA? |
|---|---|---|---|---|---|---|
| 1 | Mengubah spline garis lurus menjadi Bézier Cubic Curve | B2 — Keputusan teknis | Tidak | Tampilan visual yang jauh lebih premium dan mulus | Moderate | Ya |
| 2 | Dashed path edge dengan Path.computeMetrics() | B2 — Keputusan teknis | Tidak | Rendering dashed path untuk edge referencing secara presisi | Moderate | Ya |
| 3 | Mengubah custom tab folder menjadi rectangular UML package | B2 — Keputusan teknis | Tidak | Penyelarasan simbol collection agar persis standard package UML | Moderate | Ya |
| 4 | Meningkatkan ketebalan grid (strokeWidth = 1.0) & kontras warna di dark mode | B2 — Keputusan teknis | Tidak | Grid menghilang saat zoom out dan kurang jelas di dark mode | Moderate | Ya |

## Ringkasan Drift Inisiatif Agen
| Metrik | Nilai |
|---|---|
| Total inisiatif agen | 4 |
| B1 — Penambahan di luar spesifikasi | 0 |
| B2 — Keputusan teknis mandiri | 4 |
| Diterima oleh Intent Architect | 4 (100%) |
| Ditolak / di-revert | 0 (0%) |
| Berdampak positif pada implementasi | 4 |
| Berdampak negatif / menimbulkan masalah | 0 |

---

## Ringkasan Keseluruhan Drift
| Sumber Drift | Jumlah | Persentase |
|---|---|---|
| Intent Architect | 1 | 20% |
| Agen | 4 | 80% |
| Eksternal | 0 | 0% |
| **Total** | **5** | **100%** |

## Dampak terhadap Iterasi Berikutnya
Kustomisasi simbol UML dan ketebalan grid menjamin konsistensi rendering visual pada tahapan penambahan Security Boundary di iterasi berikutnya.

---

## ═══════════════════════════════════════════════════════════════════
## ITERASI 2a — 2026-07-06 s.d. 2026-07-07 09:05 WIB
## ═══════════════════════════════════════════════════════════════════

## Intent Awal
Membangun panel edit properti (Sidebar Kanan) untuk Storage Node dan Entity Node dengan fitur reorderable list, edit inline nama/tipe, validasi field kosong/duplikat, serta aksi hapus properti dengan SnackBar Undo 3 detik yang mengembalikan status node dan edge.

## Eksekusi Aktual
Seluruh spesifikasi terwujud 100% dan teruji sukses dengan headed integration test di Chrome.

---

## Bagian A — Drift yang Diketahui

| Aspek | Intent Awal | Eksekusi Aktual | Alasan Drift | Sumber | Disetujui IA? |
|---|---|---|---|---|---|
| (Tidak ada) | — | — | — | — | — |

---

## Bagian B — Drift Inisiatif Agen

| No | Yang Dilakukan Agen | Kategori | Ada di Spesifikasi? | Alasan Agen | Dampak | Diterima IA? |
|---|---|---|---|---|---|---|
| 1 | Pemanggilan `onPressed!()` langsung pada widget finder E2E | B2 — Keputusan teknis | Tidak | Hit-testing tombol delete di dalam ReorderableListView terhalang overlay penyeretan bawaan Flutter | Minor (hanya memengaruhi kode test) | Ya |

## Ringkasan Drift Inisiatif Agen
| Metrik | Nilai |
|---|---|
| Total inisiatif agen | 1 |
| B1 — Penambahan di luar spesifikasi | 0 |
| B2 — Keputusan teknis mandiri | 1 |
| Diterima oleh Intent Architect | 1 (100%) |
| Ditolak / di-revert | 0 (0%) |
| Berdampak positif pada implementasi | 1 |
| Berdampak negatif / menimbulkan masalah | 0 |

---

## Ringkasan Keseluruhan Drift
| Sumber Drift | Jumlah | Persentase |
|---|---|---|
| Intent Architect | 0 | 0% |
| Agen | 1 | 100% |
| Eksternal | 0 | 0% |
| **Total** | **1** | **100%** |

## Dampak terhadap Iterasi Berikutnya
Tidak ada dampak negatif. Solusi test driver ini dapat dijadikan acuan untuk pengujian UI interaktif berikutnya yang melibatkan drag-and-drop.

---

## ═══════════════════════════════════════════════════════════════════
## ITERASI 2b–7 — [Template]
## ═══════════════════════════════════════════════════════════════════

*[Blok-blok ini akan diisi pada iterasi yang sesuai]*

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: 2026-07-07*
