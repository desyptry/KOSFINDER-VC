# Worksheet Test Plan KosFinder V1

## Petunjuk pengisian

Worksheet ini disiapkan untuk pengujian manual. Hasil pengujian terdahulu
melalui Flutter Web di Chrome dirangkum terpisah pada Bagian 3; hasil tersebut
bukan pengujian HP/emulator.

Scope V1 mencakup wilayah/area, harga, fasilitas, detail kos, autentikasi
pemilik, pengelolaan kos milik sendiri, ketersediaan kamar, dan status kos.

## 1. Acceptance criteria

### US01 — Melihat dan menemukan kos

| ID | AC terkait | Prasyarat | Langkah | Hasil yang diharapkan | Hasil nyata | Lulus |
|---|---|---|---|---|---|---|
| TC-US01-AC1 | US01-AC1 | Aplikasi berjalan; tersedia data kos dengan wilayah, harga, dan fasilitas berbeda. | Buka daftar kos. Terapkan filter wilayah/area, harga, lalu fasilitas secara terpisah dan gabungan. | Hanya kos yang sesuai setiap kriteria yang tampil. |  |  |
| TC-US01-AC2 | US01-AC2 | Aplikasi berjalan; tidak ada data atau gunakan kriteria yang menghasilkan hasil kosong. | Buka daftar atau terapkan filter yang tidak memiliki hasil. | Keadaan kosong yang informatif tampil tanpa error. |  |  |
| TC-US01-AC3 | US01-AC3 | Aplikasi berjalan; siapkan kondisi koneksi internet terputus. | Buka atau filter daftar saat koneksi terputus. | Pesan koneksi gagal tampil dan aplikasi tidak menampilkan data seolah-olah berhasil dimuat. |  |  |

### US02 — Melihat detail dan ketersediaan kos

| ID | AC terkait | Prasyarat | Langkah | Hasil yang diharapkan | Hasil nyata | Lulus |
|---|---|---|---|---|---|---|
| TC-US02-AC1 | US02-AC1 | Tersedia kos; pencari belum login. | Buka detail kos. | Nama, alamat/area, harga bulanan, fasilitas, total kamar, kamar tersedia, dan status tampil. |  |  |
| TC-US02-AC2 | US02-AC2 | Tersedia satu kos dengan kamar tersedia lebih dari 0 dan satu kos dengan kamar tersedia 0. | Buka detail masing-masing kos. | Kos dengan kamar tersedia lebih dari 0 berstatus `Tersedia`; kos dengan kamar tersedia 0 berstatus `Penuh`. |  |  |
| TC-US02-AC3 | US02-AC3 | Aplikasi berjalan; tersedia ID kos yang tidak ditemukan dan kondisi koneksi terputus. | Buka detail dengan ID tersebut, lalu ulangi saat koneksi terputus. | Pesan tidak ditemukan atau koneksi gagal tampil sesuai kondisi; detail palsu tidak ditampilkan. |  |  |

### US03 — Mendaftar dan masuk sebagai pemilik

| ID | AC terkait | Prasyarat | Langkah | Hasil yang diharapkan | Hasil nyata | Lulus |
|---|---|---|---|---|---|---|
| TC-US03-AC1 | US03-AC1 | Email belum terdaftar; siapkan email dan password valid. | Buka daftar, kirim formulir, lalu masuk. | Akun dibuat dan pemilik dapat masuk tanpa verifikasi email. |  |  |
| TC-US03-AC2 | US03-AC2 | Aplikasi berjalan. | Coba masuk dengan field kosong, lalu dengan kredensial salah. | Validasi atau pesan gagal masuk tampil dan sesi pemilik tidak dibuat. |  |  |
| TC-US03-AC3 | US03-AC3 | Siapkan koneksi internet terputus. | Kirim formulir daftar atau masuk saat koneksi terputus. | Pesan koneksi gagal tampil dan proses tidak ditampilkan sebagai berhasil. |  |  |

### US04 — Menambah dan mengubah kos milik sendiri

| ID | AC terkait | Prasyarat | Langkah | Hasil yang diharapkan | Hasil nyata | Lulus |
|---|---|---|---|---|---|---|
| TC-US04-AC1 | US04-AC1 | Pemilik sudah masuk; data kos valid; pencari dapat membuka daftar publik. | Simpan kos baru, keluar atau buka sesi pencari, lalu muat ulang daftar publik. | Kos tersimpan dan langsung tampil pada daftar publik sebagai miliknya. |  |  |
| TC-US04-AC2 | US04-AC2 | Pemilik sudah masuk dan form tambah/edit terbuka. | Simpan dengan kamar tersedia negatif, lalu ulangi dengan jumlah melebihi total kamar. | Setiap input tidak valid ditolak dengan pesan validasi. |  |  |
| TC-US04-AC3 | US04-AC3 | Pemilik sudah masuk; tersedia data dengan kamar tersedia lebih dari 0 dan sama dengan 0. | Simpan atau ubah kos untuk masing-masing nilai, lalu buka kembali data. | Status otomatis menjadi `Tersedia` untuk nilai lebih dari 0 dan `Penuh` untuk nilai 0. |  |  |
| TC-US04-AC4 | US04-AC4 | Pemilik sudah masuk; form berisi perubahan valid; koneksi dapat diputus. | Putuskan koneksi, lalu kirim perubahan. | Kegagalan ditampilkan dan perubahan tidak dianggap tersimpan. |  |  |
| TC-US04-AC5 | US04-AC5 | Ada kos milik pemilik A; pemilik B sudah masuk. | Dengan akun B, coba mengubah kos milik A. | Supabase menolak permintaan dan data kos tidak berubah. |  |  |

### US05 — Menghapus kos milik sendiri

| ID | AC terkait | Prasyarat | Langkah | Hasil yang diharapkan | Hasil nyata | Lulus |
|---|---|---|---|---|---|---|
| TC-US05-AC1 | US05-AC1 | Pemilik sudah masuk dan memiliki kos; pencari dapat membuka daftar publik. | Pilih hapus, konfirmasi, lalu muat ulang daftar publik. | Kos tidak lagi tampil pada daftar publik. |  |  |
| TC-US05-AC2 | US05-AC2 | Ada kos milik pemilik A; pemilik B sudah masuk. | Dengan akun B, coba menghapus kos milik A. | Supabase menolak permintaan dan kos tetap tampil. |  |  |
| TC-US05-AC3 | US05-AC3 | Pemilik memiliki kos; koneksi dapat diputus. | Putuskan koneksi, pilih hapus, lalu konfirmasi. | Pesan gagal tampil dan kos tidak dianggap terhapus. |  |  |

## 2. Pengujian non-functional requirements

| ID | AC terkait | Prasyarat | Langkah | Hasil yang diharapkan | Hasil nyata | Lulus |
|---|---|---|---|---|---|---|
| TC-NFR-SEC-01 | Security: isolasi daftar dua pemilik | Dua akun pemilik; masing-masing memiliki kos. | Masuk sebagai pemilik B dan buka daftar kos milik. | Kos milik A tidak muncul pada daftar B. |  |  |
| TC-NFR-SEC-02 | Security: isolasi perubahan | Dua akun pemilik; kos milik A tersedia. | Dengan akun B, coba mengubah kos A. | RLS menolak dan data tetap tidak berubah. |  |  |
| TC-NFR-SEC-03 | Security: isolasi penghapusan | Dua akun pemilik; kos milik A tersedia. | Dengan akun B, coba menghapus kos A. | RLS menolak dan kos tetap ada. |  |  |
| TC-NFR-REL-01 | Reliability: load daftar | Aplikasi berjalan; koneksi dapat diputus. | Putuskan koneksi dan buka daftar publik. | Pesan error tampil tanpa data palsu. |  |  |
| TC-NFR-REL-02 | Reliability: load detail | Aplikasi berjalan; ID kos valid; koneksi dapat diputus. | Putuskan koneksi dan buka detail kos. | Pesan error tampil tanpa detail palsu. |  |  |
| TC-NFR-REL-03 | Reliability: save | Pemilik sudah masuk; form berisi data valid; koneksi dapat diputus. | Putuskan koneksi dan simpan perubahan. | Error tampil; form tidak ditutup sebagai sukses dan data tidak dianggap tersimpan. |  |  |
| TC-NFR-REL-04 | Reliability: delete | Pemilik memiliki kos; koneksi dapat diputus. | Putuskan koneksi dan konfirmasi penghapusan. | Error tampil dan kos tetap ada. |  |  |
| TC-NFR-USE-01 | Usability pencari | Aplikasi berjalan tanpa sesi pemilik. | Buka daftar dan detail kos tanpa login. | Pencari dapat melihat daftar dan detail tanpa login. |  |  |
| TC-NFR-USE-02 | Usability pemilik | Pengguna baru dan akun pemilik tersedia. | Daftar/masuk, buka kelola kos, isi form valid, simpan, edit, dan hapus. | Alur pemilik dapat diselesaikan dengan validasi dan pesan yang jelas. |  |  |
| TC-NFR-PERF-01 | Performance maksimal 3 detik | Data uji V1; koneksi normal; stopwatch tersedia. | Ukur waktu dari membuka daftar/detail sampai konten awal tampil. | Daftar dan detail mulai tampil maksimal 3 detik. |  |  |
| TC-NFR-PRIV-01 | Privacy dan akses data publik | Akses tanpa login dan dua akun owner tersedia. | Periksa data yang tampil secara publik dan data yang dapat dilihat akun lain. | Hanya data kos publik terlihat; kredensial dan data privat tidak tampil. |  |  |

## 3. Catatan pengujian terdahulu

Pengujian manual terdahulu dilakukan melalui **Flutter Web di Chrome**, bukan
HP/emulator. Dari 28 skenario worksheet, **27 Pass** dan **1 Partial**:

| Ringkasan | Hasil |
|---|---|
| 27 skenario manual | Pass |
| TC-NFR-SEC-03 — isolasi penghapusan | Partial: DELETE lintas pemilik ditolak melalui aplikasi, tetapi DELETE langsung via REST belum diverifikasi. |

Bukti dan batas hasil terdahulu:

- Kos milik A tidak muncul pada daftar Kelola Kos milik B.
- Percobaan UPDATE dan DELETE lintas pemilik melalui aplikasi ditolak.
- Pemilik membuat, mengubah, dan menghapus kos melalui aplikasi.
- Pencari melihat perubahan jumlah/status kamar setelah pemilik memperbarui kos.
- UPDATE langsung melalui REST ditolak RLS: HTTP 200, respons `[]`, dan data
  tidak berubah.
- DELETE langsung melalui REST **belum diverifikasi**.
- Generated column `status` dan constraint jumlah kamar pernah diuji di
  Supabase menggunakan transaksi `BEGIN`/`ROLLBACK`. Migration 002 tidak
  diterapkan karena aturan tersebut sudah tersedia dari migration 001.
- Hasil tersebut tidak berarti semua pengujian device atau integration test
  otomatis telah lulus. Unit test/fake/mock tetap hanya membuktikan perilaku
  yang disimulasikan.
- Target performa 3 detik belum diuji. Pengujian pada HP/emulator belum
  dilakukan.

## 4. Pekerjaan lanjutan

1. Ulangi skenario pada HP/emulator dan catat hasil device secara terpisah.
2. Verifikasi DELETE lintas pemilik langsung melalui REST pada Supabase nyata.
3. Ukur target waktu tampil daftar dan detail, maksimal 3 detik.
4. Jalankan seluruh alur pencari dan pemilik pada device; jangan menyamakan
   hasil Chrome dengan pengujian device atau integration test otomatis.
