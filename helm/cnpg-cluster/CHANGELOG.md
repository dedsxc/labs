# Changelog

## [3.3.0](https://github.com/dedsxc/labs/compare/cnpg-cluster-3.2.3...cnpg-cluster-3.3.0) (2025-12-27)


### Features

* **cnpg-cluster:** refactor logical replication to support per-database config ([0c718c9](https://github.com/dedsxc/labs/commit/0c718c9c840f38ba3601b5789042f38b90e698f2))

## [3.2.3](https://github.com/dedsxc/labs/compare/cnpg-cluster-3.2.2...cnpg-cluster-3.2.3) (2025-12-26)


### Bug Fixes

* use underscore in logicalreplication name ([b784327](https://github.com/dedsxc/labs/commit/b784327ae433b5444912b69176920119844ab4a2))

## [3.2.2](https://github.com/dedsxc/labs/compare/cnpg-cluster-3.2.1...cnpg-cluster-3.2.2) (2025-12-26)


### Bug Fixes

* unique metadata name for each db ([9b6494c](https://github.com/dedsxc/labs/commit/9b6494ceec07d98e863b4e594e5a7bfad5f047de))

## [3.2.1](https://github.com/dedsxc/labs/compare/cnpg-cluster-3.2.0...cnpg-cluster-3.2.1) (2025-12-26)


### Bug Fixes

* logicalReplication declaration ([8bcb86f](https://github.com/dedsxc/labs/commit/8bcb86fc778018a4b6ab64bdc99793228b6e9309))

## [3.2.0](https://github.com/dedsxc/labs/compare/cnpg-cluster-3.1.0...cnpg-cluster-3.2.0) (2025-12-24)


### Features

* **cnpg:** add more functionality ([dd1be99](https://github.com/dedsxc/labs/commit/dd1be99448dbf3cde2ca1bf6028db08d2051edc5))
* support image catalog ([89f3643](https://github.com/dedsxc/labs/commit/89f3643b19fe5a2dec74032024d75841d58f3a09))
* support logical replication ([cbfa975](https://github.com/dedsxc/labs/commit/cbfa975fca261c677a2d1b3f88e044312a3c58e7))

## [3.1.0](https://github.com/dedsxc/labs/compare/cnpg-cluster-3.0.1...cnpg-cluster-3.1.0) (2025-12-19)


### Features

* add pod monitor ([0519309](https://github.com/dedsxc/labs/commit/0519309a4e9b80e2de71c2b70b9f1d4bba40b85b))

## [3.0.1](https://github.com/dedsxc/labs/compare/cnpg-cluster-3.0.0...cnpg-cluster-3.0.1) (2025-12-17)


### Bug Fixes

* typo on type var ([ca0764c](https://github.com/dedsxc/labs/commit/ca0764c4414c2042b01733176636af77089e9eee))

## [3.0.0](https://github.com/dedsxc/labs/compare/cnpg-cluster-2.1.0...cnpg-cluster-3.0.0) (2025-12-17)


### ⚠ BREAKING CHANGES

* rename keys variable

### Features

* put more option to configure cluster ([#160](https://github.com/dedsxc/labs/issues/160)) ([4c32922](https://github.com/dedsxc/labs/commit/4c329221f30f57257210bed63fef1a259c753cff))

## [2.1.0](https://github.com/dedsxc/labs/compare/cnpg-cluster-2.0.0...cnpg-cluster-2.1.0) (2025-12-12)


### Features

* **schema:** add schema management on database ([ae5fe99](https://github.com/dedsxc/labs/commit/ae5fe992da6cf34d7ca52ba4124fe14236af3ac0))

## [2.0.0](https://github.com/dedsxc/labs/compare/cnpg-cluster-1.2.2...cnpg-cluster-2.0.0) (2025-11-30)


### ⚠ BREAKING CHANGES

* remove creation of s3 secret for backup

### Bug Fixes

* update default value ([#148](https://github.com/dedsxc/labs/issues/148)) ([ffa25cd](https://github.com/dedsxc/labs/commit/ffa25cd998e58d299fe45eac810bf0a57556e3c9))

## [1.2.2](https://github.com/dedsxc/labs/compare/cnpg-cluster-1.2.1...cnpg-cluster-1.2.2) (2025-10-31)


### Bug Fixes

* **psql:** custom default name for superuser secret ([#125](https://github.com/dedsxc/labs/issues/125)) ([8feb705](https://github.com/dedsxc/labs/commit/8feb705f54e46a464c580e2d77cddcc3b7ec8020))

## [1.2.1](https://github.com/dedsxc/labs/compare/cnpg-cluster-1.2.0...cnpg-cluster-1.2.1) (2025-10-17)


### Bug Fixes

* **cnpg:** values templating ([#66](https://github.com/dedsxc/labs/issues/66)) ([67ac65f](https://github.com/dedsxc/labs/commit/67ac65f257ed491b97dfcb3f2f6ea151a6beb187))

## [1.2.0](https://github.com/dedsxc/helm-charts/compare/cnpg-cluster-1.1.0...cnpg-cluster-1.2.0) (2025-10-14)


### Features

* generate super user pwd ([e2d3e95](https://github.com/dedsxc/helm-charts/commit/e2d3e95ac797c91fd5a9aa0c2865688b28cd8a58))

## [1.1.0](https://github.com/dedsxc/helm-charts/compare/cnpg-cluster-1.0.0...cnpg-cluster-1.1.0) (2025-10-13)


### Features

* auto generate password with passwordgenerator ([39c3222](https://github.com/dedsxc/helm-charts/commit/39c3222e9de1438985b5f0ec34b6fc938c2fbef9))

## 1.0.0 (2025-10-12)


### Features

* release cnpg-cluster charts ([#3](https://github.com/dedsxc/helm-charts/issues/3)) ([1d6527a](https://github.com/dedsxc/helm-charts/commit/1d6527a2e70f421ba3fdcc9715446055f2dc2c23))
