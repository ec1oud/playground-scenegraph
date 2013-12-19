import QtQuick 2.3
import Qt.labs.shapes 1.0

Polygon {
    color: "black"
    triangleSet: TriangleSet {
        Component.onCompleted: {
            beginPathConstruction()
            moveTo(0, 0)
            lineTo(50, 50)
            finishPathConstruction()
        }
    }
}
