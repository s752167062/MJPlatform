#ifndef GameSocket_h
#define GameSocket_h
#pragma once //保证头文件只被编译一次
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

#else
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <pthread.h>
#endif
#include <fcntl.h>
#include <stdio.h>
#include <errno.h>
#include "DataBuff.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import "NETWorker.h"
#endif

#define _MAX_MSGSIZE 32*1024//16 * 1024
#define INBUFFSIZE   32*1024//(64*1024)
#define OUTBUFFSIZE  (5*1024)
#define MSGLENBIT 4
//消息结构  包体长度4字节  包头2字节  序列号4字节 + 包体
class GameSocket {
public:
	char m_ip[32];
	int m_port;
	int m_socket;//socket
	int m_keepAlive;//是否保持活跃
	int m_socketStatu = 0; // 0 等待连接 1 连接成功 -1 关闭
	bool m_terminated = false;//这个socket是否已经被终止
	int m_sid = -1;//记录自己的编号
	int m_serialNumber = -1;//默认序列号为-1 就是没有接收到过序列号
	int m_staticSN = -1;
	int m_preSerialNumber = -1;

	int m_msg_offset;//每个套接字的偏移量
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	std::mutex mutex_buff;//互斥锁
#else
	pthread_mutex_t mutex_buff;//互斥锁
#endif
	unsigned char m_buff_out[OUTBUFFSIZE];
	unsigned char m_buff_in[INBUFFSIZE];
	int m_buff_out_size;
	int m_buff_in_size;
	int m_buff_in_index;

	GameSocket();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	//IPV6相关
	bool	open_inIPV6();
	static void getIPFromURL_ipv6(char* ip, const char* url);
#endif

	queue<int> dataBuff_in;
	queue<int> dataBuff_out;


	int getDataBuff_in();
	void putDataBuff_in(int pid);
	int getDataBuff_out();
	void putDataBuff_out(int pid);
	int getDataBuff_in_size();
	int getDataBuff_out_size();

	static int openSocket(const char* ip, int port);//创建一个socket
	static void getIPFromURL(char* ip, const char* url);
	static void* run(void* obj);
	bool	open();
	int     getStatu();
	int     getSerialNumber();
	int     getStaticSerialNumber();
	bool check();
	int checkRead(int s);
	bool receiveMsg(void* buff, long& size);
	bool readMSG();
	int checkWrite(int s);
	bool dealSendMsg(void* buff, long size);
	bool sendNetMsg();
	void testSend(void* buff, int size);
	bool hasError();
	void destroy();

	static void    closeSocket(int sid);
	static GameSocket* getSocket(int sid);
	void writeError(const char* filename, const char* content);

	~GameSocket();
};


#endif /* GameSocket */
