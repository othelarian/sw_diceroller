import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.LocalStorage 2.0
import QtQuick.Controls 2.1

Window {
    id: window
    visible: true
    width: 480
    minimumWidth: width
    height: 700
    minimumHeight: height
    title: qsTr("SW DiceRoller")
    // properties
    property var swdb
    property int outOrder
    property int currentcard
    property var deck: []
    // get the dice type from the selector
    function getType() {
        var type = 0;
        switch (diceSelector.currentIndex) {
        case 0: type = 2; break;
        case 1: type = 3; break;
        case 2: type = 4; break;
        case 3: type = 6; break;
        case 4: type = 8; break;
        case 5: type = 10; break;
        case 6: type = 12; break;
        case 7: type = 20; break;
        case 8: type = 100; break;
        }
        return type;
    }
    // roll one die
    function rollDice() {
        var type = getType()
        var tmp = Math.floor(Math.random()*type)+1; var res = tmp
        while (wildCheck.checked && tmp === type) {
            tmp = Math.floor(Math.random()*type)+1; res += tmp
        }
        return res
    }
    // shuffle the deck
    function shuffleDeck() {
        var index, tmp
        for (var i=53;i>0;i--) {
            index = Math.floor(Math.random()*i)
            tmp = deck[i]
            deck[i] = deck[index]
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
            tx.executeSql("CREATE TABLE output (value TEXT,outorder INT);")
            tx.executeSql("CREATE TABLE parameters (name TEXT,value TEXT);")
            tx.executeSql("CREATE TABLE deck (ordre INT,value INT);")
            var req = "('nbdice','1'),('dicetype','3'),('currentcard','-1'),('bonus','0')"
            req += ",('wild','0'),('outOrder','0')"
            tx.executeSql("INSERT INTO parameters VALUES"+req+";")
        });
        db.changeVersion("","1.0")
    }
    // save an ouput insert in the database
    function swdbOutputAdd(value) {
        swdb.transaction(function(tx) {
            tx.executeSql("INSERT INTO output VALUES('"+value+"',"+outOrder+");")
            outputModel.insert(0,{id: outOrder, value: value})
            outOrder++
            tx.executeSql("UPDATE parameters SET value='"+outOrder+"' WHERE name='outOrder';")
        })
    }
    // load the localstorage after the init
    Component.onCompleted: {
        // set the deck
        var i
        for (i=0;i<54;i++) deck.push(i)
        // set the localstorage
        swdb = LocalStorage.openDatabaseSync("SWDiceRollerDB","1.0","",1000000,swdbCreate)
        swdb.transaction(function(tx) {
            // get the parameters
            var rs = tx.executeSql("SELECT * FROM parameters;")
            for (i=0;i<rs.rows.length;i++) {
                switch (rs.rows.item(i).name) {
                case "nbdice": nbDiceSpin.value = parseInt(rs.rows.item(i).value); break;
                case "bonus": bonusSpin.value = parseInt(rs.rows.item(i).value); break;
                case "dicetype": diceSelector.currentIndex = parseInt(rs.rows.item(i).value); break;
                case "currentcard": currentcard = parseInt(rs.rows.item(i).value); if (currentcard == -1) shuffleDeck(); break;
                case "wild": wildCheck.checked = (rs.rows.item(i).value === "0")? false : true; break;
                case "outOrder": outOrder = parseInt(rs.rows.item(i).value); break;
                }
            }
            // get the deck
            rs = tx.executeSql("SELECT value FROM deck ORDER BY ordre;")
            for (i=0;i<rs.rows.length;i++) deck[i] = parseInt(rs.rows.item(i).value)
            // get the output
            rs = tx.executeSql("SELECT * FROM output ORDER BY outorder;")
            for (i=0;i<rs.rows.length;i++) outputModel.insert(0,{id: rs.rows.item(i).outorder, value: rs.rows.item(i).value})
        })
    }
    // display
    Column {
        id: column
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        spacing: 4
        // nb dice
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            Label {
                text: "nb dice:"
                font.pointSize: 16
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
            }
            SpinBox {
                id: nbDiceSpin
                value: 1; from: 1; to: 15
                validator: IntValidator{bottom: 1; top: 15}
                onValueChanged: {
                    swdb.transaction(function(tx) {
                        tx.executeSql("UPDATE parameters SET value='"+nbDiceSpin.value+"' WHERE name='nbdice';")
                    })
                }
            }
        }
        // bonus selector
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            Label {
                text: "Bonus: "
                font.pointSize: 16
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
            }
            SpinBox {
                id: bonusSpin
                value: 0; from: -20; to: 20
                validator: IntValidator{bottom: -20; top: +20}
                onValueChanged: {
                    swdb.transaction(function(tx) {
                        tx.executeSql("UPDATE parameters SET value='"+bonusSpin.value+"' WHERE name='bonus';")
                    })
                }
            }
        }
        // dice
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            Button {
                width: 50
                text: "X"
                onClicked: {
                    var rep = "roll: ", tt = 0, res = 0
                    for (var i=0;i<nbDiceSpin.value;i++) {
                        res = rollDice()
                        tt += res; rep += res
                        if (i+1<nbDiceSpin.value) rep += ","
                    }
                    var end = ""
                    if (bonusSpin.value != 0) {
                        end = ((bonusSpin.value > 0)? "+":"")+bonusSpin.value
                        rep += " "+end; tt += bonusSpin.value
                    }
                    rep += " = "+tt+" ("+nbDiceSpin.value+"d"+getType()+end
                    rep += ((wildCheck.checked)? " wild":"")+")"
                    swdbOutputAdd(rep)
                }
            }
            ComboBox {
                id: diceSelector
                width: 90
                model: ["d2","d3","d4","d6","d8","d10","d12","d20","d100"]
                onActivated: {
                    swdb.transaction(function(tx) {
                        tx.executeSql("UPDATE parameters SET value='"+diceSelector.currentIndex+"' WHERE name='dicetype';")
                    })
                }
            }
            Button {
                width: 50
                text: "R"
                onClicked: {
                    var rep = "roll: "
                    if (bonusSpin.value != 0) {
                        var end = ((bonusSpin.value > 0)? "+":"")+bonusSpin.value
                        var res = rollDice()
                        rep += res+" "+end+" = "+(res+bonusSpin.value)+" (d"+getType()+end+((wildCheck.checked)? " wild":"")+")"
                    }
                    else  rep += rollDice()+" (d"+getType()+((wildCheck.checked)? " wild":"")+")"
                    swdbOutputAdd(rep)
                }
            }
            CheckBox {
                id: wildCheck
                text: "Wild"
                font.pointSize: 16
                onCheckStateChanged: {
                    swdb.transaction(function(tx) {
                        tx.executeSql("UPDATE parameters SET value='"+((wildCheck.checked)? "1" : "0")+"' WHERE name='wild';")
                    })
                }
            }
        }
        // buttons
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            Button {
                width: 80
                text: "Clear"
                onClicked: {
                    outputModel.clear()
                    outOrder = 0
                    swdb.transaction(function(tx) { tx.executeSql("DELETE FROM output;") });
                }
            }
            Button {
                width: 80
                text: "Card"
                onClicked: {
                    var rep = ""
                    if (deck[currentcard] === 52) rep = "Red Joker"
                    else if (deck[currentcard] === 53) rep = "Black Joker"
                    else {
                        var md = deck[currentcard] % 13
                        switch (md) {
                        case 0: rep = "Ace"; break; case 1: rep = "Two"; break;
                        case 2: rep = "Three"; break; case 3: rep = "Four"; break;
                        case 4: rep = "Five"; break; case 5: rep = "Six"; break;
                        case 6: rep = "Seven"; break; case 7: rep = "Eight"; break;
                        case 8: rep = "Nine"; break; case 9: rep = "Ten"; break;
                        case 10: rep = "Jack"; break; case 11: rep = "Queen"; break;
                        case 12: rep = "King"; break;
                        }
                        if (deck[currentcard] < 13) rep += " of Spade"
                        else if (deck[currentcard] < 26) rep += " of Heart"
                        else if (deck[currentcard] < 39) rep += " of Diamond"
                        else rep += " of Club"
                    }
                    currentcard++
                    swdb.transaction(function(tx) {
                        tx.executeSql("UPDATE parameters SET value='"+currentcard+"' WHERE name='currentcard';")
                    })
                    swdbOutputAdd(rep)
                }
            }
            Button {
                width: 80
                text: "Shuffle"
                onClicked: { shuffleDeck() }
            }
        }
    }
    // output
    ListModel { id: outputModel }
    ListView {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: column.bottom
        anchors.topMargin: 30
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        interactive: true
        spacing: 4
        model: outputModel
        delegate: Row {
            property int order: id
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle {
                width: window.width-60; height: 30
                color: "#3cf"
                Text {
                    font.pointSize: 14
                    text: value
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Button {
                text: "X"
                width: 40
                height: 30
                onClicked: {
                    swdb.transaction(function(tx) {
                        tx.executeSql("DELETE FROM output WHERE outorder="+order+";")
                    })
                    outputModel.remove(index)
                }
            }
        }
    }
}
