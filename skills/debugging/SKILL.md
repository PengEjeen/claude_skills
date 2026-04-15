---
name: debugging
description: 체계적인 디버깅을 수행합니다. "버그", "에러", "안 돼", "동작 안 해", "실패", "크래시", "에러 메시지", "디버깅해줘", "왜 안 되지" 등의 요청 시 사용합니다. 가설 기반 디버깅, 이분 탐색, 로그 분석, 근본 원인 분석(RCA)을 포함합니다.
---

# Systematic Debugging Skill — Root Cause Analysis

## 목적
감(intuition)이 아닌 체계적 방법론으로 버그의 근본 원인을 찾고 수정한다.
"고쳤는데 왜 고쳐졌는지 모르겠다"를 방지한다.

## 핵심 원칙
- MUST: 수정하기 전에 버그를 재현(reproduce)
- MUST: 가설을 세우고 검증하는 과학적 방법 사용
- MUST: 근본 원인(root cause)을 찾기. 증상만 치료하지 않기
- MUST: 수정 후 회귀 테스트 작성
- MUST NOT: 한 번에 여러 가지를 변경하지 않기
- MUST NOT: "아마 이거겠지"로 코드를 변경하지 않기

## 디버깅 프로세스

### Step 1: 증상 정리
```
1. 에러 메시지 정확히 기록
2. 재현 조건 파악:
   - 언제 발생? (항상? 가끔? 특정 조건?)
   - 어디서 발생? (특정 환경? 특정 데이터?)
   - 누가 보고? (모든 사용자? 특정 사용자?)
3. 기대 동작 vs 실제 동작 명확화
```

### Step 2: 재현 (Reproduce)
```
1. 최소 재현 케이스(Minimal Reproducible Example) 생성
2. 재현되지 않으면:
   - 환경 차이 확인 (OS, 버전, 설정)
   - 데이터 차이 확인 (엣지 케이스 데이터)
   - 타이밍 문제 의심 (race condition)
3. 재현 가능한 테스트 케이스로 작성
```

### Step 3: 가설 수립 및 검증
```
가설 1: [구체적 원인 가설]
  검증 방법: [어떻게 확인할 것인가]
  결과: [확인/기각]

가설 2: [다음 가설]
  검증 방법: ...
  결과: ...
```

### Step 4: 범위 좁히기 기법

#### 이분 탐색 (Binary Search)
```
정상 동작하던 시점 → 버그 발생 시점 사이를 이분 탐색

git bisect start
git bisect bad HEAD
git bisect good v1.0.0
# 자동으로 중간 커밋 체크아웃 → 테스트 → 범위 축소
```

#### 삭제법 (Elimination)
```
1. 의심되는 코드 블록을 주석 처리 또는 격리
2. 버그가 사라지면 해당 블록 내에서 더 좁히기
3. 버그가 유지되면 다른 영역으로 이동
```

#### 로그 추가 (Instrumentation)
```
데이터 흐름의 각 단계에 로그 삽입:
  Input → Transform A → Transform B → Output

각 단계에서의 값을 비교하여 어디서 예상과 달라지는지 확인
```

### Step 5: 근본 원인 분석 (Root Cause Analysis)

버그를 찾았으면 "왜?"를 5번 묻기 (5 Whys):
```
버그: 주문 금액이 잘못 계산됨
  Why 1: 할인이 두 번 적용됨
  Why 2: 할인 함수가 두 번 호출됨
  Why 3: useEffect에서 의존성 배열이 잘못됨
  Why 4: 상태 변경이 리렌더링을 트리거하면서 이펙트 재실행
  → 근본 원인: 파생 상태를 useEffect로 계산하고 있음
  → 수정: useMemo로 변경
```

### Step 6: 수정 및 검증
```
1. 최소한의 변경으로 수정
2. 재현 테스트가 통과하는지 확인
3. 관련 기존 테스트가 여전히 통과하는지 확인
4. 회귀 테스트(regression test) 추가
5. 비슷한 패턴이 코드베이스에 더 있는지 grep으로 확인
```

## 버그 유형별 전략

### 비동기/Race Condition
```
도구:
  - async/await 누락 점검
  - Promise 체인 에러 핸들링 확인
  - 동시 접근 시 상태 관리 확인
  - setTimeout/setInterval 정리(cleanup) 확인

패턴:
  - 요청 취소(AbortController) 미구현
  - 상태 업데이트 순서 보장 실패
  - 클로저가 stale state를 캡처
```

### 메모리 누수
```
점검 포인트:
  - 이벤트 리스너 해제 누락
  - setInterval clearInterval 누락
  - 클로저에 의한 참조 유지
  - DOM 노드 참조 유지
  - 구독(subscription) 해제 누락
```

### 타입 에러 (Runtime)
```
점검 포인트:
  - null/undefined 접근
  - 잘못된 타입 변환
  - API 응답 형식 변경
  - JSON.parse 실패
  - 날짜/시간대 처리 오류
```

### 환경 의존 버그
```
점검 포인트:
  - 환경 변수 차이
  - 의존성 버전 차이
  - OS/브라우저 차이
  - 시간대(timezone) 차이
  - 로케일(locale) 차이
  - 파일 경로 구분자(/ vs \)
```

## 디버깅 도구 활용

```bash
# 로그 분석
grep -r "ERROR\|WARN\|Exception" logs/ --include="*.log"
tail -f logs/app.log | grep "ERROR"

# 프로세스 확인
lsof -i :3000           # 포트 사용 프로세스
ps aux | grep node       # 프로세스 목록

# 네트워크 디버깅
curl -v http://localhost:3000/api/health
netstat -tlnp            # 열린 포트 확인

# Node.js 디버깅
node --inspect src/index.js  # 디버거 연결
```

## 디버깅 결과 보고서

수정 완료 후 작성:
```markdown
## Bug Report: {간단한 제목}

**증상**: 무엇이 잘못되었는가
**근본 원인**: 왜 발생했는가
**수정**: 어떻게 고쳤는가
**영향 범위**: 어디까지 영향을 미쳤는가
**재발 방지**: 같은 유형의 버그를 어떻게 방지할 것인가
**추가된 테스트**: 어떤 테스트가 추가되었는가
```
