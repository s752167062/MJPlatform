/*
@网络通信加解密
@author sunfan
@date	2017/05/05
*/

#ifndef ToolBASE64_h
#define ToolBASE64_h

#include <stdio.h>
#include <string>

class ToolBASE64{
public:
    /* Base64 编码 */
    static std::string base64_encode(const char* data, int data_len);
    
    /* Base64 解码 */
    static std::string base64_decode(const char* data, int data_len);
private:
    static char find_pos(char ch);
};

#endif /* BASE64_hpp */
