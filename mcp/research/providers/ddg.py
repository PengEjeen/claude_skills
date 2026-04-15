"""
DuckDuckGo HTML lite 파싱 기반 검색 provider.
API 키 불필요한 무료 fallback provider.
rate limit 방지를 위해 요청 간 0.5초 딜레이를 적용한다.
"""
from __future__ import annotations

import asyncio
import logging
import re
from urllib.parse import urljoin

import httpx
from bs4 import BeautifulSoup

from ..config import ResearchConfig
from .base import SearchProvider, SearchResult

logger = logging.getLogger(__name__)

_DDG_HTML_URL = "https://html.duckduckgo.com/html/"
_RATE_LIMIT_DELAY = 0.5  # seconds between requests


class DuckDuckGoProvider(SearchProvider):
    """DuckDuckGo HTML 파싱 기반 검색 provider."""

    def __init__(self, config: ResearchConfig) -> None:
        self._config = config

    @property
    def name(self) -> str:
        return "ddg"

    async def search(self, query: str, num: int = 10) -> list[SearchResult]:
        """DuckDuckGo HTML에서 웹 검색 결과를 파싱하여 반환."""
        await asyncio.sleep(_RATE_LIMIT_DELAY)
        try:
            async with httpx.AsyncClient(
                timeout=self._config.request_timeout,
                follow_redirects=True,
            ) as client:
                resp = await client.post(
                    _DDG_HTML_URL,
                    data={"q": query},
                    headers={
                        "Content-Type": "application/x-www-form-urlencoded",
                        "User-Agent": self._config.user_agent,
                        "Accept": "text/html,application/xhtml+xml,*/*",
                        "Accept-Language": "ko-KR,ko;q=0.9,en;q=0.8",
                    },
                )
                resp.raise_for_status()
        except httpx.HTTPError as exc:
            logger.warning("DDG search HTTP error for query=%r: %s", query, exc)
            return []
        except Exception as exc:
            logger.warning("DDG search unexpected error for query=%r: %s", query, exc)
            return []

        return self._parse_results(resp.text, num)

    async def search_images(self, query: str, num: int = 8) -> list[SearchResult]:
        """디자인 레퍼런스 이미지 검색 — Dribbble/Behance를 우선 타깃으로 한다."""
        image_query = f"{query} site:dribbble.com OR site:behance.net"
        await asyncio.sleep(_RATE_LIMIT_DELAY)
        try:
            async with httpx.AsyncClient(
                timeout=self._config.request_timeout,
                follow_redirects=True,
            ) as client:
                resp = await client.post(
                    _DDG_HTML_URL,
                    data={"q": image_query},
                    headers={
                        "Content-Type": "application/x-www-form-urlencoded",
                        "User-Agent": self._config.user_agent,
                        "Accept": "text/html,application/xhtml+xml,*/*",
                        "Accept-Language": "ko-KR,ko;q=0.9,en;q=0.8",
                    },
                )
                resp.raise_for_status()
        except httpx.HTTPError as exc:
            logger.warning("DDG image search HTTP error for query=%r: %s", query, exc)
            return []
        except Exception as exc:
            logger.warning("DDG image search unexpected error for query=%r: %s", query, exc)
            return []

        return self._parse_results(resp.text, num)

    # ------------------------------------------------------------------
    # Private helpers
    # ------------------------------------------------------------------

    def _parse_results(self, html: str, num: int) -> list[SearchResult]:
        """DuckDuckGo HTML에서 검색 결과를 파싱한다."""
        results: list[SearchResult] = []
        try:
            soup = BeautifulSoup(html, "html.parser")
            result_divs = soup.find_all("div", class_="result")

            for div in result_divs[:num]:
                title_tag = div.find("a", class_="result__a")
                snippet_tag = div.find("a", class_="result__snippet")

                if not title_tag:
                    continue

                title = title_tag.get_text(strip=True)
                raw_url = title_tag.get("href", "")
                url = self._extract_url(raw_url)
                snippet = snippet_tag.get_text(strip=True) if snippet_tag else ""
                source = self._extract_domain(url)

                if not url:
                    continue

                results.append(
                    SearchResult(
                        title=title,
                        url=url,
                        snippet=snippet,
                        source=source,
                    )
                )
        except Exception as exc:
            logger.warning("DDG parse error: %s", exc)

        return results

    @staticmethod
    def _extract_url(raw: str) -> str:
        """DuckDuckGo redirect URL에서 실제 URL을 추출한다."""
        if not raw:
            return ""
        # DDG sometimes wraps URLs in a redirect path like //duckduckgo.com/l/?uddg=...
        uddg_match = re.search(r"uddg=([^&]+)", raw)
        if uddg_match:
            from urllib.parse import unquote
            return unquote(uddg_match.group(1))
        if raw.startswith("http"):
            return raw
        return ""

    @staticmethod
    def _extract_domain(url: str) -> str:
        """URL에서 도메인만 추출한다."""
        match = re.search(r"https?://([^/]+)", url)
        return match.group(1) if match else ""
