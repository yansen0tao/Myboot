##MMU##
###MMU的作用###
  - 虚拟地址转化为物理地址
  - 控制内存访问权限
###MMU使用###
  - 创建TTB(translation table),TTB位置安排在内存起始地址0x50000000
  - 查手册可知，虚拟地址的31-20位可以索引到具体的TTB表项,即2^12=4096个entries
  - 又如果索引到的entry最后两位为10，则对应段式转换，虚拟地址的19-0位可以索引到2^20，即1mbyte的物理段地址
  - 因此创建完TTB以后，应该根据手册中段式转换对应entry的descriptor的结构予以填充，实现TTB
  - 开启MMU，使能虚拟地址




