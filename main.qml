import QtQuick 2.7
import QtQuick.Window 2.2

import "Items"

Window {
    visible: true
    width: 480
    height: 800
    title: qsTr("SW diceroller")
    //
    Column {
        //
        //
        // buttons
        Row {
            //
            SWButton {
                btnValue: "Clear"
            }
            //
            SWButton {
                btnValue: "Card"
            }
            //
            SWButton {
                btnValue: "Shuffle"
            }

            //
        }
        // output
        ListModel {
            id: outputModel
            ListElement { value: "test0" }
            ListElement { value: "test1" }
            ListElement { value: "test2" }
            ListElement { value: "test3" }
            ListElement { value: "test4" }
            ListElement { value: "test5" }
            ListElement { value: "test6" }
            ListElement { value: "test7" }
            ListElement { value: "test8" }
            ListElement { value: "test9" }
            ListElement { value: "test" }
            ListElement { value: "test" }
            ListElement { value: "test" }
        }
        ListView {
            width: 320; height: 170
            interactive: true
            spacing: 2
            model: outputModel
            delegate: Rectangle {
                width: 320; height: 18
                color: "#3cf"
                Text { text: value }
            }
        }
    }
}
