#!/bin/sh

VERSION_FILE=$1
OUTPUT_FILE=$2

if test -z "$VERSION_FILE";then
    $VERSION_FILE="VERSION"
fi

if test -z "$OUTPUT_FILE";then
    $OUTPUT_FILE="libmapi/version.h"
fi

OPENCHANGE_VERSION_STRING=$3
SOURCE_DIR=$4

OPENCHANGE_MAJOR_RELEASE=`echo ${OPENCHANGE_VERSION_STRING} | cut -d. -f1`
OPENCHANGE_MINOR_RELEASE=`echo ${OPENCHANGE_VERSION_STRING} | cut -d. -f2`

OPENCHANGE_VERSION_IS_SVN_SNAPSHOT=`sed -n 's/^OPENCHANGE_VERSION_IS_SVN_SNAPSHOT=//p' $SOURCE_DIR$VERSION_FILE`
OPENCHANGE_VERSION_RELEASE_NICKNAME=`sed -n 's/^OPENCHANGE_VERSION_RELEASE_NICKNAME=//p' $SOURCE_DIR$VERSION_FILE`
OPENCHANGE_VERSION_RELEASE_NUMBER=`sed -n 's/^OPENCHANGE_VERSION_RELEASE_NUMBER=//p' $SOURCE_DIR$VERSION_FILE`

echo "/* Autogenerated by script/mkversion.h */" >> $OUTPUT_FILE
echo "#define OPENCHANGE_MAJOR_RELEASE ${OPENCHANGE_MAJOR_RELEASE}" >> $OUTPUT_FILE
echo "#define OPENCHANGE_MINOR_RELEASE ${OPENCHANGE_MINOR_RELEASE}" >> $OUTPUT_FILE

#
# SVN revision number
#
if test x"${OPENCHANGE_VERSION_IS_SVN_SNAPSHOT}" = x"yes";then
    _SAVE_LANG=${LANG}
    LANG=""
    HAVEVER="no"

    if test x"${HAVEVER}" != x"yes";then
        HAVESVN=no
        SVN_INFO=`svn info ${SOURCE_DIR} 2>/dev/null`
        TMP_REVISION=`echo -e "${SVN_INFO}" | grep 'Last Changed Rev.*:' |sed -e 's/Last Changed Rev.*: \([0-9]*\).*/\1/'`
        if test -n "$TMP_REVISION"; then
            HAVESVN=yes
            HAVEVER=yes
        fi
    fi

    if test x"${HAVESVN}" = x"yes";then
        OPENCHANGE_VERSION_STRING="${OPENCHANGE_VERSION_STRING}-SVN-build-${TMP_REVISION}"
        echo "#define OPENCHANGE_VERSION_SVN_REVISION ${TMP_REVISION}" >> $OUTPUT_FILE
    fi

    LANG=${_SAVE_LANG}
fi

if test -z "${OPENCHANGE_VERSION_RELEASE_NUMBER}";then
    echo "#define OPENCHANGE_VERSION_OFFICIAL_STRING \"${OPENCHANGE_VERSION_STRING}\"" >> $OUTPUT_FILE
else
    OPENCHANGE_VERSION_STRING="${OPENCHANGE_VERSION_RELEASE_NUMBER}"
    echo "#define OPENCHANGE_VERSION_OFFICIAL_STRING \"${OPENCHANGE_VERSION_RELEASE_NUMBER}\"" >> $OUTPUT_FILE
fi

##
## Add a release nickname
##
if test -n "${OPENCHANGE_VERSION_RELEASE_NICKNAME}";then
    echo "#define OPENCHANGE_VERSION_RELEASE_NICKNAME ${OPENCHANGE_VERSION_RELEASE_NICKNAME}" >> $OUTPUT_FILE
    OPENCHANGE_VERSION_STRING="${OPENCHANGE_VERSION_STRING} (${OPENCHANGE_VERSION_RELEASE_NICKNAME})"
fi

echo "#define OPENCHANGE_VERSION_STRING \"${OPENCHANGE_VERSION_STRING}\"" >> $OUTPUT_FILE

##
## Add some System related information (useful for debug and report)
##
echo "" >> $OUTPUT_FILE
echo "/* System related information */" >> $OUTPUT_FILE

OPENCHANGE_SYS_KERNEL_NAME=`uname -s`
OPENCHANGE_SYS_KERNEL_RELEASE=`uname -r`
OPENCHANGE_SYS_PROCESSOR=`uname -p`

echo "#define OPENCHANGE_SYS_KERNEL_NAME \"${OPENCHANGE_SYS_KERNEL_NAME}\"" >> $OUTPUT_FILE
echo "#define OPENCHANGE_SYS_KERNEL_RELEASE \"${OPENCHANGE_SYS_KERNEL_RELEASE}\"" >> $OUTPUT_FILE
echo "#define OPENCHANGE_SYS_PROCESSOR \"${OPENCHANGE_SYS_PROCESSOR}\"" >> $OUTPUT_FILE

echo "$0: '$OUTPUT_FILE' created for OpenChange libmapi(\"${OPENCHANGE_VERSION_STRING}\")"

exit 0
