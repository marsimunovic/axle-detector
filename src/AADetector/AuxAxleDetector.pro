TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += main.cpp \
    HanFilter.cpp \
    general.cpp \
    AuxAxleDetector.cpp \
    libnsgif.c \
    SFEC.cpp

HEADERS += \
    HanFilter.h \
    AuxAxleDetector.h \
    AAInputs.h \
    common.h \
    dirent.h \
    general.h \
    inttypes.h \
    libnsgif.h

OTHER_FILES += \
    AuxAxleDetector.pro.user

