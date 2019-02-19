# Changelog

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

- Fixe configuration memoization issue (#19).

## 7.1.0 (2017-03-13)

- Add support for configuring Redis' URL (thanks to @ETetzlaff).

## 7.0.1 (2017-03-10)

- Fixe incorrect configuration memoization issue.

## 7.0.0 (2017-03-10)

- Add HTML status page and overall refactoring (thanks to @n-rodriguez).

## 6.0.1 (2017-03-05)

- Add tests for rails 5.0.2

## 6.0.0 (2017-01-27)

- Fixe typo in the response JSON (which can caused some backward incompatibility issues)
