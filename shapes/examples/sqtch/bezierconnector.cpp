/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the demonstration applications of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia.  For licensing terms and
** conditions see http://qt.digia.com/licensing.  For further information
** use the contact form at http://qt.digia.com/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Digia gives you certain additional
** rights.  These rights are described in the Digia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "bezierconnector.h"

#include <QtQuick/qsgnode.h>
#include <QtQuick/qsgflatcolormaterial.h>

//! [1]
BezierConnector::BezierConnector(QQuickItem *parent)
    : QQuickItem(parent)
    , m_p1(0, 0)
    , m_p2(1, 0)
    , m_p3(0, 1)
    , m_p4(1, 1)
    , m_segmentCount(32)
    , m_item1(0)
    , m_item2(0)
{
    setFlag(ItemHasContents, true);
}
//! [1]

//! [2]
BezierConnector::~BezierConnector()
{
}
//! [2]

//! [3]
void BezierConnector::setP1(const QPointF &p)
{
    if (p == m_p1)
        return;

    m_p1 = p;
    emit p1Changed(p);
    update();
}
//! [3]

void BezierConnector::setP2(const QPointF &p)
{
    if (p == m_p2)
        return;

    m_p2 = p;
    emit p2Changed(p);
    update();
}

void BezierConnector::setP3(const QPointF &p)
{
    if (p == m_p3)
        return;

    m_p3 = p;
    emit p3Changed(p);
    update();
}

void BezierConnector::setP4(const QPointF &p)
{
    if (p == m_p4)
        return;

    m_p4 = p;
    emit p4Changed(p);
    update();
}

void BezierConnector::setSegmentCount(int count)
{
    if (m_segmentCount == count)
        return;

    m_segmentCount = count;
    emit segmentCountChanged(count);
    update();
}

void BezierConnector::setItem1(QQuickItem * arg)
{
    if (m_item1 != arg) {
        m_item1 = arg;

        connect(arg, SIGNAL(xChanged()), this, SLOT(updateShit()));
        connect(arg, SIGNAL(yChanged()), this, SLOT(updateShit()));
        connect(arg, SIGNAL(heightChanged()), this, SLOT(updateShit()));
        connect(arg, SIGNAL(widthChanged()), this, SLOT(updateShit()));

        emit item1Changed(arg);
        updateShit();
    }
}

void BezierConnector::setItem2(QQuickItem * arg)
{
    if (m_item2 != arg) {
        m_item2 = arg;

        connect(arg, SIGNAL(xChanged()), this, SLOT(updateShit()));
        connect(arg, SIGNAL(yChanged()), this, SLOT(updateShit()));
        connect(arg, SIGNAL(heightChanged()), this, SLOT(updateShit()));
        connect(arg, SIGNAL(widthChanged()), this, SLOT(updateShit()));

        emit item2Changed(arg);
        updateShit();
    }
}


void BezierConnector::updateShit()
{
    if (!m_item1)
        return;
    QPointF c1 = m_item1->mapToItem(m_item1->parentItem(), m_item1->boundingRect().center());
    setPosition(c1);
    if (m_item2) {
        QPointF c2 = m_item2->mapToItem(m_item2->parentItem(), m_item2->boundingRect().center());
        setSize(QSizeF(c2.x() - c1.x(), c2.y() - c1.y()));
    }
//qDebug() << Q_FUNC_INFO << c1 << width() << height();

//    setP1();
//    setP2(m_item1->mapToItem(m_item1->parentItem(), m_item1->boundingRect().center()));
//    setP3(m_item2->mapToItem(m_item2->parentItem(), m_item2->boundingRect().center()));
//    setP4(m_item2->mapToItem(m_item2->parentItem(), m_item2->boundingRect().center()));


//    setWidth(m_p4.x() - m_p1.x());
//    setHeight(m_p4.y() - m_p1.y());
//    setX(m_p1.x());
//    setY(m_p1.y());
}

//! [4]
QSGNode *BezierConnector::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *)
{
    QSGGeometryNode *node = 0;
    QSGGeometry *geometry = 0;

    if (!oldNode) {
        node = new QSGGeometryNode;
//! [4] //! [5]
        geometry = new QSGGeometry(QSGGeometry::defaultAttributes_Point2D(), m_segmentCount);
        geometry->setLineWidth(2);
        geometry->setDrawingMode(GL_LINE_STRIP);
        node->setGeometry(geometry);
        node->setFlag(QSGNode::OwnsGeometry);
//! [5] //! [6]
        QSGFlatColorMaterial *material = new QSGFlatColorMaterial;
        material->setColor(QColor(0, 0, 0));
        node->setMaterial(material);
        node->setFlag(QSGNode::OwnsMaterial);
//! [6] //! [7]
    } else {
        node = static_cast<QSGGeometryNode *>(oldNode);
        geometry = node->geometry();
        geometry->allocate(m_segmentCount);
    }
//! [7]

//! [8]
    QRectF bounds = boundingRect();
    QSGGeometry::Point2D *vertices = geometry->vertexDataAsPoint2D();
    for (int i = 0; i < m_segmentCount; ++i) {
        qreal t = i / qreal(m_segmentCount - 1);
        qreal invt = 1 - t;

        QPointF pos = invt * invt * invt * m_p1
                    + 3 * invt * invt * t * m_p2
                    + 3 * invt * t * t * m_p3
                    + t * t * t * m_p4;

        float x = bounds.x() + pos.x() * bounds.width();
        float y = bounds.y() + pos.y() * bounds.height();

//        qDebug() << x << y << m_p1 << m_p2 << m_p3 << m_p4;

        vertices[i].set(x, y);
    }
    node->markDirty(QSGNode::DirtyGeometry);
//! [8]


//! [9]
    return node;
}
//! [9]

