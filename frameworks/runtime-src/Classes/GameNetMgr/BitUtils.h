/*
@ÍøÂç²ã¹¤¾ß
@author sunfan
@date	2017/05/04
*/
#ifndef CATCHBIRD_BITUTILS_H
#define CATCHBIRD_BITUTILS_H

#include <stdio.h>

class BitUtils 
{
public:
    static void shiftRight(unsigned char* src, int bit, int len)
    {
        if (len == 0) 
		{
            return;
        }
        
        int b = bit % 8;
        if (b == 0) 
		{
            return;
        }
        
        int mask = (unsigned char) (0xff >> (8 - b));
        int last = src[len - 1] & 0xff;
        
        for (int i = 0; i < len; i++) 
		{
            int hight = (unsigned char) ((last & mask) << (8 - b));
            last = src[i] & 0xff;
            src[i] = (unsigned char) ((last >> b) | hight);
        }
    }
    
    static void shiftLeft(unsigned char* src, int bit, int len) 
	{
        if (len == 0) 
		{
            return ;
        }
        
        int b = bit % 8;
        if (b ==0) 
		{
            return ;
        }
        
        int mask = 0xff << (8 - b) & 0xff;
        
        int last = src[0];
        
        for (int i = len - 1; i >= 0; i--) 
		{
            int hight = (last & mask) >> (8 - b);
            last = src[i] & 0xff;
            src[i] = (unsigned char) ((last << b) | hight);
        }
    }
    
    static void xorMsg(unsigned char* src,int key,int len)
	{
        if (len == 0) 
		{
            return;
        }
        for (int i = len - 1; i >= 0; i--) 
		{
            if (i%3 == 0)
			{
                src[i] ^= key;
            }
        }
    }
};

#endif
