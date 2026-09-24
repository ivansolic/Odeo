<!--
PRESET: Angular 22 + NestJS + MySQL (pnpm / Prisma / Nx).
A complete, filled-in project CLAUDE.md for this stack. To use it, copy it over
your project's CLAUDE.md (the `/odeo:setup-project` command can do this for you), then
adjust the Purpose, names, and any per-project details.
-->

# Project: [FILL IN NAME]

_Last updated: [YYYY-MM-DD]_

## Purpose
[1-2 sentences describing what this project is, who it's for, and the outcome it produces.]

## Stack

### Frontend
- **Framework:** Angular 22 (released June 2026)
- **Language:** TypeScript strict mode
- **State:** Angular Signals (primary) + RxJS for streams only
- **Forms:** Signal Forms (stable in v22), use for new forms; Reactive Forms only for legacy
- **Change detection:** OnPush (new default in v22, do NOT specify manually)
- **Zone strategy:** Zoneless (default for new v22 projects)
- **Component model:** Standalone components, selectorless imports where it improves clarity
- **UI library:** Angular Material + Angular CDK
- **HTTP:** HttpClient with typed responses; `httpResource` from new Resource API for fetched data
- **Testing:** Vitest (new v22 default), fast, ESM-native
- **Linting:** ESLint + Prettier

### Backend
- **Framework:** NestJS
- **Language:** TypeScript strict mode
- **Runtime:** Node.js 22 LTS
- **ORM:** Prisma
- **Database:** MySQL 8.x
- **Validation:** class-validator + class-transformer
- **Auth:** [JWT via @nestjs/jwt / OAuth, decide per project]
- **Testing:** Jest + Supertest (e2e)
- **API style:** REST with OpenAPI/Swagger documentation

### Shared
- **Package manager:** pnpm
- **Monorepo (if used):** Nx workspace
- **Deployment:** [decide: Vercel / Railway / Fly.io / firm-internal]
- **Env management:** `.env` files (never committed), `@nestjs/config` for backend
- **DB tooling:** Prisma Studio for inspection, native MySQL CLI for ops

## Commands

### Frontend (`apps/web` or root if single-app)
- `pnpm dev`, start Angular dev server (`ng serve`)
- `pnpm test`, run Vitest unit tests (`vitest run`)
- `pnpm test:watch`, Vitest in watch mode
- `pnpm lint`, run ESLint (`ng lint`)
- `pnpm typecheck`, TypeScript check (`tsc --noEmit`)
- `pnpm build`, production build (`ng build`)

### Backend (`apps/api`)
- `pnpm dev:api`, start NestJS in watch mode (`nest start --watch`)
- `pnpm test:api`, backend unit tests
- `pnpm test:e2e`, e2e tests
- `pnpm lint:api`, lint backend
- `pnpm db:migrate`, apply Prisma migrations (`prisma migrate dev`)
- `pnpm db:generate`, generate Prisma client
- `pnpm db:studio`, open Prisma Studio

## Architecture
- **Pattern:** Modular monolith (Nx workspace: `apps/web`, `apps/api`, `libs/`)
- **Why:** one deploy and simple ops for a small team, with clear module
  boundaries that make a later split possible if needed.
- Revisit via the `architecture-reviewer` subagent + an ADR if a real need arises.

## Design
- **UI library / design system:** Angular Material + CDK
- **Design tokens:** `design/tokens.json` (source of truth) → compiled to CSS custom properties + an Angular Material theme
- **Rule:** all styling references **semantic tokens**, never hardcode colors, spacing, font sizes, radii. Reuse Material components; don't reinvent. Never `bypassSecurityTrust*` for styling.
- **Build command:** `pnpm tokens:build`
- UI work follows the `ux-design` skill and is reviewed by the `design-reviewer` subagent.

## Project Structure

```
project/
├── apps/
│   ├── web/                       # Angular frontend
│   │   ├── src/
│   │   │   ├── app/
│   │   │   │   ├── core/         # singletons, services, guards
│   │   │   │   ├── shared/       # reusable components, pipes
│   │   │   │   ├── features/     # feature modules / standalone components
│   │   │   │   └── app.routes.ts
│   │   │   └── environments/
│   │   └── ...
│   └── api/                       # NestJS backend
│       ├── src/
│       │   ├── modules/          # feature modules
│       │   ├── common/           # filters, interceptors, guards
│       │   ├── config/
│       │   └── main.ts
│       └── prisma/
│           └── schema.prisma      # provider = "mysql"
├── libs/                          # shared code (DTOs, types, utilities)
├── docs/                          # PRDs, stories, decisions
└── .claude/                       # Claude config
```

## Conventions

### Angular (v22 defaults)
- **Signals first** for component state; use RxJS only for true streams (WebSocket, debounced search, etc.)
- **Signal Forms** for new forms; Reactive Forms only when migrating legacy code
- Standalone components, no NgModules
- `inject()` function for DI, not constructor injection
- One component per file; one feature per folder
- Smart components in `features/`, dumb/presentational in `shared/`
- OnPush is automatic in v22, don't add it manually
- Use built-in control flow: `@if`, `@for`, `@switch` (not `*ngIf`, `*ngFor`)
- Use Resource API (`resource`, `rxResource`, `httpResource`) for fetched data where appropriate

### NestJS
- One feature = one module (controller + service + dto folder)
- DTOs validate input with `class-validator` decorators
- Services contain business logic; controllers only handle HTTP
- `@nestjs/swagger` decorators for API documentation
- Database access only through repository services, never directly from controllers
- Use Prisma transactions for multi-step writes

### Database (MySQL specifics)
- Use Prisma migrations, never raw `ALTER TABLE` outside migrations
- `provider = "mysql"` in `prisma/schema.prisma`
- Be aware of MySQL vs PostgreSQL differences:
  - Default collation: prefer `utf8mb4_0900_ai_ci` (case-insensitive, full Unicode)
  - JSON column type works, but querying nested fields uses MySQL-specific syntax
  - No native array types, use relation tables or JSON columns
  - String comparisons are case-insensitive by default, be explicit with `BINARY` if needed

### Shared
- DTOs and shared types live in `libs/shared-types/`
- Never duplicate types between frontend and backend, import from shared lib
- API responses are typed end-to-end

## Security & Data

_The global Security Baseline (in `~/.claude/CLAUDE.md`) applies to all code in
this project automatically. This section records what is **specific to this
project**, `/odeo:setup-project` fills it in. Stack notes for this preset: DTO
validation via class-validator on every endpoint; Prisma parameterized queries
only (no `$queryRawUnsafe`); Angular's built-in sanitization (never
`bypassSecurityTrust*` without justification); helmet for security headers in
NestJS; bcrypt/argon2 for passwords._

### Sensitive data inventory
- **Personal data (PII) handled:** [e.g. names, emails, IP addresses, or "none"]
- **Special/sensitive data:** [e.g. payment data, health data, or "none"]
- **Where it lives:** [MySQL tables, third-party processors]
- **Retention:** [how long is each kept; what gets deleted/anonymized, when]

### Users & compliance
- **User base / region:** [e.g. EU users → GDPR applies]
- **Compliance requirements:** [GDPR / none known / industry-specific]
- **Data subject rights (if GDPR):** export and deletion must work end-to-end, 
  [where is delete implemented / TODO]

### Authentication & access
- **Auth model:** [none / email+password / OAuth provider / SSO]
- **Roles & permissions:** [e.g. user/admin, guards on every protected route]
- **Session strategy:** [cookies (httpOnly+Secure+SameSite) / JWT + refresh]

### Project-specific security rules
- [added as they're decided]

### Security checkpoints (process, always on)
- Changes touching auth, input handling, uploads, payments, or data access →
  run `/security-review` before committing (in addition to code-reviewer)
- New dependency → verify maintenance/name, then `pnpm audit`
- Sensitive feature at PRD stage → include a security pre-mortem

## Git Workflow
**Hard rule, not a suggestion.**

- `main` is protected. Never commit or push directly to it.
- Every change lives on a branch:
  - `feature/<short-description>`, new functionality
  - `fix/<short-description>`, bug fixes
  - `chore/<short-description>`, maintenance, dependencies
  - `docs/<short-description>`, documentation only
  - `refactor/<short-description>`, code restructuring without behavior change
- Commit messages use Conventional Commits: `type(scope): description`
  - Scope examples: `web`, `api`, `db`, `auth`, `docs`
  - Examples: `feat(api): add user search endpoint`, `fix(web): handle empty list state`
- One logical change per commit
- Before pushing: `pnpm lint` and `pnpm typecheck` must pass
- Every merge to `main` goes through a Pull Request
- Never commit: `.env`, secrets, `node_modules`, build artifacts, large binaries
- After PR is merged, delete branch locally and remotely

## Product Documentation

Product specs live in `/docs/`:

- **`/docs/prds/`**, PRDs (one per major feature)
- **`/docs/stories/`**, user stories (smaller units of work)
- **`/docs/decisions/`**, Architecture Decision Records (capture WHY for non-obvious choices)
- **`/docs/research/`**, user research, interviews, market notes
- **`/docs/templates/`**, ADR template (PRD and story format come from the `/odeo:prd` and `/odeo:stories` skills, not a local template)

PRDs and user stories are generated by the `/odeo:prd` and `/odeo:stories` skills and saved here as `PRD-NNN-<slug>.md` / `USR-NNN-<slug>.md`.

When implementing a feature, **first read the relevant PRD or story** before writing code. If no spec exists for non-trivial work, propose creating one before implementing.

## Don't
- Don't use NgModules for new code, standalone components only
- Don't disable OnPush, it's the default in v22 for a reason
- Don't mix Reactive Forms and Signal Forms in the same component without explicit reason
- Don't put business logic in controllers (NestJS), services own logic
- Don't bypass TypeScript strict with `any` or `@ts-ignore` without a comment explaining why
- Don't introduce a new dependency without checking with me
- Don't commit generated files (Prisma client, Angular dist), they belong in `.gitignore`
- Don't write raw SQL outside Prisma migrations
- Don't import from `node_modules` paths directly, use proper imports

## Corrections
_Claude: append project-specific lessons here when I correct you._

Format:
- **YYYY-MM-DD**, [what went wrong]. **Rule:** [what to do next time].

---

_Entries appended below as corrections occur._
