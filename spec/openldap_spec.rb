#!/usr/bin/env rspec -cfd -b

require_relative 'helpers'

require 'rspec'
require 'openldap'

describe OpenLDAP do

	before( :all ) do
		setup_logging( :fatal )
	end

	after( :all ) do
		reset_logging()
	end


    # typedef struct ldap_url_desc {
    #     char *      lud_scheme;     /* URI scheme */
    #     char *      lud_host;       /* LDAP host to contact */
    #     int         lud_port;       /* port on host */
    #     char *      lud_dn;         /* base for search */
    #     char **     lud_attrs;      /* list of attributes */
    #     int         lud_scope;      /* a LDAP_SCOPE_... value */
    #     char *      lud_filter;     /* LDAP search filter */
    #     char **     lud_exts;       /* LDAP extensions */
    #     int         lud_crit_exts;  /* true if any extension is critical */
    #     /* may contain additional fields for internal use */
    # } LDAPURLDesc;
	it "can split an LDAP URL into its components" do
		OpenLDAP.split_url( 'ldap://ldap.acme.com/dc=acme,dc=com' ).should == [
			'ldap',
			'ldap.acme.com',
			389,
			'dc=acme,dc=com',
			[],
			OpenLDAP::LDAP_SCOPE_BASE,
			nil,
			[],
			false,
		]
	end

	it "raises an argument error when asked to split a String that isn't an LDAP URL" do
		expect {
			OpenLDAP.split_url( 'your cat is incredibly soft' )
		}.to raise_error( ArgumentError, /not an ldap url/i )
	end

	it "propagates taintedness from a split URL to its parts" do
		url = 'ldap://ldap.acme.com/dc=acme,dc=com'
		url.taint

		result = OpenLDAP.split_url( url )

		result[0].should be_tainted()
		result[1].should be_tainted()
		# port is an immediate object, so it's not tainted
		result[3].should be_tainted()
	end

	it "has a method for examining the API info of the library it's linked against" do
		OpenLDAP.api_info.should be_a( Hash )
		OpenLDAP.api_info.should include( :api_version, :protocol_version, :extensions,
		                                  :vendor_name, :vendor_version )
	end

	it "has a hash of extension versions for the library it's linked against" do
		OpenLDAP.api_feature_info.should be_a( Hash )
		OpenLDAP.api_feature_info.should include( *OpenLDAP.api_info[:extensions] )
	end

end

