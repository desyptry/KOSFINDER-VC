# Aturan Kerja Agen AI — KosFinder

## Konteks proyek dan dokumen acuan

KosFinder adalah aplikasi Flutter untuk mencari dan mengelola informasi kos
di sekitar Kampus Undiksha, Singaraja. Backend menggunakan Supabase.

Dokumen acuan:

- [PRD](docs/PRD.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Tasks](docs/TASKS.md)

Jika dokumen acuan belum tersedia, jangan mengarang isinya; tanyakan atau
gunakan keputusan yang sudah disepakati dalam permintaan pengguna.

## Cara kerja

- Kerjakan satu task per permintaan.
- Jangan mengubah file di luar scope task.
- Rencanakan terlebih dahulu sebelum melakukan perubahan besar.
- Pilih solusi yang paling sederhana dan mudah dirawat.
- Jangan menambah package/dependency tanpa persetujuan pengguna.

## Teknologi

- Flutter
- Provider
- Supabase

## Keamanan

- Jangan menaruh key, password, atau rahasia lain di dalam kode.
- `service_role` key tidak pernah dipakai di aplikasi.
- Hak akses wajib ditegakkan dengan Row Level Security (RLS) di Supabase.

## Git

- Satu task menghasilkan satu commit.
- Pesan commit wajib menyebutkan ID task.
- Jangan mengubah atau menghapus pekerjaan yang tidak terkait task aktif.

## Definition of Done

Task dianggap selesai jika:

- `flutter analyze` bersih.
- `flutter test` lulus.
- Aplikasi dijalankan pada device yang tersedia.
- Laporan menyebutkan pemeriksaan yang belum dapat diuji.

## Informasi About

Halaman About aplikasi wajib menampilkan:

**2415051002 - Luh Desy Putri Yanti**
