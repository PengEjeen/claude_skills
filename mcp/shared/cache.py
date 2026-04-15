"""TTL-based async-safe in-memory cache."""

import asyncio
import time
from typing import Any, Optional


class TTLCache:
    """Simple TTL cache with async lock support."""

    def __init__(self, ttl: int = 300, maxsize: int = 256):
        self._ttl = ttl
        self._maxsize = maxsize
        self._store: dict[str, tuple[Any, float]] = {}
        self._lock = asyncio.Lock()

    async def get(self, key: str) -> Optional[Any]:
        async with self._lock:
            entry = self._store.get(key)
            if entry is None:
                return None
            value, expires_at = entry
            if time.monotonic() > expires_at:
                del self._store[key]
                return None
            return value

    async def set(self, key: str, value: Any) -> None:
        async with self._lock:
            if len(self._store) >= self._maxsize:
                self._evict()
            self._store[key] = (value, time.monotonic() + self._ttl)

    async def delete(self, key: str) -> None:
        async with self._lock:
            self._store.pop(key, None)

    async def clear(self) -> None:
        async with self._lock:
            self._store.clear()

    def _evict(self) -> None:
        """Remove expired entries; if still over capacity, evict oldest."""
        now = time.monotonic()
        expired = [k for k, (_, exp) in self._store.items() if now > exp]
        for k in expired:
            del self._store[k]
        if len(self._store) >= self._maxsize:
            oldest = sorted(self._store, key=lambda k: self._store[k][1])
            for k in oldest[: len(self._store) - self._maxsize + 1]:
                del self._store[k]


# Shared singleton caches
search_cache = TTLCache(ttl=300, maxsize=256)   # 5 min for search results
page_cache = TTLCache(ttl=600, maxsize=128)     # 10 min for fetched pages
