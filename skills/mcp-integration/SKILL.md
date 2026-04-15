---
name: mcp-integration
description: Model Context Protocol(MCP) 서버를 설정하고 통합합니다. "MCP 설정", "MCP 서버", "도구 연동", "외부 서비스 연결", "MCP setup", "MCP server", "tool integration" 등의 요청 시 사용합니다. Claude의 외부 도구, 데이터베이스, 서비스 연동을 지원합니다.
---

# MCP Integration Skill

Model Context Protocol server setup and integration guide.

## Purpose

Configure and use MCP servers to extend Claude's capabilities with external tools, databases, and services.

## What is MCP?

Model Context Protocol (MCP) is an open standard for connecting AI models to external data sources and tools. It enables:

- **Resources**: Access to files, databases, APIs
- **Tools**: Execute actions in external systems
- **Prompts**: Reusable prompt templates

## Quick Start

### 1. Install MCP CLI

```bash
npm install -g @modelcontextprotocol/cli
```

### 2. Configure in Claude Code

Add to `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-filesystem", "/path/to/allowed/dir"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "your-token-here"
      }
    }
  }
}
```

## Popular MCP Servers

### Official Servers

| Server | Purpose | Install |
|--------|---------|---------|
| filesystem | File operations | `@anthropic/mcp-server-filesystem` |
| github | GitHub API | `@anthropic/mcp-server-github` |
| postgres | PostgreSQL | `@anthropic/mcp-server-postgres` |
| slack | Slack integration | `@anthropic/mcp-server-slack` |
| brave-search | Web search | `@anthropic/mcp-server-brave-search` |

### Community Servers

| Server | Purpose | Repo |
|--------|---------|------|
| sqlite | SQLite database | `@anthropic/mcp-server-sqlite` |
| memory | Persistent memory | `mcp-server-memory` |
| puppeteer | Browser automation | `mcp-server-puppeteer` |
| notion | Notion integration | `mcp-server-notion` |
| linear | Linear issues | `mcp-server-linear` |

## Configuration Examples

### Database Access

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb"
      }
    }
  }
}
```

### Multiple Servers

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-filesystem", "./src", "./docs"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "mcp-server-memory"]
    }
  }
}
```

### Docker-based Server

```json
{
  "mcpServers": {
    "custom-api": {
      "command": "docker",
      "args": ["run", "--rm", "-i", "my-mcp-server:latest"],
      "env": {
        "API_KEY": "${MY_API_KEY}"
      }
    }
  }
}
```

## Creating Custom MCP Servers

### Basic Structure

```typescript
// server.ts
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

const server = new Server({
  name: 'my-server',
  version: '1.0.0',
}, {
  capabilities: {
    tools: {},
    resources: {}
  }
});

// Define tools
server.setRequestHandler('tools/list', async () => ({
  tools: [{
    name: 'my_tool',
    description: 'Does something useful',
    inputSchema: {
      type: 'object',
      properties: {
        input: { type: 'string' }
      },
      required: ['input']
    }
  }]
}));

server.setRequestHandler('tools/call', async (request) => {
  if (request.params.name === 'my_tool') {
    const result = await doSomething(request.params.arguments.input);
    return { content: [{ type: 'text', text: result }] };
  }
});

// Define resources
server.setRequestHandler('resources/list', async () => ({
  resources: [{
    uri: 'my://resource',
    name: 'My Resource',
    mimeType: 'text/plain'
  }]
}));

server.setRequestHandler('resources/read', async (request) => {
  if (request.params.uri === 'my://resource') {
    return {
      contents: [{
        uri: request.params.uri,
        mimeType: 'text/plain',
        text: 'Resource content here'
      }]
    };
  }
});

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
```

### Package Configuration

```json
{
  "name": "my-mcp-server",
  "version": "1.0.0",
  "type": "module",
  "bin": {
    "my-mcp-server": "./dist/server.js"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.0.0"
  }
}
```

## Security Best Practices

### Environment Variables

```bash
# Store secrets in environment, not config
export GITHUB_TOKEN="ghp_xxxx"
export DATABASE_URL="postgresql://..."

# Reference in config
"env": {
  "GITHUB_TOKEN": "${GITHUB_TOKEN}"
}
```

### Restrict File Access

```json
{
  "filesystem": {
    "args": [
      "-y", "@anthropic/mcp-server-filesystem",
      "./src",           // Only src directory
      "./docs",          // Only docs directory
      "--no-write"       // Read-only mode
    ]
  }
}
```

### Network Isolation

```json
{
  "custom-server": {
    "command": "docker",
    "args": [
      "run", "--rm", "-i",
      "--network", "none",      // No network access
      "--read-only",            // Read-only filesystem
      "my-mcp-server:latest"
    ]
  }
}
```

## Debugging

### Enable Logging

```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "my-mcp-server"],
      "env": {
        "DEBUG": "mcp:*"
      }
    }
  }
}
```

### Test Server Manually

```bash
# Test server directly
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | npx my-mcp-server
```

### Check Server Status

```bash
# In Claude Code
/mcp status
```

## Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Server not starting | Path/command wrong | Check command exists |
| Tool not found | Capability not declared | Add to capabilities |
| Permission denied | File access restricted | Check allowed paths |
| Timeout | Server too slow | Increase timeout setting |
| Invalid response | Schema mismatch | Validate response format |

## Quick Reference

```markdown
# Add MCP server to config
~/.claude/settings.json → mcpServers

# Server capabilities
- tools: Execute actions
- resources: Read data
- prompts: Templates

# Best practices
- Use env vars for secrets
- Restrict file paths
- Use Docker for isolation
- Enable DEBUG for troubleshooting
```
