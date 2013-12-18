#ifndef SAVIOUR_H
#define SAVIOUR_H

#include <QObject>
#include <QQuickItem>

class Saviour : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)

public:
    explicit Saviour(QObject *parent = 0);
    QUrl url() const { return m_url; }

signals:
    void urlChanged(QUrl arg);

public slots:
    void setUrl(QUrl arg);
    void save(QQuickItem *item);

private:
    void saveDeeper(QTextStream &out, QQuickItem *item, qreal dx, qreal dy);

    QUrl m_url;
};

#endif // SAVIOUR_H
