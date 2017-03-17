#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("Othy Software");
    app.setApplicationName("SW DiceRoller");
    app.setApplicationVersion("1.0.0");
    //app.setWindowIcon(QIcon("diceroller.icns"));
    //app.setWindowIcon(QIcon("qrc:/icons/sw_diceroller.png"));

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    //
    //qInfo("" + engine.offlineStoragePath().toLatin1());
    //

    return app.exec();
}
