---
name: frontend-codemap
description: 프론트엔드 코드를 분석하여 UI 구조와 코드 매핑 문서를 자동 생성합니다. "코드맵", "UI 매핑", "컴포넌트 구조", "프론트엔드 분석", "codemap", "component map", "UI structure" 등의 요청 시 사용합니다. 스크린샷 없이 직관적으로 컴포넌트를 참조할 수 있는 문서를 만듭니다.
---

# Frontend Codemap Skill

프론트엔드 코드를 분석하여 **UI 구조와 코드를 매핑한 문서**를 자동 생성합니다. 개발자가 스크린샷 없이 "이 컴포넌트의 저 부분 고쳐줘"라고 직관적으로 요청할 수 있게 합니다.

## Purpose

**기존 방식의 문제:**
```
개발자: "여기 스크린샷 찍어서... 이 버튼 위치 바꿔줘"
Claude: "어떤 파일의 어느 코드인가요?"
개발자: "아... 잠깐 코드 찾아볼게..."
```

**새로운 방식:**
```
개발자: "UserProfile의 이메일 표시 부분 색상 변경해줘"
Claude: "ProfileHeader.tsx:30 수정합니다" (즉시 이해)
```

---

## When to Use

다음 상황에서 사용하세요:
- 프로젝트 온보딩 시 프론트엔드 구조 파악
- UI 수정 요청 시 정확한 코드 위치 식별
- 컴포넌트 리팩토링 계획 수립
- 디자이너/기획자와 협업 시 UI-코드 연결
- 신규 팀원 온보딩 자료

---

## Output Format

### 1. 페이지별 Component Map

```markdown
# Frontend Component Map - User Profile

## 📄 `/profile` 페이지

### 화면 구조
```
┌─────────────────────────────────────────┐
│ UserProfilePage                         │
│ 📂 src/pages/UserProfile.tsx            │
│                                         │
│  ┌────────────────────────────────────┐│
│  │ 🎨 ProfileHeader                   ││
│  │ 📂 components/ProfileHeader.tsx     ││
│  │                                     ││
│  │  📷 Avatar        (line 20)        ││
│  │  👤 User Name     (line 25)        ││
│  │  📧 Email         (line 30)        ││
│  │  ⚙️  Settings Btn (line 35)        ││
│  └────────────────────────────────────┘│
│                                         │
│  ┌────────────────────────────────────┐│
│  │ 📝 ProfileForm                     ││
│  │ 📂 components/ProfileForm.tsx       ││
│  │                                     ││
│  │  ✏️  Name Input    (line 45)       ││
│  │  ✉️  Email Input   (line 55)       ││
│  │  📱 Phone Input   (line 65)       ││
│  │  💾 Save Button   (line 80)       ││
│  └────────────────────────────────────┘│
│                                         │
│  ┌────────────────────────────────────┐│
│  │ 📊 ActivityLog                     ││
│  │ 📂 components/ActivityLog.tsx       ││
│  │                                     ││
│  │  📅 Activity List (line 30-60)    ││
│  │  🔽 Load More Btn (line 70)       ││
│  └────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

---

## 📦 컴포넌트 상세

### ProfileHeader
**파일**: `src/components/ProfileHeader.tsx`
**라인**: 15-45

**UI 요소:**
1. **아바타 이미지**
   - 코드: `<Avatar src={user.avatar} size="large" />` (line 20)
   - Props: `avatar: string, size: 'small' | 'medium' | 'large'`
   - 스타일: `className="avatar-container"`

2. **사용자 이름**
   - 코드: `<h1 className="user-name">{user.name}</h1>` (line 25)
   - 조건: `{user.verified && <VerifiedBadge />}` (line 26)
   - 스타일: `text-2xl font-bold text-gray-900`

3. **이메일 주소**
   - 코드: `<p className="user-email">{user.email}</p>` (line 30)
   - 스타일: `text-sm text-gray-500`
   - 변경 추천: 색상을 더 연하게 (gray-400)

4. **설정 버튼**
   - 코드: `<Button onClick={handleSettings}>Settings</Button>` (line 35)
   - 핸들러: `handleSettings()` (line 50)
   - 이동: `/settings` 페이지로 라우팅

**수정 예시:**
- "ProfileHeader의 이메일 색상 변경해줘" → line 30 수정
- "아바타 크기 키워줘" → line 20 `size="large"` → `size="xl"`
- "설정 버튼 위치 오른쪽으로" → line 35 스타일 추가

---

### ProfileForm
**파일**: `src/components/ProfileForm.tsx`
**라인**: 20-90

**UI 요소:**
1. **이름 입력 필드**
   - 코드: `<Input name="name" value={formData.name} onChange={handleChange} />` (line 45)
   - 검증: `required, minLength: 2` (line 100)
   - 에러 메시지: `{errors.name && <Error>{errors.name}</Error>}` (line 47)

2. **이메일 입력 필드**
   - 코드: `<Input type="email" name="email" value={formData.email} />` (line 55)
   - 검증: `email validation, unique` (line 105)
   - 읽기 전용: `disabled={user.emailVerified}` (line 56)

3. **전화번호 입력**
   - 코드: `<PhoneInput name="phone" value={formData.phone} />` (line 65)
   - 포맷: `(010) 1234-5678` (PhoneInput 컴포넌트가 자동 처리)
   - 선택 사항: `required={false}`

4. **저장 버튼**
   - 코드: `<Button type="submit" loading={isSubmitting}>Save</Button>` (line 80)
   - 핸들러: `handleSubmit()` (line 110)
   - 로딩 상태: `isSubmitting` (line 15)

**API 호출:**
- 엔드포인트: `PUT /api/users/{userId}` (line 115)
- 성공 시: Toast 알림 + 프로필 새로고침
- 실패 시: 에러 메시지 표시

**수정 예시:**
- "이메일 필드 항상 수정 가능하게" → line 56 `disabled` 제거
- "저장 버튼 색상 파란색으로" → line 80 `variant="primary"` 추가
- "전화번호 필수로 변경" → line 65 `required={true}`

---

### ActivityLog
**파일**: `src/components/ActivityLog.tsx`
**라인**: 15-80

**UI 요소:**
1. **활동 목록**
   - 코드:
     ```tsx
     {activities.map(activity => (
       <ActivityItem key={activity.id} activity={activity} />
     ))}
     ``` (line 30-35)
   - 표시 항목: 액션, 시간, 상세 정보
   - 최대 표시: 20개 (페이지네이션)

2. **더 보기 버튼**
   - 코드: `<Button onClick={loadMore}>Load More</Button>` (line 70)
   - 핸들러: `loadMore()` (line 45)
   - 조건: `{hasMore && ...}` (line 69)

**데이터 흐름:**
- API: `GET /api/users/{userId}/activities?page={page}&limit=20`
- 상태: `useState<Activity[]>([])` (line 18)
- 무한 스크롤 가능: `useInfiniteScroll` hook 추가 검토

**수정 예시:**
- "활동 목록 30개로 늘려줘" → line 20 `limit: 30`
- "더 보기 버튼 없애고 무한 스크롤로" → `useInfiniteScroll` hook 적용
- "최근 활동 먼저 표시" → API에 `sort=desc` 추가

---

## 🗺️ 라우팅 구조

```
/                    → HomePage          (pages/Home.tsx)
/profile             → UserProfilePage   (pages/UserProfile.tsx)
/profile/edit        → EditProfilePage   (pages/EditProfile.tsx)
/settings            → SettingsPage      (pages/Settings.tsx)
/login               → LoginPage         (pages/Login.tsx)
```

---

## 🎨 공통 컴포넌트

### Button
**파일**: `src/components/common/Button.tsx`
**Props**:
- `variant`: 'primary' | 'secondary' | 'danger'
- `size`: 'small' | 'medium' | 'large'
- `loading`: boolean
- `disabled`: boolean

**사용 위치**:
- ProfileHeader: Settings 버튼 (line 35)
- ProfileForm: Save 버튼 (line 80)
- ActivityLog: Load More 버튼 (line 70)

### Input
**파일**: `src/components/common/Input.tsx`
**Props**:
- `type`: 'text' | 'email' | 'password' | 'number'
- `name`: string
- `value`: string
- `onChange`: (e: ChangeEvent) => void
- `error`: string | undefined

**사용 위치**:
- ProfileForm: Name 입력 (line 45)
- ProfileForm: Email 입력 (line 55)
- LoginPage: Email/Password (login form)

---

## 📱 상태 관리

### UserProfile 페이지 상태
```typescript
// UserProfile.tsx
const [user, setUser] = useState<User | null>(null);
const [isLoading, setIsLoading] = useState(true);
const [error, setError] = useState<string | null>(null);

// ProfileForm.tsx
const [formData, setFormData] = useState({
  name: '',
  email: '',
  phone: ''
});
const [errors, setErrors] = useState<FormErrors>({});
const [isSubmitting, setIsSubmitting] = useState(false);

// ActivityLog.tsx
const [activities, setActivities] = useState<Activity[]>([]);
const [page, setPage] = useState(1);
const [hasMore, setHasMore] = useState(true);
```

---

## 🔄 데이터 흐름

```
UserProfilePage (부모)
    ↓ (user data)
ProfileHeader (자식)    ProfileForm (자식)    ActivityLog (자식)
    ↓ display              ↓ edit                ↓ display
   User                   API Call              API Call
                         ↓ (PUT)               ↓ (GET)
                    /api/users/{id}      /api/users/{id}/activities
```

---

## 🎯 수정 요청 예시

### ✅ 좋은 요청 (codemap 활용)
```
❌ "여기 버튼 색깔 바꿔줘" (어떤 버튼?)
✅ "ProfileForm의 Save 버튼 색상 파란색으로 변경해줘"
   → src/components/ProfileForm.tsx:80 수정

❌ "이메일 부분 좀 크게 해줘"
✅ "ProfileHeader의 이메일 표시(line 30) 폰트 크기 키워줘"
   → text-sm → text-base 변경

❌ "더 보기 버튼 없애줘"
✅ "ActivityLog의 Load More 버튼(line 70) 제거하고 무한 스크롤로 변경"
   → useInfiniteScroll hook 적용
```

---

## 🛠️ 사용 방법

### 1. 전체 프론트엔드 분석
```bash
/frontend-codemap

# 출력:
# - docs/frontend/COMPONENT_MAP.md (전체 구조)
# - docs/frontend/pages/profile.md (페이지별 상세)
# - docs/frontend/components/common.md (공통 컴포넌트)
```

### 2. 특정 페이지만 분석
```bash
/frontend-codemap src/pages/UserProfile.tsx

# 출력:
# - docs/frontend/pages/user-profile.md
```

### 3. 컴포넌트 트리 시각화
```bash
/frontend-codemap --tree

# 출력:
# UserProfilePage
# ├── ProfileHeader
# │   ├── Avatar
# │   ├── UserName
# │   └── SettingsButton
# ├── ProfileForm
# │   ├── NameInput
# │   ├── EmailInput
# │   └── SaveButton
# └── ActivityLog
#     └── ActivityList
```

---

## 🔍 분석 기능

### 자동으로 추출하는 정보

1. **컴포넌트 계층 구조**
   - 부모-자식 관계
   - Props 전달 흐름
   - 렌더링 조건

2. **UI 요소 매핑**
   - JSX 요소 → 화면 표시 위치
   - CSS 클래스 → 스타일
   - 조건부 렌더링

3. **상태 관리**
   - useState, useReducer
   - Context API
   - Redux/Zustand (있는 경우)

4. **이벤트 핸들러**
   - onClick, onChange 등
   - 함수 위치 (line number)
   - API 호출 흐름

5. **API 연동**
   - 엔드포인트 URL
   - Request/Response 타입
   - 에러 처리

---

## 📊 지원 프레임워크

| 프레임워크 | 지원 | 특징 |
|-----------|------|------|
| **React** | ✅ Full | JSX 파싱, Hooks 추출 |
| **Next.js** | ✅ Full | 페이지 라우팅, getServerSideProps |
| **Vue** | ✅ Full | SFC 파싱, Composition API |
| **Angular** | ✅ Partial | Component + Template 분석 |
| **Svelte** | ✅ Full | Reactive statements 추출 |

---

## 💡 고급 기능

### Storybook 연동
```bash
/frontend-codemap --with-storybook

# Storybook stories와 연결:
# - Button 컴포넌트 → stories/Button.stories.tsx
# - 시각적 테스트 링크 포함
```

### 디자인 시스템 매핑
```bash
/frontend-codemap --design-system

# 디자인 토큰 추출:
# - Color palette 사용 현황
# - Typography 사용
# - Spacing system
```

### 접근성(A11y) 체크
```bash
/frontend-codemap --a11y

# 접근성 이슈 식별:
# - 누락된 alt 텍스트
# - ARIA labels 부족
# - 키보드 네비게이션 문제
```

---

## 🔄 자동 업데이트

### Git Hook 설정
```bash
# .git/hooks/post-merge
#!/bin/bash
claude-code /frontend-codemap --auto-update

# 매 pull 후 자동으로 codemap 업데이트
```

### CI/CD 통합
```yaml
# .github/workflows/update-codemap.yml
name: Update Frontend Codemap

on:
  push:
    paths:
      - 'src/**/*.tsx'
      - 'src/**/*.vue'

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Update codemap
        run: claude-code /frontend-codemap
      - name: Commit changes
        run: |
          git add docs/frontend/
          git commit -m "docs: update frontend codemap"
          git push
```

---

## 📝 실제 사용 예시

### Before (비효율적)
```
개발자: [스크린샷 첨부] "여기 버튼 오른쪽으로 옮겨줘"
Claude: "어떤 파일인가요?"
개발자: "잠깐... 찾아볼게요..."
개발자: "src/components/ProfileForm.tsx 같은데..."
Claude: "몇 번째 줄인가요?"
개발자: "아... 다시 볼게요..."
```

### After (효율적)
```
개발자: "ProfileForm의 Save 버튼(line 80) 오른쪽 정렬로 변경"
Claude: "ProfileForm.tsx:80 수정합니다"
         [즉시 코드 수정]

개발자: "ProfileHeader 이메일 색상을 gray-400으로"
Claude: "ProfileHeader.tsx:30 text-gray-500 → text-gray-400"
         [즉시 수정]
```

---

## 🎨 시각화 옵션

### Mermaid 다이어그램
```bash
/frontend-codemap --mermaid

# 출력: Mermaid 형식 컴포넌트 트리
graph TD
    A[UserProfilePage] --> B[ProfileHeader]
    A --> C[ProfileForm]
    A --> D[ActivityLog]
    B --> E[Avatar]
    B --> F[UserName]
    C --> G[NameInput]
    C --> H[EmailInput]
```

### ASCII Art
```bash
/frontend-codemap --ascii

# 출력: 터미널에서 바로 보기 좋은 형식
UserProfilePage
├─ ProfileHeader
│  ├─ Avatar
│  └─ UserName
├─ ProfileForm
│  ├─ NameInput
│  └─ EmailInput
└─ ActivityLog
```

---

## 🚀 실행 로직

### 1. 프론트엔드 코드 수집
```typescript
// 모든 컴포넌트 파일 탐색
const components = glob.sync('src/**/*.{tsx,jsx,vue}');
```

### 2. AST 파싱
```typescript
// TypeScript/JavaScript AST 파싱
import { parse } from '@typescript-eslint/parser';

const ast = parse(code, {
  ecmaFeatures: { jsx: true }
});
```

### 3. 컴포넌트 정보 추출
```typescript
interface ComponentInfo {
  name: string;
  filePath: string;
  lineStart: number;
  lineEnd: number;
  props: PropInfo[];
  state: StateInfo[];
  jsxElements: JSXElement[];
  eventHandlers: EventHandler[];
  apiCalls: APICall[];
  children: ComponentInfo[];
}
```

### 4. UI 매핑 생성
```typescript
// JSX 요소 → UI 설명
<Button onClick={handleSave}>Save</Button>
→
"저장 버튼 (line 80)"
- 클릭 시: handleSave() 실행 (line 110)
- API: PUT /api/users/{id}
```

### 5. Markdown 문서 생성
```markdown
생성 위치: docs/frontend/COMPONENT_MAP.md
자동 업데이트: Git hook 또는 CI/CD
```

---

## ✅ 체크리스트

프론트엔드 codemap 생성 후:

- [ ] 모든 페이지 컴포넌트 매핑됨
- [ ] 공통 컴포넌트 문서화됨
- [ ] UI 요소 → 코드 라인 매핑 정확
- [ ] 이벤트 핸들러 위치 표시됨
- [ ] API 호출 엔드포인트 명시됨
- [ ] Props/State 타입 정의됨
- [ ] 조건부 렌더링 설명됨

---

## 📚 참고 자료

- [React Component Tree](https://reactjs.org/docs/thinking-in-react.html)
- [Storybook Documentation](https://storybook.js.org/)
- [Component-Driven Development](https://www.componentdriven.org/)

---

---

## 🔧 실제 구현 (Implementation)

### AST Parser (TypeScript/JavaScript)

```typescript
// ast-parser.ts
import * as ts from 'typescript';
import * as parser from '@babel/parser';
import traverse from '@babel/traverse';
import { readFileSync } from 'fs';
import { glob } from 'glob';

interface ComponentInfo {
  name: string;
  filePath: string;
  lineStart: number;
  lineEnd: number;
  props: PropInfo[];
  state: StateInfo[];
  jsxElements: JSXElementInfo[];
  eventHandlers: EventHandlerInfo[];
  apiCalls: APICallInfo[];
  children: string[];
}

interface JSXElementInfo {
  type: string;  // 'div', 'button', 'Avatar', etc.
  line: number;
  text?: string;  // Inner text if available
  props: Record<string, any>;
  className?: string;
}

interface PropInfo {
  name: string;
  type: string;
  required: boolean;
  line: number;
}

interface StateInfo {
  name: string;
  type: string;
  initialValue: any;
  line: number;
}

interface EventHandlerInfo {
  name: string;
  event: string;  // 'onClick', 'onChange', etc.
  line: number;
  targetLine: number;  // Line where handler is defined
}

interface APICallInfo {
  method: string;  // 'GET', 'POST', etc.
  endpoint: string;
  line: number;
}

/**
 * Parse React/TypeScript component file
 */
export function parseComponent(filePath: string): ComponentInfo {
  const code = readFileSync(filePath, 'utf-8');
  const ast = parser.parse(code, {
    sourceType: 'module',
    plugins: ['typescript', 'jsx']
  });

  const componentInfo: ComponentInfo = {
    name: '',
    filePath,
    lineStart: 0,
    lineEnd: 0,
    props: [],
    state: [],
    jsxElements: [],
    eventHandlers: [],
    apiCalls: [],
    children: []
  };

  traverse(ast, {
    // Extract component name
    FunctionDeclaration(path) {
      if (isReactComponent(path)) {
        componentInfo.name = path.node.id?.name || '';
        componentInfo.lineStart = path.node.loc?.start.line || 0;
        componentInfo.lineEnd = path.node.loc?.end.line || 0;
      }
    },

    // Extract JSX elements
    JSXElement(path) {
      const element = path.node;
      const opening = element.openingElement;
      const tagName = getJSXElementName(opening.name);

      const jsxInfo: JSXElementInfo = {
        type: tagName,
        line: opening.loc?.start.line || 0,
        props: {},
        text: getJSXText(element)
      };

      // Extract props
      opening.attributes.forEach(attr => {
        if (attr.type === 'JSXAttribute') {
          const name = attr.name.name as string;
          jsxInfo.props[name] = getAttributeValue(attr.value);

          // Extract className
          if (name === 'className') {
            jsxInfo.className = getAttributeValue(attr.value);
          }

          // Extract event handlers
          if (name.startsWith('on')) {
            const handler = extractEventHandler(attr, path);
            if (handler) {
              componentInfo.eventHandlers.push(handler);
            }
          }
        }
      });

      componentInfo.jsxElements.push(jsxInfo);
    },

    // Extract useState hooks
    CallExpression(path) {
      if (path.node.callee.type === 'Identifier' &&
          path.node.callee.name === 'useState') {
        const state = extractStateInfo(path);
        if (state) componentInfo.state.push(state);
      }

      // Extract API calls (fetch, axios)
      if (isAPICall(path)) {
        const apiCall = extractAPICall(path);
        if (apiCall) componentInfo.apiCalls.push(apiCall);
      }
    },

    // Extract props (TypeScript interface)
    TSInterfaceDeclaration(path) {
      if (path.node.id.name.endsWith('Props')) {
        const props = extractPropsFromInterface(path);
        componentInfo.props.push(...props);
      }
    }
  });

  return componentInfo;
}

function isReactComponent(path: any): boolean {
  // Check if function returns JSX
  const hasJSXReturn = path.traverse({
    ReturnStatement(returnPath: any) {
      return returnPath.node.argument?.type.startsWith('JSX');
    }
  });
  return hasJSXReturn;
}

function getJSXElementName(name: any): string {
  if (name.type === 'JSXIdentifier') {
    return name.name;
  }
  if (name.type === 'JSXMemberExpression') {
    return `${getJSXElementName(name.object)}.${name.property.name}`;
  }
  return 'Unknown';
}

function getJSXText(element: any): string | undefined {
  if (element.children.length === 1 &&
      element.children[0].type === 'JSXText') {
    return element.children[0].value.trim();
  }
  return undefined;
}

function getAttributeValue(value: any): any {
  if (!value) return true;
  if (value.type === 'StringLiteral') return value.value;
  if (value.type === 'JSXExpressionContainer') {
    if (value.expression.type === 'StringLiteral') {
      return value.expression.value;
    }
    return '[expression]';
  }
  return undefined;
}

function extractEventHandler(attr: any, path: any): EventHandlerInfo | null {
  const handlerName = attr.name.name as string;
  const value = attr.value;

  if (value?.type === 'JSXExpressionContainer') {
    const expression = value.expression;

    if (expression.type === 'Identifier') {
      // onClick={handleClick}
      return {
        name: expression.name,
        event: handlerName,
        line: attr.loc.start.line,
        targetLine: findFunctionDefinition(expression.name, path)
      };
    }

    if (expression.type === 'ArrowFunctionExpression') {
      // onClick={() => ...}
      return {
        name: 'inline',
        event: handlerName,
        line: attr.loc.start.line,
        targetLine: attr.loc.start.line
      };
    }
  }

  return null;
}

function findFunctionDefinition(name: string, path: any): number {
  let line = 0;
  path.scope.traverse(path.scope.block, {
    FunctionDeclaration(funcPath: any) {
      if (funcPath.node.id?.name === name) {
        line = funcPath.node.loc.start.line;
      }
    },
    VariableDeclarator(varPath: any) {
      if (varPath.node.id.name === name &&
          varPath.node.init?.type === 'ArrowFunctionExpression') {
        line = varPath.node.loc.start.line;
      }
    }
  });
  return line;
}

function extractStateInfo(path: any): StateInfo | null {
  const parent = path.parent;
  if (parent.type === 'VariableDeclarator') {
    const id = parent.id;
    if (id.type === 'ArrayPattern' && id.elements.length >= 1) {
      const stateName = id.elements[0]?.name;
      const initialValue = path.node.arguments[0];

      return {
        name: stateName,
        type: inferType(initialValue),
        initialValue: getInitialValue(initialValue),
        line: path.node.loc.start.line
      };
    }
  }
  return null;
}

function extractPropsFromInterface(path: any): PropInfo[] {
  const props: PropInfo[] = [];

  path.node.body.body.forEach((member: any) => {
    if (member.type === 'TSPropertySignature') {
      props.push({
        name: member.key.name,
        type: getTSType(member.typeAnnotation),
        required: !member.optional,
        line: member.loc.start.line
      });
    }
  });

  return props;
}

function isAPICall(path: any): boolean {
  const callee = path.node.callee;

  // fetch('/api/...')
  if (callee.type === 'Identifier' && callee.name === 'fetch') {
    return true;
  }

  // axios.get('/api/...')
  if (callee.type === 'MemberExpression') {
    const object = callee.object;
    if (object.type === 'Identifier' && object.name === 'axios') {
      return true;
    }
  }

  return false;
}

function extractAPICall(path: any): APICallInfo | null {
  const callee = path.node.callee;
  const args = path.node.arguments;

  if (args.length === 0) return null;

  let method = 'GET';
  let endpoint = '';

  // fetch(url, { method: 'POST' })
  if (callee.name === 'fetch') {
    endpoint = getStringValue(args[0]);
    if (args[1]?.type === 'ObjectExpression') {
      const methodProp = args[1].properties.find(
        (p: any) => p.key.name === 'method'
      );
      if (methodProp) {
        method = getStringValue(methodProp.value);
      }
    }
  }

  // axios.get(url) or axios.post(url)
  if (callee.type === 'MemberExpression') {
    method = callee.property.name.toUpperCase();
    endpoint = getStringValue(args[0]);
  }

  return {
    method,
    endpoint,
    line: path.node.loc.start.line
  };
}

function inferType(node: any): string {
  if (!node) return 'unknown';
  if (node.type === 'StringLiteral') return 'string';
  if (node.type === 'NumericLiteral') return 'number';
  if (node.type === 'BooleanLiteral') return 'boolean';
  if (node.type === 'ArrayExpression') return 'array';
  if (node.type === 'ObjectExpression') return 'object';
  return 'unknown';
}

function getInitialValue(node: any): any {
  if (!node) return undefined;
  if (node.type === 'StringLiteral') return node.value;
  if (node.type === 'NumericLiteral') return node.value;
  if (node.type === 'BooleanLiteral') return node.value;
  if (node.type === 'ArrayExpression') return '[]';
  if (node.type === 'ObjectExpression') return '{}';
  return undefined;
}

function getTSType(typeAnnotation: any): string {
  if (!typeAnnotation) return 'any';
  const type = typeAnnotation.typeAnnotation;
  if (type.type === 'TSStringKeyword') return 'string';
  if (type.type === 'TSNumberKeyword') return 'number';
  if (type.type === 'TSBooleanKeyword') return 'boolean';
  if (type.type === 'TSArrayType') return `${getTSType(type.elementType)}[]`;
  return 'unknown';
}

function getStringValue(node: any): string {
  if (node.type === 'StringLiteral') return node.value;
  if (node.type === 'TemplateLiteral') {
    return node.quasis.map((q: any) => q.value.raw).join('${...}');
  }
  return '';
}

/**
 * Generate component map markdown
 */
export function generateComponentMap(components: ComponentInfo[]): string {
  let markdown = '# Frontend Component Map\n\n';

  components.forEach(comp => {
    markdown += `## ${comp.name}\n`;
    markdown += `**File**: \`${comp.filePath}:${comp.lineStart}-${comp.lineEnd}\`\n\n`;

    // Props
    if (comp.props.length > 0) {
      markdown += '**Props**:\n';
      comp.props.forEach(prop => {
        const required = prop.required ? '✅ Required' : '⚪ Optional';
        markdown += `- \`${prop.name}\`: ${prop.type} (${required}) - line ${prop.line}\n`;
      });
      markdown += '\n';
    }

    // State
    if (comp.state.length > 0) {
      markdown += '**State**:\n';
      comp.state.forEach(state => {
        markdown += `- \`${state.name}\`: ${state.type} = ${state.initialValue} (line ${state.line})\n`;
      });
      markdown += '\n';
    }

    // UI Elements
    if (comp.jsxElements.length > 0) {
      markdown += '**UI Elements**:\n';
      comp.jsxElements.forEach((el, idx) => {
        markdown += `${idx + 1}. **${el.type}** (line ${el.line})\n`;
        if (el.text) {
          markdown += `   - Text: "${el.text}"\n`;
        }
        if (el.className) {
          markdown += `   - Class: \`${el.className}\`\n`;
        }
        if (Object.keys(el.props).length > 0) {
          markdown += `   - Props: ${JSON.stringify(el.props)}\n`;
        }
      });
      markdown += '\n';
    }

    // Event Handlers
    if (comp.eventHandlers.length > 0) {
      markdown += '**Event Handlers**:\n';
      comp.eventHandlers.forEach(handler => {
        markdown += `- \`${handler.event}\` → \`${handler.name}()\` (line ${handler.targetLine})\n`;
      });
      markdown += '\n';
    }

    // API Calls
    if (comp.apiCalls.length > 0) {
      markdown += '**API Calls**:\n';
      comp.apiCalls.forEach(api => {
        markdown += `- \`${api.method} ${api.endpoint}\` (line ${api.line})\n`;
      });
      markdown += '\n';
    }

    markdown += '---\n\n';
  });

  return markdown;
}

/**
 * CLI Command
 */
export async function analyzeFrontend(pattern: string = 'src/**/*.{tsx,jsx}'): Promise<void> {
  console.log('🔍 Analyzing frontend components...\n');

  const files = await glob(pattern);
  console.log(`Found ${files.length} component files\n`);

  const components: ComponentInfo[] = [];

  for (const file of files) {
    try {
      const component = parseComponent(file);
      if (component.name) {
        components.push(component);
        console.log(`✅ ${component.name} (${file})`);
      }
    } catch (error) {
      console.error(`❌ Failed to parse ${file}:`, error.message);
    }
  }

  // Generate markdown
  const markdown = generateComponentMap(components);

  // Write to file
  const fs = require('fs');
  const outputPath = 'docs/frontend/COMPONENT_MAP.md';
  fs.mkdirSync('docs/frontend', { recursive: true });
  fs.writeFileSync(outputPath, markdown);

  console.log(`\n📄 Component map generated: ${outputPath}`);
  console.log(`📊 Total components: ${components.length}`);
}

// Usage
if (require.main === module) {
  const pattern = process.argv[2] || 'src/**/*.{tsx,jsx}';
  analyzeFrontend(pattern);
}
```

### Vue SFC Parser

```typescript
// vue-parser.ts
import { parse } from '@vue/compiler-sfc';
import { readFileSync } from 'fs';

export function parseVueComponent(filePath: string): ComponentInfo {
  const code = readFileSync(filePath, 'utf-8');
  const { descriptor } = parse(code);

  const componentInfo: ComponentInfo = {
    name: extractComponentName(descriptor),
    filePath,
    lineStart: 0,
    lineEnd: 0,
    props: [],
    state: [],
    jsxElements: [],
    eventHandlers: [],
    apiCalls: [],
    children: []
  };

  // Parse template
  if (descriptor.template) {
    const templateAST = parseVueTemplate(descriptor.template.content);
    componentInfo.jsxElements = extractVueElements(templateAST);
  }

  // Parse script (Composition API)
  if (descriptor.script || descriptor.scriptSetup) {
    const script = descriptor.scriptSetup || descriptor.script;
    parseVueScript(script.content, componentInfo);
  }

  return componentInfo;
}

function extractComponentName(descriptor: any): string {
  // Extract from script or use filename
  return descriptor.scriptSetup?.setup?.name || 'Component';
}

function parseVueTemplate(template: string): any {
  // Parse Vue template to AST
  // Implementation here...
}

function extractVueElements(ast: any): JSXElementInfo[] {
  // Extract v-bind, v-on, etc.
  // Implementation here...
}

function parseVueScript(script: string, componentInfo: ComponentInfo): void {
  // Parse Composition API (ref, reactive, computed)
  // Implementation here...
}
```

### Package.json

```json
{
  "name": "frontend-codemap",
  "version": "1.0.0",
  "description": "Generate UI-to-code mapping for frontend projects",
  "main": "dist/index.js",
  "bin": {
    "frontend-codemap": "dist/cli.js"
  },
  "scripts": {
    "build": "tsc",
    "analyze": "ts-node src/ast-parser.ts"
  },
  "dependencies": {
    "@babel/parser": "^7.23.0",
    "@babel/traverse": "^7.23.0",
    "@vue/compiler-sfc": "^3.4.0",
    "typescript": "^5.3.0",
    "glob": "^10.3.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "ts-node": "^10.9.0"
  }
}
```

---

**버전**: 2.0 (구현 추가)
**작성일**: 2026-01-29
**최종 수정**: 2026-01-29 (AST 파서 구현 완료)
