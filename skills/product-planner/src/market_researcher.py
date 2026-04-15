#!/usr/bin/env python3
# Market Research Automation for Product Planning
# 20-year PM's expertise in automated market analysis

import requests
from typing import List, Dict, Optional, Tuple, Any
from dataclasses import dataclass
import json
from datetime import datetime
import re


@dataclass
class MarketData:
    """Market research data"""
    domain: str
    tam: float  # Total Addressable Market (USD)
    sam: float  # Serviceable Addressable Market
    som: float  # Serviceable Obtainable Market
    cagr: float  # Compound Annual Growth Rate (%)
    trends: List[str]
    competitors: List[Dict[str, Any]]
    target_segments: List[str]


class DomainClassifier:
    """
    Classify user input into industry domains

    Supports 15+ major domains with sub-categories
    """

    DOMAIN_KEYWORDS = {
        'EdTech': [
            'education', 'learning', 'teaching', 'course', 'tutor',
            'school', 'university', 'mooc', 'e-learning', '교육', '학습'
        ],
        'FinTech': [
            'finance', 'payment', 'banking', 'insurance', 'lending',
            'wallet', 'crypto', 'investing', '금융', '결제', '페이'
        ],
        'HealthTech': [
            'health', 'medical', 'hospital', 'doctor', 'patient',
            'telemedicine', 'wellness', '의료', '건강', '헬스케어'
        ],
        'FoodTech': [
            'food', 'restaurant', 'delivery', 'recipe', 'meal',
            'grocery', 'dining', '음식', '배달', '요리'
        ],
        'PropTech': [
            'real estate', 'property', 'housing', 'rent', 'lease',
            'apartment', 'building', '부동산', '집', '아파트'
        ],
        'HRTech': [
            'hr', 'recruitment', 'hiring', 'payroll', 'talent',
            'employee', 'workforce', '채용', '인사', '직원'
        ],
        'E-commerce': [
            'shopping', 'marketplace', 'retail', 'store', 'commerce',
            'buy', 'sell', '쇼핑', '판매', '이커머스'
        ],
        'SaaS': [
            'saas', 'software', 'cloud', 'platform', 'api',
            'tool', 'service', '소프트웨어', '서비스'
        ],
        'AI/ML': [
            'ai', 'ml', 'machine learning', 'deep learning', 'llm',
            'chatbot', 'gpt', '인공지능', '챗봇', 'AI'
        ],
        'Social': [
            'social', 'community', 'networking', 'messenger', 'chat',
            'forum', 'dating', '소셜', '커뮤니티', '메신저'
        ],
        'Entertainment': [
            'game', 'video', 'music', 'streaming', 'media',
            'content', 'entertainment', '게임', '영상', '엔터'
        ],
        'Logistics': [
            'logistics', 'delivery', 'shipping', 'warehouse', 'supply chain',
            'freight', 'transportation', '물류', '배송', '운송'
        ],
        'Travel': [
            'travel', 'hotel', 'flight', 'booking', 'tourism',
            'vacation', 'trip', '여행', '호텔', '항공'
        ],
        'Marketing': [
            'marketing', 'advertising', 'campaign', 'analytics', 'seo',
            'crm', 'email', '마케팅', '광고', '홍보'
        ],
        'CleanTech': [
            'clean', 'energy', 'solar', 'wind', 'sustainability',
            'recycling', 'green', '친환경', '에너지', '태양광'
        ]
    }

    def classify(self, idea: str) -> List[str]:
        """
        Classify idea into domain(s)

        Returns:
            List of domains (can be multiple for cross-domain ideas)
        """
        idea_lower = idea.lower()

        matches = []
        for domain, keywords in self.DOMAIN_KEYWORDS.items():
            for keyword in keywords:
                if keyword in idea_lower:
                    matches.append(domain)
                    break

        # Remove duplicates, keep order
        seen = set()
        unique_matches = []
        for domain in matches:
            if domain not in seen:
                seen.add(domain)
                unique_matches.append(domain)

        return unique_matches if unique_matches else ['General']


class MarketResearcher:
    """
    Automated market research using web APIs and heuristics

    In production, integrate with:
    - Statista API (market size data)
    - Crunchbase API (startup funding, competitors)
    - Google Trends API (search trends)
    - LinkedIn Sales Navigator API (B2B sizing)
    """

    # Estimated global market sizes (2026, USD Billion)
    # Source: Various industry reports (Gartner, IDC, Statista)
    MARKET_SIZES = {
        'EdTech': 350,
        'FinTech': 310,
        'HealthTech': 280,
        'FoodTech': 220,
        'PropTech': 180,
        'HRTech': 35,
        'E-commerce': 5800,
        'SaaS': 720,
        'AI/ML': 190,
        'Social': 250,
        'Entertainment': 400,
        'Logistics': 290,
        'Travel': 850,
        'Marketing': 480,
        'CleanTech': 150,
        'General': 100
    }

    # Average CAGR (2024-2028, %)
    GROWTH_RATES = {
        'EdTech': 12.3,
        'FinTech': 18.5,
        'HealthTech': 15.2,
        'FoodTech': 10.8,
        'PropTech': 14.5,
        'HRTech': 9.2,
        'E-commerce': 11.3,
        'SaaS': 16.7,
        'AI/ML': 36.2,
        'Social': 8.5,
        'Entertainment': 9.8,
        'Logistics': 7.3,
        'Travel': 12.1,
        'Marketing': 14.3,
        'CleanTech': 22.7,
        'General': 8.0
    }

    def __init__(self):
        self.classifier = DomainClassifier()

    def research(self, idea: str, region: str = "Korea") -> MarketData:
        """
        Conduct market research for given idea

        Args:
            idea: Product idea description
            region: Target market region

        Returns:
            MarketData with TAM/SAM/SOM, trends, competitors

        Raises:
            ValueError: If input validation fails
        """
        # Input validation
        if not idea or not idea.strip():
            raise ValueError("Idea cannot be empty")

        if len(idea) > 500:
            raise ValueError("Idea description too long (max 500 characters)")

        valid_regions = {'Korea', 'US', 'Europe', 'China', 'Japan', 'SEA', 'Global'}
        if region not in valid_regions:
            raise ValueError(f"Invalid region '{region}'. Choose from: {valid_regions}")

        # Sanitize input
        idea = idea.strip()

        # Classify domain
        domains = self.classifier.classify(idea)
        primary_domain = domains[0] if domains else 'General'

        # Calculate market size
        tam, sam, som = self._calculate_market_size(primary_domain, region)

        # Get growth rate
        cagr = self.GROWTH_RATES.get(primary_domain, 8.0)

        # Identify trends
        trends = self._identify_trends(primary_domain, idea)

        # Find competitors
        competitors = self._find_competitors(primary_domain, idea)

        # Define target segments
        segments = self._define_segments(primary_domain, idea)

        return MarketData(
            domain=primary_domain,
            tam=tam,
            sam=sam,
            som=som,
            cagr=cagr,
            trends=trends,
            competitors=competitors,
            target_segments=segments
        )

    def _calculate_market_size(
        self,
        domain: str,
        region: str
    ) -> Tuple[float, float, float]:
        """
        Calculate TAM, SAM, SOM

        Formula:
        - TAM: Global market size for domain
        - SAM: Regional market × addressable segment
        - SOM: SAM × realistic market share (3-5% for startup)
        """
        # TAM: Global market
        tam = self.MARKET_SIZES.get(domain, 100) * 1e9  # Convert to USD

        # SAM: Regional market
        region_multipliers = {
            'Korea': 0.025,      # ~2.5% of global
            'US': 0.30,          # 30% of global
            'Europe': 0.25,      # 25% of global
            'China': 0.20,       # 20% of global
            'Japan': 0.08,       # 8% of global
            'SEA': 0.05,         # 5% of global
            'Global': 1.0
        }

        region_mult = region_multipliers.get(region, 0.025)
        sam = tam * region_mult

        # SOM: Realistic obtainable market (3-5% of SAM for startups)
        som = sam * 0.03  # Conservative 3%

        return tam, sam, som

    def _identify_trends(self, domain: str, idea: str) -> List[str]:
        """
        Identify market trends for domain

        In production, use:
        - Google Trends API
        - Twitter trending topics
        - Reddit discussions
        - News API
        """
        # Hardcoded trends for 2026 (placeholder)
        trend_database = {
            'EdTech': [
                'AI-powered personalized learning',
                'Micro-learning (5-10 min modules)',
                'Gamification and badges',
                'Live cohort-based courses',
                'AR/VR immersive education'
            ],
            'FinTech': [
                'Embedded finance',
                'Buy Now Pay Later (BNPL)',
                'Crypto payments',
                'Open banking APIs',
                'AI fraud detection'
            ],
            'AI/ML': [
                'Generative AI (GPT-4, Claude)',
                'Multimodal AI (text+image+audio)',
                'AI agents and automation',
                'Edge AI on devices',
                'Responsible AI and ethics'
            ],
            'HealthTech': [
                'Telemedicine and remote monitoring',
                'AI diagnostics',
                'Wearable health devices',
                'Mental health apps',
                'Personalized medicine'
            ],
            'FoodTech': [
                'Dark kitchens (cloud kitchens)',
                'AI menu optimization',
                'Sustainability and plant-based',
                'Hyperlocal delivery (10 min)',
                'Food waste reduction'
            ]
        }

        trends = trend_database.get(domain, [
            'Digital transformation',
            'Mobile-first approach',
            'Subscription business model',
            'Community-driven platforms',
            'Data privacy and security'
        ])

        # Filter trends relevant to idea
        idea_lower = idea.lower()
        relevant_trends = []

        for trend in trends:
            # Simple keyword matching (in production, use NLP)
            if any(word in idea_lower for word in trend.lower().split()):
                relevant_trends.append(trend)

        # If no specific match, return top 3 trends
        if not relevant_trends:
            relevant_trends = trends[:3]

        return relevant_trends

    def _find_competitors(self, domain: str, idea: str) -> List[Dict[str, any]]:
        """
        Find competitors in the domain

        In production, use:
        - Crunchbase API (funding, employee count)
        - SimilarWeb API (traffic, rankings)
        - G2/Capterra (product reviews)
        """
        # Placeholder competitor data
        competitor_database = {
            'EdTech': [
                {
                    'name': 'Coursera',
                    'positioning': 'MOOC platform',
                    'funding': '$464M',
                    'mau': '142M',
                    'strengths': ['University partnerships', 'Degree programs', 'Global reach'],
                    'weaknesses': ['Low completion rate (15%)', 'Long courses', 'Expensive']
                },
                {
                    'name': 'Udemy',
                    'positioning': 'Marketplace for courses',
                    'funding': '$223M',
                    'mau': '64M',
                    'strengths': ['200K+ courses', 'Affordable ($10-50)', 'B2B (Udemy Business)'],
                    'weaknesses': ['Quality inconsistent', 'Low completion', 'No personalization']
                },
                {
                    'name': 'Brilliant',
                    'positioning': 'Interactive STEM learning',
                    'funding': '$100M',
                    'mau': '12M',
                    'strengths': ['Gamified', 'High engagement', 'Micro-lessons'],
                    'weaknesses': ['STEM only', 'No video', 'Not localized']
                }
            ],
            'FinTech': [
                {
                    'name': 'Stripe',
                    'positioning': 'Payment infrastructure',
                    'funding': '$2.2B',
                    'mau': 'N/A (B2B)',
                    'strengths': ['Developer-friendly', 'Global', 'Comprehensive APIs'],
                    'weaknesses': ['High fees (2.9%)', 'Complex for SMBs', 'US-focused']
                },
                {
                    'name': 'Revolut',
                    'positioning': 'Digital banking',
                    'funding': '$1.7B',
                    'mau': '30M',
                    'strengths': ['Multi-currency', 'Low fees', 'Crypto support'],
                    'weaknesses': ['Customer support', 'Regulatory issues', 'Europe-focused']
                }
            ],
            'AI/ML': [
                {
                    'name': 'OpenAI (ChatGPT)',
                    'positioning': 'Conversational AI',
                    'funding': '$11.3B',
                    'mau': '200M',
                    'strengths': ['Best LLM', 'First mover', 'Brand recognition'],
                    'weaknesses': ['Expensive API', 'Hallucinations', 'Data privacy']
                },
                {
                    'name': 'Anthropic (Claude)',
                    'positioning': 'Safe AI assistant',
                    'funding': '$7.3B',
                    'mau': '10M',
                    'strengths': ['Safety-focused', 'Long context', 'Reasoning'],
                    'weaknesses': ['Smaller market share', 'Less known', 'API cost']
                }
            ]
        }

        competitors = competitor_database.get(domain, [
            {
                'name': 'Generic Competitor 1',
                'positioning': 'Market leader',
                'funding': '$100M',
                'mau': '10M',
                'strengths': ['Established brand', 'Large user base'],
                'weaknesses': ['Legacy tech', 'Slow innovation']
            }
        ])

        return competitors[:5]  # Top 5 competitors

    def _define_segments(self, domain: str, idea: str) -> List[str]:
        """
        Define target customer segments
        """
        segment_database = {
            'EdTech': [
                'Students (K-12)',
                'University students',
                'Working professionals (upskilling)',
                'Career switchers',
                'Lifelong learners (50+)'
            ],
            'FinTech': [
                'Gen Z (digital natives)',
                'Millennials (mobile-first)',
                'SMB owners',
                'Freelancers and gig workers',
                'Underbanked populations'
            ],
            'AI/ML': [
                'Developers',
                'Data scientists',
                'Product managers',
                'Content creators',
                'Business analysts'
            ],
            'HealthTech': [
                'Chronic disease patients',
                'Elderly (65+)',
                'Fitness enthusiasts',
                'Mental health seekers',
                'Preventive care users'
            ]
        }

        return segment_database.get(domain, [
            'Early adopters',
            'Tech-savvy consumers',
            'SMB customers',
            'Enterprise clients'
        ])

    def generate_report(self, market_data: MarketData) -> str:
        """
        Generate markdown market research report
        """
        report = f"""# Market Research Report

## Domain Classification
**Primary Domain:** {market_data.domain}

---

## Market Size Analysis

### TAM (Total Addressable Market)
**${market_data.tam / 1e9:.1f}B** - Global {market_data.domain} market size (2026)

### SAM (Serviceable Addressable Market)
**${market_data.sam / 1e9:.2f}B** - Addressable market in target region

### SOM (Serviceable Obtainable Market)
**${market_data.som / 1e6:.0f}M** - Realistic 3-year revenue target (3% market share)

### Growth Rate
**{market_data.cagr:.1f}% CAGR** (2024-2028) - Industry growth projection

---

## Market Trends

"""

        for i, trend in enumerate(market_data.trends, 1):
            report += f"{i}. **{trend}**\n"

        report += "\n---\n\n## Competitive Landscape\n\n"

        for comp in market_data.competitors:
            report += f"""### {comp['name']}
**Positioning:** {comp['positioning']}
**Funding:** {comp['funding']}
**MAU:** {comp['mau']}

**Strengths:**
"""
            for strength in comp['strengths']:
                report += f"- {strength}\n"

            report += "\n**Weaknesses:**\n"
            for weakness in comp['weaknesses']:
                report += f"- {weakness}\n"

            report += "\n---\n\n"

        report += "## Target Customer Segments\n\n"

        for i, segment in enumerate(market_data.target_segments, 1):
            report += f"{i}. **{segment}**\n"

        report += f"""
---

## Strategic Recommendations

### Market Entry Strategy
1. **Focus on underserved segment**: Identify gaps in competitor offerings
2. **Differentiate on**: {market_data.trends[0] if market_data.trends else 'Technology innovation'}
3. **Pricing**: Position between free and premium competitors
4. **Distribution**: Leverage {market_data.trends[1] if len(market_data.trends) > 1 else 'digital channels'}

### Success Metrics
- **Year 1 Target**: {market_data.som / 1e6 * 0.1:.1f}M ARR (10% of SOM)
- **Customer Acquisition**: CAC < LTV × 0.3
- **Market Share**: 1% of SAM (Year 3)

---

*Report generated on {datetime.now().strftime("%Y-%m-%d %H:%M")}*
"""

        return report


# CLI usage
if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python market_researcher.py '<product idea>' [region]")
        sys.exit(1)

    idea = sys.argv[1]
    region = sys.argv[2] if len(sys.argv) > 2 else "Korea"

    researcher = MarketResearcher()
    market_data = researcher.research(idea, region)

    report = researcher.generate_report(market_data)
    print(report)

    # Save to file
    filename = f"market_research_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(report)

    print(f"\n✅ Report saved to {filename}")
