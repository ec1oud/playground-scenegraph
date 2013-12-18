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
                border.color: "black"
                Drag.active: dragArea.drag.active
                MouseArea {
                    id: dragArea
                    drag.target: rectShape
                    anchors.fill: parent
                }
            }
        }
        Rectangle {
            id: drawingPane
            Layout.fillWidth: true
            DropArea {
                // children of this will all be persisted
                id: canvas
                anchors.fill: parent
            }
            TabletSketchArea {
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
                    poly.triangleSet.finishPathConstruction()
                }
            }
        }
    }

}
