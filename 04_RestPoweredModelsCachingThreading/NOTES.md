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
