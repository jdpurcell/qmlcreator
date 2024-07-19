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
import QtQuick.Controls
import QtQuick.Layouts
import ProjectManager
import "../components"

BlankScreen {
    id: projectsScreen

    readonly property Component editorScreenComponent :
        Qt.createComponent(Qt.resolvedUrl("EditorScreen.qml"),
                           Component.PreferSynchronous);
    readonly property Component filesScreenComponent :
        Qt.createComponent(Qt.resolvedUrl("FilesScreen.qml"),
                           Component.PreferSynchronous);
    property string subPath : ""

    StackView.onStatusChanged: {
        if (StackView.status === StackView.Activating) {
            ProjectManager.subDir = projectsScreen.subPath
            listView.model = ProjectManager.files()
        }
    }

    function getDirName(path) {
        var dirname = ""
        var dirs = path.split("/")
        if(dirs.length > 0) {
            dirname = dirs[dirs.length - 1]
        } else {
            dirname = ""
        }
        return dirname
    }


    CListView {
        id: listView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: toolBar.height

        delegate: CFileButton {
            width: listView.width
            text: modelData.name
            removeButtonVisible: modelData.name !== "main.qml"
            isDir: modelData.isDir

            onClicked: {
                var newScreen = null;

                while (rightView.depth > 1) {
                    rightView.pop()
                }

                if (modelData.isDir) {
                    newScreen =
                            filesScreenComponent.createObject(leftView, {
                                                                  subPath: subPath + "/" + modelData.name
                                                              });
                    leftView.push(newScreen)
                } else {
                    newScreen =
                            editorScreenComponent.createObject(rightView,
                                                               {
                                                                   fileName : modelData.name,
                                                               });
                    rightView.push(newScreen)
                }

            }

            onRemoveClicked: {
                var parameters = {
                    title: qsTr("Delete the file"),
                    text: qsTr("Are you sure you want to delete \"%1\"?").arg(modelData.name)
                }

                var callback = function(value)
                {
                    if (value)
                    {
                        ProjectManager.removeFile(modelData.name)
                        listView.model = ProjectManager.files()
                    }
                }

                dialog.open(dialog.types.confirmation, parameters, callback)
            }
        }
    }

    CToolBar {
        id: toolBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        RowLayout {
            anchors.fill: parent
            spacing: 0

            CBackButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: subPath == "" ? ProjectManager.projectName : getDirName(subPath)
            }

            CToolButton {
                Layout.fillHeight: true
                icon: "\uf067"
                tooltipText: qsTr("New...")
                onClicked: newContextMenu.open()
            }
        }
    }

    Menu {
        id: newContextMenu
        x: parent.width - width
        y: toolBar.height
        MenuItem {
            text: qsTr("New file...")
            onTriggered: {
                var parameters = {
                    title: qsTr("New file")
                }

                var callback = function(value)
                {
                    ProjectManager.createFile(value.fileName, value.fileExtension)
                    listView.model = ProjectManager.files()
                }

                dialog.open(dialog.types.newFile, parameters, callback)
            }
        }

        MenuItem {
            text: qsTr("New directory...")
            onTriggered: {
                var parameters = {
                    title: qsTr("New directory")
                }

                var callback = function(value)
                {
                    ProjectManager.createDir(value.dirName)
                    listView.model = ProjectManager.files()
                }

                dialog.open(dialog.types.newDir, parameters, callback)
            }
        }
    }

    CToolBarBlur {
        sourceItem: listView
    }
}
