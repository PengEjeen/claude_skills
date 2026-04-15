# Security

globs: ['**/*.ts', '**/*.js', '**/*.py', '**/*.go', '**/*.rs', '**/Dockerfile', '**/*.yaml', '**/*.yml']

## Pre-Commit Checklist
- [ ] No hardcoded secrets (use env vars, .env in .gitignore)
- [ ] All user inputs validated and sanitized
- [ ] SQL: parameterized queries only
- [ ] XSS: sanitized HTML output
- [ ] CSRF protection enabled
- [ ] Auth/authz on all non-public endpoints
- [ ] Rate limiting on all endpoints
- [ ] Error messages don't leak internals

## OWASP API Top Risks
- **BOLA**: Always check object ownership before returning data
- **BFLA**: Admin endpoints require role check middleware
- **Mass Assignment**: Whitelist allowed fields, never pass req.body directly
- **Data Exposure**: Use DTOs, return only necessary fields
- **Rate Limiting**: Global + strict limits on auth endpoints

## Response Protocol
1. STOP on security issue discovery
2. Use **security-reviewer** agent
3. Fix CRITICAL before continuing
4. Rotate exposed secrets immediately

For detailed implementation patterns (secret management, K8s secrets, rotation, scanning), use `/security-audit` skill.
