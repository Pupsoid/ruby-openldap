#!/usr/bin/env ruby

require 'mkmf'
require 'fileutils'

if ENV['MAINTAINER_MODE']
	$stderr.puts "** Maintainer mode enabled. **"
	$CFLAGS << ' -Wall' << ' -Wno-unused' << " -O0" << ' -ggdb' << ' -DDEBUG'
	$LDFLAGS << ' -ggdb'
end


inc_dir, lib_dir = dir_config( 'ldap' )
if lib_dir
	$LDFLAGS << " -L%s -Wl,-rpath,%s" % [ lib_dir, lib_dir ]
end

have_func 'rb_thread_call_without_gvl' or abort "no rb_thread_call_without_gvl()"
have_func 'rb_thread_call_with_gvl' or abort "no rb_thread_call_with_gvl()"

find_header( 'ldap.h' ) or
	abort( "missing ldap.h; do you need to install a developer package?" )
find_library( 'ldap', 'ldap_initialize' ) or
	abort( "Could not find LDAP library (http://openldap.org/)." )
have_const( 'LDAP_API_VERSION', 'ldap.h' ) or
	abort "no LDAP_API_VERSION constant defined"

have_func( 'ldap_tls_inplace' )

create_header()
create_makefile( 'openldap_ext' )
