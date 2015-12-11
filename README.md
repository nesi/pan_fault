#Pan Fault 

## DESCRIPTION:

Series of ruby classes that query particular types of hardware, instantiated by bin/ipmi_host_status.rb, which outputs a json status file, that is read by the HTML5 web/rack_fault.html

## INSTALL:

Installed on xcat (as it can see the management network of the cluster) in /root/bin/

conf/auth.json defines the keys needed by classes to connect to the hardware.
eg.
```
{
  "transfer_ssh_keyfile": "/root/.ssh/id_rsa",
  "ibm_43V6145_PDU": "xxxxxxxx",
  "ibm_43V6145_PDU_community": "xxxxxxxx",
  "ibm_39m2816_PDU": "xxxxxxxx",
  "ibm_39m2816_PDU_community": "xxxxxxxx",
  "transfer_ssh_keyfile": "/root/.ssh/id_rsa",
  "node_snmp_r_community": "xxxxxxxx",
  "switch_snmp_r_community": "xxxxxxxx",
  "fc_switch_snmp_r_community": "xxxxxxxx",
  "voltaire_password": "xxxxxxxx",
  "mellanox_sx_password": "xxxxxxxx",
  "ibm_43V6145_PDU": "xxxxxxxx",
  "ibm_43V6145_PDU_community": "xxxxxxxx",
  "ibm_39m2816_PDU": "xxxxxxxx",
  "ibm_39m2816_PDU_community": "xxxxxxxx"
}
```

In root's crontab:
*/6 * * * * /root/bin/pan_fault/bin/ipmi_host_status.rb

The conf/rack_master.json file also needs to be copied to the web directory, along with the web/rack_fault.html. 

The conf/config.json file defines where directories are.

## LICENSE:

(The MIT License)

Copyright (c) 2013

1. You may make and give away verbatim copies of the source form of the
   software without restriction, provided that you duplicate all of the
   original copyright notices and associated disclaimers.

2. You may modify your copy of the software in any way, provided that
   you do at least ONE of the following:
    *  place your modifications in the Public Domain or otherwise make them Freely Available, such as by posting said modifications to Usenet or an equivalent medium, or by allowing the author to include your modifications in the software.
    *  use the modified software only within your corporation or organization.
    *  rename any non-standard executables so the names do not conflict with standard executables, which must also be provided.
    *  make other distribution arrangements with the author.

3. You may distribute the software in object code or executable form, provided that you do at least ONE of the following:
    * distribute the executables and library files of the software,
  together with instructions (in the manual page or equivalent)
  on where to get the original distribution.
    * accompany the distribution with the machine-readable source of
  the software.
    * give non-standard executables non-standard names, with
        instructions on where to get the original software distribution.
    * make other distribution arrangements with the author.

4. You may modify and include the part of the software into any other
   software (possibly commercial).  But some files or libraries used by
   code in this distribution  may not written by the author, so that they 
   are not under these terms.

5. The scripts and library files supplied as input to or produced as 
   output from the software do not automatically fall under the
   copyright of the software, but belong to whomever generated them, 
   and may be sold commercially, and may be aggregated with this
   software.

6. THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
   IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
   WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
   PURPOSE.