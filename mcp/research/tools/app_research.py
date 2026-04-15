"""
PM용 유사 앱 시장 리서치 도구.
app_idea와 category를 받아 경쟁 앱들을 병렬 검색하고,
AppResearchResult 구조로 집계하여 반환한다.
"""
from __future__ import annotations

import asyncio
import logging
import re
from datetime import datetime, timezone
from urllib.parse import urlparse

from ..models.schemas import AppInfo, AppResearchResult, MarketInsights, PMBrief
from ..providers import SearchResult, get_provider

logger = logging.getLogger(__name__)

# 가격 키워드 패턴
_FREE_KEYWORDS = {"free", "무료", "open source", "오픈소스"}
_PAID_KEYWORDS = {"premium", "pro", "paid", "subscription", "구독", "유료", "enterprise"}
_FREEMIUM_KEYWORDS = {"freemium", "free plan", "free tier", "basic free", "무료 플랜"}

# 플랫폼 키워드
_PLATFORM_MAP = {
    "web": {"web", "browser", "online", "webapp", "웹"},
    "ios": {"ios", "iphone", "ipad", "app store", "앱스토어"},
    "android": {"android", "google play", "플레이스토어"},
    "desktop": {"desktop", "windows", "macos", "mac", "linux", "pc"},
    "mobile": {"mobile", "모바일"},
}

# 공통 기능 키워드 (시장 분석에 활용)
_FEATURE_KEYWORDS = [
    "collaboration", "sharing", "sync", "offline", "notification",
    "reminder", "calendar", "analytics", "dashboard", "export",
    "import", "integration", "api", "webhook", "ai", "automation",
    "template", "tag", "filter", "search", "dark mode",
    "협업", "동기화", "알림", "분석", "대시보드", "내보내기", "가져오기",
]

# UX 트렌드 키워드
_UX_KEYWORDS = [
    "simple", "clean", "intuitive", "minimal", "drag and drop",
    "keyboard shortcut", "gesture", "swipe", "voice", "widget",
    "빠른", "직관적", "미니멀", "간편",
]


async def research_similar_apps(
    app_idea: str,
    category: str = "",
    max_results: int = 5,
) -> dict:
    """
    유사 앱 시장을 리서치하여 AppResearchResult 구조의 dict를 반환한다.

    Args:
        app_idea: 리서치할 앱 아이디어 (예: "할 일 관리 앱", "recipe sharing app")
        category: 앱 카테고리 (예: "productivity", "social") — 생략 가능
        max_results: 반환할 최대 앱 수 (최대 10)

    Returns:
        AppResearchResult.model_dump() 형태의 dict
    """
    provider = get_provider()
    cat = category.strip()
    idea = app_idea.strip()

    # 병렬 검색 쿼리 구성
    queries = [
        f'"{idea}" alternatives {cat} app'.strip(),
        f'"{idea}" {cat} app comparison review 2024'.strip(),
        f"best {cat} apps product hunt".strip() if cat else f"best apps similar to {idea} product hunt",
        f'"{idea}" competitor analysis'.strip(),
    ]

    # 모든 쿼리를 병렬 실행
    search_tasks = [provider.search(q, num=10) for q in queries]
    all_results_nested: list[list[SearchResult]] = await asyncio.gather(
        *search_tasks, return_exceptions=True
    )

    # 예외가 반환된 경우 빈 리스트로 대체
    all_results: list[SearchResult] = []
    for batch in all_results_nested:
        if isinstance(batch, Exception):
            logger.warning("Search query failed: %s", batch)
            continue
        all_results.extend(batch)

    # URL 기준 중복 제거
    seen_urls: set[str] = set()
    unique_results: list[SearchResult] = []
    for r in all_results:
        if r.url and r.url not in seen_urls:
            seen_urls.add(r.url)
            unique_results.append(r)

    # 앱 정보 추출 및 구조화
    apps = _build_app_list(unique_results, idea, max_results)
    market_insights = _build_market_insights(apps, unique_results)
    pm_brief = _build_pm_brief(idea, cat, apps, market_insights)

    result = AppResearchResult(
        meta={
            "fetched_at": datetime.now(timezone.utc).isoformat(),
            "provider": provider.name,
            "query": idea,
            "category": cat,
            "total_raw_results": len(unique_results),
        },
        apps=apps,
        market_insights=market_insights,
        pm_brief=pm_brief,
    )
    return result.model_dump()


# ---------------------------------------------------------------------------
# Private helpers
# ---------------------------------------------------------------------------


def _build_app_list(
    results: list[SearchResult],
    idea: str,
    max_results: int,
) -> list[AppInfo]:
    """검색 결과에서 앱 정보를 추출하고 중복 앱명을 제거한다."""
    apps: list[AppInfo] = []
    seen_names: set[str] = set()
    rank = 1

    for r in results:
        if rank > max_results:
            break

        name = _extract_app_name(r)
        name_key = name.lower().strip()

        # 동일 앱 중복 제거
        if name_key in seen_names or not name_key:
            continue
        seen_names.add(name_key)

        combined_text = f"{r.title} {r.snippet}".lower()
        pricing = _extract_pricing(combined_text)
        platforms = _extract_platforms(combined_text)
        features = _extract_features(combined_text)
        ux_highlights = _extract_ux_highlights(combined_text)

        apps.append(
            AppInfo(
                rank=rank,
                name=name,
                tagline=_extract_tagline(r),
                url=_extract_app_url(r.url),
                description=_clean_text(r.snippet) or f"{name} — {idea} 관련 앱",
                key_features=features,
                pricing=pricing,
                platforms=platforms,
                ux_highlights=ux_highlights,
                strengths=_infer_strengths(combined_text, features),
                weaknesses=[],
                source_url=r.url,
            )
        )
        rank += 1

    return apps


def _extract_app_name(result: SearchResult) -> str:
    """검색 결과 title 또는 URL 도메인에서 앱 이름을 추출한다."""
    title = result.title.strip()
    if " - " in title:
        return title.split(" - ")[0].strip()
    if " | " in title:
        return title.split(" | ")[0].strip()
    if " : " in title:
        return title.split(" : ")[0].strip()
    if title:
        # 너무 긴 제목은 첫 5단어만
        words = title.split()
        return " ".join(words[:5]) if len(words) > 5 else title

    # title이 없으면 도메인 사용
    try:
        domain = urlparse(result.url).netloc
        return domain.replace("www.", "").split(".")[0].capitalize()
    except Exception:
        return "Unknown App"


def _extract_tagline(result: SearchResult) -> str:
    """title에서 tagline 부분을 추출한다 (구분자 이후 텍스트)."""
    title = result.title.strip()
    for sep in [" - ", " | ", " : "]:
        if sep in title:
            parts = title.split(sep, 1)
            if len(parts) > 1:
                return parts[1].strip()
    return ""


def _extract_app_url(source_url: str) -> str:
    """소스 URL에서 앱의 기본 URL(scheme + netloc)을 추출한다."""
    try:
        parsed = urlparse(source_url)
        return f"{parsed.scheme}://{parsed.netloc}"
    except Exception:
        return source_url


def _extract_pricing(text: str) -> dict[str, str]:
    """텍스트에서 가격 모델을 추론한다."""
    pricing: dict[str, str] = {}
    text_lower = text.lower()

    is_freemium = any(kw in text_lower for kw in _FREEMIUM_KEYWORDS)
    is_free = any(kw in text_lower for kw in _FREE_KEYWORDS)
    is_paid = any(kw in text_lower for kw in _PAID_KEYWORDS)

    if is_freemium:
        pricing["model"] = "freemium"
        pricing["free_tier"] = "available"
    elif is_free and not is_paid:
        pricing["model"] = "free"
    elif is_paid and not is_free:
        pricing["model"] = "paid"
    elif is_free and is_paid:
        pricing["model"] = "freemium"
        pricing["free_tier"] = "available"
    else:
        pricing["model"] = "unknown"

    # 가격 금액 추출 ($X/month 패턴)
    price_match = re.search(r"\$(\d+(?:\.\d+)?)\s*(?:/\s*month|/mo|/yr|/year)?", text_lower)
    if price_match:
        pricing["paid_from"] = f"${price_match.group(1)}"

    return pricing


def _extract_platforms(text: str) -> list[str]:
    """텍스트에서 지원 플랫폼을 추론한다."""
    found: list[str] = []
    text_lower = text.lower()
    for platform, keywords in _PLATFORM_MAP.items():
        if any(kw in text_lower for kw in keywords):
            found.append(platform)
    return found if found else ["web"]


def _extract_features(text: str) -> list[str]:
    """텍스트에서 기능 키워드를 추출한다."""
    found: list[str] = []
    text_lower = text.lower()
    for kw in _FEATURE_KEYWORDS:
        if kw in text_lower and kw not in found:
            found.append(kw)
    return found[:8]  # 최대 8개


def _extract_ux_highlights(text: str) -> list[str]:
    """텍스트에서 UX 특징 키워드를 추출한다."""
    found: list[str] = []
    text_lower = text.lower()
    for kw in _UX_KEYWORDS:
        if kw in text_lower and kw not in found:
            found.append(kw)
    return found[:5]


def _infer_strengths(text: str, features: list[str]) -> list[str]:
    """기능 목록과 텍스트를 기반으로 강점을 추론한다."""
    strengths: list[str] = []
    text_lower = text.lower()

    if "ai" in features or "ai" in text_lower:
        strengths.append("AI 기반 기능")
    if "collaboration" in features or "sharing" in features:
        strengths.append("협업 기능 강화")
    if "offline" in features:
        strengths.append("오프라인 지원")
    if "integration" in features or "api" in features:
        strengths.append("다양한 연동 지원")
    if len(features) >= 5:
        strengths.append("풍부한 기능 세트")
    if "simple" in text_lower or "minimal" in text_lower:
        strengths.append("단순하고 직관적인 UX")

    return strengths[:4]


def _build_market_insights(
    apps: list[AppInfo],
    raw_results: list[SearchResult],
) -> MarketInsights:
    """앱 목록에서 시장 인사이트를 집계한다."""
    # 공통 기능 집계
    feature_count: dict[str, int] = {}
    for app in apps:
        for f in app.key_features:
            feature_count[f] = feature_count.get(f, 0) + 1
    common_features = [
        f for f, cnt in sorted(feature_count.items(), key=lambda x: -x[1]) if cnt >= 2
    ][:6]
    if not common_features and apps:
        # 2개 이상 없으면 가장 많이 나온 기능 상위 3개
        common_features = [
            f for f, _ in sorted(feature_count.items(), key=lambda x: -x[1])
        ][:3]

    # 가격 패턴 집계
    pricing_models: dict[str, int] = {}
    for app in apps:
        model = app.pricing.get("model", "unknown")
        pricing_models[model] = pricing_models.get(model, 0) + 1
    pricing_patterns = [
        f"{model}: {cnt}개 앱"
        for model, cnt in sorted(pricing_models.items(), key=lambda x: -x[1])
    ]

    # UX 트렌드 집계
    ux_count: dict[str, int] = {}
    for app in apps:
        for ux in app.ux_highlights:
            ux_count[ux] = ux_count.get(ux, 0) + 1
    ux_trends = [
        kw for kw, _ in sorted(ux_count.items(), key=lambda x: -x[1])
    ][:5]

    # 차별화 기회
    diff_opportunities = _find_differentiation_opportunities(common_features, ux_trends, apps)

    return MarketInsights(
        common_features=common_features,
        pricing_patterns=pricing_patterns,
        ux_trends=ux_trends,
        differentiation_opportunities=diff_opportunities,
    )


def _find_differentiation_opportunities(
    common_features: list[str],
    ux_trends: list[str],
    apps: list[AppInfo],
) -> list[str]:
    """공통 기능과 트렌드를 분석하여 차별화 기회를 제안한다."""
    opportunities: list[str] = []
    all_features_set = set(common_features)

    # 일반적으로 부재한 기능 제안
    if "ai" not in all_features_set:
        opportunities.append("AI 기반 자동화 및 추천 기능 — 경쟁 앱 대부분 미지원")
    if "offline" not in all_features_set:
        opportunities.append("완전한 오프라인 지원 — 차별화 포인트 가능")
    if "collaboration" not in all_features_set:
        opportunities.append("실시간 협업 기능 추가로 팀 사용자 공략")
    if "integration" not in all_features_set:
        opportunities.append("타 서비스 연동(Zapier, Slack, Google 등) 강화")

    # 가격 차별화
    price_models = {app.pricing.get("model", "unknown") for app in apps}
    if "free" not in price_models and "freemium" not in price_models:
        opportunities.append("무료 플랜 제공으로 진입 장벽 낮추기")

    return opportunities[:5]


def _build_pm_brief(
    idea: str,
    category: str,
    apps: list[AppInfo],
    insights: MarketInsights,
) -> PMBrief:
    """PM을 위한 시장 요약 브리프를 생성한다."""
    cat_str = f"'{category}' 카테고리의 " if category else ""
    app_count = len(apps)
    common = ", ".join(insights.common_features[:3]) if insights.common_features else "다양한 기능"
    pricing_summary = insights.pricing_patterns[0] if insights.pricing_patterns else "가격 모델 다양"

    market_summary = (
        f"'{idea}'와 유사한 {cat_str}앱 {app_count}개를 분석했습니다. "
        f"대부분의 앱이 {common} 등을 공통으로 제공하며, {pricing_summary}입니다. "
        f"UX 측면에서는 {'단순하고 직관적인 인터페이스를 지향하는' if 'simple' in insights.ux_trends or 'minimal' in insights.ux_trends else '다양한'} 경향이 관찰됩니다. "
        f"차별화 기회는 {len(insights.differentiation_opportunities)}가지 영역에서 발굴되었습니다."
    )

    recommended_features = list(insights.common_features[:5]) + [
        opp.split(" — ")[0] for opp in insights.differentiation_opportunities[:2]
    ]

    positioning_suggestion = (
        f"{idea}를 구현할 때, 기존 앱들이 공통으로 제공하는 {common} 기반 위에 "
        f"{insights.differentiation_opportunities[0].split(' — ')[0] if insights.differentiation_opportunities else 'AI 기능'} 을 더해 "
        "차별화된 포지셔닝을 추구하는 것을 권장합니다."
    )

    risks = [
        "시장 포화: 유사 앱이 다수 존재하여 사용자 획득 비용이 높을 수 있음",
        "네트워크 효과: 기존 앱의 사용자 기반이 강력하여 전환 어려울 수 있음",
        "기능 패리티: MVP 단계에서 경쟁 앱과 기능 격차 발생 가능",
    ]
    if any("freemium" in p or "free" in p for p in insights.pricing_patterns):
        risks.append("무료 경쟁: 주요 경쟁 앱이 무료 플랜 제공 중 — 수익 모델 설계 신중히")

    return PMBrief(
        market_summary=market_summary,
        recommended_features=recommended_features,
        positioning_suggestion=positioning_suggestion,
        risks=risks,
    )


def _clean_text(text: str) -> str:
    """HTML 엔티티와 특수문자를 정리한다."""
    if not text:
        return ""
    text = re.sub(r"&amp;", "&", text)
    text = re.sub(r"&lt;", "<", text)
    text = re.sub(r"&gt;", ">", text)
    text = re.sub(r"&quot;", '"', text)
    text = re.sub(r"&#39;", "'", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()
