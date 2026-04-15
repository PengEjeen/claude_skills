# Advanced Workflows (2026)

## Headless Mode (-p)

CI/CD에서 Claude Code를 비대화형으로 실행. 코드 리뷰 자동화 40% 시간 단축 (Claude Code Docs).

### 사용법

```bash
# 단일 프롬프트 실행 (stdout에 결과 출력)
claude -p "이 PR의 보안 이슈를 검토해줘" --output-format json

# 파이프라인에서 사용
git diff main...HEAD | claude -p "이 diff를 리뷰해줘. 보안, 성능, 코드 품질 관점으로."

# 세션 유지 (멀티턴)
claude -p "프로젝트 구조를 분석해줘" --session-id "review-$(date +%Y%m%d)"
claude -p "테스트 커버리지가 부족한 파일을 찾아줘" --session-id "review-$(date +%Y%m%d)"
```

### CI/CD 통합 패턴

```yaml
# GitHub Actions 예시
- name: AI Code Review
  run: |
    git diff ${{ github.event.pull_request.base.sha }}..HEAD | \
    claude -p "코드 리뷰: 보안, 성능, 품질. CRITICAL/HIGH/MEDIUM으로 분류." \
    --output-format json > review.json
```

### 규칙
- CI에서는 항상 `--output-format json` 사용 (파싱 용이)
- `--session-id`로 멀티턴 세션 유지
- 타임아웃 설정: `--max-turns 10` 으로 무한 루프 방지
- 민감 정보 주의: CI 로그에 코드가 노출될 수 있음

## Worktree (-w)

격리된 병렬 개발. 버그 수정 + 기능 개발 동시 진행. 10x 생산성 향상 보고.

### 사용법

```bash
# 기능 개발용 워크트리 생성
claude -w feature-auth    # .claude/worktrees/feature-auth 에 격리된 복사본

# 버그 수정용 워크트리 (병렬)
claude -w hotfix-login    # 동시에 다른 작업 가능

# Agent 호출 시 워크트리 격리
# Agent tool에서 isolation: "worktree" 파라미터 사용
```

### 규칙
- 변경 없으면 자동 정리
- 변경 있으면 브랜치 + 경로 반환
- `.worktreeinclude` 파일로 워크트리 간 설정 공유
- 워크트리당 독립 컨텍스트 (서로 간섭 없음)

### 사용 시나리오
| 시나리오 | 방법 |
|---------|------|
| 기능 A + 기능 B 병렬 | `claude -w feature-a` + `claude -w feature-b` |
| 위험한 리팩토링 실험 | `claude -w experiment` → 실패하면 버리기 |
| 코드 리뷰 중 수정 테스트 | `claude -w review-test` → 통과하면 머지 |

## /loop 스케줄링

cron-like 반복 작업 자동화 (2026.03 신규 기능).

### 사용법

```bash
# 5분마다 PR 상태 확인
/loop 5m "gh pr status를 확인하고 머지 가능한 PR이 있으면 알려줘"

# 10분마다 빌드 상태 체크 (기본 간격)
/loop "gh run list --limit 3을 확인하고 실패한 빌드가 있으면 원인을 분석해줘"

# 커스텀 간격으로 보안 스캔
/loop 30m /verify pre-commit
```

### 규칙
- 기본 간격: 10분
- 최소 간격: 1분
- 백그라운드로 실행 (메인 작업 방해 안 함)
- `/loop stop` 으로 중단

### 추천 자동화

| 작업 | 간격 | 커맨드 |
|------|------|--------|
| PR 리뷰 대기 확인 | 5m | `/loop 5m "gh pr list --state open"` |
| 빌드 상태 모니터링 | 10m | `/loop 10m "gh run list --limit 5"` |
| 의존성 보안 스캔 | 30m | `/loop 30m /verify pre-commit` |
| 테스트 회귀 감시 | 15m | `/loop 15m "npm test 2>&1 \| tail -5"` |

## Auto Mode

AI 안전 분류기로 루틴 동작 자동 승인 (2026.03 신규).

### 활성화

Claude Code 설정에서 permission mode를 `auto`로 변경:
- 안전한 동작 (파일 읽기, 검색, 빌드): 자동 승인
- 위험한 동작 (삭제, 푸시, 외부 API): 사용자 확인 요청
- 내부 AI 분류기가 위험도 판단

### 규칙
- 샌드박스 환경에서만 `auto` 사용 권장
- 프로덕션 코드베이스: `default` 모드 유지
- `.env`, credential 파일 접근은 항상 수동 승인
- `--dangerously-skip-permissions`는 **절대 사용 금지**

### 안전 프로파일

| 환경 | 권장 모드 | 이유 |
|------|----------|------|
| 개인 실험 프로젝트 | auto | 빠른 반복, 낮은 위험 |
| 팀 개발 프로젝트 | default | 변경 사항 검토 필요 |
| 프로덕션 코드 | default + hooks | 다층 검증 |
| CI/CD 파이프라인 | default + headless | 자동화 + 안전 |
