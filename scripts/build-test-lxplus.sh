# run:
# sh scripts/build-test-lxplus.sh [noecho] [cleanall]
# tail -f build-test-lxplus.out

# env settings
export LC_CTYPE="C"
export PATH="/afs/cern.ch/user/m/mad/madx/madX:$PATH"

# I/O redirection
if [ "$1" = "noecho" ] ; then
	shift
	exec &> build-test-lxplus.out
else
	exec 2>&1 | tee build-test-lxplus.out
fi
uname -n > build-test-lxplus.run

# error handler
check_error ()
{
	if [ "$?" != "0" ] ; then
		echo "ERROR: $1"
		exit 1
	fi
}

echo -e "\n===== Start of build and tests ====="
date
uname -m -n -r -s

echo -e "\n===== SVN update ====="
svn update
check_error "svn update failed"

echo -e "\n===== Release number ====="
cat VERSION

echo -e "\n===== Clean build ====="
if [ "$1" = "cleanall" ] ; then
	shift
	make cleanall
	check_error "make cleanall failed"
else
	echo "Skipped (no explicit request)."
fi 

echo -e "\n===== Gnu build ====="
source /afs/cern.ch/sw/lcg/contrib/gcc/4.8/i686-slc6-gcc48-opt/setup.sh
gcc      --version
g++      --version
gfortran --version
make all-linux32-gnu
# to handle bad fortran compiler, restart from scratch (only once)
if [ "$?" != "0" ] ; then 
	make cleanall && make cleanall ARCH=32
	check_error "make cleanall failed"
	make all-linux32-gnu
	check_error "make all-linux32-gnu failed"
fi

source /afs/cern.ch/sw/lcg/contrib/gcc/4.8/x86_64-slc6-gcc48-opt/setup.sh
gcc      --version
g++      --version
gfortran --version
make all-linux64-gnu
check_error "make all-linux64-gnu failed"

echo -e "\n===== Intel build ====="
source /afs/cern.ch/sw/IntelSoftware/linux/all-setup.sh ia32
icc      --version
ifort    --version
make all-linux32-intel all-linux32
check_error "make all-linux32-intel failed"

source /afs/cern.ch/sw/IntelSoftware/linux/all-setup.sh intel64
icc      --version
ifort    --version
make all-linux64-intel all-linux64
check_error "make all-linux64-intel failed"

echo -e "\n===== Binaries dependencies ====="
make infobindep
check_error "make infobindep failed"

echo -e "\n===== Tests pointless files ====="
make cleantest && make infotestdep
check_error "make infotestdep failed"

echo -e "\n===== Testing madx-linux64-intel ====="
make madx-linux64-intel && ls -l madx64 && make cleantest && make tests-all ARCH=64 NOCOLOR=yes
check_error "make tests-all for madx-linux64-intel failed"

echo -e "\n===== Testing madx-linux32-intel ====="
make madx-linux32-intel && ls -l madx32 && make cleantest && make tests-all ARCH=32 NOCOLOR=yes
check_error "make tests-all for madx-linux32-intel failed"

echo -e "\n===== Testing madx-linux64-gnu ====="
make madx-linux64-gnu && ls -l madx64 && make cleantest && make tests-all ARCH=64 NOCOLOR=yes
check_error "make tests-all for madx-linux64-gnu failed"

echo -e "\n===== Testing madx-linux32-gnu ====="
make madx-linux32-gnu && ls -l madx32 && make cleantest && make tests-all ARCH=32 NOCOLOR=yes
check_error "make tests-all for madx-linux32-gnu failed"

# restore the default version
make madx-linux32 > /dev/null && make madx-linux64 > /dev/null
check_error "unable to restore the default version"

# cleanup lxplus node
rm -f build-test-lxplus.run

# date & end marker
date
echo -e "\n===== End of build and tests ====="
