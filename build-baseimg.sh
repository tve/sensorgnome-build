#! /bin/bash -e
#
# Build the OS base image in images/base-...
# The base image is the original upstread image with additional standard software installed

if [[ ${1} == "--if-missing" ]]; then
    MISSING=yes
    shift
fi
if [[ ${1} == "--name" ]]; then
    NAME=yes
    shift
fi

MANIFEST=${1:-manifest-armv7-rpi-bullseye}
source $MANIFEST

# See whether we already have the image and skip building if requested (happens in github action)
PIFILE=base-$TYPE.pifile
BASE_ZIP=base-$TYPE-$(cksum $PIFILE | cut -f1 -d" ").zip
BASE_IMG=base-$TYPE.img
if [[ $NAME == yes ]]; then
    echo $BASE_ZIP
    exit 0
fi
if [[ ${MISSING} == "yes" ]] && [[ -f images/$BASE_ZIP ]]; then
    echo "Skipping build of base image: images/$BASE_ZIP exists"
    exit 0
fi
echo Output ZIP: images/$BASE_ZIP

# Pull docker images we will need explicitly so we get an error here where the problem is obvious
# as opposed to later in the midst of something else
docker pull $PIMOD_IMAGE

# Extract operating system image from zip archive
mkdir -p images
IMAGE_ZIP=${OS_IMAGE##*/}
IMAGE_IMG=${IMAGE_ZIP/%.zip/.img}
echo OS Image: $OS_IMAGE
if [[ ! -f images/$IMAGE_IMG ]]; then
    wget -q -O images/$IMAGE_ZIP $OS_IMAGE
    (cd images; 7z x $IMAGE_ZIP $IMAGE_IMG)
fi

# Create the base image, append the crc32 of the pifile to the name so we can tell
# when we need to build a new image
echo ""
echo "*** Building base image: $BASE_IMG"
docker run --rm --privileged \
    -v $PWD:/sg \
    -e PATH=/pimod:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    -e IMAGE_IMG=$IMAGE_IMG \
    -e TYPE=$TYPE \
    --workdir=/sg \
    $PIMOD_IMAGE \
    pimod.sh /sg/base-$TYPE.pifile
mv -f images/base-$TYPE-temp.img images/$BASE_IMG
# (cd images; rm -f $BASE_ZIP; 7z a $BASE_ZIP $BASE_IMG) # 7z too slow, not worth it...
(cd images; rm -f $BASE_ZIP; time zip -r $BASE_ZIP $BASE_IMG)

echo ""
echo "*** base image built: $BASE_ZIP"
ls -lh images/base-*
