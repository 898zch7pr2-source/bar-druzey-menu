-- Run once in Supabase Dashboard -> SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.menu_items (
  id uuid primary key default gen_random_uuid(),
  category text not null,
  subcategory text not null,
  name_ru text not null,
  name_kk text not null default '',
  description_ru text not null default '',
  description_kk text not null default '',
  price numeric(12,2),
  is_available boolean not null default true,
  sort_order integer not null default 0,
  photo_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.menu_items add column if not exists photo_url text;
alter table public.menu_items enable row level security;

drop policy if exists "Public can read menu items" on public.menu_items;
create policy "Public can read menu items" on public.menu_items
for select to anon, authenticated using (true);

drop policy if exists "Admin can insert menu items" on public.menu_items;
create policy "Admin can insert menu items" on public.menu_items
for insert to authenticated
with check (lower(coalesce(auth.jwt()->>'email','')) = 'melis3660atr@gmail.com');

drop policy if exists "Admin can update menu items" on public.menu_items;
create policy "Admin can update menu items" on public.menu_items
for update to authenticated
using (lower(coalesce(auth.jwt()->>'email','')) = 'melis3660atr@gmail.com')
with check (lower(coalesce(auth.jwt()->>'email','')) = 'melis3660atr@gmail.com');

drop policy if exists "Admin can delete menu items" on public.menu_items;
create policy "Admin can delete menu items" on public.menu_items
for delete to authenticated
using (lower(coalesce(auth.jwt()->>'email','')) = 'melis3660atr@gmail.com');

grant select on public.menu_items to anon, authenticated;
grant insert, update, delete on public.menu_items to authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('menu-photos', 'menu-photos', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = true, file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg','image/png','image/webp'];

drop policy if exists "Public can view menu photos" on storage.objects;
create policy "Public can view menu photos" on storage.objects
for select to anon, authenticated using (bucket_id = 'menu-photos');

drop policy if exists "Admin can upload menu photos" on storage.objects;
create policy "Admin can upload menu photos" on storage.objects
for insert to authenticated
with check (bucket_id = 'menu-photos' and lower(coalesce(auth.jwt()->>'email','')) = 'melis3660atr@gmail.com');

drop policy if exists "Admin can update menu photos" on storage.objects;
create policy "Admin can update menu photos" on storage.objects
for update to authenticated
using (bucket_id = 'menu-photos' and lower(coalesce(auth.jwt()->>'email','')) = 'melis3660atr@gmail.com')
with check (bucket_id = 'menu-photos' and lower(coalesce(auth.jwt()->>'email','')) = 'melis3660atr@gmail.com');

drop policy if exists "Admin can delete menu photos" on storage.objects;
create policy "Admin can delete menu photos" on storage.objects
for delete to authenticated
using (bucket_id = 'menu-photos' and lower(coalesce(auth.jwt()->>'email','')) = 'melis3660atr@gmail.com');
