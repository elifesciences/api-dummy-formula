api-dummy-php-composer-1.0:
   cmd.run:
        - name: |
            cp composer composer1.0
            composer1.0 self-update 1.0.3
        - cwd: /usr/local/bin/
        - require:
            - cmd: install-composer
        - unless:
            - which composer1.0

api-dummy-php-puli-latest:
   cmd.run:
        - name: |
            curl https://puli.io/installer | php
            mv puli.phar puli
        - cwd: /usr/local/bin/
        - unless:
            - which puli

api-dummy-repository:
    builder.git_latest:
        - name: git@github.com:elifesciences/api-dummy.git
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: {{ salt['elife.rev']() if pillar.api_dummy.standalone else 'master' }}
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

api-dummy-composer-install:
    cmd.run:
        {% if pillar.elife.env in ['prod', 'demo'] %}
        - name: composer1.0 --no-interaction install --classmap-authoritative --no-dev
        {% elif pillar.elife.env in ['ci'] %}
        - name: composer1.0 --no-interaction install --classmap-authoritative
        {% else %}
        - name: composer1.0 --no-interaction install
        {% endif %}
        - cwd: /srv/api-dummy/
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - api-dummy-repository
            - cmd: api-dummy-php-composer-1.0
            - cmd: api-dummy-php-puli-latest
