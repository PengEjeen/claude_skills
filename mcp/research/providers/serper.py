"""
Serper.dev Google Search API 어댑터.
웹 검색과 이미지 검색을 모두 지원한다.
API 키: SERPER_API_KEY 환경변수 필요.
"""
from __future__ import annotations

import logging
import re

import httpx

from ..config import ResearchConfig
from .base import SearchProvider, SearchResult

logger = logging.getLogger(__name__)

_SERPER_SEARCH_URL = "https://google.serper.dev/search"
_SERPER_IMAGE_URL = "https://google.serper.dev/images"


class SerperProvider(SearchProvider):
    """Serper.dev 기반 Google Search 어댑터."""

    def __init__(self, api_key: str, config: ResearchConfig) -> None:
        self._api_key = api_key
        self._config = config

    @property
    def name(self) -> str:
        return "serper"

    def _headers(self) -> dict[str, str]:
        return {
            "X-API-KEY": self._api_key,
            "Content-Type": "application/json",
            "User-Agent": self._config.user_agent,
        }

    async def search(self, query: str, num: int = 10) -> list[SearchResult]:
        """Serper.dev로 웹 검색 결과를 반환한다."""
        payload = {"q": query, "num": min(num, 100)}
        try:
            async with httpx.AsyncClient(
                timeout=self._config.request_timeout,
                follow_redirects=True,
            ) as client:
                resp = await client.post(
                    _SERPER_SEARCH_URL,
                    headers=self._headers(),
                    json=payload,
                )
                resp.raise_for_status()
                data = resp.json()
        except httpx.HTTPError as exc:
            logger.warning("Serper search HTTP error for query=%r: %s", query, exc)
            return []
        except Exception as exc:
            logger.warning("Serper search unexpected error for query=%r: %s", query, exc)
            return []

        results: list[SearchResult] = []
        for item in data.get("organic", []):
            url = item.get("link", "")
            results.append(
                SearchResult(
                    title=item.get("title", ""),
                    url=url,
                    snippet=item.get("snippet", ""),
                    source=self._extract_domain(url),
                )
            )
        return results[:num]

    async def search_images(self, query: str, num: int = 8) -> list[SearchResult]:
        """Serper.dev로 이미지 검색 결과를 반환한다."""
        payload = {"q": query, "num": min(num, 100)}
        try:
            async with httpx.AsyncClient(
                timeout=self._config.request_timeout,
                follow_redirects=True,
            ) as client:
                resp = await client.post(
                    _SERPER_IMAGE_URL,
                    headers=self._headers(),
                    json=payload,
                )
                resp.raise_for_status()
                data = resp.json()
        except httpx.HTTPError as exc:
            logger.warning("Serper image search HTTP error for query=%r: %s", query, exc)
            return []
        except Exception as exc:
            logger.warning("Serper image search unexpected error for query=%r: %s", query, exc)
            return []

        results: list[SearchResult] = []
        for item in data.get("images", []):
            url = item.get("imageUrl", "")
            results.append(
                SearchResult(
                    title=item.get("title", ""),
                    url=url,
                    snippet="",
                    source=self._extract_domain(url),
                    thumbnail=item.get("thumbnailUrl", ""),
                )
            )
        return results[:num]

    @staticmethod
    def _extract_domain(url: str) -> str:
        match = re.search(r"https?://([^/]+)", url)
        return match.group(1) if match else ""
