# Interpore-Trello newsletter generator

Shamelessly stolen from https://changelog.com/trello-as-a-cms

## Setup

- `bundle install --path .bundle`
- `cp config/secret.yml.example config/secret.yml`
- Fill in credentials of a Trello app, [more ...](https://github.com/jeremytregunna/ruby-trello)

## Usage

### Rake

```bash
bundle exec rake import ISSUE=yyyy-nr
```

### Sinatra app

```bash
ruby lib/app.rb
```
### Heroku app

```bash
heroku create
heroku config:set trello_developer_public_key=[REDACTED]
heroku config:set trello_member_token=[REDACTED]
git push heroku master
```

For local environment setup use `.env`-file:

```
trello_developer_public_key=[REDACTED]
trello_member_token=[REDACTED]
```
