#!/usr/bin/env bash

app_name=$(heroku apps --json | jq -r first.name)

if [ -z "$app_name" ]; then
  git config --global user.email "$HEROKU_API_USER"
  git config --global user.name "anything here"
  mkdir foo
  cd foo
  echo "hello" >> scratch.txt # not deployed
  git init .; git add .; git commit -m first
  heroku create

  app_name=$(heroku apps --json | -r jq first.name)
fi

echo "$app_name"

heroku_run_output=$(heroku run which bash -a $app_name)

echo "Script output is: '$heroku_run_output', should be '/bin/bash'"
