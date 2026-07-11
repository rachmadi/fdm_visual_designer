# 🔧 Log Koreksi Dokumentasi Historis (Historical Corrections Log)
## Format: Koreksi Keterlacakan Proyek | Spesifikasi: Revisi 3 Final

> Berkas ini mencatat setiap perbaikan/koreksi yang dilakukan terhadap berkas dokumentasi historis jika ditemukan kesalahan pencatatan di masa depan.
> Sesuai ketentuan, data asli di sejarah commit Git tidak dihapus, namun koreksi dicatat secara formal di sini.

---

## Prosedur Koreksi Dokumentasi

Jika ditemukan kesalahan dokumentasi historis:
1. Identifikasi informasi yang salah dan tentukan berkas sumbernya.
2. Identifikasi bukti faktual (evidence) yang benar dari log chat, commit, atau kode.
3. Catat entri koreksi menggunakan format di bawah ini.
4. Perbaiki seluruh berkas dokumentasi terdampak.
5. Jalankan Cross-Artifact Integrity Check dan pastikan status `PASS`.
6. Lakukan commit Git dengan pesan yang jelas bahwa ini merupakan koreksi dokumentasi.

### Struktur Entri Koreksi

```markdown
### COR-XXX: [Judul Koreksi]
- **Correction ID**: COR-XXX
- **Tanggal**: YYYY-MM-DD
- **Incorrect Statement**: [Pernyataan salah yang tercatat sebelumnya]
- **Correct Statement**: [Pernyataan benar yang menggantikannya]
- **Evidence**: [Bukti pendukung kebenaran pernyataan baru]
- **Affected Artifacts**: [Daftar berkas dokumentasi yang diperbaiki]
- **Repair Commit**: [Hash commit perbaikan]
- **Integrity Check Result**: [PASS / FAIL]
```

---

## ═══════════════════════════════════════════════════════════════════
## DAFTAR KOREKSI DOKUMENTASI HISTORIS
## ═══════════════════════════════════════════════════════════════════

### COR-001: Koreksi Istilah Arsitektur Node (Three-Node ke Two-Node with Query Vector)
- **Correction ID**: COR-001
- **Tanggal**: 2026-07-11
- **Incorrect Statement**: Beberapa berkas menyebutkan “Three-Node Architecture” dengan `StorageNode`, `EntityNode`, dan `QueryVectorNode` sebagai 3 tipe node kanvas yang mandiri.
- **Correct Statement**: Menggunakan istilah “Two-Node Architecture with Query Vector”. Kanvas aktual hanya merender `StorageNode` (structural) dan `EntityNode`. Query vector diintegrasikan sebagai data properti dan badge visual di dalam Entity Node, bukan sebagai node terpisah.
- **Evidence**: Implementasi kelas `FDMNode` di `lib/core/metamodel.dart` yang hanya memiliki `NodeType { structural, entity }`, serta `entity_node.dart` yang menangani query vector internal.
- **Affected Artifacts**: `README.md`, `requirement_traceability_matrix.md`, `estimated_vs_actual_time.md`, `feature_duration_log.md`, `interactive_test_log.md`, `iteration_summary.md`, `validation_log.md`, `context_drift_log.md`, `decision_log.md`, `error_log.md`, `conversation_log.md`.
- **Repair Commit**: `9f7e605`, `6dd902f`
- **Integrity Check Result**: PASS

### COR-002: Penyelarasan Durasi Aktual Iterasi 3a
- **Correction ID**: COR-002
- **Tanggal**: 2026-07-11
- **Incorrect Statement**: `iteration_summary.md` mencatat durasi aktual Iterasi 3a sebesar "0 m".
- **Correct Statement**: Durasi aktual Iterasi 3a adalah "56 m", sinkron dengan rincian di `estimated_vs_actual_time.md` dan `feature_duration_log.md` (akumulasi pengerjaan dari audit RTM, pengujian, sinkronisasi log, dan pendaftaran Scheduled Task E2E).
- **Evidence**: Rekap log waktu Sesi 13 & Sesi 14 pada berkas `estimated_vs_actual_time.md` dan rekap di dashboard progres ringkas.
- **Affected Artifacts**: `iteration_summary.md` (durasi aktual Iterasi 3a).
- **Repair Commit**: `6dd902f`
- **Integrity Check Result**: PASS

### COR-003: Penyelarasan Status Requirement pada RTM
- **Correction ID**: COR-003
- **Tanggal**: 2026-07-11
- **Incorrect Statement**: Matriks RTM mencatat REQ-024 s.d. REQ-035, REQ-036, dan REQ-038 sebagai "Belum dimulai".
- **Correct Statement**: Memperbarui status requirement tersebut ke status riil: `Partially Implemented` untuk REQ-024 s.d. REQ-026 (dengan catatan gap), `Technically Validated` untuk REQ-027 s.d. REQ-034 (lulus unit test), `Implemented` untuk REQ-035 (WFR Badges UI, dengan catatan gap), dan `Implemented` untuk REQ-036 & REQ-038.
- **Evidence**: Keberadaan source code `lib/canvas/nodes/security_boundary.dart`, `lib/engine/validator.dart`, `lib/export/serializer.dart`, `lib/ui/toolbar.dart`, dan unit test `test/validator_test.dart` yang lulus uji.
- **Affected Artifacts**: `requirement_traceability_matrix.md` (legenda status, tabel matriks, dan tabel rekap ringkasan).
- **Repair Commit**: `6dd902f`
- **Integrity Check Result**: PASS

---

*Dokumen ini dibuat: 2026-07-11*
