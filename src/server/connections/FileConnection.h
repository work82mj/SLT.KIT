/*
 * MTecConnection.h
 *
 *  Created on: 31.05.2016
 *      Author: jniehues
 */

#ifndef FILECONNECTION_H_
#define FILECONNECTION_H_
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif


#include <time.h>
#include <iostream>
#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include <sstream>
#include <string>
#include <limits>
#include <stack>
#include <mutex>
#include <thread>
#include "Connection.h"
#include "PipelineManager.h"
using namespace std;
using namespace rapidxml;



class FileConnection : public Connection{
 private:


	string inputFilename;
	string outputFilename;
	ifstream* inputFile;
	ofstream* outputFile;
	PipelineManager * server;
	bool waiting;

	bool ignoreFlush;

	void initStreams();
	void waitForOutput();
	void parseXML(xml_node<> * desc);

public:
	FileConnection(xml_node<> * desc,PipelineManager * p);
	virtual ~FileConnection();
	void start();
	void send(const Text result);
	

};


#endif /* FILECONNECTION_H_ */
