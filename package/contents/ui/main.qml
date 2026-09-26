import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // Disable default plasmoid background so our custom theme card is used
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    preferredRepresentation: fullRepresentation

    // State properties
    property string statusText: i18n("Demo View • Set username in Settings")
    property int currentStreak: 12
    property int totalSolved: 147
    property int activeDaysCount: 87
    property bool solvedToday: true
    property var gridData: []
    property bool isLoading: false
    property bool hasError: false
    property bool isDemoMode: false

    // Theme definitions catalog
    readonly property var themes: ({
        "midnight": {
            cardBg: "#12162d",
            cardBorder: "#28335c",
            secondaryBox: "#161b36",
            accentCyan: "#00f5b4",
            accentBlue: "#00a2ff",
            cellInactive: "#1c244b",
            levels: ["#005bbd", "#007fff", "#00aaff", "#00d5ff"]
        },
        "emerald": {
            cardBg: "#0b1c19",
            cardBorder: "#174039",
            secondaryBox: "#102622",
            accentCyan: "#00ff9d",
            accentBlue: "#00e676",
            cellInactive: "#142c26",
            levels: ["#007a48", "#00ab66", "#00e676", "#00ff9d"]
        },
        "sunset": {
            cardBg: "#1f1118",
            cardBorder: "#422030",
            secondaryBox: "#261520",
            accentCyan: "#ff9d00",
            accentBlue: "#ff5500",
            cellInactive: "#2c1724",
            levels: ["#993d00", "#cc5200", "#ff6a00", "#ff9d00"]
        },
        "dracula": {
            cardBg: "#171326",
            cardBorder: "#362854",
            secondaryBox: "#201a36",
            accentCyan: "#ff79c6",
            accentBlue: "#bd93f9",
            cellInactive: "#271f40",
            levels: ["#6272a4", "#8be9fd", "#bd93f9", "#ff79c6"]
        }
    })

    // Currently selected theme object
    readonly property var activeTheme: {
        var key = Plasmoid.configuration.themeStyle || "midnight";
        return themes[key] ? themes[key] : themes["midnight"];
    }

    readonly property color cardBgColor: activeTheme.cardBg
    readonly property color cardBorderColor: activeTheme.cardBorder
    readonly property color secondaryBoxColor: activeTheme.secondaryBox
    readonly property color textPrimary: "#ffffff"
    readonly property color textMuted: "#6c7da4"
    readonly property color accentCyan: activeTheme.accentCyan
    readonly property color accentBlue: activeTheme.accentBlue
    readonly property color cellInactive: activeTheme.cellInactive

    // Timer for periodic data refresh
    Timer {
        id: refreshTimer
        interval: Math.max(5, Plasmoid.configuration.refreshInterval || 30) * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: false
        onTriggered: fetchLeetCodeData()
    }

    Connections {
        target: Plasmoid.configuration
        function onUsernameChanged() { fetchLeetCodeData(); }
        function onRefreshIntervalChanged() {
            refreshTimer.interval = Math.max(5, Plasmoid.configuration.refreshInterval || 30) * 60 * 1000;
            refreshTimer.restart();
        }
    }

    Component.onCompleted: {
        fetchLeetCodeData();
    }

    function formatDateString(d) {
        var y = d.getFullYear();
        var m = String(d.getMonth() + 1).padStart(2, '0');
        var day = String(d.getDate()).padStart(2, '0');
        return y + "-" + m + "-" + day;
    }

    function formatUtcDateString(d) {
        var y = d.getUTCFullYear();
        var m = String(d.getUTCMonth() + 1).padStart(2, '0');
        var day = String(d.getUTCDate()).padStart(2, '0');
        return y + "-" + m + "-" + day;
    }

    function loadDemoData() {
        isDemoMode = true;
        currentStreak = 12;
        totalSolved = 147;
        activeDaysCount = 87;
        solvedToday = true;
        statusText = i18n("Updated just now");

        var now = new Date();
        var dayOfWeek = now.getDay();
        var daysToSunday = (dayOfWeek === 0) ? 0 : (7 - dayOfWeek);
        var totalCells = 56;
        
        var endDate = new Date(now.getTime() + daysToSunday * 86400 * 1000);
        var startDate = new Date(endDate.getTime() - (totalCells - 1) * 86400 * 1000);

        var sampleGrid = [];
        for (var i = 0; i < totalCells; i++) {
            var dayObj = new Date(startDate.getTime() + i * 86400 * 1000);
            var locStr = formatDateString(dayObj);
            
            var lvl = 0;
            var pseudo = (i * 7 + 13) % 17;
            if (pseudo > 11) lvl = 4;
            else if (pseudo > 8) lvl = 3;
            else if (pseudo > 5) lvl = 2;
            else if (pseudo > 3) lvl = 1;

            sampleGrid.push({
                date: locStr,
                count: lvl * 2,
                level: lvl
            });
        }
        gridData = sampleGrid;
    }

    function fetchLeetCodeData() {
        var uname = Plasmoid.configuration.username ? Plasmoid.configuration.username.trim() : "";
        if (!uname) {
            loadDemoData();
            statusText = i18n("Demo View • Set username in Settings");
            return;
        }

        isDemoMode = false;
        isLoading = true;
        statusText = i18n("Updating...");
        hasError = false;

        // Direct GraphQL request
        var xhr = new XMLHttpRequest();
        var url = "https://leetcode.com/graphql";
        var query = 'query getUserProfile($username: String!) { matchedUser(username: $username) { username submitStatsGlobal { acSubmissionNum { difficulty count } } userCalendar { streak totalActiveDays submissionCalendar } } }';

        xhr.open("POST", url, true);
        xhr.setRequestHeader("Content-Type", "application/json");

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var res = JSON.parse(xhr.responseText);
                        if (res.data && res.data.matchedUser) {
                            isLoading = false;
                            parseUserData(res.data.matchedUser);
                            return;
                        }
                    } catch (e) {}
                }
                // Fallback to Alfa LeetCode API if direct query blocked
                fetchFallbackData(uname);
            }
        };

        xhr.send(JSON.stringify({ query: query, variables: { username: uname } }));
    }

    function fetchFallbackData(uname) {
        var xhr1 = new XMLHttpRequest();
        xhr1.open("GET", "https://alfa-leetcode-api.onrender.com/userProfile/" + uname, true);
        xhr1.onreadystatechange = function() {
            if (xhr1.readyState === XMLHttpRequest.DONE) {
                if (xhr1.status === 200) {
                    try {
                        var profile = JSON.parse(xhr1.responseText);
                        if (profile.totalSolved !== undefined) {
                            totalSolved = profile.totalSolved;
                        }
                    } catch(e) {}
                }
                fetchFallbackCalendar(uname);
            }
        };
        xhr1.send();
    }

    function fetchFallbackCalendar(uname) {
        var xhr2 = new XMLHttpRequest();
        xhr2.open("GET", "https://alfa-leetcode-api.onrender.com/" + uname + "/calendar", true);
        xhr2.onreadystatechange = function() {
            if (xhr2.readyState === XMLHttpRequest.DONE) {
                isLoading = false;
                if (xhr2.status === 200) {
                    try {
                        var cal = JSON.parse(xhr2.responseText);
                        currentStreak = cal.streak || 0;
                        activeDaysCount = cal.totalActiveDays || 0;
                        
                        var subMap = {};
                        if (cal.submissionCalendar) {
                            var parsedCal = typeof cal.submissionCalendar === "string" 
                                            ? JSON.parse(cal.submissionCalendar) 
                                            : cal.submissionCalendar;
                            for (var tsKey in parsedCal) {
                                var tsSec = parseInt(tsKey, 10);
                                if (!isNaN(tsSec)) {
                                    var count = parsedCal[tsKey];
                                    var dateObj = new Date(tsSec * 1000);
                                    subMap[formatDateString(dateObj)] = Math.max(subMap[formatDateString(dateObj)] || 0, count);
                                    subMap[formatUtcDateString(dateObj)] = Math.max(subMap[formatUtcDateString(dateObj)] || 0, count);
                                }
                            }
                        }
                        buildGridAndStatus(subMap);
                    } catch(e) {
                        hasError = true;
                        statusText = i18n("Error parsing LeetCode data");
                    }
                } else {
                    hasError = true;
                    statusText = i18n("User '%1' not found", uname);
                }
            }
        };
        xhr2.send();
    }

    function parseUserData(user) {
        var solved = 0;
        if (user.submitStatsGlobal && user.submitStatsGlobal.acSubmissionNum) {
            for (var i = 0; i < user.submitStatsGlobal.acSubmissionNum.length; i++) {
                if (user.submitStatsGlobal.acSubmissionNum[i].difficulty === "All") {
                    solved = user.submitStatsGlobal.acSubmissionNum[i].count;
                    break;
                }
            }
        }
        totalSolved = solved;

        var cal = user.userCalendar;
        currentStreak = cal ? cal.streak : 0;
        activeDaysCount = cal ? cal.totalActiveDays : 0;

        var subMap = {};
        if (cal && cal.submissionCalendar) {
            try {
                var parsedCal = JSON.parse(cal.submissionCalendar);
                for (var tsKey in parsedCal) {
                    var tsSec = parseInt(tsKey, 10);
                    if (!isNaN(tsSec)) {
                        var count = parsedCal[tsKey];
                        var dateObj = new Date(tsSec * 1000);
                        subMap[formatDateString(dateObj)] = Math.max(subMap[formatDateString(dateObj)] || 0, count);
                        subMap[formatUtcDateString(dateObj)] = Math.max(subMap[formatUtcDateString(dateObj)] || 0, count);
                    }
                }
            } catch (err) {}
        }
        buildGridAndStatus(subMap);
    }

    function calculateCurrentStreak(subMap) {
        var now = new Date();
        var today = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 12, 0, 0);
        var yesterday = new Date(today.getTime() - 86400 * 1000);

        function hasSub(dObj) {
            var locStr = formatDateString(dObj);
            var utcStr = formatUtcDateString(dObj);
            return (subMap[locStr] || 0) > 0 || (subMap[utcStr] || 0) > 0;
        }

        var solvedToday = hasSub(today);
        var solvedYesterday = hasSub(yesterday);

        // If no submissions today and no submissions yesterday, streak is broken (0)
        if (!solvedToday && !solvedYesterday) {
            return 0;
        }

        var streak = 0;
        var check = solvedToday ? today : yesterday;

        while (hasSub(check)) {
            streak++;
            check = new Date(check.getTime() - 86400 * 1000);
        }

        return streak;
    }

    function buildGridAndStatus(subMap) {
        var now = new Date();
        var todayLoc = formatDateString(now);
        var todayUtc = formatUtcDateString(now);
        var countToday = Math.max(subMap[todayLoc] || 0, subMap[todayUtc] || 0);
        solvedToday = countToday > 0;

        // Calculate actual streak dynamically from subMap
        currentStreak = calculateCurrentStreak(subMap);

        // Calculate grid starting on a Monday, ending on Sunday (56 days = 14 cols x 4 rows)
        var dayOfWeek = now.getDay(); // 0=Sun, 1=Mon, ..., 6=Sat
        var daysToSunday = (dayOfWeek === 0) ? 0 : (7 - dayOfWeek);
        var totalCells = 56;
        
        var endDate = new Date(now.getTime() + daysToSunday * 86400 * 1000);
        var startDate = new Date(endDate.getTime() - (totalCells - 1) * 86400 * 1000);

        var newGrid = [];
        for (var i = 0; i < totalCells; i++) {
            var dayObj = new Date(startDate.getTime() + i * 86400 * 1000);
            var locDStr = formatDateString(dayObj);
            var utcDStr = formatUtcDateString(dayObj);
            var dayCount = Math.max(subMap[locDStr] || 0, subMap[utcDStr] || 0);
            
            var level = 0;
            if (dayCount >= 8) level = 4;
            else if (dayCount >= 5) level = 3;
            else if (dayCount >= 3) level = 2;
            else if (dayCount >= 1) level = 1;

            newGrid.push({
                date: locDStr,
                count: dayCount,
                level: level
            });
        }

        gridData = newGrid;
        var nowTimeStr = Qt.formatTime(new Date(), "hh:mm");
        statusText = i18n("Updated at %1", nowTimeStr);
    }

    // Panel icon representation
    compactRepresentation: Component {
        Item {
            implicitWidth: Kirigami.Units.iconSizes.medium
            implicitHeight: Kirigami.Units.iconSizes.medium

            MouseArea {
                anchors.fill: parent
                onClicked: root.expanded = !root.expanded
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 3
                PlasmaComponents.Label {
                    text: "🔥"
                    font.pixelSize: 14
                }
                PlasmaComponents.Label {
                    text: root.currentStreak.toString()
                    font.bold: true
                    font.pixelSize: 12
                    color: root.accentCyan
                }
            }
        }
    }

    // Full desktop representation matching active theme
    fullRepresentation: Component {
        Rectangle {
            id: mainCard
            implicitWidth: 320
            implicitHeight: 285
            Layout.minimumWidth: 280
            Layout.minimumHeight: 260

            radius: 18
            color: Qt.rgba(cardBgColor.r, cardBgColor.g, cardBgColor.b, 
                           Plasmoid.configuration.glassOpacity !== undefined ? Plasmoid.configuration.glassOpacity : 0.90)
            border.color: cardBorderColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                // 1. Header: LeetCode Icon + Title + External Link Button
                RowLayout {
                    Layout.fillWidth: true

                    // LeetCode Logo Canvas
                    Canvas {
                        id: logoCanvas
                        implicitWidth: 20
                        implicitHeight: 20
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.scale(width / 24.0, height / 24.0);

                            ctx.strokeStyle = "#ffffff";
                            ctx.lineWidth = 2.8;
                            ctx.lineCap = "round";
                            ctx.lineJoin = "round";

                            // Upper angled stroke
                            ctx.beginPath();
                            ctx.moveTo(16, 4);
                            ctx.lineTo(7, 9.5);
                            ctx.lineTo(14, 15);
                            ctx.stroke();

                            // Lower horizontal stroke
                            ctx.beginPath();
                            ctx.moveTo(6, 20);
                            ctx.lineTo(18, 20);
                            ctx.stroke();
                        }
                    }

                    PlasmaComponents.Label {
                        text: "LEETCODE"
                        font.bold: true
                        font.pixelSize: 13
                        font.letterSpacing: 2.0
                        color: textPrimary
                    }

                    Item { Layout.fillWidth: true }

                    // Link Icon Button
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 8
                        color: linkMouse.containsMouse ? Qt.lighter(secondaryBoxColor, 1.2) : secondaryBoxColor
                        border.color: cardBorderColor
                        border.width: 1

                        Canvas {
                            anchors.centerIn: parent
                            width: 12
                            height: 12
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.scale(width / 16.0, height / 16.0);
                                ctx.strokeStyle = accentBlue;
                                ctx.lineWidth = 2.0;
                                ctx.lineCap = "round";
                                ctx.lineJoin = "round";

                                // Square box
                                ctx.beginPath();
                                ctx.moveTo(11, 8);
                                ctx.lineTo(11, 13);
                                ctx.lineTo(3, 13);
                                ctx.lineTo(3, 5);
                                ctx.lineTo(8, 5);
                                ctx.stroke();

                                // External arrow
                                ctx.beginPath();
                                ctx.moveTo(8, 3);
                                ctx.lineTo(14, 3);
                                ctx.lineTo(14, 9);
                                ctx.moveTo(14, 3);
                                ctx.lineTo(7, 10);
                                ctx.stroke();
                            }
                        }

                        MouseArea {
                            id: linkMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var uname = Plasmoid.configuration.username ? Plasmoid.configuration.username.trim() : "";
                                if (uname) {
                                    Qt.openUrlExternally("https://leetcode.com/u/" + uname);
                                } else if (typeof Plasmoid.action === "function" && Plasmoid.action("configure")) {
                                    Plasmoid.action("configure").trigger();
                                }
                            }
                        }
                    }
                }

                // 2. Streak Counter & Today Badge Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // Streak Display
                    RowLayout {
                        spacing: 8

                        PlasmaComponents.Label {
                            text: "🔥"
                            font.pixelSize: 32
                        }

                        ColumnLayout {
                            spacing: -3
                            PlasmaComponents.Label {
                                text: root.currentStreak.toString()
                                font.bold: true
                                font.pixelSize: 32
                                color: textPrimary
                            }
                            PlasmaComponents.Label {
                                text: i18n("DAY STREAK")
                                font.pixelSize: 9
                                font.bold: true
                                font.letterSpacing: 1.2
                                color: textMuted
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Today Status Badge
                    Rectangle {
                        color: root.solvedToday ? Qt.rgba(accentCyan.r, accentCyan.g, accentCyan.b, 0.15) : secondaryBoxColor
                        border.color: root.solvedToday ? accentCyan : cardBorderColor
                        border.width: 1
                        radius: 16
                        implicitWidth: todayLayout.implicitWidth + 20
                        implicitHeight: 32

                        RowLayout {
                            id: todayLayout
                            anchors.centerIn: parent
                            spacing: 6

                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                color: root.solvedToday ? accentCyan : Qt.darker(cellInactive, 1.2)

                                PlasmaComponents.Label {
                                    anchors.centerIn: parent
                                    text: root.solvedToday ? "✓" : "!"
                                    font.bold: true
                                    font.pixelSize: 11
                                    color: root.solvedToday ? "#0b2029" : textMuted
                                }
                            }

                            PlasmaComponents.Label {
                                text: i18n("TODAY")
                                font.bold: true
                                font.pixelSize: 10
                                font.letterSpacing: 1.0
                                color: root.solvedToday ? accentCyan : textMuted
                            }
                        }
                    }
                }

                // 3. Activity Heatmap Grid (14 columns x 4 rows)
                ColumnLayout {
                    visible: Plasmoid.configuration.showActivityGrid !== false
                    Layout.fillWidth: true
                    spacing: 6

                    // Grid matrix
                    GridLayout {
                        id: gridMatrix
                        columns: 14
                        columnSpacing: 4
                        rowSpacing: 4
                        Layout.alignment: Qt.AlignHCenter

                        Repeater {
                            model: root.gridData

                            Rectangle {
                                required property var modelData
                                required property int index

                                width: 12
                                height: 12
                                radius: 3

                                color: {
                                    var lvl = modelData ? modelData.level : 0;
                                    if (lvl === 0) return cellInactive;
                                    var levelsArr = activeTheme.levels;
                                    if (lvl >= 1 && lvl <= 4) return levelsArr[lvl - 1];
                                    return levelsArr[3];
                                }

                                QQC2.ToolTip.visible: cellMouse.containsMouse && modelData !== undefined && modelData !== null
                                QQC2.ToolTip.text: modelData ? (modelData.date + ": " + modelData.count + " submission" + (modelData.count === 1 ? "" : "s")) : ""

                                MouseArea {
                                    id: cellMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                }
                            }
                        }
                    }

                    // Days of week horizontal labels below grid
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Repeater {
                            model: [i18n("Mon"), i18n("Tue"), i18n("Wed"), i18n("Thu"), i18n("Fri"), i18n("Sat"), i18n("Sun")]

                            PlasmaComponents.Label {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: modelData
                                font.pixelSize: 10
                                color: textMuted
                            }
                        }
                    }
                }

                // 4. Statistics Card (Solved & Active Days)
                Rectangle {
                    visible: Plasmoid.configuration.showSolvedTotals !== false
                    Layout.fillWidth: true
                    height: 56
                    radius: 14
                    color: secondaryBoxColor
                    border.color: cardBorderColor
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8

                        // Solved Column
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 10

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: Qt.rgba(accentBlue.r, accentBlue.g, accentBlue.b, 0.20)

                                PlasmaComponents.Label {
                                    anchors.centerIn: parent
                                    text: "✓"
                                    font.bold: true
                                    font.pixelSize: 14
                                    color: accentBlue
                                }
                            }

                            ColumnLayout {
                                spacing: -3
                                PlasmaComponents.Label {
                                    text: root.totalSolved.toString()
                                    font.bold: true
                                    font.pixelSize: 18
                                    color: textPrimary
                                }
                                PlasmaComponents.Label {
                                    text: i18n("SOLVED")
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.letterSpacing: 1.0
                                    color: textMuted
                                }
                            }
                        }

                        // Divider Line
                        Rectangle {
                            width: 1
                            height: 28
                            color: cardBorderColor
                        }

                        // Active Days Column
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 10

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: Qt.rgba(accentBlue.r, accentBlue.g, accentBlue.b, 0.20)

                                Canvas {
                                    anchors.centerIn: parent
                                    width: 14
                                    height: 14
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();
                                        ctx.strokeStyle = accentBlue;
                                        ctx.lineWidth = 1.8;
                                        ctx.lineCap = "round";
                                        ctx.lineJoin = "round";

                                        ctx.strokeRect(2, 4, 10, 8);
                                        ctx.beginPath();
                                        ctx.moveTo(4, 2); ctx.lineTo(4, 4);
                                        ctx.moveTo(10, 2); ctx.lineTo(10, 4);
                                        ctx.moveTo(2, 7); ctx.lineTo(12, 7);
                                        ctx.stroke();
                                    }
                                }
                            }

                            ColumnLayout {
                                spacing: -3
                                PlasmaComponents.Label {
                                    text: root.activeDaysCount.toString()
                                    font.bold: true
                                    font.pixelSize: 18
                                    color: textPrimary
                                }
                                PlasmaComponents.Label {
                                    text: i18n("ACTIVE DAYS")
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.letterSpacing: 1.0
                                    color: textMuted
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // 5. Status Footer
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        width: 7
                        height: 7
                        radius: 3.5
                        color: root.hasError ? "#ff5555" : accentCyan
                    }

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        text: root.statusText
                        font.pixelSize: 10
                        color: root.hasError ? "#ff5555" : textMuted
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
