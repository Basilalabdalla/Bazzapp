User: You are a senior software architect and DevOps engineer.

I want you to fully set up a production-grade monorepo environment for a modern delivery platform inspired by Deliveroo/Uber Eats but not for food it’s for the online stores or local market in jordan real market or online we deliver everything from anywhere to anywhere in jordan 

The project must be scalable, clean, modular, AI-friendly, and production-ready from day one.

# Main Goal

Prepare the FULL development environment and project structure only.
DO NOT build business features yet.

I want:
- Flutter mobile app (the app name BazZ)
- NestJS backend API
- PostgreSQL database
- Firebase integration
- GitHub monorepo setup
- Production-ready architecture
- Clean folder structures
- Best practices
- Developer tooling
- Environment configs
- CI/CD preparation
- Docker support
- Scalable codebase

# Tech Stack

Frontend Mobile:
- Flutter
- Riverpod
- GoRouter
- Dio
- Freezed
- Flutter Animate

Backend:
- NestJS
- PostgreSQL
- Prisma ORM
- JWT Authentication
- Socket.IO
- Swagger
- ConfigModule

DevOps:
- Docker
- Docker Compose
- GitHub Actions
- ESLint
- Prettier
- Husky
- lint-staged

Cloud/Services:
- Firebase Authentication
- Firebase Cloud Messaging
- Stripe preparation
- Railway deployment preparation

# Repository Structure

Create a monorepo structure like:

/apps
   /mobile
   /server

/packages
   /shared-types
   /shared-utils

/docs

/scripts

/.github

# Tasks

1. Initialize Git repository
2. Create professional .gitignore
3. Create README.md
4. Setup Flutter app
5. Setup NestJS backend
6. Configure PostgreSQL with Prisma
7. Configure environment variables
8. Install all required packages
9. Setup linting and formatting
10. Setup Git hooks
11. Setup Docker files
12. Setup docker-compose
13. Setup GitHub Actions CI
14. Setup Swagger
15. Setup clean architecture folders
16. Setup Firebase placeholders
17. Setup Stripe placeholders
18. Setup API versioning
19. Setup global error handling
20. Setup logging system
21. Setup validation pipeline
22. Setup production-ready configs

# Important Requirements

- Use latest stable versions
- Use scalable architecture
- Use enterprise-level best practices
- Explain every command before running it
- Generate terminal commands step-by-step
- Never skip configuration details
- Keep code modular and maintainable
- Optimize for performance and developer experience
- Prepare everything for future scaling

# Flutter Requirements

Use:
- feature-first architecture
- Riverpod state management
- responsive utilities
- reusable widgets
- theme system
- dark/light mode support
- localization-ready structure

# NestJS Requirements

Use:
- modular architecture
- DTO validation
- Prisma ORM
- centralized exception filters
- logging middleware
- JWT auth structure
- API versioning
- environment validation

# Output Format

Give me:
1. Terminal commands
2. File structure
3. Config files
4. Installation steps
5. Explanation for each setup
6. Best practices
7. Next steps after environment setup

Act like a senior engineer preparing a real startup infrastructure. there is more than one AI agent will work on this app so I need you to prepare it to let any agent understand it and work on it
Model: # BazZ Delivery Platform — Complete Production-Grade Monorepo Setup

> **Jordan's Universal Delivery Platform** — Delivering everything from anywhere to anywhere

---

## Table of Contents

1. [Prerequisites & System Requirements](#prerequisites)
2. [Repository Initialization](#repo-init)
3. [Monorepo Root Configuration](#monorepo-root)
4. [Shared Packages Setup](#shared-packages)
5. [NestJS Backend Setup](#nestjs-setup)
6. [Flutter Mobile App Setup](#flutter-setup)
7. [Docker Configuration](#docker-setup)
8. [GitHub Actions CI/CD](#github-actions)
9. [Environment Configuration](#env-config)
10. [Developer Tooling](#dev-tooling)
11. [Documentation & AI Agent Guide](#docs)
12. [Final Verification](#verification)

---

## Phase 0: Prerequisites & System Requirements

### What You Need Installed

```bash
# Verify all prerequisites before starting
# Each command checks a required tool

node --version          # Required: v20.x LTS or higher
npm --version           # Required: v10.x or higher
git --version           # Required: v2.40+
docker --version        # Required: v24+
docker compose version  # Required: v2.20+
flutter --version       # Required: v3.19+
dart --version          # Required: v3.3+

# Install global tools needed for the project
npm install -g @nestjs/cli@latest    # NestJS CLI for scaffolding
npm install -g prisma@latest         # Prisma CLI for DB management
npm install -g pnpm@latest           # pnpm for monorepo workspace management
```

---

## Phase 1: Repository Initialization

### Step 1.1 — Create the Project Root

```bash
# Create the main project directory
# This will be the root of your entire monorepo
mkdir bazz-platform
cd bazz-platform

# Initialize git repository
git init

# Set default branch to main (industry standard)
git branch -M main
```

### Step 1.2 — Create Full Directory Structure

```bash
# Create all directories at once
# This establishes the entire monorepo skeleton

mkdir -p apps/mobile
mkdir -p apps/server
mkdir -p packages/shared-types/src
mkdir -p packages/shared-utils/src
mkdir -p docs/api
mkdir -p docs/architecture
mkdir -p docs/deployment
mkdir -p docs/agents
mkdir -p scripts
mkdir -p .github/workflows
mkdir -p .github/ISSUE_TEMPLATE
mkdir -p .github/PULL_REQUEST_TEMPLATE

# Verify structure was created
find . -type d | grep -v node_modules | grep -v .git | sort
```

---

## Phase 2: Root-Level Configuration Files

### Step 2.1 — Root `.gitignore`

```bash
cat > .gitignore << 'EOF'
# ============================================
# BazZ Platform — Global .gitignore
# ============================================

# ---- Node.js ----
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
.pnpm-store/
.npm/

# ---- Build Outputs ----
dist/
build/
out/
.next/
.nuxt/

# ---- Environment Files ----
.env
.env.local
.env.development
.env.staging
.env.production
.env.test
!.env.example
!.env.*.example

# ---- IDE & Editors ----
.vscode/*
!.vscode/extensions.json
!.vscode/settings.json
!.vscode/launch.json
.idea/
*.swp
*.swo
*.suo
*.ntvs*
*.njsproj
*.sln
.DS_Store
Thumbs.db

# ---- Flutter / Dart ----
apps/mobile/.dart_tool/
apps/mobile/.flutter-plugins
apps/mobile/.flutter-plugins-dependencies
apps/mobile/.packages
apps/mobile/pubspec.lock
apps/mobile/build/
apps/mobile/ios/Pods/
apps/mobile/ios/.symlinks/
apps/mobile/android/.gradle/
apps/mobile/android/local.properties
apps/mobile/android/captures/
apps/mobile/*.g.dart
apps/mobile/**/*.g.dart
apps/mobile/**/*.freezed.dart
apps/mobile/**/*.mocks.dart
apps/mobile/coverage/

# ---- Prisma ----
apps/server/prisma/migrations/dev/
apps/server/generated/

# ---- Docker ----
.docker/
docker-compose.override.yml

# ---- Testing ----
coverage/
.nyc_output/
test-results/
playwright-report/

# ---- Logs ----
logs/
*.log
lerna-debug.log*

# ---- Firebase ----
.firebase/
firebase-debug.log
.firebaserc
# Keep google-services.json structure but not actual keys
apps/mobile/android/app/google-services.json
apps/mobile/ios/Runner/GoogleService-Info.plist

# ---- Certificates & Keys ----
*.pem
*.key
*.cert
*.p12
*.jks
*.keystore

# ---- Cache ----
.cache/
.parcel-cache/
.turbo/
.eslintcache
.stylelintcache

# ---- OS Generated ----
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# ---- Temporary ----
tmp/
temp/
*.tmp
*.temp
EOF
```

### Step 2.2 — Root `package.json` (pnpm Workspace)

```bash
cat > package.json << 'EOF'
{
  "name": "bazz-platform",
  "version": "1.0.0",
  "private": true,
  "description": "BazZ — Jordan's Universal Delivery Platform. Monorepo containing mobile app and backend server.",
  "author": "BazZ Team",
  "license": "UNLICENSED",
  "engines": {
    "node": ">=20.0.0",
    "pnpm": ">=8.0.0"
  },
  "scripts": {
    "prepare": "husky",
    "lint": "pnpm --filter './apps/**' --filter './packages/**' lint",
    "lint:fix": "pnpm --filter './apps/**' --filter './packages/**' lint:fix",
    "format": "prettier --write \"**/*.{ts,tsx,js,jsx,json,md,yaml,yml}\" --ignore-path .gitignore",
    "format:check": "prettier --check \"**/*.{ts,tsx,js,jsx,json,md,yaml,yml}\" --ignore-path .gitignore",
    "build": "pnpm --filter './packages/**' build && pnpm --filter './apps/**' build",
    "test": "pnpm --filter './apps/**' --filter './packages/**' test",
    "clean": "pnpm --filter './apps/**' --filter './packages/**' clean && rm -rf node_modules",
    "dev:server": "pnpm --filter server dev",
    "dev:shared-types": "pnpm --filter shared-types dev",
    "docker:up": "docker compose up -d",
    "docker:down": "docker compose down",
    "docker:logs": "docker compose logs -f",
    "docker:rebuild": "docker compose up -d --build",
    "db:migrate": "pnpm --filter server prisma:migrate",
    "db:studio": "pnpm --filter server prisma:studio",
    "db:seed": "pnpm --filter server prisma:seed",
    "db:reset": "pnpm --filter server prisma:reset",
    "type-check": "pnpm --filter './apps/**' --filter './packages/**' type-check"
  },
  "devDependencies": {
    "@commitlint/cli": "^19.3.0",
    "@commitlint/config-conventional": "^19.2.2",
    "husky": "^9.1.4",
    "lint-staged": "^15.2.7",
    "prettier": "^3.3.3",
    "typescript": "^5.5.4"
  },
  "pnpm": {
    "overrides": {
      "typescript": "^5.5.4"
    }
  }
}
EOF
```

### Step 2.3 — pnpm Workspace Configuration

```bash
cat > pnpm-workspace.yaml << 'EOF'
# ============================================
# BazZ Platform — pnpm Workspace
# ============================================
# Defines which directories are workspace packages
# pnpm will hoist shared dependencies and link local packages

packages:
  - "apps/server"
  - "packages/*"
EOF
```

### Step 2.4 — Root `tsconfig.json` (Base TypeScript Config)

```bash
cat > tsconfig.json << 'EOF'
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022"],
    "module": "commonjs",
    "moduleResolution": "node",
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "strictNullChecks": true,
    "noImplicitAny": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    "exactOptionalPropertyTypes": false,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "removeComments": false,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "paths": {
      "@bazz/shared-types": ["./packages/shared-types/src/index.ts"],
      "@bazz/shared-utils": ["./packages/shared-utils/src/index.ts"]
    }
  },
  "exclude": [
    "node_modules",
    "dist",
    "build",
    "coverage",
    "apps/mobile"
  ]
}
EOF
```

### Step 2.5 — Prettier Configuration

```bash
cat > .prettierrc << 'EOF'
{
  "semi": true,
  "trailingComma": "all",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "bracketSameLine": false,
  "arrowParens": "always",
  "endOfLine": "lf",
  "overrides": [
    {
      "files": "*.json",
      "options": {
        "printWidth": 80
      }
    },
    {
      "files": "*.md",
      "options": {
        "proseWrap": "preserve",
        "printWidth": 120
      }
    },
    {
      "files": "*.yaml",
      "options": {
        "tabWidth": 2
      }
    }
  ]
}
EOF

cat > .prettierignore << 'EOF'
# Auto-generated files
*.g.dart
*.freezed.dart
*.mocks.dart
pubspec.lock

# Build outputs
dist/
build/
out/
coverage/

# Dependencies
node_modules/
.pnpm-store/

# Flutter
apps/mobile/.dart_tool/
apps/mobile/ios/
apps/mobile/android/

# Prisma generated
apps/server/generated/

# Lock files
pnpm-lock.yaml
package-lock.json
yarn.lock
EOF
```

### Step 2.6 — ESLint Root Configuration

```bash
cat > .eslintrc.js << 'EOF'
// ============================================
// BazZ Platform — Root ESLint Configuration
// ============================================
// This is the base config. Each app/package extends this.

module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
  },
  plugins: ['@typescript-eslint', 'import'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:import/recommended',
    'plugin:import/typescript',
    'prettier', // Must be last to override other configs
  ],
  settings: {
    'import/resolver': {
      typescript: {
        project: './tsconfig.json',
      },
    },
  },
  rules: {
    // TypeScript
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-empty-interface': 'warn',
    '@typescript-eslint/prefer-optional-chain': 'error',
    '@typescript-eslint/no-non-null-assertion': 'warn',

    // Imports
    'import/order': [
      'error',
      {
        groups: [
          'builtin',
          'external',
          'internal',
          'parent',
          'sibling',
          'index',
        ],
        'newlines-between': 'always',
        alphabetize: { order: 'asc', caseInsensitive: true },
      },
    ],
    'import/no-duplicates': 'error',
    'import/no-cycle': 'error',

    // General
    'no-console': ['warn', { allow: ['warn', 'error'] }],
    'prefer-const': 'error',
    'no-var': 'error',
    eqeqeq: ['error', 'always'],
    curly: 'error',
  },
  ignorePatterns: [
    'dist/',
    'build/',
    'node_modules/',
    '*.g.ts',
    'generated/',
    'apps/mobile/',
    'coverage/',
  ],
};
EOF
```

### Step 2.7 — CommitLint Configuration

```bash
cat > commitlint.config.js << 'EOF'
// ============================================
// BazZ Platform — CommitLint Configuration
// ============================================
// Enforces conventional commits format:
// type(scope): description
//
// Types: feat, fix, docs, style, refactor, 
//        test, chore, perf, ci, build, revert

module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // New feature
        'fix',      // Bug fix
        'docs',     // Documentation
        'style',    // Formatting (no logic change)
        'refactor', // Code refactoring
        'test',     // Tests
        'chore',    // Build process, tooling
        'perf',     // Performance improvement
        'ci',       // CI/CD changes
        'build',    // Build system changes
        'revert',   // Revert commit
        'wip',      // Work in progress (avoid in main)
      ],
    ],
    'scope-enum': [
      2,
      'always',
      [
        'mobile',
        'server',
        'shared-types',
        'shared-utils',
        'docker',
        'ci',
        'docs',
        'deps',
        'config',
        'auth',
        'orders',
        'delivery',
        'payments',
        'notifications',
        'users',
        'stores',
        'products',
      ],
    ],
    'subject-max-length': [2, 'always', 100],
    'body-max-line-length': [1, 'always', 200],
  },
};
EOF
```

### Step 2.8 — EditorConfig

```bash
cat > .editorconfig << 'EOF'
# ============================================
# BazZ Platform — EditorConfig
# ============================================
# Ensures consistent coding styles across all editors

root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true
max_line_length = 100

[*.md]
trim_trailing_whitespace = false
max_line_length = off

[*.{yaml,yml}]
indent_size = 2

[*.dart]
indent_size = 2

[Makefile]
indent_style = tab

[*.{png,jpg,gif,ico,svg,woff,woff2,ttf,eot}]
insert_final_newline = false
trim_trailing_whitespace = false
EOF
```

### Step 2.9 — Root `.nvmrc` (Node Version Manager)

```bash
cat > .nvmrc << 'EOF'
20.15.1
EOF
```

---

## Phase 3: Shared Packages Setup

### Step 3.1 — Shared Types Package

```bash
# Navigate to shared-types package
cd packages/shared-types

cat > package.json << 'EOF'
{
  "name": "@bazz/shared-types",
  "version": "1.0.0",
  "description": "Shared TypeScript types and interfaces for BazZ platform",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "import": "./dist/index.js",
      "require": "./dist/index.js",
      "types": "./dist/index.d.ts"
    }
  },
  "scripts": {
    "build": "tsc --project tsconfig.build.json",
    "dev": "tsc --project tsconfig.build.json --watch",
    "lint": "eslint src --ext .ts",
    "lint:fix": "eslint src --ext .ts --fix",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist"
  },
  "devDependencies": {
    "typescript": "^5.5.4"
  },
  "files": [
    "dist",
    "src"
  ]
}
EOF

cat > tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "rootDir": "./src",
    "outDir": "./dist",
    "composite": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

cat > tsconfig.build.json << 'EOF'
{
  "extends": "./tsconfig.json",
  "exclude": ["node_modules", "dist", "**/*.spec.ts", "**/*.test.ts"]
}
EOF
```

### Step 3.2 — Shared Types — Source Files

```bash
# Create the main index file
cat > src/index.ts << 'EOF'
// ============================================
// @bazz/shared-types — Main Export
// ============================================
// This package is shared between server and any 
// future frontend apps. Keep types framework-agnostic.

export * from './enums';
export * from './interfaces';
export * from './dtos';
export * from './constants';
EOF
```

```bash
cat > src/enums/index.ts << 'EOF'
export * from './user.enum';
export * from './order.enum';
export * from './delivery.enum';
export * from './payment.enum';
export * from './store.enum';
EOF

cat > src/enums/user.enum.ts << 'EOF'
/**
 * User role types across the BazZ platform
 * - CUSTOMER: End users placing orders
 * - DRIVER: Delivery drivers
 * - STORE_OWNER: Business owners listing products
 * - ADMIN: Platform administrators
 * - SUPER_ADMIN: Full system access
 */
export enum UserRole {
  CUSTOMER = 'CUSTOMER',
  DRIVER = 'DRIVER',
  STORE_OWNER = 'STORE_OWNER',
  ADMIN = 'ADMIN',
  SUPER_ADMIN = 'SUPER_ADMIN',
}

export enum UserStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  SUSPENDED = 'SUSPENDED',
  PENDING_VERIFICATION = 'PENDING_VERIFICATION',
  BANNED = 'BANNED',
}

export enum VerificationStatus {
  UNVERIFIED = 'UNVERIFIED',
  PENDING = 'PENDING',
  VERIFIED = 'VERIFIED',
  REJECTED = 'REJECTED',
}
EOF

cat > src/enums/order.enum.ts << 'EOF'
/**
 * Order lifecycle states
 * Flow: PENDING → CONFIRMED → PREPARING → READY_FOR_PICKUP
 *       → PICKED_UP → IN_TRANSIT → DELIVERED
 *       (or CANCELLED / FAILED at any point)
 */
export enum OrderStatus {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  PREPARING = 'PREPARING',
  READY_FOR_PICKUP = 'READY_FOR_PICKUP',
  PICKED_UP = 'PICKED_UP',
  IN_TRANSIT = 'IN_TRANSIT',
  DELIVERED = 'DELIVERED',
  CANCELLED = 'CANCELLED',
  FAILED = 'FAILED',
  REFUNDED = 'REFUNDED',
}

export enum OrderType {
  DELIVERY = 'DELIVERY',
  PICKUP = 'PICKUP',
}

export enum CancelReason {
  CUSTOMER_CANCELLED = 'CUSTOMER_CANCELLED',
  STORE_CANCELLED = 'STORE_CANCELLED',
  DRIVER_CANCELLED = 'DRIVER_CANCELLED',
  PAYMENT_FAILED = 'PAYMENT_FAILED',
  ITEM_UNAVAILABLE = 'ITEM_UNAVAILABLE',
  SYSTEM_CANCELLED = 'SYSTEM_CANCELLED',
}
EOF

cat > src/enums/delivery.enum.ts << 'EOF'
export enum DeliveryStatus {
  SEARCHING_FOR_DRIVER = 'SEARCHING_FOR_DRIVER',
  DRIVER_ASSIGNED = 'DRIVER_ASSIGNED',
  DRIVER_EN_ROUTE_TO_STORE = 'DRIVER_EN_ROUTE_TO_STORE',
  DRIVER_AT_STORE = 'DRIVER_AT_STORE',
  PACKAGE_PICKED_UP = 'PACKAGE_PICKED_UP',
  IN_TRANSIT = 'IN_TRANSIT',
  NEAR_DESTINATION = 'NEAR_DESTINATION',
  DELIVERED = 'DELIVERED',
  FAILED = 'FAILED',
}

export enum VehicleType {
  MOTORCYCLE = 'MOTORCYCLE',
  CAR = 'CAR',
  VAN = 'VAN',
  BICYCLE = 'BICYCLE',
  WALKING = 'WALKING',
}

export enum DriverStatus {
  ONLINE = 'ONLINE',
  OFFLINE = 'OFFLINE',
  BUSY = 'BUSY',
  ON_BREAK = 'ON_BREAK',
}
EOF

cat > src/enums/payment.enum.ts << 'EOF'
export enum PaymentStatus {
  PENDING = 'PENDING',
  PROCESSING = 'PROCESSING',
  SUCCEEDED = 'SUCCEEDED',
  FAILED = 'FAILED',
  REFUNDED = 'REFUNDED',
  PARTIALLY_REFUNDED = 'PARTIALLY_REFUNDED',
  CANCELLED = 'CANCELLED',
}

export enum PaymentMethod {
  CASH = 'CASH',
  CARD = 'CARD',
  WALLET = 'WALLET',
  CLIQ = 'CLIQ',         // Jordan-specific payment method
  ORANGE_MONEY = 'ORANGE_MONEY', // Jordan mobile payment
  STRIPE = 'STRIPE',
}

export enum Currency {
  JOD = 'JOD',  // Jordanian Dinar (primary)
  USD = 'USD',
}
EOF

cat > src/enums/store.enum.ts << 'EOF'
export enum StoreStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  SUSPENDED = 'SUSPENDED',
  PENDING_APPROVAL = 'PENDING_APPROVAL',
  CLOSED = 'CLOSED',
}

export enum StoreCategory {
  SUPERMARKET = 'SUPERMARKET',
  ELECTRONICS = 'ELECTRONICS',
  PHARMACY = 'PHARMACY',
  CLOTHING = 'CLOTHING',
  BAKERY = 'BAKERY',
  BUTCHER = 'BUTCHER',
  VEGETABLES_FRUITS = 'VEGETABLES_FRUITS',
  HARDWARE = 'HARDWARE',
  BOOKS_STATIONERY = 'BOOKS_STATIONERY',
  COSMETICS = 'COSMETICS',
  PET_SUPPLIES = 'PET_SUPPLIES',
  TOYS = 'TOYS',
  FLOWERS = 'FLOWERS',
  AUTO_PARTS = 'AUTO_PARTS',
  OTHER = 'OTHER',
}

export enum ProductStatus {
  AVAILABLE = 'AVAILABLE',
  OUT_OF_STOCK = 'OUT_OF_STOCK',
  DISCONTINUED = 'DISCONTINUED',
  COMING_SOON = 'COMING_SOON',
}
EOF
```

```bash
# Create interfaces directory
mkdir -p src/interfaces

cat > src/interfaces/index.ts << 'EOF'
export * from './user.interface';
export * from './order.interface';
export * from './location.interface';
export * from './pagination.interface';
export * from './api-response.interface';
EOF

cat > src/interfaces/location.interface.ts << 'EOF'
/**
 * Geographic coordinate interface
 * Used for driver tracking, store locations, and delivery addresses
 * Jordan coordinate bounds:
 *   Latitude: 29.18 to 33.37
 *   Longitude: 34.88 to 39.30
 */
export interface ICoordinates {
  latitude: number;
  longitude: number;
}

export interface IAddress {
  id?: string;
  label?: string;         // e.g., "Home", "Work"
  fullAddress: string;    // Arabic or English full address
  building?: string;
  floor?: string;
  apartment?: string;
  street?: string;
  area: string;           // Neighborhood/area
  city: string;           // e.g., "Amman", "Zarqa", "Irbid"
  governorate: string;    // Jordan governorate
  coordinates?: ICoordinates;
  landmark?: string;      // Nearby landmark (common in Jordan)
  instructions?: string;  // Delivery instructions
}

export interface IJordanCity {
  nameEn: string;
  nameAr: string;
  governorate: string;
  coordinates: ICoordinates;
}
EOF

cat > src/interfaces/api-response.interface.ts << 'EOF'
/**
 * Standard API response wrapper
 * All BazZ API endpoints return this structure
 */
export interface IApiResponse<T = unknown> {
  success: boolean;
  statusCode: number;
  message: string;
  data?: T;
  meta?: IPaginationMeta;
  timestamp: string;
  path?: string;
}

export interface IApiError {
  success: false;
  statusCode: number;
  error: string;
  message: string | string[];
  details?: Record<string, unknown>;
  timestamp: string;
  path: string;
  requestId?: string;
}

export interface IPaginationMeta {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}
EOF

cat > src/interfaces/pagination.interface.ts << 'EOF'
export interface IPaginationQuery {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  search?: string;
}

export interface IPaginatedResult<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
}
EOF

cat > src/interfaces/user.interface.ts << 'EOF'
import { UserRole, UserStatus, VerificationStatus } from '../enums/user.enum';

export interface IUser {
  id: string;
  firebaseUid?: string;
  email?: string;
  phone: string;           // Primary identifier in Jordan
  firstName: string;
  lastName: string;
  displayName?: string;
  avatar?: string;
  role: UserRole;
  status: UserStatus;
  verificationStatus: VerificationStatus;
  preferredLanguage: 'ar' | 'en';
  createdAt: Date;
  updatedAt: Date;
}

export interface IJwtPayload {
  sub: string;          // User ID
  phone: string;
  role: UserRole;
  iat?: number;
  exp?: number;
}
EOF

cat > src/interfaces/order.interface.ts << 'EOF'
import { OrderStatus, OrderType } from '../enums/order.enum';
import { PaymentMethod, PaymentStatus } from '../enums/payment.enum';
import { IAddress } from './location.interface';

export interface IOrderItem {
  productId: string;
  productName: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  notes?: string;
}

export interface IOrder {
  id: string;
  orderNumber: string;   // Human-readable: BZZ-20240101-0001
  customerId: string;
  storeId: string;
  driverId?: string;
  status: OrderStatus;
  type: OrderType;
  items: IOrderItem[];
  deliveryAddress: IAddress;
  subtotal: number;
  deliveryFee: number;
  serviceFee: number;
  discount: number;
  total: number;
  paymentMethod: PaymentMethod;
  paymentStatus: PaymentStatus;
  estimatedDeliveryTime?: Date;
  actualDeliveryTime?: Date;
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}
EOF
```

```bash
mkdir -p src/dtos src/constants

cat > src/dtos/index.ts << 'EOF'
// DTOs are primarily defined in the server
// This file exports any shared DTO-like types
export * from './pagination.dto';
EOF

cat > src/dtos/pagination.dto.ts << 'EOF'
export interface PaginationQueryDto {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  search?: string;
}
EOF

cat > src/constants/index.ts << 'EOF'
export * from './app.constants';
export * from './jordan.constants';
EOF

cat > src/constants/app.constants.ts << 'EOF'
export const APP_CONSTANTS = {
  APP_NAME: 'BazZ',
  APP_NAME_AR: 'بازز',
  VERSION: '1.0.0',
  DEFAULT_LANGUAGE: 'ar',
  SUPPORTED_LANGUAGES: ['ar', 'en'],
  DEFAULT_CURRENCY: 'JOD',
  DEFAULT_PAGE_SIZE: 20,
  MAX_PAGE_SIZE: 100,
  ORDER_NUMBER_PREFIX: 'BZZ',
  SUPPORT_PHONE: '+962-XX-XXXXXXX',
  SUPPORT_EMAIL: 'support@bazz.jo',
} as const;
EOF

cat > src/constants/jordan.constants.ts << 'EOF'
/**
 * Jordan-specific constants
 * Used across the platform for location, formatting, etc.
 */
export const JORDAN_CONSTANTS = {
  COUNTRY_CODE: 'JO',
  PHONE_CODE: '+962',
  PHONE_REGEX: /^(\+962|0)(7[789]\d{7}|[23456]\d{7})$/,
  DEFAULT_CURRENCY: 'JOD',
  VAT_RATE: 0.16,              // Jordan VAT is 16%
  BOUNDS: {
    MIN_LAT: 29.18,
    MAX_LAT: 33.37,
    MIN_LNG: 34.88,
    MAX_LNG: 39.30,
  },
  GOVERNORATES: [
    'Amman', 'Zarqa', 'Irbid', 'Balqa', 'Madaba',
    'Karak', 'Tafilah', 'Ma\'an', 'Aqaba', 'Jerash',
    'Ajloun', 'Mafraq',
  ],
} as const;
EOF

cd ../..
```

### Step 3.3 — Shared Utils Package

```bash
cd packages/shared-utils

cat > package.json << 'EOF'
{
  "name": "@bazz/shared-utils",
  "version": "1.0.0",
  "description": "Shared utility functions for BazZ platform",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "import": "./dist/index.js",
      "require": "./dist/index.js",
      "types": "./dist/index.d.ts"
    }
  },
  "scripts": {
    "build": "tsc --project tsconfig.build.json",
    "dev": "tsc --project tsconfig.build.json --watch",
    "lint": "eslint src --ext .ts",
    "lint:fix": "eslint src --ext .ts --fix",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist",
    "test": "jest"
  },
  "dependencies": {
    "@bazz/shared-types": "workspace:*"
  },
  "devDependencies": {
    "typescript": "^5.5.4"
  },
  "files": ["dist", "src"]
}
EOF

cat > tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "rootDir": "./src",
    "outDir": "./dist",
    "composite": true,
    "paths": {
      "@bazz/shared-types": ["../shared-types/src/index.ts"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

cat > tsconfig.build.json << 'EOF'
{
  "extends": "./tsconfig.json",
  "exclude": ["node_modules", "dist", "**/*.spec.ts", "**/*.test.ts"]
}
EOF
```

```bash
cat > src/index.ts << 'EOF'
export * from './format';
export * from './validation';
export * from './date';
export * from './pagination';
export * from './order';
EOF

mkdir -p src

cat > src/format.ts << 'EOF'
import { JORDAN_CONSTANTS } from '@bazz/shared-types';

/**
 * Format a price in Jordanian Dinar
 * @example formatPrice(12.5) => "12.500 JOD"
 */
export function formatPrice(amount: number, currency = 'JOD'): string {
  return new Intl.NumberFormat('ar-JO', {
    style: 'currency',
    currency,
    minimumFractionDigits: 3,
    maximumFractionDigits: 3,
  }).format(amount);
}

/**
 * Format a Jordanian phone number
 * @example formatPhone('0791234567') => '+962791234567'
 */
export function formatPhone(phone: string): string {
  const cleaned = phone.replace(/\D/g, '');
  if (cleaned.startsWith('962')) {
    return `+${cleaned}`;
  }
  if (cleaned.startsWith('0')) {
    return `+962${cleaned.slice(1)}`;
  }
  return `+962${cleaned}`;
}

/**
 * Validate Jordanian phone number
 */
export function isValidJordanPhone(phone: string): boolean {
  return JORDAN_CONSTANTS.PHONE_REGEX.test(phone);
}

/**
 * Generate human-readable order number
 * @example generateOrderNumber() => "BZZ-20240115-A1B2"
 */
export function generateOrderNumber(): string {
  const date = new Date();
  const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');
  const random = Math.random().toString(36).substring(2, 6).toUpperCase();
  return `BZZ-${dateStr}-${random}`;
}

/**
 * Truncate string with ellipsis
 */
export function truncate(str: string, maxLength: number): string {
  if (str.length <= maxLength) {
    return str;
  }
  return `${str.slice(0, maxLength - 3)}...`;
}
EOF

cat > src/validation.ts << 'EOF'
import { JORDAN_CONSTANTS } from '@bazz/shared-types';

export function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

export function isValidJordanPhone(phone: string): boolean {
  return JORDAN_CONSTANTS.PHONE_REGEX.test(phone);
}

export function isValidCoordinates(lat: number, lng: number): boolean {
  const { MIN_LAT, MAX_LAT, MIN_LNG, MAX_LNG } = JORDAN_CONSTANTS.BOUNDS;
  return lat >= MIN_LAT && lat <= MAX_LAT && lng >= MIN_LNG && lng <= MAX_LNG;
}

export function isValidJordanGovernorate(governorate: string): boolean {
  return JORDAN_CONSTANTS.GOVERNORATES.includes(governorate as typeof JORDAN_CONSTANTS.GOVERNORATES[number]);
}
EOF

cat > src/date.ts << 'EOF'
/**
 * Date utilities optimized for Jordan timezone (Asia/Amman, UTC+3)
 */
export const JORDAN_TIMEZONE = 'Asia/Amman';

export function toJordanTime(date: Date): Date {
  return new Date(date.toLocaleString('en-US', { timeZone: JORDAN_TIMEZONE }));
}

export function formatJordanDate(date: Date, locale: 'ar' | 'en' = 'ar'): string {
  return new Intl.DateTimeFormat(locale === 'ar' ? 'ar-JO' : 'en-JO', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    timeZone: JORDAN_TIMEZONE,
  }).format(date);
}

export function isStoreOpen(openTime: string, closeTime: string): boolean {
  const now = toJordanTime(new Date());
  const [openH, openM] = openTime.split(':').map(Number);
  const [closeH, closeM] = closeTime.split(':').map(Number);

  const currentMinutes = now.getHours() * 60 + now.getMinutes();
  const openMinutes = openH * 60 + openM;
  const closeMinutes = closeH * 60 + closeM;

  return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
}

export function getEstimatedDeliveryTime(distanceKm: number): Date {
  const baseMinutes = 20;
  const minutesPerKm = 3;
  const estimatedMinutes = baseMinutes + Math.ceil(distanceKm * minutesPerKm);
  const eta = new Date();
  eta.setMinutes(eta.getMinutes() + estimatedMinutes);
  return eta;
}
EOF

cat > src/pagination.ts << 'EOF'
import type { IPaginatedResult } from '@bazz/shared-types';

export function paginate<T>(
  data: T[],
  total: number,
  page: number,
  limit: number,
): IPaginatedResult<T> {
  const totalPages = Math.ceil(total / limit);
  return {
    data,
    meta: {
      total,
      page,
      limit,
      totalPages,
      hasNext: page < totalPages,
      hasPrev: page > 1,
    },
  };
}

export function getPaginationOffset(page: number, limit: number): number {
  return (page - 1) * limit;
}

export function normalizePaginationQuery(
  page?: number,
  limit?: number,
): { page: number; limit: number; skip: number } {
  const normalizedPage = Math.max(1, page || 1);
  const normalizedLimit = Math.min(100, Math.max(1, limit || 20));
  return {
    page: normalizedPage,
    limit: normalizedLimit,
    skip: getPaginationOffset(normalizedPage, normalizedLimit),
  };
}
EOF

cat > src/order.ts << 'EOF'
import { generateOrderNumber } from './format';
export { generateOrderNumber };

export function calculateDeliveryFee(distanceKm: number): number {
  const baseFee = 0.75;        // 0.75 JOD base fee
  const perKmRate = 0.15;      // 0.15 JOD per km
  const minFee = 0.5;          // Minimum 0.5 JOD
  const maxFee = 5.0;          // Maximum 5.0 JOD

  const fee = baseFee + distanceKm * perKmRate;
  return Math.min(maxFee, Math.max(minFee, parseFloat(fee.toFixed(3))));
}

export function calculateServiceFee(subtotal: number): number {
  const feeRate = 0.05;        // 5% service fee
  return parseFloat((subtotal * feeRate).toFixed(3));
}

export function calculateVAT(amount: number): number {
  const vatRate = 0.16;        // Jordan VAT 16%
  return parseFloat((amount * vatRate).toFixed(3));
}
EOF

cd ../..
```

---

## Phase 4: NestJS Backend Setup

### Step 4.1 — Scaffold NestJS App

```bash
# Navigate to apps directory
cd apps

# Create NestJS app with specific options
# --skip-git: we already have git at root
# --skip-install: we'll install with pnpm from root
nest new server --package-manager pnpm --skip-git --strict

cd server
```

### Step 4.2 — Backend `package.json`

```bash
# Replace the default package.json with our production-ready version
cat > package.json << 'EOF'
{
  "name": "server",
  "version": "1.0.0",
  "description": "BazZ Platform — NestJS Backend API Server",
  "private": true,
  "license": "UNLICENSED",
  "scripts": {
    "prebuild": "rimraf dist",
    "build": "nest build",
    "start": "node dist/main",
    "start:dev": "nest start --watch",
    "start:debug": "nest start --debug --watch",
    "start:prod": "node dist/main",
    "dev": "nest start --watch",
    "lint": "eslint \"{src,apps,libs,test}/**/*.ts\" --ext .ts",
    "lint:fix": "eslint \"{src,apps,libs,test}/**/*.ts\" --ext .ts --fix",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:cov": "jest --coverage",
    "test:debug": "node --inspect-brk -r tsconfig-paths/register -r ts-node/register node_modules/.bin/jest --runInBand",
    "test:e2e": "jest --config ./test/jest-e2e.json",
    "type-check": "tsc --noEmit",
    "clean": "rimraf dist",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate dev",
    "prisma:migrate:prod": "prisma migrate deploy",
    "prisma:studio": "prisma studio",
    "prisma:seed": "ts-node prisma/seed.ts",
    "prisma:reset": "prisma migrate reset"
  },
  "dependencies": {
    "@bazz/shared-types": "workspace:*",
    "@bazz/shared-utils": "workspace:*",
    "@nestjs/common": "^10.3.10",
    "@nestjs/config": "^3.2.3",
    "@nestjs/core": "^10.3.10",
    "@nestjs/jwt": "^10.2.0",
    "@nestjs/mapped-types": "^2.0.5",
    "@nestjs/passport": "^10.0.3",
    "@nestjs/platform-express": "^10.3.10",
    "@nestjs/platform-socket.io": "^10.3.10",
    "@nestjs/schedule": "^4.1.0",
    "@nestjs/swagger": "^7.4.0",
    "@nestjs/throttler": "^6.1.0",
    "@nestjs/websockets": "^10.3.10",
    "@prisma/client": "^5.17.0",
    "bcryptjs": "^2.4.3",
    "class-transformer": "^0.5.1",
    "class-validator": "^0.14.1",
    "compression": "^1.7.4",
    "cookie-parser": "^1.4.6",
    "firebase-admin": "^12.3.1",
    "helmet": "^7.1.0",
    "joi": "^17.13.3",
    "morgan": "^1.10.0",
    "multer": "^1.4.5-lts.1",
    "passport": "^0.7.0",
    "passport-jwt": "^4.0.1",
    "reflect-metadata": "^0.2.2",
    "rimraf": "^5.0.9",
    "rxjs": "^7.8.1",
    "socket.io": "^4.7.5",
    "stripe": "^16.8.0",
    "uuid": "^10.0.0",
    "winston": "^3.14.1",
    "winston-daily-rotate-file": "^5.0.0"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.4.4",
    "@nestjs/schematics": "^10.1.4",
    "@nestjs/testing": "^10.3.10",
    "@types/bcryptjs": "^2.4.6",
    "@types/compression": "^1.7.5",
    "@types/cookie-parser": "^1.4.7",
    "@types/express": "^4.17.21",
    "@types/jest": "^29.5.12",
    "@types/morgan": "^1.9.9",
    "@types/multer": "^1.4.11",
    "@types/node": "^20.14.15",
    "@types/passport-jwt": "^4.0.1",
    "@types/supertest": "^6.0.2",
    "@types/uuid": "^10.0.0",
    "@typescript-eslint/eslint-plugin": "^8.0.1",
    "@typescript-eslint/parser": "^8.0.1",
    "eslint": "^9.8.0",
    "eslint-config-prettier": "^9.1.0",
    "eslint-plugin-import": "^2.29.1",
    "jest": "^29.7.0",
    "prisma": "^5.17.0",
    "source-map-support": "^0.5.21",
    "supertest": "^7.0.0",
    "ts-jest": "^29.2.3",
    "ts-loader": "^9.5.1",
    "ts-node": "^10.9.2",
    "tsconfig-paths": "^4.2.0",
    "typescript": "^5.5.4"
  },
  "jest": {
    "moduleFileExtensions": ["js", "json", "ts"],
    "rootDir": "src",
    "testRegex": ".*\\.spec\\.ts$",
    "transform": {
      "^.+\\.(t|j)s$": "ts-jest"
    },
    "collectCoverageFrom": ["**/*.(t|j)s", "!**/*.module.ts", "!main.ts"],
    "coverageDirectory": "../coverage",
    "testEnvironment": "node",
    "moduleNameMapper": {
      "^@bazz/shared-types(.*)$": "<rootDir>/../../packages/shared-types/src$1",
      "^@bazz/shared-utils(.*)$": "<rootDir>/../../packages/shared-utils/src$1"
    }
  }
}
EOF
```

### Step 4.3 — Backend TypeScript Config

```bash
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "ES2022",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true,
    "skipLibCheck": true,
    "strictNullChecks": true,
    "noImplicitAny": true,
    "strictBindCallApply": true,
    "noFallthroughCasesInSwitch": true,
    "esModuleInterop": true,
    "resolveJsonModule": true,
    "paths": {
      "@bazz/shared-types": ["../../packages/shared-types/src/index.ts"],
      "@bazz/shared-utils": ["../../packages/shared-utils/src/index.ts"],
      "@common/*": ["src/common/*"],
      "@config/*": ["src/config/*"],
      "@modules/*": ["src/modules/*"]
    }
  }
}
EOF

cat > tsconfig.build.json << 'EOF'
{
  "extends": "./tsconfig.json",
  "exclude": ["node_modules", "test", "dist", "**/*spec.ts", "**/*e2e-spec.ts"]
}
EOF
```

### Step 4.4 — Create Full NestJS Folder Structure

```bash
# Create the complete modular architecture
# This follows clean architecture + domain-driven design

mkdir -p src/config
mkdir -p src/common/decorators
mkdir -p src/common/filters
mkdir -p src/common/guards
mkdir -p src/common/interceptors
mkdir -p src/common/middleware
mkdir -p src/common/pipes
mkdir -p src/common/utils
mkdir -p src/common/dto
mkdir -p src/database/prisma
mkdir -p src/modules/auth/dto
mkdir -p src/modules/auth/guards
mkdir -p src/modules/auth/strategies
mkdir -p src/modules/users/dto
mkdir -p src/modules/users/entities
mkdir -p src/modules/stores/dto
mkdir -p src/modules/stores/entities
mkdir -p src/modules/products/dto
mkdir -p src/modules/products/entities
mkdir -p src/modules/orders/dto
mkdir -p src/modules/orders/entities
mkdir -p src/modules/delivery/dto
mkdir -p src/modules/delivery/entities
mkdir -p src/modules/payments/dto
mkdir -p src/modules/notifications/dto
mkdir -p src/modules/uploads/dto
mkdir -p src/modules/health
mkdir -p src/modules/websockets
mkdir -p src/logger
mkdir -p prisma/migrations
mkdir -p test
```

### Step 4.5 — Environment Configuration

```bash
# Create the environment validation schema
cat > src/config/env.validation.ts << 'EOF'
import Joi from 'joi';

/**
 * Environment variable validation schema
 * All required variables must be defined before the app starts
 * This prevents runtime errors due to missing configuration
 */
export const envValidationSchema = Joi.object({
  // ---- Application ----
  NODE_ENV: Joi.string()
    .valid('development', 'staging', 'production', 'test')
    .default('development'),
  PORT: Joi.number().default(3000),
  API_PREFIX: Joi.string().default('api'),
  API_VERSION: Joi.string().default('v1'),
  APP_NAME: Joi.string().default('BazZ API'),
  FRONTEND_URL: Joi.string().default('http://localhost:3001'),

  // ---- Database ----
  DATABASE_URL: Joi.string().required().description('PostgreSQL connection string'),

  // ---- JWT ----
  JWT_SECRET: Joi.string().min(32).required().description('Must be at least 32 characters'),
  JWT_EXPIRES_IN: Joi.string().default('7d'),
  JWT_REFRESH_SECRET: Joi.string().min(32).required(),
  JWT_REFRESH_EXPIRES_IN: Joi.string().default('30d'),

  // ---- Firebase ----
  FIREBASE_PROJECT_ID: Joi.string().required(),
  FIREBASE_CLIENT_EMAIL: Joi.string().email().required(),
  FIREBASE_PRIVATE_KEY: Joi.string().required(),
  FIREBASE_STORAGE_BUCKET: Joi.string().required(),

  // ---- Stripe (Optional in dev) ----
  STRIPE_SECRET_KEY: Joi.string().when('NODE_ENV', {
    is: 'production',
    then: Joi.required(),
    otherwise: Joi.optional().default('sk_test_placeholder'),
  }),
  STRIPE_WEBHOOK_SECRET: Joi.string().optional(),
  STRIPE_PUBLISHABLE_KEY: Joi.string().optional(),

  // ---- Redis (Optional - for caching/queues) ----
  REDIS_URL: Joi.string().optional().description('Redis connection URL'),

  // ---- AWS S3 (Optional) ----
  AWS_ACCESS_KEY_ID: Joi.string().optional(),
  AWS_SECRET_ACCESS_KEY: Joi.string().optional(),
  AWS_REGION: Joi.string().default('me-south-1'), // Middle East (Bahrain) - closest to Jordan
  AWS_S3_BUCKET: Joi.string().optional(),

  // ---- Rate Limiting ----
  THROTTLE_TTL: Joi.number().default(60),
  THROTTLE_LIMIT: Joi.number().default(100),

  // ---- Logging ----
  LOG_LEVEL: Joi.string()
    .valid('error', 'warn', 'info', 'http', 'verbose', 'debug', 'silly')
    .default('info'),
});
EOF
```

```bash
cat > src/config/app.config.ts << 'EOF'
import { registerAs } from '@nestjs/config';

/**
 * Application configuration factory
 * Centralizes all config values with type safety
 * Access via: ConfigService.get('app.port')
 */
export const appConfig = registerAs('app', () => ({
  nodeEnv: process.env.NODE_ENV || 'development',
  name: process.env.APP_NAME || 'BazZ API',
  port: parseInt(process.env.PORT || '3000', 10),
  apiPrefix: process.env.API_PREFIX || 'api',
  apiVersion: process.env.API_VERSION || 'v1',
  frontendUrl: process.env.FRONTEND_URL || 'http://localhost:3001',
  isProduction: process.env.NODE_ENV === 'production',
  isDevelopment: process.env.NODE_ENV === 'development',
  isTest: process.env.NODE_ENV === 'test',
}));

export const databaseConfig = registerAs('database', () => ({
  url: process.env.DATABASE_URL,
}));

export const jwtConfig = registerAs('jwt', () => ({
  secret: process.env.JWT_SECRET,
  expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  refreshSecret: process.env.JWT_REFRESH_SECRET,
  refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
}));

export const firebaseConfig = registerAs('firebase', () => ({
  projectId: process.env.FIREBASE_PROJECT_ID,
  clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
  privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
}));

export const stripeConfig = registerAs('stripe', () => ({
  secretKey: process.env.STRIPE_SECRET_KEY,
  webhookSecret: process.env.STRIPE_WEBHOOK_SECRET,
  publishableKey: process.env.STRIPE_PUBLISHABLE_KEY,
}));

export const throttleConfig = registerAs('throttle', () => ({
  ttl: parseInt(process.env.THROTTLE_TTL || '60', 10),
  limit: parseInt(process.env.THROTTLE_LIMIT || '100', 10),
}));
EOF
```

### Step 4.6 — Logger Service

```bash
cat > src/logger/logger.service.ts << 'EOF'
import { Injectable, LoggerService as NestLoggerService } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import winston, { createLogger, format, transports } from 'winston';
import DailyRotateFile from 'winston-daily-rotate-file';

/**
 * BazZ Logger Service
 * 
 * Wraps Winston for structured, production-ready logging
 * Features:
 * - JSON format in production
 * - Colorized output in development
 * - Daily rotating log files
 * - Request ID tracking
 * - Log levels: error, warn, info, http, debug
 */
@Injectable()
export class LoggerService implements NestLoggerService {
  private logger: winston.Logger;

  constructor(private configService: ConfigService) {
    this.logger = this.createWinstonLogger();
  }

  private createWinstonLogger(): winston.Logger {
    const logLevel = this.configService.get<string>('LOG_LEVEL', 'info');
    const isProduction = this.configService.get<string>('NODE_ENV') === 'production';

    const logFormat = isProduction
      ? format.combine(
          format.timestamp(),
          format.errors({ stack: true }),
          format.json(),
        )
      : format.combine(
          format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
          format.errors({ stack: true }),
          format.colorize(),
          format.printf(({ timestamp, level, message, context, ...meta }) => {
            const ctx = context ? `[${context}]` : '';
            const metaStr = Object.keys(meta).length ? JSON.stringify(meta, null, 2) : '';
            return `${timestamp} ${level} ${ctx} ${message} ${metaStr}`;
          }),
        );

    const loggerTransports: winston.transport[] = [
      new transports.Console({ level: logLevel }),
    ];

    if (isProduction) {
      loggerTransports.push(
        new DailyRotateFile({
          filename: 'logs/error-%DATE%.log',
          datePattern: 'YYYY-MM-DD',
          level: 'error',
          maxSize: '20m',
          maxFiles: '14d',
          zippedArchive: true,
        }),
        new DailyRotateFile({
          filename: 'logs/combined-%DATE%.log',
          datePattern: 'YYYY-MM-DD',
          maxSize: '20m',
          maxFiles: '30d',
          zippedArchive: true,
        }),
      );
    }

    return createLogger({
      level: logLevel,
      format: logFormat,
      transports: loggerTransports,
      exitOnError: false,
    });
  }

  log(message: string, context?: string): void {
    this.logger.info(message, { context });
  }

  error(message: string, trace?: string, context?: string): void {
    this.logger.error(message, { trace, context });
  }

  warn(message: string, context?: string): void {
    this.logger.warn(message, { context });
  }

  debug(message: string, context?: string): void {
    this.logger.debug(message, { context });
  }

  verbose(message: string, context?: string): void {
    this.logger.verbose(message, { context });
  }

  http(message: string, meta?: Record<string, unknown>): void {
    this.logger.http(message, meta);
  }
}
EOF

cat > src/logger/logger.module.ts << 'EOF'
import { Global, Module } from '@nestjs/common';

import { LoggerService } from './logger.service';

/**
 * Global Logger Module
 * @Global makes it available everywhere without importing
 */
@Global()
@Module({
  providers: [LoggerService],
  exports: [LoggerService],
})
export class LoggerModule {}
EOF
```

### Step 4.7 — Database Module (Prisma)

```bash
cat > src/database/prisma/prisma.service.ts << 'EOF'
import {
  Injectable,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaClient } from '@prisma/client';

import { LoggerService } from '../../logger/logger.service';

/**
 * Prisma Service
 * 
 * Manages database connection lifecycle
 * Features:
 * - Auto-connect on module init
 * - Graceful disconnect on module destroy
 * - Query logging in development
 * - Connection health check
 */
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  constructor(
    private configService: ConfigService,
    private logger: LoggerService,
  ) {
    const isDev = configService.get('NODE_ENV') === 'development';

    super({
      log: isDev
        ? [
            { emit: 'event', level: 'query' },
            { emit: 'stdout', level: 'info' },
            { emit: 'stdout', level: 'warn' },
            { emit: 'stdout', level: 'error' },
          ]
        : [
            { emit: 'stdout', level: 'error' },
          ],
    });
  }

  async onModuleInit(): Promise<void> {
    this.logger.log('Connecting to PostgreSQL database...', 'PrismaService');
    await this.$connect();
    this.logger.log('Database connection established', 'PrismaService');

    // Log queries in development
    if (this.configService.get('NODE_ENV') === 'development') {
      // @ts-expect-error - Prisma event typing
      this.$on('query', (e: { query: string; duration: number }) => {
        this.logger.debug(`Query: ${e.query} | Duration: ${e.duration}ms`, 'PrismaService');
      });
    }
  }

  async onModuleDestroy(): Promise<void> {
    this.logger.log('Disconnecting from database...', 'PrismaService');
    await this.$disconnect();
  }

  async healthCheck(): Promise<boolean> {
    try {
      await this.$queryRaw`SELECT 1`;
      return true;
    } catch {
      return false;
    }
  }
}
EOF

cat > src/database/prisma/prisma.module.ts << 'EOF'
import { Global, Module } from '@nestjs/common';

import { PrismaService } from './prisma.service';

/**
 * @Global makes PrismaService available everywhere
 * without needing to import PrismaModule in each module
 */
@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
EOF
```

### Step 4.8 — Prisma Schema

```bash
cat > prisma/schema.prisma << 'EOF'
// ============================================
// BazZ Platform — Prisma Schema
// ============================================
// Database: PostgreSQL
// ORM: Prisma v5
//
// Naming Conventions:
//   - Models: PascalCase
//   - Fields: camelCase
//   - Enums: SCREAMING_SNAKE_CASE

generator client {
  provider = "prisma-client-js"
  output   = "../node_modules/.prisma/client"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ============================================
// ENUMS
// ============================================

enum UserRole {
  CUSTOMER
  DRIVER
  STORE_OWNER
  ADMIN
  SUPER_ADMIN
}

enum UserStatus {
  ACTIVE
  INACTIVE
  SUSPENDED
  PENDING_VERIFICATION
  BANNED
}

enum OrderStatus {
  PENDING
  CONFIRMED
  PREPARING
  READY_FOR_PICKUP
  PICKED_UP
  IN_TRANSIT
  DELIVERED
  CANCELLED
  FAILED
  REFUNDED
}

enum PaymentStatus {
  PENDING
  PROCESSING
  SUCCEEDED
  FAILED
  REFUNDED
  PARTIALLY_REFUNDED
  CANCELLED
}

enum PaymentMethod {
  CASH
  CARD
  WALLET
  CLIQ
  ORANGE_MONEY
  STRIPE
}

enum DeliveryStatus {
  SEARCHING_FOR_DRIVER
  DRIVER_ASSIGNED
  DRIVER_EN_ROUTE_TO_STORE
  DRIVER_AT_STORE
  PACKAGE_PICKED_UP
  IN_TRANSIT
  NEAR_DESTINATION
  DELIVERED
  FAILED
}

enum StoreStatus {
  ACTIVE
  INACTIVE
  SUSPENDED
  PENDING_APPROVAL
  CLOSED
}

enum VehicleType {
  MOTORCYCLE
  CAR
  VAN
  BICYCLE
  WALKING
}

enum DriverStatus {
  ONLINE
  OFFLINE
  BUSY
  ON_BREAK
}

// ============================================
// MODELS
// ============================================

model User {
  id                  String      @id @default(uuid())
  firebaseUid         String?     @unique @map("firebase_uid")
  email               String?     @unique
  phone               String      @unique
  firstName           String      @map("first_name")
  lastName            String      @map("last_name")
  displayName         String?     @map("display_name")
  avatar              String?
  role                UserRole    @default(CUSTOMER)
  status              UserStatus  @default(PENDING_VERIFICATION)
  preferredLanguage   String      @default("ar") @map("preferred_language")
  isEmailVerified     Boolean     @default(false) @map("is_email_verified")
  isPhoneVerified     Boolean     @default(false) @map("is_phone_verified")
  lastActiveAt        DateTime?   @map("last_active_at")
  createdAt           DateTime    @default(now()) @map("created_at")
  updatedAt           DateTime    @updatedAt @map("updated_at")
  deletedAt           DateTime?   @map("deleted_at")

  // Relations
  addresses           Address[]
  customerOrders      Order[]     @relation("CustomerOrders")
  driverDeliveries    Order[]     @relation("DriverOrders")
  store               Store?
  driverProfile       DriverProfile?
  notifications       Notification[]
  refreshTokens       RefreshToken[]
  wallet              Wallet?

  @@map("users")
  @@index([phone])
  @@index([email])
  @@index([firebaseUid])
  @@index([role])
  @@index([status])
}

model Address {
  id           String    @id @default(uuid())
  userId       String    @map("user_id")
  label        String?                     // "Home", "Work", etc.
  fullAddress  String    @map("full_address")
  building     String?
  floor        String?
  apartment    String?
  street       String?
  area         String
  city         String
  governorate  String
  latitude     Float?
  longitude    Float?
  landmark     String?
  instructions String?
  isDefault    Boolean   @default(false) @map("is_default")
  createdAt    DateTime  @default(now()) @map("created_at")
  updatedAt    DateTime  @updatedAt @map("updated_at")

  user         User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  orders       Order[]

  @@map("addresses")
  @@index([userId])
}

model Store {
  id              String      @id @default(uuid())
  ownerId         String      @unique @map("owner_id")
  name            String
  nameAr          String?     @map("name_ar")
  description     String?
  descriptionAr   String?     @map("description_ar")
  logo            String?
  coverImage      String?     @map("cover_image")
  category        String
  phone           String?
  email           String?
  website         String?
  status          StoreStatus @default(PENDING_APPROVAL)
  rating          Float       @default(0)
  reviewCount     Int         @default(0) @map("review_count")
  isVerified      Boolean     @default(false) @map("is_verified")
  openTime        String      @default("08:00") @map("open_time")  // "HH:MM"
  closeTime       String      @default("22:00") @map("close_time")
  deliveryRadius  Float       @default(10) @map("delivery_radius")  // km
  minOrderAmount  Float       @default(0) @map("min_order_amount")
  estimatedDeliveryTime Int   @default(30) @map("estimated_delivery_time")  // minutes
  address         String
  area            String
  city            String
  governorate     String
  latitude        Float?
  longitude       Float?
  createdAt       DateTime    @default(now()) @map("created_at")
  updatedAt       DateTime    @updatedAt @map("updated_at")
  deletedAt       DateTime?   @map("deleted_at")

  owner           User        @relation(fields: [ownerId], references: [id])
  products        Product[]
  orders          Order[]

  @@map("stores")
  @@index([status])
  @@index([category])
  @@index([city])
  @@index([governorate])
}

model Product {
  id            String    @id @default(uuid())
  storeId       String    @map("store_id")
  name          String
  nameAr        String?   @map("name_ar")
  description   String?
  descriptionAr String?   @map("description_ar")
  price         Float
  discountPrice Float?    @map("discount_price")
  sku           String?
  barcode       String?
  images        String[]  @default([])
  category      String
  subcategory   String?
  tags          String[]  @default([])
  stock         Int       @default(0)
  unit          String    @default("item")  // "kg", "liter", "item", etc.
  isAvailable   Boolean   @default(true) @map("is_available")
  isFeatured    Boolean   @default(false) @map("is_featured")
  sortOrder     Int       @default(0) @map("sort_order")
  rating        Float     @default(0)
  reviewCount   Int       @default(0) @map("review_count")
  createdAt     DateTime  @default(now()) @map("created_at")
  updatedAt     DateTime  @updatedAt @map("updated_at")
  deletedAt     DateTime? @map("deleted_at")

  store         Store     @relation(fields: [storeId], references: [id])
  orderItems    OrderItem[]

  @@map("products")
  @@index([storeId])
  @@index([category])
  @@index([isAvailable])
  @@index([isFeatured])
}

model Order {
  id                    String        @id @default(uuid())
  orderNumber           String        @unique @map("order_number")
  customerId            String        @map("customer_id")
  storeId               String        @map("store_id")
  driverId              String?       @map("driver_id")
  deliveryAddressId     String        @map("delivery_address_id")
  status                OrderStatus   @default(PENDING)
  subtotal              Float
  deliveryFee           Float         @map("delivery_fee")
  serviceFee            Float         @map("service_fee")
  discount              Float         @default(0)
  vat                   Float         @default(0)
  total                 Float
  paymentMethod         PaymentMethod @map("payment_method")
  paymentStatus         PaymentStatus @default(PENDING) @map("payment_status")
  stripePaymentIntentId String?       @map("stripe_payment_intent_id")
  estimatedDeliveryTime DateTime?     @map("estimated_delivery_time")
  actualDeliveryTime    DateTime?     @map("actual_delivery_time")
  notes                 String?
  cancelReason          String?       @map("cancel_reason")
  rating                Int?          // 1-5 stars
  review                String?
  createdAt             DateTime      @default(now()) @map("created_at")
  updatedAt             DateTime      @updatedAt @map("updated_at")

  customer              User          @relation("CustomerOrders", fields: [customerId], references: [id])
  driver                User?         @relation("DriverOrders", fields: [driverId], references: [id])
  store                 Store         @relation(fields: [storeId], references: [id])
  deliveryAddress       Address       @relation(fields: [deliveryAddressId], references: [id])
  items                 OrderItem[]
  delivery              Delivery?
  payment               Payment?

  @@map("orders")
  @@index([customerId])
  @@index([storeId])
  @@index([driverId])
  @@index([status])
  @@index([orderNumber])
  @@index([createdAt])
}

model OrderItem {
  id          String    @id @default(uuid())
  orderId     String    @map("order_id")
  productId   String    @map("product_id")
  productName String    @map("product_name")  // Snapshot at order time
  quantity    Int
  unitPrice   Float     @map("unit_price")
  totalPrice  Float     @map("total_price")
  notes       String?
  createdAt   DateTime  @default(now()) @map("created_at")

  order       Order     @relation(fields: [orderId], references: [id], onDelete: Cascade)
  product     Product   @relation(fields: [productId], references: [id])

  @@map("order_items")
  @@index([orderId])
  @@index([productId])
}

model Delivery {
  id              String          @id @default(uuid())
  orderId         String          @unique @map("order_id")
  driverId        String?         @map("driver_id")
  status          DeliveryStatus  @default(SEARCHING_FOR_DRIVER)
  pickupLatitude  Float?          @map("pickup_latitude")
  pickupLongitude Float?          @map("pickup_longitude")
  dropLatitude    Float?          @map("drop_latitude")
  dropLongitude   Float?          @map("drop_longitude")
  distanceKm      Float?          @map("distance_km")
  durationMinutes Int?            @map("duration_minutes")
  assignedAt      DateTime?       @map("assigned_at")
  pickedUpAt      DateTime?       @map("picked_up_at")
  deliveredAt     DateTime?       @map("delivered_at")
  proofOfDelivery String?         @map("proof_of_delivery")  // Image URL
  createdAt       DateTime        @default(now()) @map("created_at")
  updatedAt       DateTime        @updatedAt @map("updated_at")

  order           Order           @relation(fields: [orderId], references: [id])

  @@map("deliveries")
  @@index([driverId])
  @@index([status])
}

model DriverProfile {
  id              String        @id @default(uuid())
  userId          String        @unique @map("user_id")
  vehicleType     VehicleType   @default(MOTORCYCLE) @map("vehicle_type")
  vehiclePlate    String?       @map("vehicle_plate")
  vehicleModel    String?       @map("vehicle_model")
  vehicleColor    String?       @map("vehicle_color")
  licenseNumber   String?       @unique @map("license_number")
  licenseExpiry   DateTime?     @map("license_expiry")
  status          DriverStatus  @default(OFFLINE)
  currentLatitude Float?        @map("current_latitude")
  currentLongitude Float?       @map("current_longitude")
  lastLocationAt  DateTime?     @map("last_location_at")
  rating          Float         @default(0)
  totalDeliveries Int           @default(0) @map("total_deliveries")
  isVerified      Boolean       @default(false) @map("is_verified")
  nationalId      String?       @map("national_id")
  createdAt       DateTime      @default(now()) @map("created_at")
  updatedAt       DateTime      @updatedAt @map("updated_at")

  user            User          @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("driver_profiles")
  @@index([status])
  @@index([currentLatitude, currentLongitude])
}

model Payment {
  id                    String          @id @default(uuid())
  orderId               String          @unique @map("order_id")
  amount                Float
  currency              String          @default("JOD")
  method                PaymentMethod
  status                PaymentStatus   @default(PENDING)
  stripePaymentIntentId String?         @unique @map("stripe_payment_intent_id")
  stripeChargeId        String?         @map("stripe_charge_id")
  metadata              Json?
  failureReason         String?         @map("failure_reason")
  refundedAt            DateTime?       @map("refunded_at")
  refundAmount          Float?          @map("refund_amount")
  createdAt             DateTime        @default(now()) @map("created_at")
  updatedAt             DateTime        @updatedAt @map("updated_at")

  order                 Order           @relation(fields: [orderId], references: [id])

  @@map("payments")
}

model Wallet {
  id          String    @id @default(uuid())
  userId      String    @unique @map("user_id")
  balance     Float     @default(0)
  currency    String    @default("JOD")
  createdAt   DateTime  @default(now()) @map("created_at")
  updatedAt   DateTime  @updatedAt @map("updated_at")

  user        User      @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("wallets")
}

model Notification {
  id          String    @id @default(uuid())
  userId      String    @map("user_id")
  title       String
  titleAr     String?   @map("title_ar")
  body        String
  bodyAr      String?   @map("body_ar")
  type        String    // "ORDER_UPDATE", "PROMOTION", "SYSTEM", etc.
  data        Json?     // Additional notification data
  isRead      Boolean   @default(false) @map("is_read")
  readAt      DateTime? @map("read_at")
  fcmMessageId String?  @map("fcm_message_id")
  createdAt   DateTime  @default(now()) @map("created_at")

  user        User      @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("notifications")
  @@index([userId])
  @@index([isRead])
  @@index([createdAt])
}

model RefreshToken {
  id          String    @id @default(uuid())
  userId      String    @map("user_id")
  token       String    @unique
  expiresAt   DateTime  @map("expires_at")
  isRevoked   Boolean   @default(false) @map("is_revoked")
  deviceInfo  String?   @map("device_info")
  ipAddress   String?   @map("ip_address")
  createdAt   DateTime  @default(now()) @map("created_at")

  user        User      @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("refresh_tokens")
  @@index([userId])
  @@index([expiresAt])
}
EOF
```

### Step 4.9 — Common Filters, Guards, Interceptors

```bash
# Global Exception Filter
cat > src/common/filters/global-exception.filter.ts << 'EOF'
import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Prisma } from '@prisma/client';
import { Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';

import type { IApiError } from '@bazz/shared-types';

import { LoggerService } from '../../logger/logger.service';

/**
 * Global Exception Filter
 * 
 * Catches ALL exceptions and returns consistent error responses
 * Handles:
 * - HTTP exceptions (NestJS built-in)
 * - Prisma database errors
 * - Validation errors
 * - Unknown/unexpected errors
 */
@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  constructor(
    private readonly logger: LoggerService,
    private readonly configService: ConfigService,
  ) {}

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();
    const requestId = uuidv4();
    const isProduction = this.configService.get('NODE_ENV') === 'production';

    let statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
    let message: string | string[] = 'Internal server error';
    let error = 'Internal Server Error';
    let details: Record<string, unknown> | undefined;

    // ---- Handle NestJS HTTP Exceptions ----
    if (exception instanceof HttpException) {
      statusCode = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      if (typeof exceptionResponse === 'string') {
        message = exceptionResponse;
      } else if (typeof exceptionResponse === 'object') {
        const resp = exceptionResponse as Record<string, unknown>;
        message = (resp.message as string | string[]) || message;
        error = (resp.error as string) || exception.name;
      }
    }

    // ---- Handle Prisma Errors ----
    else if (exception instanceof Prisma.PrismaClientKnownRequestError) {
      switch (exception.code) {
        case 'P2002':
          statusCode = HttpStatus.CONFLICT;
          error = 'Conflict';
          message = `A record with this ${(exception.meta?.target as string[])?.join(', ')} already exists`;
          break;
        case 'P2025':
          statusCode = HttpStatus.NOT_FOUND;
          error = 'Not Found';
          message = 'Record not found';
          break;
        case 'P2003':
          statusCode = HttpStatus.BAD_REQUEST;
          error = 'Bad Request';
          message = 'Foreign key constraint failed';
          break;
        case 'P2014':
          statusCode = HttpStatus.BAD_REQUEST;
          error = 'Bad Request';
          message = 'Required relation violation';
          break;
        default:
          statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
          message = 'Database error occurred';
      }
    }

    else if (exception instanceof Prisma.PrismaClientValidationError) {
      statusCode = HttpStatus.BAD_REQUEST;
      error = 'Validation Error';
      message = 'Invalid data provided';
    }

    // ---- Handle Unknown Errors ----
    else if (exception instanceof Error) {
      message = isProduction ? 'Internal server error' : exception.message;
      if (!isProduction) {
        details = { stack: exception.stack };
      }
    }

    // Log the error
    this.logger.error(
      `[${requestId}] ${request.method} ${request.url} - ${statusCode} - ${JSON.stringify(message)}`,
      exception instanceof Error ? exception.stack : String(exception),
      'GlobalExceptionFilter',
    );

    const errorResponse: IApiError = {
      success: false,
      statusCode,
      error,
      message,
      timestamp: new Date().toISOString(),
      path: request.url,
      requestId,
      ...(details && !isProduction ? { details } : {}),
    };

    response.status(statusCode).json(errorResponse);
  }
}
EOF
```

```bash
# Response Transform Interceptor
cat > src/common/interceptors/transform-response.interceptor.ts << 'EOF'
import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

import type { IApiResponse } from '@bazz/shared-types';

/**
 * Response Transform Interceptor
 * 
 * Wraps all successful responses in the standard BazZ API format:
 * {
 *   success: true,
 *   statusCode: 200,
 *   message: "...",
 *   data: {...},
 *   timestamp: "..."
 * }
 */
@Injectable()
export class TransformResponseInterceptor<T>
  implements NestInterceptor<T, IApiResponse<T>>
{
  intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Observable<IApiResponse<T>> {
    const ctx = context.switchToHttp();
    const response = ctx.getResponse();
    const statusCode = response.statusCode;

    return next.handle().pipe(
      map((data) => {
        // If data is already in our format, return as-is
        if (data && typeof data === 'object' && 'success' in data && 'statusCode' in data) {
          return data;
        }

        // Extract message and meta if present
        let responseData = data;
        let message = 'Request successful';
        let meta;

        if (data && typeof data === 'object') {
          if ('message' in data) {
            message = data.message;
            const { message: _, ...rest } = data;
            responseData = rest;
          }
          if ('meta' in data) {
            meta = data.meta;
          }
          if ('data' in data) {
            responseData = data.data;
          }
        }

        const result: IApiResponse<T> = {
          success: true,
          statusCode,
          message,
          data: responseData,
          timestamp: new Date().toISOString(),
        };

        if (meta) {
          result.meta = meta;
        }

        return result;
      }),
    );
  }
}
EOF
```

```bash
# Logging Middleware
cat > src/common/middleware/http-logger.middleware.ts << 'EOF'
import { Injectable, NestMiddleware } from '@nestjs/common';
import { NextFunction, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';

import { LoggerService } from '../../logger/logger.service';

/**
 * HTTP Logger Middleware
 * 
 * Logs all incoming HTTP requests with:
 * - Request ID (for tracing)
 * - Method & URL
 * - Response status code
 * - Response time
 * - IP address
 */
@Injectable()
export class HttpLoggerMiddleware implements NestMiddleware {
  constructor(private readonly logger: LoggerService) {}

  use(req: Request, res: Response, next: NextFunction): void {
    const requestId = uuidv4();
    const startTime = Date.now();

    // Attach request ID for tracing
    req['requestId'] = requestId;
    res.setHeader('X-Request-Id', requestId);

    const { method, originalUrl, ip } = req;
    const userAgent = req.get('user-agent') || '';

    res.on('finish', () => {
      const { statusCode } = res;
      const duration = Date.now() - startTime;

      const logMessage = `[${requestId}] ${method} ${originalUrl} ${statusCode} ${duration}ms`;

      if (statusCode >= 500) {
        this.logger.error(logMessage, undefined, 'HTTP');
      } else if (statusCode >= 400) {
        this.logger.warn(logMessage, 'HTTP');
      } else {
        this.logger.http(logMessage, { ip, userAgent });
      }
    });

    next();
  }
}
EOF
```

```bash
# Global Validation Pipe Config
cat > src/common/pipes/validation.pipe.ts << 'EOF'
import { ValidationPipe } from '@nestjs/common';

/**
 * Global Validation Pipe Configuration
 * 
 * Applied to all incoming requests
 * Features:
 * - whitelist: strips unknown properties
 * - forbidNonWhitelisted: throws error for unknown properties
 * - transform: auto-transforms payloads to DTO class instances
 * - transformOptions: enables implicit type conversion
 */
export const createValidationPipe = (): ValidationPipe =>
  new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
    transformOptions: {
      enableImplicitConversion: true,
    },
    stopAtFirstError: false,
  });
EOF
```

```bash
# JWT Auth Guard
cat > src/common/guards/jwt-auth.guard.ts << 'EOF'
import {
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';
import { Observable } from 'rxjs';

import { IS_PUBLIC_KEY } from '../decorators/public.decorator';

/**
 * JWT Authentication Guard
 * 
 * Protects routes by default. Use @Public() decorator to skip.
 * Usage:
 *   @UseGuards(JwtAuthGuard) — explicit
 *   Apply globally in app.module for automatic protection
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private reflector: Reflector) {
    super();
  }

  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) {
      return true;
    }

    return super.canActivate(context);
  }

  handleRequest<TUser = unknown>(err: Error, user: TUser): TUser {
    if (err || !user) {
      throw err || new UnauthorizedException('Invalid or expired token');
    }
    return user;
  }
}
EOF
```

```bash
# Roles Guard
cat > src/common/guards/roles.guard.ts << 'EOF'
import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';

import { UserRole } from '@bazz/shared-types';

import { ROLES_KEY } from '../decorators/roles.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<UserRole[]>(
      ROLES_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!requiredRoles || requiredRoles.length === 0) {
      return true;
    }

    const { user } = context.switchToHttp().getRequest();

    if (!user) {
      throw new ForbiddenException('Access denied');
    }

    const hasRole = requiredRoles.some((role) => user.role === role);

    if (!hasRole) {
      throw new ForbiddenException(
        `Access denied. Required roles: ${requiredRoles.join(', ')}`,
      );
    }

    return true;
  }
}
EOF
```

```bash
# Decorators
cat > src/common/decorators/public.decorator.ts << 'EOF'
import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'isPublic';

/**
 * Mark a route as public (no JWT required)
 * @example
 * @Public()
 * @Get('health')
 * healthCheck() {}
 */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
EOF

cat > src/common/decorators/roles.decorator.ts << 'EOF'
import { SetMetadata } from '@nestjs/common';

import { UserRole } from '@bazz/shared-types';

export const ROLES_KEY = 'roles';

/**
 * Restrict route access to specific roles
 * @example
 * @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
 * @Get('admin/users')
 */
export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles);
EOF

cat > src/common/decorators/current-user.decorator.ts << 'EOF'
import { ExecutionContext, createParamDecorator } from '@nestjs/common';

import type { IUser } from '@bazz/shared-types';

/**
 * Extract current authenticated user from request
 * @example
 * @Get('profile')
 * getProfile(@CurrentUser() user: IUser) {}
 */
export const CurrentUser = createParamDecorator(
  (data: keyof IUser | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user as IUser;

    return data ? user?.[data] : user;
  },
);
EOF

cat > src/common/decorators/api-paginated-response.decorator.ts << 'EOF'
import { applyDecorators, Type } from '@nestjs/common';
import { ApiExtraModels, ApiOkResponse, getSchemaPath } from '@nestjs/swagger';

/**
 * Swagger decorator for paginated responses
 * @example
 * @ApiPaginatedResponse(UserDto)
 * @Get()
 */
export const ApiPaginatedResponse = <T extends Type<unknown>>(model: T) =>
  applyDecorators(
    ApiExtraModels(model),
    ApiOkResponse({
      schema: {
        allOf: [
          {
            properties: {
              success: { type: 'boolean', example: true },
              statusCode: { type: 'number', example: 200 },
              message: { type: 'string' },
              data: {
                type: 'array',
                items: { $ref: getSchemaPath(model) },
              },
              meta: {
                type: 'object',
                properties: {
                  total: { type: 'number' },
                  page: { type: 'number' },
                  limit: { type: 'number' },
                  totalPages: { type: 'number' },
                  hasNext: { type: 'boolean' },
                  hasPrev: { type: 'boolean' },
                },
              },
              timestamp: { type: 'string' },
            },
          },
        ],
      },
    }),
  );
EOF
```

### Step 4.10 — Common DTOs

```bash
cat > src/common/dto/pagination.dto.ts << 'EOF'
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

export enum SortOrder {
  ASC = 'asc',
  DESC = 'desc',
}

export class PaginationDto {
  @ApiPropertyOptional({ minimum: 1, default: 1 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @IsOptional()
  page?: number = 1;

  @ApiPropertyOptional({ minimum: 1, maximum: 100, default: 20 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  @IsOptional()
  limit?: number = 20;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  sortBy?: string;

  @ApiPropertyOptional({ enum: SortOrder, default: SortOrder.DESC })
  @IsEnum(SortOrder)
  @IsOptional()
  sortOrder?: SortOrder = SortOrder.DESC;

  @ApiPropertyOptional()
  @IsString()
  @Transform(({ value }) => value?.trim())
  @IsOptional()
  search?: string;
}
EOF
```

### Step 4.11 — Health Module

```bash
cat > src/modules/health/health.module.ts << 'EOF'
import { Module } from '@nestjs/common';

import { HealthController } from './health.controller';

@Module({
  controllers: [HealthController],
})
export class HealthModule {}
EOF

cat > src/modules/health/health.controller.ts << 'EOF'
import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';

import { Public } from '../../common/decorators/public.decorator';
import { PrismaService } from '../../database/prisma/prisma.service';
import { LoggerService } from '../../logger/logger.service';

@ApiTags('Health')
@Controller('health')
export class HealthController {
  constructor(
    private readonly prismaService: PrismaService,
    private readonly logger: LoggerService,
  ) {}

  @Public()
  @Get()
  @ApiOperation({ summary: 'Basic health check' })
  check() {
    return {
      status: 'ok',
      service: 'bazz-api',
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV,
      version: process.env.npm_package_version || '1.0.0',
    };
  }

  @Public()
  @Get('detailed')
  @ApiOperation({ summary: 'Detailed health check with service statuses' })
  async detailedCheck() {
    const dbHealthy = await this.prismaService.healthCheck();

    return {
      status: dbHealthy ? 'ok' : 'degraded',
      service: 'bazz-api',
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV,
      version: process.env.npm_package_version || '1.0.0',
      services: {
        database: { status: dbHealthy ? 'up' : 'down' },
        api: { status: 'up' },
      },
    };
  }
}
EOF
```

### Step 4.12 — Auth Module Structure

```bash
cat > src/modules/auth/auth.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';

import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './strategies/jwt.strategy';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        signOptions: {
          expiresIn: configService.get<string>('JWT_EXPIRES_IN', '7d'),
        },
      }),
      inject: [ConfigService],
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy],
  exports: [AuthService, JwtModule, PassportModule],
})
export class AuthModule {}
EOF

cat > src/modules/auth/auth.service.ts << 'EOF'
import { Injectable } from '@nestjs/common';

import { LoggerService } from '../../logger/logger.service';

/**
 * Auth Service — Placeholder
 * 
 * TODO (Phase 2 - Business Features):
 * - Firebase token verification
 * - JWT token generation
 * - Refresh token management
 * - OTP via SMS (for Jordan phone auth)
 * - User registration/login
 */
@Injectable()
export class AuthService {
  constructor(private readonly logger: LoggerService) {
    this.logger.log('AuthService initialized', 'AuthService');
  }

  // Placeholder methods - will be implemented in Phase 2
  async validateUser(_token: string) {
    return null;
  }
}
EOF

cat > src/modules/auth/auth.controller.ts << 'EOF'
import { Controller } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

import { AuthService } from './auth.service';

/**
 * Auth Controller — Placeholder
 * Full implementation in Phase 2
 */
@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  // Endpoints will be added in Phase 2
}
EOF

cat > src/modules/auth/strategies/jwt.strategy.ts << 'EOF'
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

import type { IJwtPayload } from '@bazz/shared-types';

import { PrismaService } from '../../../database/prisma/prisma.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    configService: ConfigService,
    private prismaService: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET') || 'fallback-secret',
    });
  }

  async validate(payload: IJwtPayload) {
    const user = await this.prismaService.user.findUnique({
      where: { id: payload.sub },
      select: {
        id: true,
        phone: true,
        email: true,
        firstName: true,
        lastName: true,
        role: true,
        status: true,
        preferredLanguage: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return user;
  }
}
EOF
```

### Step 4.13 — Firebase Service (Placeholder)

```bash
mkdir -p src/common/services

cat > src/common/services/firebase.service.ts << 'EOF'
import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

import { LoggerService } from '../../logger/logger.service';

/**
 * Firebase Service
 * 
 * Handles:
 * - Firebase Admin initialization
 * - Token verification (for user auth)
 * - FCM push notifications
 * 
 * Phase 2 will add:
 * - Phone number OTP verification
 * - Custom token generation
 * - Notification batching
 */
@Injectable()
export class FirebaseService implements OnModuleInit {
  private app: admin.app.App | null = null;

  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
  ) {}

  onModuleInit(): void {
    try {
      const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
      const clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');
      const privateKey = this.configService.get<string>('FIREBASE_PRIVATE_KEY');

      if (!projectId || !clientEmail || !privateKey) {
        this.logger.warn(
          'Firebase credentials not configured. FCM and Firebase auth will be unavailable.',
          'FirebaseService',
        );
        return;
      }

      if (!admin.apps.length) {
        this.app = admin.initializeApp({
          credential: admin.credential.cert({
            projectId,
            clientEmail,
            privateKey,
          }),
          storageBucket: this.configService.get<string>('FIREBASE_STORAGE_BUCKET'),
        });
        this.logger.log('Firebase Admin initialized successfully', 'FirebaseService');
      } else {
        this.app = admin.app();
      }
    } catch (error) {
      this.logger.error('Failed to initialize Firebase Admin', String(error), 'FirebaseService');
    }
  }

  /**
   * Verify Firebase ID token from mobile app
   */
  async verifyIdToken(idToken: string): Promise<admin.auth.DecodedIdToken | null> {
    if (!this.app) {
      this.logger.warn('Firebase not initialized, skipping token verification', 'FirebaseService');
      return null;
    }

    try {
      return await admin.auth().verifyIdToken(idToken);
    } catch (error) {
      this.logger.error('Firebase token verification failed', String(error), 'FirebaseService');
      return null;
    }
  }

  /**
   * Send push notification via FCM
   * Phase 2: Full implementation
   */
  async sendNotification(
    _token: string,
    _title: string,
    _body: string,
    _data?: Record<string, string>,
  ): Promise<string | null> {
    if (!this.app) {
      return null;
    }

    // TODO: Implement in Phase 2
    return null;
  }

  /**
   * Send notification to multiple devices
   * Phase 2: Full implementation
   */
  async sendMulticastNotification(
    _tokens: string[],
    _title: string,
    _body: string,
    _data?: Record<string, string>,
  ): Promise<void> {
    if (!this.app) {
      return;
    }

    // TODO: Implement in Phase 2
  }
}
EOF
```

### Step 4.14 — Stripe Service (Placeholder)

```bash
cat > src/common/services/stripe.service.ts << 'EOF'
import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Stripe from 'stripe';

import { LoggerService } from '../../logger/logger.service';

/**
 * Stripe Payment Service
 * 
 * Phase 1: Infrastructure placeholder
 * Phase 2 will implement:
 * - Payment Intent creation
 * - Webhook handling
 * - Refund processing
 * - Connected accounts (for store payouts)
 * 
 * Note: JOD is supported by Stripe
 * Stripe uses fils (1 JOD = 1000 fils) for amounts
 */
@Injectable()
export class StripeService implements OnModuleInit {
  private stripe: Stripe | null = null;

  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
  ) {}

  onModuleInit(): void {
    const secretKey = this.configService.get<string>('STRIPE_SECRET_KEY');

    if (!secretKey || secretKey === 'sk_test_placeholder') {
      this.logger.warn(
        'Stripe secret key not configured. Payment processing will be unavailable.',
        'StripeService',
      );
      return;
    }

    try {
      this.stripe = new Stripe(secretKey, {
        apiVersion: '2024-06-20',
        typescript: true,
        telemetry: false,
      });
      this.logger.log('Stripe initialized successfully', 'StripeService');
    } catch (error) {
      this.logger.error('Failed to initialize Stripe', String(error), 'StripeService');
    }
  }

  /**
   * Convert JOD to smallest currency unit (fils)
   * 1 JOD = 1000 fils
   */
  toSmallestUnit(amount: number): number {
    return Math.round(amount * 1000);
  }

  /**
   * Convert fils back to JOD
   */
  fromSmallestUnit(amount: number): number {
    return amount / 1000;
  }

  /**
   * Create a payment intent
   * Phase 2: Full implementation
   */
  async createPaymentIntent(
    _amount: number,
    _currency = 'jod',
    _metadata?: Record<string, string>,
  ): Promise<Stripe.PaymentIntent | null> {
    if (!this.stripe) {
      return null;
    }

    // TODO: Implement in Phase 2
    return null;
  }

  /**
   * Handle Stripe webhook
   * Phase 2: Full implementation
   */
  constructWebhookEvent(
    _payload: Buffer,
    _signature: string,
  ): Stripe.Event | null {
    if (!this.stripe) {
      return null;
    }

    // TODO: Implement in Phase 2
    return null;
  }

  get isConfigured(): boolean {
    return this.stripe !== null;
  }
}
EOF
```

### Step 4.15 — WebSocket Gateway (Placeholder)

```bash
cat > src/modules/websockets/realtime.gateway.ts << 'EOF'
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  OnGatewayInit,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

import { LoggerService } from '../../logger/logger.service';

/**
 * Real-time WebSocket Gateway
 * 
 * Handles real-time communication for:
 * - Order status updates
 * - Driver location tracking
 * - Chat/support messages
 * - Push notification fallback
 * 
 * Phase 2: Full implementation with:
 * - JWT authentication for WebSocket connections
 * - Room management (per-order, per-driver)
 * - Rate limiting
 * - Connection pooling
 */
@WebSocketGateway({
  cors: {
    origin: process.env.FRONTEND_URL || '*',
    credentials: true,
  },
  namespace: '/realtime',
  transports: ['websocket', 'polling'],
})
export class RealtimeGateway
  implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server!: Server;

  constructor(private readonly logger: LoggerService) {}

  afterInit(): void {
    this.logger.log('WebSocket Gateway initialized', 'RealtimeGateway');
  }

  handleConnection(client: Socket): void {
    this.logger.debug(
      `Client connected: ${client.id}`,
      'RealtimeGateway',
    );
  }

  handleDisconnect(client: Socket): void {
    this.logger.debug(
      `Client disconnected: ${client.id}`,
      'RealtimeGateway',
    );
  }

  // ---- Order Tracking ----
  @SubscribeMessage('join:order')
  handleJoinOrder(
    @ConnectedSocket() client: Socket,
    @MessageBody() orderId: string,
  ): void {
    client.join(`order:${orderId}`);
    this.logger.debug(`Client ${client.id} joined order:${orderId}`, 'RealtimeGateway');
  }

  @SubscribeMessage('leave:order')
  handleLeaveOrder(
    @ConnectedSocket() client: Socket,
    @MessageBody() orderId: string,
  ): void {
    client.leave(`order:${orderId}`);
  }

  // ---- Driver Location Updates ----
  @SubscribeMessage('driver:location')
  handleDriverLocation(
    @ConnectedSocket() _client: Socket,
    @MessageBody() _data: { driverId: string; lat: number; lng: number },
  ): void {
    // TODO: Phase 2 - Broadcast to customers tracking this driver
    // TODO: Phase 2 - Update driver location in database
  }

  // ---- Emit helpers ----
  emitOrderUpdate(orderId: string, data: Record<string, unknown>): void {
    this.server.to(`order:${orderId}`).emit('order:updated', data);
  }

  emitDriverLocation(orderId: string, data: { lat: number; lng: number }): void {
    this.server.to(`order:${orderId}`).emit('driver:location', data);
  }
}
EOF

cat > src/modules/websockets/websockets.module.ts << 'EOF'
import { Module } from '@nestjs/common';

import { RealtimeGateway } from './realtime.gateway';

@Module({
  providers: [RealtimeGateway],
  exports: [RealtimeGateway],
})
export class WebSocketsModule {}
EOF
```

### Step 4.16 — Main App Module

```bash
cat > src/app.module.ts << 'EOF'
import {
  MiddlewareConsumer,
  Module,
  NestModule,
  RequestMethod,
} from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_FILTER, APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';

import {
  appConfig,
  databaseConfig,
  firebaseConfig,
  jwtConfig,
  stripeConfig,
  throttleConfig,
} from './config/app.config';
import { envValidationSchema } from './config/env.validation';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';
import { JwtAuthGuard } from './common/guards/jwt-auth.guard';
import { RolesGuard } from './common/guards/roles.guard';
import { TransformResponseInterceptor } from './common/interceptors/transform-response.interceptor';
import { HttpLoggerMiddleware } from './common/middleware/http-logger.middleware';
import { FirebaseService } from './common/services/firebase.service';
import { StripeService } from './common/services/stripe.service';
import { PrismaModule } from './database/prisma/prisma.module';
import { LoggerModule } from './logger/logger.module';
import { AuthModule } from './modules/auth/auth.module';
import { HealthModule } from './modules/health/health.module';
import { WebSocketsModule } from './modules/websockets/websockets.module';

@Module({
  imports: [
    // ---- Configuration ----
    ConfigModule.forRoot({
      isGlobal: true,
      validationSchema: envValidationSchema,
      load: [
        appConfig,
        databaseConfig,
        jwtConfig,
        firebaseConfig,
        stripeConfig,
        throttleConfig,
      ],
      expandVariables: true,
      validationOptions: {
        abortEarly: false,
        allowUnknown: true,
      },
    }),

    // ---- Rate Limiting ----
    ThrottlerModule.forRootAsync({
      useFactory: () => [
        {
          ttl: parseInt(process.env.THROTTLE_TTL || '60000', 10),
          limit: parseInt(process.env.THROTTLE_LIMIT || '100', 10),
        },
      ],
    }),

    // ---- Core Infrastructure ----
    LoggerModule,
    PrismaModule,

    // ---- Feature Modules ----
    HealthModule,
    AuthModule,
    WebSocketsModule,

    // ---- Phase 2 Modules (uncomment as implemented) ----
    // UsersModule,
    // StoresModule,
    // ProductsModule,
    // OrdersModule,
    // DeliveryModule,
    // PaymentsModule,
    // NotificationsModule,
    // UploadsModule,
  ],
  providers: [
    // ---- Global Services ----
    FirebaseService,
    StripeService,

    // ---- Global Guards ----
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
    {
      provide: APP_GUARD,
      useClass: RolesGuard,
    },
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },

    // ---- Global Filters ----
    {
      provide: APP_FILTER,
      useClass: GlobalExceptionFilter,
    },

    // ---- Global Interceptors ----
    {
      provide: APP_INTERCEPTOR,
      useClass: TransformResponseInterceptor,
    },
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer): void {
    consumer
      .apply(HttpLoggerMiddleware)
      .forRoutes({ path: '*', method: RequestMethod.ALL });
  }
}
EOF
```

### Step 4.17 — Main Bootstrap File

```bash
cat > src/main.ts << 'EOF'
import { NestFactory, Reflector } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { NestExpressApplication } from '@nestjs/platform-express';
import * as compression from 'compression';
import * as cookieParser from 'cookie-parser';
import helmet from 'helmet';

import { AppModule } from './app.module';
import { createValidationPipe } from './common/pipes/validation.pipe';
import { LoggerService } from './logger/logger.service';

/**
 * BazZ API Bootstrap
 * 
 * Initializes the NestJS application with:
 * - Security middleware (Helmet, CORS)
 * - Compression
 * - Global validation pipe
 * - Swagger documentation
 * - Graceful shutdown
 */
async function bootstrap(): Promise<void> {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    bufferLogs: true,
  });

  // ---- Logger ----
  const logger = app.get(LoggerService);
  app.useLogger(logger);

  const configService = app.get(require('@nestjs/config').ConfigService);
  const port = configService.get<number>('PORT', 3000);
  const apiPrefix = configService.get<string>('API_PREFIX', 'api');
  const apiVersion = configService.get<string>('API_VERSION', 'v1');
  const isProduction = configService.get<string>('NODE_ENV') === 'production';
  const frontendUrl = configService.get<string>('FRONTEND_URL', '*');

  // ---- Security ----
  app.use(
    helmet({
      contentSecurityPolicy: isProduction ? undefined : false,
      crossOriginEmbedderPolicy: false,
    }),
  );

  // ---- CORS ----
  app.enableCors({
    origin: isProduction ? [frontendUrl] : '*',
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'X-Requested-With',
      'Accept',
      'X-Request-Id',
      'X-App-Version',
    ],
    credentials: true,
    maxAge: 86400,
  });

  // ---- Compression ----
  app.use(compression());

  // ---- Cookie Parser ----
  app.use(cookieParser());

  // ---- Trust Proxy (for Railway/cloud deployments) ----
  app.set('trust proxy', 1);

  // ---- API Versioning ----
  app.setGlobalPrefix(`${apiPrefix}/${apiVersion}`);

  // ---- Global Validation Pipe ----
  app.useGlobalPipes(createValidationPipe());

  // ---- Swagger Documentation ----
  if (!isProduction) {
    const swaggerConfig = new DocumentBuilder()
      .setTitle('BazZ API')
      .setDescription(
        `
## BazZ — Jordan's Universal Delivery Platform

**API Version:** ${apiVersion}  
**Environment:** ${configService.get('NODE_ENV')}

### Authentication
Use JWT Bearer token in the Authorization header:
\`Authorization: Bearer <token>\`

### Rate Limiting
- **Default:** 100 requests per 60 seconds
- **Auth endpoints:** 10 requests per 60 seconds

### Response Format
All responses follow the standard format:
\`\`\`json
{
  "success": true,
  "statusCode": 200,
  "message": "...",
  "data": {},
  "timestamp": "..."
}
\`\`\`
      `,
      )
      .setVersion(apiVersion)
      .setContact('BazZ Support', 'https://bazz.jo', 'api@bazz.jo')
      .setLicense('UNLICENSED', '')
      .addServer(`http://localhost:${port}`, 'Local Development')
      .addServer('https://api-staging.bazz.jo', 'Staging')
      .addServer('https://api.bazz.jo', 'Production')
      .addBearerAuth(
        {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          name: 'JWT',
          description: 'Enter your JWT token',
          in: 'header',
        },
        'JWT-auth',
      )
      .addTag('Health', 'API health checks')
      .addTag('Authentication', 'User authentication endpoints')
      .addTag('Users', 'User management')
      .addTag('Stores', 'Store management')
      .addTag('Products', 'Product catalog')
      .addTag('Orders', 'Order management')
      .addTag('Delivery', 'Delivery tracking')
      .addTag('Payments', 'Payment processing')
      .addTag('Notifications', 'Push notifications')
      .build();

    const document = SwaggerModule.createDocument(app, swaggerConfig);
    SwaggerModule.setup(`${apiPrefix}/docs`, app, document, {
      swaggerOptions: {
        persistAuthorization: true,
        displayRequestDuration: true,
        docExpansion: 'none',
        filter: true,
        showCommonExtensions: true,
        tryItOutEnabled: true,
      },
      customSiteTitle: 'BazZ API Documentation',
    });

    logger.log(
      `