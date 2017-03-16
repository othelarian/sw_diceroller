#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    //
    //qInfo("test");
    //qInfo("" + engine.offlineStoragePath().toLatin1());
    //

    return app.exec();
}
