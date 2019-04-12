QT += \
    core gui qml quick \
    multimedia sql \
    network websockets \
    xml svg quickcontrols2

TARGET = qmlcreator
TEMPLATE = app

target.path = /usr/bin
INSTALLS += target

CONFIG += mobility
MOBILITY =

RESOURCES += \
    qmlcreator_resources.qrc

HEADERS += \
    cpp/ProjectManager.h \
    cpp/QMLHighlighter.h \
    cpp/SyntaxHighlighter.h \
    cpp/MessageHandler.h

SOURCES += \
    cpp/main.cpp \
    cpp/ProjectManager.cpp \
    cpp/QMLHighlighter.cpp \
    cpp/SyntaxHighlighter.cpp \
    cpp/MessageHandler.cpp

lupdate_only {
SOURCES += \
    qml/components/*.qml \
    qml/components/dialogs/*.qml \
    qml/components/palettes/*.qml \
    qml/modules/*.qml \
    qml/screens/*.qml \
    qml/*.qml
}

TRANSLATIONS = resources/translations/qmlcreator_ru.ts

android {
    QT += androidextras \
        sensors bluetooth nfc \
        positioning location \
        3dcore 3drender 3dinput 3dlogic \
        3dextras 3dquick 3danimation
    OTHER_FILES += platform-specific/android/AndroidManifest.xml
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/platform-specific/android
}

ios {
    ICON_DATA.files = \
        $$PWD/platform-specific/ios/Icon.png \
        $$PWD/platform-specific/ios/Icon@2x.png \
        $$PWD/platform-specific/ios/Icon-60.png \
        $$PWD/platform-specific/ios/Icon-60@2x.png \
        $$PWD/platform-specific/ios/Icon-72.png \
        $$PWD/platform-specific/ios/Icon-72@2x.png \
        $$PWD/platform-specific/ios/Icon-76.png \
        $$PWD/platform-specific/ios/Icon-76@2x.png \
        $$PWD/platform-specific/ios/Def.png \
        $$PWD/platform-specific/ios/Def@2x.png \
        $$PWD/platform-specific/ios/Def-Portrait.png \
        $$PWD/platform-specific/ios/Def-568h@2x.png
    QMAKE_BUNDLE_DATA += ICON_DATA

    QMAKE_INFO_PLIST = $$PWD/platform-specific/ios/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST
}

contains(CONFIG, click) {
    DEFINES += UBUNTU_CLICK
    # figure out the current build architecture
    CLICK_ARCH=$$system(dpkg-architecture -qDEB_HOST_ARCH)
    # do not remove this line, it is required by the IDE even if you do
    # not substitute variables in the manifest file
    UBUNTU_MANIFEST_FILE = $$PWD/manifest.json.in


    # substitute the architecture in the manifest file
    manifest_file.output   = manifest.json
    manifest_file.CONFIG  += no_link \
                             add_inputs_as_makefile_deps\
                             target_predeps
    manifest_file.commands = sed s/@CLICK_ARCH@/$$CLICK_ARCH/g ${QMAKE_FILE_NAME} > ${QMAKE_FILE_OUT}
    manifest_file.input = UBUNTU_MANIFEST_FILE
    QMAKE_EXTRA_COMPILERS += manifest_file

    # installation path of the manifest file
    mfile.CONFIG += no_check_exist
    mfile.files  += $$OUT_PWD/manifest.json
    mfile.path = /

    # AppArmor profile
    apparmor.files += $$PWD/qmlcreator.apparmor
    apparmor.path = /

    # Desktop launcher
    desktop.files += $$PWD/qmlcreator.desktop
    desktop.path = /

    # Run script
    runscript.files += $$PWD/run.sh
    runscript.path = /

    INSTALLS += mfile apparmor desktop runscript
}
