#!/bin/bash

PRIVATE_REPO="akifakif32/infinity-x-patches"
PUBLIC_REPO="akifakif32/infinity-x6833b-patches-public"
BRANCH="main"
RET=0

fetch_patch() {
    local repo="$1"
    local file="$2"
    gh api "repos/${repo}/contents/${file}?ref=${BRANCH}" \
        --jq '.content' | base64 -d
}

echo "- Applying compatibility and security patches"

echo "  -> Applying libfs_avb fenrir compatibility patch"
( cd system/fs/fs_mgr && fetch_patch "$PUBLIC_REPO" "libfs_avb-fenrir-compat.patch" | git am >/dev/null 2>&1 ) || {
    RET=1
    ( cd system/fs/fs_mgr && git am --abort >/dev/null 2>&1 )
}

echo "  -> Applying fastbootd bypass patch"
( cd system/core && fetch_patch "$PUBLIC_REPO" "fastbootd-bypass.patch" | git am >/dev/null 2>&1 ) || {
    RET=1
    ( cd system/core && git am --abort >/dev/null 2>&1 )
}

echo "  -> Applying security patch"
( cd system/core && fetch_patch "$PRIVATE_REPO" "third.patch" | git am >/dev/null 2>&1 ) || {
    RET=1
    ( cd system/core && git am --abort >/dev/null 2>&1 )
}

echo "  -> Applying libsnapshot error63 fix patch"
( cd system/fs/fs_mgr && fetch_patch "$PUBLIC_REPO" "libsnapshot-error63-fix.patch" | git am >/dev/null 2>&1 ) || {
    RET=1
    ( cd system/fs/fs_mgr && git am --abort >/dev/null 2>&1 )
}

echo "  -> Applying update_engine debug63 instrumentation patch"
( cd system/update_engine && fetch_patch "$PUBLIC_REPO" "update_engine-debug63-instrumentation.patch" | git am >/dev/null 2>&1 ) || {
    RET=1
    ( cd system/update_engine && git am --abort >/dev/null 2>&1 )
}

if [ $RET -ne 0 ]; then
  echo "ERROR: Patch is not applied! Maybe it's already patched, or you'll have to adapt it to this specific rom source?"
else
  echo "OK: All patched"
fi
