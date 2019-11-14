/*
 * S2STranslationServer.cpp
 *
 *  Created on: 19.12.2011
 *      Author: jniehues
 */

#include "FileConnection.h"


FileConnection::FileConnection(xml_node<> * desc,PipelineManager * p) : Connection(desc,p){
    inputFilename = "";
    outputFilename = "";
    waiting = false;

    parseXML(desc);

    initStreams();
}

FileConnection::~FileConnection() {
  delete inputFile;
  delete outputFile;
}


void FileConnection::start() {

  int count = 0;
  if (inputFile->is_open()) {
    string line;
    while ( getline (*inputFile,line) )
    {
      cout << "Input: " << line << '\n';
      Segment input;
      input.text = line;
      input.startTime = count;
      input.stopTime = count +1;
      count ++;
       
      waiting= true;
      server->input(input);
      server->markFinal(); // start new segment
      waitForOutput();
    }

    
    inputFile->close();
  }
}


void FileConnection::waitForOutput() {

  while(waiting)  {
    sleep(5);
  }
    
  
}

void FileConnection::send(const Text result) {


        for(int i = 0; i < result.size(); i++) {
	  cout << "Output Message Timestap: " << result[i].type << result[i].text  << endl;

        }


}


void FileConnection::initStreams() {

  inputFile = new ifstream(inputFilename);
  outputFile = new ofstream(outputFilename);

}




void FileConnection::parseXML(xml_node<> * desc) {

    for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "inputFile") == 0) {
            inputFilename = trim(node->value());
        }else if (strcmp(node->name(), "outputFile") == 0) {
	    outputFilename = trim(node->value());
        }
    }

}



