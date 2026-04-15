# /rust Command

Invoke Rust expert agent for systems programming assistance.

## Usage

```
/rust <action> [target]
```

## Actions

### review

Review Rust code for idiomatic patterns, safety, and performance:

```
/rust review src/lib.rs
```

**Output**:
```markdown
## Rust Review: src/lib.rs

### Summary
Overall: Good structure, some ownership patterns could improve.

### Ownership Issues
| Line | Issue | Fix |
|------|-------|-----|
| 45 | Unnecessary clone | Use reference |
| 89 | String allocation in loop | Reuse buffer |

### Error Handling
- ✅ Using thiserror for custom errors
- ⚠️ Line 123: unwrap() in production code

### Performance
- Line 67: Vec allocation in hot path
  → Consider `Vec::with_capacity()`
- Line 145: String concatenation
  → Use `format!` or `String::push_str`

### Safety
- No unsafe blocks ✅
- All error paths handled ✅
```

### unsafe-audit

Deep audit of unsafe code blocks:

```
/rust unsafe-audit src/ffi.rs
```

**Output**:
```markdown
## Unsafe Audit: src/ffi.rs

### Unsafe Blocks Found: 3

### Block 1 (Line 34-42)
```rust
unsafe {
    let ptr = allocate(size);
    std::ptr::write(ptr, value);
}
```

**Risk Level**: MEDIUM
**Invariants Required**:
- `size` must be non-zero
- `ptr` must be valid after allocation

**Recommendation**: Add safety comment documenting invariants

### Block 2 (Line 78-85)
```rust
unsafe { std::mem::transmute(data) }
```

**Risk Level**: HIGH
**Issue**: Transmute without size check
**Fix**: Use `try_from` or validate sizes match

### Summary
| Risk | Count |
|------|-------|
| HIGH | 1 |
| MEDIUM | 1 |
| LOW | 1 |
```

### lifetime

Analyze and explain lifetime issues:

```
/rust lifetime "error[E0597]: `x` does not live long enough"
```

**Output**:
```markdown
## Lifetime Analysis

### Error
`x` does not live long enough

### Explanation
The variable `x` is being borrowed, but its lifetime ends before
the borrow is used. This commonly happens when:
1. Returning a reference to a local variable
2. Storing a reference that outlives the data

### Your Code
```rust
fn get_ref() -> &str {
    let s = String::from("hello");
    &s  // Error: s is dropped here, but reference escapes
}
```

### Fix Options

**Option 1: Return owned data**
```rust
fn get_owned() -> String {
    String::from("hello")
}
```

**Option 2: Accept lifetime from caller**
```rust
fn get_ref<'a>(s: &'a str) -> &'a str {
    s
}
```

**Option 3: Use 'static if truly static**
```rust
fn get_static() -> &'static str {
    "hello"  // String literals are 'static
}
```
```

### async

Review async Rust code:

```
/rust async src/server.rs
```

**Output**:
```markdown
## Async Review: src/server.rs

### Runtime
Using: tokio (detected from Cargo.toml)

### Issues Found

#### Blocking in Async Context (Line 45)
```rust
async fn handle() {
    std::thread::sleep(Duration::from_secs(1));  // BLOCKS!
}
```
**Fix**: Use `tokio::time::sleep` instead

#### Unbounded Channel (Line 89)
```rust
let (tx, rx) = mpsc::unbounded_channel();
```
**Risk**: Memory exhaustion under load
**Fix**: Use bounded channel with backpressure

### Patterns Review
- ✅ Using `tokio::spawn` for concurrent tasks
- ✅ Using `select!` for cancellation
- ⚠️ No timeout on external calls (Line 123)

### Recommendations
1. Add timeout to HTTP client calls
2. Replace unbounded channels
3. Consider using `tokio::task::spawn_blocking` for CPU work
```

### cargo

Run cargo commands with enhanced output:

```
/rust cargo test
/rust cargo clippy
/rust cargo bench
```

### optimize

Performance optimization suggestions:

```
/rust optimize src/parser.rs
```

**Output**:
```markdown
## Performance Analysis: src/parser.rs

### Hot Paths Identified
1. `parse_tokens()` - called 10K+ times
2. `validate_node()` - recursive, deep trees

### Optimization Opportunities

#### 1. Reduce Allocations (Line 56)
```rust
// Current: Allocates on every call
fn process(s: &str) -> String {
    s.to_uppercase()
}

// Optimized: Reuse buffer
fn process_into(s: &str, buf: &mut String) {
    buf.clear();
    buf.extend(s.chars().map(|c| c.to_ascii_uppercase()));
}
```

#### 2. Use Iterator Instead of Collect (Line 89)
```rust
// Current: Collects then iterates
let items: Vec<_> = data.iter().map(transform).collect();
for item in items { ... }

// Optimized: Direct iteration
for item in data.iter().map(transform) { ... }
```

#### 3. Consider SIMD (Line 123)
Pattern matching over large byte arrays could benefit from SIMD.
Consider `memchr` crate for byte searching.

### Benchmarking Suggestion
```rust
#[bench]
fn bench_parse(b: &mut Bencher) {
    let input = include_str!("../fixtures/large.txt");
    b.iter(|| parse_tokens(input));
}
```
```

## Options

### --strict

Apply stricter linting rules:
```
/rust review --strict src/lib.rs
```

### --fix

Suggest automatic fixes where possible:
```
/rust review --fix src/lib.rs
```

### --edition

Specify Rust edition:
```
/rust review --edition 2024 src/lib.rs
```

## Quick Reference

```
/rust review <file>        # Full code review
/rust unsafe-audit <file>  # Audit unsafe blocks
/rust lifetime "<error>"   # Explain lifetime errors
/rust async <file>         # Review async code
/rust optimize <file>      # Performance suggestions
/rust cargo <command>      # Enhanced cargo commands
```
