"""
Pydantic v2 스키마 정의.
세 가지 MCP 도구의 입출력 구조를 정의한다:
  - AppResearchResult: 유사 앱 리서치 결과 (PM용)
  - DesignRefsResult: 디자인 레퍼런스 리서치 결과 (디자이너용)
  - DigestResult: URL 다이제스트 결과
"""
from __future__ import annotations

from typing import Any

from pydantic import BaseModel, Field


# ---------------------------------------------------------------------------
# App Research 스키마 (PM용)
# ---------------------------------------------------------------------------


class AppInfo(BaseModel):
    """개별 앱 정보."""

    rank: int
    name: str
    tagline: str = ""
    url: str = ""
    description: str
    key_features: list[str] = Field(default_factory=list)
    target_users: str = ""
    pricing: dict[str, str] = Field(default_factory=dict)  # model, free_tier, paid_from
    platforms: list[str] = Field(default_factory=list)
    ux_highlights: list[str] = Field(default_factory=list)
    strengths: list[str] = Field(default_factory=list)
    weaknesses: list[str] = Field(default_factory=list)
    source_url: str


class MarketInsights(BaseModel):
    """시장 전체 인사이트."""

    common_features: list[str] = Field(default_factory=list)
    pricing_patterns: list[str] = Field(default_factory=list)
    ux_trends: list[str] = Field(default_factory=list)
    differentiation_opportunities: list[str] = Field(default_factory=list)


class PMBrief(BaseModel):
    """PM을 위한 시장 요약 브리프."""

    market_summary: str
    recommended_features: list[str] = Field(default_factory=list)
    positioning_suggestion: str
    risks: list[str] = Field(default_factory=list)


class AppResearchResult(BaseModel):
    """research_similar_apps 도구의 전체 응답 구조."""

    meta: dict[str, Any] = Field(default_factory=dict)
    apps: list[AppInfo] = Field(default_factory=list)
    market_insights: MarketInsights
    pm_brief: PMBrief


# ---------------------------------------------------------------------------
# Design Refs 스키마 (디자이너용)
# ---------------------------------------------------------------------------


class DesignRef(BaseModel):
    """개별 디자인 레퍼런스."""

    rank: int
    title: str
    source: str  # "dribbble" | "behance" | "mobbin" | "web" 등
    url: str
    thumbnail_url: str = ""
    tags: list[str] = Field(default_factory=list)
    color_palette: list[str] = Field(default_factory=list)
    spotted_components: list[str] = Field(default_factory=list)
    design_notes: str = ""


class DesignPattern(BaseModel):
    """발견된 디자인 패턴."""

    pattern: str
    frequency: str  # "high" | "medium" | "low"
    description: str


class DesignerBrief(BaseModel):
    """디자이너를 위한 레퍼런스 요약 브리프."""

    recommended_style: str
    key_components: list[str] = Field(default_factory=list)
    color_suggestion: str
    reference_urls: list[str] = Field(default_factory=list)


class DesignRefsResult(BaseModel):
    """research_design_refs 도구의 전체 응답 구조."""

    meta: dict[str, Any] = Field(default_factory=dict)
    references: list[DesignRef] = Field(default_factory=list)
    design_patterns: list[DesignPattern] = Field(default_factory=list)
    color_trends: dict[str, list[str]] = Field(default_factory=dict)
    typography_trends: list[str] = Field(default_factory=list)
    icon_styles: list[str] = Field(default_factory=list)
    component_inventory: list[str] = Field(default_factory=list)
    designer_brief: DesignerBrief


# ---------------------------------------------------------------------------
# Digest 스키마 (URL 다이제스트)
# ---------------------------------------------------------------------------


class DigestResult(BaseModel):
    """open_reference_digest 도구의 전체 응답 구조."""

    meta: dict[str, Any] = Field(default_factory=dict)
    summary: str
    key_points: list[str] = Field(default_factory=list)
    extracted: dict[str, Any] = Field(default_factory=dict)  # type별 다른 필드
    relevance_for_pm: str
    relevance_for_designer: str
