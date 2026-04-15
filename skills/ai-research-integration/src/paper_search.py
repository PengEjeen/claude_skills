# Paper Search Implementation
# Semantic Scholar and arXiv API integration

import requests
from typing import List, Dict, Optional
from dataclasses import dataclass
from datetime import datetime
import time


@dataclass
class Paper:
    """Research paper metadata"""
    title: str
    authors: List[str]
    year: int
    venue: str
    url: str
    abstract: str
    citations: int
    arxiv_id: Optional[str] = None
    semantic_scholar_id: Optional[str] = None


class SemanticScholarAPI:
    """
    Semantic Scholar API client
    API Documentation: https://api.semanticscholar.org/

    Free tier: 100 requests/5 minutes (no API key required)
    """

    BASE_URL = "https://api.semanticscholar.org/graph/v1"

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key
        self.session = requests.Session()
        if api_key:
            self.session.headers['x-api-key'] = api_key

    def search_papers(
        self,
        query: str,
        year_range: Optional[tuple] = None,
        min_citations: int = 0,
        fields_of_study: Optional[List[str]] = None,
        limit: int = 10
    ) -> List[Paper]:
        """
        Search papers by query

        Args:
            query: Search query
            year_range: (start_year, end_year)
            min_citations: Minimum citation count
            fields_of_study: Filter by field (e.g., ["Computer Science", "AI"])
            limit: Max results

        Returns:
            List of Paper objects
        """
        url = f"{self.BASE_URL}/paper/search"

        params = {
            'query': query,
            'limit': limit,
            'fields': 'title,authors,year,venue,abstract,citationCount,externalIds,url'
        }

        if year_range:
            params['year'] = f"{year_range[0]}-{year_range[1]}"

        if min_citations > 0:
            params['minCitationCount'] = min_citations

        if fields_of_study:
            params['fieldsOfStudy'] = ','.join(fields_of_study)

        response = self.session.get(url, params=params)
        response.raise_for_status()

        data = response.json()

        papers = []
        for item in data.get('data', []):
            papers.append(Paper(
                title=item.get('title', ''),
                authors=[a.get('name', '') for a in item.get('authors', [])],
                year=item.get('year', 0),
                venue=item.get('venue', ''),
                url=item.get('url', ''),
                abstract=item.get('abstract', ''),
                citations=item.get('citationCount', 0),
                semantic_scholar_id=item.get('paperId'),
                arxiv_id=item.get('externalIds', {}).get('ArXiv')
            ))

        return papers

    def get_paper_details(self, paper_id: str) -> Paper:
        """Get detailed information for a specific paper"""
        url = f"{self.BASE_URL}/paper/{paper_id}"

        params = {
            'fields': 'title,authors,year,venue,abstract,citationCount,externalIds,url,influentialCitationCount'
        }

        response = self.session.get(url, params=params)
        response.raise_for_status()

        item = response.json()

        return Paper(
            title=item.get('title', ''),
            authors=[a.get('name', '') for a in item.get('authors', [])],
            year=item.get('year', 0),
            venue=item.get('venue', ''),
            url=item.get('url', ''),
            abstract=item.get('abstract', ''),
            citations=item.get('citationCount', 0),
            semantic_scholar_id=item.get('paperId'),
            arxiv_id=item.get('externalIds', {}).get('ArXiv')
        )

    def get_citations(self, paper_id: str, limit: int = 10) -> List[Paper]:
        """Get papers that cite this paper"""
        url = f"{self.BASE_URL}/paper/{paper_id}/citations"

        params = {
            'fields': 'title,authors,year,venue,citationCount',
            'limit': limit
        }

        response = self.session.get(url, params=params)
        response.raise_for_status()

        data = response.json()

        papers = []
        for item in data.get('data', []):
            citing_paper = item.get('citingPaper', {})
            papers.append(Paper(
                title=citing_paper.get('title', ''),
                authors=[a.get('name', '') for a in citing_paper.get('authors', [])],
                year=citing_paper.get('year', 0),
                venue=citing_paper.get('venue', ''),
                url=citing_paper.get('url', ''),
                abstract='',
                citations=citing_paper.get('citationCount', 0),
                semantic_scholar_id=citing_paper.get('paperId')
            ))

        return papers


class ArXivAPI:
    """
    arXiv API client
    API Documentation: https://arxiv.org/help/api/

    No rate limits documented, but be respectful
    """

    BASE_URL = "http://export.arxiv.org/api/query"

    def search_papers(
        self,
        query: str,
        category: Optional[str] = None,
        max_results: int = 10,
        sort_by: str = "relevance"
    ) -> List[Paper]:
        """
        Search arXiv papers

        Args:
            query: Search query
            category: arXiv category (e.g., "cs.AI", "cs.LG")
            max_results: Max results
            sort_by: "relevance" or "lastUpdatedDate"

        Returns:
            List of Paper objects
        """
        # Build search query
        search_query = query
        if category:
            search_query = f"cat:{category} AND ({query})"

        params = {
            'search_query': search_query,
            'max_results': max_results,
            'sortBy': sort_by,
            'sortOrder': 'descending'
        }

        response = requests.get(self.BASE_URL, params=params)
        response.raise_for_status()

        # Parse Atom XML
        import xml.etree.ElementTree as ET

        root = ET.fromstring(response.content)

        # Namespace
        ns = {
            'atom': 'http://www.w3.org/2005/Atom',
            'arxiv': 'http://arxiv.org/schemas/atom'
        }

        papers = []
        for entry in root.findall('atom:entry', ns):
            title = entry.find('atom:title', ns).text.strip()
            abstract = entry.find('atom:summary', ns).text.strip()

            authors = [
                author.find('atom:name', ns).text
                for author in entry.findall('atom:author', ns)
            ]

            published = entry.find('atom:published', ns).text
            year = int(published.split('-')[0])

            arxiv_id = entry.find('atom:id', ns).text.split('/')[-1]
            url = f"https://arxiv.org/abs/{arxiv_id}"

            # Category
            category = entry.find('arxiv:primary_category', ns).get('term')

            papers.append(Paper(
                title=title,
                authors=authors,
                year=year,
                venue=f"arXiv:{category}",
                url=url,
                abstract=abstract,
                citations=0,  # arXiv doesn't provide citation count
                arxiv_id=arxiv_id
            ))

        return papers


class PaperSearchEngine:
    """
    Combined search engine using both Semantic Scholar and arXiv
    """

    def __init__(self, semantic_scholar_api_key: Optional[str] = None):
        self.semantic_scholar = SemanticScholarAPI(semantic_scholar_api_key)
        self.arxiv = ArXivAPI()

    def search(
        self,
        query: str,
        year_range: Optional[tuple] = None,
        min_citations: int = 0,
        sources: List[str] = ["semantic_scholar", "arxiv"],
        limit_per_source: int = 10
    ) -> List[Paper]:
        """
        Search papers across multiple sources

        Args:
            query: Search query
            year_range: (start_year, end_year)
            min_citations: Minimum citations (Semantic Scholar only)
            sources: List of sources to search
            limit_per_source: Max results per source

        Returns:
            Combined list of papers, sorted by citations
        """
        all_papers = []

        # Search Semantic Scholar
        if "semantic_scholar" in sources:
            try:
                papers = self.semantic_scholar.search_papers(
                    query=query,
                    year_range=year_range,
                    min_citations=min_citations,
                    limit=limit_per_source
                )
                all_papers.extend(papers)
            except Exception as e:
                print(f"Semantic Scholar search failed: {e}")

        # Search arXiv
        if "arxiv" in sources:
            try:
                # Extract arXiv category from query if present
                category = None
                if "cs.AI" in query or "AI" in query:
                    category = "cs.AI"
                elif "cs.LG" in query or "machine learning" in query.lower():
                    category = "cs.LG"
                elif "cs.CL" in query or "NLP" in query:
                    category = "cs.CL"

                papers = self.arxiv.search_papers(
                    query=query,
                    category=category,
                    max_results=limit_per_source
                )
                all_papers.extend(papers)
            except Exception as e:
                print(f"arXiv search failed: {e}")

        # Remove duplicates (same arXiv ID)
        seen_arxiv_ids = set()
        unique_papers = []

        for paper in all_papers:
            if paper.arxiv_id:
                if paper.arxiv_id in seen_arxiv_ids:
                    continue
                seen_arxiv_ids.add(paper.arxiv_id)
            unique_papers.append(paper)

        # Sort by citations (desc)
        unique_papers.sort(key=lambda p: p.citations, reverse=True)

        return unique_papers

    def evaluate_paper(self, paper: Paper) -> Dict[str, float]:
        """
        Evaluate paper using 5-criteria framework

        Returns scores (1-5) for:
        - Relevance
        - Novelty
        - Reproducibility
        - Applicability
        - Maturity
        """
        # This is a simplified heuristic-based evaluation
        # In production, use LLM to evaluate based on abstract

        scores = {}

        # Novelty: based on publication year
        current_year = datetime.now().year
        years_old = current_year - paper.year
        if years_old <= 1:
            scores['novelty'] = 5
        elif years_old <= 2:
            scores['novelty'] = 4
        elif years_old <= 3:
            scores['novelty'] = 3
        else:
            scores['novelty'] = 2

        # Reproducibility: has arXiv ID = likely has code
        scores['reproducibility'] = 4 if paper.arxiv_id else 3

        # Maturity: based on citations
        if paper.citations >= 100:
            scores['maturity'] = 5
        elif paper.citations >= 50:
            scores['maturity'] = 4
        elif paper.citations >= 10:
            scores['maturity'] = 3
        else:
            scores['maturity'] = 2

        # Relevance and Applicability: needs LLM evaluation
        scores['relevance'] = 3  # Placeholder
        scores['applicability'] = 3  # Placeholder

        return scores

    def calculate_priority_score(self, scores: Dict[str, float]) -> float:
        """
        Calculate weighted priority score

        Weights:
        - Relevance: 25%
        - Novelty: 15%
        - Reproducibility: 20%
        - Applicability: 25%
        - Maturity: 15%
        """
        weights = {
            'relevance': 0.25,
            'novelty': 0.15,
            'reproducibility': 0.20,
            'applicability': 0.25,
            'maturity': 0.15
        }

        total = sum(scores[k] * weights[k] for k in weights)
        return total


# Example usage
if __name__ == "__main__":
    # Initialize search engine
    engine = PaperSearchEngine()

    # Search for RAG papers
    papers = engine.search(
        query="retrieval augmented generation improvements",
        year_range=(2025, 2026),
        min_citations=10,
        limit_per_source=5
    )

    print(f"Found {len(papers)} papers\n")

    for i, paper in enumerate(papers, 1):
        print(f"{i}. {paper.title}")
        print(f"   Authors: {', '.join(paper.authors[:3])}{'...' if len(paper.authors) > 3 else ''}")
        print(f"   Venue: {paper.venue} ({paper.year})")
        print(f"   Citations: {paper.citations}")
        print(f"   URL: {paper.url}")

        # Evaluate
        scores = engine.evaluate_paper(paper)
        priority = engine.calculate_priority_score(scores)

        print(f"   Evaluation: {priority:.2f}/5.0")
        print(f"   - Novelty: {scores['novelty']}/5")
        print(f"   - Reproducibility: {scores['reproducibility']}/5")
        print(f"   - Maturity: {scores['maturity']}/5")
        print()
