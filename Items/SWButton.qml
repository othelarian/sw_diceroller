import QtQuick 2.0

Rectangle {
    property int btnWidth: 45
    property string btnValue : "test"
    property color btnColor: "#3cf"
    function activate() {}
    width: btnWidth
    height: 20
    color: "#3cf"
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: { btnColor = "white" }
        onExited: { btnColor = "#3cf" }
        onClicked: { activate() }
    }
    Rectangle {
        x: 1; y: 1
        width: btnWidth-2; height: 18
        color: btnColor
        Text { anchors.centerIn: parent; text: btnValue }
    }
}
