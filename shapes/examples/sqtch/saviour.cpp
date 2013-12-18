#include "saviour.h"
#include "QFile"
#include "QTextStream"
//#include <QQuickRectangle>

Saviour::Saviour(QObject *parent) :
    QObject(parent)
{
}

void Saviour::setUrl(QUrl arg)
{
    if (m_url != arg) {
        m_url = arg;
        emit urlChanged(arg);
    }
}

void Saviour::save(QQuickItem *item)
{
    qDebug() << Q_FUNC_INFO << item;
    QFile file(m_url.toLocalFile());
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "failed to open" << m_url << "for writing";
        return;
    }
    QTextStream out(&file);

    out << "import QtQuick 2.3\n";
    out << "import QtQuick.Controls 1.1\n";
    out << "import Qt.labs.shapes 1.0\n\n";
    out << "Rectangle {\n";
    out << "   color: \"lightblue\"\n";

    QList<QQuickItem*> children = item->childItems();
    qDebug() << "found children " << children << children.length();
    foreach (QQuickItem* child, children)
        saveDeeper(out, child, 0, 0);
    out << "}\n";
    qDebug() << "\n";
}

void Saviour::saveDeeper(QTextStream &out, QQuickItem *item, qreal dx, qreal dy)
{
    QString qmlName = item->property("qmlName").toString();
    qDebug() << Q_FUNC_INFO << qmlName << item << dx << dy;
    if (qmlName == "DragHandle")
        return;
    if (qmlName != "Item")
        item->saveQml(out, QPointF(dx, dy));
    else
        foreach (QQuickItem* child, item->childItems())
            saveDeeper(out, child, dx + item->x(), dy + item->y());
}
