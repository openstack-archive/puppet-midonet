#!/bin/bash

set -ex

if [ -n "${GEM_HOME}" ]; then
    GEM_BIN_DIR=${GEM_HOME}/bin/
    export PATH=${PATH}:${GEM_BIN_DIR}
fi

if [ "${PUPPET_MAJ_VERSION}" = 4 ]; then
  export PUPPET_BASE_PATH=/etc/puppetlabs/code
  export PATH=${PATH}:/opt/puppetlabs/bin
  # Workaround to deploy puppet for beaker jobs
  sudo -E ln -sfn /opt/puppetlabs/bin/puppet /usr/sbin/puppet
else
  export PUPPET_BASE_PATH=/etc/puppet
fi

export SCRIPT_DIR=$(cd `dirname $0` && pwd -P)/../../
export FUNCTIONS_DIR=$(cd `dirname $0` && pwd -P)
export PUPPETFILE_DIR=${PUPPETFILE_DIR:-${PUPPET_BASE_PATH}/modules}
source $FUNCTIONS_DIR/functions

print_header 'Start (install_modules.sh)'
print_header 'Install r10k'
# puppet_forge 2.2.7 has a dependency on semantic_puppet ~> 1.0
# which is not compatible with dependency of latest r10k on semantic_puppet ~> 0.1.0
gem install puppet_forge -v '= 2.2.6' --verbose
gem install r10k --no-ri --no-rdoc --verbose

# make sure there is no puppet module pre-installed
rm -rf "${PUPPETFILE_DIR:?}/"*

print_header 'Install Modules'
install_modules

print_header 'Module List'
puppet module list

print_header 'Done (install_modules.sh)'
