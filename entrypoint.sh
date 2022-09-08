#!/bin/bash

set -eux

USER_ID=${LOCAL_UID:?}
GROUP_ID=${LOCAL_GID:?}
USER_NAME=${LOCAL_USER:?}

echo "Strating with UID: ${USER_ID}, GID: ${GROUP_ID}"
useradd -u "${USER_ID}" -o -m ${USER_NAME}
groupmod -g "${GROUP_ID}" ${USER_NAME}
export HOME=/home/${USER_NAME}

exec /usr/sbin/gosu ${USER_NAME} fish

ghq get https://github.com/Atnuhs/dotfiles.git
${HOME}/ghq/github.com/Atnuhs/dotfiles/scripts/link.sh

exec /usr/sbin/gosu ${USER_NAME} "$@"

