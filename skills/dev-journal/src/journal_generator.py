#!/usr/bin/env python3
# Development Journal Generator
# Automatically generate development journals from Git commits

import subprocess
import json
from datetime import datetime, timedelta
from typing import List, Dict, Optional
from dataclasses import dataclass
from pathlib import Path
import re


@dataclass
class Commit:
    """Git commit information"""
    hash: str
    author: str
    date: datetime
    subject: str
    body: str
    files_changed: List[str]
    insertions: int
    deletions: int


class GitLogParser:
    """Parse Git log and extract commit information"""

    def __init__(self, repo_path: str = "."):
        self.repo_path = Path(repo_path)

    def get_commits_since(self, since: str) -> List[Commit]:
        """
        Get commits since a specific date

        Args:
            since: Date string (e.g., "today", "2026-01-29", "1 week ago")

        Returns:
            List of Commit objects
        """
        # Git log format
        format_str = "--pretty=format:%H%n%an%n%ai%n%s%n%b%n---END---"

        cmd = [
            "git", "log",
            f"--since={since}",
            format_str,
            "--numstat"
        ]

        result = subprocess.run(
            cmd,
            cwd=self.repo_path,
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            raise Exception(f"Git log failed: {result.stderr}")

        return self._parse_log_output(result.stdout)

    def _parse_log_output(self, output: str) -> List[Commit]:
        """Parse git log output into Commit objects"""
        commits = []

        # Split by commit separator
        commit_blocks = output.split("---END---\n")

        for block in commit_blocks:
            if not block.strip():
                continue

            lines = block.split('\n')

            if len(lines) < 4:
                continue

            commit_hash = lines[0]
            author = lines[1]
            date_str = lines[2]
            subject = lines[3]

            # Parse date
            date = datetime.fromisoformat(date_str.rsplit(' ', 1)[0])

            # Extract body (everything between subject and file stats)
            body_lines = []
            file_stats_start = -1

            for i, line in enumerate(lines[4:], start=4):
                if re.match(r'^\d+\s+\d+\s+', line):
                    file_stats_start = i
                    break
                body_lines.append(line)

            body = '\n'.join(body_lines).strip()

            # Parse file stats
            files_changed = []
            insertions = 0
            deletions = 0

            if file_stats_start > 0:
                for line in lines[file_stats_start:]:
                    match = re.match(r'^(\d+)\s+(\d+)\s+(.+)$', line)
                    if match:
                        adds = int(match.group(1))
                        dels = int(match.group(2))
                        file = match.group(3)

                        insertions += adds
                        deletions += dels
                        files_changed.append(file)

            commits.append(Commit(
                hash=commit_hash,
                author=author,
                date=date,
                subject=subject,
                body=body,
                files_changed=files_changed,
                insertions=insertions,
                deletions=deletions
            ))

        return commits

    def get_issue_references(self, commit: Commit) -> List[str]:
        """Extract issue references from commit (e.g., #42, GH-123)"""
        text = f"{commit.subject} {commit.body}"

        # Match #123 or GH-123
        pattern = r'(?:#|GH-)(\d+)'
        matches = re.findall(pattern, text)

        return [f"#{m}" for m in matches]

    def categorize_commit(self, commit: Commit) -> str:
        """Categorize commit by type (feat, fix, refactor, etc.)"""
        subject_lower = commit.subject.lower()

        # Check conventional commit format
        if match := re.match(r'^(feat|fix|refactor|docs|test|chore|perf|ci)(\(.+\))?:', subject_lower):
            return match.group(1)

        # Heuristic categorization
        if any(word in subject_lower for word in ['add', 'implement', 'create']):
            return 'feat'
        elif any(word in subject_lower for word in ['fix', 'resolve', 'bug']):
            return 'fix'
        elif any(word in subject_lower for word in ['refactor', 'clean', 'simplify']):
            return 'refactor'
        elif any(word in subject_lower for word in ['test', 'coverage']):
            return 'test'
        elif any(word in subject_lower for word in ['doc', 'readme']):
            return 'docs'
        else:
            return 'chore'


class JournalGenerator:
    """Generate development journal in markdown format"""

    def __init__(self, repo_path: str = "."):
        self.parser = GitLogParser(repo_path)

    def generate_daily_log(self, date: Optional[str] = None) -> str:
        """Generate daily development log"""
        if date is None:
            date = datetime.now().strftime("%Y-%m-%d")

        commits = self.parser.get_commits_since(f"{date} 00:00:00")

        if not commits:
            return f"# {date} 개발 일지\n\n커밋이 없습니다.\n"

        # Sort by date
        commits.sort(key=lambda c: c.date)

        # Generate markdown
        md = f"# {date} 개발 일지\n\n"
        md += f"## 커밋 요약 ({len(commits)} commits)\n\n"

        for commit in commits:
            category = self.parser.categorize_commit(commit)
            time_str = commit.date.strftime("%H:%M")

            md += f"### [{category}] {commit.subject}\n"
            md += f"**Time:** {time_str}\n"
            md += f"**Author:** {commit.author}\n"
            md += f"**Commit:** {commit.hash[:7]}\n\n"

            if commit.body:
                md += f"{commit.body}\n\n"

            # File changes
            if commit.files_changed:
                md += f"**Files Changed:** {len(commit.files_changed)}\n"
                for file in commit.files_changed[:5]:
                    md += f"- `{file}`\n"
                if len(commit.files_changed) > 5:
                    md += f"- ... and {len(commit.files_changed) - 5} more\n"
                md += "\n"

            # Stats
            md += f"**Changes:** +{commit.insertions} -{commit.deletions}\n"

            # Issue references
            issues = self.parser.get_issue_references(commit)
            if issues:
                md += f"**Related Issues:** {', '.join(issues)}\n"

            md += "\n---\n\n"

        # Summary stats
        total_insertions = sum(c.insertions for c in commits)
        total_deletions = sum(c.deletions for c in commits)
        total_files = len(set(f for c in commits for f in c.files_changed))

        md += "## 메트릭 (Metrics)\n\n"
        md += f"- **Commits:** {len(commits)}\n"
        md += f"- **Lines Added:** +{total_insertions}\n"
        md += f"- **Lines Deleted:** -{total_deletions}\n"
        md += f"- **Files Changed:** {total_files}\n"

        return md

    def generate_weekly_summary(self, week_start: Optional[str] = None) -> str:
        """Generate weekly summary"""
        if week_start is None:
            # Start of current week (Monday)
            today = datetime.now()
            week_start = (today - timedelta(days=today.weekday())).strftime("%Y-%m-%d")

        week_end = (datetime.fromisoformat(week_start) + timedelta(days=6)).strftime("%Y-%m-%d")

        commits = self.parser.get_commits_since(f"{week_start} 00:00:00")

        # Filter commits within the week
        week_end_dt = datetime.fromisoformat(week_end + " 23:59:59")
        commits = [c for c in commits if c.date <= week_end_dt]

        if not commits:
            return f"# 주간 요약 ({week_start} ~ {week_end})\n\n커밋이 없습니다.\n"

        md = f"# 주간 요약 ({week_start} ~ {week_end})\n\n"

        # Categorize commits
        by_category = {}
        for commit in commits:
            category = self.parser.categorize_commit(commit)
            if category not in by_category:
                by_category[category] = []
            by_category[category].append(commit)

        # Highlights
        md += "## 🚀 주요 성과\n\n"

        category_names = {
            'feat': '새 기능',
            'fix': '버그 수정',
            'refactor': '리팩토링',
            'test': '테스트',
            'docs': '문서',
            'perf': '성능 개선'
        }

        for category, category_commits in by_category.items():
            category_name = category_names.get(category, category)
            md += f"### {category_name} ({len(category_commits)}개)\n\n"

            # Show top 3
            for commit in category_commits[:3]:
                md += f"- {commit.subject}\n"

            if len(category_commits) > 3:
                md += f"- ... and {len(category_commits) - 3} more\n"

            md += "\n"

        # Stats
        total_insertions = sum(c.insertions for c in commits)
        total_deletions = sum(c.deletions for c in commits)
        total_files = len(set(f for c in commits for f in c.files_changed))

        md += "## 📊 통계\n\n"
        md += "| 지표 | 이번 주 |\n"
        md += "|------|--------|\n"
        md += f"| Commits | {len(commits)} |\n"
        md += f"| Lines Added | +{total_insertions} |\n"
        md += f"| Lines Deleted | -{total_deletions} |\n"
        md += f"| Files Changed | {total_files} |\n"

        # Author contributions
        by_author = {}
        for commit in commits:
            if commit.author not in by_author:
                by_author[commit.author] = []
            by_author[commit.author].append(commit)

        md += "\n## 👥 기여자\n\n"
        for author, author_commits in sorted(by_author.items(), key=lambda x: len(x[1]), reverse=True):
            md += f"- **{author}:** {len(author_commits)} commits\n"

        return md


def main():
    """CLI entry point"""
    import argparse

    parser = argparse.ArgumentParser(description="Generate development journal")
    parser.add_argument('--daily', action='store_true', help='Generate daily log')
    parser.add_argument('--weekly', action='store_true', help='Generate weekly summary')
    parser.add_argument('--date', type=str, help='Date (YYYY-MM-DD)')
    parser.add_argument('--output', type=str, help='Output file path')
    parser.add_argument('--repo', type=str, default='.', help='Git repository path')

    args = parser.parse_args()

    generator = JournalGenerator(args.repo)

    if args.daily:
        content = generator.generate_daily_log(args.date)
    elif args.weekly:
        content = generator.generate_weekly_summary(args.date)
    else:
        print("Error: Specify --daily or --weekly")
        return

    if args.output:
        Path(args.output).write_text(content, encoding='utf-8')
        print(f"Journal saved to {args.output}")
    else:
        print(content)


if __name__ == "__main__":
    main()
