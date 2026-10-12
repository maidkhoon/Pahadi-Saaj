# Pahadi Saaj Custom Commerce — Implementation Plan

## Goal
Turn the existing Astro catalogue into a custom omnichannel commerce platform for online customers and the physical shop. Preserve the current visual design and build incrementally; do not break the existing GitHub Pages catalogue while backend work is being prepared.

## Current state
- Astro + TypeScript static site deployed to GitHub Pages.
- Product cards currently contain illustrative sample products and public stock photography.
- No backend, database, authentication, cart, checkout, payments, POS or live inventory.
- GitHub Pages can host the frontend only; it cannot securely run order/payment APIs or store secrets.

## Target architecture
- **Frontend:** existing Astro site. Keep public catalogue pages static where possible; add client-side cart and customer/account pages as needed.
- **Backend/database:** Supabase Postgres + Auth + Row Level Security; privileged operations must run through trusted server-side Edge Functions or another server API. Never put service-role keys or payment secrets in browser code.
- **Online checkout:** server validates product/variant, price and stock; creates a pending order and reserves stock transactionally; payment provider webhook confirms payment. COD/manual payment stays a separate payment state.
- **Offline POS:** staff-only screen; server-side sale operation decrements the same inventory ledger used by online orders, records payment method and receipt number.
- **Unified stock:** products → variants/SKUs → inventory per location (online/physical shop) → append-only stock movements. Online and POS sales both use the same transaction-safe stock functions.
- **Admin:** role-protected product/variant management, photos, prices, inventory adjustments, order fulfilment/refunds, staff access and sales reports.
- **Shipping:** configurable delivery address, shipping fee rules, fulfilment/tracking status; choose a carrier integration after the shop confirms needs.
- **Payments:** select a provider only after the owner confirms Indian business/KYC readiness, settlement account and whether COD is required. Never collect card details directly.

## Delivery phases
1. **Foundation (this PR):** architecture, security boundaries and initial Postgres schema with RLS defaults.
2. **Backend services:** Supabase project setup, Auth/roles, seed/admin bootstrap, Edge Functions for checkout, POS sale, inventory adjustment and payment webhooks. Add automated tests for stock race conditions and authorization.
3. **Storefront:** replace demo products with database-backed catalogue; variants, search/filter, cart and customer addresses.
4. **Checkout:** shipping/tax/discount calculation on server, order creation, payment-provider integration, COD policy, idempotent webhooks and order emails.
5. **Admin & POS:** staff dashboard, SKU/stock controls, barcode-friendly POS, receipt, returns/refunds and sales reports.
6. **Hardening & launch:** staging, backups, monitoring, accessibility/mobile testing, security review, owner UAT, actual product data and domain cutover.

## Decisions required from shop owner before production
- Legal business name, billing address, GSTIN/tax requirements (if applicable), return/refund and privacy policies.
- Actual products, SKU, sizes, colours, prices, cost price, tax category and opening stock.
- Physical store location(s), who can use POS, and whether online orders draw stock from the shop or a separate online location.
- Shipping areas, rates, dispatch SLA and carrier.
- Payment provider account/KYC, UPI/cards/netbanking and COD policy.
- Customer support phone/email, store hours and verified brand/social links.

## Deployment and cost note
The existing GitHub Pages deployment is static and remains useful for the current catalogue. The production e-commerce backend requires a separately configured Supabase project and server-side functions; hosting/provider costs and transaction fees depend on selected plans and payment provider. No credentials are stored in this repository. Do not switch the public site to live checkout until staging, security tests and owner approval are complete.

## Acceptance criteria
- Customer cannot set price, role, payment state or inventory from the browser.
- Public users can only read active products and their sellable variants.
- Staff/admin operations require authenticated role checks on the server.
- Online and POS sales update stock atomically and cannot oversell under concurrent requests.
- Payment webhooks are signature-verified and idempotent.
- Order/payment/inventory state changes are auditable.
- Secrets are environment variables on server-side services only.
