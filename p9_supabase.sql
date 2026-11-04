-- Pertemuan 9: tabel tugas per pengguna untuk fitur autentikasi.
-- Jalankan di SQL Editor dashboard Supabase (project todo).
-- Tabel ini terpisah dari tabel todos milik Pertemuan 8, supaya
-- halaman Pertemuan 8 yang memakai anon key tidak ikut rusak.

create table tugas (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  judul text,
  selesai boolean default false,
  created_at timestamptz default now()
);

-- Nyalakan Row Level Security. Tanpa policy di bawah, tidak ada
-- yang bisa mengakses tabel ini lewat API.
alter table tugas enable row level security;

-- Satu policy untuk semua operasi (lihat, tambah, ubah, hapus):
-- pengguna yang sudah login hanya bisa mengakses baris yang
-- user_id-nya sama dengan id akunnya sendiri.
create policy "Pengguna mengelola tugas miliknya sendiri"
  on tugas
  for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
