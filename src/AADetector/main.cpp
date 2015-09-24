#include "mainwindow.h"
#include <QApplication>
#include <QtGui>
#include <iostream>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <set>

#include <sys/stat.h>
#include <unistd.h>

#define MEAS_TIME_LINUX 1
//#define SAVING_OFF 1
//#define DEBUG_SEL 1
#include "general.h"
#include "AuxAxleDetector.h"

char const fSep = '/';
std::string const fExt = ".gif";

inline bool exists_test3 (const std::string& name) {
  struct stat buffer;
  return (stat (name.c_str(), &buffer) == 0);
}


int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

#ifdef MEAS_TIME_LINUX
    unsigned long start_seconds, end_seconds, start_tag, end_tag;
    start_tag = get_time_mseconds(start_seconds);
    std::cout << "Stated at: " << start_seconds << "." << start_tag << std::endl;
#endif


    Uint32 baseNumbers2[10] = {655000, 665000, 710000, 715000, 730000,
                            740000, 750000, 755000, 805000, 810000};
    Uint32 baseNumbers[16] = {5000, 10000, 15000, 280000, 660000, 670000,
                            675000, 695000, 720000, 725000, 750000,
                            755000, 760000, 765000, 860000, 865000};
    //std::cout << (sizeof(baseNumbers)/sizeof(baseNumbers[0])) << std::endl;
#ifdef  DEBUG_SEL
    Uint32 debugNum = 719026;
#endif
    Uint16 N = (sizeof(baseNumbers)/sizeof(baseNumbers[0]));

    for(Uint16 i = 0; i < N; ++i)
    {
        Uint32 baseNum = baseNumbers[i];
        //std::cout << baseNum << std::endl;
        Uint16 total = 0;
        std::vector<std::string> outputFiles;
        for(int cnt = 0; cnt < 5000; ++cnt)
        {
#ifdef  DEBUG_SEL
            if((baseNum+cnt) != debugNum)
                continue;
            else
                std::cout << "Break on debug" << std::endl;
#endif
            std::stringstream ss;
            Uint32 subdir = (cnt/250)*250;
            ss << '.' << fSep << baseNum << "_images" << fSep << subdir << fSep << (baseNum+cnt) << fExt;
            if(!exists_test3(ss.str()))
                continue;
            AuxAxleDetector AAD;
            AAD.LoadProfileDetails(ss.str());
            unsigned int numAxles = AAD.CountAuxAxles();
            if(numAxles > 0)
            {
                //std::cout << total << ":" << (baseNum + cnt) << fExt << std::endl;
                ++total;
                outputFiles.push_back("." + ss.str());
             //   std::cout << numAxles << std::endl;
            }
        }
#ifndef SAVING_OFF
        sort(outputFiles.begin(), outputFiles.end());
        stringstream ssfname;
        ssfname << "./reports/" << baseNum << "_images_sel.txt";
        std::cout << ssfname.str() << endl;
        std::fstream output(ssfname.str().c_str(), std::fstream::out);
        for(Uint16 f = 0; f < outputFiles.size(); ++f)
        {
            output << outputFiles[f] << std::endl;
        }
        output.close();
#endif
    }
    //AAD.LoadProfileDetails("710088.gif");
    //AAD.LoadProfileDetails("656360.gif");



#ifdef MEAS_TIME_LINUX
      end_tag = get_time_mseconds(end_seconds);
      std::cout << "Ended at: " << end_seconds << "." << end_tag << std::endl;
      std::cout << " Elapsed time: " << time_diff_mseconds(start_seconds, start_tag, end_seconds, end_tag) << std::endl;
#endif
    //MainWindow w;
    //w.show();

    return a.exec();
}
