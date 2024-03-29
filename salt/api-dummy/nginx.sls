api-dummy-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/api-dummy.conf
        - source: salt://api-dummy/config/etc-nginx-sites-enabled-api-dummy.conf
        - template: jinja
        - watch_in:
            - service: nginx-server-service
            - service: php-fpm

api-dummy-smoke-tests:
    cmd.run:
        - cwd: /srv/api-dummy
        - runas: {{ pillar.elife.deploy_user.username }}
        - name: ./smoke_tests.sh
        - require:
            - api-dummy-vhost
