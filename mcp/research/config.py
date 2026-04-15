"""환경변수 기반 설정 모듈."""
import os
from dataclasses import dataclass, field


@dataclass
class ResearchConfig:
    # Provider 선택 (brave | serper | ddg)
    search_provider: str = field(default_factory=lambda: os.getenv("SEARCH_PROVIDER", "ddg"))
    brave_api_key: str = field(default_factory=lambda: os.getenv("BRAVE_API_KEY", ""))
    serper_api_key: str = field(default_factory=lambda: os.getenv("SERPER_API_KEY", ""))

    # 동작 설정
    max_search_results: int = field(default_factory=lambda: int(os.getenv("MAX_SEARCH_RESULTS", "10")))
    request_timeout: float = field(default_factory=lambda: float(os.getenv("REQUEST_TIMEOUT", "15.0")))
    cache_ttl: int = field(default_factory=lambda: int(os.getenv("CACHE_TTL", "300")))

    # User-Agent
    user_agent: str = "Mozilla/5.0 (compatible; ResearchMCP/1.0)"

    def effective_provider(self) -> str:
        """API 키 존재 여부로 실제 provider를 자동 결정."""
        if self.search_provider != "ddg":
            return self.search_provider
        if self.brave_api_key:
            return "brave"
        if self.serper_api_key:
            return "serper"
        return "ddg"


config = ResearchConfig()
