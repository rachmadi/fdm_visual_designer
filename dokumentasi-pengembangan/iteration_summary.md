# 📋 Iteration Summary — FDM Visual Designer
## Format: Kumulatif per Iterasi | Spesifikasi: Revisi 3 Final

> File ini merangkum pencapaian, masalah, dan lesson learned di setiap akhir iterasi.
> Dibuat setelah semua test lulus dan iterasi dinyatakan selesai.

---

## Format Ringkasan Iterasi

```
### Ringkasan [Iterasi X]
- **Tanggal Mulai**: 
- **Tanggal Selesai**: 
- **Durasi Aktual**: 
- **Status Akhir**: ✅ Selesai / ⚠️ Partial / ❌ Gagal
- **Fitur Selesai**: 
- **REQ yang Ditutup**: 
- **Test Coverage**: 
- **Lesson Learned**: 
```

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1a — Fondasi Canvas & Three-Node Architecture
### Status: ✅ Selesai
═══════════════════════════════════════════════════════════════════

### Target Iterasi 1a

| # | Target | Status |
|---|--------|--------|
| 1 | `InteractiveViewer` + `TransformationController` terimplementasi | ✅ |
| 2 | Inversi matriks untuk konversi koordinat screen → canvas | ✅ |
| 3 | Metamodel `StorageNode`, `EntityNode`, `QueryVectorNode` | ✅ |
| 4 | `CustomPainter` untuk ketiga jenis node | ✅ |
| 5 | State management Riverpod `Notifier` | ✅ |
| 6 | Integration test headed lulus | ✅ |

### Ringkasan Akhir Iterasi 1a

- **Tanggal Mulai**: 2026-06-27
- **Tanggal Selesai**: 2026-07-06
- **Durasi Aktual**: ~3,5 jam (kumulatif)
- **Status Akhir**: ✅ Selesai
- **Fitur Selesai**: Fondasi InteractiveViewer, inversi matriks delta drag, dan 3 metamodel dasar.
- **REQ yang Ditutup**: REQ-001 s.d. REQ-009
- **Keputusan Teknis Baru**: D-001 s.d. D-009 (lihat `decision_log.md`)
- **Lesson Learned**: InteractiveViewer dengan `constrained: false` mempertahankan ukuran rendering child.

---

═══════════════════════════════════════════════════════════════════
## ITERASI 1b — Node Interaction
### Status: ✅ Selesai
═══════════════════════════════════════════════════════════════════

- **Tanggal Mulai**: 2026-07-06
- **Tanggal Selesai**: 2026-07-06
- **Status Akhir**: ✅ Selesai
- **Durasi Aktual**: ~1,1 jam (kumulatif)
- **Target**: Add, Select, Move, Delete Node, and basic Edge routing.
- **Hasil Utama**: 
  - Fungsionalitas pembuatan node (SN & EN) via sidebar palette dengan grid-based spawn layout.
  - Penyeretan/geser node yang stabil pada semua tingkat zoom menggunakan matriks inversi canvas space.
  - Seleksi node via tap dengan outline highlight kuning/amber, serta deseleksi via tap area kosong canvas.
  - Penghapusan node terseleksi via Keyboard Shortcuts (`Del`) atau toolbar.
  - Edge routing dasar berupa garis hubung relasi lurus berarah panah.
- **E2E Test**: ✅ PASS (Headed Chrome E2E Test lulus 100%).
- **Lesson Learned**: Duplikasi teks antara tombol palette utama dan teks penjelasan pintasan keyboard kustom menyebabkan finder ambigu pada E2E test, diselesaikan dengan menggunakan pencarian selektif `.first`.

---

═══════════════════════════════════════════════════════════════════
## ITERASI 2a–7 — [Template]
═══════════════════════════════════════════════════════════════════

*[Blok-blok ini akan diisi pada iterasi yang sesuai]*

---

## Dashboard Progres Keseluruhan

| Iterasi | Status | Durasi Aktual | REQ Ditutup | Test |
|---------|--------|---------------|-------------|------|
| 1a | ✅ Selesai | ~3,5 jam | 9/9 | PASS |
| 1b | ✅ Selesai | ~1,1 jam | 5/5 | PASS |
| 2a | 🕒 Belum | — | 0/3 | — |
| 2b | 🕒 Belum | — | 0/2 | — |
| 3a | 🕒 Belum | — | 0/4 | — |
| 3b | 🕒 Belum | — | 0/3 | — |
| 4a | 🕒 Belum | — | 0/9 | — |
| 4b | 🕒 Belum | — | 0/4 | — |
| 5a | 🕒 Belum | — | 0/2 | — |
| 5b | 🕒 Belum | — | 0/2 | — |
| 6a | 🕒 Belum | — | 0/2 | — |
| 6b | 🕒 Belum | — | 0/4 | — |
| 7 | 🕒 Belum | — | 0/1 | — |

---

*Dokumen ini dibuat: 2026-07-06 | Diperbarui: otomatis setiap akhir iterasi*
