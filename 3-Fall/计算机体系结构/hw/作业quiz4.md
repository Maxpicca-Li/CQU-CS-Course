![image-20211116111637637](作业quiz4.assets/image-20211116111637637.png)

地址空间：$log(16MB) = 24$

cache_blocks：$64kB/4B = 2^{14}$

index：14



(1)cache中，cache lines: $2^{14}$

(2)主存中，mem_blocks：$16MB/4B=2^{22}$

(3) 直接映射：

​	offset: $log(4B)=2$

​	index = $log(cache\_blocks /m)$

​	tag:  $$

(4) 

index = log(cache lines /m) = 13

tag = 24-2-13 = 9

(5)

index = log(cache lines /m) = 12 即set bit数

tag = 24-2-12=10

(6)

直接映射：1个

两路组相联：2个

四路组相联：4个

![image-20211116115758782](作业quiz4.assets/image-20211116115758782.png)

![image-20211116115809217](作业quiz4.assets/image-20211116115809217.png)

![image-20211116115818917](作业quiz4.assets/image-20211116115818917.png)