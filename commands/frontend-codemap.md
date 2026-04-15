# Frontend Codemap Command

Generate UI-to-code mapping documentation for frontend projects.

## Usage

```bash
# Analyze entire frontend
/frontend-codemap

# Specific page
/frontend-codemap src/pages/UserProfile.tsx

# Tree view only
/frontend-codemap --tree

# With Storybook
/frontend-codemap --with-storybook

# Design system mapping
/frontend-codemap --design-system

# Accessibility check
/frontend-codemap --a11y
```

## What It Does

1. **Scans** all frontend components (React/Vue/Angular/Svelte)
2. **Parses** JSX/Template to extract UI elements
3. **Maps** each UI element to exact code location (file:line)
4. **Generates** markdown documentation with visual structure
5. **Outputs** to `docs/frontend/COMPONENT_MAP.md`

## Output Example

```markdown
## ProfileHeader
**File**: src/components/ProfileHeader.tsx:15-45

**UI Elements:**
1. Avatar Image
   - Code: `<Avatar src={user.avatar} />` (line 20)
   - Props: avatar: string, size: 'large'

2. User Name
   - Code: `<h1>{user.name}</h1>` (line 25)
   - Style: text-2xl font-bold

3. Email Display
   - Code: `<p>{user.email}</p>` (line 30)
   - Style: text-sm text-gray-500

**Modification Examples:**
- "ProfileHeader의 이메일 색상 변경" → line 30
- "아바타 크기 키우기" → line 20 size="xl"
```

## Benefits

### Before (Inefficient)
```
Developer: [Screenshot] "Change this button color"
Claude: "Which file is this?"
Developer: "Let me find it..."
Developer: "I think it's in ProfileForm.tsx..."
Claude: "Which line?"
Developer: "Searching..."
```

### After (Efficient)
```
Developer: "ProfileForm의 Save 버튼(line 80) 파란색으로"
Claude: "ProfileForm.tsx:80 수정합니다" ✅
```

## Supported Frameworks

- ✅ React (JSX, Hooks)
- ✅ Next.js (Pages, App Router)
- ✅ Vue (SFC, Composition API)
- ✅ Angular (Components + Templates)
- ✅ Svelte (Reactive)

## See Also

- Skill: `.claude/skills/frontend-codemap/SKILL.md`
- Update frequency: Run after major UI changes
- CI/CD: Auto-update via GitHub Actions
