import QtQuick

QtObject {
    id: theme

    // Theme state
    property bool isDark: true

    // Core color palette
    readonly property color accent: "#3b82f6"
    readonly property color accentHover: "#2563eb"
    readonly property color accentPressed: "#1d4ed8"

    readonly property color success: "#10b981"
    readonly property color warning: "#f59e0b"
    readonly property color error: "#ef4444"
    readonly property color info: "#06b6d4"

    // Theme-aware colors with guaranteed updates
    readonly property color background: isDark ? "#0f172a" : "#f8fafc"
    readonly property color surface: isDark ? "#1e293b" : "#ffffff"
    readonly property color surfaceHover: isDark ? "#334155" : "#f1f5f9"
    readonly property color surfacePressed: isDark ? "#475569" : "#e2e8f0"

    readonly property color cardBackground: isDark ? "#1e293b" : "#ffffff"
    readonly property color cardBorder: isDark ? "#334155" : "#e2e8f0"
    readonly property color cardShadow: isDark ? Qt.alpha("#000000", 0.4) : Qt.alpha("#000000", 0.1)

    readonly property color textPrimary: isDark ? "#f1f5f9" : "#1e293b"
    readonly property color textSecondary: isDark ? "#94a3b8" : "#64748b"
    readonly property color textTertiary: isDark ? "#64748b" : "#94a3b8"
    readonly property color textOnAccent: "#ffffff"

    readonly property color border: isDark ? "#334155" : "#cbd5e1"
    readonly property color borderLight: isDark ? "#475569" : "#e2e8f0"

    // Glass effect
    readonly property color glassBackground: isDark ? Qt.alpha("#1e293b", 0.8) : Qt.alpha("#ffffff", 0.8)
    readonly property color glassBorder: isDark ? Qt.alpha("#64748b", 0.2) : Qt.alpha("#334155", 0.2)

    // Animation settings
    readonly property int fastAnimation: 150
    readonly property int normalAnimation: 250
    readonly property int slowAnimation: 350

    function toggleTheme() {
        isDark = !isDark
    }

    function getLanguageColor(language) {
        const colors = {
            "JavaScript": "#f7df1e",
            "Python": "#3776ab",
            "Java": "#ed8b00",
            "C++": "#00599c",
            "C": "#a8b9cc",
            "C#": "#239120",
            "TypeScript": "#3178c6",
            "Go": "#00add8",
            "Rust": "#000000",
            "Swift": "#fa7343",
            "Kotlin": "#7f52ff",
            "Ruby": "#cc342d",
            "PHP": "#777bb4",
            "HTML": "#e34c26",
            "CSS": "#1572b6",
            "Shell": "#89e051",
            "Dart": "#0175c2",
            "Vue": "#4fc08d",
            "React": "#61dafb"
        }
        return colors[language] || textSecondary
    }
}
