#! /bin/bash -e

#deb-s3 help copy

# Figure out versions of sensorgnome dependencies
wget -q https://sensorgnome.s3.us-east-2.amazonaws.com/dists/testing/main/binary-armhf/Packages
deps=$(awk -v ORS= '/^Depends:/,/[^,]$/' DEBIAN/control | sed -e 's/^\S*://' -e 's/ *, */ /g')
echo "Versions found in repo:"
for d in $deps; do
    version=$(awk '/^Package:/{pkg=$2} /^Version/&&pkg=="'$d'"{print $2}' Packages | sort | tail -1)
    echo "$d: $version"
    set -x
    out=$(deb-s3 copy --bucket=sensorgnome --s3-region=$S3_REGION --preserve-versions \
        --codename=testing --sign=8EFF151A5DDAE8F1 --visibility=public --arch=armhf \
        $d stable main)
    # --versions=2022.033
    if [[ $out =~ "ERROR" ]]; then exit 1; fi
done
echo ""
