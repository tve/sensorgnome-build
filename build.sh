#! /bin/bash -e

# parse commandline options for tag, codename, and manifest
CODENAME=booktest
MANIFEST=manifest-armv7-rpi-bookworm
V=$(TZ=PST8PDT date +%Y-%j)
while getopts ":t:c:m:" opt; do
    case $opt in
        t)
            V=$OPTARG
            ;;
        c)
            CODENAME=$OPTARG
            ;;
        m)
            MANIFEST=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done
echo "V=$V, CODENAME=$CODENAME, MANIFEST=$MANIFEST"

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
# Make some tweak to image name: for test images add -testing, for final images remove OS version
if [[ $CODENAME == 'booktest' ]]; then
    IMG=sg-$TYPE-testing-$V
else
    IMG=sg-${TYPE%-*}-$V
fi

mv -f images/sg-$TYPE-temp.img images/$IMG.img
rm -f images/$IMG.zip
(cd images; zip $IMG.zip $IMG.img)
#(cd images; 7z a sg-$TYPE-$V.zip sg-$TYPE-$V.img)

echo ""
echo "*** sensorgnome image built: images/$IMG.img"
ls -lh images/$IMG.*
