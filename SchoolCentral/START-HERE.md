# SchoolCentral GitHub handoff

This directory is the repository root: upload its contents to GitHub, rather than uploading the zip file.

1. Read memory-bank/README.md and memory-bank/active-context.md.
2. Install Node 22+ and pnpm; run pnpm install --frozen-lockfile.
3. Copy .env.example to .env.local. Set NEXT_PUBLIC_DEMO_MODE=true for the local demo, then pnpm dev.
4. For real accounts follow REAL-ACCOUNTS-SETUP.md; credentials and live backend are not included.
5. Copilot automatically receives .github/copilot-instructions.md. Tell it to read the memory-bank before continuing.

To initialize Git locally:
```sh
git init
git add .
git commit -m "Initial SchoolCentral source and handoff"
```
Create an empty GitHub repository, add its URL as origin and push using GitHub's instructions. No remote has been created by this handoff.

Dependencies/build outputs/private environment files and existing browser-local demo accounts were intentionally excluded. Existing source README and historical verification are preserved. The memory bank records current changes and limitations.
