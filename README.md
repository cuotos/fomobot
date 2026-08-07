# FOMOBot

"never fear of missing out on Slack freebies again!"

FOMOBot is a Slack bot that will let you know if there is something going on that you should know about.

If enough users "emoji response" to a message in a channel within a certain time period, FOMOBot will drop a message in a notification channel to let you know.
This is the only channel you need to pay attention to (via pop up alerts etc)

### why?

There are too many public channels and I do not like watching them all, and when everyone is off to a party or eating free cake I get annoyed at the "didn't you see the message in Slack?"

## How

This app is written to run as a Lambda function or as a long running service


- use ngrok and put url in slack admin page
- uses user permissions to read reactions from all public channels, need to test if this includes channels user is not in
- needs write access as bot, but the bot will need to be in the channel that it wants to write to

- test verification challenge
`GOOS=linux go build -o bin/handler && docker run --rm -ti -v $(pwd):/var/task:ro,delegated -e DOCKER_LAMBDA_DEBUG=true lambci/lambda:go1.x bin/handler "$(cat example_funcurl_challenge.json)"`

- test reaction added
`GOOS=linux go build -o bin/handler && docker run --rm -ti -v $(pwd):/var/task:ro,delegated -e DOCKER_LAMBDA_DEBUG=true lambci/lambda:go1.x bin/handler "$(cat example_funcurl_event.json)"`

- deploy
`GOOS=linux go build -o main && zip function.zip main &&  av exec personal -- aws lambda  update-function-code --function-name fomobot --zip-file fileb://function.zip`

## configuration

Configured entirely through env vars. The app exits on startup if a required one is missing.

| Env var | Required | Default | Purpose |
| --- | --- | --- | --- |
| `SLACK_TOKEN` | yes | | Slack API token used to read reactions and post messages |
| `SLACK_VERIFICATION_TOKEN` | yes | | Slack app verification token; incoming events whose token does not match are rejected |
| `SLACK_NOTIFICATION_CHANNEL` | yes | | ID of the channel fomobot posts notifications to |
| `REDIS_ADDR` | yes | | Redis address used to count reactions |
| `REDIS_PASSWORD` | no | *(empty)* | Redis password |
| `REDIS_DB` | no | `0` | Redis database number |
| `FOMO_NOTIFICATION_COUNT_TRIGGER` | no | `5` | Reactions needed on a message before notifying |
| `FOMO_NOTIFICATION_COUNT_TIMEOUT` | no | `30` | Seconds the reaction count is kept before expiring |
| `AUTH_TOKEN` | no | *(empty)* | Token required by the `/leave` endpoint below |
| `LISTEN` | no | `0.0.0.0:8080` | Listen address in server mode (ignored in Lambda) |
| `LOG_LEVEL` | no | `INFO` | Minimum level to log, in increasing order: `TRACE`, `DEBUG`, `WARN`, `INFO`, `ERROR` |

The verification token is found under "Basic Information" → "App Credentials" in the Slack app admin page.

## leave a channel
you can request fomobot to remove iteself from a channel
`curl -H Authentication: <same as AUTH_TOKEN env var" https://<fomobot>/leave?channel=<channelId>`

## auth scopes

* chat:write - enable fomobot to send a message, essential
* reactions:read - get info about the reaction, self explanitory
* channels:read - used to view how many users are in a channel, in order to adjust thresholds based on number of users
* channels:manage - required for fomobot to remove itself from a public channel
* groups:write - required for fomobot to remove itself from a private channel