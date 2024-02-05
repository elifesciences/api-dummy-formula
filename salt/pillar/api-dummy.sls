api_dummy:
    # api-dummy is 'standalone' when it's running as it's own project and not a dependency of another.
    # if another project needs to include api-dummy, set `api_dummy.standalone` to `false`.
    # api-dummy will use the latest master branch revision and run on port 8080
    standalone: True
    pinned_revision_file: null
