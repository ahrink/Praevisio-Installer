#!/bin/sh

# file name array (simulation)
arr="ol001_aDApp.sh,ol001_aDStart.sh,ol001_INIfunc.sh"
arr="${arr},nw001_aDApp.sh,nw001_aDStart.sh,nw001_INIfunc.sh"

# distro files must exist in current folder
# blank files just names for now
for fl in $(echo "$arr" | tr ',' '\n'); do
   > "$fl"
done

##
#  Create also the distribution-record with fields of interest
##

cre_distro() {
cat << EOF
ol001_aDApp.sh|old|app
ol001_aDStart.sh|old|rot
ol001_INIfunc.sh|old|app
nw001_aDApp.sh|new|app
nw001_aDStart.sh|new|rot
nw001_INIfunc.sh|new|app
EOF
}

cre_distro > "composition.ahr"
