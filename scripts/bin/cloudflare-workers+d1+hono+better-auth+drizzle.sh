#!/usr/bin/env bash

PS3="Choose a package manager: "

select PM in npm pnpm bun yarn; do
  [[ -n $PM ]] && break
  echo "Invalid choice"
done

case "$PM" in
npm)
  PX="npx"
  ;;
pnpm)
  PX="pnpm dlx"
  ;;
bun)
  PX="bunx"
  ;;
yarn)
  PX="yarn dlx"
  ;;
esac

"$PM" create cloudflare@latest

echo "Initialize the D1 database"
read -rp "Enter your db name: " DBNAME
"$PX" wrangler d1 create "$DBNAME"

"$PM" install better-auth drizzle-orm@rc @better-auth/drizzle-adapter
"$PM" install -D drizzle-kit@rc

# # Hono + Cloudflare Workers + Better Auth + Drizzle (D1) — Full Setup Guide
#
# Sourced from the official Cloudflare Workers docs, Hono's official "Better Auth on Cloudflare" example, and Better Auth's Drizzle adapter docs (checked live, current as of Aug 2026).
#
# This guide uses **D1** (Cloudflare's native SQLite) as the database, since that's the most "Cloudflare-native" pairing and avoids needing an external Postgres provider. A note on the Postgres/Neon variant is at the bottom if you'd rather use that instead.
#
# ---
#
# ## 0. Prerequisites
#
# - Node.js ≥ 20.19.0 (Better Auth's CLI needs this)
# - A Cloudflare account (free tier is fine)
# - `npm`, `pnpm`, `yarn`, or `bun` — examples below use `npm`
#
# ---
#
# ## 1. Scaffold the Hono + Cloudflare project
#
# ```bash
# npm create cloudflare@latest my-app
# ```
#
# You'll be prompted to pick a template — choose **`hono`** from application starter. Then:
#
# **Folder structure right after scaffolding:**
#
# ```
# my-app/
# ├── src/
# │   └── index.ts
# ├── package.json
# ├── tsconfig.json
# ├── wrangler.jsonc
# └── worker-configuration.d.ts   (generated later, see step 3)
# ```
#
# ---
#
# ## 2. Install Better Auth, Drizzle, and D1 tooling
#
# ```bash
# npm install better-auth drizzle-orm
# npm install -D drizzle-kit
# ```
#
# You don't need a separate DB driver package for D1 — `drizzle-orm/d1` uses the binding Wrangler injects automatically.
#
# ---
#
# ## 3. Create the D1 database
#
# ```bash
# npx wrangler d1 create my-app-db
# ```
#
# This prints something like:
#
# ```
# [[d1_databases]]
# binding = "DB"
# database_name = "my-app-db"
# database_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
# ```
#
# Copy that into your `wrangler.jsonc` (Wrangler's config is JSONC now, not TOML, so translate the shape):
#
# ```jsonc
# // wrangler.jsonc
# {
#   "$schema": "node_modules/wrangler/config-schema.json",
#   "name": "my-app",
#   "main": "src/index.ts",
#   "compatibility_date": "2026-08-05",
#   "compatibility_flags": ["nodejs_compat"],
#   "d1_databases": [
#     {
#       "binding": "DB",
#       "database_name": "my-app-db",
#       "database_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
#     }
#   ]
# }
# ```
#
# Now generate TypeScript types for your bindings — this creates `worker-configuration.d.ts` with a `CloudflareBindings` interface reflecting everything in `wrangler.jsonc`:
#
# ```bash
# npx wrangler types --env-interface CloudflareBindings
# ```
#
# Make sure `tsconfig.json` picks these types up:
#
# ```jsonc
# // tsconfig.json
# {
#   "compilerOptions": {
#     "types": ["worker-configuration.d.ts"]
#     // ...your other options
#   }
# }
# ```
#
# Re-run `wrangler types` any time you add a new binding.
#
# ---
#
# ## 4. Set your environment variables
#
# Better Auth needs a secret and a base URL. Locally, Wrangler reads these from `.dev.vars`. In production they become Worker secrets (never committed).
#
# ```bash
# touch .dev.vars
# ```
#
# ```bash
# # .dev.vars
# BETTER_AUTH_URL=http://localhost:8787
# BETTER_AUTH_SECRET=replace-with-a-long-random-string
# ```
#
# Generate a good secret:
#
# ```bash
# openssl rand -base64 32
# ```
#
# Add `.dev.vars` to `.gitignore` if it isn't already there.
#
# ---
#
# ## 5. Write the Drizzle schema
#
# Better Auth can *generate* this file for you (step 7), but Drizzle needs a schema file to exist for its config to point at, and you need it in place before the generator runs. Create the folder now:
#
# ```bash
# mkdir -p src/db
# touch src/db/schema.ts
# ```
#
# Leave it empty for now — the Better Auth CLI will populate it in step 7.
#
# ---
#
# ## 6. Configure Drizzle Kit
#
# ```bash
# touch drizzle.config.ts
# ```
#
# ```ts
# // drizzle.config.ts
# import { defineConfig } from 'drizzle-kit';
#
# export default defineConfig({
#   out: './drizzle',
#   schema: './src/db/schema.ts',
#   dialect: 'sqlite',
#   driver: 'd1-http',
#   dbCredentials: {
#     accountId: process.env.CLOUDFLARE_ACCOUNT_ID!,
#     databaseId: process.env.CLOUDFLARE_DATABASE_ID!,
#     token: process.env.CLOUDFLARE_D1_TOKEN!,
#   },
# });
# ```
#
# The `d1-http` driver lets `drizzle-kit generate`/`studio` talk to D1 over Cloudflare's HTTP API from your machine, rather than needing a local SQLite file path. You need three extra env vars for this (add them to `.dev.vars` or a separate `.env` — Drizzle Kit reads from `process.env`, so `.env` is more conventional here):
#
# ```bash
# # .env
# CLOUDFLARE_ACCOUNT_ID=your-account-id       # Workers & Pages > Overview, right sidebar
# CLOUDFLARE_DATABASE_ID=your-d1-database-id  # same id printed in step 3
# CLOUDFLARE_D1_TOKEN=your-api-token          # My Profile > API Tokens > create with D1 Edit permission
# ```
#
# > **Simpler alternative:** if you don't want to create an API token, skip `drizzle.config.ts`'s `d1-http` driver entirely and instead apply migrations with `wrangler d1 migrations apply` directly (shown in step 8) — that command talks to D1 through your already-authenticated `wrangler login` session. Either path works; the `d1-http` driver is only needed if you want `drizzle-kit generate/push/studio` to hit D1 directly from your terminal.
#
# ---
#
# ## 7. Generate the Better Auth schema
#
# Better Auth ships a CLI that reads your auth config and emits a matching Drizzle schema. Create a minimal CLI-only config first:
#
# ```bash
# touch better-auth.config.ts
# ```
#
# ```ts
# // better-auth.config.ts
# // Used ONLY by the Better Auth CLI to generate the Drizzle schema.
# // This does not run in your Worker.
# import { betterAuth } from 'better-auth';
# import { drizzleAdapter } from 'better-auth/adapters/drizzle';
# import { drizzle } from 'drizzle-orm/d1';
#
# // The CLI needs *a* db instance to introspect the provider — it won't
# // actually connect anywhere, this is just to satisfy the adapter's shape.
# const db = drizzle({} as D1Database);
#
# export const auth = betterAuth({
#   database: drizzleAdapter(db, { provider: 'sqlite' }),
#   secret: process.env.BETTER_AUTH_SECRET,
#   baseURL: process.env.BETTER_AUTH_URL,
#
#   emailAndPassword: {
#     enabled: true,
#   },
# });
# ```
#
# Now generate the schema:
#
# ```bash
# npx @better-auth/cli@latest generate --config ./better-auth.config.ts --output ./src/db/schema.ts
# ```
#
# This writes `user`, `session`, `account`, and `verification` tables (plus anything extra your plugins need) into `src/db/schema.ts` as proper `sqliteTable` Drizzle definitions.
#
# ---
#
# ## 8. Apply the schema to D1
#
# Turn the schema into SQL migration files, then apply them.
#
# ```bash
# npx drizzle-kit generate
# ```
#
# This writes SQL files into `./drizzle`. Apply them to your **local** dev D1 instance (the one `wrangler dev` uses):
#
# ```bash
# npx wrangler d1 migrations apply my-app-db --local
# ```
#
# And to **production** D1 when you're ready:
#
# ```bash
# npx wrangler d1 migrations apply my-app-db --remote
# ```
#
# ---
#
# ## 9. Create the Better Auth instance for your Worker
#
# This is the instance your app actually uses at request time — separate from the CLI-only config in step 7, because this one needs the live `D1Database` binding from `c.env`, which only exists inside a request.
#
# ```bash
# mkdir -p src/lib/auth
# touch src/lib/auth/index.ts
# touch src/lib/auth/options.ts
# ```
#
# ```ts
# // src/lib/auth/options.ts
# import type { BetterAuthOptions } from 'better-auth';
#
# /**
#  * Shared Better Auth config — kept separate from the instance factory
#  * so both the runtime instance (index.ts) and the CLI config
#  * (better-auth.config.ts) can import the same options if you want to
#  * keep them in sync as your app grows.
#  */
# export const betterAuthOptions: BetterAuthOptions = {
#   appName: 'my-app',
#   basePath: '/api/auth',
#
#   emailAndPassword: {
#     enabled: true,
#   },
#
#   // socialProviders, plugins, rate limiting, etc. go here as you add them
# };
# ```
#
# ```ts
# // src/lib/auth/index.ts
# import { betterAuth } from 'better-auth';
# import { drizzleAdapter } from 'better-auth/adapters/drizzle';
# import { drizzle } from 'drizzle-orm/d1';
# import { betterAuthOptions } from './options';
# import * as schema from '../../db/schema';
#
# /**
#  * Creates a Better Auth instance bound to this request's D1 database.
#  * Call this once per request (in middleware) rather than at module
#  * scope — Workers isolates are reused across requests, and D1 bindings
#  * are only available once a request comes in via `c.env`.
#  */
# export const auth = (env: CloudflareBindings): ReturnType<typeof betterAuth> => {
#   const db = drizzle(env.DB, { schema });
#
#   return betterAuth({
#     ...betterAuthOptions,
#     database: drizzleAdapter(db, { provider: 'sqlite', schema }),
#     baseURL: env.BETTER_AUTH_URL,
#     secret: env.BETTER_AUTH_SECRET,
#   });
# };
# ```
#
# ---
#
# ## 10. Mount Better Auth on your Hono app
#
# ```ts
# // src/index.ts
# import { Hono } from 'hono';
# import { auth } from './lib/auth';
#
# const app = new Hono<{ Bindings: CloudflareBindings }>();
#
# // Mount path must match `basePath` in options.ts ("/api/auth")
# app.on(['GET', 'POST'], '/api/auth/*', (c) => {
#   return auth(c.env).handler(c.req.raw);
# });
#
# app.get('/', (c) => c.text('Hello from Hono!'));
#
# export default app;
# ```
#
# Add `BETTER_AUTH_URL` and `BETTER_AUTH_SECRET` to your `CloudflareBindings` type if `wrangler types` didn't already pick them up from `.dev.vars` (it generally only types actual bindings from `wrangler.jsonc`, not `.dev.vars` values, so you may need to extend it manually):
#
# ```ts
# // worker-configuration.d.ts (append, or create src/types.ts and merge)
# interface CloudflareBindings {
#   BETTER_AUTH_URL: string;
#   BETTER_AUTH_SECRET: string;
# }
# ```
#
# ---
#
# ## 11. Run it locally
#
# ```bash
# npm run dev
# ```
#
# Wrangler's dev server (via the Cloudflare Vite plugin or plain `wrangler dev`, depending on your template) runs your Worker in an emulated Workers runtime, so D1 bindings, KV, etc. behave like production. Test the auth endpoint:
#
# ```bash
# curl -X POST http://localhost:8787/api/auth/sign-up/email \
#   -H "Content-Type: application/json" \
#   -d '{"email":"test@example.com","password":"password123","name":"Test User"}'
# ```
#
# ---
#
# ## 12. Deploy
#
# Set your real secrets on Cloudflare (never deploy with `.dev.vars` values baked in):
#
# ```bash
# npx wrangler secret put BETTER_AUTH_SECRET
# npx wrangler secret put BETTER_AUTH_URL
# ```
#
# Apply migrations to production D1 if you haven't already (step 8's `--remote` command), then deploy:
#
# ```bash
# npm run deploy
# ```
#
# ---
#
# ## Final folder structure
#
# ```
# my-app/
# ├── src/
# │   ├── db/
# │   │   └── schema.ts              # generated by Better Auth CLI
# │   ├── lib/
# │   │   └── auth/
# │   │       ├── index.ts           # runtime Better Auth instance (per-request)
# │   │       └── options.ts         # shared config object
# │   └── index.ts                   # Hono app, mounts /api/auth/*
# ├── drizzle/                       # generated SQL migrations
# ├── .dev.vars                      # local secrets (gitignored)
# ├── .env                           # Drizzle Kit CLI creds (gitignored)
# ├── better-auth.config.ts          # CLI-only config, used to (re)generate schema.ts
# ├── drizzle.config.ts
# ├── wrangler.jsonc
# ├── tsconfig.json
# ├── worker-configuration.d.ts      # generated types, includes CloudflareBindings
# └── package.json
# ```
#
# ---
#
# ## Handy package.json scripts
#
# Worth adding once the pieces are wired up, so the workflow stays one command deep:
#
# ```jsonc
# {
#   "scripts": {
#     "dev": "wrangler dev",
#     "deploy": "npm run cf-typegen && wrangler deploy --minify",
#     "cf-typegen": "wrangler types --env-interface CloudflareBindings",
#     "auth:generate-schema": "npx @better-auth/cli@latest generate --config ./better-auth.config.ts --output ./src/db/schema.ts",
#     "db:generate": "drizzle-kit generate",
#     "db:migrate:local": "wrangler d1 migrations apply my-app-db --local",
#     "db:migrate:remote": "wrangler d1 migrations apply my-app-db --remote"
#   }
# }
# ```
#
# ---
#
# ## If you'd rather use Postgres (Neon) instead of D1
#
# Hono's official example (hono.dev/examples/better-auth-on-cloudflare) uses this exact stack but with Neon Postgres instead of D1. The differences are small:
#
# - Install `@neondatabase/serverless` instead of relying on the D1 binding
# - `drizzleAdapter(db, { provider: 'pg' })` instead of `'sqlite'`
# - `drizzle.config.ts` uses `dialect: 'postgresql'` with a plain `url` credential (your Neon connection string) — no `driver: 'd1-http'`, no Cloudflare API token needed
# - No `wrangler d1 create` / `d1_databases` binding — instead a `DATABASE_URL` secret holding the Neon connection string
# - Migrations run with plain `drizzle-kit generate` + `drizzle-kit migrate`, no `wrangler d1 migrations apply`
#
# Everything else (Better Auth instance shape, Hono mounting pattern, CLI schema generation) is identical. D1 is the better pick if you want to stay entirely inside Cloudflare's platform with no external DB provider; Neon Postgres is the better pick if you're already using Postgres elsewhere or want a full relational feature set (D1 is SQLite under the hood, so some Postgres-only features aren't available).
#
# ---
#
# ## Sources
#
# - Cloudflare Workers docs — Hono framework guide (developers.cloudflare.com/workers/framework-guides/web-apps/more-web-frameworks/hono)
# - Hono official example — Better Auth on Cloudflare (hono.dev/examples/better-auth-on-cloudflare)
# - Better Auth — Drizzle ORM Adapter docs (better-auth.com/docs/adapters/drizzle)
# - Drizzle ORM — D1 HTTP API with Drizzle Kit guide (orm.drizzle.team/docs/guides/d1-http-with-drizzle-kit)
