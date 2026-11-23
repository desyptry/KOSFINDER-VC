# KosFinder

Aplikasi Flutter untuk mencari kos di sekitar Kampus Undiksha, Singaraja.

## Menjalankan aplikasi

URL dan anon key Supabase dibaca melalui `--dart-define`. Gunakan nilai palsu
berikut sebagai contoh:

```powershell
flutter run -d chrome `
  --dart-define=SUPABASE_URL=https://example.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=example-anon-key
```

Jangan menaruh `service_role` key atau kredensial asli di source code.
