/****************************************************************************
**
** Copyright (C) 2013-2015 Oleg Yadrov
**
** Licensed under the Apache License, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
** http://www.apache.org/licenses/LICENSE-2.0
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
**
****************************************************************************/

import QtQuick
import QtQuick.Effects
import ".."

BaseDialog {
    id: fontSizeDialog
    contentItem: mainContent

    property alias title: titleLabel.text
    property string text
    property int minSize
    property int maxSize
    property int currentSize

    function initialize(parameters) {
        for (var attr in parameters) {
            fontSizeDialog[attr] = parameters[attr]
        }

        fontSizeSlider.value = (currentSize - minSize) / (maxSize - minSize)
    }

    MultiEffect {
        anchors.fill: mainContent
        shadowEnabled: true
        shadowColor: appWindow.colorPalette.dialogShadow
        shadowBlur: 1
        blurMax: 30 * settings.pixelDensity
        source: mainContent
    }

    Rectangle {
        id: mainContent
        width: popupWidth
        height: popupHeight
        anchors.centerIn: parent
        color: appWindow.colorPalette.dialogBackground

        Rectangle {
            id: header

            height: 22 * settings.pixelDensity
            anchors.left: parent.left
            anchors.right: parent.right
            color: appWindow.colorPalette.toolBarBackground

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                height: Math.max(1, Math.round(0.8 * settings.pixelDensity))
                color: appWindow.colorPalette.toolBarStripe
            }

            CLabel {
                id: titleLabel
                anchors.fill: parent
                anchors.leftMargin: 5 * settings.pixelDensity
                font.pixelSize: 10 * settings.pixelDensity
            }
        }

        CFlickable {
            id: flickable

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.bottom: footer.top
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            property double margin: 3 * settings.pixelDensity

            leftMargin: margin
            rightMargin: margin
            topMargin: margin
            bottomMargin: margin

            contentWidth: width - margin * 2
            contentHeight: column.height

            Column {
                id: column
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 2 * settings.pixelDensity

                CSlider {
                    id: fontSizeSlider
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                CLabel {
                    id: previewLabel
                    anchors.left: parent.left
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter

                    font.family: settings.font
                    font.pixelSize: minSize + (maxSize - minSize) * fontSizeSlider.value

                    text: fontSizeDialog.text + "\n(%1px)".arg(font.pixelSize)
                }
            }
        }

        CDialogButton {
            anchors.left: parent.left
            anchors.right: footer.left
            anchors.bottom: parent.bottom
            text: qsTr("Cancel")
            onClicked: fontSizeDialog.close()
        }

        CVerticalSeparator {
            id: footer
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
        }

        CDialogButton {
            anchors.left: footer.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            text: qsTr("OK")
            onClicked: fontSizeDialog.process(previewLabel.font.pixelSize)
        }
    }
}
