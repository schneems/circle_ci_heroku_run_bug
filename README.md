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
$ circleci local execute --job build --env HEROKU_API_USER=$(heroku whoami) --env HEROKU_API_KEY=$(heroku auth:token)
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

You can modify the behavior of `dyno-js.js` to add debugging input. Use the `debug()` function and pass in an `--env DEBUG=*` to docker:

```
circleci local execute --job build --env HEROKU_API_USER=$(heroku whoami) --env HEROKU_API_KEY=$(heroku auth:token) --env DEBUG=*
```

In this case I've added a debug output when the process receives an input from stdin it will output it with `reading data`, in this case you can see that it's reading in a character that node won't put on the screen, likely a null byte:

```
Running which bash on austin-henry-schneeman... connecting, run.3018 (Free)Running which bash on austin-henry-schneeman... up, run.3018 (Free)
  heroku:run connect +0ms
  heroku:run input: 'rendezvous\r\n' +2s
  heroku:run reading data  +1ms   # <============= HERE =========================
  heroku:run input: '^@^@' +98ms
  heroku:run input: '/bin/bash\r\n' +1s
  heroku:run close +3s
  heroku:run done running +0ms
Script output is: '^@^@/bin/bash', should be '/bin/bash'
Success!
```

