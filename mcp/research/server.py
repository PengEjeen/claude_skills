"""
mcp.research — 목적형 리서치 MCP 서버

실행:
  fastmcp run mcp/research/server.py          ← 권장 (Claude Code MCP 등록)
  python -m mcp.research.server               ← 모듈 실행
"""
import sys
from pathlib import Path

from fastmcp import FastMCP

# 스크립트 직접 실행 시 패키지 루트를 sys.path에 추가
if __package__ in (None, ""):
    _pkg_root = str(Path(__file__).resolve().parent.parent.parent)
    if _pkg_root not in sys.path:
        sys.path.insert(0, _pkg_root)
    from mcp.research.tools.app_research import research_similar_apps as _research_apps
    from mcp.research.tools.design_refs import research_design_refs as _research_design
    from mcp.research.tools.digest import open_reference_digest as _digest
    from mcp.research.tools.pdf_reader import read_pdf as _read_pdf
else:
    from .tools.app_research import research_similar_apps as _research_apps
    from .tools.design_refs import research_design_refs as _research_design
    from .tools.digest import open_reference_digest as _digest
    from .tools.pdf_reader import read_pdf as _read_pdf

mcp = FastMCP(
    name="research-mcp",
    instructions=(
        "목적형 리서치 MCP 서버.\n"
        "- research_similar_apps: PM이 초안 작성 전 유사 앱 시장을 리서치\n"
        "- research_design_refs: 디자이너가 UI/아이콘 디자인 레퍼런스를 수집\n"
        "- open_reference_digest: URL 내용을 구조화 JSON으로 다이제스트\n"
        "- read_pdf: PDF 파일을 Markdown/JSON으로 변환하여 텍스트를 추출\n"
    ),
)


@mcp.tool(description="PM 전용: 앱 아이디어와 유사한 기존 앱들을 리서치하여 시장 분석, 기능 비교, 차별화 기회를 구조화 JSON으로 반환.")
async def research_similar_apps(app_idea: str, category: str = "", max_results: int = 5) -> dict:
    return await _research_apps(app_idea, category, min(max_results, 10))


@mcp.tool(description="디자이너 전용: UI/UX 디자인 및 아이콘 레퍼런스를 리서치. Dribbble, Behance 등에서 스타일·컴포넌트·컬러 패턴을 수집.")
async def research_design_refs(query: str, style: str = "", platform: str = "mobile", max_results: int = 8) -> dict:
    return await _research_design(query, style, platform, min(max_results, 15))


@mcp.tool(description="URL을 열어 내용을 구조화 다이제스트로 반환. 앱/디자인/아티클 타입을 자동 감지.")
async def open_reference_digest(url: str, digest_type: str = "auto") -> dict:
    return await _digest(url, digest_type)


@mcp.tool(
    description=(
        "PDF 파일을 Markdown 또는 JSON으로 변환하여 텍스트를 추출. "
        "법률문서·감정서·보고서 등 로컬 PDF 분석에 사용. "
        "opendataloader_pdf(JVM 기반) 사용."
    )
)
def read_pdf(
    pdf_path: str,
    pages: str | None = None,
    format: str = "markdown",
    image_output: str = "off",
) -> dict:
    """PDF 파일을 변환하여 텍스트 콘텐츠를 반환한다.

    Args:
        pdf_path: PDF 파일 경로 (절대 또는 상대).
        pages: 페이지 범위 문자열 (예: "1,3,5-7"). None이면 전체.
        format: 출력 포맷 — "markdown" 또는 "json" (기본: markdown).
        image_output: 이미지 처리 방식 — "off" | "embedded" | "external".
    """
    result = _read_pdf(pdf_path, pages=pages, format=format, image_output=image_output)
    if result.get("success"):
        result["pages_requested"] = pages
    return result


if __name__ == "__main__":
    mcp.run()
