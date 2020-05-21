[[ $DEBUG == true ]] && set -x

STORAGE_LOCATION=${STORAGE_LOCATION:-"/tmp"}
URL_PROTOCOL="http://"

ANKA_PLUGIN_VERSION="1.23.0"
GITHUB_PLUGIN_VERSION="1.30.0"
PIPELINE_PLUGIN_VERSION="1.6.0"

ANKA_VIRTUALIZATION_PACKAGE=${ANKA_VIRTUALIZATION_PACKAGE:-"Anka-2.2.3.118.pkg"}
ANKA_VIRTUALIZATION_DOWNLOAD_URL="https://ankabeta.s3.amazonaws.com/$ANKA_VIRTUALIZATION_PACKAGE"
ANKA_VM_USER=${ANKA_VM_USER:-"anka"}
ANKA_VM_PASSWORD=${ANKA_VM_USER:-"admin"}
ANKA_VM_TEMPLATE_UUID="c0847bc9-5d2d-4dbc-ba6a-240f7ff08032" # Used in https://github.com/veertuinc/jenkins-dynamic-label-example

CLOUD_CONTROLLER_ADDRESS=${CLOUD_CONTROLLER_ADDRESS:-"anka.controller"}
CLOUD_REGISTRY_ADDRESS=${CLOUD_REGISTRY_ADDRESS:-"anka.registry"}
<<<<<<< HEAD
CLOUD_CONTROLLER_PORT="8090"

CLOUD_REGISTRY_PORT="8091"
=======
CLOUD_CONTROLLER_PORT=8090

CLOUD_REGISTRY_PORT=8091
>>>>>>> master
CLOUD_REGISTRY_REPO_NAME="local-demo"
CLOUD_NATIVE_PACKAGE=${CLOUD_NATIVE_PACKAGE:-"AnkaControllerRegistry-1.7.1-9545c9f5.pkg"}
CLOUD_DOCKER_TAR="anka-controller-registry-1.7.1-9545c9f5.tar.gz"
CLOUD_DOCKER=$(echo $CLOUD_DOCKER_TAR | awk -F'.tar.gz' '{print $1}')
CLOUD_DOWNLOAD_URL="https://ankabeta.s3.amazonaws.com/$CLOUD_NATIVE_PACKAGE"

<<<<<<< HEAD
TEAMCITY_PORT="8094"
TEAMCITY_VERSION="2020.1"
TEAMCITY_DOCKER_TAG_VERSION=${TEAMCITY_DOCKER_TAG_VERSION:-"$TEAMCITY_VERSION-linux"}
TEAMCITY_DOCKER_CONTAINER_NAME="anka.teamcity"
TEAMCITY_DOCKER_DATA_DIR="$HOME/$TEAMCITY_DOCKER_CONTAINER_NAME-data"

=======
>>>>>>> master
modify_hosts() {
  [[ -z $1 ]] && echo "ARG 1 missing" && exit 1
  if [[ $(uname) == "Darwin" ]]; then
    SED="sudo sed -i ''"
  else
    SED="sudo sed -i"
  fi
  HOSTS_LOCATION="/etc/hosts"
  $SED "/$1/d" $HOSTS_LOCATION
  echo "127.0.0.1 $1" | sudo tee -a $HOSTS_LOCATION
}