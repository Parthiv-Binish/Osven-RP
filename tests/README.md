# Osven City — Test Framework

## Structure
- `unit/` — Lua unit tests for individual modules
- `integration/` — Multi-resource interaction tests
- `ui/` — NUI HTML/CSS validation

## Running Tests
```bash
# Lint all Lua files
lua tests/unit/lint.lua

# Validate NUI HTML structure
lua tests/ui/validate_html.lua
```

## Test Patterns
- All server events must validate `source` and never trust client data
- All rate-limited endpoints must reject rapid requests
- NUI callbacks must handle timeout and error states
