api-dummy-repository:
    builder.git_latest:
        - name: git@github.com:elifesciences/api-dummy.git
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: {{ salt['elife.rev']() }}
        - branch: {{ salt['elife.branch']() }}
        - target: /srv/api-dummy/
        - force_fetch: True
        - force_checkout: True
        - force_reset: True
        - fetch_pull_requests: True

    file.directory:
        - name: /srv/api-dummy
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - builder: api-dummy-repository

api-dummy-cache-directory:
    file.directory:
        - name: /srv/api-dummy/cache
        - user: {{ pillar.elife.webserver.username }}
        - group: {{ pillar.elife.webserver.username }}
        - dir_mode: 775
        - recurse:
            - user
            - group
        - require:
            - api-dummy-repository

composer-install:
    cmd.run:
        - name: composer --no-interaction install
        - cwd: /srv/api-dummy/
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - api-dummy-repository

api-dummy-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/api-dummy.conf
        - source: salt://api-dummy/config/etc-nginx-sites-enabled-api-dummy.conf
        - require:
            - nginx-config
            - composer-install
        - listen_in:
            - service: nginx-server-service
            - service: php-fpm
