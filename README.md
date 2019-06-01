# Radish: Money with Rails and ActiveAdmin

I hate Mint and find it a pain to use, and I wanted a money app 
that works the way I want it to work. So I just spend some time
hacking at Rails + ActiveAdmin, and Radish was born.

Future plans involve wiring it up to [Plaid](http://plaid.com/), 
making the interface a little more intuitive, and a full spec suite. 
But right now it works well enough to use, and it supports CSV imports 
from Chase bank, Chase credit cards, and Amex.

PRs are welcome.

## Requirements
- Postgres
- Redis (for sidekiq)
- Ruby 2.6.3

![screenshot](/public/radish-transactions.png)

![screenshot](/public/radish-uploads.png)