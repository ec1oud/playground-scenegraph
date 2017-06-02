import QtQuick 2.8
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import Qt.labs.handlers 1.0
import Qt.labs.pathitem 1.0

ApplicationWindow {
    visible: true
    title: qsTr("sQtch")
    width: 1000
    height: 800

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
            }
        }
    }

    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal
        Rectangle {
            id: palette
            width: 100

            Rectangle {
                id: rectShape
                width: 50
                height: 50
                z: 10
//                onXChanged: console.log("parent " + parent + " x " + x)
                border.color: "black"
                Drag.active: dragArea.drag.active
                MouseArea {
                    id: dragArea
                    drag.target: rectShape
                    anchors.fill: parent
                }
            }

        }
        DropArea {
            id: canvas
            Layout.fillWidth: true
            onEntered: {
//                console.log("entered " + drag.source + " with parent " + drag.source.parent)
                drag.source.parent = canvas
//                Drag.drop()
            }
            onDropped: console.log("dropped")
//            onContainsDragChanged: console.log("contains drag " + containsDrag)

            PathItem {
                id: jsApiItem
                anchors.fill: parent
                asynchronous: true

                Component.onCompleted: {
                    clearVisualPaths();

                    var path = newPath();
                    var sfp = newStrokeFillParams();
                    sfp.strokeColor = "red";
                    path.lineTo(100, 100);
                    appendVisualPath(path, sfp)

                    path.clear();
                    sfp.clear();
                    sfp.strokeColor = "blue";
                    path.moveTo(100, 0);
                    path.lineTo(0, 100);
                    appendVisualPath(path, sfp)

                    path.clear();
                    sfp.clear();
                    sfp.strokeColor = "red"
                    sfp.strokeWidth = 4;
//                    sfp.fillGradient = refGrad;
                    path.moveTo(10, 40);
                    path.arcTo(40, 40, 0, 10, 60, true, true);
                    appendVisualPath(path, sfp);

                    commitVisualPaths();
                }
            }

            DragHandler {
                id: handler
//                acceptedButtons: Qt.AllButtons
//                acceptedDevices: PointerDevice.Stylus | PointerDevice.Airbrush
                property bool polyStarted: false
                property var path: null
                target: null
                onActiveChanged: {
                    if (!active) {
                        console.log("released button(s) " + point.pressedButtons + " @ " + point.scenePosition)
                        path.lineTo(point.scenePosition.x, point.scenePosition.y)
                        var sfp = jsApiItem.newStrokeFillParams();
                        sfp.strokeColor = "red";
                        jsApiItem.appendVisualPath(path, sfp)
                        jsApiItem.commitVisualPaths();
//                        path.clear()
                        polyStarted = false
                    }
                }
                onPointChanged: {
                    if (point.pressedButtons) {
                        if (!polyStarted) { // pressed but not active yet: didn't get past the drag threshold
                            console.log("pressed button(s) " + point.pressedButtons + " @ " + point.scenePosition)
                            polyStarted = true
                            path = jsApiItem.newPath();
                            path.moveTo(point.scenePosition.x, point.scenePosition.y)
                        } else {
                            console.log("updated button(s) " + point.pressedButtons + " @ " + point.scenePosition)
                            path.lineTo(point.scenePosition.x, point.scenePosition.y);
                        }
                    }
                }
            }
        }
    }
}
