# SchoolCentral - Complete Sourcecode Documentation

**Project**: SchoolCentral - School Life, in One Place  
**Version**: 1.0.0  
**Tech Stack**: Next.js 15.5, React 19, Supabase, Tailwind CSS, TypeScript  
**Status**: Production (Vercel deployment)

---

## TABLE OF CONTENTS

1. [Project Structure & Setup](#project-structure--setup)
2. [Configuration Files](#configuration-files)
3. [Package Dependencies](#package-dependencies)
4. [Database Schema & Migrations](#database-schema--migrations)
5. [Core TypeScript Types](#core-typescript-types)
6. [Data Layer (Supabase Client)](#data-layer-supabase-client)
7. [Frontend Components](#frontend-components)
8. [API Routes (Backend)](#api-routes-backend)
9. [Styling & UI](#styling--ui)
10. [Environment Setup](#environment-setup)

---

## PROJECT STRUCTURE & SETUP

### Directory Layout
```
schoolcentral/
├── src/
│   ├── app/
│   │   ├── api/
│   │   │   ├── accept-representative/
│   │   │   ├── application-notifications/
│   │   │   ├── event-notifications/
│   │   │   ├── representative-applications/
│   │   │   ├── teacher-management/
│   │   │   ├── teacher-review/
│   │   │   ├── reset/
│   │   │   └── cleanup/
│   │   ├── teacher-review/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── manifest.ts
│   ├── components/
│   │   ├── ui/
│   │   ├── schoolhub.tsx
│   │   ├── account-settings.tsx
│   │   ├── representative-applications.tsx
│   │   ├── catalog-editor.tsx
│   │   └── teacher-picker.tsx
│   ├── data/
│   │   ├── supabase.ts
│   │   ├── repository.ts
│   │   └── seed.ts
│   ├── domain/
│   │   ├── types.ts
│   │   └── applications.ts
│   └── server/
│       └── application-service.ts
├── supabase/
│   ├── migrations/
│   │   ├── 001_schoolhub.sql
│   │   ├── 002_schoolcentral_brand.sql
│   │   ├── 003_representative_applications.sql
│   │   ├── 004_teacher_directory_search.sql
│   │   ├── 005_event_notifications.sql
│   │   ├── 006_reminder_time.sql
│   │   ├── 007_accepted_application_status.sql
│   │   └── 008_fix_org_creation.sql
│   ├── tests/
│   ├── seed.sql
│   ├── bootstrap-owner.sql
│   └── install-fresh.sql
├── public/
│   └── sw.js (Service Worker)
├── tests/
│   ├── domain.test.ts
│   └── applications.test.ts
├── memory-bank/
│   ├── README.md
│   ├── active-context.md
│   ├── product-context.md
│   ├── progress.md
│   ├── project-brief.md
│   └── system-patterns.md
├── package.json
├── tsconfig.json
├── next.config.ts
├── tailwind.config.ts
├── postcss.config.mjs
├── eslint.config.mjs
└── .env.example
```

---

## CONFIGURATION FILES

### package.json
```json
{
  "name": "schoolhub",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "next dev --hostname 127.0.0.1",
    "build": "next build",
    "start": "next start --hostname 127.0.0.1",
    "typecheck": "tsc --noEmit",
    "lint": "eslint .",
    "test": "node --experimental-strip-types --test tests/*.test.ts"
  },
  "dependencies": {
    "next": "^15.5.0",
    "react": "^19.1.0",
    "react-dom": "^19.1.0",
    "@supabase/supabase-js": "^2.57.0",
    "lucide-react": "^0.468.0",
    "@radix-ui/react-slot": "^1.2.0",
    "class-variance-authority": "^0.7.1",
    "clsx": "^2.1.1",
    "tailwind-merge": "^3.3.0"
  },
  "devDependencies": {
    "@eslint/eslintrc": "^3.3.0",
    "typescript": "^5.9.0",
    "@types/node": "^22.0.0",
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "tailwindcss": "^4.1.0",
    "@tailwindcss/postcss": "^4.1.0",
    "eslint": "^9.0.0",
    "eslint-config-next": "^15.5.0"
  }
}
```

### tsconfig.json
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "bundler",
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    },
    "jsx": "preserve"
  },
  "include": ["src"],
  "exclude": ["node_modules"]
}
```

### next.config.ts
```typescript
import type { NextConfig } from 'next';

const config: NextConfig = {
  reactStrictMode: true,
};

export default config;
```

### tailwind.config.ts
```typescript
import type { Config } from 'tailwindcss';

export default {
  content: ['./src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#227869',
        secondary: '#1F4137',
      },
      spacing: {
        safe: 'env(safe-area-inset-bottom)',
      },
    },
  },
  plugins: [],
} satisfies Config;
```

### postcss.config.mjs
```javascript
export default {
  plugins: {
    '@tailwindcss/postcss': {},
  },
};
```

### .env.example
```
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
RESEND_API_KEY=your-resend-api-key-here
NEXT_PUBLIC_DEMO_MODE=false
NEXT_PUBLIC_APP_URL=http://127.0.0.1:3000
```

---

## PACKAGE DEPENDENCIES

### Core Dependencies
- **next@^15.5.0** - React framework with App Router
- **react@^19.1.0** - UI library
- **react-dom@^19.1.0** - DOM rendering
- **@supabase/supabase-js@^2.57.0** - Backend as a Service
- **typescript@^5.9.0** - Type safety
- **tailwindcss@^4.1.0** - Utility-first CSS framework
- **lucide-react@^0.468.0** - Icon library
- **clsx@^2.1.1** - Conditional CSS classes
- **tailwind-merge@^3.3.0** - Merge Tailwind classes

---

## DATABASE SCHEMA & MIGRATIONS

### Migration 001: schoolhub.sql
Base schema with core tables:
- `profiles` - User information
- `user_roles` - User type (Student/Representative/Owner)
- `organizations` - Clubs/teams
- `organization_representatives` - Assignments
- `categories` - Event categories
- `events` - Calendar events
- `favorites` - Enrolled events
- `settings` - App-wide settings

### Migration 002: schoolcentral_brand.sql
Rebranding from Schoolhub to SchoolCentral

### Migration 003: representative_applications.sql
Representative application workflow:
- `approved_teachers` - Authorized teacher emails
- `representative_applications` - Application records
- `teacher_approval_tokens` - Email verification links
- Functions: `submit_representative_application`, `review_teacher_application`, `finalize_representative_application`

### Migration 004: teacher_directory_search.sql
Full-text search for teacher directory

### Migration 005: event_notifications.sql
Event change notifications:
- `event_notification_preferences` - User opt-in settings
- `event_notification_queue` - Pending notifications
- Trigger: `queue_event_changes` - Captures updates/deletes

### Migration 006: reminder_time.sql
Adds `reminder_minutes` to preferences (5, 10, 15, 30 min; 1, 2, 6, 12, 24 hours)

### Migration 007: accepted_application_status.sql
Adds `accepted` status to applications

### Migration 008: fix_org_creation.sql
Fixes duplicate organization name handling - reuses existing orgs

---

## CORE TYPESCRIPT TYPES

### src/domain/types.ts
```typescript
export type Profile = {
  id: string;
  name: string;
  email: string;
  role: 'Student' | 'Representative' | 'Owner';
  active: boolean;
  created_at: string;
};

export type Organization = {
  id: string;
  name: string;
  description: string;
  created_at: string;
};

export type Category = {
  id: string;
  name: string;
  color: string;
};

export type Event = {
  id: string;
  organization_id: string;
  category_id: string;
  title: string;
  description: string;
  starts_at: string;
  ends_at: string;
  all_day: boolean;
  location: string;
  external_url: string;
  status: 'draft' | 'published';
  created_by: string;
  updated_by: string;
  created_at: string;
  updated_at: string;
};

export type Favorite = {
  user_id: string;
  event_id: string;
};

export type RepresentativeApplication = {
  id: string;
  user_id: string;
  applicant_name: string;
  club_name: string;
  description: string;
  teacher_email: string;
  status: 'pending_teacher' | 'teacher_approved' | 'teacher_rejected' | 'approved' | 'rejected' | 'accepted';
  created_at: string;
  teacher_reviewed_at: string | null;
  owner_reviewed_at: string | null;
  organization_id: string | null;
};

export type ApprovedTeacher = {
  email: string;
  name: string;
};

export type Settings = {
  school_name: string;
  timezone: string;
  notification_email: string;
  reminders_enabled: boolean;
  reminder_minutes: number;
  event_changes_enabled: boolean;
};

export type State = {
  profiles: Profile[];
  organizations: Organization[];
  categories: Category[];
  events: Event[];
  favorites: Favorite[];
  applications: RepresentativeApplication[];
  teachers: ApprovedTeacher[];
  assignments: Array<{ user_id: string; organization_id: string }>;
  settings: Settings | null;
};
```

### src/domain/applications.ts
```typescript
export function validateApplication(input: unknown) {
  if (typeof input !== 'object' || !input) throw Error('Application required');
  const app = input as Record<string, unknown>;
  
  if (typeof app.club_name !== 'string' || !/^.{2,120}$/.test(app.club_name)) {
    throw Error('Club name must be 2–120 characters');
  }
  if (typeof app.description !== 'string' || !/^.{10,1000}$/.test(app.description)) {
    throw Error('Description must be 10–1000 characters');
  }
  if (typeof app.teacher_email !== 'string' || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(app.teacher_email)) {
    throw Error('Valid teacher email required');
  }
}
```

---

## DATA LAYER (SUPABASE CLIENT)

### src/data/supabase.ts
```typescript
import { createClient, createServiceRoleClient } from '@supabase/supabase-js';

const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!url || !key) {
  if (typeof window === 'undefined') {
    console.warn('Supabase credentials missing. Running in demo mode.');
  }
}

export const db = url && key ? createClient(url, key) : null;
export const dbAdmin = url && serviceKey ? createServiceRoleClient(url, serviceKey) : null;

export const demo = process.env.NEXT_PUBLIC_DEMO_MODE === 'true' && typeof window !== 'undefined';
```

### src/data/repository.ts
```typescript
import { db } from './supabase';
import type { State } from '@/domain/types';

export async function loadState(): Promise<State> {
  if (!db) return getInitialState();
  
  const [
    { data: profiles = [] },
    { data: organizations = [] },
    { data: categories = [] },
    { data: events = [] },
    { data: favorites = [] },
    { data: applications = [] },
    { data: teachers = [] },
  ] = await Promise.all([
    db.from('profiles').select('*'),
    db.from('organizations').select('*'),
    db.from('categories').select('*'),
    db.from('events').select('*'),
    db.from('favorites').select('*'),
    db.from('representative_applications').select('*'),
    db.from('approved_teachers').select('*'),
  ]);

  return {
    profiles: profiles.map(p => ({
      ...p,
      role: p.role?.[0]?.toUpperCase() + p.role?.slice(1) || 'Student'
    })),
    organizations,
    categories: categories || [],
    events: events || [],
    favorites: favorites || [],
    applications: applications || [],
    teachers: teachers || [],
    assignments: [],
    settings: null,
  };
}

function getInitialState(): State {
  return {
    profiles: [],
    organizations: [],
    categories: [],
    events: [],
    favorites: [],
    applications: [],
    teachers: [],
    assignments: [],
    settings: null,
  };
}
```

---

## FRONTEND COMPONENTS

### src/components/schoolhub.tsx
Main app component managing all state and navigation.

### src/components/account-settings.tsx
User profile settings, notification preferences, representative application form.

### src/components/representative-applications.tsx
Displays applications and approval workflow for both students and owners.

### src/components/catalog-editor.tsx
Owner interface for managing organizations, categories, and events.

### src/components/teacher-picker.tsx
Searchable dropdown for selecting authorized teachers.

### src/components/ui/button.tsx
Reusable button component with variant support (solid, outline, etc.)

---

## API ROUTES (BACKEND)

All routes require authentication via Supabase JWT token.

### POST /api/representative-applications
Submit or resend representative application.
- Input: `club_name`, `description`, `teacher_email`
- Output: `application_id`, confirmation message

### POST /api/teacher-review
Teacher approval/rejection via signed token.
- Input: `token` (from email), `action` ('approve' or 'decline')
- Output: Success message

### POST /api/accept-representative
Student accepts representative role.
- Input: `application_id`
- Output: Upgrade confirmation, auto-creates organization if needed

### POST /api/teacher-management
Owner manages authorized teacher list.
- Input: `action` ('add' or 'remove'), `email`, `name`

### POST /api/event-notifications
Handle notification delivery webhook (Resend).

### POST /api/reset
Development helper - reset application to initial state.

### POST /api/cleanup
Development helper - clean up test data.

---

## STYLING & UI

### Design System
- **Colors**: Primary #227869, Secondary #1F4137
- **Framework**: Tailwind CSS with utility-first approach
- **Responsive**: Mobile-first with breakpoints
- **Layout**: Bottom navigation on mobile, sidebar on desktop
- **Accessibility**: WCAG 2.1 compliant with proper ARIA labels

### Component Library
- Button component with variants
- Form inputs with validation
- Modal/dialog system
- Navigation (mobile bottom nav, desktop sidebar)
- Grid/list views for events and applications

---

## ENVIRONMENT SETUP

### Prerequisites
- Node.js 18+ (recommend 20+)
- pnpm (or npm/yarn)
- Supabase account with project
- Resend account (for production emails)

### Installation Steps
```bash
# Clone repository
git clone <repo-url>
cd schoolcentral

# Install dependencies
pnpm install

# Create .env.local
cp .env.example .env.local
# Edit .env.local with your Supabase credentials

# Run migrations
pnpm exec supabase db push

# Start development server
pnpm dev

# Application available at http://127.0.0.1:3000
```

### Database Setup
1. Create Supabase project
2. Run migrations in order (001-008)
3. (Optional) Add seed data with bootstrap-owner.sql
4. Configure approved teachers in admin panel

### Deployment (Vercel)
```bash
git push origin main
# Vercel auto-deploys from GitHub
```

---

## KEY FEATURES IMPLEMENTED

1. **Authentication**
   - Supabase Auth with email/password
   - Three roles: Student, Representative, Owner
   - Session persistence across page refresh

2. **Representative Applications**
   - Students submit club applications
   - Teachers review and approve via secure email links
   - Owners make final approval decisions
   - Auto-creation of organization on acceptance
   - One-time button that disappears after use

3. **Organization Management**
   - Create/edit/delete clubs
   - Assign representatives
   - Event scheduling and publishing
   - Category management with color coding

4. **Calendar & Events**
   - Month view with day selection
   - Filter by organization/category
   - All-day and timed events
   - Event enrollment (favorites)
   - Draft/published status control

5. **User Settings**
   - Separate notification email from login email
   - Notification timing preferences (5m to 24h)
   - Event change notifications
   - Display preferences (timezone, date format, density)

6. **Admin Dashboard**
   - User management
   - Organization overview
   - Application review queue
   - Teacher directory maintenance

7. **PWA Features**
   - Service worker for offline support
   - Manifest for installability
   - Responsive design for mobile/tablet/desktop

---

## IMPORTANT NOTES FOR REPLICATION

### Known Issues & Workarounds
1. **Organization name duplicates**: Migration 008 handles reusing existing orgs instead of failing
2. **Git not in PATH**: You may need to install Git for Windows or configure PowerShell execution
3. **Supabase UI SQL editor**: Sometimes has syntax highlighting issues; use SQL directly via API when needed

### Database Constraints
- `organizations.name` is UNIQUE - no duplicate club names
- `user_roles` has UNIQUE constraint on Owner role (only one Owner)
- All deletions respect foreign key constraints (cascade/restrict)

### Security
- All authenticated endpoints use Supabase JWT validation
- RLS (Row Level Security) policies enforce data visibility
- Service role required for admin operations
- Teacher approval tokens are hashed and time-limited

### Testing
- Run: `pnpm test`
- Includes domain validation tests
- Application workflow integration tests

---

## QUICK START COMMANDS

```bash
# Development
pnpm dev              # Start dev server on http://127.0.0.1:3000

# Testing & Quality
pnpm typecheck        # TypeScript type checking
pnpm lint            # ESLint check
pnpm test            # Run tests

# Production
pnpm build           # Build for production
pnpm start           # Start production server

# Database
pnpm exec supabase db push    # Push migrations to Supabase
pnpm exec supabase db reset   # Reset database (dev only)
```

---

## DEPLOYMENT CHECKLIST

- [ ] All environment variables configured
- [ ] Database migrations applied
- [ ] Supabase RLS policies enabled
- [ ] At least one Owner account created
- [ ] Teachers added to approved list
- [ ] Resend API key configured (for emails)
- [ ] Custom domain configured (optional)
- [ ] SSL certificate valid
- [ ] Error monitoring setup (optional)
- [ ] Backup/restore procedures documented

---

**Last Updated**: October 2026  
**Status**: Production Ready  
**Support**: For issues or questions, refer to memory-bank/ documentation or GitHub issues.
