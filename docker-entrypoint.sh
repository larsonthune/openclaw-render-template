#!/bin/sh
set -e

# Bootstrap rdt-cli (Reddit) from REDDIT_SESSION env var
# Full credential.json format matches what browser:subprocess produces
if [ -n "$REDDIT_SESSION" ]; then
  mkdir -p /root/.config/rdt-cli
  cat > /root/.config/rdt-cli/credential.json <<EOF
{
  "cookies": {
    "reddit_session": "$REDDIT_SESSION"
  },
  "source": "env",
  "username": null,
  "modhash": null,
  "saved_at": 0,
  "last_verified_at": null
}
EOF
fi

# twitter-cli reads TWITTER_AUTH_TOKEN + TWITTER_CT0 directly from env — nothing to do.

exec "$@"
