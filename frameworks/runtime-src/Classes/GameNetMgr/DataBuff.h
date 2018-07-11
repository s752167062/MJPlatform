/*
@ÍøÂç²ãÊý¾Ý»º´æ
@author sunfan
@date	2017/05/04
*/
#ifndef GAME_DATA_BUFF_H
#define GAME_DATA_BUFF_H

#include "cocos2d.h"
#include <map>
#include <string>
#include <iostream>

using namespace std;

class DataBuff
{
public:
    
    static int createBuffer(unsigned char*data,long size,int sn);
    static int createBuffer();
    static void deleteBuffer(int pid);
    static DataBuff* getDataBuffer(int pid);
    
    DataBuff();
    DataBuff(unsigned char*data,long size);
    
    ~DataBuff();
    
    long _length;
    long _buff_length;
    long _index;
    long _beanStart;
    unsigned char* _buff;
    int _key;
    
    void buffAutoAlloc(long size);
    void buffAlloc(long size);
    void addLength(long size);
    long getLength();
    void setKey(int key);
    int  getKey();
    
    std::string toString();
    bool encode();
    bool decode(int dep,long len);
    
    unsigned char readByte();
    short readShort();
    int readInt();
    long long readLong();
    std::string readString();
    std::string readNewString();
    std::string readDataString();
    std::string readJsonString(int &size);
    bool readBoolean();
    int readLength();
    unsigned char* readBytes(long &size);
    
    void writeByte(unsigned char data);
    void writeShort(short data);
    void writeInt(int data);
    void writeLong(long long data);
    void writeString(std::string data);
    void writeNewString(std::string data);
    void writeBoolean(bool data);
    void writeLength(int data);
    void writeBytes(unsigned char*data,long size);
    
    void addBeanLength(long size);
    void writeNewBean();
    void writeBeanByte(unsigned char data);
    void writeBeanShort(short data);
    void writeBeanInt(int data);
    void writeBeanLong(long long data);
    void writeBeanString(std::string data);
    void writeBeanBoolean(bool data);
    void writeBeanLength(int data);
    void writeBeanBytes(unsigned char*data,long size);
    
    
    std::string EncryptString(std::string data,int keylen);
    void EncryptByteShift(int keylen);
    void EncryptXor();
    
    std::string DecryptString(std::string data,int keylen);
};
#endif
