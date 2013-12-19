/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the Scene Graph Playground module of the Qt Toolkit.
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

#ifndef QSGPOLYGON_H
#define QSGPOLYGON_H

#include <QtQuick/QQuickItem>

#include "qsgtriangleset.h"

class QSGPolygon : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QSGTriangleSet *triangleSet READ triangleSet WRITE setTriangleSet NOTIFY triangleSetChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
public:
    QSGPolygon();

    QSGTriangleSet *triangleSet() const { return m_triangleSet; }
    QColor color() const { return m_color; }

protected:
    QSGNode *updatePaintNode(QSGNode *, UpdatePaintNodeData *);

signals:
    void triangleSetChanged(QSGTriangleSet *set);
    void colorChanged(const QColor &color);

public slots:
    void setTriangleSet(QSGTriangleSet *set);
    void setColor(const QColor &color);
    void changed();
    void shrinkToFit();
    virtual void saveQml(QTextStream &out, QPointF offset = QPointF());

private:
    QSGTriangleSet *m_triangleSet;
    QColor m_color;

    uint m_colorWasChanged : 1;
    uint m_triangleSetWasChanged : 1;
};

QML_DECLARE_TYPE(QSGPolygon)

#endif
