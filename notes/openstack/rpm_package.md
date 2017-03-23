# RPM包制作流程
  
## 环境准备

1. 系统环境: redhat系列系统，我这里以使用CentOS 7.0为例

    * 不建议使用root用户执行打包操作，以免破坏系统原有环境

2. 安装环境依赖
    
    * rpm打包依赖rpm-build和rpmdevtools

## Step by Step

1. 执行```rpm --showrc|grep _topdir```查看_topdir位置，通常为```~/rpmbuild/```目录，这个目录很重要，
因为接下来的打包都是在这个顶层目录下进行的

2. 执行```rpmdev-setuptree```创建rpmbuild目录及子目录

3. copy源码压缩文件及相关文件到```~/rpmbuild/SOURCES/```目录下

4. 接下来就是编写spec文件了, spec文件位于```~/rpmbuild/SPECS```目录下,关于spec文件的详细解释参照[SPEC文件说明](# SPEC文件说明)

5. Finally，执行```rpmbuild -bb xxx.spec```

```
整个过程串起来就是这样的，以openvswitch的rpm包制作为例
[makerpm@localhost ~]$ yum install -q -y rpm-build rpmdevtools *---->安装依赖*
[makerpm@localhost ~]$ rpm --showrc|grep _topdir  *---->查看_topdir*
-14: _builddir  %{_topdir}/BUILD
-14: _buildrootdir      %{_topdir}/BUILDROOT
-14: _rpmdir    %{_topdir}/RPMS
-14: _sourcedir %{_topdir}/SOURCES
-14: _specdir   %{_topdir}/SPECS
-14: _srcrpmdir %{_topdir}/SRPMS
-14: _topdir    %(echo $HOME)/rpmbuild  *---->表明topdir为~/rpmbuild*
[makerpm@localhost ~]$ rpmdev-setuptree  *---->创建rpmbuild目录及子目录*
[makerpm@localhost ~]$ tree rpmbuild/
rpmbuild/
├── BUILD
├── RPMS
├── SOURCES
├── SPECS
└── SRPMS
[makerpm@localhost ~]$ cp /tmp/ovs-20160909.tar.gz ~/rpmbuild/SOURCES/  *---->copy源码压缩文件*
[makerpm@localhost ~]$ cp /tmp/ovs.service ~/rpmbuild/SOURCES/  *---->systemctl service文件*
[makerpm@localhost ~]$ cp /tmp/ovs.sh /tmp/stopovs.sh ~/rpmbuild/SOURCES/  *---->ovs service 启动和停止脚本*
[makerpm@localhost SPECS]$ cd ~/rpmbuild/SPECS/

生成spec模板，对于制作简单的安装包可以直接执行rpmdev-newspec，对于ovs这类相对复杂的软件可以从源码包里找
spec文件作为模板，再在此基础上进行定制。比如ovs的spec文件可以在```ovs-20160909/rhel/openvswitch.spec```找到
[makerpm@localhost SPECS]$ rpmdev-newspec -o ovs-20160909.spec 
或者从源码包copy spec文件作为模板
[makerpm@localhost SPECS]$ cp /tmp/ovs-20160909/rhel/openvswitch.spec ovs-20160909.spec

定制spec文件(关键步骤，十分重要！！)
[makerpm@localhost SPECS]$ vi ovs-20160909.spec

[makerpm@localhost SPECS]$ rpmbuild -bb ovs-20160909.spec
[makerpm@localhost SPECS]$ ls ~/rpmbuild/RPMS/x86_64/
ovs-20160909-1.x86_64.rpm  *---->最终生成的rpm包在此>_< !!!*
```

## SPEC文件说明

```
以省略版的ovs-20160909.spec为例， *注意---->之后为注释*

# ovs-20160909.spec

Name:		ovs    *---->软件包名*
Summary:	Custom OpenvSwitch  *---->软件包大致功能概要*
Group: 		System Environment/Daemons * ---->软件包类型*
Version: 	20160909    *---->这个就是软件包的版本*
Release: 	1 *---->软件包释出号*
License:        Commercial   *---->licence, 可以是Apache，MIT，GPL，Commecial等等 *
URL:            http://custom.com   *---->随便填*

Source0: 	ovs-%{version}.tar.gz  *---->这里就是~/rpmbuild/SOURCES/目录下文件*
Source1: 	ovs.sh  *---->同上*
Source2:	stopovs.sh * ---->同上*
Source3:	ovs.service  *---->同上*
# Requires: 	openvswitch-kmod, logrotate, python * ---->软件包外部依赖*

%bcond_without check

%description *---->简要描述*
Custom OpenvSwitch

%prep *---->安装之前的执行脚本，可以写一些安装依赖的脚本*
yum install -y make
yum install -y gcc
yum install -y openssl-devel
yum install -y wget
yum install -y autoconf
yum install -y automake
yum install -y libtool
yum install -y perl
yum install -y kernel
yum install -y kernel-devel
%setup -q *---->这句的作用是解压~/rpmbuild/SOURCES目录下的压缩文件*

%build *---->build脚本*
./boot.sh
./configure --prefix=/usr/local --sysconfdir=/usr/local/etc --with-linux=/lib/modules/`uname -r`/build 
make

%install   *---->这个是关键的安装过程！！*
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
make modules_install

install -d -m755 $RPM_BUILD_ROOT/%{_unitdir}  *---->创建ovs.service安装目录*
install -m644 %{SOURCE3} $RPM_BUILD_ROOT/%{_unitdir}/ovs.service *---->安装ovs.service*

install -d -m755 $RPM_BUILD_ROOT/usr/local/bin
install -m744 %{SOURCE1} $RPM_BUILD_ROOT/usr/local/bin/ovs.sh  *---->安装ovs.sh, stopovs.sh*
install -m744 %{SOURCE2} $RPM_BUILD_ROOT/usr/local/bin/stopovs.sh

install -d -m 755 $RPM_BUILD_ROOT/usr/local/var/lib/openvswitch



%check    *---->这里会跑openvswitch功能测试，建议注释不然报错*
# %if %{with check}
#     if make check TESTSUITEFLAGS='%{_smp_mflags}' ||
#        make check TESTSUITEFLAGS='--recheck'; then :;
#     else
#         cat tests/testsuite.log
#         exit 1
#     fi
# %endif

%clean
rm -rf $RPM_BUILD_ROOT

%post    *---->rpm包安装完了后执行的脚本，可以把一些初始化工作相关脚本放这里*
/sbin/modprobe openvswitch  *---->内核加载ovs模块*
mkdir -p /usr/local/etc/openvswitch   *---->配置目录*
mkdir -p /usr/local/var/run/openvswitch
/usr/local/bin/ovsdb-tool create /usr/local/etc/openvswitch/conf.db    *---->创建ovsdb*
# Create default or update existing /etc/sysconfig/openvswitch.
SYSCONFIG=/etc/sysconfig/openvswitch
TEMPLATE=/usr/share/openvswitch/scripts/sysconfig.template
if [ ! -e $SYSCONFIG ]; then
    cp $TEMPLATE $SYSCONFIG
else
    for var in $(awk -F'[ :]' '/^# [_A-Z0-9]+:/{print $2}' $TEMPLATE)
    do
        if ! grep $var $SYSCONFIG >/dev/null 2>&1; then
            echo >> $SYSCONFIG
            sed -n "/$var:/,/$var=/p" $TEMPLATE >> $SYSCONFIG
        fi
    done
fi

# Ensure all required services are set to run
/sbin/chkconfig --add openvswitch
/sbin/chkconfig openvswitch on

%preun   *---->很好懂，全称是pre uninstall script，卸载之前执行的脚本*
if [ "$1" = "0" ]; then     # $1 = 0 for uninstall
    /sbin/service openvswitch stop
    /sbin/chkconfig --del openvswitch
fi

%postun   *---->post uninstall script*
if [ "$1" = "0" ]; then     # $1 = 0 for uninstall
    rm -f /usr/local/etc/openvswitch/conf.db
    rm -f /usr/local/etc/sysconfig/openvswitch
    rm -f /usr/local/etc/openvswitch/vswitchd.cacert
fi

exit 0

%files    *---->定义软件包所包含的软件，也就是执行```rpm -qpl ovs-20160909-1.x86_64.rpm```时期望会列出的文件*
%defattr(-,root,root)
/etc/init.d/openvswitch
%config(noreplace) /etc/logrotate.d/openvswitch
/etc/sysconfig/network-scripts/ifup-ovs
/etc/sysconfig/network-scripts/ifdown-ovs
/usr/local/bin/ovs-appctl
/usr/local/bin/ovs-ofctl
/usr/local/bin/ovs-vsctl
/usr/local/bin/ovsdb-client
/usr/local/bin/ovsdb-tool
/usr/local/sbin/ovs-vswitchd
/usr/local/sbin/ovsdb-server
...
...
...

%{_unitdir}/ovs.service *---->systemctl service文件， unitdir是个宏，也就是```/usr/lib/systemd/system```了*
/usr/local/bin/ovs.sh   *---->ovs 启动脚本*
/usr/local/bin/stopovs.sh   *---->ovs停止脚本*
```

## 参考文献

- [RPM 打包技术与典型 SPEC 文件分析](https://www.ibm.com/developerworks/cn/linux/l-rpm/)
- [使用 RPM 打包软件，第 1 部分: 构建和分发包](https://www.ibm.com/developerworks/cn/linux/l-rpm1/)

## By @ayakashi
