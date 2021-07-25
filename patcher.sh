#!/bin/bash

ROOT="${PWD}"

REPOSITORIES=(
    'frameworks/opt/net/wifi'
    'frameworks/base'
)

for repository in "${REPOSITORIES[@]}"; do
    cd "${ROOT}/${repository}"
        for patch in ${ROOT}/patcher/patches/${repository}/*.patch; do
                #Check if patch is already applied
                if patch -f -p1 --dry-run -R < $patch > /dev/null;then
                        echo "[Skip] patch is already applied? ${patch##*/}"
                        echo "[log]: "
                        patch -f -p1 --dry-run -R < $patch > /dev/stdout
                        continue
                fi
                #Ckeck patch error
                git apply --check  $patch  2> ${ROOT}/patcher/patch.tmp
                if [ -s ${ROOT}/patcher/patch.tmp ]; then
                    echo "[Warm] ${patch##*/} maybe can't patch"
                    echo "[Warm] force to apply"
                    rm ${ROOT}/patcher/patch.tmp
                    git am $patch 1> /dev/null  2> /dev/null
                    if patch -f -p1 --dry-run -R < $patch > /dev/null;then
                            echo "[Succeed] ${patch##*/}"
                    else
                        echo "[Error!] failed! abort"
                        echo "[log]: "
                        patch -f -p1 --dry-run -R < $patch > /dev/stdout
                        git am --abort
                    fi
                else
                    echo  "[Patch] ${patch##*/}"
                    git am $patch > /dev/null
                fi
        done 
    cd "${ROOT}"
done

echo "Done. Each patch is essence. If find patch failed, do \"repo sync\" rollback HEAD"

cd ${ROOT}
