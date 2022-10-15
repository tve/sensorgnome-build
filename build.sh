#! /bin/bash -e

CODENAME=$1
MANIFEST=${2:-manifest-armv7-rpi-bullseye}
source $MANIFEST

# Pull docker images we will need explicitly so we get an error here where the problem is obvious
# as opposed to later in the midst of something else
docker pull $PIMOD_IMAGE

# If we don't have it, create the base image
PIFILE=base-$TYPE.pifile
BASE_ZIP=base-$TYPE-$(echo $OS_IMAGE | cat - $PIFILE | cksum | cut -f1 -d" ").zip
BASE_IMG=base-$TYPE.img
if [[ -f images/$BASE_ZIP ]]; then
    echo ""
    echo "*** Extracting base image: $BASE_IMG"
    (cd images; rm -f $BASE_IMG; 7z x -bd $BASE_ZIP $BASE_IMG)
else
    echo images/$BASE_ZIP not found
    echo ""
    echo "*** Building base image: $BASE_IMG"
    echo "Hit ctrl-C to cancel...."
    sleep 5
    ./build-baseimg.sh $MANIFEST
fi

# Create sensorgnome image
V=$(TZ=PST8PDT date +%Y-%j)
echo ""
echo "*** Building sensorgnome image: images/sg-$TYPE-$V.zip"
set -x
docker run --rm --privileged \
    -v $PWD:/sg \
    -e PATH=/pimod:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    -e TYPE=$TYPE \
    -e V=$V \
    -e CODENAME=$CODENAME \
    --workdir=/sg \
    $PIMOD_IMAGE \
    pimod.sh /sg/sg-$TYPE.pifile
#    -e "SG_DEBS=$SG_DEBS" \
set +x
[[ $CODENAME == 'testing' ]] && $V=testing-$V
mv -f images/sg-$TYPE-temp.img images/sg-$TYPE-$V.img
rm -f images/sg-$TYPE-$V.zip
(cd images; zip sg-$TYPE-$V.zip sg-$TYPE-$V.img)
#(cd images; 7z a sg-$TYPE-$V.zip sg-$TYPE-$V.img)

echo ""
echo "*** sensorgnome image built: images/sg-$TYPE-$V.img"
ls -lh images/sg-$TYPE-$V.*
