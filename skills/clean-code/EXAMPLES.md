# 리팩토링 실전 예시

## 현재 프로젝트에 적용 가능한 리팩토링

### 1. Backend Routes 리팩토링

#### 현재 상태 (추정)
```python
# backend/routes/multi_excel.py
@router.post("/api/v1/multi-excel")
async def process_multi_excel(files: list[UploadFile]):
    # 모든 로직이 여기에
    results = []
    for file in files:
        # 검증
        if not file.filename.endswith('.xlsx'):
            raise HTTPException(400, "Invalid file")

        # 파싱
        df = pd.read_excel(file)

        # 처리
        # ... 100줄의 비즈니스 로직

        # LLM 호출
        # ... 50줄

        results.append(result)

    return results
```

#### 리팩토링 후
```python
# backend/routes/multi_excel.py (라우트만)
from backend.services.excel_service import ExcelService
from backend.models.requests import MultiExcelRequest
from backend.models.responses import MultiExcelResponse

@router.post(
    "/api/v1/multi-excel",
    response_model=MultiExcelResponse,
    summary="다중 엑셀 처리",
    description="여러 엑셀 파일을 병렬로 처리합니다"
)
async def process_multi_excel(
    files: list[UploadFile],
    service: ExcelService = Depends(get_excel_service)
) -> MultiExcelResponse:
    """엑셀 파일 처리 엔드포인트 (라우팅만)"""
    return await service.process_files(files)


# backend/services/excel_service.py (비즈니스 로직)
from typing import List
from backend.repositories.excel_repository import ExcelRepository
from src.multi_excel.agents import MultiExcelAgent

class ExcelService:
    """엑셀 처리 비즈니스 로직"""

    def __init__(
        self,
        agent: MultiExcelAgent,
        repository: ExcelRepository,
        validator: FileValidator
    ):
        self.agent = agent
        self.repository = repository
        self.validator = validator

    async def process_files(
        self, files: List[UploadFile]
    ) -> MultiExcelResponse:
        """파일 처리 조율"""
        # 1. 검증
        validated = await self._validate_files(files)

        # 2. 에이전트 처리
        results = await self.agent.process_parallel(validated)

        # 3. 저장
        saved = await self._save_results(results)

        return MultiExcelResponse(results=saved)

    async def _validate_files(
        self, files: List[UploadFile]
    ) -> List[ValidatedFile]:
        """파일 검증 (단일 책임)"""
        validated = []
        for file in files:
            if await self.validator.is_valid(file):
                validated.append(ValidatedFile.from_upload(file))
            else:
                raise ValidationError(f"Invalid file: {file.filename}")
        return validated

    async def _save_results(self, results: List[ProcessResult]) -> List[SavedResult]:
        """결과 저장 (단일 책임)"""
        return await self.repository.save_batch(results)


# backend/core/dependencies.py (DI)
def get_excel_service() -> ExcelService:
    """Excel 서비스 의존성 주입"""
    agent = MultiExcelAgent(
        llm=get_llm_client(),
        config=get_agent_config()
    )
    repository = ExcelRepository(db=get_db())
    validator = FileValidator(
        allowed_extensions=['.xlsx', '.xls'],
        max_size_mb=10
    )
    return ExcelService(agent, repository, validator)
```

---

### 2. Multi Excel Agent 리팩토링

#### 현재 상태
```python
# src/multi_excel/agents/synthesizer.py
class MultiExcelAgent:
    def __init__(self):
        self.llm = ChatAnthropic(...)
        # 많은 초기화 코드

    def process(self, files):
        # 500줄의 모든 로직
        pass
```

#### 리팩토링 후
```python
# src/agents/base.py (추상 베이스)
from abc import ABC, abstractmethod
from typing import TypeVar, Generic

TInput = TypeVar('TInput')
TOutput = TypeVar('TOutput')

class BaseAgent(ABC, Generic[TInput, TOutput]):
    """모든 에이전트의 베이스 클래스"""

    def __init__(self, llm, config: AgentConfig):
        self.llm = llm
        self.config = config
        self._validate_config()

    @abstractmethod
    async def process(self, input_data: TInput) -> TOutput:
        """에이전트 메인 로직"""
        pass

    @abstractmethod
    def _validate_config(self) -> None:
        """설정 검증"""
        pass


# src/agents/multi_excel/agent.py (구현)
from ..base import BaseAgent
from .state import MultiExcelState, MultiExcelResult
from .tools import ExcelParser, DataExtractor
from .synthesizer import ResultSynthesizer

class MultiExcelAgent(BaseAgent[MultiExcelState, MultiExcelResult]):
    """다중 엑셀 처리 에이전트"""

    def __init__(self, llm, config: AgentConfig):
        super().__init__(llm, config)
        self.parser = ExcelParser()
        self.extractor = DataExtractor()
        self.synthesizer = ResultSynthesizer(llm)

    async def process(self, state: MultiExcelState) -> MultiExcelResult:
        """병렬 처리 조율 (각 단계는 위임)"""
        # 1. 파싱
        parsed = await self._parse_files(state.files)

        # 2. 데이터 추출
        extracted = await self._extract_data(parsed)

        # 3. 병렬 분석
        analyzed = await self._analyze_parallel(extracted)

        # 4. 결과 합성
        synthesized = await self.synthesizer.synthesize(analyzed)

        return MultiExcelResult(
            data=synthesized,
            metadata=self._build_metadata(state)
        )

    async def _parse_files(self, files: List[File]) -> List[ParsedData]:
        """파일 파싱 (위임)"""
        return await asyncio.gather(*[
            self.parser.parse(file) for file in files
        ])

    async def _extract_data(self, parsed: List[ParsedData]) -> List[ExtractedData]:
        """데이터 추출 (위임)"""
        return [
            self.extractor.extract(data) for data in parsed
        ]

    async def _analyze_parallel(self, data: List[ExtractedData]) -> List[AnalyzedData]:
        """병렬 분석 (실제 LLM 호출)"""
        tasks = [
            self._analyze_single(item) for item in data
        ]
        return await asyncio.gather(*tasks)

    async def _analyze_single(self, data: ExtractedData) -> AnalyzedData:
        """단일 데이터 분석"""
        prompt = self._build_prompt(data)
        response = await self.llm.ainvoke(prompt)
        return AnalyzedData.from_response(response)

    def _validate_config(self) -> None:
        """설정 검증"""
        required = ['model_name', 'max_tokens']
        for key in required:
            if not hasattr(self.config, key):
                raise ValueError(f"Missing config: {key}")


# src/agents/multi_excel/state.py (상태 분리)
from pydantic import BaseModel
from typing import List, Dict

class MultiExcelState(BaseModel):
    """에이전트 입력 상태"""
    files: List[File]
    query: str
    options: Dict = {}

class MultiExcelResult(BaseModel):
    """에이전트 출력 결과"""
    data: Dict
    metadata: Dict
    confidence: float = 0.0


# src/agents/multi_excel/tools.py (도구 분리)
class ExcelParser:
    """엑셀 파싱 전용"""

    async def parse(self, file: File) -> ParsedData:
        """엑셀 파일을 파싱하여 구조화된 데이터 반환"""
        df = pd.read_excel(file.path)
        return ParsedData(
            dataframe=df,
            sheets=df.sheet_names if hasattr(df, 'sheet_names') else ['Sheet1'],
            metadata={'filename': file.name}
        )


class DataExtractor:
    """데이터 추출 전용"""

    def extract(self, parsed: ParsedData) -> ExtractedData:
        """필요한 데이터만 추출"""
        return ExtractedData(
            rows=parsed.dataframe.to_dict('records'),
            columns=list(parsed.dataframe.columns),
            summary=self._summarize(parsed.dataframe)
        )

    def _summarize(self, df: pd.DataFrame) -> Dict:
        """데이터 요약"""
        return {
            'row_count': len(df),
            'column_count': len(df.columns),
            'numeric_columns': list(df.select_dtypes(include=['number']).columns)
        }
```

---

### 3. Frontend 컴포넌트 리팩토링

#### 현재 상태
```jsx
// frontend_react/src/components/ChatV1V6Tab.jsx
const ChatV1V6Tab = () => {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleSend = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/chat', {
        method: 'POST',
        body: JSON.stringify({ message: input })
      });
      const data = await response.json();
      setMessages([...messages, data]);
      setInput('');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      {/* 모든 UI가 여기에 */}
    </div>
  );
};
```

#### 리팩토링 후
```jsx
// hooks/useChat.js (비즈니스 로직 분리)
import { useState, useCallback } from 'react';
import { chatService } from '../services/chatService';

export const useChat = () => {
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const sendMessage = useCallback(async (text) => {
    if (!text.trim()) return;

    setLoading(true);
    setError(null);

    try {
      const response = await chatService.send(text);
      setMessages(prev => [...prev, {
        text,
        response: response.data,
        timestamp: new Date()
      }]);
    } catch (err) {
      setError(err.message);
      console.error('Chat error:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  const clearMessages = useCallback(() => {
    setMessages([]);
  }, []);

  return {
    messages,
    loading,
    error,
    sendMessage,
    clearMessages
  };
};


// services/chatService.js (API 호출 분리)
import api from './api';

export const chatService = {
  async send(message) {
    return api.post('/api/chat', { message });
  },

  async getHistory(userId) {
    return api.get(`/api/chat/history/${userId}`);
  }
};


// components/features/chat/ChatV1V6Tab.jsx (프레젠테이션)
import { useChat } from '../../../hooks/useChat';
import ChatHeader from './ChatHeader';
import MessageList from './MessageList';
import MessageInput from './MessageInput';
import ErrorAlert from '../../common/ErrorAlert';
import LoadingSpinner from '../../common/LoadingSpinner';

const ChatV1V6Tab = () => {
  const { messages, loading, error, sendMessage, clearMessages } = useChat();

  return (
    <div className="chat-container">
      <ChatHeader onClear={clearMessages} />

      {error && <ErrorAlert message={error} />}

      <MessageList messages={messages} loading={loading} />

      {loading && <LoadingSpinner />}

      <MessageInput onSend={sendMessage} disabled={loading} />
    </div>
  );
};

export default ChatV1V6Tab;


// components/features/chat/MessageList.jsx (단일 책임)
const MessageList = ({ messages, loading }) => {
  const messagesEndRef = useRef(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  if (messages.length === 0 && !loading) {
    return <EmptyState />;
  }

  return (
    <div className="message-list">
      {messages.map((msg, idx) => (
        <MessageItem key={idx} message={msg} />
      ))}
      <div ref={messagesEndRef} />
    </div>
  );
};


// components/features/chat/MessageInput.jsx (단일 책임)
const MessageInput = ({ onSend, disabled }) => {
  const [text, setText] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (text.trim()) {
      onSend(text);
      setText('');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="message-input">
      <input
        type="text"
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder="메시지를 입력하세요..."
        disabled={disabled}
      />
      <button type="submit" disabled={disabled || !text.trim()}>
        전송
      </button>
    </form>
  );
};
```

---

### 4. 프롬프트 관리 리팩토링

#### 현재 상태
```python
# src/prompts/tax_expert_2026.py
def get_tax_prompt(data):
    return f"""
    You are a tax expert...
    [100줄의 프롬프트가 하드코딩]
    Data: {data}
    """
```

#### 리팩토링 후
```python
# src/prompts/base.py (베이스 클래스)
from abc import ABC, abstractmethod
from typing import Dict
from pathlib import Path

class BasePrompt(ABC):
    """프롬프트 베이스 클래스"""

    def __init__(self, template_dir: Path):
        self.template_dir = template_dir
        self._templates = {}
        self._load_templates()

    @abstractmethod
    def _load_templates(self) -> None:
        """템플릿 로드"""
        pass

    @abstractmethod
    def build(self, context: Dict) -> str:
        """컨텍스트로 프롬프트 구성"""
        pass

    def _read_template(self, filename: str) -> str:
        """템플릿 파일 읽기"""
        path = self.template_dir / filename
        with open(path, 'r', encoding='utf-8') as f:
            return f.read()


# src/prompts/tax_expert_2026.py (구현)
from .base import BasePrompt
from pathlib import Path

class TaxExpertPrompt(BasePrompt):
    """세금 전문가 프롬프트"""

    def __init__(self):
        template_dir = Path(__file__).parent / "templates" / "tax_expert"
        super().__init__(template_dir)

    def _load_templates(self) -> None:
        """템플릿 파일들 로드"""
        self._templates = {
            'system': self._read_template('system.txt'),
            'user_query': self._read_template('user_query.txt'),
            'few_shot_examples': self._read_template('examples.txt')
        }

    def build(self, context: Dict) -> str:
        """프롬프트 구성"""
        return f"""
{self._templates['system']}

{self._templates['few_shot_examples']}

{self._templates['user_query'].format(**context)}
"""

    def build_with_rag(self, query: str, documents: list) -> str:
        """RAG 컨텍스트 포함 프롬프트"""
        context = {
            'query': query,
            'documents': self._format_documents(documents)
        }
        return self.build(context)

    def _format_documents(self, docs: list) -> str:
        """문서 포맷팅"""
        formatted = []
        for idx, doc in enumerate(docs, 1):
            formatted.append(f"[문서 {idx}]\n{doc.content}\n출처: {doc.source}")
        return "\n\n".join(formatted)


# src/prompts/templates/tax_expert/system.txt (별도 파일)
당신은 2026년 대한민국 세법 전문가입니다.

주요 역할:
1. 소득세 계산 및 분석
2. 공제 항목 검토
3. 절세 전략 제안

답변 원칙:
- 근거 법령을 반드시 명시
- 계산 과정을 단계별로 설명
- 주의사항 및 예외사항 안내
- 전문 용어는 쉽게 풀어서 설명


# src/prompts/templates/tax_expert/user_query.txt (별도 파일)
사용자 질의: {query}

참고 문서:
{documents}

위 정보를 바탕으로 다음 형식으로 답변해주세요:

1. 요약 답변
2. 상세 설명
3. 근거 법령
4. 계산 과정 (해당시)
5. 주의사항
```

---

## 마이그레이션 단계별 가이드

### 1단계: 테스트 작성 (리팩토링 전)
```python
# tests/test_multi_excel_service.py
import pytest
from backend.services.excel_service import ExcelService

@pytest.fixture
def excel_service():
    # 의존성 모킹
    return ExcelService(
        agent=MockAgent(),
        repository=MockRepository(),
        validator=MockValidator()
    )

def test_process_valid_files(excel_service):
    """정상 파일 처리 테스트"""
    files = [create_mock_file("test.xlsx")]
    result = await excel_service.process_files(files)
    assert result.success is True

def test_process_invalid_files(excel_service):
    """잘못된 파일 처리 테스트"""
    files = [create_mock_file("test.txt")]
    with pytest.raises(ValidationError):
        await excel_service.process_files(files)
```

### 2단계: 새 구조 생성
```bash
# 디렉토리 구조 생성
mkdir -p backend/services
mkdir -p backend/repositories
mkdir -p backend/models/{requests,responses}
mkdir -p backend/core
```

### 3단계: 점진적 마이그레이션
```python
# 1. 새 엔드포인트 추가 (기존 유지)
@router.post("/api/v1/multi-excel")  # 기존
async def process_multi_excel_old(...):
    pass

@router.post("/api/v2/multi-excel")  # 신규
async def process_multi_excel(...):
    pass

# 2. 테스트 및 검증
# 3. 기존 엔드포인트를 새 구조로 교체
# 4. 구버전 deprecated 표시
```

### 4단계: 문서 업데이트
```markdown
# MIGRATION.md

## API v1 → v2 마이그레이션

### 변경사항
- 엔드포인트: `/api/v1/multi-excel` → `/api/v2/multi-excel`
- 응답 형식 변경: ...

### 마이그레이션 일정
- 2026-02-01: v2 출시
- 2026-03-01: v1 deprecated
- 2026-04-01: v1 종료
```

---

## 체크리스트

리팩토링 시 확인할 항목:

### 시작 전
- [ ] 기존 테스트가 모두 통과하는가?
- [ ] Git에 커밋되어 있는가?
- [ ] 백업이 있는가?

### 진행 중
- [ ] 한 번에 하나씩 변경하는가?
- [ ] 각 변경 후 테스트를 실행하는가?
- [ ] 작은 커밋으로 이력을 남기는가?

### 완료 후
- [ ] 모든 테스트가 통과하는가?
- [ ] 성능이 개선되었는가? (또는 유지되는가?)
- [ ] 문서가 업데이트되었는가?
- [ ] 팀원에게 리뷰 요청했는가?
