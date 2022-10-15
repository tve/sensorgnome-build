#! /bin/bash -e

#deb-s3 help copy

# Figure out versions of sensorgnome dependencies
wget -q -O Packages-testing \
    https://sensorgnome.s3.us-east-2.amazonaws.com/dists/testing/main/binary-armhf/Packages
wget -q -O Packages-stable \
    https://sensorgnome.s3.us-east-2.amazonaws.com/dists/stable/main/binary-armhf/Packages

#deps=$(awk -v ORS= '/^Depends:/,/[^,]$/' DEBIAN/control | sed -e 's/^\S*://' -e 's/ *, */ /g')
deps=$(egrep '^Package' Packages-testing | sed -e 's/^\S*:\s*//' | sort -u)

for d in $deps; do
    version_t=$(awk '/^Package:/{pkg=$2} /^Version/&&pkg=="'$d'"{print $2}' Packages-testing | sort | tail -1)
    version_s=$(awk '/^Package:/{pkg=$2} /^Version/&&pkg=="'$d'"{print $2}' Packages-stable | sort | tail -1)
    echo "$d -- testing: $version_t, stable: $version_s"
    if [[ $version_t != $version_s ]]; then
        out=$(deb-s3 copy --bucket=sensorgnome --s3-region=$S3_REGION --preserve-versions \
            --codename=testing --sign=8EFF151A5DDAE8F1 --visibility=public --arch=armhf \
            $d stable main)
        # --versions=2022.033
        if [[ "$out" =~ "ERROR" ]]; then exit 1; fi
    fi
done
echo ""
