---
name: backend-api
description: FastAPI 기반 백엔드 API를 구현하고 테스트합니다. "백엔드 구현", "FastAPI", "엔드포인트 구현", "API 구현", "라우터", "미들웨어", "backend", "endpoint", "router", "middleware", "Pydantic" 등의 요청 시 사용합니다. API 설계, 요청 검증, 데이터베이스 통합, 인증/인가를 포함합니다. (설계 원칙은 api-design, PM용 명세는 api-spec-generator 스킬 참조)
allowed-tools: Read, Write, Edit, Bash
---

# FastAPI 백엔드 API 개발 가이드

## 📋 구현 프로세스

1. **API 설계**: RESTful 원칙에 따라 엔드포인트 설계
2. **라우트 정의**: `backend/routes/` 디렉토리에 모듈 추가
3. **데이터 모델**: Pydantic 모델로 요청/응답 스키마 정의
4. **비즈니스 로직**: 서비스 계층에서 핵심 로직 구현
5. **테스트**: pytest로 엔드포인트 검증

## 🎯 코드 스타일 (2026 Best Practices)

### 필수 원칙
- ✅ **Type Hints**: 모든 함수/메서드에 타입 명시
- ✅ **Pydantic v2**: 최신 문법 준수 (`Field`, `model_validator`)
- ✅ **계층 분리**: Routes → Services → Repositories
- ✅ **에러 처리**: `HTTPException`으로 명확한 상태 코드 반환
- ✅ **로깅**: 구조화된 로깅 (`logger.info`, `logger.error`)

### 선택적 개선
- 🔧 **의존성 주입**: `Depends()`로 결합도 낮추기
- 🔧 **비동기 처리**: I/O 작업은 `async/await` 사용
- 🔧 **미들웨어**: 인증, 로깅, CORS 등

## 📁 권장 파일 구조

```
backend/
├── routes/              # API 엔드포인트 (Presentation Layer)
│   ├── __init__.py
│   ├── users.py         # 사용자 관리 API
│   ├── items.py         # 아이템 관리 API
│   └── search.py        # 검색 API
├── services/            # 비즈니스 로직 (Business Logic Layer)
│   ├── __init__.py
│   ├── user_service.py
│   └── item_service.py
├── repositories/        # 데이터 액세스 (Data Access Layer)
│   ├── __init__.py
│   ├── user_repository.py
│   └── item_repository.py
├── models/              # Pydantic 모델
│   ├── __init__.py
│   ├── requests.py      # 요청 스키마
│   └── responses.py     # 응답 스키마
├── schemas/             # DB 스키마 (SQLAlchemy ORM)
│   └── tables.py
├── core/                # 핵심 설정
│   ├── config.py        # 환경 설정
│   ├── dependencies.py  # 의존성 주입
│   └── exceptions.py    # 커스텀 예외
└── utils/               # 유틸리티
    └── validators.py
```

## 🛠️ 주요 패턴

### 1. 계층 분리 패턴 (Clean Architecture)

#### ✅ GOOD - 계층별 명확한 역할 분리

```python
# backend/routes/items.py (Presentation Layer)
from fastapi import APIRouter, Depends, HTTPException
from typing import List

from ..models.requests import ItemCreateRequest
from ..models.responses import ItemResponse
from ..services.item_service import ItemService
from ..core.dependencies import get_item_service

router = APIRouter(prefix="/api/items", tags=["items"])

@router.post("/", response_model=ItemResponse, status_code=201)
async def create_item(
    request: ItemCreateRequest,
    service: ItemService = Depends(get_item_service)
) -> ItemResponse:
    """아이템 생성 엔드포인트 (라우팅만 담당)"""
    return await service.create_item(request)


# backend/services/item_service.py (Business Logic Layer)
from typing import List, Optional

class ItemService:
    """아이템 관리 비즈니스 로직"""

    def __init__(self, repository: ItemRepository):
        self.repository = repository

    async def create_item(self, request: ItemCreateRequest) -> ItemResponse:
        """아이템 생성 로직"""
        # 1. 검증
        if not self._validate_item(request):
            raise ValueError("Invalid item data")

        # 2. 생성
        created_item = await self.repository.create(request)

        # 3. 응답 변환
        return ItemResponse.from_orm(created_item)


# backend/repositories/item_repository.py (Data Access Layer)
class ItemRepository:
    """아이템 데이터 액세스"""

    def __init__(self, db: Session):
        self.db = db

    async def create(self, data: ItemCreateRequest) -> Item:
        """DB에 아이템 저장"""
        db_item = ItemModel(**data.dict())
        self.db.add(db_item)
        await self.db.commit()
        await self.db.refresh(db_item)
        return db_item
```

#### ❌ BAD - 모든 로직이 라우트에

```python
@router.post("/api/items")
async def create_item(request: ItemCreateRequest):
    # DB 연결, 검증, 생성, 에러 처리 모두 한 곳에
    db = get_db()
    if not request.name:
        raise HTTPException(status_code=400)
    item = ItemModel(name=request.name)
    db.add(item)
    db.commit()
    return item
```

### 2. 데이터 모델 패턴 (Pydantic v2)

```python
# backend/models/requests.py
from pydantic import BaseModel, Field, field_validator
from typing import Optional
from datetime import datetime

class ItemCreateRequest(BaseModel):
    """아이템 생성 요청"""

    name: str = Field(..., min_length=1, max_length=100, description="아이템 이름")
    description: Optional[str] = Field(None, max_length=500)
    price: float = Field(..., gt=0, description="가격 (0보다 커야 함)")
    quantity: int = Field(default=1, ge=0)

    @field_validator('name')
    @classmethod
    def validate_name(cls, v: str) -> str:
        """이름 검증"""
        if not v.strip():
            raise ValueError("Name cannot be empty")
        return v.strip()

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "name": "Sample Item",
                    "description": "This is a sample",
                    "price": 29.99,
                    "quantity": 10
                }
            ]
        }
    }


# backend/models/responses.py
class ItemResponse(BaseModel):
    """아이템 응답"""

    id: int
    name: str
    description: Optional[str]
    price: float
    quantity: int
    created_at: datetime

    model_config = {"from_attributes": True}  # ORM 지원
```

### 3. 에러 처리 패턴

```python
from fastapi import HTTPException, status
from fastapi.responses import JSONResponse
import logging

logger = logging.getLogger(__name__)

# 커스텀 예외 정의
class ItemNotFoundError(Exception):
    """아이템을 찾을 수 없음"""
    pass

class InvalidItemDataError(Exception):
    """유효하지 않은 아이템 데이터"""
    pass


# 라우트에서 사용
@router.get("/{item_id}", response_model=ItemResponse)
async def get_item(
    item_id: int,
    service: ItemService = Depends(get_item_service)
) -> ItemResponse:
    """아이템 조회"""
    try:
        return await service.get_item_by_id(item_id)

    except ItemNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item with id {item_id} not found"
        )

    except InvalidItemDataError as e:
        logger.error(f"Invalid item data: {e}")
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(e)
        )

    except Exception as e:
        logger.exception(f"Unexpected error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


# 전역 예외 핸들러 (main.py)
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

app = FastAPI()

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """전역 예외 처리"""
    logger.exception(f"Unhandled exception: {exc}")
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"}
    )
```

### 4. 의존성 주입 패턴

```python
# backend/core/dependencies.py
from fastapi import Depends
from sqlalchemy.orm import Session
from typing import Generator

from ..repositories.item_repository import ItemRepository
from ..services.item_service import ItemService
from .database import SessionLocal

def get_db() -> Generator[Session, None, None]:
    """데이터베이스 세션 의존성"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_item_repository(
    db: Session = Depends(get_db)
) -> ItemRepository:
    """아이템 저장소 의존성"""
    return ItemRepository(db)


def get_item_service(
    repository: ItemRepository = Depends(get_item_repository)
) -> ItemService:
    """아이템 서비스 의존성"""
    return ItemService(repository)
```

### 5. 비동기 처리 패턴

```python
import asyncio
from typing import List

# 병렬 처리
async def process_multiple_items(item_ids: List[int]) -> List[ItemResponse]:
    """여러 아이템 병렬 처리"""
    tasks = [fetch_item(item_id) for item_id in item_ids]
    results = await asyncio.gather(*tasks, return_exceptions=True)

    # 에러 필터링
    successful_results = [
        r for r in results
        if not isinstance(r, Exception)
    ]

    return successful_results


# 타임아웃
from asyncio import timeout

async def fetch_with_timeout(url: str, timeout_seconds: int = 5):
    """타임아웃이 있는 외부 API 호출"""
    async with timeout(timeout_seconds):
        async with httpx.AsyncClient() as client:
            response = await client.get(url)
            return response.json()
```

## 🧪 테스트 패턴

```python
# tests/test_items_api.py
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from backend.main import app
from backend.core.dependencies import get_db
from backend.schemas.tables import Base

# 테스트 DB 설정
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture
def client():
    """테스트 클라이언트 픽스처"""
    Base.metadata.create_all(bind=engine)
    yield TestClient(app)
    Base.metadata.drop_all(bind=engine)


def test_create_item(client):
    """아이템 생성 테스트"""
    response = client.post(
        "/api/items/",
        json={
            "name": "Test Item",
            "description": "Test description",
            "price": 19.99,
            "quantity": 5
        }
    )

    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Test Item"
    assert data["price"] == 19.99


def test_get_item_not_found(client):
    """존재하지 않는 아이템 조회"""
    response = client.get("/api/items/999")
    assert response.status_code == 404


def test_invalid_item_data(client):
    """잘못된 데이터로 아이템 생성"""
    response = client.post(
        "/api/items/",
        json={"name": "", "price": -10}  # 잘못된 데이터
    )
    assert response.status_code == 422
```

## 🚀 실행 및 테스트

### 개발 서버 실행

```bash
# uvicorn으로 실행
uvicorn backend.main:app --reload --port 8000

# 특정 호스트/포트 지정
uvicorn backend.main:app --host 0.0.0.0 --port 8080
```

### 테스트 실행

```bash
# 전체 테스트
pytest

# 특정 파일 테스트
pytest tests/test_items_api.py -v

# 커버리지 확인
pytest --cov=backend tests/

# 특정 테스트만
pytest tests/test_items_api.py::test_create_item -v
```

### API 문서 확인

```bash
# 서버 실행 후:
# - Swagger UI: http://localhost:8000/docs
# - ReDoc: http://localhost:8000/redoc
```

## 📚 추가 리소스

- [FastAPI 공식 문서](https://fastapi.tiangolo.com/)
- [Pydantic v2 문서](https://docs.pydantic.dev/latest/)
- [SQLAlchemy 문서](https://docs.sqlalchemy.org/)
