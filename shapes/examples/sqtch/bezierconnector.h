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

#ifndef BEZIERCONNECTOR_H
#define BEZIERCONNECTOR_H

//! [1]
#include <QtQuick/QQuickItem>

class BezierConnector : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QPointF p1 READ p1 WRITE setP1 NOTIFY p1Changed)
    Q_PROPERTY(QPointF p2 READ p2 WRITE setP2 NOTIFY p2Changed)
    Q_PROPERTY(QPointF p3 READ p3 WRITE setP3 NOTIFY p3Changed)
    Q_PROPERTY(QPointF p4 READ p4 WRITE setP4 NOTIFY p4Changed)

    Q_PROPERTY(QQuickItem *item1 WRITE setItem1 READ item1 NOTIFY item1Changed)
    Q_PROPERTY(QQuickItem *item2 WRITE setItem2 READ item2 NOTIFY item2Changed)

    Q_PROPERTY(int segmentCount READ segmentCount WRITE setSegmentCount NOTIFY segmentCountChanged)

public:
    BezierConnector(QQuickItem *parent = 0);
    ~BezierConnector();

//! [2]
    QSGNode *updatePaintNode(QSGNode *, UpdatePaintNodeData *);
//! [2]

    QPointF p1() const { return m_p1; }
    QPointF p2() const { return m_p2; }
    QPointF p3() const { return m_p3; }
    QPointF p4() const { return m_p4; }

    int segmentCount() const { return m_segmentCount; }

    void setP1(const QPointF &p);
    void setP2(const QPointF &p);
    void setP3(const QPointF &p);
    void setP4(const QPointF &p);

    void setSegmentCount(int count);

    QQuickItem * item1() const { return m_item1; }
    QQuickItem * item2() const { return m_item2; }

public slots:
    void setItem1(QQuickItem * arg);
    void setItem2(QQuickItem * arg);
    void updateShit();

signals:
    void p1Changed(const QPointF &p);
    void p2Changed(const QPointF &p);
    void p3Changed(const QPointF &p);
    void p4Changed(const QPointF &p);

    void segmentCountChanged(int count);

    void item1Changed(QQuickItem * arg);
    void item2Changed(QQuickItem * arg);

private:
    QPointF m_p1;
    QPointF m_p2;
    QPointF m_p3;
    QPointF m_p4;

    int m_segmentCount;
    QQuickItem * m_item1;
    QQuickItem * m_item2;
};
//! [1]

#endif // BEZIERCONNECTOR_H
