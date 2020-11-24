#!/usr/bin/env bash

ART_ROOT=${WORKDIR}/bazel-bin/release

pushd ${ART_ROOT} || exit 1

{
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen version ${RELEASE_TAG}
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen project "v2fly"
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-dragonfly-64.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-freebsd-32.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-freebsd-64.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-linux-32.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-linux-64.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-linux-arm32-v5.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-linux-arm32-v6.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-linux-arm32-v7a.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-linux-arm64-v8a.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-linux-mips32.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-linux-mips32le.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-linux-mips64.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-linux-mips64le.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-linux-ppc64.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-linux-ppc64le.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-linux-riscv64.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-linux-s390x.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-macos-64.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-openbsd-32.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-openbsd-64.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-windows-32.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-windows-64.zip
  go run github.com/v2fly/V2BuildAssist/v2buildutil gen file v2ray-windows-arm32-v7a.zip
} >Release.unsigned.unsorted

go run github.com/v2fly/V2BuildAssist/v2buildutil gen sort < Release.unsigned.unsorted > Release.unsigned

if [[ "$IsBleedingRelease" == true ]]; then
  RELBODY="https://github.com/${COMMENT_TARGETTED_REPO_OWNER}/${COMMENT_TARGETTED_REPO_NAME}/commit/${RELEASE_SHA}"
  JSON_DATA=$(echo "{}" | jq -c ".tag_name=\"${RELEASE_TAG}\"")
  JSON_DATA=$(echo ${JSON_DATA} | jq -c ".name=\"${RELEASE_TAG}\"")
  JSON_DATA=$(echo ${JSON_DATA} | jq -c ".prerelease=${PRERELEASE}")
  JSON_DATA=$(echo ${JSON_DATA} | jq -c ".body=\"${RELBODY}\"")
  RELEASE_DATA=$(curl -X POST --data "${JSON_DATA}" -H "Authorization: token ${PERSONAL_TOKEN}" "https://api.github.com/repos/${UPLOAD_REPO}/releases")
  echo "Bleeding Edge Release data:"
  echo $RELEASE_DATA
  RELEASE_ID=$(echo $RELEASE_DATA | jq ".id")

  echo "Build Finished\nhttps://github.com/${UPLOAD_REPO}/releases/tag/${RELEASE_TAG}" > buildcomment
  go run github.com/v2fly/V2BuildAssist/v2buildutil post commit "${RELEASE_SHA}" < buildcomment
else
  RELEASE_DATA=$(curl -X GET -H "Authorization: token ${PERSONAL_TOKEN}" "https://api.github.com/repos/${UPLOAD_REPO}/releases/tags/${RELEASE_TAG}")
  echo "Tag Release data:"
  echo $RELEASE_DATA
  RELEASE_ID=$(echo $RELEASE_DATA | jq ".id")
fi

popd

function uploadfile() {
  FILE=$1
  CTYPE=$(file -b --mime-type $FILE)

  curl -H "Authorization: token ${PERSONAL_TOKEN}" -H "Content-Type: ${CTYPE}" --data-binary @$FILE "https://uploads.github.com/repos/${UPLOAD_REPO}/releases/${RELEASE_ID}/assets?name=$(basename $FILE)"
  sleep 1
}

function upload() {
  FILE=$1
  DGST=$1.dgst
  openssl dgst -md5 $FILE | sed 's/([^)]*)//g' >>$DGST
  openssl dgst -sha1 $FILE | sed 's/([^)]*)//g' >>$DGST
  openssl dgst -sha256 $FILE | sed 's/([^)]*)//g' >>$DGST
  openssl dgst -sha512 $FILE | sed 's/([^)]*)//g' >>$DGST
  uploadfile $FILE
  uploadfile $DGST
}

upload ${ART_ROOT}/Release.unsigned
upload ${ART_ROOT}/v2ray-dragonfly-64.zip
upload ${ART_ROOT}/v2ray-freebsd-32.zip
upload ${ART_ROOT}/v2ray-freebsd-64.zip
upload ${ART_ROOT}/v2ray-linux-32.zip
upload ${ART_ROOT}/v2ray-linux-64.zip
upload ${ART_ROOT}/v2ray-linux-arm32-v5.zip
upload ${ART_ROOT}/v2ray-linux-arm32-v6.zip
upload ${ART_ROOT}/v2ray-linux-arm32-v7a.zip
upload ${ART_ROOT}/v2ray-linux-arm64-v8a.zip
upload ${ART_ROOT}/v2ray-linux-mips32.zip
upload ${ART_ROOT}/v2ray-linux-mips32le.zip
upload ${ART_ROOT}/v2ray-linux-mips64.zip
upload ${ART_ROOT}/v2ray-linux-mips64le.zip
upload ${ART_ROOT}/v2ray-linux-ppc64.zip
upload ${ART_ROOT}/v2ray-linux-ppc64le.zip
upload ${ART_ROOT}/v2ray-linux-riscv64.zip
upload ${ART_ROOT}/v2ray-linux-s390x.zip
upload ${ART_ROOT}/v2ray-macos-64.zip
upload ${ART_ROOT}/v2ray-openbsd-32.zip
upload ${ART_ROOT}/v2ray-openbsd-64.zip
upload ${ART_ROOT}/v2ray-windows-32.zip
upload ${ART_ROOT}/v2ray-windows-64.zip
upload ${ART_ROOT}/v2ray-windows-arm32-v7a.zip
