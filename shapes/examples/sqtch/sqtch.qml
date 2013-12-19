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
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import Qt.labs.shapes 1.0
import sQtch 1.0

ApplicationWindow {
    id: root
    visible: true
    title: qsTr("sQtch")
    width: 1000
    height: 800

    property QtObject lastCreated: null
    property Item selectedItem: null
    property var listCreatedObjects: ListModel {}
    property bool acceptableDrop: false

    Saviour { id: saviour }

    FileDialog {
        id: saveDialog
        title: "Save as..."
        folder: "file:///tmp"
        selectExisting: false
        nameFilters: [ "QML files (*.qml)" ]
        onAccepted: {
            console.log("save as " + fileUrl)
            saviour.url = fileUrl
            saviour.save(canvas)
        }
    }

    Action {
        id: revertAction
        text: "Undo"
        shortcut: "Ctrl+Z"
        iconSource: "qrc:/resources/edit-undo.png"
        onTriggered: {
            if (!!listCreatedObjects && listCreatedObjects.count > 0) {
                var object = listCreatedObjects.get(listCreatedObjects.count-1)
                if (object.component)
                    object.component.destroy()
                if (object.area)
                    object.area.destroy()
                listCreatedObjects.remove(listCreatedObjects.count-1)
            }
        }
    }

    property color strokeColor: "brown"
    Action {
        id: strokeAction
        text: "Stroke color"
        iconSource: "qrc:/resources/icon-stroke.png"
        onTriggered: strokeColorDialog.open()
    }

    ColorDialog {
        id: strokeColorDialog
        onAccepted: {
            if (selectedItem && selectedItem.hasOwnProperty("border"))
                selectedItem.border.color = strokeColorDialog.currentColor
            else if (selectedItem && selectedItem.hasOwnProperty("color"))
                selectedItem.color = strokeColorDialog.currentColor
            else
                strokeColor = strokeColorDialog.currentColor
        }
    }

    property color fillColor: "beige"
    Action {
        id: fillAction
        text: "Fill color"
        iconSource: "qrc:/resources/icon-fill.png"
        onTriggered: fillColorDialog.open()
    }

    ColorDialog {
        id: fillColorDialog
        onAccepted: {
            console.log(selectedItem + " accepted fill color " + color + fillColorDialog.color)
            if (selectedItem && selectedItem.hasOwnProperty("color"))
                selectedItem.color = fillColorDialog.currentColor
            else
                fillColor = fillColorDialog.currentColor
        }
    }

    onSelectedItemChanged: if (selectedItem) {
        if (selectedItem.hasOwnProperty("color"))
            fillColorDialog.color = selectedItem.color
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("Save as...")
                onTriggered: saveDialog.open()
            }
            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
            }
        }
        Menu {
            title: qsTr("Edit")
            MenuItem { action: revertAction }
            MenuItem { action: strokeAction }
            MenuItem { action: fillAction }
        }
    }

    toolBar: ToolBar {
        RowLayout {
            ToolButton { action: revertAction }
            ToolButton { action: strokeAction }
            ToolButton { action: fillAction }
        }
    }

    property Component mouseAreaDropped:  Item {
        id: container
        property QtObject comp

        property bool initialUpdate: true
        property bool selected: comp == root.selectedItem

        Component.onCompleted: {
            if (initialUpdate) {
                container.width = comp.implicitWidth
                container.height = comp.implicitHeight
                container.x = comp.x
                container.y = comp.y
                bottomRightHandle.x = container.width - bottomRightHandle.height
                bottomRightHandle.y = container.height - bottomRightHandle.height
                initialUpdate = false
            }
        }

        MouseArea {
            id: mousearea
            anchors.fill: parent
            drag.target: parent
            hoverEnabled: true
            drag.minimumX: 0
            drag.maximumX: dropArea.width - parent.width
            drag.minimumY: 0
            drag.maximumY: dropArea.height - parent.height
            drag.filterChildren: true

            onClicked: root.selectedItem = comp

            Rectangle {
                anchors.fill: parent
                opacity: selected ? 0.5 : 0
                color: "red"
            }
        }

        Binding {
            target: container
            property: "width"
            value: Math.floor(bottomRightHandle.x + bottomRightHandle.height - topLeftHandle.x)
        }

        Binding {
            target: container
            property: "height"
            value: Math.floor(bottomRightHandle.y + bottomRightHandle.height - topLeftHandle.y)
        }

        Binding {
            target: comp
            property: "width"
            value: Math.floor(bottomRightHandle.x + bottomRightHandle.height - topLeftHandle.x)
            when: !initialUpdate
        }

        Binding {
            target: comp
            property: "height"
            value: Math.floor(bottomRightHandle.y + bottomRightHandle.height - topLeftHandle.y)
            when: !initialUpdate
        }

        Binding {
            target: comp
            property: "x"
            value: container.x
            when: !initialUpdate
        }

        Binding {
            target: comp
            property: "y"
            value: container.y
            when: !initialUpdate
        }

        MouseArea {
            id: topLeftHandle
            width: 10
            height: 10
            drag.target: topLeftHandle
            drag.minimumX: 0; drag.minimumY: 0
            drag.maximumX: bottomRightHandle.x - width
            drag.maximumY: bottomRightHandle.y - height
            Rectangle {
                anchors.fill: parent
                visible: container.selected
                border.color: "gray"
            }
        }
        MouseArea {
            id: bottomRightHandle
            width: 10
            height: 10
            drag.target: bottomRightHandle
            drag.minimumX: topLeftHandle.x + width
            drag.minimumY: topLeftHandle.y + height
            Rectangle {
                anchors.fill: parent
                visible: container.selected
                border.color: "gray"
            }
        }
    }

    property Component rectProto: Rectangle {
        implicitWidth: 50
        implicitHeight: 50
        width: implicitWidth
        height: implicitHeight
        border.color: root.strokeColor
        color: root.fillColor
    }

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
            width: 180
            ListView {
                id: listview
                anchors.fill: parent
                anchors.margins: 10
                model: componentModel
                spacing: 20
                delegate:  ColumnLayout {
                    id: column
                    width: listview.width
                    Label {
                        text: name
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Item {
                        id: item
                        width: loader.item.implicitWidth
                        height: loader.item.implicitHeight
                        anchors.horizontalCenter: parent.horizontalCenter
                        Loader {
                            id: loader
                            sourceComponent:  component
                        }
                        MouseArea {
                            id: dragArea
                            anchors.fill: parent
                            onPressed: {
                                lastCreated = component.createObject(item, {"x": item.x, "y": item.y, "Drag.active": true })
                                drag.target = lastCreated
                            }
                            drag.target: lastCreated
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
                    var count = listCreatedObjects.count
                    var area = mouseAreaDropped.createObject(dropArea, {"comp":lastCreated} )
                    if (lastCreated.qmlName == "Rectangle") {
                        lastCreated.color = fillColor
                        lastCreated.border.color = strokeColor
                    }
                    listCreatedObjects.append({ id: count, component: lastCreated, mousearea: area, x: lastCreated.x, y: lastCreated.y});
                }
                onEntered: {
                    lastCreated.parent = canvas
                    acceptableDrop = true
                }
                onExited: {
                    acceptableDrop = false
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: selectedItem = null
                }

                Rectangle {
                    id: canvas
                    z: -2
                    anchors.fill: parent
                    color: parent.containsDrag ?"green": "transparent"
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
                Component {
                    id: bezierConnectorProto

                    BezierConnector { }
                }

                anchors.fill: parent
                property Polygon poly
                property var connector
                property var pressedOver: false
                property real pressedX
                property real pressedY

                onPressed: {
                    for (var i = 0; i < canvas.children.length && !pressedOver; ++i) {
                        var coords = canvas.children[i].mapFromItem(canvas, stylus.x, stylus.y);
//                        console.log("looking at " + canvas.children[i] + " translated stylus coords " + coords.x + "," + coords.y)
                        if (!canvas.children[i].hasOwnProperty("triangleSet"))
                            if (coords.x > 0 && coords.x < canvas.children[i].width && coords.y > 0 && coords.y < canvas.children[i].height)
                                pressedOver = canvas.children[i];
                    }
                    pressedX = stylus.x
                    pressedY = stylus.y
                    console.log("pressed over " + pressedOver)
                    if (pressedOver) {
                        connector = bezierConnectorProto.createObject(canvas,
                            {"item1": pressedOver, z: -10})
                    } else {
                        poly = polySketchProto.createObject(canvas,
                            {"x": 0, "y": 0, z: -10, "width": canvas.width, "height": canvas.height, "color": strokeColor})
                        poly.triangleSet.beginPathConstruction()
                        poly.triangleSet.moveTo(stylus.x, stylus.y)
                    }
                }
                onDragged: {
                    if (pressedOver) {
                        connector.width = stylus.x - pressedX
                        connector.height = stylus.y - pressedY
//                        connector.p3.x = stylus.x
//                        connector.p3.y = stylus.y
//                        connector.p4.x = stylus.x
//                        connector.p4.y = stylus.y
                    } else {
                        poly.triangleSet.lineTo(stylus.x, stylus.y)
                        // finishPathConstruction is a bit expensive because of stroking, so do it less often
                        if (poly.triangleSet.pathElementCount < 50 || poly.triangleSet.pathElementCount%10 == 0)
                            poly.triangleSet.finishPathConstruction()
                    }
                }
                onReleased: {
                    console.log("released")
                    if (pressedOver) {
                        var releasedOver = false
                        for (var i = 0; i < canvas.children.length && !releasedOver; ++i) {
                            var coords = canvas.children[i].mapFromItem(canvas, stylus.x, stylus.y);
    //                        console.log("looking at " + canvas.children[i] + " translated stylus coords " + coords.x + "," + coords.y)
                            if (!canvas.children[i].hasOwnProperty("triangleSet"))
                                if (coords.x > 0 && coords.x < canvas.children[i].width && coords.y > 0 && coords.y < canvas.children[i].height)
                                    releasedOver = canvas.children[i];
                        }
                        if (releasedOver)
                            connector.item2 = releasedOver;
                        else {
                            connector.width = stylus.x - pressedX
                            connector.height = stylus.y - pressedY
//                            connector.p3.x = stylus.x
//                            connector.p3.y = stylus.y
//                            connector.p4.x = stylus.x
//                            connector.p4.y = stylus.y
                        }
                    } else {
                        poly.triangleSet.lineTo(stylus.x, stylus.y)
                        poly.triangleSet.fitCubic()
                        poly.triangleSet.finishPathConstruction()
                        poly.implicitWidth = 50
                        poly.implicitHeight = 50
                        var area = mouseAreaDropped.createObject(dropArea, {"comp":poly} )
                        console.log("made dragger area " + area + " parent " + area.parent)
                    }
                    pressedOver = false
                }
            }
        }
    }
    statusBar: StatusBar {
        Row {
            anchors.fill: parent
            visible: dropArea.containsDrag
            spacing: 10
            Label {
                Layout.preferredWidth: 100
                text: "drag to " + dropArea.drag.x + ", " + dropArea.drag.y
            }
        }
    }

}
