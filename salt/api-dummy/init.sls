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

    {% if not pillar.api_dummy.standalone %}
    cmd.run:
        - name: ./pin.sh $(cat {{ pillar.api_dummy.pinned_revision }})
        - cwd: /srv/api-dummy
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - file: api-dummy-repository
    {% endif %}

api-dummy-composer-install:
    cmd.run:
        {% if pillar.elife.env in ['prod', 'demo'] %}
        - name: composer --no-interaction install --no-suggest --classmap-authoritative --no-dev
        {% elif pillar.elife.env != 'dev' %}
        - name: composer --no-interaction install --no-suggest --classmap-authoritative
        {% else %}
        - name: composer --no-interaction install --no-suggest
        {% endif %}
        - cwd: /srv/api-dummy/
        - user: {{ pillar.elife.deploy_user.username }}
        - env:
          - COMPOSER_DISCARD_CHANGES: 'true'
        - require:
            - api-dummy-repository
