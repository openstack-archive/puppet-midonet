# == Class = midonet::params
#
# Configure the parameters for midonet module
#
# === Parameters
#
# [*midonet_repo_baseurl*]
#   Address of the midonet repository

class midonet::params {

  $midonet_repo_baseurl = 'builds.midonet.org'

}
