import QtQuick 2.0

Rectangle {
    property int btnWidth: 70
    property string btnValue : "test"
    property color btnColor: "#3cf"
    function activate() {}
    width: btnWidth
    height: 50
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
        width: btnWidth-2; height: parent.height-2
        color: btnColor
        Text {
            font.pointSize: 16
            anchors.centerIn: parent;
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: btnValue
        }
    }
}
