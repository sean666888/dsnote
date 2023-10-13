/* Copyright (C) 2021-2023 Michal Kosciesza <michal@mkiol.net>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.2 as Dialogs
import QtQuick.Layouts 1.3

import org.mkiol.dsnote.Settings 1.0

DialogPage {
    id: root

    property bool verticalMode: width < appWin.verticalWidthThreshold

    title: qsTr("Settings")

    footerLabel {
        visible: _settings.restart_required
        text: qsTr("Restart the application to apply changes.")
        color: "red"
    }

    TabBar {
        id: bar

        width: parent.width

        TabButton {
            text: qsTr("User Interface")
            width: implicitWidth
        }

        TabButton {
            text: qsTr("Speech to Text")
            width: implicitWidth
        }

        TabButton {
            text: qsTr("Text to Speech")
            width: implicitWidth
        }

        TabButton {
            text: qsTr("Accessibility")
            width: implicitWidth
        }

        TabButton {
            text: qsTr("Other")
            width: implicitWidth
        }
    }

    StackLayout {
        width: root.width
        Layout.topMargin: appWin.padding

        currentIndex: bar.currentIndex

        ColumnLayout {
            id: userInterfaceTab

            width: root.width

            GridLayout {
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Text appending style")
                }
                ComboBox {
                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    currentIndex: {
                        if (_settings.insert_mode === Settings.InsertInLine) return 0
                        if (_settings.insert_mode === Settings.InsertNewLine) return 1
                        return 0
                    }
                    model: [
                        qsTr("In line"),
                        qsTr("After line break")
                    ]
                    onActivated: {
                        if (index === 0) {
                            _settings.insert_mode = Settings.InsertInLine
                        } else if (index === 1) {
                            _settings.insert_mode = Settings.InsertNewLine
                        } else {
                            _settings.insert_mode = Settings.InsertInLine
                        }
                    }

                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Text is appended to the note in the same line or after line break.")
                }
            }

            GridLayout {
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Font size in text editor")
                    wrapMode: Text.Wrap
                }
                SpinBox {
                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    from: 4
                    to: 25
                    stepSize: 1
                    value: _settings.font_size < 5 ? 4 : _settings.font_size
                    textFromValue: function(value) {
                        return value < 5 ? qsTr("Auto") : value.toString() + " px"
                    }
                    valueFromText: function(text) {
                        if (text === qsTr("Auto")) return 4
                        return parseInt(text);
                    }
                    onValueChanged: {
                        _settings.font_size = value;
                    }
                    Component.onCompleted: {
                        contentItem.color = palette.text
                    }
                }
            }

            GridLayout {
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Graphical style") + " (" + qsTr("advanced option") + ")"
                    wrapMode: Text.Wrap
                }
                ComboBox {
                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    currentIndex: _settings.qt_style_idx
                    model: _settings.qt_styles()
                    onActivated: _settings.qt_style_idx = index

                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Application graphical interface style.") + " " +
                                  qsTr("Change if you observe problems with incorrect colors under a dark theme.")
                }
            }

            GridLayout {
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Show desktop notification")
                }
                ComboBox {
                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    currentIndex: {
                        switch(_settings.desktop_notification_policy) {
                        case Settings.DesktopNotificationNever: return 0
                        case Settings.DesktopNotificationWhenInacvtive: return 1
                        case Settings.DesktopNotificationAlways: return 2
                        }
                        return 0
                    }
                    model: [
                        qsTr("Never"),
                        qsTr("When in background"),
                        qsTr("Always")
                    ]
                    onActivated: {
                        if (index === 0) {
                            _settings.desktop_notification_policy = Settings.DesktopNotificationNever
                        } else if (index === 1) {
                            _settings.desktop_notification_policy = Settings.DesktopNotificationWhenInacvtive
                        } else if (index === 2) {
                            _settings.desktop_notification_policy = Settings.DesktopNotificationAlways
                        }
                    }

                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Show desktop notification while reading or listening.")
                }
            }
        }

        ColumnLayout {
            id: speechToTextTab

            width: root.width

            GridLayout {
                id: grid

                visible: _settings.audio_inputs.length > 1
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding

                Label {
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    text: qsTr("Audio source")
                }
                ComboBox {
                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    currentIndex: _settings.audio_input_idx
                    model: _settings.audio_inputs
                    onActivated: {
                        _settings.audio_input_idx = index
                    }

                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Select preferred audio source.")
                }
            }

            Label {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                visible: _settings.audio_inputs.length <= 1
                color: "red"
                text: qsTr("No audio source could be found.") + " " + qsTr("Make sure the microphone is properly connected.")
            }

            GridLayout {
                Layout.fillWidth: true
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Listening mode")
                }
                ComboBox {
                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    currentIndex: {
                        if (_settings.speech_mode === Settings.SpeechSingleSentence) return 0
                        if (_settings.speech_mode === Settings.SpeechAutomatic) return 2
                        return 1
                    }
                    model: [
                        qsTr("One sentence"),
                        qsTr("Press and hold"),
                        qsTr("Always on")
                    ]
                    onActivated: {
                        if (index === 0) {
                            _settings.speech_mode = Settings.SpeechSingleSentence
                        } else if (index === 2) {
                            _settings.speech_mode = Settings.SpeechAutomatic
                        } else {
                            _settings.speech_mode = Settings.SpeechManual
                        }
                    }

                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    ToolTip.visible: hovered
                    ToolTip.text: "<i>" + qsTr("One sentence") + "</i>" + " — " + qsTr("Clicking on the %1 button starts listening, which ends when the first sentence is recognized.")
                                    .arg("<i>" + qsTr("Listen") + "</i>") + "<br/>" +
                                  "<i>" + qsTr("Press and hold") + "</i>" + " — " + qsTr("Pressing and holding the %1 button enables listening. When you stop holding, listening will turn off.")
                                    .arg("<i>" + qsTr("Listen") + "</i>") + "<br/>" +
                                  "<i>" + qsTr("Always on") + "</i>" + " — " + qsTr("After clicking on the %1 button, listening is always turn on.")
                                    .arg("<i>" + qsTr("Listen") + "</i>")
                }
            }

            CheckBox {
                id: puncCheckBox

                visible: _settings.py_supported()
                checked: _settings.restore_punctuation
                text: qsTr("Restore punctuation")
                onCheckedChanged: {
                    _settings.restore_punctuation = checked
                }

                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Enable advanced punctuation restoration after speech recognition. To make it work, " +
                                   "make sure you have enabled %1 model for your language.")
                              .arg("<i>" + qsTr("Punctuation") + "</i>") + " " +
                              qsTr("When this option is enabled model initialization takes much longer and memory usage is much higher.")
            }

            Label {
                wrapMode: Text.Wrap
                Layout.leftMargin: verticalMode ? appWin.padding : appWin.padding
                Layout.fillWidth: true
                visible: _settings.py_supported() && _settings.restore_punctuation && !app.ttt_configured
                color: "red"
                text: qsTr("To make %1 work, download %2 model.")
                        .arg("<i>" + qsTr("Restore punctuation") + "</i>").arg("<i>" + qsTr("Punctuation") + "</i>")
            }

            CheckBox {
                visible: _settings.gpu_supported()
                checked: _settings.whisper_use_gpu
                text: qsTr("Use GPU acceleration for Whisper")
                onCheckedChanged: {
                    _settings.whisper_use_gpu = checked
                }

                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.visible: hovered
                ToolTip.text: qsTr("If a suitable GPU device is found in the system, it will be used to accelerate processing.") + " " +
                              qsTr("GPU hardware acceleration significantly reduces the time of decoding.") + " " +
                              qsTr("Disable this option if you observe problems when using Speech to Text with Whisper models.")
            }

            Label {
                wrapMode: Text.Wrap
                Layout.leftMargin: verticalMode ? appWin.padding : 2 * appWin.padding
                Layout.fillWidth: true
                visible: _settings.gpu_supported() && _settings.whisper_use_gpu && _settings.gpu_devices.length <= 1
                color: "red"
                text: qsTr("A suitable GPU device could not be found.")
            }

            GridLayout {
                visible: _settings.gpu_supported() && _settings.whisper_use_gpu && _settings.gpu_devices.length > 1
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding

                Label {
                    wrapMode: Text.Wrap
                    Layout.leftMargin: verticalMode ? appWin.padding : 2 * appWin.padding
                    Layout.fillWidth: true
                    text: qsTr("GPU device")
                }
                ComboBox {
                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    currentIndex: _settings.gpu_device_idx
                    model: _settings.gpu_devices
                    onActivated: {
                        _settings.gpu_device_idx = index
                    }

                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Select preferred GPU device for hardware acceleration.")
                }
            }
        }

        ColumnLayout {
            id: textToSpeechTab

            width: root.width

            GridLayout {
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding

                Label {
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    text: qsTr("Speech speed")
                }

                Slider {
                    id: speechSpeedSlider

                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    ToolTip.visible: hovered && !pressed
                    ToolTip.text: qsTr("Change to make synthesized speech slower or faster.")

                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    snapMode: Slider.SnapAlways
                    stepSize: 1
                    from: 1
                    to: 20
                    value: _settings.speech_speed

                    onValueChanged: {
                        _settings.speech_speed = value
                    }

                    Connections {
                        target: _settings
                        onSpeech_speedChanged: {
                            speechSpeedSlider.value = _settings.speech_speed
                        }
                    }

                    Label {
                        anchors.bottom: parent.handle.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: appWin.padding
                        text: "x " + (parent.value / 10).toFixed(1)
                    }
                }
            }

            CheckBox {
                checked: _settings.diacritizer_enabled
                text: qsTr("Restore diacritics before speech synthesis")
                onCheckedChanged: {
                    _settings.diacritizer_enabled = checked
                }

                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Restore diacritical marks in the text before speech synthesis.") + " " +
                              qsTr("It works only for Arabic and Hebrew languages.")
            }
        }

        ColumnLayout {
            id: accessibilityTab

            width: root.width

            CheckBox {
                visible: _settings.is_xcb()
                checked: _settings.hotkeys_enabled
                text: qsTr("Use global keyboard shortcuts")
                onCheckedChanged: {
                    _settings.hotkeys_enabled = checked
                }

                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Shortcuts allow you to start or stop listening and reading using keyboard.") + " " +
                              qsTr("Speech to Text result can be appended to the current note, inserted into any active window (currently in focus) or copied to the clipboard.") + " " +
                              qsTr("Text to Speech reading can be from current note or from text in the clipboard.") + " " +
                              qsTr("Keyboard shortcuts function even when the application is not active (e.g. minimized or in the background).") + " " +
                              qsTr("This feature only works under X11.")
            }

            GridLayout {
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding
                visible: _settings.hotkeys_enabled

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: verticalMode ? appWin.padding : 2 * appWin.padding
                    text: qsTr("Start listening")
                }
                TextField {
                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    text: _settings.hotkey_start_listening
                    onTextChanged: _settings.hotkey_start_listening = text
                }
            }

            GridLayout {
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding
                visible: _settings.hotkeys_enabled

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: verticalMode ? appWin.padding : 2 * appWin.padding
                    text: qsTr("Start listening, text to active window")
                }
                TextField {
                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    text: _settings.hotkey_start_listening_active_window
                    onTextChanged: _settings.hotkey_start_listening_active_window = text
                }
            }

            GridLayout {
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding
                visible: _settings.hotkeys_enabled

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: verticalMode ? appWin.padding : 2 * appWin.padding
                    text: qsTr("Start listening, text to clipboard")
                }
                TextField {
                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    text: _settings.hotkey_start_listening_clipboard
                    onTextChanged: _settings.hotkey_start_listening_clipboard = text
                }
            }

            GridLayout {
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding
                visible: _settings.hotkeys_enabled

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: verticalMode ? appWin.padding : 2 * appWin.padding
                    text: qsTr("Stop listening")
                }
                TextField {
                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    text: _settings.hotkey_stop_listening
                    onTextChanged: _settings.hotkey_stop_listening = text
                }
            }

            GridLayout {
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding
                visible: _settings.hotkeys_enabled

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: verticalMode ? appWin.padding : 2 * appWin.padding
                    text: qsTr("Start reading")
                }
                TextField {
                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    text: _settings.hotkey_start_reading
                    onTextChanged: _settings.hotkey_start_reading = text
                }
            }

            GridLayout {
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding
                visible: _settings.hotkeys_enabled

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: verticalMode ? appWin.padding : 2 * appWin.padding
                    text: qsTr("Start reading text from clipboard")
                }
                TextField {
                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    text: _settings.hotkey_start_reading_clipboard
                    onTextChanged: _settings.hotkey_start_reading_clipboard = text
                }
            }

            GridLayout {
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding
                visible: _settings.hotkeys_enabled

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: verticalMode ? appWin.padding : 2 * appWin.padding
                    text: qsTr("Pause/Resume reading")
                }
                TextField {
                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    text: _settings.hotkey_pause_resume_reading
                    onTextChanged: _settings.hotkey_pause_resume_reading = text
                }
            }

            GridLayout {
                columns: root.verticalMode ? 1 : 2
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding
                visible: _settings.hotkeys_enabled

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: verticalMode ? appWin.padding : 2 * appWin.padding
                    text: qsTr("Cancel")
                }
                TextField {
                    Layout.fillWidth: verticalMode
                    Layout.preferredWidth: verticalMode ? grid.width : grid.width / 2
                    text: _settings.hotkey_cancel
                    onTextChanged: _settings.hotkey_cancel = text
                }
            }

            CheckBox {
                checked: _settings.actions_api_enabled
                text: qsTr("Allow external applications to invoke actions")
                onCheckedChanged: {
                    _settings.actions_api_enabled = checked
                }

                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Action allow external application to invoke certain operation when %1 is running.").arg("<i>Speech Note</i>");
            }

            Label {
                visible: _settings.actions_api_enabled
                Layout.leftMargin: verticalMode ? 1 * appWin.padding : 2 * appWin.padding
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: "<p>" + qsTr("Action allows external application to invoke certain operation when %1 is running.").arg("<i>Speech Note</i>") + " " +
                      qsTr("An action can be triggered via DBus call or with command-line option.") + " " +
                      qsTr("The following actions are currently supported:") +
                      "</p><ul>" +
                      "<li><i>start-listening</i> - " + qsTr("Starts listening.") + "</li>" +
                      "<li><i>start-listening-active-window</i> (X11) - " + qsTr("Starts listening. The decoded text is inserted into the active window.") + "</li>" +
                      "<li><i>start-listening-clipboard</i> - " + qsTr("Starts listening. The decoded text is copied to the clipboard.") + "</li>" +
                      "<li><i>stop-listening</i> - " + qsTr("Stops listening. The already captured voice is decoded into text.") + "</li>" +
                      "<li><i>start-reading</i> - " + qsTr("Starts reading.") + "</li>" +
                      "<li><i>start-reading-clipboard</i> - " + qsTr("Starts reading text from the clipboard.") + "</li>" +
                      "<li><i>pause-resume-reading</i> - " + qsTr("Pauses or resumes reading.") + "</li>" +
                      "<li><i>cancel</i> - " + qsTr("Cancels any of the above operations.") + "</li>" +
                      "</ul>" +
                      qsTr("For example, to trigger %1 action, execute the following command: %2.")
                              .arg("<i>start-listening</i>")
                              .arg("<i>flatpak run net.mkiol.SpeechNote --action start-listening</i>")
            }
        }

        ColumnLayout {
            id: otherTab

            width: root.width

            GridLayout {
                columns: root.verticalMode ? 1 : 3
                columnSpacing: appWin.padding
                rowSpacing: appWin.padding

                Label {
                    text: qsTr("Location of language files")
                }
                TextField {
                    Layout.fillWidth: true
                    text: _settings.models_dir
                    enabled: false

                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    ToolTip.visible: hovered
                    ToolTip.text: _settings.models_dir
                }
                Button {
                    text: qsTr("Change")
                    onClicked: directoryDialog.open()

                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Directory where language files are downloaded to and stored.")
                }
            }
        }
    }

    Dialogs.FileDialog {
        id: directoryDialog
        title: qsTr("Select Directory")
        selectFolder: true
        selectExisting: true
        folder:  _settings.models_dir_url
        onAccepted: {
            _settings.models_dir_url = fileUrl
        }
    }
}
