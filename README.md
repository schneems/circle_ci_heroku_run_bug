## Circle CI Heroku Run bug

There is a bug in which running `heroku run <command>` returns a string prepended with `^@^@` when run from CircleCI's platform or from `circleci local` but not when executing the same script via docker.

It's assumed that you've got the `heroku` cli installed and that you're logged in.

- Download the Heroku CLI: https://devcenter.heroku.com/articles/heroku-cli
- Sign up for a Heroku account: https://www.heroku.com

If you've done this successfully you should be able to execute:

```
$ heroku whoami
yourname@example.com
```

## Reproduction on CircleCI CLI - Fails

```
$ brew install circleci
$ circleci local execute --job build--env HEROKU_API_USER=$(heroku whoami) --env HEROKU_API_KEY=$(heroku auth:token)
```

Output:

```
====>> ./script.sh
  #!/bin/bash -eo pipefail
./script.sh
afternoon-cove-69728
Running which bash on afternoon-cove-69728... starting, run.6017 (Free)
Running which bash on afternoon-cove-69728... connecting, run.6017 (Free)Running which bash on afternoon-cove-69728... up, run.6017 (Free)
Script output is: '^@^@/bin/bash', should be '/bin/bash'
Success!
```

> Note the `^@^@` in the output, it should not be there.

## Reproduction on Docker - Works as expected

This suite will successfully complete in docker. It's using the same base image as the CircleCI job!

```
$ docker build .
$ docker run --env HEROKU_API_USER=$(heroku whoami) --env HEROKU_API_KEY=$(heroku auth:token) <$IMAGE_ID>
```

Output:

```
afternoon-cove-69728
Running which bash on afternoon-cove-69728... starting, run.8393 (Free)
Running which bash on afternoon-cove-69728... connecting, run.8393 (Free)Running which bash on afternoon-cove-69728... up, run.8393 (Free)
Script output is: '/bin/bash', should be '/bin/bash'
```

## Debugging

You can get a LOT more information from the Heroku CLI via running with `DEBUG=*` environment variable. Since this happens on CircleCI but cannot be reproduced outside of that environment, it appears something on disk or in the environment (or how commands are executed) is triggering this behavior.
