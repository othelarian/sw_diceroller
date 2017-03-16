import QtQuick 2.0

Item {
    width: 100
    height: 20
    property int spinValue: 1
    function remove() { if (spinValue > 1) spinValue-- }
    function add() { if (spinValue < 30) spinValue++ }
    Row {
        SWButton {
            btnWidth: 50
            btnValue: "-"
            function activate() { remove() }
        }
        TextInput {
            width: 60
            height: 50
            text: spinValue
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            //font.pixelSize: 12
            font.pointSize: 16
            validator: IntValidator{bottom: 1; top: 30;}
        }

        SWButton {
            btnWidth: 50
            btnValue: "+"
            function activate() { add() }
        }

    }
}
