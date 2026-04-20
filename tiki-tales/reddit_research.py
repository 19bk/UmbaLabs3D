"""
Reddit research scraper for Tiki Tales — Tonies & kids toys market research.
Uses PRAW (same setup as EssayAlly reddit-bot).

Usage: python reddit_research.py
Output: reddit_research_results.md
"""

import json
import os
import sys
import time
from datetime import datetime

# Borrow credentials from the reddit-bot project
sys.path.insert(0, "/Users/bernard/dev/EssayAlly/reddit-bot")
from dotenv import load_dotenv
load_dotenv("/Users/bernard/dev/EssayAlly/reddit-bot/.env")

import praw

reddit = praw.Reddit(
    client_id=os.getenv("REDDIT_CLIENT_ID"),
    client_secret=os.getenv("REDDIT_CLIENT_SECRET"),
    user_agent="macos:tikitales.research:1.0 (by /u/mc_mafia)",
)

# ── Search Queries ──────────────────────────────────────────────────────────

SEARCHES = [
    # Tonies - parent opinions
    {"query": "toniebox worth it", "subreddit": "Mommit+daddit+Parenting+beyondthebump+toddlers", "label": "tonies_worth"},
    {"query": "tonies kids love OR hate", "subreddit": "Mommit+daddit+Parenting+beyondthebump+toddlers", "label": "tonies_love_hate"},
    {"query": "toniebox alternative", "subreddit": "all", "label": "tonies_alt"},
    {"query": "toniebox expensive figurines", "subreddit": "all", "label": "tonies_cost"},
    {"query": "yoto player vs toniebox", "subreddit": "all", "label": "yoto_vs_tonies"},

    # Screen-free toys
    {"query": "screen free toys toddler", "subreddit": "Mommit+daddit+Parenting+beyondthebump+toddlers", "label": "screen_free"},
    {"query": "best toys 3 year old actually play with", "subreddit": "Mommit+daddit+Parenting+beyondthebump+toddlers", "label": "best_toys_3"},
    {"query": "best toys 5 year old", "subreddit": "Mommit+daddit+Parenting+toddlers", "label": "best_toys_5"},

    # Audio toys / storytelling
    {"query": "audio stories kids device", "subreddit": "all", "label": "audio_stories"},
    {"query": "yoto player review kids", "subreddit": "Mommit+daddit+Parenting+beyondthebump", "label": "yoto"},
    {"query": "storypod kids", "subreddit": "all", "label": "storypod"},

    # Kids toys that are hits
    {"query": "toy kids obsessed with", "subreddit": "Mommit+daddit+Parenting+beyondthebump+toddlers", "label": "obsessed"},
    {"query": "toy kids play with every day", "subreddit": "Mommit+daddit+Parenting+beyondthebump+toddlers", "label": "daily_play"},
    {"query": "gift toddler actually uses", "subreddit": "Mommit+daddit+Parenting+beyondthebump+toddlers", "label": "gift_uses"},

    # Collectible toys
    {"query": "kids collecting toys obsessed", "subreddit": "Mommit+daddit+Parenting", "label": "collecting"},

    # DIY Toniebox / Phoniebox
    {"query": "phoniebox DIY toniebox", "subreddit": "all", "label": "diy_toniebox"},
    {"query": "raspberry pi kids music player NFC", "subreddit": "all", "label": "diy_nfc_player"},
]

# ── Specific threads to scrape ─────────────────────────────────────────────

SPECIFIC_THREADS = [
    "1oy4iz3",  # Tonie box do kids actually like it (Mommit)
]

def scrape_thread(submission, max_comments=100):
    """Extract post + top comments from a submission."""
    submission.comment_sort = "top"
    submission.comments.replace_more(limit=0)

    comments = []
    for c in submission.comments[:max_comments]:
        if hasattr(c, 'body'):
            comments.append({
                "author": str(c.author) if c.author else "[deleted]",
                "body": c.body[:1000],
                "score": c.score,
                "replies_count": len(c.replies) if hasattr(c.replies, '__len__') else 0,
            })

    return {
        "id": submission.id,
        "title": submission.title,
        "subreddit": str(submission.subreddit),
        "selftext": submission.selftext[:2000] if submission.selftext else "",
        "score": submission.score,
        "num_comments": submission.num_comments,
        "url": f"https://reddit.com{submission.permalink}",
        "created": datetime.fromtimestamp(submission.created_utc).strftime("%Y-%m-%d"),
        "comments": comments,
    }

def search_reddit(query, subreddit="all", limit=15, time_filter="year"):
    """Search a subreddit and return top results."""
    results = []
    try:
        sub = reddit.subreddit(subreddit)
        for submission in sub.search(query, time_filter=time_filter, sort="relevance", limit=limit):
            results.append({
                "id": submission.id,
                "title": submission.title,
                "subreddit": str(submission.subreddit),
                "score": submission.score,
                "num_comments": submission.num_comments,
                "url": f"https://reddit.com{submission.permalink}",
                "created": datetime.fromtimestamp(submission.created_utc).strftime("%Y-%m-%d"),
                "preview": (submission.selftext or "")[:300],
            })
        time.sleep(1)  # rate limit
    except Exception as e:
        print(f"  Error searching '{query}': {e}")
    return results

def main():
    all_data = {}

    # 1. Scrape specific threads
    print("=== Scraping specific threads ===")
    for thread_id in SPECIFIC_THREADS:
        try:
            submission = reddit.submission(id=thread_id)
            data = scrape_thread(submission)
            all_data[f"thread_{thread_id}"] = data
            print(f"  Scraped: {data['title']} ({len(data['comments'])} comments)")
        except Exception as e:
            print(f"  Error scraping {thread_id}: {e}")
        time.sleep(1)

    # 2. Run searches
    print("\n=== Running searches ===")
    for s in SEARCHES:
        print(f"  Searching: {s['query']} in r/{s['subreddit']}...")
        results = search_reddit(s["query"], s["subreddit"])
        all_data[s["label"]] = results
        print(f"    Found {len(results)} results")

    # 3. Scrape top 3 results from key searches for full comments
    print("\n=== Scraping top threads for comments ===")
    key_searches = ["tonies_worth", "tonies_love_hate", "screen_free", "obsessed", "daily_play", "tonies_alt"]
    scraped_ids = set(SPECIFIC_THREADS)

    for key in key_searches:
        if key in all_data and isinstance(all_data[key], list):
            for result in all_data[key][:3]:
                if result["id"] not in scraped_ids and result["num_comments"] > 5:
                    try:
                        submission = reddit.submission(id=result["id"])
                        data = scrape_thread(submission, max_comments=50)
                        all_data[f"full_{result['id']}"] = data
                        scraped_ids.add(result["id"])
                        print(f"  Scraped: {data['title']} ({len(data['comments'])} comments)")
                        time.sleep(1)
                    except Exception as e:
                        print(f"  Error: {e}")

    # 4. Save raw JSON
    output_json = "/Users/bernard/dev/UmbaLabs3D/tiki-tales/reddit_raw_data.json"
    with open(output_json, "w") as f:
        json.dump(all_data, f, indent=2, default=str)
    print(f"\nRaw data saved to {output_json}")

    # 5. Generate markdown report
    output_md = "/Users/bernard/dev/UmbaLabs3D/tiki-tales/reddit_research_results.md"
    generate_report(all_data, output_md)
    print(f"Report saved to {output_md}")

def generate_report(data, output_path):
    """Generate markdown report from scraped data."""
    lines = ["# Reddit Research: Tonies, Kids Toys & Audio Devices", ""]
    lines.append(f"*Scraped: {datetime.now().strftime('%Y-%m-%d %H:%M')}*\n")

    # Specific threads with full comments
    lines.append("---\n## Full Thread Analysis\n")
    for key, val in data.items():
        if key.startswith("thread_") or key.startswith("full_"):
            if isinstance(val, dict) and "comments" in val:
                lines.append(f"### [{val['title']}]({val['url']})")
                lines.append(f"**r/{val['subreddit']}** | Score: {val['score']} | Comments: {val['num_comments']} | {val['created']}\n")
                if val.get("selftext"):
                    lines.append(f"> {val['selftext'][:500]}\n")
                lines.append("**Top Comments:**\n")
                for c in sorted(val["comments"], key=lambda x: x["score"], reverse=True)[:15]:
                    body = c["body"].replace("\n", " ").strip()
                    if len(body) > 300:
                        body = body[:300] + "..."
                    lines.append(f"- **[{c['score']} pts]** {body}\n")
                lines.append("")

    # Search results
    lines.append("---\n## Search Results by Topic\n")
    for s in SEARCHES:
        key = s["label"]
        if key in data and isinstance(data[key], list) and data[key]:
            lines.append(f"### {s['query']}")
            lines.append(f"*Searched in: r/{s['subreddit']}*\n")
            for r in data[key][:10]:
                lines.append(f"- **[{r['score']}]** [{r['title']}]({r['url']}) (r/{r['subreddit']}, {r['num_comments']} comments, {r['created']})")
                if r.get("preview"):
                    preview = r["preview"].replace("\n", " ").strip()
                    if len(preview) > 200:
                        preview = preview[:200] + "..."
                    lines.append(f"  > {preview}")
            lines.append("")

    with open(output_path, "w") as f:
        f.write("\n".join(lines))

if __name__ == "__main__":
    main()
