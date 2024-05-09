# Configurations

KERNEL_SRC="/home/clf/linux-5.10/bc-repos-llvm-15/linux-5.10.100"
IRDUMPER="/home/clf/mlta/IRDumper/build/lib/libDumper.so"
CLANG="/home/clf/llvm-project/build/bin/clang-15"
CONFIG="defconfig"
#CONFIG="allyesconfig"

# Use -Wno-error to avoid turning warnings into errors
NEW_CMD="\n\n\
KBUILD_USERCFLAGS += -Wno-error -g -Xclang -no-opaque-pointers -Xclang -flegacy-pass-manager -Xclang -load -Xclang $IRDUMPER\nKBUILD_CFLAGS += -Wno-error -g -Xclang -no-opaque-pointers -Xclang -flegacy-pass-manager -Xclang -load -Xclang $IRDUMPER"

# Back up Linux Makefile
#cp $KERNEL_SRC/Makefile $KERNEL_SRC/Makefile.bak

if [ ! -f "$KERNEL_SRC/Makefile.bak" ]; then
	echo "Back up Linux Makefile first"
	exit 1
fi

# The new flags better follow "# Add user supplied CPPFLAGS, AFLAGS and CFLAGS as the last assignments"
echo `-e` "$NEW_CMD" >$KERNEL_SRC/IRDumper.cmd
cat $KERNEL_SRC/Makefile.bak $KERNEL_SRC/IRDumper.cmd >$KERNEL_SRC/Makefile

cd $KERNEL_SRC
# make $CONFIG
echo $CLANG
echo $NEW_CMD
make CC=$CLANG -j`nproc` -k -i
