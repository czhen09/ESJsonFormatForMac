
至前致谢：此工具核心内容来自[EnjoySR/ESJsonFormat-Xcode](https://github.com/EnjoySR/ESJsonFormat-Xcode)    

附上[简书地址](http://www.jianshu.com/p/a5e26ae42d8b),在使用中有任何问题或者好的建议可以在简书或者GitHub issue


![image](https://github.com/czhen09/ESJsonFormatForMac/raw/master/image/useGuide.gif)  


##2017-6-2  
##新增功能  
1.支持post/get请求选择; Https请求我也处理了下,但是没有测试,具体是否可行未知;    
2.Base_Url和Joint_Url分离;Base_Url做了本地缓存功能;如果Base_Url和Joint_Url不想分开,可以将两者拼接好直接输入Base_Url中即可;  
3.参数和接口分离;      
![image](https://github.com/czhen09/ESJsonFormatForMac/raw/master/image/6.png)  

##2017-5-31:  
##新增功能:  
1.默认转换id为ID;  
2.面向使用YYModel和MJExtension用户提供不同的.m文件格式输出;在使用YYModel的时候,自动捕捉填充以下代码:  
		  
	+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper{
	    return @{@“ID”:id};
	}  
and 
   
    + (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@“subItems” : [Subitems class]};  
    }

![image](https://github.com/czhen09/ESJsonFormatForMac/raw/master/image/5.png)  

##2017-5-22:  
##现状：  
1.在YYModel盛行的时候，其他插件都可以不用，但是ESJsonFormat必不可缺；

2.Xcode8不支持插件之后,需要对其重签名才能使用插件;并且还有顾及到底层问题，重新签名后的Xcode打包不能上传上传AppStore;   
 
3.我之前是没有选择在Xcode8上面安装插件，而是电脑上并存了Xcode7和Xcode8，而Xcode7就只是在必要的时候使用ESJsonFormat;并且突然打开Xcode7的时候，会反复打开很多次，使用ESJsonFormat之后，Xcode8又得重启;  
  
4.无论如何，电脑中都存了两个Xcode，浪费内存；  
  

##挣扎：  
1.在ESJsonFormat核心内容不变的情况下，重建了macOS工程，添加了界面。至此，ESJsonFormat的基本功能可以独立于Xcode运行;  
![image](https://github.com/czhen09/ESJsonFormatForMac/raw/master/image/1.png)

 

其中界面功能如下:  
1).支持输入Url，发送请求获取Json数据、.h文件、.m文件内容;   
2).支持直接在Json中输入Json数据进行转换；  
3).支持Swift和OC语言;    
4).支持.h、.m文件内容的复制清除；  


2.使用:程序下载下来，跑起来之后，之后在Dock中保留就可以了;  


![image](https://github.com/czhen09/ESJsonFormatForMac/raw/master/image/2.png)


##最后：  
软件使用相当简单，大家下载下来一看便知； 
附几张效果图:    

![image](https://github.com/czhen09/ESJsonFormatForMac/raw/master/image/3.png)  
![image](https://github.com/czhen09/ESJsonFormatForMac/raw/master/image/4.png)

