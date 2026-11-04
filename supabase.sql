-- Skema akhir database Supabase (project flutterlab).
-- Satu tabel To-Do List untuk Pertemuan 8 dan Pertemuan 9: daftar
-- yang sama, dibagi per akun lewat kolom user_id dan Row Level
-- Security. Pertemuan 8 mengaksesnya lewat http mentah, Pertemuan 9
-- lewat SDK, keduanya membaca baris milik akun yang sedang login.

create table todos (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  judul text,
  selesai boolean default false,
  created_at timestamptz default now()
);

-- Nyalakan Row Level Security. Tanpa policy di bawah, tidak ada
-- yang bisa mengakses tabel ini lewat API.
alter table todos enable row level security;

-- Satu policy untuk semua operasi (lihat, tambah, ubah, hapus):
-- pengguna yang sudah login hanya bisa mengakses baris yang
-- user_id-nya sama dengan id akunnya sendiri.
create policy "Pengguna mengelola todo miliknya sendiri"
  on todos
  for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
