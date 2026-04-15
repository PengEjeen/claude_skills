"""
디자이너용 UI/UX 디자인 레퍼런스 리서치 도구.
query, style, platform을 받아 Dribbble/Behance/Material Design 등에서
디자인 레퍼런스를 병렬 수집하고, DesignRefsResult 구조로 반환한다.
"""
from __future__ import annotations

import asyncio
import logging
import re
from datetime import datetime, timezone

from ..models.schemas import (
    DesignerBrief,
    DesignPattern,
    DesignRef,
    DesignRefsResult,
)
from ..providers import SearchResult, get_provider

logger = logging.getLogger(__name__)

# 디자인 패턴 키워드 → 패턴 이름 매핑
_PATTERN_KEYWORDS: list[tuple[list[str], str, str]] = [
    (["bottom navigation", "tab bar", "bottom tab"], "Bottom Navigation", "하단 탭 네비게이션 패턴"),
    (["card", "cards", "card list"], "Card/List", "카드 또는 리스트 기반 콘텐츠 표시 패턴"),
    (["floating", "fab", "floating action"], "FAB", "플로팅 액션 버튼 패턴"),
    (["swipe", "gesture", "swipe gesture"], "Gesture", "스와이프/제스처 기반 인터랙션 패턴"),
    (["dark mode", "night mode", "dark theme"], "Dark Mode", "다크 모드 지원"),
    (["onboarding", "tutorial", "walkthrough"], "Onboarding", "온보딩/튜토리얼 플로우"),
    (["search bar", "search field", "search ui"], "Search", "검색 UI 패턴"),
    (["modal", "bottom sheet", "drawer"], "Modal/Sheet", "모달/바텀시트 패턴"),
    (["grid", "masonry"], "Grid Layout", "그리드 레이아웃 패턴"),
    (["hamburger", "side menu", "drawer menu", "navigation drawer"], "Side Drawer", "사이드 드로어 메뉴"),
    (["hero", "hero image", "hero section"], "Hero Section", "히어로 섹션 패턴"),
]

# 컴포넌트 키워드
_COMPONENT_KEYWORDS = [
    "button", "input", "form", "modal", "toast", "snackbar",
    "chip", "badge", "avatar", "card", "list", "table",
    "tab", "navbar", "sidebar", "footer", "header",
    "icon", "illustration", "empty state", "loading", "skeleton",
    "toggle", "checkbox", "radio", "slider", "dropdown", "select",
    "progress", "spinner", "pagination", "breadcrumb", "tooltip",
]

# 색상 키워드 → 팔레트 추론
_COLOR_KEYWORDS: dict[str, list[str]] = {
    "blue": ["#0066FF", "#1DA1F2", "#0052CC"],
    "green": ["#00C853", "#00B894", "#27AE60"],
    "red": ["#FF3B30", "#E74C3C", "#D32F2F"],
    "purple": ["#6C5CE7", "#8E44AD", "#9B59B6"],
    "orange": ["#FF6B00", "#F39C12", "#FF9500"],
    "yellow": ["#F1C40F", "#FFCC00", "#FFC107"],
    "gray": ["#636E72", "#95A5A6", "#BDC3C7"],
    "black": ["#1E1E1E", "#2D3436", "#212529"],
    "white": ["#FFFFFF", "#F8F9FA", "#FAFAFA"],
    "pink": ["#E91E63", "#FF4081", "#F06292"],
    "teal": ["#00BCD4", "#009688", "#26A69A"],
    "indigo": ["#3F51B5", "#5C6BC0", "#283593"],
}

# 타이포그래피 트렌드 키워드
_TYPOGRAPHY_KEYWORDS = [
    "SF Pro", "Inter", "Roboto", "Noto Sans", "Pretendard",
    "sans-serif", "serif", "monospace",
    "bold headline", "large typography", "display font",
    "variable font",
]

# 아이콘 스타일 키워드
_ICON_STYLE_KEYWORDS = [
    "line icon", "outline icon", "filled icon", "two-tone icon",
    "flat icon", "material icon", "SF Symbol", "rounded icon",
    "bold icon", "duotone",
]


def classify_source(url: str) -> str:
    """URL 기반으로 디자인 소스를 분류한다."""
    url_lower = url.lower()
    if "dribbble.com" in url_lower:
        return "dribbble"
    if "behance.net" in url_lower:
        return "behance"
    if "mobbin.com" in url_lower:
        return "mobbin"
    if "figma.com" in url_lower:
        return "figma"
    if "pinterest.com" in url_lower:
        return "pinterest"
    if "material.io" in url_lower or "m3.material.io" in url_lower:
        return "material_design"
    if "developer.apple.com" in url_lower:
        return "apple_hig"
    return "web"


async def research_design_refs(
    query: str,
    style: str = "",
    platform: str = "mobile",
    max_results: int = 8,
) -> dict:
    """
    디자인 레퍼런스를 리서치하여 DesignRefsResult 구조의 dict를 반환한다.

    Args:
        query: 디자인 검색 쿼리 (예: "todo app UI", "onboarding screen")
        style: 원하는 디자인 스타일 (예: "minimal", "flat", "material")
        platform: 타겟 플랫폼 — "mobile" | "web" | "desktop"
        max_results: 반환할 최대 레퍼런스 수 (최대 15)

    Returns:
        DesignRefsResult.model_dump() 형태의 dict
    """
    provider = get_provider()
    q = query.strip()
    s = style.strip()
    p = platform.strip()

    # 병렬 검색 쿼리 구성
    web_queries = [
        f"{q} {s} UI design {p} dribbble".strip(),
        f"{q} {s} app design behance".strip(),
        f"{q} icon design {s}".strip(),
        f"{q} {p} UX pattern".strip(),
    ]
    image_query = f"{q} {s} mobile app design".strip()

    # 웹 검색과 이미지 검색 병렬 실행
    all_tasks = [provider.search(wq, num=10) for wq in web_queries]
    all_tasks.append(provider.search_images(image_query, num=max_results))

    raw_batches = await asyncio.gather(*all_tasks, return_exceptions=True)

    web_results: list[SearchResult] = []
    image_results: list[SearchResult] = []

    for i, batch in enumerate(raw_batches):
        if isinstance(batch, Exception):
            logger.warning("Design search query failed (index=%d): %s", i, batch)
            continue
        if i < len(web_queries):
            web_results.extend(batch)
        else:
            image_results.extend(batch)

    # URL 기준 중복 제거
    seen_urls: set[str] = set()
    unique_web: list[SearchResult] = []
    for r in web_results:
        if r.url and r.url not in seen_urls:
            seen_urls.add(r.url)
            unique_web.append(r)

    # 레퍼런스 구조화
    references = _build_design_refs(unique_web, image_results, max_results)
    all_text = " ".join(f"{r.title} {r.snippet}" for r in unique_web).lower()

    design_patterns = _extract_design_patterns(all_text)
    color_trends = _extract_color_trends(all_text, unique_web)
    typography_trends = _extract_typography(all_text)
    icon_styles = _extract_icon_styles(all_text)
    component_inventory = _extract_components(all_text)
    designer_brief = _build_designer_brief(
        q, s, references, design_patterns, color_trends, component_inventory
    )

    result = DesignRefsResult(
        meta={
            "fetched_at": datetime.now(timezone.utc).isoformat(),
            "provider": provider.name,
            "query": q,
            "style": s,
            "platform": p,
            "total_web_results": len(unique_web),
            "total_image_results": len(image_results),
        },
        references=references,
        design_patterns=design_patterns,
        color_trends=color_trends,
        typography_trends=typography_trends,
        icon_styles=icon_styles,
        component_inventory=component_inventory,
        designer_brief=designer_brief,
    )
    return result.model_dump()


# ---------------------------------------------------------------------------
# Private helpers
# ---------------------------------------------------------------------------


def _build_design_refs(
    web_results: list[SearchResult],
    image_results: list[SearchResult],
    max_results: int,
) -> list[DesignRef]:
    """웹/이미지 결과를 합쳐 DesignRef 목록을 구성한다."""
    refs: list[DesignRef] = []
    rank = 1
    seen_urls: set[str] = set()

    # 이미지 결과를 thumbnail과 함께 먼저 처리
    for r in image_results:
        if rank > max_results:
            break
        if not r.url or r.url in seen_urls:
            continue
        seen_urls.add(r.url)

        combined = f"{r.title} {r.snippet}".lower()
        refs.append(
            DesignRef(
                rank=rank,
                title=_clean_text(r.title),
                source=classify_source(r.url),
                url=r.url,
                thumbnail_url=r.thumbnail,
                tags=_extract_tags(combined),
                color_palette=_extract_hex_colors(combined),
                spotted_components=_extract_spotted_components(combined),
                design_notes=_clean_text(r.snippet),
            )
        )
        rank += 1

    # 웹 결과로 나머지 채우기
    for r in web_results:
        if rank > max_results:
            break
        if not r.url or r.url in seen_urls:
            continue
        seen_urls.add(r.url)

        combined = f"{r.title} {r.snippet}".lower()
        refs.append(
            DesignRef(
                rank=rank,
                title=_clean_text(r.title),
                source=classify_source(r.url),
                url=r.url,
                thumbnail_url="",
                tags=_extract_tags(combined),
                color_palette=_extract_hex_colors(combined),
                spotted_components=_extract_spotted_components(combined),
                design_notes=_clean_text(r.snippet),
            )
        )
        rank += 1

    return refs


def _extract_tags(text: str) -> list[str]:
    """텍스트에서 디자인 관련 태그를 추출한다."""
    tag_keywords = [
        "minimal", "flat", "material", "glassmorphism", "neumorphism",
        "dark", "light", "colorful", "monochrome", "gradient",
        "mobile", "web", "desktop", "ios", "android",
        "ui", "ux", "icon", "illustration",
    ]
    return [kw for kw in tag_keywords if kw in text][:6]


def _extract_hex_colors(text: str) -> list[str]:
    """텍스트에서 hex 색상 코드를 추출한다."""
    return re.findall(r"#[0-9A-Fa-f]{6}", text)[:5]


def _extract_spotted_components(text: str) -> list[str]:
    """텍스트에서 발견된 UI 컴포넌트를 추출한다."""
    return [kw for kw in _COMPONENT_KEYWORDS if kw in text][:6]


def _extract_design_patterns(text: str) -> list[DesignPattern]:
    """텍스트 전체에서 디자인 패턴을 집계한다."""
    patterns: list[DesignPattern] = []
    for keywords, pattern_name, description in _PATTERN_KEYWORDS:
        count = sum(1 for kw in keywords if kw in text)
        if count > 0:
            frequency = "high" if count >= 3 else "medium" if count >= 2 else "low"
            patterns.append(
                DesignPattern(
                    pattern=pattern_name,
                    frequency=frequency,
                    description=description,
                )
            )
    # 빈도 높은 순으로 정렬
    order = {"high": 0, "medium": 1, "low": 2}
    patterns.sort(key=lambda p: order.get(p.frequency, 3))
    return patterns


def _extract_color_trends(
    text: str,
    results: list[SearchResult],
) -> dict[str, list[str]]:
    """텍스트와 결과에서 색상 트렌드를 추출한다."""
    color_trends: dict[str, list[str]] = {}

    # 각 결과에서 hex 추출
    all_hex: list[str] = re.findall(r"#[0-9A-Fa-f]{6}", text)

    # 색상 키워드로 팔레트 추론
    for color_name, palette in _COLOR_KEYWORDS.items():
        if color_name in text:
            color_trends[color_name] = palette

    # 발견된 hex 코드 추가
    if all_hex:
        color_trends["extracted_hex"] = list(set(all_hex))[:8]

    return color_trends


def _extract_typography(text: str) -> list[str]:
    """텍스트에서 타이포그래피 트렌드를 추출한다."""
    found: list[str] = []
    for kw in _TYPOGRAPHY_KEYWORDS:
        if kw.lower() in text:
            found.append(kw)
    # 일반적인 트렌드 추가
    if "sans-serif" not in found:
        found.append("sans-serif (일반적 모바일 UI 선택)")
    return found[:6]


def _extract_icon_styles(text: str) -> list[str]:
    """텍스트에서 아이콘 스타일을 추출한다."""
    found: list[str] = [kw for kw in _ICON_STYLE_KEYWORDS if kw.lower() in text]
    if not found:
        found = ["outline icon", "filled icon"]  # 기본값
    return found[:5]


def _extract_components(text: str) -> list[str]:
    """텍스트 전체에서 UI 컴포넌트 인벤토리를 구성한다."""
    return [kw for kw in _COMPONENT_KEYWORDS if kw in text]


def _build_designer_brief(
    query: str,
    style: str,
    references: list[DesignRef],
    patterns: list[DesignPattern],
    color_trends: dict[str, list[str]],
    components: list[str],
) -> DesignerBrief:
    """디자이너 브리프를 생성한다."""
    # 가장 많이 언급된 스타일 추론
    all_tags: list[str] = []
    for ref in references:
        all_tags.extend(ref.tags)

    style_count: dict[str, int] = {}
    for tag in all_tags:
        style_count[tag] = style_count.get(tag, 0) + 1

    recommended_style = style if style else (
        max(style_count, key=lambda k: style_count[k]) if style_count else "minimal"
    )

    # 핵심 컴포넌트 (패턴에서 + 컴포넌트 인벤토리)
    key_components = list({
        comp
        for ref in references
        for comp in ref.spotted_components
    })[:8]
    if not key_components:
        key_components = components[:6]

    # 컬러 추천
    color_suggestion = "neutral + accent 조합 권장"
    if color_trends:
        primary_color = next(iter(color_trends))
        if primary_color != "extracted_hex":
            colors = color_trends[primary_color]
            color_suggestion = f"{primary_color} 계열 ({', '.join(colors[:2])})"

    # 상위 5개 레퍼런스 URL
    reference_urls = [ref.url for ref in references[:5]]

    return DesignerBrief(
        recommended_style=recommended_style,
        key_components=key_components,
        color_suggestion=color_suggestion,
        reference_urls=reference_urls,
    )


def _clean_text(text: str) -> str:
    """HTML 엔티티와 과도한 공백을 정리한다."""
    if not text:
        return ""
    text = re.sub(r"&amp;", "&", text)
    text = re.sub(r"&lt;", "<", text)
    text = re.sub(r"&gt;", ">", text)
    text = re.sub(r"&quot;", '"', text)
    text = re.sub(r"&#39;", "'", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()
