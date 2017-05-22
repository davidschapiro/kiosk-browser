#!/bin/bash
function die() { echo 1>&2 ERROR: "$@" ; exit 1 ; }

for s in xsession.sh kiosk-browser-control ; do
  bash -n $s || die "$s syntax error"
done

visudo -c -s -f sudoers || die "sudoers syntax error"

xmllint -noout openbox-rc.xml || die "openbox-rc.xml syntax error"