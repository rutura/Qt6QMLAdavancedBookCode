# Chapter 4 — Session Handoff Context

> Read this file in full before doing anything else. It contains everything needed to resume the build from the exact point the previous session was interrupted.

---

## 1. Who I am, what I'm building

I am Daniel Gakwaya, author of *Qt6 QML Advanced*. The cwd is the chapter 4 folder of the book's code repository:

```
d:\Sandbox\Qt6QMLAdavancedBookCode\04_RestPoweredModelsCachingThreading\
```

The task is to create the **project succession** for chapter 4 — 10 incremental Qt 6 CMake projects (`01_starter_with_github_service` through `10_polish_and_summary`) — that together teach the chapter's material. The chapter is about REST-powered `QAbstractListModel`s, disk caching, threading, conditional requests, live updates.

The end product is **Repo Explorer Pro**: a paginated GitHub client with 3 tabs (Repositories, Issues, Users), offline-friendly caching, smooth scrolling, and live refresh.

The full specification is in `prompt.md` at the chapter root. **Read it.** It is the authoritative source — this file only summarizes.

---

## 2. Working rules (non-negotiable)

- **Strict incremental diffs.** Folder `NN+1` is `NN` plus only the additions of section `NN+1`. A `diff` between two adjacent folders must show exactly what the section teaches. Never sneak features ahead.
- **Project name is constant across all sections**: `RepoExplorerPro` (in CMakeLists.txt `project()` and `qt_add_executable`).
- **QML module URI is constant**: `RepoExplorerProApp`.
- **Qt 6.8+ idioms** throughout: `qt_standard_project_setup(REQUIRES 6.8)`, `QML_ELEMENT` in headers (no `qmlRegisterType` in `main.cpp`), `qt_add_qml_module(... SOURCES ...)` for QML-exposed C++.
- **No git commits.** The user handles all commits.
- **No chapter prose.** Code only.
- **No comments explaining the obvious.** Only WHY-comments where the choice is non-obvious.
- **Build verification** after each section: configure + build with MinGW, then briefly launch the binary (smoke only, no scripted interaction). Fix errors before moving on.

---

## 3. Build environment

- **OS:** Windows 11 Pro
- **Shell:** PowerShell (use PowerShell syntax in commands — no `&&` chaining; use `;` with `if ($?)` instead, or chain in one PowerShell call)
- **Qt:** `C:\Qt\6.11.0\mingw_64` (satisfies `REQUIRES 6.8`)
- **MinGW:** `C:\Qt\Tools\mingw1310_64\bin` (GCC 13.1.0)
- **CMake:** 3.30 on PATH (`C:\Program Files\CMake\bin\cmake.exe`)
- **qt-cmake wrapper:** `C:\Qt\6.11.0\mingw_64\bin\qt-cmake.bat`

### Standard configure + build incantation for any section

```powershell
$env:PATH = "C:\Qt\6.11.0\mingw_64\bin;C:\Qt\Tools\mingw1310_64\bin;" + $env:PATH
$sec = "d:\Sandbox\Qt6QMLAdavancedBookCode\04_RestPoweredModelsCachingThreading\NN_section_name"
& "C:\Qt\6.11.0\mingw_64\bin\qt-cmake.bat" -G "MinGW Makefiles" -S $sec -B "$sec\build" 2>&1 | Select-Object -Last 5
cmake --build "$sec\build" -j 4 2>&1 | Select-Object -Last 12
```

### Smoke-launch a built binary

```powershell
$exe = "$sec\build\RepoExplorerPro.exe"
$p = Start-Process -FilePath $exe -PassThru
Start-Sleep -Seconds 2
if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force; "OK_LAUNCHED" } else { "EXITED_EARLY rc=$($p.ExitCode)" }
```

### Copy section N -> section N+1 (excludes build dir)

```powershell
$src = "d:\Sandbox\Qt6QMLAdavancedBookCode\04_RestPoweredModelsCachingThreading\NN_current"
$dst = "d:\Sandbox\Qt6QMLAdavancedBookCode\04_RestPoweredModelsCachingThreading\NN_next"
robocopy $src $dst /E /XD build /NFL /NDL /NJH /NJS | Out-Null
```

`robocopy` exits with non-zero codes (1 = files copied successfully) — that's normal; do not treat as error.

### About IDE clang diagnostics

Every C++ file I write triggers a stream of clang `pp_file_not_found` / `unknown_typename` diagnostics for Qt headers (`QObject`, `QString`, etc.). **These are false positives** — clang has no Qt include paths configured at the IDE level. They are not real errors. The actual builds with `qt-cmake` + MinGW succeed cleanly. Ignore them entirely.

---

## 4. Design decisions already made (with user approval)

The user explicitly approved all four "Recommended" answers at the start of the session:

1. **Service shape (section 01):** Port the chapter-2 `GitHubService` v2 API **intact** (with its `QVariantList repositories` etc.). Section 01's QML uses a `Repeater` bound to `gitHubService.repositories`. Section 02 then **extends** the service with a new raw-result signal (`searchResultsReady(QList<Repository*>)`) that the model consumes, leaving the v2 API in place alongside it.
2. **Model owns the service:** Section 02's `RepositoryListModel` owns a `GitHubService` instance internally (per prompt's recommendation). A short comment in the header documents this choice.
3. **Cursor pagination trigger (section 04):** Sentinel `Item` as `ListView.footer` with `onVisibleChanged: if (visible) model.fetchNextPage()`. The offset path from section 03 stays intact; a `ComboBox` in QML toggles between offset and cursor modes.
4. **Verification depth:** Configure + build each section. Launch the binary briefly (~2s) to confirm it starts; no scripted UI interaction.

Additional internal decision:
- **Section 05 folder layout:** Keep `src/api/` for `githubservice.*` (already present since section 01) and add `src/services/cachemanager.*` and `src/workers/cacheworker.*` alongside. **Do not** rename `src/api/` to `src/services/` — that would add gratuitous churn to the diff.

---

## 5. Section progress — what is DONE and what is IN PROGRESS

### Completed (built + smoke-launched)

| # | Folder | Status |
|---|---|---|
| 01 | `01_starter_with_github_service` | ✅ builds, smoke OK |
| 02 | `02_repo_model_basic` | ✅ builds, smoke OK |
| 03 | `03_offset_pagination` | ✅ builds, smoke OK |
| 04 | `04_cursor_pagination_link_header` | ✅ builds, smoke OK |

### In progress — section 05 (`05_disk_cache_threaded`)

Folder exists (copied from 04). **NOT YET BUILT.** Files written so far:

- `src/workers/cacheworker.h` ✅ written
- `src/workers/cacheworker.cpp` ✅ written
- `src/services/cachemanager.h` ✅ written
- `src/services/cachemanager.cpp` ✅ written
- `src/api/githubservice.h` ✅ extended — added forward decl `class CacheManager`, `setCache()`, `cachedPageReady`/`cachedCursorReady` signals, `onCacheLoaded()` slot, `RequestKind` enum, `PendingRequest` struct, `parseSearchItems()`, `m_cache` + `m_pendingByKey` members
- `src/api/githubservice.cpp` ✅ extended — included `cachemanager.h`, added `setCache()`, `parseSearchItems()`, `onCacheLoaded()` implementations; `searchRepositoriesPage()`, `searchRepositoriesCursor()`, `fetchByUrl()` now also call `m_cache->requestLoad(key)` first; `onSearchResultsPageReceived()` and `onSearchResultsCursorReceived()` now also call `m_cache->requestSave(...)` on success
- `src/models/repositorylistmodel.cpp` ✅ extended — now wires `CacheManager::create(nullptr, nullptr)` into the service and connects to BOTH `cachedPageReady`/`cachedCursorReady` AND `searchResultsPageReady`/`searchResultsCursorReady` so cache + network both feed the model (stale-while-revalidate)

**Still to do for section 05** (this is exactly where the session was interrupted):

1. **Update `05_disk_cache_threaded/CMakeLists.txt`** to add the new sources. The full updated CMakeLists.txt should look like this:

```cmake
cmake_minimum_required(VERSION 3.16)

project(RepoExplorerPro VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Network)

qt_standard_project_setup(REQUIRES 6.8)

set(PROJECT_SOURCES
    main.cpp
)

set(QML_FILES
    qml/Main.qml
    qml/pages/RepositoryListPage.qml
    qml/components/RepoDelegate.qml
)

qt_add_executable(RepoExplorerPro
    ${PROJECT_SOURCES}
)

qt_add_qml_module(RepoExplorerPro
    URI RepoExplorerProApp
    VERSION 1.0
    QML_FILES ${QML_FILES}
    SOURCES
        src/user.h
        src/user.cpp
        src/repository.h
        src/repository.cpp
        src/api/githubservice.h
        src/api/githubservice.cpp
        src/models/repositorylistmodel.h
        src/models/repositorylistmodel.cpp
        src/services/cachemanager.h
        src/services/cachemanager.cpp
        src/workers/cacheworker.h
        src/workers/cacheworker.cpp
)

set_target_properties(RepoExplorerPro PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_include_directories(RepoExplorerPro
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/api
    ${CMAKE_CURRENT_SOURCE_DIR}/src/models
    ${CMAKE_CURRENT_SOURCE_DIR}/src/services
    ${CMAKE_CURRENT_SOURCE_DIR}/src/workers
)

target_link_libraries(RepoExplorerPro
    PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
)

include(GNUInstallDirs)
install(TARGETS RepoExplorerPro
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
```

The differences from section 04's CMakeLists are: added `src/services/cachemanager.{h,cpp}` and `src/workers/cacheworker.{h,cpp}` to `SOURCES`; added `src/services` and `src/workers` to `target_include_directories`.

2. **Configure + build section 05** with the standard incantation. Watch for:
   - The `CacheManager::create(nullptr, nullptr)` call in the model: this is fine because `create` is a static QML-singleton factory. It uses `QCoreApplication::instance()` as the parent and returns the same static instance.
   - `QQmlEngine` is forward-declared via `<qqml.h>` and `<QQmlEngine>` is included in `repositorylistmodel.cpp`. If linker complains about `QQmlEngine`, link `Qt6::Qml` (already linked).
   - `QThread` ownership in `CacheManager`: the worker's `moveToThread(&m_thread)` happens in constructor body, before `m_thread.start()`. Worker is parented to `nullptr` because it lives on a different thread; cleaned up via `QThread::finished -> deleteLater`.

3. **Fix any compile errors that surface.** Most likely candidates:
   - Missing include of `<QHash>` for `m_pendingByKey` in `githubservice.h`.
   - The `CacheManager::create(nullptr, nullptr)` accepts `QQmlEngine*` and `QJSEngine*` — passing `nullptr` for both is fine for direct creation outside the QML engine context.

4. **Smoke launch.** Confirm window opens.

5. **Mark section 05 todo as completed**, move to section 06.

---

## 6. Files to look at for context / precedent

- `prompt.md` — full spec (READ FIRST in next session)
- `NOTES.md` (already seeded at chapter root) — API behavioral notes; add observations as new ones surface
- `../02_RestClientCustomTypes/07_GitHubService/` — canonical chapter-2 GitHubService source
- `../03-CustomModelsRealData/04_contact_list_model/CMakeLists.txt` — closest CMake-style precedent

---

## 7. Remaining sections (06–10) plan

Each section's `NN+1` folder is a copy of `NN` (via `robocopy /E /XD build`) plus the listed additions. **Do not** sneak features from later sections into earlier ones.

### Section 06 — `06_concurrent_json_parsing`

Delta over 05:
- `Repository::listFromJsonBytes(const QByteArray&)` static helper added in `repository.h/.cpp`. Returns `QList<Repository*>` parented to nullptr.
- `GitHubService` JSON parsing for the page/cursor receive handlers moves off the GUI thread via `QtConcurrent::run`. A `QFutureWatcher<QList<Repository*>>` (one per request, owned by the watcher's lambda capture, deleted on finish) notifies back on GUI thread.
- New `Q_PROPERTY bool isParsing` on `GitHubService` (with `m_inflightParses` counter).
- `QElapsedTimer` in the parse path; `qDebug()` log shows ms taken.
- `RepositoryListPage.qml`: tiny "parsing…" label bound to `repoModel.service.isParsing`.
- `CMakeLists.txt`: add `Qt6::Concurrent` to `find_package` and `target_link_libraries`.

### Section 07 — `07_etag_conditional_requests`

Delta over 06:
- `CacheManager::loaded` already returns the ETag (was stored since 05). `GitHubService::onCacheLoaded` now extracts the etag and stashes it by URL into `m_etagByUrl`.
- On outgoing requests for a URL that has a cached ETag, set `If-None-Match: "<etag>"`.
- In page/cursor receive handlers: detect 304 via `reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() == 304`. On 304: do NOT emit network-results signal. Still save the existing cache entry with the response's possibly-updated ETag header (or skip save entirely — 304 means body is empty).
- Parse `X-RateLimit-Remaining`, `X-RateLimit-Limit`, `X-RateLimit-Reset` from every response. Expose on `GitHubService` as `Q_PROPERTY int rateLimitRemaining`, `Q_PROPERTY int rateLimitTotal`, `Q_PROPERTY QDateTime rateLimitReset`.
- `RepositoryListPage.qml`: small status row above the search bar showing "rate limit: 47/60, resets at 14:32".
- New `qml/components/TokenSettings.qml`: collapsible row with a masked `TextField` bound to `gitHubService.authToken`. NO C++ changes for token — the chapter-2 service already supports `authToken` natively.

### Section 08 — `08_live_updates_polling`

Delta over 07:
- `RepositoryListModel` adds: `QTimer m_refreshTimer`, `Q_PROPERTY int refreshIntervalMs` (default 60000), `Q_PROPERTY bool autoRefresh`.
- On timer tick: re-fetch page 1 of `m_currentQuery`.
- New private method `applyDiff(QList<Repository*> incoming)`:
  - Build hash of current m_repos by `id`.
  - For incoming IDs not present → prepend (insert at row 0) with `IsNewRole=true`.
  - For current IDs absent from incoming → `beginRemoveRows` + remove.
  - For overlapping IDs whose stargazersCount/forksCount/description changed → mutate the existing `Repository*` and emit `dataChanged(idx, idx, {role…})`.
- New `IsNewRole` (boolean). `QTimer m_isNewClearTimer` (one-shot) fires ~3s after insert, flips `isNew` back to false and emits `dataChanged` for the role.
- `RepoDelegate.qml`: soft yellow background that fades to white via `Behavior on color` when `model.isNew` flips false.
- `docs/websocket_note.md` at section root — short MD on real-time-push via WebSockets/SSE/MQTT (deferred to Book 2). **This is the only doc file in the chapter.**

### Section 09 — `09_full_ui_three_tabs`

This is the biggest section. Delta over 08:
- **New abstract base class** `src/models/abstractgithublistmodel.{h,cpp}`:
  - Holds owned `GitHubService*`, `status` enum (`Idle, Loading, Error`), `errorMessage`, `totalCount`, `nextUrl`, `useCursor`, paged + cursor entry points, and the diff-merge logic from section 08.
  - Virtual `parseItems(const QByteArray &body, int *totalCountOut) -> QList<QObject*>` for subclasses to override (must return objects with a stable `id()`).
  - Virtual `endpointPathForQuery(const QString&, int page, int perPage)` for subclasses to build their URL.
  - Subclasses provide `data()` and `roleNames()` switches.
- `RepositoryListModel` becomes a thin subclass over the abstract base.
- New `src/models/issue.{h,cpp}` — analogous to `Repository`, fields per GitHub `/search/issues` schema (number, title, state, user.login, comments).
- New `src/models/issuelistmodel.{h,cpp}` — cursor-paginated subclass consuming `/search/issues`. Default query e.g. `"is:issue qt qml"`.
- New `src/models/userlistmodel.{h,cpp}` — offset-paginated subclass consuming `/search/users`. Reuses `User` (already extended with score/bio if needed).
- `GitHubService` learns `searchIssues(q, page, perPage)`, `searchUsers(q, page, perPage)`. Each emits its own `searchResultsPageReady` variant (e.g. `issueResultsPageReady(QList<Issue*>, int page, int total)`). OR — preferred — the abstract base owns its own private QNetworkAccessManager and the service only provides URL helpers. **Decide on whichever produces the cleaner diff over 08.** Recommendation: abstract base does the network + cache itself, with the service reduced to a URL builder helper.
- New QML: `qml/pages/IssueListPage.qml`, `qml/pages/UserListPage.qml`, `qml/components/IssueDelegate.qml`, `qml/components/UserDelegate.qml`. All three pages share the same idiom: search bar, status row, ListView with footer sentinel, empty/loading/error states.
- `qml/Main.qml`: section 01's placeholder Items for Issues and Users tabs are replaced with the real pages.

### Section 10 — `10_polish_and_summary`

Delta over 09:
- `src/services/appsettings.{h,cpp}` — `QML_SINGLETON` wrapping `QSettings`. Properties: `lastTabIndex`, `authToken`, `refreshIntervalMs`. Reads at startup, writes on change.
- `qml/Main.qml`: TabBar `currentIndex` bound bidirectionally to `AppSettings.lastTabIndex`. PAT field in TokenSettings bound to `AppSettings.authToken`.
- Explicit keyboard shortcuts on search bar: `Shortcut { sequence: "Ctrl+L"; onActivated: queryField.forceActiveFocus() }`, `Shortcut { sequence: StandardKey.Cancel; onActivated: queryField.clear() }`.
- `README.md` at section root: what the project does, build instructions (MinGW + Qt 6.8+), GitHub PAT setup, cache location (`%LOCALAPPDATA%\...\cache\RepoExplorerPro\` on Windows).
- **No new C++ types** beyond `AppSettings`.

---

## 8. Final report I owe the user after section 10

After all 10 sections build cleanly, deliver a short report summarizing:

1. **Decisions left open by the prompt** and which way I went:
   - Service shape in section 01 → kept v2 API intact (Option 1)
   - Model<->service ownership in section 02 → internal ownership (prompt recommendation)
   - Cursor trigger in section 04 → sentinel `ListView.footer` Item (Option 1)
   - Section 05 layout → kept `src/api/` alongside new `src/services/` and `src/workers/` (no rename)
   - Section 09 abstract base ownership → (whichever was chosen — document at time of work)
2. **Any `NOTES.md` entries** added during the build (GitHub API quirks encountered, total_count cap, etc.). NOTES.md currently has only the seeded entry about `Link` headers on search endpoints.
3. **Confirmed list of the 10 completed section folders**, ready for review.

---

## 9. Per-section verification checklist

Before marking a section complete:

1. `CMakeLists.txt` present and lists every source file.
2. `main.cpp` compiles cleanly with Qt 6.11 / MinGW (warnings only on Qt headers, not our code).
3. QML module URI in `qt_add_qml_module` is `RepoExplorerProApp` exactly.
4. Build end-to-end succeeds.
5. Binary launches without crashing on startup (2-second smoke).
6. Diff against `NN-1` shows ONLY the additions the section is supposed to introduce.

---

## 10. Todo list state at session interruption

```
1. [completed] Section 01 — starter with GitHubService
2. [completed] Section 02 — repo model basic
3. [completed] Section 03 — offset pagination
4. [completed] Section 04 — cursor pagination via Link header
5. [in_progress] Section 05 — disk cache + threaded worker
6. [pending] Section 06 — concurrent JSON parsing
7. [pending] Section 07 — ETags + conditional requests + rate limit
8. [pending] Section 08 — live updates with polling + diff merge
9. [pending] Section 09 — full UI with three tabs + abstract base
10. [pending] Section 10 — polish, QSettings, README
11. [pending] Final report + decisions summary
```

Recreate this todo list with TodoWrite at the start of the next session.

---

## 11. Immediate next actions for the resuming agent

1. **Read `prompt.md`** in full.
2. **Re-create the todo list** above using TodoWrite, leaving section 05 as in_progress.
3. **Read every file already created in `05_disk_cache_threaded/`** to verify state matches what this context file describes. Particularly:
   - `src/api/githubservice.h` — should have cache wiring (forward decl, signals, slot, members)
   - `src/api/githubservice.cpp` — should have `setCache`, `parseSearchItems`, `onCacheLoaded`, cache calls in entry points and save in receive handlers
   - `src/models/repositorylistmodel.cpp` — should wire CacheManager and connect to both cached+network signals
4. **Write the updated CMakeLists.txt** for section 05 (full contents shown in §5 above).
5. **Build section 05** with the standard incantation.
6. **Fix any errors that surface.** Expected error candidates noted in §5.
7. **Smoke launch.** Mark section 05 todo completed.
8. **Continue with section 06** per the plan in §7.

---

## 12. Things the user has explicitly said

- "No git commits. I'll handle commits myself."
- "No chapter prose. Code only."
- "Build verification: After completing each section, configure and build it on Windows + MinGW (the author's primary kit) to confirm it compiles cleanly. Fix any errors before moving on."
- "Order of work: complete sections one at a time, in numerical order."

---

End of context. Resume work at §11.
