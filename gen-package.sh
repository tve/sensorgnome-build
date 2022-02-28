#! /bin/bash -e
DESTDIR=build-temp
rm -rf $DESTDIR
mkdir $DESTDIR

# Set version in version file (goes into /etc/sensorgnome)
DEST=$DESTDIR/etc/sensorgnome
install -d $DEST
TZ=PST8PDT date +'SG %Y-%j' > $DEST/version

# Boilerplate package generation
cp -r DEBIAN $DESTDIR
sed -e "/^Version/s/:.*/: $(TZ=PST8PDT date +%Y.%j)/" -i $DESTDIR/DEBIAN/control # set version: YYYY.DDD
mkdir -p packages
dpkg-deb --root-owner-group --build $DESTDIR packages
# dpkg-deb --contents ../packages
ls -lh packages
