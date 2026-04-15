"""
CachedProvider — SearchProvider에 TTL 캐시 레이어를 추가하는 래퍼.

동일 쿼리+num 조합의 검색 결과를 search_cache(TTL 5분)에 저장하여
반복 API 호출을 줄인다.
"""
from __future__ import annotations

import hashlib
import logging

from mcp.shared.cache import search_cache
from .base import SearchProvider, SearchResult

logger = logging.getLogger(__name__)


class CachedProvider(SearchProvider):
    """임의의 SearchProvider를 감싸 TTL 캐시를 적용하는 데코레이터 클래스."""

    def __init__(self, inner: SearchProvider) -> None:
        self._inner = inner

    @property
    def name(self) -> str:
        return f"cached:{self._inner.name}"

    @staticmethod
    def _key(prefix: str, query: str, num: int) -> str:
        """캐시 키 — provider+prefix+쿼리+num의 SHA256 앞 16자."""
        raw = f"{prefix}:{query}:{num}"
        return hashlib.sha256(raw.encode()).hexdigest()[:16]

    async def search(self, query: str, num: int = 10) -> list[SearchResult]:
        key = self._key(f"web:{self._inner.name}", query, num)
        cached = await search_cache.get(key)
        if cached is not None:
            logger.debug("Cache hit [web] query=%r", query)
            return [SearchResult(**item) for item in cached]

        results = await self._inner.search(query, num)
        if results:
            await search_cache.set(key, [r.__dict__ for r in results])
        return results

    async def search_images(self, query: str, num: int = 8) -> list[SearchResult]:
        key = self._key(f"img:{self._inner.name}", query, num)
        cached = await search_cache.get(key)
        if cached is not None:
            logger.debug("Cache hit [img] query=%r", query)
            return [SearchResult(**item) for item in cached]

        results = await self._inner.search_images(query, num)
        if results:
            await search_cache.set(key, [r.__dict__ for r in results])
        return results
