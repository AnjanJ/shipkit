---
paths:
  - "**/models.py"
  - "**/views.py"
  - "**/serializers.py"
  - "**/migrations/**"
  - "**/settings*.py"
---
# Django Gotchas
- **N+1 queries:** Always use `select_related`/`prefetch_related` for associations in loops
- **Migration safety:** Never remove fields in the same deploy that removes code references
- **Forms/Serializers:** Validate all user input through forms (Django) or serializers (DRF)
- **Settings:** Use `django-environ` or similar — never hardcode secrets
- **Signals:** Avoid `post_save` for side effects — use service functions or tasks instead
