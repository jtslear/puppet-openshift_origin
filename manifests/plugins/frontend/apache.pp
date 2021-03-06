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
class openshift_origin::plugins::frontend::apache {

  ensure_resource ( 'package', 'httpd', {
      require => Class['openshift_origin::install_method'],
    }
  )

  if 'broker' in $::openshift_origin::roles {
    $httpd_servername_path    = '/etc/httpd/conf.d/000002_openshift_origin_broker_servername.conf'
    $servername_conf_template = 'openshift_origin/plugins/frontend/apache/broker_servername.conf.erb'
  } elsif 'node' in $::openshift_origin::roles {
    $httpd_servername_path    = '/etc/httpd/conf.d/000001_openshift_origin_node_servername.conf'
    $servername_conf_template = 'openshift_origin/plugins/frontend/apache/node_servername.conf.erb'
  }

  service { 'httpd':
    enable     => true,
    ensure     => true,
    hasstatus  => true,
    hasrestart => true,
    require    =>  Package['httpd'],
    provider   => $openshift_origin::params::os_init_provider,
  }
  
  file { 'servername config':
    ensure  => present,
    path    => $httpd_servername_path,
    content => template($servername_conf_template),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['httpd'],
    notify  => Service['httpd'],
  }
  
  if $::operatingsystem == "Fedora" and 'node' in $::openshift_origin::roles {
    file { 'allow cartridge files through apache':
      ensure  => present,
      path    => '/etc/httpd/conf.d/cartridge_files.conf',
      content => template('openshift_origin/plugins/frontend/apache/cartridge_files.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0660',
      require =>  Package['httpd'],
      notify  => Service['httpd'],
    }
  }
}
