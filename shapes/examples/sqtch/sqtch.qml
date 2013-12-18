/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is a QtQuick demo of tablet sketching using the scene graph.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.3
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import Qt.labs.shapes 1.0

ApplicationWindow {
    id: root
    visible: true
    title: qsTr("sQtch")
    width: 1000
    height: 800

    property QtObject lastCreated: null
    property var listCreatedObjects: ListModel {}
    property bool acceptableDrop: false

    Action {
        id: revertAction
        shortcut: "Ctrl+Z"
        onTriggered: {
            if (!!listCreatedObjects && listCreatedObjects.count > 0) {
                var object = listCreatedObjects.get(listCreatedObjects.count-1)
                object.component.destroy()
                object.area.destroy()
                listCreatedObjects.remove(listCreatedObjects.count-1)
            }
        }
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
            }
        }
    }

    property Component mouseAreaDropped: MouseArea {
        anchors.fill: parent
        drag.target: parent
//        drag.filterChildren: true
        drag.minimumX: 0
        drag.maximumX: dropArea.width - parent.width
        drag.minimumY: 0
        drag.maximumY: dropArea.height - parent.height
    }

    property Component rectProto: Rectangle { implicitWidth: width; implicitHeight: height; width: 50; height: 50; border.color: "black" }
    property Component button: Button { text: "empty" }
    property Component busyIndicator: BusyIndicator {}
    property Component checkbox: CheckBox { text: "empty" }
    property Component combobox: ComboBox { width: 50 }

    property var componentModel: ListModel {
        Component.onCompleted: {
            append({ name: "Rectangle",     component: rectProto});
            append({ name: "Button",        component: button});
            append({ name: "BusyIndicator", component: busyIndicator});
            append({ name: "CheckBox",      component: checkbox});
            append({ name: "ComboBox",      component: combobox});
        }
    }

    SplitView {
        id: splitView
        anchors.fill: parent

        Item {
            width: 100
            ListView {
                id: listview
                anchors.fill: parent
                anchors.margins: 10
                model: componentModel
                delegate:  ColumnLayout {
                    id: column
                    Label {
                        text: name
                        font.bold: true
                    }
                    Item {
                        id: item
                        width: loader.item.implicitWidth
                        height: loader.item.implicitHeight
                        Loader {
                            id: loader
                            sourceComponent: component
                        }
                        MouseArea {
                            id: dragArea
                            anchors.fill: parent
                            onPressed: {
                                lastCreated = component.createObject(item, {"x": item.x, "y": item.y, "Drag.active": true })
                                drag.target = lastCreated
                            }
                            drag.target: lastCreated
//                            drag.filterChildren: true
                            onReleased: {
                                if (!root.acceptableDrop){
                                    lastCreated.Drag.cancel()
                                    lastCreated.destroy()
                                }else {
                                    lastCreated.Drag.drop()
                                }
                            }
                        }
                        Item {
                            Layout.preferredHeight: 20
                        }
                    }
                }
            }
        }
        Rectangle {
            id: drawingPane
            Layout.fillWidth: true
            DropArea {
                id: dropArea
                anchors.fill: parent
                onDropped: {
                    console.log("dropped")
                    var count = listCreatedObjects.count
                    var area = mouseAreaDropped.createObject(lastCreated, {"x": lastCreated.x, "y": lastCreated.y})
                    listCreatedObjects.append({ id: count, component: lastCreated, mousearea: area, x: lastCreated.x, y: lastCreated.y});
                }
                onEntered: {
                    lastCreated.parent = canvas
                    acceptableDrop = true
                }
                onExited: {
                    acceptableDrop = false
                }
                Rectangle {
                    id: canvas
                    z: -2
                    anchors.fill: parent
                    color: parent.containsDrag ?"green": "lightblue"
                    opacity: parent.containsDrag ? 0.5 : 1
                }
            }
            TabletSketchArea {
                z: 1000
                Component {
                    id: polySketchProto

                    Polygon {
                        color: "black"
                        triangleSet: TriangleSet { }
                    }
                }

                anchors.fill: parent
                property Polygon poly

                onPressed: {
                    poly = polySketchProto.createObject(canvas,
                                                        {"x": 0, "y": 0, "width": canvas.width, "height": canvas.height})
                    poly.triangleSet.beginPathConstruction()
                    poly.triangleSet.moveTo(stylus.x, stylus.y)
                }
                onDragged: {
                    poly.triangleSet.lineTo(stylus.x, stylus.y)
                    // finishPathConstruction is a bit expensive because of stroking, so do it less often
                    if (poly.triangleSet.pathElementCount < 50 || poly.triangleSet.pathElementCount%10 == 0)
                        poly.triangleSet.finishPathConstruction()
                }
                onReleased: {
                    poly.triangleSet.lineTo(stylus.x, stylus.y)
                    poly.triangleSet.fitCubic()
                    poly.triangleSet.finishPathConstruction()
                }
            }
        }
    }
    statusBar: StatusBar {
        RowLayout {
            anchors.fill: parent
            Label {
                Layout.preferredWidth: 100
                text: "dragx: " + dropArea.drag.x
            }
            Label {
                Layout.preferredWidth: 100
                text: "dragy: " + dropArea.drag.y
            }
        }
    }

}
