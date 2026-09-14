---
paths:
  - "package.json"
  - "package-lock.json"
  - "yarn.lock"
  - "pnpm-lock.yaml"
  - "bun.lockb"
---
# When Modifying package.json / Lockfiles
- Use caret `^` for compatible version ranges (default)
- After ANY change: run install with frozen lockfile check, then full test suite
- Run `npm audit` / `yarn audit` / `pnpm audit` to verify no new vulnerabilities
- Never manually edit lockfiles
- Detect package manager from lockfile: package-lock.json=npm, yarn.lock=yarn, pnpm-lock.yaml=pnpm, bun.lockb=bun
- Use the detected package manager consistently — don't mix npm and yarn commands
