#!/bin/sh
## 安装iStore 参考 https://github.com/linkease/istore
ISTORE_REPO=https://istore.linkease.com/repo/all/store
FCURL="curl --fail --show-error"

curl -V >/dev/null 2>&1 || {
    echo "prereq: install curl"
    opkg info curl | grep -Fqm1 curl || opkg update
    opkg install curl
}

IPK=$($FCURL "$ISTORE_REPO/Packages.gz" | zcat | grep -m1 '^Filename: luci-app-store.*\.ipk$' | sed -n -e 's/^Filename: \(.\+\)$/\1/p')

[ -n "$IPK" ] || exit 1

$FCURL "$ISTORE_REPO/$IPK" | tar -xzO ./data.tar.gz | tar -xzO ./bin/is-opkg >/tmp/is-opkg

[ -s "/tmp/is-opkg" ] || exit 1

chmod 755 /tmp/is-opkg
/tmp/is-opkg update
# /tmp/is-opkg install taskd
/tmp/is-opkg opkg install --force-reinstall luci-lib-taskd luci-lib-xterm
/tmp/is-opkg opkg install --force-reinstall luci-app-store || exit $?
[ -s "/etc/init.d/tasks" ] || /tmp/is-opkg opkg install --force-reinstall taskd
[ -s "/usr/lib/lua/luci/cbi.lua" ] || /tmp/is-opkg opkg install luci-compat >/dev/null 2>&1
