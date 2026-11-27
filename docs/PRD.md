# PRD KosFinder

## 1. Masalah dan tujuan terukur

Informasi kos sekitar Kampus Undiksha, Singaraja tersebar di media sosial,
grup WhatsApp, dan rekomendasi lisan. Pencari sulit membandingkan harga,
fasilitas, serta ketersediaan kamar; pemilik juga sulit memperbarui jumlah
kamar yang tersedia.

Tujuan versi 1:
- Pencari dapat menemukan kos berdasarkan wilayah/area, harga, dan
  fasilitas tanpa membuat akun.
- Setiap kos menampilkan harga per bulan, fasilitas, jumlah kamar tersedia,
  dan status ketersediaan.
- Pemilik dapat mengelola kos miliknya sendiri dan memperbarui ketersediaan
  kamar tanpa mengubah data milik pemilik lain.

## 2. Pengguna

- **Pencari kos:** mahasiswa atau masyarakat yang mencari kos sekitar
  Kampus Undiksha, Singaraja; tidak perlu login.
- **Pemilik kos:** pengguna yang mendaftarkan akun email dan password untuk
  mempublikasikan serta mengelola kos miliknya.

## 3. Scope versi 1

### Masuk
- Aplikasi Android Flutter dengan backend Supabase.
- Daftar kos publik, pencarian nama wilayah/area, filter harga serta
  fasilitas, dan detail kos.
- Registrasi dan masuk pemilik dengan email + password tanpa verifikasi email.
- Pemilik menambah, mengubah, dan menghapus kos miliknya sendiri.
- Data kos: nama, alamat/area, harga Rupiah per bulan, fasilitas, total kamar,
  dan jumlah kamar tersedia.
- Validasi `0 <= kamar tersedia <= total kamar`.
- Status otomatis **Tersedia** jika kamar tersedia > 0 dan **Penuh** jika 0.

### Tidak masuk

Pembayaran online, chat, ulasan/rating, rekomendasi AI, verifikasi identitas
pemilik, upload foto, peta, dan fitur lain di luar daftar scope versi 1.

## 4. NFR

- **Keamanan:** Supabase Row Level Security harus menolak perubahan atau
  penghapusan kos oleh akun selain pemiliknya; uji dengan dua akun pemilik.
- **Keandalan:** kegagalan koneksi menampilkan pesan yang dapat dipahami dan
  tidak menghapus data lokal/form yang belum berhasil disimpan; uji dengan
  memutus koneksi saat memuat dan menyimpan.
- **Kemudahan pakai:** pencari dapat membuka daftar dan detail tanpa login;
  pemilik dapat menyelesaikan alur daftar/masuk dan simpan kos melalui
  validasi yang jelas; uji dengan pengguna baru.
- **Performa:** daftar hasil dan detail mulai tampil paling lambat 3 detik
  pada koneksi normal dengan data uji versi 1.
- **Privasi:** hanya data kos yang dipublikasikan yang terlihat publik;
  kredensial tidak ditampilkan atau disimpan di luar mekanisme autentikasi
  Supabase; uji melalui akses publik dan akun berbeda.

## 5–6. User story dan acceptance criteria

### US01 — Melihat dan menemukan kos

**Sebagai pencari kos, saya ingin melihat, mencari, dan menyaring daftar kos,
agar dapat membandingkan pilihan di sekitar Undiksha.**

- **US01-AC1:** Given data kos tersedia, When pencari membuka daftar dan
  menerapkan wilayah/area, harga, atau fasilitas, Then hanya kos yang
  sesuai kriteria yang ditampilkan.
- **US01-AC2:** Given tidak ada kos atau hasil filter kosong, When pencari
  membuka atau menyaring daftar, Then aplikasi menampilkan keadaan kosong
  yang informatif tanpa error.
- **US01-AC3:** Given koneksi gagal, When pencari membuka atau menyaring
  daftar, Then aplikasi menampilkan pesan koneksi gagal dan tidak menampilkan
  data seolah-olah berhasil dimuat.

### US02 — Melihat detail dan ketersediaan kos

**Sebagai pencari kos, saya ingin melihat detail kos dan ketersediaan kamar,
agar dapat menilai apakah kos masih sesuai kebutuhan.**

- **US02-AC1:** Given pencari tidak login dan kos tersedia, When pencari
  membuka detail, Then nama, alamat/area, harga bulanan, fasilitas, total
  kamar, kamar tersedia, dan status tampil.
- **US02-AC2:** Given kamar tersedia lebih dari 0, When detail ditampilkan,
  Then statusnya **Tersedia**; given kamar tersedia 0, Then statusnya
  **Penuh**.
- **US02-AC3:** Given koneksi gagal atau kos tidak ditemukan, When pencari
  membuka detail, Then aplikasi menampilkan pesan yang sesuai dan tidak
  menampilkan detail palsu.

### US03 — Mendaftar dan masuk sebagai pemilik

**Sebagai pemilik kos, saya ingin mendaftar dan masuk dengan email serta
password, agar dapat mengelola kos saya.**

- **US03-AC1:** Given email dan password valid yang belum terdaftar, When
  pemilik mengirim formulir daftar, Then akun dibuat dan pemilik dapat masuk
  tanpa verifikasi email.
- **US03-AC2:** Given kredensial salah atau kosong, When pemilik mencoba
  masuk, Then aplikasi menampilkan validasi/gagal masuk dan tidak membuat sesi
  pemilik.
- **US03-AC3:** Given koneksi gagal saat daftar atau masuk, When formulir
  dikirim, Then aplikasi menampilkan pesan koneksi gagal dan tidak
  menampilkan proses sebagai berhasil.

### US04 — Menambah dan mengubah kos milik sendiri

**Sebagai pemilik kos, saya ingin menambah dan mengubah data kos milik saya,
agar informasi harga, fasilitas, dan ketersediaan tetap terbaru.**

- **US04-AC1:** Given pemilik masuk dan data valid, When pemilik menyimpan kos,
  Then kos langsung tampil pada daftar publik sebagai miliknya.
- **US04-AC2:** Given kamar tersedia negatif atau melebihi total kamar, When
  pemilik menyimpan atau mengubah kos, Then penyimpanan ditolak dengan pesan
  validasi.
- **US04-AC3:** Given kamar tersedia > 0 atau = 0, When pemilik menyimpan
  perubahan, Then status otomatis menjadi **Tersedia** atau **Penuh**.
- **US04-AC4:** Given koneksi gagal saat menyimpan, When pemilik mengirim
  perubahan, Then aplikasi menampilkan kegagalan dan perubahan tidak
  dianggap tersimpan.
- **US04-AC5:** Given pemilik mencoba mengubah kos milik orang lain, When
  permintaan dikirim, Then Supabase menolaknya dan data kos tetap tidak
  berubah.

### US05 — Menghapus kos milik sendiri

**Sebagai pemilik kos, saya ingin menghapus kos milik saya, agar daftar
publik tidak memuat kos yang sudah tidak saya kelola.**

- **US05-AC1:** Given pemilik masuk dan kos adalah miliknya, When penghapusan
  dikonfirmasi, Then kos tidak lagi tampil pada daftar publik.
- **US05-AC2:** Given pemilik mencoba menghapus kos milik orang lain, When
  permintaan dikirim, Then Supabase menolaknya dan kos tetap tampil.
- **US05-AC3:** Given koneksi gagal saat menghapus, When pemilik mengonfirmasi,
  Then aplikasi menampilkan pesan gagal dan kos tidak dianggap terhapus.

## Pertanyaan yang masih ambigu

- Daftar fasilitas yang tersedia serta apakah fasilitas dipilih dari daftar
  tetap atau diisi sebagai teks belum ditentukan.
- Format alamat/area yang wajib diisi belum ditentukan.
