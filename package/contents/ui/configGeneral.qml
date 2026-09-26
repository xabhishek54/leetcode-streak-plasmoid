import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: configGeneral

    property alias cfg_themeStyle: themeComboBox.currentValue
    property alias cfg_username: usernameTextField.text
    property alias cfg_refreshInterval: refreshSpinBox.value
    property alias cfg_glassOpacity: glassOpacitySlider.value
    property alias cfg_useCustomAccentColor: customAccentCheckBox.checked
    property alias cfg_customAccentColor: accentColorField.text
    property alias cfg_showActivityGrid: showGridCheckBox.checked
    property alias cfg_showSolvedTotals: showTotalsCheckBox.checked

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: themeComboBox
            Kirigami.FormData.label: i18n("Color Theme:")
            textRole: "text"
            valueRole: "value"
            model: [
                { text: i18n("Midnight Neon (Default Blue)"), value: "midnight" },
                { text: i18n("Emerald Cyber (Matrix Green)"), value: "emerald" },
                { text: i18n("Sunset Fire (Amber Orange)"), value: "sunset" },
                { text: i18n("Dracula Violet (Purple Neon)"), value: "dracula" }
            ]
        }

        QQC2.TextField {
            id: usernameTextField
            Kirigami.FormData.label: i18n("LeetCode Username:")
            placeholderText: i18n("e.g. lee215")
        }

        QQC2.SpinBox {
            id: refreshSpinBox
            Kirigami.FormData.label: i18n("Refresh Interval (minutes):")
            from: 5
            to: 1440
            stepSize: 5
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Glass Opacity:")
            QQC2.Slider {
                id: glassOpacitySlider
                from: 0.1
                to: 1.0
                stepSize: 0.05
                Layout.fillWidth: true
            }
            QQC2.Label {
                text: Math.round(glassOpacitySlider.value * 100) + "%"
            }
        }

        QQC2.CheckBox {
            id: showGridCheckBox
            Kirigami.FormData.label: i18n("Activity Grid:")
            text: i18n("Show 12-week activity heatmap")
        }

        QQC2.CheckBox {
            id: showTotalsCheckBox
            Kirigami.FormData.label: i18n("Statistics:")
            text: i18n("Show solved count and active days")
        }

        QQC2.CheckBox {
            id: customAccentCheckBox
            Kirigami.FormData.label: i18n("Accent Color:")
            text: i18n("Use custom accent color instead of Plasma theme")
        }

        QQC2.TextField {
            id: accentColorField
            Kirigami.FormData.label: i18n("Custom Accent Hex:")
            placeholderText: "#8839ef"
            enabled: customAccentCheckBox.checked
        }
    }
}
