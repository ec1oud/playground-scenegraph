TEMPLATE = app
TARGET = sqtch
QT += core gui qml quick

SOURCES += main.cpp

APP_FILES += sqtch.qml

OTHER_FILES = $$APP_FILES

# Create the resource file
GENERATED_RESOURCE_FILE = $$OUT_PWD/sqtcher.qrc

RESOURCE_CONTENT = \
    "<RCC>" \
    "<qresource>"

for(resourcefile, APP_FILES) {
    resourcefileabsolutepath = $$absolute_path($$resourcefile)
    relativepath_in = $$relative_path($$resourcefileabsolutepath, $$_PRO_FILE_PWD_)
    relativepath_out = $$relative_path($$resourcefileabsolutepath, $$OUT_PWD)
    RESOURCE_CONTENT += "<file alias=\"$$relativepath_in\">$$relativepath_out</file>"
}

RESOURCE_CONTENT += \
    "</qresource>" \
    "</RCC>"

write_file($$GENERATED_RESOURCE_FILE, RESOURCE_CONTENT)|error("Aborting.")

RESOURCES += $$GENERATED_RESOURCE_FILE

