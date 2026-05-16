# Chapter 4 — API behavioral notes

Behaviors of GitHub's REST API that are load-bearing for this chapter's lessons but not obvious from a fresh reading of the docs. Add observations here as the projects encounter them.

## Confirmed behaviors

### `Link` headers on every search endpoint
GitHub's `/search/repositories`, `/search/issues`, and `/search/users` endpoints all return a `Link` header on multi-page responses. This makes cursor pagination via `Link` genuinely demonstrable on every endpoint used in this chapter — no separate endpoint is needed for the cursor lesson in section 04, and the three-tab generalization in section 09 can use the same `Link`-parsing helper for issues and (optionally) users.

Example response header on the second page of a search:

```
Link: <https://api.github.com/search/repositories?q=qt&per_page=30&page=1>; rel="first",
      <https://api.github.com/search/repositories?q=qt&per_page=30&page=3>; rel="next",
      <https://api.github.com/search/repositories?q=qt&per_page=30&page=34>; rel="last",
      <https://api.github.com/search/repositories?q=qt&per_page=30&page=1>; rel="prev"
```

Only the `rel="next"` URL is consumed by the cursor flow.

## Deviations from prompt.md (deliberate, author-approved)

### PAT (Personal Access Token) UI appears from section 01, not section 07
`prompt.md` schedules the PAT settings UI as section 07's lesson. During development the author intentionally added a GitHub PAT `TextField` plus a rate-limit hint to `qml/pages/RepositoryListPage.qml` in **sections 01–04** (the unauthenticated 60 req/hr limit makes the early sections frustrating to demo without a token). The author chose to keep these edits and carry them forward.

Consequence: the PAT field is present from section 01 onward. Section 07's delta is therefore reduced to:
- the `X-RateLimit-*` header parsing + the visible "rate limit: N/M, resets at HH:MM" indicator,
- ETag storage + `If-None-Match` conditional requests + `304 Not Modified` handling,
- (optionally) restyling the existing PAT field into a collapsible settings row.

Section 07 does **not** "introduce" the PAT field — it already exists. The C++ `authToken` property / `Authorization: Bearer` header were already implemented in the chapter-2 `GitHubService`, so no C++ token work is new in 07 either.

### Section 09 abstract base owns its own QNAM + cache (not GitHubService)
`prompt.md` says to "factor `AbstractGitHubListModel` … holding … the owned `GitHubService` instance", and the planning notes floated making `RepositoryListModel` a thin subclass too. The implemented design instead:

- `AbstractGitHubListModel` owns its **own** `QNetworkAccessManager` + the shared `CacheManager`, plus the pagination / stale-while-revalidate / ETag-304 / cursor-`Link` machinery. Subclasses supply only `endpointForQuery()` and `parseItems()`.
- `IssueListModel` and `UserListModel` inherit from it (as the prompt requires).
- `RepositoryListModel` is left **unchanged from section 08** — it keeps its `GitHubService`, offset+cursor toggle, polling/diff-merge, and `isNew` highlight.

Rationale (the prompt's tie-breaker is "cleanest diff between sections"): rewriting the mature `RepositoryListModel` onto the new base would have produced an enormous, lesson-obscuring diff over section 08 and risked regressing the section-08 polling/diff-merge lesson. Keeping Repository as-is makes section 09 a near-pure addition (base class + two models + Issue type + three pages/delegates), which is the most teachable boundary. The base deliberately does not depend on `GitHubService`, which is the cleanest possible generalization for the two new endpoints.

### GitHub search `total_count` is capped at 1000
GitHub's search endpoints report `total_count` but will not page past 1000 results regardless of the real match count. The offset-pagination "X of N" label can therefore show an N larger than the number of rows that can actually be loaded. This is expected GitHub behavior, not a bug in the model.
