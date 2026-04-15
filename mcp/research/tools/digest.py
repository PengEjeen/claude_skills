"""
URL 다이제스트 도구.
URL을 fetch하고 타입(app/design/article)에 따라 구조화된 다이제스트를 반환한다.
auto 모드에서는 URL과 콘텐츠를 분석하여 타입을 자동 감지한다.
"""
from __future__ import annotations

import hashlib
import logging
import re
from datetime import datetime, timezone
from urllib.parse import urlparse

import httpx
from bs4 import BeautifulSoup

from mcp.shared.cache import page_cache
from ..config import config
from ..models.schemas import DigestResult

logger = logging.getLogger(__name__)

_DESIGN_URL_SIGNALS = ["dribbble", "behance", "figma", "mobbin", "ui8"]
_APP_URL_SIGNALS = ["producthunt", "appstore", "apps.apple", "play.google", "alternativeto"]
_PRICING_KEYWORDS = ["free", "premium", "pro", "paid", "$", "₩", "pricing", "plan", "subscribe", "price"]
_FEATURE_KEYWORDS = ["feature", "기능", "function", "capability", "support", "allows", "enables"]


async def open_reference_digest(url: str, digest_type: str = "auto") -> dict:
    html, fetch_error = await _fetch_page(url)
    if fetch_error:
        return DigestResult(
            meta={"fetched_at": datetime.now(timezone.utc).isoformat(), "url": url, "digest_type": digest_type, "error": fetch_error},
            summary=f"페이지를 가져올 수 없습니다: {fetch_error}", key_points=[], extracted={},
            relevance_for_pm="fetch 실패로 분석 불가", relevance_for_designer="fetch 실패로 분석 불가",
        ).model_dump()

    title, meta_desc, text, images = _parse_html(html)
    effective_type = digest_type if digest_type != "auto" else detect_type(url, title, text)
    summary = _build_summary(title, meta_desc, text, effective_type)
    key_points = _extract_key_points(text, effective_type)
    extracted = _build_extracted(url, title, text, images, effective_type)
    relevance_pm = _build_relevance_pm(title, extracted, effective_type)
    relevance_designer = _build_relevance_designer(title, extracted, images, effective_type)

    return DigestResult(
        meta={"fetched_at": datetime.now(timezone.utc).isoformat(), "url": url, "digest_type": effective_type, "title": title, "word_count": len(text.split())},
        summary=summary, key_points=key_points, extracted=extracted,
        relevance_for_pm=relevance_pm, relevance_for_designer=relevance_designer,
    ).model_dump()


def detect_type(url: str, title: str, text: str) -> str:
    url_lower = url.lower()
    if any(s in url_lower for s in _DESIGN_URL_SIGNALS):
        return "design"
    if any(s in url_lower for s in _APP_URL_SIGNALS):
        return "app"
    return "article"


def _url_cache_key(url: str) -> str:
    return hashlib.sha256(url.encode()).hexdigest()[:16]


async def _fetch_page(url: str) -> tuple[str, str]:
    cache_key = _url_cache_key(url)
    cached_html = await page_cache.get(cache_key)
    if cached_html is not None:
        return cached_html, ""
    try:
        async with httpx.AsyncClient(timeout=15.0, follow_redirects=True) as client:
            resp = await client.get(url, headers={
                "User-Agent": config.user_agent,
                "Accept": "text/html,application/xhtml+xml,*/*",
                "Accept-Language": "ko-KR,ko;q=0.9,en;q=0.8",
            })
            resp.raise_for_status()
            html = resp.text
            await page_cache.set(cache_key, html)
            return html, ""
    except httpx.HTTPStatusError as exc:
        return "", f"HTTP {exc.response.status_code}: {exc.response.reason_phrase}"
    except httpx.TimeoutException:
        return "", "요청 시간 초과"
    except httpx.HTTPError as exc:
        return "", f"HTTP 오류: {exc}"
    except Exception as exc:
        return "", f"예기치 못한 오류: {exc}"


def _parse_html(html: str) -> tuple[str, str, str, list[str]]:
    try:
        soup = BeautifulSoup(html, "html.parser")
        for tag in soup(["script", "style", "nav", "footer", "iframe", "aside"]):
            tag.decompose()
        title = soup.title.string.strip() if soup.title and soup.title.string else ""
        meta_tag = soup.find("meta", attrs={"name": "description"})
        meta_desc = meta_tag.get("content", "") if meta_tag else ""
        main_content = soup.find("article") or soup.find("main") or soup.find("body")
        text = main_content.get_text(separator="\n", strip=True)[:5000] if main_content else ""
        images = [img.get("src", "") for img in soup.find_all("img") if img.get("src")][:10]
        return title, meta_desc, text, images
    except Exception:
        return "", "", "", []


def _build_summary(title: str, meta_desc: str, text: str, digest_type: str) -> str:
    if meta_desc:
        return f"{title}: {meta_desc}" if title else meta_desc
    paragraphs = [p.strip() for p in text.split("\n") if len(p.strip()) > 30]
    first_para = paragraphs[0] if paragraphs else ""
    if title and first_para:
        return f"{title} — {first_para[:200]}"
    return title or first_para[:200] or "내용을 요약할 수 없습니다."


def _extract_key_points(text: str, digest_type: str) -> list[str]:
    key_points: list[str] = []
    paragraphs = [p.strip() for p in text.split("\n") if len(p.strip()) > 40]
    if digest_type == "app":
        for para in paragraphs[:20]:
            if any(kw in para.lower() for kw in _FEATURE_KEYWORDS + _PRICING_KEYWORDS):
                key_points.append(para[:150])
                if len(key_points) >= 5:
                    break
    elif digest_type == "design":
        for para in paragraphs[:20]:
            if any(kw in para.lower() for kw in ["design", "color", "font", "component", "icon", "ui", "style", "theme"]):
                key_points.append(para[:150])
                if len(key_points) >= 5:
                    break
    else:
        key_points = [p[:150] for p in paragraphs[:5]]
    if len(key_points) < 3:
        for para in paragraphs:
            if para[:150] not in key_points:
                key_points.append(para[:150])
            if len(key_points) >= 3:
                break
    return key_points[:5]


def _build_extracted(url: str, title: str, text: str, images: list[str], digest_type: str) -> dict:
    if digest_type == "app":
        return _extract_app_info(url, title, text, images)
    if digest_type == "design":
        return _extract_design_info(url, title, text, images)
    return _extract_article_info(url, title, text)


def _extract_app_info(url: str, title: str, text: str, images: list[str]) -> dict:
    app_name = title.split(" - ")[0].split(" | ")[0].strip() if title else ""
    text_lower = text.lower()
    features: list[str] = []
    for kw in _FEATURE_KEYWORDS:
        idx = text_lower.find(kw)
        while idx != -1 and len(features) < 8:
            snippet = re.sub(r"\s+", " ", text[max(0, idx - 20): idx + 100].strip())
            if len(snippet) > 10 and snippet not in features:
                features.append(snippet[:120])
            idx = text_lower.find(kw, idx + 1)
    pricing_info: list[str] = []
    for kw in _PRICING_KEYWORDS:
        idx = text_lower.find(kw)
        while idx != -1 and len(pricing_info) < 4:
            snippet = re.sub(r"\s+", " ", text[max(0, idx - 10): idx + 80].strip())
            if len(snippet) > 5 and snippet not in pricing_info:
                pricing_info.append(snippet[:100])
            idx = text_lower.find(kw, idx + 1)
    platforms = [p for p in ["ios", "android", "web", "windows", "macos", "linux"] if p in text_lower]
    screenshots = [img for img in images if any(kw in img.lower() for kw in ["screenshot", "screen", "preview"])] or images[:5]
    return {"name": app_name, "features": features[:6], "pricing": pricing_info[:3], "screenshots": screenshots[:5], "platforms": platforms}


def _extract_design_info(url: str, title: str, text: str, images: list[str]) -> dict:
    color_palette = list(set(re.findall(r"#[0-9A-Fa-f]{6}", text)))[:8]
    fonts = list({f.strip().strip('"').strip("'") for f in re.findall(r'font-family\s*:\s*["\']?([^;"\']+)["\']?', text, re.IGNORECASE)})[:5]
    components = [kw for kw in ["button", "input", "modal", "card", "nav", "tab", "icon", "avatar", "badge", "chip", "toast", "slider", "toggle"] if kw in text.lower()][:8]
    return {"color_palette": color_palette, "fonts": fonts, "components": components, "image_urls": images[:8]}


def _extract_article_info(url: str, title: str, text: str) -> dict:
    author_match = re.search(r'(?:by|author|작성자)[:\s]+([A-Za-z가-힣\s]{2,30})', text, re.IGNORECASE)
    author = author_match.group(1).strip() if author_match else ""
    date_match = re.search(r'(\d{4}[-./]\d{1,2}[-./]\d{1,2})', text)
    published_date = date_match.group(1) if date_match else ""
    return {"author": author, "published_date": published_date, "main_content": re.sub(r"\s+", " ", text[:500]).strip(), "word_count": len(text.split())}


def _build_relevance_pm(title: str, extracted: dict, digest_type: str) -> str:
    if digest_type == "app":
        return f"앱명: {extracted.get('name', title)} | 기능 {len(extracted.get('features', []))}개 | 가격: {(extracted.get('pricing', []) or ['정보 없음'])[0][:50]}"
    if digest_type == "design":
        return f"'{title}' — 디자인 레퍼런스 페이지. PM 관련성 낮음."
    return f"'{title}' — 아티클 ({extracted.get('word_count', 0)}단어). 시장/기술 참고 자료."


def _build_relevance_designer(title: str, extracted: dict, images: list[str], digest_type: str) -> str:
    if digest_type == "design":
        colors = ", ".join(extracted.get("color_palette", [])[:3]) or "색상 미발견"
        comps = ", ".join(extracted.get("components", [])[:3]) or "컴포넌트 정보 없음"
        return f"컬러: {colors} | 컴포넌트: {comps} | 이미지 {len(images)}개"
    if digest_type == "app":
        return f"앱 스크린샷 {len(extracted.get('screenshots', []))}개 | 플랫폼: {', '.join(extracted.get('platforms', [])) or '미상'} — UI 레퍼런스로 활용 가능"
    return f"'{title}' — 아티클. 디자인 인사이트 추출 가능성 낮음."
