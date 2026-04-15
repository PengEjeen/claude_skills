# Database Schema Design (2026)

ERD generation, schema design, migrations, and query optimization for SQL and NoSQL databases.

## Context

Use this skill when designing database schemas, creating migrations, optimizing queries, or establishing database best practices.

---

## Schema Design Principles

### 1. Normalization

**3NF (Third Normal Form) - Standard for most applications:**
```sql
-- ✅ GOOD: Normalized
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id),
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- ❌ BAD: Denormalized (redundant user data)
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  user_email VARCHAR(255),  -- Redundant
  user_name VARCHAR(100),   -- Redundant
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL
);
```

### 2. Indexing Strategy

```sql
-- Primary key (automatic index)
id SERIAL PRIMARY KEY

-- Unique constraint (automatic index)
email VARCHAR(255) UNIQUE NOT NULL

-- Foreign key index
CREATE INDEX idx_posts_user_id ON posts(user_id);

-- Composite index for common queries
CREATE INDEX idx_posts_user_created ON posts(user_id, created_at DESC);

-- Partial index for filtered queries
CREATE INDEX idx_active_users ON users(email) WHERE deleted_at IS NULL;

-- Full-text search index (PostgreSQL)
CREATE INDEX idx_posts_search ON posts USING GIN(to_tsvector('english', title || ' ' || content));
```

---

## Common Patterns

### Soft Delete

```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  deleted_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Query only active users
SELECT * FROM users WHERE deleted_at IS NULL;

-- Soft delete
UPDATE users SET deleted_at = NOW() WHERE id = 123;
```

### Timestamps

```sql
-- Always include
created_at TIMESTAMP DEFAULT NOW() NOT NULL,
updated_at TIMESTAMP DEFAULT NOW() NOT NULL

-- Auto-update trigger (PostgreSQL)
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

### Many-to-Many Relationships

```sql
-- Junction table
CREATE TABLE user_roles (
  user_id INT REFERENCES users(id) ON DELETE CASCADE,
  role_id INT REFERENCES roles(id) ON DELETE CASCADE,
  assigned_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (user_id, role_id)
);

CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role_id);
```

---

## Migrations

### Migration Template

```sql
-- migrations/001_create_users_table.sql
-- UP
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_users_email ON users(email);

-- DOWN
DROP TABLE IF EXISTS users;
```

### TypeScript Migration (Prisma example)

```typescript
// prisma/migrations/20260101_create_users/migration.sql
-- CreateTable
CREATE TABLE "User" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
```

---

## Query Optimization

### Use EXPLAIN ANALYZE

```sql
EXPLAIN ANALYZE
SELECT u.name, COUNT(p.id) as post_count
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
WHERE u.created_at > '2024-01-01'
GROUP BY u.id, u.name
ORDER BY post_count DESC
LIMIT 10;
```

### Common Optimizations

```sql
-- ❌ BAD: N+1 query problem
SELECT * FROM users;
-- Then for each user:
SELECT * FROM posts WHERE user_id = ?;

-- ✅ GOOD: Single query with join
SELECT u.*, p.*
FROM users u
LEFT JOIN posts p ON p.user_id = u.id;

-- ❌ BAD: SELECT *
SELECT * FROM users;

-- ✅ GOOD: Select only needed columns
SELECT id, email, name FROM users;

-- ❌ BAD: No index on WHERE clause
SELECT * FROM posts WHERE user_id = 123;

-- ✅ GOOD: Index on user_id
CREATE INDEX idx_posts_user_id ON posts(user_id);
```

---

## Schema Evolution

### Adding Columns (Safe)

```sql
-- Add nullable column (safe, no rewrite)
ALTER TABLE users ADD COLUMN bio TEXT NULL;

-- Add column with default (PostgreSQL 11+, no rewrite)
ALTER TABLE users ADD COLUMN verified BOOLEAN DEFAULT FALSE;
```

### Removing Columns (Risky)

```sql
-- Step 1: Stop using the column in code
-- Step 2: Deploy code
-- Step 3: Remove column
ALTER TABLE users DROP COLUMN old_field;
```

### Renaming (2-step deploy)

```sql
-- Step 1: Add new column, copy data
ALTER TABLE users ADD COLUMN full_name VARCHAR(100);
UPDATE users SET full_name = name;

-- Deploy code to use full_name

-- Step 2: Remove old column
ALTER TABLE users DROP COLUMN name;
```

---

## Checklist

- [ ] All tables have primary keys
- [ ] Foreign keys have indexes
- [ ] Unique constraints where needed
- [ ] Timestamps (created_at, updated_at)
- [ ] Soft delete pattern (deleted_at)
- [ ] Indexes for common queries
- [ ] No SELECT * in production
- [ ] Migrations are reversible
- [ ] No sensitive data in plain text
- [ ] Query performance tested (EXPLAIN)
- [ ] Proper NULL handling
- [ ] Cascading deletes configured

---

## Resources

- `migrations/` - Migration templates
- `examples/` - Common schema patterns
