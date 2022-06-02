# -*- text -*-
######################################################################
#
#  Sample virtual server for receiving a CoA or Disconnect-Request packet.
#

#  Listen on the CoA port.
#
#  This uses the normal set of clients, with the same secret as for
#  authentication and accounting.
#
listen {
		type = coa
		ipaddr = $ENV{FREERADIUS_SITES_COA_LISTEN}
		port = $ENV{FREERADIUS_SITES_COA_PORT}
		virtual_server = coa
}

server coa {
		#  When a packet is received, it is processed through the
		#  recv-coa section.  This applies to *both* CoA-Request and
		#  Disconnect-Request packets.
		recv-coa {
				#  CoA && Disconnect packets can be proxied in the same
				#  way as authentication or accounting packets.
				#  Just set Proxy-To-Realm, or Home-Server-Pool, and the
				#  packets will be proxied.

				#  Do proxying based on realms here.  You don't need
				#  "IPASS" or "ntdomain", as the proxying is based on
				#  the Operator-Name attribute.  It contains the realm,
				#  and ONLY the realm (prefixed by a '1')
				suffix

				#  Insert your own policies here.
				ok
		}

		#  When a packet is sent, it is processed through the
		#  send-coa section.  This applies to *both* CoA-Request and
		#  Disconnect-Request packets.
		send-coa {
				#  Sample module.
				ok
		}

		#  You can use pre-proxy and post-proxy sections here, too.
		#  They will be processed for sending && receiving proxy packets.
}