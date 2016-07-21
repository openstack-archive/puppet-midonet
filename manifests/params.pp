# == Class = midonet::params
#
# Configure the parameters for midonet module
#
# === Parameters
#
# [*midonet_repo_baseurl*]
#   Address of the midonet repository

class midonet::params {

  $midonet_repo_baseurl             = 'builds.midonet.org'
  $midonet_key_url                  = "https://${midonet_repo_baseurl}/midorepo.key"

  $midonet_faraday_package          = 'tfm-rubygem-faraday'
  $midonet_faraday_url              = 'http://yum.theforeman.org/nightly/el7/x86_64/tfm-rubygem-faraday-0.9.1-3.el7.noarch.rpm'
  $midonet_multipart_post_package   =  'tfm-rubygem-multipart-post'
  $midonet_multipart_post_url       =  'http://yum.theforeman.org/nightly/el7/x86_64/tfm-rubygem-multipart-post-1.2.0-4.el7.noarch.rpm'

}
