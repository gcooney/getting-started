#!/bin/bash
set -eo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $SCRIPT_DIR
. ../shared.bash
cleanup() {
  sudo anka delete --yes $TEMPLATE
}
trap cleanup ERR INT
# TODO: Support existing installers
[[ -z $(command -v jq) ]] && echo "JQ is required. You can install it with brew." && exit 1
TEMP_DIR="/tmp/anka-mac-resources"
MOUNT_DIR="$TEMP_DIR/mount"
mkdir -p $MOUNT_DIR
cd $TEMP_DIR
if [[ -z $1 ]]; then # interactive installer
  # Download the macOS installer script and prepare the install.app
  echo "Downloading Mac Installer .app (requires root) ..."
  curl -S -L -O https://raw.githubusercontent.com/munki/macadmin-scripts/master/installinstallmacos.py
  sudo chmod +x installinstallmacos.py
  sudo ./installinstallmacos.py --raw
  INSTALL_IMAGE=$(basename $TEMP_DIR/Install_*.sparseimage)
  TEMPLATE="$(echo $INSTALL_IMAGE | sed -n 's/.*macOS_\([0-9][0-9]\..*\)-.*/\1/p')"
  echo "Mounting $INSTALL_IMAGE to $MOUNT_DIR ..."
  sudo hdiutil attach $INSTALL_IMAGE -mountpoint $MOUNT_DIR
  INSTALL_APP=$(basename $MOUNT_DIR/Applications/Install*.app)
  INSTALLER_LOCATION="/Applications/$INSTALL_APP"
  sudo cp -rf "$MOUNT_DIR/Applications/$INSTALL_APP" /Applications/
  sudo hdiutil detach $MOUNT_DIR -force
else
  [[ "${1:0:1}" != "/" ]] && echo "Ensure you're using the absolute path to your install .app" && exit 1
  TEMPLATE="$(echo $1 | sed -n 's/.*macOS \(.*\).app/\1/p' | sed 's/ /-/g')"
  [[ -z $TEMPLATE ]] && echo "Did you specify the path to an macOS installer .app?" && exit 1
  INSTALLER_LOCATION="$1"
fi
cd $HOME
# Cleanup already existing Template
curl -s -X DELETE ${URL_PROTOCOL}$CLOUD_CONTROLLER_ADDRESS:$CLOUD_CONTROLLER_PORT/api/v1/registry/vm\?id\=$ANKA_VM_TEMPLATE_UUID &>/dev/null
sudo anka delete --yes $ANKA_VM_TEMPLATE_UUID &>/dev/null || true
sudo anka delete --yes $TEMPLATE &>/dev/null || true
# Create Base Template
echo "Creating $TEMPLATE using $INSTALLER_LOCATION ..."
sudo anka create --ram-size 10G --cpu-count 6 --disk-size 80G --app "$INSTALLER_LOCATION" $TEMPLATE
## Change UUID for Template
CUR_UUID=$(sudo anka --machine-readable list | jq -r ".body[] | select(.name==\"$TEMPLATE\") | .uuid")
sudo mv "$(sudo anka config vm_lib_dir)/$CUR_UUID" "$(sudo anka config vm_lib_dir)/$ANKA_VM_TEMPLATE_UUID"
sudo sed -i '' "s/$CUR_UUID/$ANKA_VM_TEMPLATE_UUID/" "$(sudo anka config vm_lib_dir)/$ANKA_VM_TEMPLATE_UUID/$CUR_UUID.yaml"
sudo mv "$(sudo anka config vm_lib_dir)/$ANKA_VM_TEMPLATE_UUID/$CUR_UUID.yaml" "$(sudo anka config vm_lib_dir)/$ANKA_VM_TEMPLATE_UUID/$ANKA_VM_TEMPLATE_UUID.yaml"
# Add Registry to CLI
if [[ -z $(sudo anka registry list-repos | grep $CLOUD_REGISTRY_REPO_NAME) ]]; then
  sudo anka registry add $CLOUD_REGISTRY_REPO_NAME ${URL_PROTOCOL}$CLOUD_REGISTRY_ADDRESS:$CLOUD_REGISTRY_PORT
  sudo anka registry list-repos
fi
$SCRIPT_DIR/create-tags.bash $TEMPLATE