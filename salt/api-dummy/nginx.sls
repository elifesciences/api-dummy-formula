api-dummy-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/api-dummy.conf
        - source: salt://api-dummy/config/etc-nginx-sites-enabled-api-dummy.conf
        - listen_in:
            - service: nginx-server-service
            - service: php-fpm

api-dummy-smoke-tests:
    cmd.run:
        - cwd: /srv/api-dummy
        - runas: {{ pillar.elife.deploy_user.username }}
        - name: ./smoke_tests.sh
        - require:
            - api-dummy-nginx-vhost
