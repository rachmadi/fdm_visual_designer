# 📊 Derived Interaction Dataset — Intent-Action-Validation Episode (IAVE)
## Format: Unit Analisis Interaksi | Spesifikasi: Revisi 3 Final

> Berkas ini menyimpan derived dataset berupa episode interaksi antara Intent Architect (IA) dan Agen untuk kebutuhan analisis penelitian tata kelola Agentic AI.
> Verbatim chat log tetap dipertahankan sebagai bukti primer di `verbatim_conversation_log.md`.

---

## Konsep Intent-Action-Validation Episode (IAVE)

Satu episode dimulai ketika Intent Architect menyampaikan intent baru atau mengubah intent sebelumnya. Episode berakhir ketika intent tervalidasi, ditolak, ditunda, atau digantikan oleh intent baru.

### Struktur Entri IAVE

```markdown
### IAVE-XXX: [Judul Episode]
- **Episode ID**: IAVE-XXX
- **Source Conversation**: [Tautan / referensi sesi chat]
- **IA Intent**: [Deskripsi intent/perubahan dari Intent Architect]
- **Agent Interpretation**: [Interpretasi agen terhadap intent tersebut]
- **Agent Planned Action**: [Tindakan yang direncanakan agen]
- **Agent Executed Action**: [Tindakan teknis nyata yang dieksekusi agen]
- **Autonomous Decision**: [Keputusan mandiri yang diambil agen selama episode]
- **Context Drift**: [Ada/tidaknya drift dan kaitannya ke DFT-XXX]
- **Human Intervention**: [Ada/tidaknya intervensi dan kaitannya ke INT-XXX]
- **Validation**: [Metode verifikasi dan kaitannya ke REQ-XXX / test result]
- **Outcome**: [Hasil akhir episode: Berhasil / Ditolak / Ditunda / Diganti]
- **Authority Holder**: [Intent Architect / Agent / Shared]
- **Related Requirements**: [Daftar ID Requirement terdampak]
- **Related Decisions**: [Daftar ID Keputusan terdampak]
- **Related Commits**: [Daftar hash commit terkait]
```

---

## ═══════════════════════════════════════════════════════════════════
## DAFTAR EPISODE INTERAKSI (IAVE) — TEMPLATE
## ═══════════════════════════════════════════════════════════════════

*Bagian ini akan diisi secara berkala untuk keperluan analisis penelitian.*

---

*Dokumen ini dibuat: 2026-07-11*
