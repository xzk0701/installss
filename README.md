-1.shadwosocks简介
---
hadowsocks（中文名称：影梭）是使用Python等语言开发的、基于Apache许可证开源的代理软件。Shadowsocks使用socks5代理，用于保护网络流量。在中国大陆被广泛用于突破防火长城（GFW），以浏览被封锁的内容。

Shadowsocks分为服务器端和客户端。在使用之前，需要先将服务器端部署在支持Python的服务器上面，然后通过客户端连接并创建本地代理。

2015年8月22日，Shadowsocks原作者Clowwindy因受到中国政府的压力，停止维护此项目。[2][3]但开发已有人接管，仍有更新陆续推送。
0.说明
---
若要免费的服务，推荐使用[Lantern](https://github.com/getlantern/lantern)

shadowsock脚本使用[秋水逸冰](https://teddysun.com/342.html)大大的脚本

锐速脚本使用[91云](https://www.91yun.org/archives/683)的脚本
1.准备工作
---
- kvm的vps，[推荐教程](http://www.freehao123.com/ten-vps/)，并获得服务器ip与初始密码
- [putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)
- shadowsocks的[win客户端](https://github.com/shadowsocks/shadowsocks-windows/releases)
- 请确保vps发行版为centos 6.X
2.确保工作环境
---
首先打开putty.exe，将其8.8.8.8更改为自己的服务器ip地址，并点击Open

![](http://ww2.sinaimg.cn/mw690/6a1637c7gw1f4kns4s0wuj20cm0c574o.jpg)

此处点击确认

![](http://ww4.sinaimg.cn/mw690/6a1637c7gw1f4kns2bfzsj20kh0btwes.jpg)
用户名为:root

密码为默认密码

密码输入时默认为不可见，这点请注意，并不是不能输入

![](http://ww2.sinaimg.cn/mw690/6a1637c7gw1f4kns2rzv4j20if0bqt8k.jpg)
![](http://ww3.sinaimg.cn/mw690/6a1637c7gw1f4kns3i50jj20ig0brq2u.jpg)

登陆成功

![](http://ww4.sinaimg.cn/mw690/6a1637c7gw1f4kns0pfz3j20ib0bpdft.jpg)

更改密码命令
   
    passwd root

![](http://ww2.sinaimg.cn/mw690/6a1637c7gw1f4kns3ulkej20id0bk3yd.jpg)

密码同样不可见

按提示输入更改后密码，以及确认更改密码

![](http://ww2.sinaimg.cn/mw690/6a1637c7gw1f4kns0zsqjj20ie0blt8o.jpg)

更改初始密码成功

3.正式安装
---
请直接输入以下代码，若运行失败，请检查Linux发行版是否为Centos 6.X

使用Ctrl+C可终止所有脚本

    cd ~
    yum install git vim -y
    git clone https://github.com/xzk0701/installss.git
    cd ~/installss
    chmod +x installss.sh
    ./installss.sh
![](http://ww2.sinaimg.cn/mw690/6a1637c7gw1f4kns1wv02j20ic0bljr8.jpg)
![](http://ww4.sinaimg.cn/mw690/6a1637c7gw1f4knrzo9epj20if0blmx1.jpg)

此处填写shadowsock使用密码，建议使用非默认密码。

![](http://ww4.sinaimg.cn/mw690/6a1637c7gw1f4kns6a1atj20if0bo74b.jpg)

建议使用默认端口，可按回车跳过，也可自行修改。

![](http://ww2.sinaimg.cn/mw690/6a1637c7gw1f4kns4gccgj20ic0bqq33.jpg)

其余选项都可按回车跳过

安装过程中出现类似输出代表安装成功

![](http://ww1.sinaimg.cn/mw690/6a1637c7gw1f4kns5u8a1j20if0bowey.jpg)

自此shadowsocks可以使用。

4.学会使用
---

#建议看[官方教程](https://github.com/shadowsocks/shadowsocks-windows/wiki/Shadowsocks-Windows-%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)

启动shadowsocks客户端后右击飞机图标

![](http://ww1.sinaimg.cn/mw690/6a1637c7gw1f4kohz9ff2j20cx06ejsh.jpg)

然后选择编辑服务器（Edit Servers)

填写内容

    ip：你的服务器ip
    端口:逆选择的端口（默认8989）
    密码自己填写
    加密方式如果没有更改这里不用选择
    本地端口默认


![](http://ww3.sinaimg.cn/mw690/6a1637c7gw1f4koi9f6kyj20dc08jwfi.jpg)

5.继续安装
---
输入
   
    ./serverspeeder-all.sh

选择内核时可按中文提示填写
![](http://ww2.sinaimg.cn/mw690/6a1637c7gw1f4kns58tqfj20k607xweq.jpg)

自此安装完成

![](http://ww1.sinaimg.cn/mw690/6a1637c7gw1f4kns0bpdxj20if0bmt8v.jpg)
