#-------------------------------------------------
#
# Project created by QtCreator 2015-09-18T09:23:46
#
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = AADetector
TEMPLATE = app


SOURCES += main.cpp\
        mainwindow.cpp \
    general.cpp \
    AuxAxleDetector.cpp \
    HanFilter.cpp

HEADERS  += mainwindow.h \
    general.h \
    AAInputs.h \
    AuxAxleDetector.h \
    common.h \
    HanFilter.h

FORMS    += mainwindow.ui

OTHER_FILES += \
    earth.gif \
    AuxAxleDetector.pro.user

SUBDIRS += \
    AuxAxleDetector.pro
