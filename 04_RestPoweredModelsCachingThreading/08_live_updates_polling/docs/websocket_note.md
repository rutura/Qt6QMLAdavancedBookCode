# Note: Real-Time Push vs Polling

This section demonstrates **polling**-based live updates: a `QTimer` periodically re-fetches
page 1 of the current query and diff-merges the result into the existing model. Polling works
well for APIs (like GitHub's REST API) that do not support push.

For true real-time push you would instead open a persistent connection using one of:

| Mechanism | Qt class | Suitable for |
|-----------|----------|--------------|
| WebSocket | `QWebSocket` (Qt WebSockets module) | Bidirectional, low-latency push |
| Server-Sent Events (SSE) | Plain `QNetworkAccessManager` + chunked read | Server → client event streams |
| MQTT | `QMqttClient` (Qt MQTT module) | IoT / pub-sub messaging |

Implementing a WebSocket-driven live model (connecting to a service like GitHub's GraphQL
subscriptions or a custom backend) is covered in Book 2 of the series.
