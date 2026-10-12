# Pahadi Saaj Catalogue

A mobile-first product catalogue demo for Pahadi Saaj built with Astro, TypeScript and CSS. The page includes sample Ladies’ Suits and Sadriyaan collections and enquiry links prepared for WhatsApp. No checkout, payments, backend or database.

## Run locally
Requires Node.js 20.3+ (Node.js 22 LTS recommended) and npm.

```bash
npm install
npm run dev
```

Open the local URL printed by Astro, usually http://localhost:4321.

## Verify production build

```bash
npm run check
npm run build
npm run preview
```

## Before public launch
- Replace the illustrative product names, photos, descriptions, price labels and colours with details confirmed by the shop owner.
- Add the shop’s verified WhatsApp number in `src/consts.ts`; enquiry buttons stay disabled until it is configured.
- Confirm shop address, business hours and contact details before publishing.
- The Instagram link uses the account URL supplied for this project.

## Scope and cost guardrails
Static catalogue only: no cart, checkout, payment processing, login, backend, database or stock/shipping integrations. No domain or hosting has been purchased. The project uses an open-source toolchain; deploy the `dist/` directory to a compatible static host only after owner approval.
