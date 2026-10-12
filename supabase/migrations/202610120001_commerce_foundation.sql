-- Pahadi Saaj commerce schema foundation.
-- Apply to a dedicated Supabase project after reviewing the implementation plan.
-- This migration intentionally does not expose privileged stock/order writes to clients.

create extension if not exists pgcrypto;

create type public.app_role as enum ('customer', 'staff', 'admin');
create type public.order_status as enum (
  'pending_payment', 'confirmed', 'processing', 'packed', 'shipped',
  'ready_for_pickup', 'completed', 'cancelled', 'refunded'
);
create type public.payment_status as enum (
  'pending', 'authorized', 'paid', 'failed', 'partially_refunded', 'refunded'
);
create type public.payment_method as enum ('online', 'upi', 'card', 'cash', 'cod', 'bank_transfer');
create type public.stock_movement_type as enum (
  'opening', 'purchase', 'sale', 'reservation', 'release', 'return',
  'damage', 'adjustment', 'transfer_in', 'transfer_out'
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  phone text,
  role public.app_role not null default 'customer',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.store_locations (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  location_type text not null check (location_type in ('physical', 'online', 'warehouse')),
  address jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  description text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.categories(id) on delete set null,
  slug text not null unique,
  name text not null,
  description text,
  status text not null default 'draft' check (status in ('draft', 'active', 'archived')),
  brand text not null default 'Pahadi Saaj',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  sku text not null unique,
  barcode text unique,
  size text,
  colour text,
  attributes jsonb not null default '{}'::jsonb,
  price_paise bigint not null check (price_paise >= 0),
  compare_at_price_paise bigint check (compare_at_price_paise is null or compare_at_price_paise >= price_paise),
  cost_price_paise bigint check (cost_price_paise is null or cost_price_paise >= 0),
  weight_grams integer check (weight_grams is null or weight_grams >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  variant_id uuid references public.product_variants(id) on delete cascade,
  storage_path text not null,
  alt_text text not null,
  sort_order integer not null default 0,
  is_primary boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.inventory_levels (
  location_id uuid not null references public.store_locations(id),
  variant_id uuid not null references public.product_variants(id),
  on_hand integer not null default 0 check (on_hand >= 0),
  reserved integer not null default 0 check (reserved >= 0 and reserved <= on_hand),
  updated_at timestamptz not null default now(),
  primary key (location_id, variant_id)
);

create table public.stock_movements (
  id uuid primary key default gen_random_uuid(),
  location_id uuid not null references public.store_locations(id),
  variant_id uuid not null references public.product_variants(id),
  movement_type public.stock_movement_type not null,
  quantity_delta integer not null check (quantity_delta <> 0),
  reference_type text,
  reference_id uuid,
  reason text,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.customer_addresses (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references auth.users(id) on delete cascade,
  label text,
  recipient_name text not null,
  phone text not null,
  address_line1 text not null,
  address_line2 text,
  landmark text,
  city text not null,
  state text not null,
  postal_code text not null,
  country_code char(2) not null default 'IN',
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number bigint generated always as identity unique,
  customer_id uuid references auth.users(id) on delete set null,
  source text not null check (source in ('online', 'pos')),
  location_id uuid references public.store_locations(id),
  status public.order_status not null default 'pending_payment',
  payment_status public.payment_status not null default 'pending',
  payment_method public.payment_method,
  currency char(3) not null default 'INR',
  subtotal_paise bigint not null default 0 check (subtotal_paise >= 0),
  discount_paise bigint not null default 0 check (discount_paise >= 0),
  shipping_paise bigint not null default 0 check (shipping_paise >= 0),
  tax_paise bigint not null default 0 check (tax_paise >= 0),
  total_paise bigint not null default 0 check (total_paise >= 0),
  shipping_address jsonb,
  billing_address jsonb,
  customer_note text,
  internal_note text,
  idempotency_key text unique,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (discount_paise <= subtotal_paise),
  check (total_paise = subtotal_paise - discount_paise + shipping_paise + tax_paise)
);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  variant_id uuid references public.product_variants(id) on delete set null,
  sku_snapshot text not null,
  product_name_snapshot text not null,
  variant_snapshot jsonb not null default '{}'::jsonb,
  quantity integer not null check (quantity > 0),
  unit_price_paise bigint not null check (unit_price_paise >= 0),
  discount_paise bigint not null default 0 check (discount_paise >= 0),
  tax_paise bigint not null default 0 check (tax_paise >= 0),
  line_total_paise bigint not null check (line_total_paise >= 0),
  created_at timestamptz not null default now(),
  check (discount_paise <= unit_price_paise * quantity)
);

create table public.payment_transactions (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete restrict,
  provider text not null,
  provider_payment_id text,
  provider_order_id text,
  amount_paise bigint not null check (amount_paise >= 0),
  currency char(3) not null default 'INR',
  status text not null check (status in ('created', 'authorized', 'captured', 'failed', 'refunded', 'partially_refunded')),
  idempotency_key text unique,
  provider_payload jsonb not null default '{}'::jsonb,
  processed_at timestamptz,
  created_at timestamptz not null default now(),
  unique (provider, provider_payment_id)
);

create table public.order_events (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  event_type text not null,
  from_status text,
  to_status text,
  note text,
  actor_id uuid references auth.users(id) on delete set null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index products_status_category_idx on public.products(status, category_id);
create index variants_product_active_idx on public.product_variants(product_id, is_active);
create index stock_movements_variant_created_idx on public.stock_movements(variant_id, created_at desc);
create index orders_customer_created_idx on public.orders(customer_id, created_at desc);
create index orders_status_created_idx on public.orders(status, created_at desc);
create index order_items_order_idx on public.order_items(order_id);

-- Role helper is SECURITY DEFINER to avoid recursive RLS evaluation on profiles.
create or replace function public.current_app_role()
returns public.app_role
language sql
stable
security definer
set search_path = ''
as $$
  select p.role from public.profiles p where p.id = (select auth.uid())
$$;

revoke all on function public.current_app_role() from public;
grant execute on function public.current_app_role() to authenticated;

alter table public.profiles enable row level security;
alter table public.store_locations enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.product_variants enable row level security;
alter table public.product_images enable row level security;
alter table public.inventory_levels enable row level security;
alter table public.stock_movements enable row level security;
alter table public.customer_addresses enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.payment_transactions enable row level security;
alter table public.order_events enable row level security;

-- Public catalogue reads only; draft and archived products stay private.
create policy "public reads active categories" on public.categories
for select to anon, authenticated using (is_active = true);
create policy "public reads active products" on public.products
for select to anon, authenticated using (status = 'active');
create policy "public reads active variants of active products" on public.product_variants
for select to anon, authenticated using (
  is_active = true and exists (
    select 1 from public.products p where p.id = product_id and p.status = 'active'
  )
);
create policy "public reads images for active products" on public.product_images
for select to anon, authenticated using (
  exists (select 1 from public.products p where p.id = product_id and p.status = 'active')
);

-- Customers may read/update their own profile but cannot self-promote their role.
create policy "users read own profile" on public.profiles
for select to authenticated using (id = (select auth.uid()) or public.current_app_role() in ('staff', 'admin'));
create policy "users update own basic profile" on public.profiles
for update to authenticated using (id = (select auth.uid()))
with check (id = (select auth.uid()) and role = public.current_app_role());
create policy "staff read locations" on public.store_locations
for select to authenticated using (public.current_app_role() in ('staff', 'admin') and is_active = true);
create policy "customers manage own addresses" on public.customer_addresses
for all to authenticated using (customer_id = (select auth.uid()))
with check (customer_id = (select auth.uid()));

create policy "customers read own orders" on public.orders
for select to authenticated using (customer_id = (select auth.uid()) or public.current_app_role() in ('staff', 'admin'));
create policy "customers read own order items" on public.order_items
for select to authenticated using (
  exists (select 1 from public.orders o where o.id = order_id and
    (o.customer_id = (select auth.uid()) or public.current_app_role() in ('staff', 'admin')))
);
create policy "staff read inventory" on public.inventory_levels
for select to authenticated using (public.current_app_role() in ('staff', 'admin'));
create policy "staff read stock ledger" on public.stock_movements
for select to authenticated using (public.current_app_role() in ('staff', 'admin'));
create policy "staff read payment transactions" on public.payment_transactions
for select to authenticated using (public.current_app_role() in ('staff', 'admin'));
create policy "order participants read events" on public.order_events
for select to authenticated using (
  exists (select 1 from public.orders o where o.id = order_id and
    (o.customer_id = (select auth.uid()) or public.current_app_role() in ('staff', 'admin')))
);

-- No direct client INSERT/UPDATE/DELETE policies for orders, order items, payments,
-- inventory levels or stock ledger. Trusted server functions will own these writes.
-- Admin mutations should be implemented through server-side authorization, not broad client policies.
