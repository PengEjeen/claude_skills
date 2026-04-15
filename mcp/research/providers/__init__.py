"""
mcp.research.providers 패키지.
get_provider() 팩토리 함수로 설정에 맞는 provider를 반환한다.
반환값은 항상 CachedProvider로 감싸져 TTL 캐시가 적용된다.
"""
from .base import SearchProvider, SearchResult
from .brave import BraveProvider
from .cached import CachedProvider
from .ddg import DuckDuckGoProvider
from .serper import SerperProvider
from ..config import config


def get_provider() -> SearchProvider:
    """설정에 따라 최적의 provider 인스턴스를 반환한다 (캐시 적용)."""
    provider_name = config.effective_provider()
    if provider_name == "brave" and config.brave_api_key:
        inner = BraveProvider(config.brave_api_key, config)
    elif provider_name == "serper" and config.serper_api_key:
        inner = SerperProvider(config.serper_api_key, config)
    else:
        inner = DuckDuckGoProvider(config)
    return CachedProvider(inner)


__all__ = [
    "SearchProvider",
    "SearchResult",
    "BraveProvider",
    "SerperProvider",
    "DuckDuckGoProvider",
    "CachedProvider",
    "get_provider",
]
