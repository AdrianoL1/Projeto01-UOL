#!/bin/bash

curl -H "Content-Type: application/json" -X POST \
     -d '{
  "username": "Nginx Status",
  "embeds": [
    {
      "title": "NGINX",
      "description": "O NGINX está desativado.",
      "color": 15158332,
      "footer": {"text": " '"$(date '+%d/%m/%Y %H:%M:%S')"'  "}
    }
  ]
}' "$WEBHOOK_URL"
