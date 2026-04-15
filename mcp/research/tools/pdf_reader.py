"""
PDF 리더 도구.
opendataloader_pdf를 사용해 PDF 파일을 Markdown/JSON으로 변환하고 텍스트를 추출한다.
"""
from __future__ import annotations

import logging
import os
import tempfile
from pathlib import Path

logger = logging.getLogger(__name__)

# JVM headless 모드 — opendataloader_pdf 내부 JVM이 AWT 없이 동작하도록 설정
os.environ.setdefault("JAVA_TOOL_OPTIONS", "-Djava.awt.headless=true")


def read_pdf(
    pdf_path: str,
    pages: str | None = None,
    format: str = "markdown",
    image_output: str = "off",
) -> dict:
    """PDF 파일을 변환하여 텍스트 콘텐츠를 반환한다.

    Args:
        pdf_path: PDF 파일 경로 (절대 또는 상대).
        pages: 페이지 범위 (예: "1,3,5-7"). None이면 전체.
        format: 출력 포맷 — "markdown" 또는 "json" (기본: markdown).
        image_output: 이미지 처리 방식 — "off" | "embedded" | "external".
    """
    path = Path(pdf_path).resolve()
    if not path.exists():
        return _error(f"파일을 찾을 수 없습니다: {pdf_path}")
    if path.suffix.lower() != ".pdf":
        return _error(f"PDF 파일이 아닙니다: {pdf_path}")

    try:
        import opendataloader_pdf  # type: ignore
    except ImportError:
        return _error(
            "opendataloader_pdf 패키지가 설치되지 않았습니다. "
            "`pip install opendataloader_pdf` 를 실행하세요."
        )

    with tempfile.TemporaryDirectory() as tmp_dir:
        try:
            opendataloader_pdf.convert(
                input_path=[str(path)],
                output_dir=tmp_dir,
                format=format,
                pages=pages,
                image_output=image_output,
                quiet=True,
            )
        except Exception as exc:
            return _error(f"PDF 변환 실패: {exc}")

        return _collect_output(tmp_dir, path.stem, format)


def _collect_output(output_dir: str, stem: str, format: str) -> dict:
    """변환된 출력 파일을 읽어 dict로 반환한다."""
    out_path = Path(output_dir)
    ext = "md" if format == "markdown" else "json"

    # opendataloader_pdf 출력 파일 탐색 (stem 일치 또는 단일 파일)
    candidates = list(out_path.rglob(f"*.{ext}"))
    if not candidates:
        # 다른 포맷 파일이 있는지 확인
        all_files = list(out_path.rglob("*"))
        return {
            "success": False,
            "error": "변환 결과 파일을 찾을 수 없습니다.",
            "debug_files": [str(f) for f in all_files],
        }

    results: list[dict] = []
    for fp in candidates:
        try:
            content = fp.read_text(encoding="utf-8", errors="replace")
            results.append({"file": fp.name, "content": content})
        except Exception as exc:
            results.append({"file": fp.name, "error": str(exc)})

    primary = results[0]
    return {
        "success": True,
        "source": stem,
        "format": format,
        "content": primary.get("content", ""),
        "word_count": len(primary.get("content", "").split()),
        "pages_requested": None,  # 호출 시 채워짐
        "all_outputs": results if len(results) > 1 else None,
    }


def _error(msg: str) -> dict:
    return {"success": False, "error": msg}
