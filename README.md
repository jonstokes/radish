# Radish: Money with Rails and ActiveAdmin

I hate Mint and find it a pain to use, and I wanted a money app 
that works the way I want it to work. So I just spend some time
hacking at Rails + ActiveAdmin, and Radish was born.

Right now I really just use Radish to track my spending, so that's
what it's geared toward. I export CSVs from financial institutions and
upload them into Radish. Radish handles deduping so even if there's some
overlap it's ok, and I can also use it to auto-categorize transactions.

If I screw up a CSV import, I can easily delete all the transactions created by
that upload and start over again.

Radish supports multi-edit for transaction record categories, and the filters
work really well thanks to ActiveAdmin.

## Requirements
- Postgres
- Redis (for sidekiq)
- Ruby 2.6.3

## Future plans
- Wire it up to [Plaid](http://plaid.com/)
- Make the interface a little more intuitive
- A full spec suite
- Change `TransactionRecord` to `LedgerEntry` because the former is not ideal from an "already overloaded rails terms" object name perspective
- Clean out cruft from pre-ActiveAdmin iterations

PRs are welcome.

## Screenshots

![screenshot](/public/radish-transactions.png)

![screenshot](/public/radish-uploads.png)