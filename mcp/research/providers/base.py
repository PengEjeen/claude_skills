"""
추상 SearchProvider 인터페이스.
모든 검색 provider는 이 클래스를 상속하여 search / search_images를 구현해야 한다.
"""
from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field


@dataclass
class SearchResult:
    """단일 검색 결과를 나타내는 데이터 클래스."""

    title: str
    url: str
    snippet: str
    source: str = ""       # 결과 출처 도메인
    thumbnail: str = ""    # 이미지 URL (있을 경우)
    extra: dict = field(default_factory=dict)  # provider별 추가 메타


class SearchProvider(ABC):
    """모든 검색 provider가 구현해야 하는 추상 인터페이스."""

    @abstractmethod
    async def search(self, query: str, num: int = 10) -> list[SearchResult]:
        """쿼리로 웹 검색하고 결과 리스트를 반환."""
        ...

    @abstractmethod
    async def search_images(self, query: str, num: int = 8) -> list[SearchResult]:
        """이미지 검색 (디자인 레퍼런스용)."""
        ...

    @property
    @abstractmethod
    def name(self) -> str:
        """provider 이름."""
        ...
