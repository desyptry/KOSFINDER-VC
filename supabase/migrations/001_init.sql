create table if not exists public.kos (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  name text not null check (length(trim(name)) > 0),
  address_area text not null check (length(trim(address_area)) > 0),
  price_monthly bigint not null check (price_monthly >= 0),
  facilities text[] not null default '{}',
  total_rooms integer not null check (total_rooms > 0),
  available_rooms integer not null check (
    available_rooms >= 0
    and available_rooms <= total_rooms
  ),
  status text generated always as (
    case
      when available_rooms > 0 then 'Tersedia'
      else 'Penuh'
    end
  ) stored,
  created_at timestamptz not null default now()
);

alter table public.kos enable row level security;

grant select on public.kos to anon, authenticated;
grant insert, update, delete on public.kos to authenticated;

create policy "Kos dapat dilihat publik"
on public.kos
for select
to anon, authenticated
using (true);

create policy "Pemilik dapat menambah kos sendiri"
on public.kos
for insert
to authenticated
with check (owner_id = (select auth.uid()));

create policy "Pemilik dapat mengubah kos sendiri"
on public.kos
for update
to authenticated
using (owner_id = (select auth.uid()))
with check (owner_id = (select auth.uid()));

create policy "Pemilik dapat menghapus kos sendiri"
on public.kos
for delete
to authenticated
using (owner_id = (select auth.uid()));
