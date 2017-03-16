import QtQuick 2.0

Item {
    width: 100
    height: 20
    property int spinValue: 1
    function remove() { if (spinValue > 1) spinValue-- }
    function add() { if (spinValue < 30) spinValue++ }
    Row {
        SWButton {
            btnWidth: 20
            btnValue: "-"
            function activate() { remove() }
        }
        TextInput {
            width: 30
            height: 20
            text: spinValue
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 12
            validator: IntValidator{bottom: 1; top: 30;}
        }

        SWButton {
            btnWidth: 20
            btnValue: "+"
            function activate() { add() }
        }

    }
}
