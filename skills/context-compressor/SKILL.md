---
name: context-compressor
description: 컨텍스트를 압축하여 토큰 사용을 최적화합니다. "컨텍스트 압축", "토큰 절약", "요약", "정보 압축", "context compression", "token optimization", "summarize context" 등의 요청 시 사용합니다. 코드, 문서, 대화 컨텍스트의 정보 밀도를 높이면서 핵심 정보를 보존합니다.
---

# Context Compressor Skill

Compress context to maximize information density while preserving essential details.

## Purpose

Reduce token usage by intelligently compressing code, documentation, and conversation context without losing critical information.

## Techniques

### 1. Extractive Summarization

Extract key information from verbose content:

```markdown
# INPUT: Full error log (500 tokens)
Error: ECONNREFUSED 127.0.0.1:5432
    at TCPConnectWrap.afterConnect [as oncomplete] (net.js:1141:16)
    at Protocol._enqueue (/node_modules/pg/lib/protocol.js:156:12)
    ... (50 more lines)

# OUTPUT: Summary (30 tokens)
Error: `ECONNREFUSED 127.0.0.1:5432`
Cause: PostgreSQL connection refused
Location: `pg` driver, TCP connect phase
Action: Check if PostgreSQL is running on port 5432
```

### 2. Code Skeleton Extraction

Preserve structure, compress implementation:

```typescript
// INPUT: Full implementation (400 tokens)
export class OrderService {
  private repository: OrderRepository;
  private eventBus: EventBus;
  private validator: OrderValidator;

  constructor(
    repository: OrderRepository,
    eventBus: EventBus,
    validator: OrderValidator
  ) {
    this.repository = repository;
    this.eventBus = eventBus;
    this.validator = validator;
  }

  async createOrder(input: CreateOrderInput): Promise<Order> {
    const validationResult = await this.validator.validate(input);
    if (!validationResult.isValid) {
      throw new ValidationError(validationResult.errors);
    }
    const order = Order.create(input);
    await this.repository.save(order);
    await this.eventBus.publish(new OrderCreatedEvent(order));
    return order;
  }

  async cancelOrder(orderId: string): Promise<void> {
    // ... 30 more lines
  }
}

// OUTPUT: Skeleton (80 tokens)
class OrderService {
  deps: repository, eventBus, validator

  createOrder(input) → Order
    validates → creates → saves → publishes event

  cancelOrder(orderId) → void
    finds → validates cancellable → updates status → publishes

  getOrder(orderId) → Order | null
    cache-first lookup
}
```

### 3. Delta Compression

Show only what changed:

```markdown
# INPUT: Full before/after (200 tokens)
// Before
async function fetchUser(id) {
  const response = await fetch(`/api/users/${id}`);
  const data = await response.json();
  return data;
}

// After
async function fetchUser(id) {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) {
    throw new Error(`Failed to fetch user: ${response.status}`);
  }
  const data = await response.json();
  return data;
}

# OUTPUT: Delta (40 tokens)
`fetchUser`: Added error handling
- Check `response.ok` before parsing
- Throw with status code on failure
```

### 4. Reference Substitution

Replace repeated references with shorthand:

```markdown
# INPUT: Verbose references
The UserAuthenticationService in src/services/auth/UserAuthenticationService.ts
calls the TokenValidationService in src/services/auth/TokenValidationService.ts
which depends on the JWTService in src/services/auth/JWTService.ts...

# OUTPUT: With references
Services (all in src/services/auth/):
- UAS: UserAuthenticationService
- TVS: TokenValidationService
- JWT: JWTService

Flow: UAS → TVS → JWT for token validation
```

### 5. Semantic Chunking

Group related information:

```markdown
# INPUT: Scattered information
Line 45: User model defined
Line 123: User validation
Line 89: User repository
Line 200: User controller
Line 156: User service

# OUTPUT: Grouped
User module structure:
- Model (L45) → Validation (L123)
- Repository (L89) → Service (L156) → Controller (L200)
```

## Compression Levels

| Level | Ratio | Use Case |
|-------|-------|----------|
| Light | 2:1 | Normal context, preserve detail |
| Medium | 4:1 | Large contexts, key info only |
| Heavy | 10:1 | Context overflow, essence only |

## Application Guidelines

### When to Compress

- Context approaching 60% capacity
- Repeated file reads
- Large tool outputs
- Historical conversation context

### What NOT to Compress

- Active code being edited
- Error messages being debugged
- User requirements/specifications
- Security-sensitive information

## Commands

```markdown
/compress [level] [target]

Examples:
/compress light file:src/services/UserService.ts
/compress medium conversation
/compress heavy all
```

## Output Format

```markdown
## Compressed Context

### Original Size: [X] tokens
### Compressed Size: [Y] tokens
### Compression Ratio: [X:Y]

### Compressed Content
[Compressed output]

### Key Details Preserved
- [Detail 1]
- [Detail 2]

### Omitted (retrievable if needed)
- [What was removed]
```

---

## 🔧 실제 구현 (Implementation)

### Context Compressor (TypeScript)

```typescript
// context-compressor.ts
import tiktoken from 'tiktoken';

interface CompressionOptions {
  level: 'light' | 'medium' | 'heavy';
  preserveCodeStructure: boolean;
  preserveLineNumbers: boolean;
  maxTokens?: number;
}

interface CompressionResult {
  compressed: string;
  originalTokens: number;
  compressedTokens: number;
  compressionRatio: number;
  techniques: string[];
  preserved: string[];
  omitted: string[];
}

export class ContextCompressor {
  private encoder: tiktoken.Tiktoken;

  constructor() {
    this.encoder = tiktoken.encoding_for_model('gpt-4');
  }

  /**
   * Main compression entry point
   */
  compress(
    content: string,
    options: CompressionOptions = { level: 'medium', preserveCodeStructure: true, preserveLineNumbers: true }
  ): CompressionResult {
    const originalTokens = this.countTokens(content);
    const techniques: string[] = [];
    const preserved: string[] = [];
    const omitted: string[] = [];

    let compressed = content;

    // Apply compression techniques based on level
    if (options.level === 'light' || options.level === 'medium' || options.level === 'heavy') {
      // 1. Reference Substitution
      const { result: refSubstituted, replaced } = this.applyReferenceSubstitution(compressed);
      compressed = refSubstituted;
      techniques.push('Reference Substitution');
      preserved.push(...replaced.map(r => `${r.original} → ${r.shortened}`));
    }

    if (options.level === 'medium' || options.level === 'heavy') {
      // 2. Code Skeleton Extraction
      if (this.isCode(content)) {
        const { skeleton, details } = this.extractCodeSkeleton(compressed, options);
        compressed = skeleton;
        techniques.push('Code Skeleton Extraction');
        preserved.push('Function signatures', 'Class structure', 'Important logic');
        omitted.push(...details);
      }
    }

    if (options.level === 'heavy') {
      // 3. Aggressive Delta Compression
      compressed = this.applyDeltaCompression(compressed);
      techniques.push('Delta Compression');
      omitted.push('Verbose descriptions', 'Redundant examples');
    }

    const compressedTokens = this.countTokens(compressed);
    const compressionRatio = originalTokens / compressedTokens;

    return {
      compressed,
      originalTokens,
      compressedTokens,
      compressionRatio,
      techniques,
      preserved,
      omitted
    };
  }

  /**
   * Technique 1: Reference Substitution
   */
  private applyReferenceSubstitution(content: string): {
    result: string;
    replaced: Array<{ original: string; shortened: string }>;
  } {
    const replacements: Array<{ original: string; shortened: string }> = [];
    let result = content;

    // Long file paths
    const filePathRegex = /(\w+\/)+(\w+\.\w+)/g;
    result = result.replace(filePathRegex, (match) => {
      const parts = match.split('/');
      if (parts.length > 3) {
        const shortened = `.../${parts[parts.length - 2]}/${parts[parts.length - 1]}`;
        replacements.push({ original: match, shortened });
        return shortened;
      }
      return match;
    });

    // Long class/function names (repeated)
    const nameFrequency = new Map<string, number>();
    const nameRegex = /\b([A-Z][a-zA-Z0-9]{15,})\b/g;
    let match;

    while ((match = nameRegex.exec(content)) !== null) {
      const name = match[1];
      nameFrequency.set(name, (nameFrequency.get(name) || 0) + 1);
    }

    // Replace frequently used long names
    nameFrequency.forEach((count, name) => {
      if (count >= 3) {
        const shortened = this.abbreviate(name);
        result = result.replace(new RegExp(`\\b${name}\\b`, 'g'), shortened);
        replacements.push({ original: name, shortened });
      }
    });

    return { result, replaced: replacements };
  }

  /**
   * Technique 2: Code Skeleton Extraction
   */
  private extractCodeSkeleton(code: string, options: CompressionOptions): {
    skeleton: string;
    details: string[];
  } {
    const lines = code.split('\n');
    const skeleton: string[] = [];
    const omittedDetails: string[] = [];

    let inFunction = false;
    let functionName = '';
    let braceCount = 0;

    lines.forEach((line, index) => {
      const trimmed = line.trim();

      // Class declaration
      if (trimmed.startsWith('class ') || trimmed.startsWith('interface ')) {
        skeleton.push(line);
        return;
      }

      // Function/method signature
      if (this.isFunctionSignature(trimmed)) {
        functionName = this.extractFunctionName(trimmed);
        skeleton.push(line);
        inFunction = true;
        braceCount = (line.match(/{/g) || []).length - (line.match(/}/g) || []).length;
        return;
      }

      // Inside function
      if (inFunction) {
        braceCount += (line.match(/{/g) || []).length - (line.match(/}/g) || []).length;

        // Only keep important lines
        if (this.isImportantLine(trimmed)) {
          if (options.preserveLineNumbers) {
            skeleton.push(`    // line ${index + 1}: ${this.summarizeLine(trimmed)}`);
          } else {
            skeleton.push(`    ${this.summarizeLine(trimmed)}`);
          }
        } else {
          omittedDetails.push(`${functionName}: ${trimmed}`);
        }

        if (braceCount === 0) {
          inFunction = false;
          skeleton.push('');  // Empty line after function
        }
      }
    });

    return {
      skeleton: skeleton.join('\n'),
      details: omittedDetails
    };
  }

  /**
   * Technique 3: Delta Compression
   */
  private applyDeltaCompression(content: string): string {
    let compressed = content;

    // Remove verbose descriptions
    compressed = compressed.replace(/\n\s*\/\/\s+.{100,}\n/g, '\n');

    // Compress repeated patterns
    compressed = compressed.replace(/(\n\s*console\.log\([^)]+\);\s*)+/g, '\n    // [logging statements omitted]\n');

    // Remove excessive whitespace
    compressed = compressed.replace(/\n{3,}/g, '\n\n');

    return compressed;
  }

  /**
   * Auto-trigger based on context usage
   */
  autoCompress(content: string, contextUsage: number): CompressionResult | null {
    // Context zones (from token-efficiency.md)
    if (contextUsage < 0.6) {
      return null;  // Safe zone, no compression needed
    }

    if (contextUsage >= 0.6 && contextUsage < 0.8) {
      // Caution zone: light compression
      return this.compress(content, {
        level: 'light',
        preserveCodeStructure: true,
        preserveLineNumbers: true
      });
    }

    if (contextUsage >= 0.8 && contextUsage < 0.9) {
      // Critical zone: medium compression
      return this.compress(content, {
        level: 'medium',
        preserveCodeStructure: true,
        preserveLineNumbers: false
      });
    }

    // Danger zone (>90%): heavy compression
    return this.compress(content, {
      level: 'heavy',
      preserveCodeStructure: false,
      preserveLineNumbers: false
    });
  }

  /**
   * Measure compression quality
   */
  measureQuality(original: string, compressed: string): {
    tokenSavings: number;
    informationRetention: number;
    score: number;
  } {
    const originalTokens = this.countTokens(original);
    const compressedTokens = this.countTokens(compressed);
    const tokenSavings = (1 - compressedTokens / originalTokens) * 100;

    // Simple information retention heuristic
    // (In practice, use more sophisticated metrics)
    const originalKeywords = this.extractKeywords(original);
    const compressedKeywords = this.extractKeywords(compressed);
    const retainedKeywords = originalKeywords.filter(k => compressedKeywords.includes(k));
    const informationRetention = (retainedKeywords.length / originalKeywords.length) * 100;

    // Quality score: balance between compression and retention
    const score = (tokenSavings * 0.4) + (informationRetention * 0.6);

    return {
      tokenSavings,
      informationRetention,
      score
    };
  }

  // Helper methods
  private countTokens(text: string): number {
    return this.encoder.encode(text).length;
  }

  private isCode(content: string): boolean {
    const codeIndicators = [
      'function ', 'class ', 'const ', 'let ', 'var ',
      'import ', 'export ', 'async ', 'await '
    ];
    return codeIndicators.some(indicator => content.includes(indicator));
  }

  private isFunctionSignature(line: string): boolean {
    return /^(export\s+)?(async\s+)?function\s+/.test(line) ||
           /^(public|private|protected)?\s*(async\s+)?\w+\s*\([^)]*\)\s*({|:)/.test(line);
  }

  private extractFunctionName(line: string): string {
    const match = line.match(/function\s+(\w+)/) || line.match(/(\w+)\s*\(/);
    return match ? match[1] : 'unknown';
  }

  private isImportantLine(line: string): boolean {
    const importantKeywords = [
      'return', 'throw', 'await', 'fetch', 'axios',
      'if (', 'for (', 'while (', 'switch (',
      'console.error', 'logger.'
    ];
    return importantKeywords.some(keyword => line.includes(keyword));
  }

  private summarizeLine(line: string): string {
    // Remove verbose comments
    let summary = line.replace(/\/\/.*$/, '').trim();

    // Shorten long strings
    summary = summary.replace(/"[^"]{50,}"/g, '"..."');
    summary = summary.replace(/'[^']{50,}'/g, "'...'");

    return summary || line;
  }

  private abbreviate(name: string): string {
    // CamelCase to acronym: UserAuthenticationService → UAS
    const words = name.match(/[A-Z][a-z]+/g);
    if (words && words.length > 2) {
      return words.map(w => w[0]).join('');
    }
    // Otherwise, just take first 8 chars
    return name.substring(0, 8);
  }

  private extractKeywords(text: string): string[] {
    // Extract important words (simplified)
    return text
      .toLowerCase()
      .match(/\b\w{4,}\b/g) || [];
  }
}

// CLI Usage
export async function compressContext(
  inputFile: string,
  level: 'light' | 'medium' | 'heavy' = 'medium'
): Promise<void> {
  const fs = require('fs');
  const content = fs.readFileSync(inputFile, 'utf-8');

  const compressor = new ContextCompressor();
  const result = compressor.compress(content, {
    level,
    preserveCodeStructure: true,
    preserveLineNumbers: level !== 'heavy'
  });

  // Output
  console.log('🗜️  Context Compression Results\n');
  console.log(`Original: ${result.originalTokens} tokens`);
  console.log(`Compressed: ${result.compressedTokens} tokens`);
  console.log(`Ratio: ${result.compressionRatio.toFixed(2)}x`);
  console.log(`Savings: ${((1 - 1/result.compressionRatio) * 100).toFixed(1)}%\n`);

  console.log('Techniques applied:');
  result.techniques.forEach(t => console.log(`  - ${t}`));

  // Write compressed output
  const outputFile = inputFile.replace(/(\.\w+)$/, '.compressed$1');
  fs.writeFileSync(outputFile, result.compressed);
  console.log(`\n📄 Output: ${outputFile}`);

  // Quality metrics
  const quality = compressor.measureQuality(content, result.compressed);
  console.log(`\n📊 Quality Score: ${quality.score.toFixed(1)}/100`);
  console.log(`   Token Savings: ${quality.tokenSavings.toFixed(1)}%`);
  console.log(`   Info Retention: ${quality.informationRetention.toFixed(1)}%`);
}

// Auto-trigger integration
export function setupAutoCompression(contextProvider: any): void {
  contextProvider.on('contextUpdate', (context: any) => {
    const usage = context.tokens / context.maxTokens;
    const compressor = new ContextCompressor();

    const result = compressor.autoCompress(context.content, usage);
    if (result) {
      console.log(`\n⚠️  Context usage: ${(usage * 100).toFixed(1)}%`);
      console.log(`🗜️  Auto-compression applied: ${result.techniques.join(', ')}`);
      console.log(`   Saved ${result.originalTokens - result.compressedTokens} tokens\n`);

      context.content = result.compressed;
    }
  });
}
```

### Package.json

```json
{
  "name": "context-compressor",
  "version": "1.0.0",
  "description": "Intelligent context compression for LLMs",
  "main": "dist/index.js",
  "bin": {
    "context-compress": "dist/cli.js"
  },
  "scripts": {
    "build": "tsc",
    "compress": "ts-node src/context-compressor.ts"
  },
  "dependencies": {
    "tiktoken": "^1.0.10"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.3.0",
    "ts-node": "^10.9.0"
  }
}
```

### CLI Usage

```bash
# Install
npm install -g context-compressor

# Compress a file
context-compress large-file.ts --level medium

# Output:
# 🗜️  Context Compression Results
#
# Original: 5000 tokens
# Compressed: 1200 tokens
# Ratio: 4.17x
# Savings: 76.0%
#
# Techniques applied:
#   - Reference Substitution
#   - Code Skeleton Extraction
#
# 📄 Output: large-file.compressed.ts
#
# 📊 Quality Score: 85.3/100
#    Token Savings: 76.0%
#    Info Retention: 90.4%
```

---

**버전**: 2.0 (구현 추가)
**최종 수정**: 2026-01-29 (압축 로직 구현 완료)
