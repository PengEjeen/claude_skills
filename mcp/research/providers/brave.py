"""
Brave Search API 어댑터.
웹 검색과 이미지 검색을 모두 지원한다.
API 키: BRAVE_API_KEY 환경변수 필요.
"""
from __future__ import annotations

import logging
import re

import httpx

from ..config import ResearchConfig
from .base import SearchProvider, SearchResult

logger = logging.getLogger(__name__)

_BRAVE_WEB_URL = "https://api.search.brave.com/res/v1/web/search"
_BRAVE_IMAGE_URL = "https://api.search.brave.com/res/v1/images/search"


class BraveProvider(SearchProvider):
    """Brave Search API 기반 검색 provider."""

    def __init__(self, api_key: str, config: ResearchConfig) -> None:
        self._api_key = api_key
        self._config = config

    @property
    def name(self) -> str:
        return "brave"

    def _headers(self) -> dict[str, str]:
        return {
            "Accept": "application/json",
            "Accept-Encoding": "gzip",
            "X-Subscription-Token": self._api_key,
            "User-Agent": self._config.user_agent,
        }

    async def search(self, query: str, num: int = 10) -> list[SearchResult]:
        """Brave Web Search API로 검색 결과를 반환한다."""
        params = {
            "q": query,
            "count": min(num, 20),
            "search_lang": "ko",
        }
        try:
            async with httpx.AsyncClient(
                timeout=self._config.request_timeout,
                follow_redirects=True,
            ) as client:
                resp = await client.get(
                    _BRAVE_WEB_URL,
                    headers=self._headers(),
                    params=params,
                )
                resp.raise_for_status()
                data = resp.json()
        except httpx.HTTPError as exc:
            logger.warning("Brave search HTTP error for query=%r: %s", query, exc)
            return []
        except Exception as exc:
            logger.warning("Brave search unexpected error for query=%r: %s", query, exc)
            return []

        results: list[SearchResult] = []
        for item in data.get("web", {}).get("results", []):
            url = item.get("url", "")
            results.append(
                SearchResult(
                    title=item.get("title", ""),
                    url=url,
                    snippet=item.get("description", ""),
                    source=self._extract_domain(url),
                )
            )
        return results[:num]

    async def search_images(self, query: str, num: int = 8) -> list[SearchResult]:
        """Brave Image Search API로 이미지 결과를 반환한다."""
        params = {
            "q": query,
            "count": min(num, 20),
        }
        try:
            async with httpx.AsyncClient(
                timeout=self._config.request_timeout,
                follow_redirects=True,
            ) as client:
                resp = await client.get(
                    _BRAVE_IMAGE_URL,
                    headers=self._headers(),
                    params=params,
                )
                resp.raise_for_status()
                data = resp.json()
        except httpx.HTTPError as exc:
            logger.warning("Brave image search HTTP error for query=%r: %s", query, exc)
            return []
        except Exception as exc:
            logger.warning("Brave image search unexpected error for query=%r: %s", query, exc)
            return []

        results: list[SearchResult] = []
        for item in data.get("results", []):
            url = item.get("url", "")
            results.append(
                SearchResult(
                    title=item.get("title", ""),
                    url=url,
                    snippet="",
                    source=self._extract_domain(url),
                    thumbnail=item.get("thumbnail", {}).get("src", ""),
                )
            )
        return results[:num]

    @staticmethod
    def _extract_domain(url: str) -> str:
        match = re.search(r"https?://([^/]+)", url)
        return match.group(1) if match else ""
