#include <QtWidgets/QApplication>
#include <QtQml>
#include <QtQuick/QQuickWindow>
#include "bezierconnector.h"
#include "saviour.h"

int main(int argc, char *argv[])
{
    QApplication  app(argc, argv);
    qmlRegisterType<Saviour>("sQtch", 1, 0, "Saviour");
    qmlRegisterType<BezierConnector>("sQtch", 1, 0, "BezierConnector");
    QQmlApplicationEngine engine(QUrl("qrc:/sqtch.qml"));
    QObject *topLevel = engine.rootObjects().value(0);
    QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
    if ( !window ) {
        qWarning("Error: Your root item has to be a Window.");
        return -1;
    }
    window->show();
    return app.exec();
}
