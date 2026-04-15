# /modern-frontend — Anti-AI Frontend Design (2026)

프론트엔드 작업에 Anti-AI 디자인 원칙을 적용합니다.

> 이 커맨드는 `~/.claude/rules/modern-frontend.md` 규칙과 `react-component` 스킬의 내용을 활성화합니다.

## 실행 순서

1. **WebSearch**로 해당 컴포넌트/페이지 유형의 2026 트렌드 조사
2. **react-component** 스킬의 Anti-AI 디자인 원칙 적용
3. **rules/modern-frontend.md**의 금지 패턴 확인
4. 구현 후 Anti-AI 체크리스트 검증

## 핵심 원칙 요약

- 중앙 정렬 금지 → 비대칭 레이아웃
- 보라/파랑 그라데이션 금지 → 단색 또는 예상 외 색상
- 둥근 pill 버튼 금지 → 각진 버튼 또는 밑줄 링크
- Glass morphism 금지 → 솔리드 또는 투명
- 아이콘+제목+설명 카드 금지 → 숫자 인덱스, 가로 레이아웃
- fade-in 남발 금지 → UX 목적이 있는 clip-path reveal, line-draw

## 레퍼런스 스타일

- **Neo-Brutalist**: 두꺼운 테두리, 오프셋 그림자, 하이 콘트라스트
- **Swiss/Editorial**: 강력한 그리드, 여백의 미, 흑백 + 원색 하나
- **Minimal Dark**: 검은 배경, 텍스트 중심, 모노스페이스/세리프

상세 가이드는 `react-component` 스킬과 `rules/modern-frontend.md`를 참조하세요.
