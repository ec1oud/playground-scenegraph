#include <QtGui/QGuiApplication>
#include <QtQml>
#include <QtQuick/QQuickWindow>

int main(int argc, char *argv[])
{
    QGuiApplication  app(argc, argv);
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
