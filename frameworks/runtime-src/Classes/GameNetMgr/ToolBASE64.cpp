/*
@网络通信加解密
@author sunfan
@date	2017/05/05
*/

#include "ToolBASE64.h"
#include <stdio.h>
#include "stdlib.h"
/* Base64 编码 */

static char base[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

std::string ToolBASE64::base64_encode(const char* data, int data_len)
{
    //int data_len = strlen(data);
    int prepare = 0;
    int ret_len;
    int temp = 0;
    char *ret = NULL;
    char *f = NULL;
    int tmp = 0;
    char changed[4];
    int i = 0;
    ret_len = data_len / 3;
    temp = data_len % 3;
    if (temp > 0)
    {
        ret_len += 1;
    }
    ret_len = ret_len*4 + 1;
    ret = (char *)malloc(ret_len);
    
    if ( ret == NULL)
    {
        printf("No enough memory.\n");
        exit(0);
    }
    memset(ret, 0, ret_len);
    f = ret;
    while (tmp < data_len)
    {
        temp = 0;
        prepare = 0;
        memset(changed, '\0', 4);
        while (temp < 3)
        {
            //printf("tmp = %d\n", tmp);
            if (tmp >= data_len)
            {
                break;
            }
            prepare = ((prepare << 8) | (data[tmp] & 0xFF));
            tmp++;
            temp++;
        }
        prepare = (prepare<<((3-temp)*8));
        //printf("before for : temp = %d, prepare = %d\n", temp, prepare);
        for (i = 0; i < 4 ;i++ )
        {
            if (temp < i)
            {
                changed[i] = 0x40;
            }
            else
            {
                changed[i] = (prepare>>((3-i)*6)) & 0x3F;
            }
            *f = base[changed[i]];
            //printf("%.2X", changed[i]);
            f++;
        }
    }
    *f = '\0';
    
    for (int i=0; i<ret_len; i++) {
        if (ret[i] == '=') {
            ret[i]='\0';
        }
        if (i%3==0) {
            if (ret[i] >= 'a' && ret[i] <= 'z') {
                ret[i] = ret[i] - ('a' - 'A');
            }else if (ret[i] >= 'A' && ret[i] <= 'Z') {
                ret[i] = ret[i] + ('a' - 'A');
            }
        }
    }
    
    std::string ss = ret;
    
    free(ret);
    return ss;
    
}

/* 转换算子 */
char ToolBASE64::find_pos(char ch)
{
    char *ptr = (char*)strrchr(base, ch);//the last position (the only) in base[]
    return (ptr - base);
}

/* Base64 解码 */
std::string ToolBASE64::base64_decode(const char *data, int data_len)
{
    int ret_len = (data_len / 4) * 3;
    int equal_count = 0;
    char *ret = NULL;
    char *f = NULL;
    int tmp = 0;
    int temp = 0;
    int prepare = 0;
    int i = 0;
    if (*(data + data_len - 1) == '=')
    {
        equal_count += 1;
    }
    if (*(data + data_len - 2) == '=')
    {
        equal_count += 1;
    }
    if (*(data + data_len - 3) == '=')
    {//seems impossible
        equal_count += 1;
    }
    switch (equal_count)
    {
        case 0:
            ret_len += 4;//3 + 1 [1 for NULL]
            break;
        case 1:
            ret_len += 4;//Ceil((6*3)/8)+1
            break;
        case 2:
            ret_len += 3;//Ceil((6*2)/8)+1
            break;
        case 3:
            ret_len += 2;//Ceil((6*1)/8)+1
            break;
    }
    ret = (char *)malloc(ret_len);
    if (ret == NULL)
    {
        printf("No enough memory.\n");
        exit(0);
    }
    memset(ret, 0, ret_len);
    
    int len = strlen(data);
    char *rr = (char *)malloc(len);
    memcpy(rr, data, len);
    
    for (int i=0; i<len; i++) {
        if (i%3==0) {
            if (rr[i] >= 'a' && rr[i] <= 'z') {
                rr[i] = rr[i] - ('a' - 'A');
            }else if (rr[i] >= 'A' && rr[i] <= 'Z') {
                rr[i] = rr[i] + ('a' - 'A');
            }
        }
        
    }
    
    f = ret;
    while (tmp < (data_len - equal_count))
    {
        temp = 0;
        prepare = 0;
        while (temp < 4)
        {
            if (tmp >= (data_len - equal_count))
            {
                break;
            }
            prepare = (prepare << 6) | (find_pos(rr[tmp]));
            temp++;
            tmp++;
        }
        prepare = prepare << ((4-temp) * 6);
        for (i=0; i<3 ;i++ )
        {
            if (i == temp)
            {
                break;
            }
            *f = (char)((prepare>>((2-i)*8)) & 0xFF);
            f++;
        }
    }
    *f = '\0';
    
    std::string ss = ret;
    free(ret);
    free(rr);
    return ss;
}
