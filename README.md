# EnviroblyBuilder

## Running CLI commands in development

```sh
ruby -Ilib bin/envirobly-builder version

# Perform some builds (run bin/dev first)
ruby -Ilib bin/envirobly-builder builds pull --url http://localhost:1337/builds.json --token MySecret --log /tmp/build.log
```

## Installing

```sh
# Install the gem locally from the project folder
gem build envirobly-builder.gemspec && \
gem install ./envirobly-builder-*.gem --no-document
```
