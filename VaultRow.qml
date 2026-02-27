// VaultRow.qml
import QtQuick
import qs.Widgets

Rectangle {
    id: control

    property string name: ""
        property string path: ""
            property bool isExcluded: false // Ricevuto dal Repeater

                property color rowColor: "gray"
                    property color accentColor: "blue"
                        property color textColor: "white"

                            signal toggled()

                            width: parent.width
                            height: 52

                            // Feedback visivo basato sullo stato isExcluded
                            color: isExcluded ? "transparent" : control.rowColor
                            radius: 10
                            opacity: isExcluded ? 0.6 : 1.0 // Un po' più visibile anche se escluso
                            border.color: isExcluded ? control.rowColor : "transparent"
                            border.width: 1

                            Row {
                                anchors.fill: parent; anchors.margins: 12; spacing: 16

                                // Lo Switch (Checkbox personalizzata)
                                Rectangle {
                                    id: switchTrack
                                    width: 38; height: 20; radius: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    // Se NON è escluso (attivo), usa l'accento
                                    color: !control.isExcluded ? control.accentColor : "#312d3d"

                                    Rectangle {
                                        width: 14; height: 14; radius: 7
                                        color: !control.isExcluded ? "#1a1a1a" : control.textColor
                                        anchors.verticalCenter: parent.verticalCenter
                                        // Animazione dello switch
                                        x: !control.isExcluded ? 21 : 3
                                        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    StyledText {
                                        text: control.name
                                        font.weight: Font.Medium
                                        color: control.textColor
                                        // Sbarra il testo se è in blacklist
                                        font.strikeout: control.isExcluded
                                    }
                                    StyledText {
                                        text: control.path
                                        font.pixelSize: 10
                                        color: control.textColor
                                        opacity: 0.5
                                        elide: Text.ElideMiddle
                                        width: control.width - 110
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: control.toggled() // Notifica solo il padre
                            }
                        }