# Copyright 2013 Mojo Lingo LLC.
# Modifications by Red Hat, Inc.
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
class openshift_origin::cartridges {

  package { 'yum-plugin-versionlock':
    ensure  => present,
  }

  define openshiftCartridge  {
    case $name {
      'jenkins', 'jenkins-client': {
        ensure_resource( 'package', 'jenkins', {
            ensure  => "1.510-1.1",
            require => Class['openshift_origin::install_method'],
          }
        )
            
        ensure_resource( 'exec', '/usr/bin/yum versionlock jenkins', {
            require => [
              Package['jenkins'],
              Package['yum-plugin-versionlock'],
            ]
          }
        )
        
        ensure_resource( 'package', "openshift-origin-cartridge-${name}", {
            ensure  => present,
            require => Class['openshift_origin::install_method'],
            notify  => Service["${::openshift_origin::params::ruby_scl_prefix}mcollective"],
          }
        )
      }
      'mariadb', 'mysql': {
        case $::operatingsystem {
          'Fedora' : {
            $mariadb_cart = 'openshift-origin-cartridge-mariadb'
          }
          default  : {
            $mariadb_cart = 'openshift-origin-cartridge-mysql'    
          }
        }
        
        ensure_resource( 'package', $mariadb_cart, {
            ensure  => present,
            require => Class['openshift_origin::install_method'],
            notify  => Service["${::openshift_origin::params::ruby_scl_prefix}mcollective"],
          } 
        )
      }
      default: {
        ensure_resource( 'package', "openshift-origin-cartridge-${name}", {
            ensure  => present,
            require => Class['openshift_origin::install_method'],
            notify  => Service["${::openshift_origin::params::ruby_scl_prefix}mcollective"],
          }
        )
      }
    }
  }

  openshiftCartridge { $::openshift_origin::install_cartridges: }
  
  if( $::openshift_origin::development_mode == true ) {
    openshiftCartridge { [ 'mock', 'mock-plugin' ]: }
  }
}
