import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: configAbout

    ColumnLayout {
        spacing: 16
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter

        Item { height: 10 }

        // Header Icon & App Name
        ColumnLayout {
            spacing: 6
            Layout.alignment: Qt.AlignHCenter

            // Logo Canvas
            Canvas {
                width: 48
                height: 48
                Layout.alignment: Qt.AlignHCenter
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.scale(width / 24.0, height / 24.0);

                    ctx.strokeStyle = "#00a2ff";
                    ctx.lineWidth = 2.5;
                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";

                    ctx.beginPath();
                    ctx.moveTo(16, 4);
                    ctx.lineTo(7, 9.5);
                    ctx.lineTo(14, 15);
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.moveTo(6, 20);
                    ctx.lineTo(18, 20);
                    ctx.stroke();
                }
            }

            QQC2.Label {
                text: i18n("LeetCode Streak Plasmoid")
                font.pixelSize: 18
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            QQC2.Label {
                text: i18n("Version 1.0.0")
                font.pixelSize: 12
                color: Kirigami.Theme.disabledTextColor
                Layout.alignment: Qt.AlignHCenter
            }
        }

        QQC2.Label {
            text: i18n("A modern glassmorphism desktop widget for KDE Plasma 6 that tracks your LeetCode problem solving streak, daily activity, 14-column activity heatmap grid, and solved problem counts.")
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.maximumWidth: 420
            color: Kirigami.Theme.textColor
            opacity: 0.9
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Kirigami.Theme.disabledTextColor
            opacity: 0.2
        }

        // Developer Credits Card
        Kirigami.FormLayout {
            Layout.fillWidth: true

            QQC2.Label {
                Kirigami.FormData.label: i18n("Developer:")
                text: "xabhishek54"
                font.bold: true
            }

            QQC2.Label {
                Kirigami.FormData.label: i18n("Email:")
                text: "abhishek54yt@gmail.com"
            }

            QQC2.Label {
                Kirigami.FormData.label: i18n("License:")
                text: "GNU General Public License v3.0"
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Kirigami.Theme.disabledTextColor
            opacity: 0.2
        }

        // Links Buttons
        RowLayout {
            spacing: 12
            Layout.alignment: Qt.AlignHCenter

            QQC2.Button {
                text: i18n("GitHub Repository")
                icon.name: "code-context"
                onClicked: Qt.openUrlExternally("https://github.com/xabhishek54/leetcode-streak-plasmoid")
            }

            QQC2.Button {
                text: i18n("Report Issue")
                icon.name: "tools-report-bug"
                onClicked: Qt.openUrlExternally("https://github.com/xabhishek54/leetcode-streak-plasmoid/issues")
            }
        }

        Item { height: 10 }
    }
}
