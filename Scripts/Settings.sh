#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_CI-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

WIFI_SH="./package/base-files/files/etc/uci-defaults/990_set-wireless.sh"
WIFI_UC="./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"
if [ -f "$WIFI_SH" ]; then
	#修改WIFI名称
	sed -i "s/BASE_SSID='.*'/BASE_SSID='$WRT_SSID'/g" $WIFI_SH
	#修改WIFI密码
	sed -i "s/BASE_WORD='.*'/BASE_WORD='$WRT_WORD'/g" $WIFI_SH
elif [ -f "$WIFI_UC" ]; then
	#修改WIFI名称
	sed -i "s/ssid='.*'/ssid='$WRT_SSID'/g" $WIFI_UC
	#修改WIFI密码
	sed -i "s/key='.*'/key='$WRT_WORD'/g" $WIFI_UC
	#修改WIFI地区
	sed -i "s/country='.*'/country='CN'/g" $WIFI_UC
	#修改WIFI加密
	sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" $WIFI_UC
fi

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo "$WRT_PACKAGE" >> ./.config
fi

#高通平台调整
if [[ $WRT_TARGET == *"IPQ"* ]]; then
	#取消nss相关feed
	echo "CONFIG_FEED_nss_packages=n" >> ./.config
	echo "CONFIG_FEED_sqm_scripts_nss=n" >> ./.config
	#设置NSS版本
	echo "CONFIG_NSS_FIRMWARE_VERSION_11_4=n" >> ./.config
	echo "CONFIG_NSS_FIRMWARE_VERSION_12_2=y" >> ./.config
fi

#编译器优化
if [[ $WRT_TARGET != *"X86"* ]]; then
	echo "CONFIG_TARGET_OPTIONS=y" >> ./.config
	echo "CONFIG_TARGET_OPTIMIZATION=\"-O3 -pipe -march=armv8-a+crypto+crc -mcpu=cortex-a53+crypto+crc -mtune=cortex-a53\"" >> ./.config
     	# echo "CONFIG_TARGET_OPTIMIZATION=\"-Ofast -pipe -march=armv8-a+crypto+crc -mcpu=cortex-a53+crypto+crc -mtune=cortex-a53 -ffast-math -flto -funroll-loops -ftree-vectorize -fomit-frame-pointer -funswitch-loops -finline-functions\"" >> ./.config
      	# echo "CONFIG_TARGET_OPTIMIZATION=\"-Ofast -pipe -march=armv8-a+crypto+crc+fp-armv8 -mcpu=cortex-a53+crypto+crc -mtune=cortex-a53 -ffast-math -flto=full -funroll-loops -ftree-vectorize -fomit-frame-pointer -funswitch-loops -finline-functions -fgcse-after-reload -fipa-sra -fprefetch-loop-arrays -floop-parallelize-all -flink-time-optimization -frename-registers -funroll-all-loops -fstrict-aliasing -fwhole-program -mfpu=neon-fp-armv8 -mfloat-abi=hard\"" >> ./.config
       	# echo "CONFIG_TARGET_OPTIMIZATION=\"-Ofast -pipe -march=armv8-a+crypto+crc+fp-armv8+simd+neon -mcpu=cortex-a53+crypto+crc+neon -mtune=cortex-a53 -ffast-math -flto=full -funroll-loops -ftree-vectorize -fomit-frame-pointer -funswitch-loops -finline-functions -fgcse-after-reload -fipa-sra -fprefetch-loop-arrays -floop-parallelize-all -flink-time-optimization -frename-registers -funroll-all-loops -fstrict-aliasing -fwhole-program -mfpu=neon-fp-armv8 -mfloat-abi=hard -fsched2-use-superblocks -fgraphite-identity -ftree-loop-im -floop-nest-optimize -ftree-builtin-call-dce -floop-block -fprofile-use -fprofile-generate -funroll-loops -fomit-frame-pointer -fschedule-insns -fstack-protector-strong -foptimize-sibling-calls -fno-tree-vrp -fno-tree-scev-cprop -fno-fat-lto-objects -falign-functions=32 -falign-loops=32 -falign-jumps=32 -falign-labels=32\"" >> ./.config
       	# echo "CONFIG_TARGET_OPTIMIZATION=\"-Ofast -pipe -march=armv8-a+crypto+crc+fp-armv8+simd+neon+vfpv4 -mcpu=cortex-a53+crypto+crc+neon+vfpv4 -mtune=cortex-a53 -ffast-math -flto=full -funroll-loops -ftree-vectorize -fomit-frame-pointer -funswitch-loops -finline-functions -fgcse-after-reload -fipa-sra -fprefetch-loop-arrays -floop-parallelize-all -flink-time-optimization -frename-registers -funroll-all-loops -fstrict-aliasing -fwhole-program -mfpu=neon-fp-armv8 -mfloat-abi=hard -fsched2-use-superblocks -fgraphite-identity -ftree-loop-im -floop-nest-optimize -ftree-builtin-call-dce -floop-block -fprofile-use -fprofile-generate -funroll-loops -fomit-frame-pointer -fschedule-insns -fstack-protector-strong -foptimize-sibling-calls -fno-tree-vrp -fno-tree-scev-cprop -fno-fat-lto-objects -falign-functions=64 -falign-loops=64 -falign-jumps=64 -falign-labels=64 -fbranch-target-load-optimize -fmax-inline-insns-single=200 -ftree-loop-distribute-patterns -fno-tree-vectorize -ftree-loop-im -floop-nest-optimize -floop-interchange -ftree-vec-threshold=512 -foptimize-sibling-calls -fprefetch-loop-arrays -fno-thread-jumps -fschedule-insns2 -fgcse-lm -floop-block -frename-registers -funroll-all-loops -fstrict-aliasing -fwhole-program -mfpu=neon-fp-armv8 -mfloat-abi=hard\"" >> ./.config
	# echo "CONFIG_TARGET_OPTIMIZATION=\"-Ofast -pipe -march=armv8-a+crypto+crc+fp-armv8+simd+neon+vfpv4+dotprod+fp16 -mcpu=cortex-a53+crypto+crc+neon+vfpv4 -mtune=cortex-a53 -ffast-math -flto=full -funroll-loops -ftree-vectorize -fomit-frame-pointer -funswitch-loops -finline-functions -fgcse-after-reload -fipa-sra -fprefetch-loop-arrays -floop-parallelize-all -flink-time-optimization -frename-registers -funroll-all-loops -fstrict-aliasing -fwhole-program -mfpu=neon-fp-armv8 -mfloat-abi=hard -fsched2-use-superblocks -fgraphite-identity -ftree-loop-im -floop-nest-optimize -ftree-builtin-call-dce -floop-block -fprofile-use -fprofile-generate -funroll-loops -fomit-frame-pointer -fschedule-insns -fstack-protector-strong -foptimize-sibling-calls -fno-tree-vrp -fno-tree-scev-cprop -fno-fat-lto-objects -falign-functions=64 -falign-loops=64 -falign-jumps=64 -falign-labels=64 -fbranch-target-load-optimize -fmax-inline-insns-single=500 -ftree-loop-distribute-patterns -fno-tree-vectorize -ftree-loop-im -floop-nest-optimize -floop-interchange -ftree-vec-threshold=512 -foptimize-sibling-calls -fprefetch-loop-arrays -fno-thread-jumps -fschedule-insns2 -fgcse-lm -floop-block -frename-registers -funroll-all-loops -fstrict-aliasing -fwhole-program -mfpu=neon-fp-armv8 -mfloat-abi=hard -fomit-frame-pointer -fno-inline-functions -fno-rtti -fno-exceptions -fno-implicit-templates -fno-defer-pop -ffunction-sections -fdata-sections -fno-builtin -fno-strict-aliasing -fvisibility=hidden -ffast-math -fno-math-errno -fno-unsafe-math-optimizations -fno-new-eh-contract -fno-math-errno -falign-functions=64 -fno-inline -fno-builtin -fno-defer-pop -fexpensive-optimizations -fno-unroll-loops -fsingle-precision-constant -ffp-contract=fast -fwhole-program -fdiagnostics-color=never\"" >> ./.config
	# echo "CONFIG_TARGET_OPTIMIZATION=\"-Ofast -pipe -march=armv8-a+crypto+crc+simd+neon+vfpv4+fp-armv8+dotprod+fp16+advanced-neon -mcpu=cortex-a53+crypto+crc+neon+vfpv4 -mtune=cortex-a53 -ffast-math -flto=full -funroll-loops -fivopts -ftree-vectorize -fomit-frame-pointer -fno-strict-aliasing -funswitch-loops -finline-functions -frename-registers -fgcse-after-reload -floop-parallelize-all -floop-interchange -floop-nest-optimize -fgraphite-identity -floop-block -fprofile-use -fprofile-generate -fschedule-insns2 -fschedule-insns -foptimize-sibling-calls -ftree-loop-distribute-patterns -fno-tree-vrp -fno-tree-scev-cprop -fno-fat-lto-objects -fno-builtin -fno-rtti -fno-exceptions -fno-defer-pop -fvisibility=hidden -fwhole-program -fno-unsafe-math-optimizations -fno-math-errno -funroll-all-loops -fno-stack-protector -fexpensive-optimizations -fstrict-aliasing -fgraphite-identity -fsingle-precision-constant -ftree-builtin-call-dce -floop-unroll-and-jam -fstack-protector-strong -fno-inline -fno-defer-pop -ftree-loop-im -falign-functions=64 -falign-loops=64 -falign-jumps=64 -falign-labels=64 -fbranch-target-load-optimize -ftree-slp-vectorize -ffunction-sections -fdata-sections -fno-inline-functions -fomit-frame-pointer -fno-implicit-templates -fprofile-dir=/tmp/prof -ftree-ccp -fgcse-lm -fprefetch-loop-arrays -fno-inline-small-functions -fno-builtin -fno-strict-aliasing -fschedule-insns -fmax-inline-insns-single=1000 -ftree-loop-distribute-patterns -fno-lto -falign-jumps=64 -ftree-vectorize -fomit-frame-pointer -ftree-slp-vectorize -floop-nest-optimize -floop-interchange -fgraphite-identity -fno-defer-pop -ftree-loop-block -fgraphite-identity -fno-unroll-loops -ftree-vect-loop-version -fno-thread-jumps -fstack-clash-protection -fprofile-generate -fprofile-use\"" >> ./.config
	# echo "CONFIG_TARGET_OPTIMIZATION=\"-Ofast -pipe -march=armv8-a+crypto+crc+simd+neon+vfpv4+fp-armv8+dotprod+fp16+advanced-neon -mcpu=cortex-a53+crypto+crc+neon+vfpv4 -mtune=cortex-a53 -ffast-math -flto=full -funroll-loops -fivopts -ftree-vectorize -fomit-frame-pointer -fno-strict-aliasing -funswitch-loops -finline-functions -frename-registers -fgcse-after-reload -floop-parallelize-all -floop-interchange -floop-nest-optimize -fgraphite-identity -floop-block -fprofile-use -fprofile-generate -fschedule-insns2 -fschedule-insns -foptimize-sibling-calls -ftree-loop-distribute-patterns -fno-tree-vrp -fno-tree-scev-cprop -fno-fat-lto-objects -fno-builtin -fno-rtti -fno-exceptions -fno-defer-pop -fvisibility=hidden -fwhole-program -fno-unsafe-math-optimizations -fno-math-errno -funroll-all-loops -fno-stack-protector -fexpensive-optimizations -fstrict-aliasing -fgraphite-identity -fsingle-precision-constant -ftree-builtin-call-dce -floop-unroll-and-jam -fstack-protector-strong -fno-inline -fno-defer-pop -ftree-loop-im -falign-functions=64 -falign-loops=64 -falign-jumps=64 -falign-labels=64 -fbranch-target-load-optimize -ftree-slp-vectorize -ffunction-sections -fdata-sections -fno-inline-functions -fomit-frame-pointer -fno-implicit-templates -fprofile-dir=/tmp/prof -ftree-ccp -fgcse-lm -fprefetch-loop-arrays -fno-inline-small-functions -fno-builtin -fno-strict-aliasing -fschedule-insns -fmax-inline-insns-single=1000 -ftree-loop-distribute-patterns -fno-lto -falign-jumps=64 -ftree-vectorize -fomit-frame-pointer -ftree-slp-vectorize -floop-nest-optimize -floop-interchange -fgraphite-identity -fno-defer-pop -ftree-loop-block -fgraphite-identity -fno-unroll-loops -ftree-vect-loop-version -fno-thread-jumps -fstack-clash-protection -fprofile-generate -fprofile-use -ftree-vectorize -ftree-slp-vectorize -floop-nest-optimize -ftree-builtin-call-dce -fsingle-precision-constant -fgraphite-identity -fno-tree-vrp -ftree-loop-distribute-patterns -floop-parallelize-all -fno-fat-lto-objects -fno-builtin -fno-stack-protector -fvisibility=hidden -fwhole-program -foptimize-sibling-calls -floop-block -fno-builtin -fgraphite-identity -falign-functions=64 -ftree-builtin-call-dce -ftree-loop-unroll-and-jam -ftree-slp-vectorize -falign-functions=64 -fno-profile-arcs -ftree-vect-loop-version -fprofile-generate -fprofile-use -fgraphite-identity -fno-builtin -fvisibility=hidden -foptimize-sibling-calls -fno-fat-lto-objects -fmax-inline-insns-single=1000 -fno-lto\"" >> ./.config
	##echo "CONFIG_TARGET_OPTIMIZATION=\"-O3 -pipe -march=armv8-a+crypto+crc+simd+neon+vfpv4+fp-armv8+dotprod+fp16+advanced-neon -mcpu=cortex-a53+crypto+crc+neon+vfpv4 -mtune=cortex-a53 -ffast-math -flto=full -funroll-loops -fivopts -ftree-vectorize -fomit-frame-pointer -fno-strict-aliasing -funswitch-loops -finline-functions -frename-registers -fgcse-after-reload -floop-parallelize-all -floop-interchange -floop-nest-optimize -fgraphite-identity -floop-block -fprofile-use -fprofile-generate -fschedule-insns2 -fschedule-insns -foptimize-sibling-calls -ftree-loop-distribute-patterns -fno-tree-vrp -fno-tree-scev-cprop -fno-fat-lto-objects -fno-builtin -fno-rtti -fno-exceptions -fno-defer-pop -fvisibility=hidden -fwhole-program -fno-unsafe-math-optimizations -fno-math-errno -funroll-all-loops -fno-stack-protector -fexpensive-optimizations -fstrict-aliasing -fgraphite-identity -fsingle-precision-constant -ftree-builtin-call-dce -floop-unroll-and-jam -fstack-protector-strong -fno-inline -fno-defer-pop -ftree-loop-im -falign-functions=64 -falign-loops=64 -falign-jumps=64 -falign-labels=64 -fbranch-target-load-optimize -ftree-slp-vectorize -ffunction-sections -fdata-sections -fno-inline-functions -fomit-frame-pointer -fno-implicit-templates -fprofile-dir=/tmp/prof -ftree-ccp -fgcse-lm -fprefetch-loop-arrays -fno-inline-small-functions -fno-builtin -fno-strict-aliasing -fschedule-insns -fmax-inline-insns-single=1000 -ftree-loop-distribute-patterns -fno-lto -falign-jumps=64 -ftree-vectorize -fomit-frame-pointer -ftree-slp-vectorize -floop-nest-optimize -floop-interchange -fgraphite-identity -fno-defer-pop -ftree-loop-block -fgraphite-identity -fno-unroll-loops -ftree-vect-loop-version -fno-thread-jumps -fstack-clash-protection -fprofile-generate -fprofile-use -ftree-vectorize -ftree-slp-vectorize -floop-nest-optimize -ftree-builtin-call-dce -fsingle-precision-constant -fgraphite-identity -fno-tree-vrp -ftree-loop-distribute-patterns -floop-parallelize-all -fno-fat-lto-objects -fno-builtin -fno-stack-protector -fvisibility=hidden -fwhole-program -foptimize-sibling-calls -floop-block -fno-builtin -fgraphite-identity -falign-functions=64 -ftree-builtin-call-dce -ftree-loop-unroll-and-jam -ftree-slp-vectorize -falign-functions=64 -fno-profile-arcs -ftree-vect-loop-version -fprofile-generate -fprofile-use -fgraphite-identity -fno-builtin -fvisibility=hidden -foptimize-sibling-calls -fno-fat-lto-objects -fmax-inline-insns-single=1000 -fno-lto\"" >> ./.config
	# echo "CONFIG_TARGET_OPTIMIZATION=\"-Ofast -pipe -march=armv8-a+crypto+crc+simd+neon+vfpv4+fp-armv8+dotprod+fp16+advanced-neon -mcpu=cortex-a53+crypto+crc+neon+vfpv4 -mtune=cortex-a53 -ffast-math -flto=full -funroll-loops -fivopts -ftree-vectorize -fomit-frame-pointer -fno-strict-aliasing -funswitch-loops -finline-functions -frename-registers -fgcse-after-reload -floop-parallelize-all -floop-interchange -floop-nest-optimize -fgraphite-identity -floop-block -fprofile-use -fprofile-generate -fschedule-insns2 -fschedule-insns -foptimize-sibling-calls -ftree-loop-distribute-patterns -fno-tree-vrp -fno-tree-scev-cprop -fno-fat-lto-objects -fno-builtin -fno-rtti -fno-exceptions -fno-defer-pop -fvisibility=hidden -fwhole-program -fno-unsafe-math-optimizations -fno-math-errno -funroll-all-loops -fno-stack-protector -fexpensive-optimizations -fstrict-aliasing -fgraphite-identity -fsingle-precision-constant -ftree-builtin-call-dce -floop-unroll-and-jam -fstack-protector-strong -fno-inline -fno-defer-pop -ftree-loop-im -falign-functions=64 -falign-loops=64 -falign-jumps=64 -falign-labels=64 -fbranch-target-load-optimize -ftree-slp-vectorize -ffunction-sections -fdata-sections -fno-inline-functions -fomit-frame-pointer -fno-implicit-templates -fprofile-dir=/tmp/prof -ftree-ccp -fgcse-lm -fprefetch-loop-arrays -fno-inline-small-functions -fno-builtin -fno-strict-aliasing -fschedule-insns -fmax-inline-insns-single=1000 -ftree-loop-distribute-patterns -fno-lto -falign-jumps=64 -ftree-vectorize -fomit-frame-pointer -ftree-slp-vectorize -floop-nest-optimize -floop-interchange -fgraphite-identity -fno-defer-pop -ftree-loop-block -fgraphite-identity -fno-unroll-loops -ftree-vect-loop-version -fno-thread-jumps -fstack-clash-protection -fprofile-generate -fprofile-use -fgraphite-identity -fno-builtin -fvisibility=hidden -foptimize-sibling-calls -fno-fat-lto-objects -fmax-inline-insns-single=1000 -fno-lto\"" >> ./.config
  	# echo "CONFIG_TARGET_OPTIMIZATION=\"-Ofast -pipe -march=armv8-a+crypto+crc+simd+neon+vfpv4+fp-armv8+dotprod+fp16+advanced-neon -mcpu=cortex-a53+crypto+crc+neon+vfpv4 -mtune=cortex-a53 -ffast-math -flto=full -funroll-all-loops -fivopts -ftree-vectorize -fomit-frame-pointer -fno-strict-aliasing -funswitch-loops -finline-functions -frename-registers -fgcse-after-reload -floop-parallelize-all -floop-interchange -floop-nest-optimize -fgraphite-identity -floop-block -fprofile-use -fprofile-generate -fschedule-insns2 -fschedule-insns -foptimize-sibling-calls -ftree-loop-distribute-patterns -fno-tree-vrp -fno-tree-scev-cprop -fno-fat-lto-objects -fno-builtin -fno-rtti -fno-exceptions -fno-defer-pop -fvisibility=hidden -fwhole-program -fno-unsafe-math-optimizations -fno-math-errno -funroll-all-loops -fno-stack-protector -fexpensive-optimizations -fstrict-aliasing -fgraphite-identity -fsingle-precision-constant -ftree-builtin-call-dce -floop-unroll-and-jam -fstack-protector-strong -fno-inline -fno-defer-pop -ftree-loop-im -falign-functions=64 -falign-loops=64 -falign-jumps=64 -falign-labels=64 -fbranch-target-load-optimize -ftree-slp-vectorize -ffunction-sections -fdata-sections -fno-inline-functions -fomit-frame-pointer -fno-implicit-templates -fprofile-dir=/tmp/prof -ftree-ccp -fgcse-lm -fprefetch-loop-arrays -fno-inline-small-functions -fno-builtin -fno-strict-aliasing -fschedule-insns -fmax-inline-insns-single=1000 -ftree-loop-distribute-patterns -fno-lto -falign-jumps=64 -ftree-vectorize -fomit-frame-pointer -ftree-slp-vectorize -floop-nest-optimize -floop-interchange -fgraphite-identity -fno-defer-pop -ftree-loop-block -fgraphite-identity -fno-unroll-loops -ftree-vect-loop-version -fno-thread-jumps -fstack-clash-protection -fprofile-generate -fprofile-use -fgraphite-identity -fno-builtin -fvisibility=hidden -foptimize-sibling-calls -fno-fat-lto-objects -fmax-inline-insns-single=1000 -fno-lto\"" >> ./.config
   	# echo "CONFIG_TARGET_OPTIMIZATION=\"-Ofast -pipe -march=armv8-a+crypto+crc+simd+neon+vfpv4+fp-armv8+fp16+dotprod+advanced-neon -mcpu=cortex-a53+crypto+crc+neon+vfpv4 -mtune=cortex-a53 -ffast-math -flto=full -funroll-all-loops -fivopts -ftree-vectorize -fomit-frame-pointer -fno-strict-aliasing -funswitch-loops -finline-functions -frename-registers -fgcse-after-reload -floop-parallelize-all -floop-interchange -floop-nest-optimize -fgraphite-identity -floop-block -fprofile-use -fprofile-generate -fschedule-insns2 -fschedule-insns -foptimize-sibling-calls -ftree-loop-distribute-patterns -fno-tree-vrp -fno-tree-scev-cprop -fno-fat-lto-objects -fno-builtin -fno-rtti -fno-exceptions -fno-defer-pop -fvisibility=hidden -fwhole-program -fno-unsafe-math-optimizations -fno-math-errno -funroll-all-loops -fno-stack-protector -fexpensive-optimizations -fstrict-aliasing -fgraphite-identity -fsingle-precision-constant -ftree-builtin-call-dce -floop-unroll-and-jam -fstack-protector-strong -fno-inline -fno-defer-pop -ftree-loop-im -falign-functions=64 -falign-loops=64 -falign-jumps=64 -falign-labels=64 -fbranch-target-load-optimize -ftree-slp-vectorize -ffunction-sections -fdata-sections -fno-inline-functions -fomit-frame-pointer -fno-implicit-templates -fprofile-dir=/tmp/prof -ftree-ccp -fgcse-lm -fprefetch-loop-arrays -fno-inline-small-functions -fno-builtin -fno-strict-aliasing -fschedule-insns -fmax-inline-insns-single=1000 -ftree-loop-distribute-patterns -fno-lto -falign-jumps=64 -ftree-vectorize -fomit-frame-pointer -ftree-slp-vectorize -floop-nest-optimize -floop-interchange -fgraphite-identity -fno-defer-pop -ftree-loop-block -fgraphite-identity -fno-unroll-loops -ftree-vect-loop-version -fno-thread-jumps -fstack-clash-protection -fprofile-generate -fprofile-use -fgraphite-identity -fno-builtin -fvisibility=hidden -foptimize-sibling-calls -fno-fat-lto-objects -fmax-inline-insns-single=1000 -fno-lto\"" >> ./.config
    	# echo "CONFIG_TARGET_OPTIMIZATION=\"-Ofast -pipe -march=armv8-a+crypto+crc+simd+neon+fp-armv8+vfpv4+dotprod+advanced-neon+fp16 -mtune=cortex-a53+simd+crypto -ffast-math -funroll-loops -ftree-vectorize -floop-unroll-and-jam -fno-trapping-math -flto=full -fwhole-program -fno-unsafe-math-optimizations -fexpensive-optimizations -fomit-frame-pointer -fno-icf -fmerge-all-constants -frename-registers -fno-fat-lto-objects -fprefetch-loop-arrays -finline-functions -finline-limit=1000000 -fno-inline-functions-called-once -funroll-all-loops -funswitch-loops -fno-inline-small-functions -fno-inline -fno-strict-aliasing -fno-thread-jumps -fno-stack-clash-protection -fno-unroll-loops -fno-builtin -fno-strict-aliasing -fschedule-insns -fmax-inline-insns-single=1000 -ftree-loop-distribute-patterns -fno-lto -falign-jumps=64 -ftree-vectorize -fomit-frame-pointer -ftree-slp-vectorize -floop-nest-optimize -fgraphite-identity -floop-block\""
fi

# eBPF
echo "CONFIG_DEVEL=y" >> ./.config
echo "CONFIG_BPF_TOOLCHAIN_HOST=y" >> ./.config
echo "# CONFIG_BPF_TOOLCHAIN_NONE is not set" >> ./.config
echo "CONFIG_KERNEL_BPF_EVENTS=y" >> ./.config
echo "CONFIG_KERNEL_CGROUP_BPF=y" >> ./.config
echo "CONFIG_KERNEL_DEBUG_INFO=y" >> ./.config
echo "CONFIG_KERNEL_DEBUG_INFO_BTF=y" >> ./.config
echo "# CONFIG_KERNEL_DEBUG_INFO_REDUCED is not set" >> ./.config
echo "CONFIG_KERNEL_XDP_SOCKETS=y" >> ./.config

#修改jdc re-ss-01 (亚瑟) 的内核大小为12M
sed -i "/^define Device\/jdcloud_re-ss-01/,/^endef/ { /KERNEL_SIZE := 6144k/s//KERNEL_SIZE := 12288k/ }" target/linux/qualcommax/image/ipq60xx.mk

#修改jdc re-cs-02 (雅典娜) 的内核大小为12M
sed -i "/^define Device\/jdcloud_re-cs-02/,/^endef/ { /KERNEL_SIZE := 6144k/s//KERNEL_SIZE := 12288k/ }" target/linux/qualcommax/image/ipq60xx.mk

#修改jdc re-cs-07 (太乙) 的内核大小为12M
sed -i "/^define Device\/jdcloud_re-cs-07/,/^endef/ { /KERNEL_SIZE := 6144k/s//KERNEL_SIZE := 12288k/ }" target/linux/qualcommax/image/ipq60xx.mk

# 想要剔除的
# echo "CONFIG_PACKAGE_htop=n" >> ./.config
# echo "CONFIG_PACKAGE_iperf3=n" >> ./.config
echo "CONFIG_PACKAGE_luci-app-wolplus=n" >> ./.config
echo "CONFIG_PACKAGE_luci-app-tailscale=n" >> ./.config
echo "CONFIG_PACKAGE_luci-app-advancedplus=n" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-kucat=n" >> ./.config
# 一定要禁止编译这个coremark 不然会导致编译失败
echo "CONFIG_PACKAGE_coremark=n" >> ./.config

# 可以让FinalShell查看文件列表并且ssh连上不会自动断开
echo "CONFIG_PACKAGE_openssh-sftp-server=y" >> ./.config
# 解析、查询、操作和格式化 JSON 数据
echo "CONFIG_PACKAGE_jq=y" >> ./.config
# 简单明了的系统资源占用查看工具
echo "CONFIG_PACKAGE_btop=y" >> ./.config
# 多网盘存储
echo "CONFIG_PACKAGE_luci-app-alist=y" >> ./.config
# 强大的工具Lucky大吉(需要添加源或git clone)
echo "CONFIG_PACKAGE_luci-app-lucky=y" >> ./.config
# 网络通信工具
echo "CONFIG_PACKAGE_curl=y" >> ./.config
# BBR 拥塞控制算法(终端侧)
# echo "CONFIG_PACKAGE_kmod-tcp-bbr=y" >> ./.config
# echo "CONFIG_DEFAULT_tcp_bbr=y" >> ./.config
# 磁盘管理
echo "CONFIG_PACKAGE_luci-app-diskman=y" >> ./.config
# 其他调整
# 大鹅
echo "CONFIG_PACKAGE_luci-app-daed=y" >> ./.config
# 大鹅-next
# echo "CONFIG_PACKAGE_luci-app-daed-next=y" >> ./.config
＃ 连上ssh不会断开并且显示文件管理
echo "CONFIG_PACKAGE_openssh-sftp-server"=y
# docker只能集成
echo "CONFIG_PACKAGE_luci-app-dockerman=y" >> ./.config

# qBittorrent
echo "CONFIG_PACKAGE_luci-app-qbittorrent=y" >> ./.config
# 添加Homebox内网测速
# echo "CONFIG_PACKAGE_luci-app-homebox=y" >> ./.config
# V2rayA
echo "CONFIG_PACKAGE_luci-app-v2raya=y" >> ./.config
# NSS的sqm
echo "CONFIG_PACKAGE_luci-app-sqm=y" >> ./.config
echo "CONFIG_PACKAGE_sqm-scripts-nss=y" >> ./.config
# istore 编译报错
# echo "CONFIG_PACKAGE_luci-app-istorex=y" >> ./.config
# QuickStart
# echo "CONFIG_PACKAGE_luci-app-quickstart=y" >> ./.config
