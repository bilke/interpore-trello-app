# Interpore-Trello newsletter generator

Shamelessly stolen from https://changelog.com/trello-as-a-cms

## Setup

- `bundle install --path .bundle`
- `cp config/secret.yml.example config/secret.yml`
- Fill in credentials of a Trello app, [more ...](https://github.com/jeremytregunna/ruby-trello)

## Usage

```bash
bundle exec rake import ISSUE=yyyy-nr
```
