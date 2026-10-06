---
paths:
  - "package.json"
  - "package-lock.json"
  - "yarn.lock"
  - "pnpm-lock.yaml"
  - "bun.lockb"
---
# When Modifying package.json / Lockfiles
- Install with the frozen-lockfile flag (`npm ci`, `yarn --frozen-lockfile`, `pnpm i --frozen-lockfile`); never hand-edit a lockfile
- Detect the package manager from the lockfile — `package-lock.json` → npm, `yarn.lock` → yarn,
  `pnpm-lock.yaml` → pnpm, `bun.lockb` → bun — and use only that one
