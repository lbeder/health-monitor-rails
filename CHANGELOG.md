# Changelog

## 12.9.0 (2025-04-27)

- Add show response times for providers (thanks to @Combos93)

## 12.8.0 (2025-04-14)

- Remove expired keys from the Redis (thanks to @Combos93)

## 12.7.0 (2025-04-09)

- Show warning status for non critical providers (thanks to @Erika-Barr)

## 12.6.0 (2025-03-17)

- Add config_name configuration to database provider to check specific database config (thanks to @legendetm)

## 12.5.0 (2024-12-15)

- Fix compatibility with Rails 7 by conditionally using lease_connection (thanks to @mapreal19)

## 12.4.1 (2024-11-11)

- Address #connection deprecation in favor of #lease_connection (thanks to @aaron-collier)

## 12.4.0 (2024-11-09)

- Adding FileAbsence provider to check that a file remains absent (thanks to @carolyncole)

## 12.3.0 (2024-08-22)

- Allowing a specific solr collection to be monitored (thanks to @carolyncole)

## 12.2.0 (2024-07-26)

- Get rubocop and tests running locally #122 (thanks to @maxkadel)
- Add solr monitor (thanks to @maxkadel)

## 12.1.0 (2024-03-29)

- Make sidekiq maximum_amount_of_retries configurable

## 12.0.0 (2024-03-23)

- Use "SELECT 1" to check for DB connectivity and liveness (thanks to @jayceekay)

## 11.3.0 (2024-01-21)

- Unpermitting subdomain (thanks to @shettytejas)

## 11.2.0 (2023-10-20)

- Refactor Tailwind out of this project (thanks to @loed-idzinga)

## 11.1.0 (2023-05-08)

- Fixed add_custom_provider (thanks to @shettytejas)

## 11.0.0 (2023-04-14)

- Adding support for multiple named providers and optional providers (thanks to @saviogl)

## 10.2.0 (2023-02-28)

- Prevent duplicative status checks on JSON and XML endpoints (thanks to @GUI)

## 10.1.0 (2023-01-16)

- Add retry check for Sidekiq (thanks to @loed-idzinga)

## 10.0.0 (2023-01-11)

- Support multiple databases (thanks to @HarlemSquirrel and @loed-idzinga for the help)

## 9.4.0 (2022-12-10)

- Support a connection pool for Redis

## 9.3.0 (2022-03-15)

- Add env variables to HTML page (thanks to @yorch)

## 9.2.0 (2022-03-14)

- Convert page to use TailwindCSS (thanks to @yorch)
- Avoid Unpermitted parameter: format error (thanks to @yorch)
- Add path config (thanks to @yorch)

## 9.1.0 (2021-12-24)

- Use formatted rather than deprecated to_s (thanks to @Liberatys).

## 9.0.0 (2020-08-18)

- Require Ruby 2.5.0 and later.

## 8.9.0 (2020-04-16)

- Deprecate Ruby 2.4.0 and update dependencies and style.

## 8.8.0 (2019-11-12)

- Replace dependency for rails with railties (thanks to @sliiser).

## 8.7.0 (2019-08-22)

- Add support for Rails 6.0.

## 8.6.3 (2019-05-31)

- Add Rails 4.2 to CI.

## 8.6.2 (2019-05-28)

- Remove the safe navigation operator, in order to support older Ruby versions.

## 8.6.1 (2019-05-17)

- Fix requires and new rubocop violations.

## 8.6.0 (2019-05-09)

- Fix engine autoloading and updated CI.

## 8.5.0 (2019-02-19)

- Fix default Sidekiq configuration setting.

## 8.4.0 (2018-08-17)

- Set custom UserAgent in check_rails script (thanks to @n-rodriguez).

## 8.3.0 (2018-07-27)

- Allow Sidekiq configuration per queue and allow filtering of providers on the check end-point (thanks to @danielnc).

## 8.1.0 (2018-03-23)

- Delayed Job support (thanks to @orangewolf).

## 8.0.0 (2018-03-22)

- Return 503 when one of the checks fails.

## 7.5.0 (2017-12-29)

- Add Providers::Redis.configuration.max_used_memory check (thanks to @sveredyuk).

## 7.4.0 (2017-12-27)

- Add Redis.configuration.connection and Sidekiq.configuration.queues_size check (thanks to @sveredyuk).

## 7.3.1 (2017-12-22)

- Fix redis compatibility.

## 7.3.0 (2017-10-25)

- Add Sidekiq live process check (thanks to @noto-alex-j).

## 7.2.3 (2017-06-22)

- Improve compatibility with `active_model_serializers` (thanks to @tsaifi9).

## 7.2.2 (2017-06-21)

- Improve fix to issue (#19).

## 7.2.1 (2017-06-18)

- Fix configuration memoization issue (#19).

## 7.1.0 (2017-03-13)

- Add support for configuring Redis' URL (thanks to @ETetzlaff).

## 7.0.1 (2017-03-10)

- Fix incorrect configuration memoization issue.

## 7.0.0 (2017-03-10)

- Add HTML status page and overall refactoring (thanks to @n-rodriguez).

## 6.0.1 (2017-03-05)

- Add tests for rails 5.0.2

## 6.0.0 (2017-01-27)

- Fix typo in the response JSON (which can caused some backward incompatibility issues)
