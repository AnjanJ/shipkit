#!/bin/bash
# linkshort's shape at 69578a5: T1 touches a field whose decision cites only T2's requirements. The
# brief is brief.sh's own output, left in BRIEF.md, so this measures the brief on the tree. Runs only
# with --scaffold.
HERE=$(cd "$(dirname "$0")" && pwd)
S=.shipkit/specs/link-expiry
mkdir -p src/linkshort tests "$S"
cat > src/linkshort/models.py <<'PY'
from dataclasses import dataclass


@dataclass
class Link:
    code: str
    target: str
PY
cat > src/linkshort/service.py <<'PY'
from .models import Link


class InvalidTarget(ValueError):
    pass


class LinkService:
    def __init__(self) -> None:
        self.links: dict[str, Link] = {}

    def create(self, target: str, code: str) -> Link:
        if not target.startswith("http"):
            raise InvalidTarget(target)
        self.links[code] = Link(code=code, target=target)
        return self.links[code]
PY
cat > src/linkshort/api.py <<'PY'
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from .service import InvalidTarget, LinkService

app = FastAPI()
service = LinkService()


class CreateLink(BaseModel):
    target: str
    code: str


class LinkOut(BaseModel):
    code: str
    target: str


@app.post("/links", response_model=LinkOut, status_code=201)
def create_link(body: CreateLink) -> LinkOut:
    try:
        link = service.create(body.target, body.code)
    except InvalidTarget as e:
        raise HTTPException(status_code=422, detail=str(e))
    return LinkOut(code=link.code, target=link.target)
PY
printf 'from fastapi.testclient import TestClient\n\nfrom linkshort.api import app\n\nclient = TestClient(app)\n' > tests/test_api.py
cat > "$S/spec.md" <<'MD'
# Spec: Link expiry

> Spec accepted at commit `a5f1eb8` on main.
> Status: open
> Paths: src/linkshort/, tests/

## Purpose
A link can be created with an optional `expires_at`.

## Requirements (EARS)
- **REQ-1.** When `POST /links` is given a timezone-aware ISO 8601 `expires_at` in the future, the API shall create the link and return it with `expires_at` as an ISO 8601 string.
- **REQ-2.** Where `POST /links` omits `expires_at`, the API shall create a link that never expires and return `expires_at` as null.
- **REQ-3.** If `expires_at` on `POST /links` has no timezone, then the API shall answer 422 and create no link.
- **REQ-4.** If `expires_at` on `POST /links` is not later than the current UTC time, then the API shall answer 422 and create no link.
MD
cat > "$S/design.md" <<'MD'
# Design: Link expiry

## Decision: Injectable `now` on LinkService   (→ REQ-4)

**Decision.** A `now` argument, not freezegun.

## Decision: Expiry is checked in the service, not the endpoint   (→ REQ-4)

**Decision.** `resolve` raises `LinkExpired`.

## Decision: Reject bad `expires_at` in the service as a ValueError subclass   (→ REQ-3, REQ-4)

**Alternatives.**
1. `InvalidExpiry(ValueError)` raised in `create`, mapped to 422 in `api.py`.
2. A Pydantic validator on `CreateLink` for the naive check.
3. Pydantic's `AwareDatetime` type for the naive check.

**Decision.** We chose option 1.
MD
cat > "$S/tasks.md" <<'MD'
# Tasks: Link expiry

- [ ] **T1** Create a link with or without `expires_at` and show it in the response → REQ-1, REQ-2
  - Files: src/linkshort/models.py, src/linkshort/service.py, src/linkshort/api.py, tests/test_api.py
  - Test: tests/test_api.py::test_create_with_future_expires_at_returns_it
  - After: none
  - Done when: `pytest tests/test_api.py` → all pass
- [ ] **T2** Reject a naive or past `expires_at` with 422 → REQ-3, REQ-4
  - Files: src/linkshort/service.py, src/linkshort/api.py, tests/test_api.py
  - Test: tests/test_api.py::test_naive_expires_at_is_422
  - After: T1
  - Done when: `pytest tests/test_api.py` → all pass
MD
git init -q . && git add -A && git -c user.email=eval@example.com -c user.name=eval commit -q -m "initial commit"
sh "$HERE/../../../scripts/brief.sh" . link-expiry T1 > BRIEF.md
