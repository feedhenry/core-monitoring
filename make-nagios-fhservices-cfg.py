#!/usr/bin/env python

import os

from jinja2 import Environment, FileSystemLoader, Template

fh_services_ping = ['fh-aaa', 'fh-appstore', 'fh-ngui', 'fh-scm', 'fh-supercore', 'httpd', 'millicore']
fh_services_health = ['fh-aaa', 'fh-appstore', 'fh-ngui', 'fh-scm', 'fh-supercore', 'httpd', 'millicore']

core_admin_email = os.getenv('CORE_ADMIN_EMAIL', 'root@localhost')
core_router_dns = os.getenv('CORE_ROUTER_DNS', 'core.localhost')

template_file = '/opt/rhmap/fhservices.cfg.j2'
nagios_config_filename = '/etc/nagios/conf.d/fhservices.cfg'

template_basename = os.path.basename(template_file)
template_dirname = os.path.dirname(template_file)

j2env = Environment(loader=FileSystemLoader(template_dirname), trim_blocks=True)
j2template = j2env.get_template(template_basename)

j2renderedouput = j2template.render(fh_services_ping = fh_services_ping,
									fh_services_health = fh_services_health,
                                    core_router_dns=core_router_dns,
                                    core_admin_email=core_admin_email)

with open(nagios_config_filename, 'wb') as nagios_config_file:
    nagios_config_file.write(j2renderedouput)
