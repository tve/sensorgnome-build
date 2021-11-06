#! /bin/bash -e

MANIFEST=${1:-manifest-armv7-rpi-buster}
source $MANIFEST

# Pull docker images we will need explicitly so we get an error here where the problem is obvious
# as opposed to later in the midst of something else
docker pull $PIMOD_IMAGE

# Extract operating system image frmo zip archive
mkdir -p images
IMAGE_ZIP=${OS_IMAGE##*/}
IMAGE_IMG=${IMAGE_ZIP/%.zip/.img}
echo OS Image: $OS_IMAGE
if [[ ! -f images/$IMAGE_IMG ]]; then
    wget -q -O images/$IMAGE_ZIP $OS_IMAGE
    (cd images; 7z x $IMAGE_ZIP $IMAGE_IMG)
fi

# Ensure we have the dockcross script
#docker pull $DOCKCROSS_IMAGE
#DOCKCROSS_SCRIPT=${DOCKCROSS_IMAGE##*/}
#DOCKCROSS_SCRIPT=$PWD/${DOCKCROSS_SCRIPT/:/-}
#docker run --rm $DOCKCROSS_IMAGE >$DOCKCROSS_SCRIPT

# If we don't have it, create the base image
if [[ ! -f images/base-$TYPE.img ]]; then
    echo ""
    echo "*** Building base image: images/base-$TYPE.img"
    docker run --rm --privileged \
        -v $PWD:/sg \
        -e PATH=/pimod:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        -e IMAGE_IMG=$IMAGE_IMG \
        -e TYPE=$TYPE \
        --workdir=/sg \
        $PIMOD_IMAGE \
        pimod.sh /sg/base-$TYPE.pifile
    mv images/base-$TYPE-temp.img images/base-$TYPE.img
else
    echo ""
    echo "*** Using base image: images/base-$TYPE.img"
fi

# Fetch remote packages, iterate through $SG_DEBS and wget the ones starting with http
# into a packages subdir, then alter SG_DEBS so it points to these local files.
mkdir -p packages
pp=""
for p in ${SG_DEBS[@]}; do
    if [[ "$p" =~ http.* ]]; then
        f=packages/${p##*/}
        echo "*** Fetching $p -> $f"
        if [[ -f $f ]]; then
            curl -LRs -z $f -o $f $p
        else
            curl -LRs -o $f $p
        fi
        pp="$pp $f"
    else
        pp="$pp $p"
    fi
done
SG_DEBS="$pp"

# Create sensorgnome image
echo ""
echo "*** Building sensorgnome image: images/sg-$TYPE.img"
set -x
docker run --rm --privileged \
    -v $PWD:/sg \
    -e PATH=/pimod:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    -e TYPE=$TYPE \
    -e "SG_DEBS=$SG_DEBS" \
    --workdir=/sg \
    $PIMOD_IMAGE \
    pimod.sh /sg/sg-$TYPE.pifile
set +x
V=$(date +%Y-%j)
mv -f images/sg-$TYPE-temp.img images/sg-$TYPE-$V.img

echo ""
echo "*** sensorgnome image built: images/sg-$TYPE-$V.img"
ls -lh images/sg-$TYPE-$V.img
