-- TRIMT HOMES starter database schema for Supabase (PostgreSQL)
-- Review and run in Supabase SQL Editor after creating a new project.
-- Admin users should be assigned by a trusted server/admin process using app_metadata.
-- Never let users set their own role.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  created_at timestamptz not null default now()
);

create type public.property_type as enum ('House', 'Apartment', 'Land', 'Commercial');
create type public.listing_purpose as enum ('For Sale', 'For Rent');
create type public.listing_status as enum ('draft', 'published', 'sold', 'rented', 'archived');

create table if not exists public.properties (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  location text not null,
  property_type public.property_type not null,
  purpose public.listing_purpose not null,
  price_ngn numeric(18,2) not null check (price_ngn > 0),
  bedrooms integer not null default 0 check (bedrooms >= 0),
  bathrooms integer not null default 0 check (bathrooms >= 0),
  area_sqm numeric(12,2),
  image_urls text[] not null default '{}',
  status public.listing_status not null default 'draft',
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, property_id)
);

create table if not exists public.enquiries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  property_id uuid references public.properties(id) on delete set null,
  name text not null,
  contact text not null,
  message text not null,
  created_at timestamptz not null default now(),
  status text not null default 'new' check (status in ('new','in_progress','closed'))
);

create index if not exists properties_status_created_idx on public.properties(status, created_at desc);
create index if not exists properties_location_idx on public.properties using gin (to_tsvector('simple', location));
create index if not exists enquiries_created_idx on public.enquiries(created_at desc);

alter table public.profiles enable row level security;
alter table public.properties enable row level security;
alter table public.favorites enable row level security;
alter table public.enquiries enable row level security;

-- Profiles: signed-in users can read/update only their own profile.
create policy "profile_select_own" on public.profiles for select to authenticated
using (id = (select auth.uid()));
create policy "profile_insert_own" on public.profiles for insert to authenticated
with check (id = (select auth.uid()));
create policy "profile_update_own" on public.profiles for update to authenticated
using (id = (select auth.uid())) with check (id = (select auth.uid()));

-- Public visitors see published properties only.
create policy "public_read_published_properties" on public.properties for select to anon, authenticated
using (status = 'published' or created_by = (select auth.uid()));

-- Signed-in users manage only their own favourites.
create policy "favorites_read_own" on public.favorites for select to authenticated
using (user_id = (select auth.uid()));
create policy "favorites_insert_own" on public.favorites for insert to authenticated
with check (user_id = (select auth.uid()));
create policy "favorites_delete_own" on public.favorites for delete to authenticated
using (user_id = (select auth.uid()));

-- Allow visitors to submit enquiries. Do not allow public reads.
create policy "public_submit_enquiry" on public.enquiries for insert to anon, authenticated
with check (user_id is null or user_id = (select auth.uid()));
create policy "users_read_own_enquiries" on public.enquiries for select to authenticated
using (user_id = (select auth.uid()));

-- IMPORTANT:
-- Add admin-only INSERT/UPDATE/DELETE policies for properties and admin SELECT/UPDATE
-- policies for enquiries only after implementing and testing a trusted admin role check.
-- Recommended: use a server-side helper that checks auth.jwt()->'app_metadata'->>'role'
-- = 'admin'. Do not trust user-editable user_metadata for authorisation.
-- Add rate limiting / CAPTCHA to public enquiry submissions and configure email notifications.
