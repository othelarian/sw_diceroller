import QtQuick 2.0

Row {
    spacing: 1
    property int diceValue
    SWButton {
        btnWidth: 50
        btnValue: "X"
        //
    }
    SWButton {
        btnWidth: 50
        btnValue: "d"+diceValue
        //
    }
    SWButton {
        btnWidth: 50
        btnValue: "W"
        //
    }
}
