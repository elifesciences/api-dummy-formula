api-dummy-vhost:
    file.managed:
        - name: /etc/caddy/sites.d/api-dummy
        - source: salt://api-dummy/config/etc-caddy-sites.d-api-dummy
        - template: jinja
        - makedirs: true
        - require:
            - caddy-config
        - require_in:
            - cmd: caddy-validate-config
        - watch_in:
            - service: caddy-server-service
            - service: php-fpm

api-dummy-smoke-tests:
    cmd.run:
        - cwd: /srv/api-dummy
        - runas: {{ pillar.elife.deploy_user.username }}
        - name: ./smoke_tests.sh
        - require:
            - api-dummy-vhost
