# Chapter 4 — REST-Powered Models, Caching & Threading

## Your task

You are creating the **project succession** for Chapter 4 of the book *Qt6 QML Advanced* by Daniel Gakwaya. The author writes each lecture **from working code**, so the projects must exist before the prose. Your job is to create a series of incrementally-built, self-contained Qt 6 CMake projects — one per section — that together teach the chapter's material.

You will NOT write the chapter prose. You write code only. Each project in the succession must:

- Build and run on its own (Qt 6.8+, MinGW or MSVC on Windows; the author works on Windows).
- Be **strictly incremental**: project `NN+1` is a copy of project `NN` with the new section's content added. The reader should be able to `diff` two successive folders and see exactly what the section teaches.
- Use the project structure conventions from chapter 3 in this same repo (see "Conventions" below — read those folders first).
- Use modern Qt 6.8+ idioms: `QML_ELEMENT`, `qt_add_qml_module`, `qt_standard_project_setup`, declarative QML modules, no `qmlRegisterType` calls in `main.cpp` for normal types.

## Chapter goal

Teach the reader how to build **C++ models that fetch their own data from REST APIs**, with disk caching, background threading, conditional requests, and live updates — using GitHub's REST API as the real-world data source.

By the end of the chapter the reader has built **Repo Explorer Pro**: a paginated, multi-tab GitHub client (repositories, issues, users) with offline-friendly caching, smooth scrolling under load, and live refresh.

## Why GitHub, not a social media API

The chapter previously planned a "Social Media Feed" project. That was dropped because there is no real social API to call without inventing mocks. GitHub's REST API provides everything we actually need to teach:

- Real **offset pagination** (`page` / `per_page`).
- Real **cursor pagination** via the `Link` header.
- Real **rate limits** (60/hr unauth, 5000/hr authenticated) — gives `429`/`403` handling teeth.
- Real **ETags** for conditional `If-None-Match` requests.
- Stable, free, well-documented.

The reader already trusts the `GitHubService` class from chapter 2 (`02_RestClientCustomTypes/07_GitHubService/`). Chapter 4 levels it up.

## What the reader already knows (do not re-teach)

By the time the reader reaches chapter 4, they have built:

- **Chapter 1:** every QML↔C++ wiring mechanism (context properties, signals/slots both directions, `Q_INVOKABLE`, `QML_ELEMENT`, declarative QML modules).
- **Chapter 2:** a `GitHubService` using `QNetworkAccessManager`, custom `User` and `Repository` types with `Q_PROPERTY`, JSON parsing, error/loading UI states.
- **Chapter 3:** a full `QAbstractListModel` (Contact Manager) with custom roles, CRUD, `QSortFilterProxyModel`, JSON persistence.

Chapter 4 fuses chapter 2's networking with chapter 3's modeling. Do not re-explain how `QAbstractListModel` or `QNetworkAccessManager` work — assume the reader knows them. Show the **integration patterns**.

## Conventions to follow (READ THESE FIRST)

Before writing any code, study the existing chapter folders in this repo:

- `01_DivingIn/` — 10 sub-projects, one per section
- `02_RestClientCustomTypes/` — REST + custom types
- `03-CustomModelsRealData/` — model succession, the closest precedent for this chapter

Match those folders' conventions exactly:

- **Folder naming:** `NN_short_snake_case` describing what that section adds (e.g. `02_repo_model_basic`, `03_offset_pagination`).
- **Per-project structure:**
  ```
  NN_section_name/
    CMakeLists.txt
    main.cpp
    src/
      models/
      services/
      managers/   (only if needed)
      workers/    (only if needed)
    qml/
      Main.qml
      components/
      pages/
  ```
- **Project name** inside `CMakeLists.txt` stays constant across all sections of this chapter: **`RepoExplorerPro`**. Only the folder name changes.
- **QML module URI:** `RepoExplorerProApp` (constant across sections).
- **CMake style:** mirror `03-CustomModelsRealData/04_contact_list_model/CMakeLists.txt`. Use `qt_standard_project_setup(REQUIRES 6.8)`, list sources explicitly, pass C++ sources to `qt_add_qml_module(... SOURCES ...)` when those types are exposed to QML.
- **Modern idiom:** put `QML_ELEMENT` directly in C++ headers; do not call `qmlRegisterType` in `main.cpp` for normal types. Use singleton attribute + `QML_SINGLETON` where appropriate.
- **No comments explaining the obvious.** Code reads itself. Only comment WHY when non-obvious.

## Section succession to create

Create **10 project folders** numbered `01` through `10`. Each is a complete buildable Qt project. The order and increment for each is below.

> **Important about section 01:** unlike chapter 3 (which starts with a generic starter), chapter 4 starts by **importing chapter 2's `GitHubService`** so the reader sees their previous work being reused. Section 01 IS the starter — set up the project shell + ported service.

---

### 01_starter_with_github_service

**Purpose:** baseline project that has chapter 2's `GitHubService` and `Repository` / `User` types brought across, plus a minimal QML shell. No models yet — just a working single-call demo.

**What to include:**

- Copy `GitHubService`, `Repository`, `User` from `02_RestClientCustomTypes/07_GitHubService/src/` (or 08/09 — whichever is the latest complete version of those types).
- Minimal `Main.qml` with an `ApplicationWindow`, a tab bar with three tabs (Repositories / Issues / Users) — only the Repositories tab is wired this chapter; the other two are placeholders the reader will activate in later sections.
- A single "Search" text field + button that triggers `gitHubService.searchRepositories(query)` and dumps results into a plain `Repeater` or basic `ListView` showing repo name + description. This is intentionally crude — it'll be replaced by a proper model in section 02.

**Why this exists:** establishes the project, proves the chapter 2 service still works in the new home, and creates the visual "before" state the reader replaces.

---

### 02_repo_model_basic

**Purpose:** wrap `GitHubService` in a `QAbstractListModel` (`RepositoryListModel`) so QML binds to a proper model instead of a `Repeater`.

**What to add over 01:**

- `src/models/repositorylistmodel.h` / `.cpp` — `QAbstractListModel` subclass exposing repos via custom roles (Name, FullName, Description, Stars, Forks, Language, Url).
- Model **owns** a `GitHubService` instance internally OR receives one — pick one pattern and explain in code which it is (`Q_PROPERTY` for injection, or internal ownership). Recommendation: internal ownership for this section, then we may refactor later.
- `Q_INVOKABLE void search(const QString &query)` on the model.
- `ListView` in QML replaces the `Repeater` from section 01, with a basic `RepoDelegate.qml` showing the same fields.

**No pagination yet.** Single-page fetch. The model holds whatever the first response returns.

---

### 03_offset_pagination

**Purpose:** teach offset pagination — `page` and `per_page` query parameters, a "Load more" trigger from QML.

**What to add over 02:**

- `RepositoryListModel` gains `currentPage`, `perPage`, `hasMore` (or similar) properties.
- `Q_INVOKABLE void loadMore()` that fetches the next page and **appends** to the model (`beginInsertRows` / `endInsertRows`).
- QML: a "Load more" button at the bottom of the list, or a `ListView.onAtYEnd` trigger that auto-fires.
- Track `totalCount` if the API gives it (GitHub search responses include `total_count`).
- Loading indicator while a page is in flight (`isLoadingPage` property).

---

### 04_cursor_pagination_link_header

**Purpose:** teach cursor pagination using GitHub's `Link` header — the pattern needed for endpoints that don't expose total counts (issues, comments, etc.).

**What to add over 03:**

- New service method (or extension): `searchRepositoriesByCursor()` that parses the `Link: <...>; rel="next"` header from the response.
- The model stores the **next URL** (or cursor token) instead of computing it from a page number.
- Infinite scroll feel: as the user scrolls toward the end of the `ListView`, the model triggers the next fetch automatically. Use `ListView.onContentYChanged` with a threshold, or `ScrollBar`-driven, or a sentinel delegate at the end — pick the cleanest.
- Keep offset pagination working in parallel (as a fallback / for the search endpoint which uses page numbers). The point is to show both patterns coexisting.

---

### 05_disk_cache_threaded

**Purpose:** introduce a disk cache for responses, and run cache I/O on a worker thread so the GUI never blocks on disk.

**What to add over 04:**

- `src/workers/cacheworker.h` / `.cpp` — `QObject` derivative running on its own `QThread`. Receives "save this response under this key" and "load response for this key" messages via signals/slots. Cache files stored under `QStandardPaths::CacheLocation`/`RepoExplorerPro/`.
- `src/services/cachemanager.h` / `.cpp` — facade that owns the worker thread, exposes a sync-looking API to the rest of the app via futures or callbacks.
- Cache key strategy: hash of the request URL.
- Cache write happens on successful response; cache read happens on every request and serves stale data instantly while the network request is in flight (stale-while-revalidate).
- Show the "double-render" pattern: model emits data from cache, then updates when fresh data arrives.

This is the section that **demonstrates threading concretely**. Do not introduce threading abstractly — the reader sees the GUI thread getting unblocked.

---

### 06_concurrent_json_parsing

**Purpose:** move JSON parsing off the GUI thread using `QtConcurrent::run` + `QFuture` + `QFutureWatcher`.

**What to add over 05:**

- `GitHubService` (or a parsing helper) hands the raw `QByteArray` response to `QtConcurrent::run([] { return Repository::listFromJson(bytes); })`.
- A `QFutureWatcher<QList<Repository>>` notifies the model on the GUI thread when parsing finishes.
- Demonstrate with an artificially large response (e.g. fetch `per_page=100` and parse) — possibly with a `qDebug` timing log so the reader sees the difference.
- Add `Q_PROPERTY bool isParsing` so QML can show a "parsing..." state distinct from "fetching...".

This is the second threading lesson. After 05 + 06, the reader has seen both `QThread`-worker and `QtConcurrent`-fire-and-forget patterns, and knows when to use each.

---

### 07_etag_conditional_requests

**Purpose:** teach conditional requests and rate-limit awareness.

**What to add over 06:**

- Cache entries now store the response's `ETag` alongside the body.
- Outgoing requests for a cached key add `If-None-Match: "<etag>"`.
- Handle `304 Not Modified` — serve cached body, do **not** count against the model's "new data arrived" path (no row inserts).
- Parse `X-RateLimit-Remaining` and `X-RateLimit-Reset` from response headers; expose as a singleton or property on the service.
- Show a small "rate limit: 47 / 60 remaining, resets at 14:32" indicator somewhere in the UI — taught as a real production concern.
- Personal Access Token support: a settings field where the reader pastes a token, used as `Authorization: Bearer <token>` to bump the limit to 5000/hr. (Chapter 2 may have already covered the token; if so, just reuse — don't reteach.)

---

### 08_live_updates_polling

**Purpose:** teach periodic refresh + diff-merge so the model stays current without resetting and losing scroll position.

**What to add over 07:**

- A `QTimer` (configurable interval, e.g. 60s) on the model that re-fetches page 1.
- Compare incoming list against current list **by stable ID** (GitHub repos have `id`):
  - New IDs → `beginInsertRows` at the top.
  - Removed IDs → `beginRemoveRows`.
  - Existing IDs with changed fields (e.g. `stargazers_count` went up) → emit `dataChanged` for affected rows/roles.
- Visual cue: newly inserted rows briefly highlight in QML (a quick animation in the delegate keyed off a "is new" role).
- **WebSocket conceptual sidebar:** include a small `docs/websocket_note.md` in this section's folder explaining that real-time push systems use WebSockets (or SSE), and we'll see actual WebSocket-like push in Book 2's IoT chapter via MQTT. This is the only "doc" file in the chapter — purely there because the chapter prose will reference it.

---

### 09_full_ui_three_tabs

**Purpose:** activate the Issues and Users tabs the reader stubbed back in section 01. Demonstrate that the model patterns generalize.

**What to add over 08:**

- `IssueListModel` (cursor-paginated via `Link`) consuming the GitHub Issues search endpoint.
- `UserListModel` (offset-paginated) consuming the Users search endpoint.
- Three corresponding pages: `RepositoryListPage.qml`, `IssueListPage.qml`, `UserListPage.qml` — all use the same delegate/list/loadingstate idioms from the repo page.
- Empty / loading / error / offline states wired consistently across all three. (Chapter 2 covered these visually; chapter 4 connects them properly through the model's status signals.)
- A shared `LoadingState` enum or status `Q_PROPERTY` on a common model base. **Optional:** factor `AbstractGitHubListModel` as a tiny shared base — only if the duplication genuinely warrants it.

---

### 10_polish_and_summary

**Purpose:** the final, "this is what shipped" version. Code matches what the chapter summary refers back to.

**What to add over 09:**

- Final polish: persistent settings (last-used tab, PAT, refresh interval) via `QSettings`.
- Keyboard shortcuts on the search bar.
- A `README.md` at the root of this section's folder summarizing what the project does, how to build, the GitHub PAT setup, and the cache location.
- No new C++ types unless polish demands it.

This is also the version that gets referenced by Book 2 chapters as "the chapter 4 end state."

---

## Constraints and don'ts

- **Do not invent APIs.** Use real GitHub REST endpoints. If you need an endpoint that doesn't behave as described above, flag it in a `NOTES.md` at the chapter root rather than faking behavior.
- **Do not add features beyond the section's scope.** If a feature naturally belongs to section 07, don't sneak it into section 05 even if it'd be easy. The whole point is the reader sees one concept added per section.
- **Do not introduce frameworks the reader hasn't met.** No `KDE Frameworks`, no third-party JSON libs, no Boost. Stick to Qt + standard C++.
- **Do not skip ahead on the QML side.** Keep delegates simple; section 09 is the one allowed to be visually polished. Earlier sections should look intentionally rough.
- **Do not write the chapter prose.** Code only. The author writes prose from your code.
- **Do not commit to git.** Just create the files. The author handles commits.

## Deliverable

After you finish, the folder `04_RestPoweredModelsCachingThreading/` should contain **10 subfolders** (`01_...` through `10_...`), each a buildable Qt project, plus this `prompt.md` left in place. No top-level CMakeLists, no top-level `main.cpp` — each subfolder is independent.

## How to verify before declaring done

For each project folder, confirm:

1. `CMakeLists.txt` is present and lists every source file.
2. `main.cpp` compiles without errors against Qt 6.8.
3. The QML module URI in `qt_add_qml_module` matches `RepoExplorerProApp`.
4. The project builds end-to-end on Windows MinGW (the author's primary kit).
5. Running it produces visible, working behavior for the section's concept.
6. Diff against the previous section's folder shows ONLY the additions the section is supposed to introduce.

## Reference: GitHub endpoints used

- `GET /search/repositories?q=<query>&page=N&per_page=30`
- `GET /search/issues?q=<query>&per_page=30` (returns `Link` header)
- `GET /search/users?q=<query>&page=N&per_page=30`
- All with `Accept: application/vnd.github+json` and optional `Authorization: Bearer <pat>`.

## Final note

The author's writing pattern is: take a section's project, walk the reader through building it from the previous section's state. Your job is to make those "from → to" diffs **teachable**: small enough that one section of prose can cover them, large enough that the section earns its place in the book.

If something in this prompt is ambiguous, prefer the choice that produces the cleanest **diff between sections**. That's the unit of value here.
