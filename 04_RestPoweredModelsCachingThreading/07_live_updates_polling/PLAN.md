# Section 7 — Live Updates via Polling + Diff-Merge

## Context

This plan is for Chapter 4 of Book 1 (Qt6 QML Advanced), section 7. The previous section's code in `06_concurrent_json_parsing` was copied into `07_live_updates_polling` as the starter, but **the only thing that carries over from section 6 is concurrent JSON parsing**. Polling, the refresh timer, the diff-merge algorithm, the "new" highlight, and the sort axis are all **introduced from scratch in this section**.

The original outline had section 7 as ETag + rate-limit handling. That's **dropped** because GitHub's `/search/repositories` doesn't return 304 on repeat (`ETag` header present but useless as a 304 trigger for search results). The original section 8 (live updates) slides up to become section 7.

### Why polling is the right teach here

After models, async networking, caching, and threading, the natural next reader question is: *"how do I make this list update on its own?"* The interesting answer is not the timer — it's **how to land new data into the model without throwing away scroll position or flashing every row**. That's the diff-merge algorithm, and it's the centerpiece of the section.

WebSockets get a conceptual sidebar (one or two paragraphs) — when you'd reach for them instead, and a pointer to Book 2 ch 8 (MQTT for IoT). **No WebSocket code** in this section; GitHub doesn't expose one for repo activity anyway, which is part of why polling is the honest answer here.

### Verified GitHub API behavior (curl probe, 2026-05-26)

- `GET /search/repositories?q=<query>&sort=updated&order=desc&per_page=N` returns the same `items[]` shape `Repository::listFromJsonBytes` already parses. **No parser changes needed.**
- Re-polling the same URL 6 seconds apart against `q=stars:>1&sort=updated&order=desc&per_page=5` showed 4 of 5 top items rotate between polls. Live churn is visible — perfect demo material.
- `q=qt+qml&sort=updated&order=desc` returns ~4,200 results with `updated_at` timestamps in the last hour. The reader's demo query (`qt qml`) will show new items pop in within a poll or two.
- `X-RateLimit-Limit: 10` for search unauthenticated, 30/min authenticated. **15s default poll interval** leaves headroom for manual searches. **10s is the hard floor** to enforce in the model.
- Search responses do **not** return 304 on `If-None-Match` (verified during section 6's work — that's why ETag was dropped from this section's title).

---

## What's actually in the starter (verified by reading the files)

The starter is section 6's code with concurrent JSON parsing already wired through, and **nothing else live-related**. Concretely:

- `repositorylistmodel.h/.cpp` — has `search()`, `loadMore()`, `fetchNextPage()`, `resetWith()`, `appendBatch()`. Roles: `IdRole, NameRole, FullNameRole, DescriptionRole, StarsRole, ForksRole, LanguageRole, UrlRole`. **No** refresh timer, **no** autoRefresh, **no** sortField, **no** diff-merge, **no** IsNewRole, **no** lastRefreshAt.
- `githubservice.h/.cpp` — `searchRepositoriesPage(query, page, perPage, sort="stars", order="desc")` already takes `sort` and `order` arguments with `"stars"` defaults. **No service changes needed** beyond changing the call site to pass `"updated"`.
- `qml/pages/RepositoryListPage.qml` — has SearchField, Search button, mode combo (Offset/Cursor), TokenField, ListContainer, Load-more button. **No** auto-refresh switch, **no** poll-interval picker, **no** "last refresh" pill, **no** sort combo.
- `Repository::id()` exists and is the stable GitHub-assigned int — perfect diff key.
- `RepoCard` delegate has no `isNew`/highlight state.

**Everything below is new code in this section.**

---

## Concrete changes

### A. `src/models/repositorylistmodel.h` — add the live-update surface

New roles:
```cpp
enum Roles {
    IdRole = Qt::UserRole + 1, NameRole, FullNameRole, DescriptionRole,
    StarsRole, ForksRole, LanguageRole, UrlRole,
    IsNewRole                                       // NEW: true for ~3s after diff-merge insert
};
```

New properties:
```cpp
Q_PROPERTY(bool autoRefresh READ autoRefresh WRITE setAutoRefresh NOTIFY autoRefreshChanged)
Q_PROPERTY(int refreshIntervalMs READ refreshIntervalMs WRITE setRefreshIntervalMs NOTIFY refreshIntervalMsChanged)
Q_PROPERTY(QDateTime lastRefreshAt READ lastRefreshAt NOTIFY lastRefreshAtChanged)
Q_PROPERTY(QString sortField READ sortField WRITE setSortField NOTIFY sortFieldChanged)
```

New private state:
```cpp
QTimer *m_refreshTimer;             // owned by this
bool m_autoRefresh = false;
int m_refreshIntervalMs = 15000;    // 15s default
QDateTime m_lastRefreshAt;
QString m_sortField = "updated";    // default for this section's demo
bool m_isRefreshing = false;        // set on tick start, cleared on tick result
QSet<int> m_newIds;                 // ids currently flagged IsNewRole
QTimer *m_clearNewTimer;            // single-shot 3s after each diff-merge that inserted
```

New methods:
```cpp
private slots:
    void onRefreshTick();
    void onClearNewFlags();

private:
    void applyDiff(const QList<Repository*> &incoming);  // the centerpiece
```

### B. `src/models/repositorylistmodel.cpp` — implementation

1. **Constructor**: create `m_refreshTimer` and `m_clearNewTimer`, wire timeout signals to slots. `m_clearNewTimer` is single-shot. Both parented to `this`.

2. **`search()`**: change the call site from `searchRepositoriesPage(query, m_currentPage, m_perPage)` to `searchRepositoriesPage(query, m_currentPage, m_perPage, m_sortField, "desc")`. Same for the cursor branch. **Stop the refresh timer** at start of a fresh search and **restart it** at the end of the first successful response if `m_autoRefresh` is on.

3. **`data()`**: add `case IsNewRole: return m_newIds.contains(repo->id());`

4. **`roleNames()`**: add `{ IsNewRole, "isNew" }`.

5. **`setAutoRefresh(bool)`**: writes property; if turning ON and we have a non-empty query and we're in offset mode, start the timer; if turning OFF, stop the timer. Emits signal.

6. **`setRefreshIntervalMs(int)`**: **clamp to floor 10000**. Update timer interval if running. Emit signal. (Chapter prose explains the floor: unauthenticated search is 10/min, so anything below 6s is going to 403.)

7. **`setSortField(QString)`**: accepts `"updated"` or `"stars"` (anything else falls back to `"stars"`). Emits signal. **Does not re-fetch automatically** — the QML wires `onSortFieldChanged` to call `search(currentQuery)` so the change is visible immediately, but the model itself doesn't decide that.

8. **`onRefreshTick()`** — the polling brain:
   - Guard: bail if `m_currentQuery.isEmpty()` or `m_isLoadingPage` or `m_useCursor` (no stable page-1 in cursor mode).
   - Set `m_isRefreshing = true`. Set `m_lastRefreshAt = QDateTime::currentDateTime()` and emit notify.
   - Call `m_service->searchRepositoriesPage(m_currentQuery, 1, m_perPage, m_sortField, "desc")`. **Do not** flip `setIsLoadingPage(true)` — that would make the spinner blink every 15s. (Chapter explains this. Refresh is a *background* fetch, not a user-blocking one.)

9. **`onSearchResultsPageReady(repos, page, totalCount)`** — branch on `m_isRefreshing`:
   - If `m_isRefreshing && page == 1`: call `applyDiff(repos)`, then `m_isRefreshing = false`. **Don't** touch `setIsLoadingPage`. **Don't** emit `currentPageChanged`. Update `totalCount`.
   - Else: existing behavior (`page==1` → `resetWith`, else `appendBatch`). Then if `m_autoRefresh && !m_useCursor && !m_currentQuery.isEmpty()`, **start the refresh timer** so it fires 15s after the *fresh* search completes (not 15s after the search button was clicked).

10. **`applyDiff(incoming)`** — three passes, with narrow signals:
    - **Build current index**: `QHash<int, int> rowById` mapping repo id → row.
    - **Build incoming index**: `QHash<int, Repository*> incomingById` and `QSet<int> incomingIds`.
    - **Pass 1 — Remove**: iterate backwards over `m_repos`; if `!incomingIds.contains(repo->id())`, `beginRemoveRows(row, row)`, delete the repo, remove from list, `endRemoveRows()`. (Backwards so indices stay valid.)
    - **Pass 2 — Update in place**: for each surviving row, look up incoming by id; if mutable fields differ (`stargazersCount`, `forksCount`, `description`, `language`), write them via Repository setters, emit `dataChanged(index, index, {StarsRole, ForksRole, DescriptionRole, LanguageRole})`. **Narrow roles vector** — chapter calls this out as the win.
    - **Pass 3 — Insert new at top**: iterate `incoming` in order; any id not in `rowById` is new. Collect into a `toPrepend` list, then one `beginInsertRows(0, count-1)`/`endInsertRows()` for the whole batch, prepended to `m_repos`. Adopt with `setParent(this)`. Add each new id to `m_newIds`. Delete the unused incoming objects (the ones that matched existing rows — they were never adopted, so they leak unless we delete them).
    - **Emit `dataChanged` for the IsNewRole on the newly-prepended rows** (so QML sees the highlight come on).
    - Restart `m_clearNewTimer` for 3000ms.
    - `emit countChanged()` only if count changed.

11. **`onClearNewFlags()`**: snapshot `m_newIds`, clear it, then for each id still in the model, emit `dataChanged(index, index, {IsNewRole})` so the highlight fades off. This is one of the rare places where the model peeks at "which row is which id again" — keep it simple with a linear scan since the new set is small (typically 0-5).

### C. `qml/pages/RepositoryListPage.qml` — UI controls

Add to the `StatusStrip` content (or alongside the existing mode combo, depending on horizontal space):

```qml
// Sort axis combo — default "Most updated" for this section's demo
ComboBox {
    id: sortCombo
    model: ["Most updated", "Most starred"]
    currentIndex: repoModel.sortField === "updated" ? 0 : 1
    onActivated: {
        repoModel.sortField = (currentIndex === 0 ? "updated" : "stars")
        if (queryField.text.length > 0)
            repoModel.search(queryField.text)
    }
}

// Auto-refresh switch
Switch {
    id: autoRefreshSwitch
    text: "Auto-refresh"
    checked: repoModel.autoRefresh
    enabled: !repoModel.useCursor              // cursor mode: refresh is meaningless
    onToggled: repoModel.autoRefresh = checked
}

// Poll interval picker (only meaningful when auto-refresh is on)
ComboBox {
    id: intervalCombo
    enabled: repoModel.autoRefresh && !repoModel.useCursor
    model: [{ label: "15s", ms: 15000 }, { label: "30s", ms: 30000 },
            { label: "60s", ms: 60000 }, { label: "5 min", ms: 300000 }]
    textRole: "label"
    valueRole: "ms"
    currentIndex: 0
    onActivated: repoModel.refreshIntervalMs = currentValue
}

// "Updated 12s ago" pill — re-renders every second from a QML Timer
PillBadge {
    visible: repoModel.autoRefresh && repoModel.lastRefreshAt.getTime() > 0
    pillColor: Theme.info
    text: {
        const now = nowTick.now           // dependency for re-eval
        const last = repoModel.lastRefreshAt.getTime()
        const sec = Math.max(0, Math.floor((now - last) / 1000))
        return sec < 5 ? "updated just now" : "updated " + sec + "s ago"
    }
}

// Drives the pill's re-render each second
Timer {
    id: nowTick
    property double now: Date.now()
    interval: 1000; running: repoModel.autoRefresh; repeat: true
    onTriggered: now = Date.now()
}
```

The cursor-mode `Switch` becoming disabled is honest UX — auto-refresh genuinely doesn't work in cursor mode and the chapter prose explains why (no stable page-1 to diff against, page boundaries shift as new items arrive at the top).

### D. `qml/components/RepoCard.qml` — show the "new" highlight

Add an `isNew` boolean property; when true, render a 3s-fading green pill in the corner (e.g. `PillBadge { text: "new"; pillColor: Theme.success }`). The fade comes from a `Behavior on opacity { NumberAnimation { duration: 600 } }` triggered by the model's `dataChanged(IsNewRole)`. Wire `isNew: model.isNew` from the `RepositoryListPage` delegate.

### E. AsciiDoc section narrative (separate work — not the code task)

The book's section 7 AsciiDoc file will be written **after** the code passes verification with the user. The agent doing the code task does **not** need to write this — Daniel will write the prose himself once the code behaves. Don't touch the book repo at `D:\Sandbox\Qt6QMLAdvancedAsciidoc` from this task.

---

## Files to modify (code task only)

| Path | Change |
|---|---|
| `D:\Sandbox\Qt6QMLAdavancedBookCode\04_RestPoweredModelsCachingThreading\07_live_updates_polling\src\models\repositorylistmodel.h` | Add `IsNewRole`; add `autoRefresh`, `refreshIntervalMs`, `lastRefreshAt`, `sortField` properties; declare `m_refreshTimer`, `m_clearNewTimer`, `m_newIds`, `m_isRefreshing`; declare `onRefreshTick`, `onClearNewFlags`, `applyDiff`. |
| `D:\Sandbox\Qt6QMLAdavancedBookCode\04_RestPoweredModelsCachingThreading\07_live_updates_polling\src\models\repositorylistmodel.cpp` | Implement all the above; route `onSearchResultsPageReady` through diff-merge when `m_isRefreshing`; pass `m_sortField` into the service call. |
| `D:\Sandbox\Qt6QMLAdavancedBookCode\04_RestPoweredModelsCachingThreading\07_live_updates_polling\qml\pages\RepositoryListPage.qml` | Add sort combo, auto-refresh switch, interval combo, "updated Xs ago" pill, the 1s `Timer`; wire `isNew: model.isNew` into the delegate. |
| `D:\Sandbox\Qt6QMLAdavancedBookCode\04_RestPoweredModelsCachingThreading\07_live_updates_polling\qml\components\RepoCard.qml` | Add `isNew` property and a fading green "new" pill. |

---

## Out of scope (deliberate cuts — do not add these)

- **ETag-conditional polling** — dropped per the chapter rework.
- **Rate-limit adaptive backoff** — interesting, but balloons the section. The existing rate-limit pill is visible; that's enough.
- **Authenticated polling for the 30/min ceiling** — already covered in section 2; not re-taught.
- **WebSocket code** — sidebar only in prose, Book 2 ch 8 owns the real thing. No code.
- **Cursor-mode auto-refresh** — the model declines it, UI disables the switch in cursor mode.
- **Pause-on-window-unfocus** — out of scope.
- **Persisting sort/interval choice across launches** — out of scope; that's section 10 / app-state territory.

---

## Verification — hand back to Daniel to run

When the code changes are done, **stop**. Do not build or launch the project yourself. Tell Daniel the code is ready and hand him this verification script to run in Qt Creator:

> Open `D:\Sandbox\Qt6QMLAdavancedBookCode\04_RestPoweredModelsCachingThreading\07_live_updates_polling` in Qt Creator, configure with a Qt 6.8+ kit, hit Run. Walk through both scripts below; report anything that doesn't match.

### Quick sanity check (no GitHub account needed)

1. **First launch** — sort combo reads "Most updated" by default. Search field shows `qt`. Auto-refresh switch is off.
2. **Search** — change query to `qt qml`, hit Search. List fills with recent activity (top items should have `updated_at` from the last hour or so).
3. **Flip auto-refresh on** — within 15 seconds, the "updated Xs ago" pill appears, counts up each second, resets to "just now" on each tick.
4. **Scroll-preserved diff-merge** — scroll down a few rows, leave the window alone for one or two ticks. Viewport should **not** jump. Watch the top of the list while you wait — one of the next two or three polls should slide a card in at index 0 with a green "new" pill that fades after ~3s. (Switch query to `stars:>1` for a faster demo.)
5. **Sort flip** — change combo to "Most starred". List re-fetches; top items have huge star counts. Auto-refresh keeps running; in-place star-count updates can still happen with no flash.
6. **Cursor mode opt-out** — flip pagination to "Cursor". Auto-refresh switch and interval picker grey out. Flip back, they re-enable.
7. **Empty state under polling** — search `qkfjslajksldfjlsdkjf`. Auto-refresh keeps ticking quietly; empty state stays; no error banners. Toggle off, nothing else happens.

### The good test — make a new repo appear on cue

This proves the diff-merge works deterministically:

1. Paste your token into the TokenField. Confirm the rate-limit pill shows the authenticated ceiling.
2. In the app, search `user:rutura` (or `user:rutura qt` for a narrower set). Sort "Most updated". Auto-refresh on at 15s.
3. Open `https://github.com/new` in a browser. Create a new public repo under the `rutura` account — any name. Hit Create.
4. Switch back to the app and wait at most one full poll cycle. The new repo should slide in at the top with the green "new" pill. The pill fades after ~3 seconds.
5. Star or unstar the same repo from the browser. Within one tick, the star count on that card should change **in place** — no scroll jump, no row flash. That's pass 2 of `applyDiff`.
6. Delete the test repo from the browser. Within one tick, the card disappears with no visual disturbance to surrounding rows. That's pass 1 of `applyDiff`.

If insert / in-place update / remove all work cleanly against the real repo, diff-merge is correct end to end.

### What to report back

- Anything that flashes the whole list (means a `modelReset` is sneaking in where it shouldn't).
- Any viewport jump on a tick (means the diff is removing/inserting in a way that disturbs the scroll anchor).
- Any 403s or error banners during the soak (means the interval floor isn't holding or auth isn't being sent).
- Anything else surprising.
