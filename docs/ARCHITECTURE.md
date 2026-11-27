# Arsitektur KosFinder

## 1. Komponen aplikasi

Pola yang digunakan adalah **Screen → Provider → Repository → Supabase**.
Dependensi mengalir satu arah agar logika UI, state, dan akses data terpisah.

- **Screens (Flutter):** menampilkan daftar/filter/detail kos, login/daftar,
  form tambah/edit, penghapusan, dan About. Screen hanya membaca state dari
  Provider serta mengirim aksi pengguna. Dibutuhkan oleh **US01–US05** dan
  About wajib sesuai `AGENTS.md`.
- **Provider:** menyimpan state loading, data, error, sesi pemilik, serta
  validasi form; memberi notifikasi perubahan ke Screen. Dibutuhkan oleh
  **US01–US05**.
- **Repository:** satu pintu untuk query daftar/detail, autentikasi, insert,
  update, dan delete; menerjemahkan error koneksi menjadi error aplikasi.
  Dibutuhkan oleh **US01–US05**.
- **Supabase:** Auth untuk email/password, Postgres untuk data kos, dan RLS
  untuk membatasi perubahan berdasarkan `owner_id`. Dibutuhkan oleh
  **US01–US05**.

## 2. Layar dan alur navigasi

- **Daftar Kos:** layar awal publik → filter wilayah/area, harga, fasilitas
  → **Detail Kos** (**US01**).
- **Detail Kos:** menampilkan data kamar dan status otomatis (**US02**).
- **Masuk / Daftar Pemilik:** dari aksi pemilik → setelah berhasil ke
  **Kelola Kos** (**US03**).
- **Kelola Kos:** daftar kos milik pemilik → **Form Kos** untuk tambah/edit;
  aksi hapus kembali menghapus dari daftar publik (**US04–US05**).
- **Form Kos:** validasi data dan jumlah kamar sebelum simpan (**US04**).
- **About:** menampilkan `2415051002 - Luh Desy Putri Yanti` sesuai aturan
  proyek.

Pencari dapat memakai Daftar Kos dan Detail Kos tanpa login. Rute pemilik
memerlukan sesi Supabase Auth.

## 3. Rencana database dan akses

Migration: `supabase/migrations/001_init.sql`.

### Tabel `public.kos`

- `id uuid` — primary key.
- `owner_id uuid` — wajib, foreign key ke `auth.users(id)`.
- `name text` — nama kos.
- `address_area text` — alamat atau area di sekitar Undiksha.
- `price_monthly bigint` — harga Rupiah per bulan, wajib angka >= 0.
- `facilities text[]` — fasilitas.
- `total_rooms integer` — total kamar, wajib > 0.
- `available_rooms integer` — kamar tersedia, wajib 0 sampai total kamar.
- `status text` — kolom generated: **Tersedia** jika tersedia > 0,
  **Penuh** jika 0.
- `created_at timestamptz` — waktu pembuatan.

`owner_id` menghubungkan setiap kos dengan pemiliknya. Anonim dan pengguna
terautentikasi boleh membaca kos. Hanya pengguna terautentikasi yang boleh
menambah kos dengan `owner_id = auth.uid()`, serta mengubah atau menghapus
baris yang `owner_id`-nya sama dengan `auth.uid()`. RLS menolak akses pemilik
lain. Constraint database menegakkan aturan jumlah kamar.

## 4. Konfigurasi

URL project dan anon key dibaca saat build/run, bukan ditulis di source code:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://<project>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

Aplikasi membaca `String.fromEnvironment('SUPABASE_URL')` dan
`String.fromEnvironment('SUPABASE_ANON_KEY')`. Hanya anon key yang boleh
dipakai aplikasi; `service_role` key tidak pernah digunakan.

## 5. Rilis

1. Jalankan `flutter analyze` dan `flutter test`.
2. Build APK:
   `flutter build apk --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`.
3. Buat tag versi pada commit yang dirilis dan push tag ke GitHub.
4. Buat GitHub Release dari tag tersebut dan lampirkan
   `build/app/outputs/flutter-apk/app-release.apk`.

## 6. Package

- `provider` — state management untuk Provider pada **US01–US05**.
- `supabase_flutter` — Supabase Auth, query Postgres, dan sesi untuk
  **US01–US05**.

Navigasi, validasi dasar, dan HTTP tidak menambah package karena tersedia di
Flutter SDK atau ditangani oleh `supabase_flutter`.
