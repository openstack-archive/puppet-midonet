# == Class = midonet::params
#
# Configure the parameters for midonet module
#
# === Parameters
#
# [*midonet_repo_baseurl*]
#   Address of the midonet repository
# [*faraday version*]
#   Version of faraday gem to use ( RHEL-Only Variable )
# [*multipart_post_version*]
#   Version of multipart post to use ( RHEL-Only Variable )
# [*faraday_package*]
#   Name of the faraday package
# [*faraday_url*]
#   URL to download faraday gem
# [*multipart_post_package*]
#   Name of the multipart post package
# [*multipart_post_url*]
#   Url of the multipart post package
class midonet::params {

  $midonet_repo_baseurl = 'builds.midonet.org'
  $faraday_version = '0.9.1-3'
  $mulipart_post_version = '1.2.0-4'
  $faraday_package = 'tfm-rubygem-faraday'
  $faraday_url = "http://yum.theforeman.org/nightly/el${::operatingsystemmajrelease}/x86_64/${faraday_package}-${faraday_version}.el7.noarch.rpm"
  $multipart_post_package = 'tfm-rubygem-multipart-post'
  $multipart_post_url = "http://yum.theforeman.org/nightly/el${::operatingsystemmajrelease}/x86_64/${multipart_post_package}-${mulipart_post_version}.el7.noarch.rpm"

}
