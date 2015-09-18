#include "mainwindow.h"
#include <QApplication>
#include <QtGui>
#include <iostream>
#include <fstream>

#include "AuxAxleDetector.h"



int main(int argc, char *argv[])
{
    QApplication a(argc, argv);


    AuxAxleDetector AAD;
    AAD.LoadProfileDetails("655029.gif");

    MainWindow w;
    w.show();

    return a.exec();
}
