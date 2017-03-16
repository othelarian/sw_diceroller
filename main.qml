import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.LocalStorage 2.0
import QtQuick.Controls 2.1

import "Items"

Window {
    visible: true
    width: 480
    height: 800
    title: qsTr("SW diceroller")
    //
    // TODO : check init
    // TODO : keep track of the deck
    // TODO : draw a card
    //
    // properties
    property var swdb
    property int currentcard
    property var deck: []
    // get the dice type from the selector
    function getType() {
        var type = 0;
        switch (diceSelector.currentIndex) {
        case 0: type = 1; break;
        case 1: type = 2; break;
        case 2: type = 3; break;
        case 3: type = 5; break;
        case 4: type = 7; break;
        case 5: type = 9; break;
        case 6: type = 11; break;
        case 7: type = 19; break;
        case 8: type = 99; break;
        }
        return type;
    }
    // shuffle the deck
    function shuffleDeck() {
        var counter = 54, index, tmp
        while (counter > 0) {
            index = Math.floor(Math.random()*counter)
            counter--
            tmp = deck[counter]
            deck[counter] = deck[index]
            deck[index] = tmp
        }
        currentcard = 0;
        swdb.transaction(function(tx) {
            tx.executeSql("DELETE FROM deck;")
            var req = []
            for (var i=0;i<54;i++) req.push("('"+i+"','"+deck[i]+"')")
            tx.executeSql("INSERT INTO deck VALUES"+req.join(',')+";")
            tx.executeSql("UPDATE parameters SET value='0' WHERE name='currentcard';")
        })
    }
    // create the database scheme
    function swdbCreate(db) {
        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE output (value TEXT,time TIMESTAMP);")
            tx.executeSql("CREATE TABLE parameters (name TEXT,value TEXT);")
            tx.executeSql("CREATE TABLE deck (ordre INT,value INT);")
            tx.executeSql("INSERT INTO parameters VALUES('nbdice','1'),('dicetype','3'),('currentcard','-1');")
        });
    }
    // save an ouput insert in the database
    function swdbOutputAdd(value) {
        swdb.transaction(function(tx) {
            tx.executeSql("INSERT INTO output VALUES('"+value+"',CURRENT_TIMESTAMP);")
        })
    }
    // load the localstorage after the init
    Component.onCompleted: {
        // set the deck
        for (var i=0;i<54;i++) deck.push(i)
        // set the localstorage
        swdb = LocalStorage.openDatabaseSync("SWDiceRollerDB","","",1000000,swdbCreate)
        swdb.transaction(function(tx) {
            // get the number of dice
            var rs = tx.executeSql("SELECT value FROM parameters WHERE name='nbdice';")
            nbDiceSpin.value = parseInt(rs.rows.item(0).value)
            // get the dice type
            rs = tx.executeSql("SELECT value FROM parameters WHERE name='dicetype';")
            diceSelector.currentIndex = parseInt(rs.rows.item(0).value)
            // get the deck
            rs = tx.executeSql("SELECT value FROM parameters WHERE name='currentcard';")
            currentcard = parseInt(rs.rows.item(0).value)
            if (currentcard == -1) shuffleDeck()
            //
            //
            // TODO : get the deck
            //
            //var rs = tx.executeSql("SELECT COUNT(*)")
            //
            //
            // get the output
            rs = tx.executeSql("SELECT value FROM output ORDER BY time;")
            for (var i = 0;i<rs.rows.length;i++) {
                outputModel.insert(0,{value: rs.rows.item(i).value})
            }
        })
    }
    // display
    Column {
        id: column
        spacing: 2
        // nb dice
        Row {
            width: 220
            height: 50
            Text {
                text: "nb dice:"
                rightPadding: 10
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 16
            }
            SpinBox {
                id: nbDiceSpin
                value: 1
                validator: IntValidator{bottom: 1; top: 30}
                onValueChanged: {
                    swdb.transaction(function(tx) {
                        tx.executeSql("UPDATE parameters SET value='"+nbDiceSpin.value+"' WHERE name='nbdice';")
                    })
                }
            }
        }
        // dice
        Row {
            spacing: 2
            SWButton {
                btnWidth: 50
                btnValue: "X"
                function activate() {
                    var type = getType()
                    var rep = "roll: ", tt = 0
                    for (var i=0;i<nbDiceSpin.value;i++) {
                        var tmp = Math.round(Math.random() * type)+1; var res = tmp
                        while (tmp == (type+1)) {
                            tmp = Math.round(Math.random() * type)+1; res += tmp
                        }
                        tt += res; rep += res
                        if (i+1 < nbDiceSpin.value) rep += ","
                    }
                    rep += " = "+tt+" ("+nbDiceSpin.value+"d"+(type+1)+")"
                    swdbOutputAdd(rep)
                    outputModel.insert(0,{value: rep})
                }
            }
            ComboBox {
                id: diceSelector
                width: 90
                height: 50
                font.pointSize: 16
                model: ["d2","d3","d4","d6","d8","d10","d12","d20","d100"]
                onActivated: {
                    swdb.transaction(function(tx) {
                        tx.executeSql("UPDATE parameters SET value='"+diceSelector.currentIndex+"' WHERE name='dicetype';")
                    })
                }
            }
            SWButton {
                btnWidth: 50
                btnValue: "R"
                function activate() {
                    var type = getType()
                    var res = Math.round(Math.random() * type)+1
                    var rep = "roll: "+res+" (d"+(type+1)+")"
                    swdbOutputAdd(rep)
                    outputModel.insert(0,{value: rep})
                }
            }
            SWButton {
                btnWidth: 50
                btnValue: "W"
                function activate() {
                    var type = getType()
                    var tmp = Math.round(Math.random() * type)+1; var res = tmp
                    while (tmp == (type+1)) {
                        tmp = Math.round(Math.random() * type)+1; res += tmp
                    }
                    var rep = "roll: "+res+"(wild d"+(type+1)+")"
                    swdbOutputAdd(rep)
                    outputModel.insert(0,{value: rep})
                }
            }
        }
        // buttons
        Row {
            spacing: 2
            SWButton {
                btnValue: "Clear"
                function activate() {
                    outputModel.clear()
                    swdb.transaction(function(tx) {
                        tx.executeSql("DELETE FROM output;")
                    });
                }
            }
            SWButton {
                btnValue: "Card"
                function activate() {
                    //
                    //outputModel.insert(0,{value: "test " + tmp})
                    //
                    //tmp++
                    //
                }
            }
            SWButton {
                btnValue: "Shuffle"
                function activate() { shuffleDeck() }
            }
        }
    }
    // output
    ListModel { id: outputModel }
    ListView {
        width: 320; height: 210
        anchors.top: column.bottom
        anchors.topMargin: 30
        interactive: true
        spacing: 2
        model: outputModel
        delegate: Rectangle {
            width: 320; height: 30
            color: "#3cf"
            Text {
                font.pointSize: 14
                text: value
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
