# Changelog DedicatedNetworks

<!-- TOC:START -->
## Table of Contents
- [r2.1](#r21)
<!-- TOC:END -->

**Please be aware that the project will have frequent updates to the main branch. There are no compatibility guarantees associated with code in any branch, including main, until it has been released. For example, changes may be reverted before a release is published. For the best results, use the latest published release.**

The below sections record the changes for each API version in each release as follows:

* for an alpha release, the delta with respect to the previous release
* for the first release-candidate, all changes since the last public release
* for subsequent release-candidate(s), only the delta to the previous release-candidate
* for a public release, the consolidated changes since the previous public release

# r2.1

## Release Notes

This pre-release contains the definition and documentation of
* dedicated-network-accesses 0.2.0-alpha.1
* dedicated-network-profiles 0.2.0-alpha.1
* dedicated-network 0.2.0-alpha.1
* dedicated-network-areas 0.1.0-alpha.1

The API definition(s) are based on
* Commonalities 0.6.1
* Identity and Consent Management 0.4.0

## dedicated-network-accesses 0.2.0-alpha.1

**dedicated-network-accesses 0.2.0-alpha.1 is an alpha of the version 0.2.0 of the Dedicated Network Accesses API.**

- API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r2.1/code/API_definitions/dedicated-network-accesses.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r2.1/code/API_definitions/dedicated-network-accesses.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/DedicatedNetworks/blob/r2.1/code/API_definitions/dedicated-network-accesses.yaml)

### Added

* Support for asynchronous events for device access creation and device access lifecycle.
  * by @hubertp-ericsson in https://github.com/camaraproject/DedicatedNetworks/pull/91
* Support operations to manage access to dedicated network for multiple devices at a time
  * by @hubertp-ericsson in https://github.com/camaraproject/DedicatedNetworks/pull/98

### Changed

* Adding a clear description of the `MaxNumberOfDevices` parameter and its relation to aggregated UL/DL throughput parameters.
  * by @tlohmar in https://github.com/camaraproject/DedicatedNetworks/pull/88 
* New 409 Error Code called INCOMPATIBLE_STATE is used, indicating that the dedicated network resource referenced in the POST request is in an incompatible state, e.g. in TERMINATED state.
  * by in https://github.com/camaraproject/DedicatedNetworks/pull/81

## dedicated-network-profiles 0.2.0-alpha.1

**dedicated-network-profiles 0.2.0-alpha.1 is an alpha of version 0.2.0 of the Dedicated Network Profiles API.**

- API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r2.1/code/API_definitions/dedicated-network-profiles.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r2.1/code/API_definitions/dedicated-network-profiles.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/DedicatedNetworks/blob/r2.1/code/API_definitions/dedicated-network-profiles.yaml)

### Changed

* Adding a clear description of the `MaxNumberOfDevices` parameter and its relation to aggregated UL/DL throughput parameters.
  * by @tlohmar in https://github.com/camaraproject/DedicatedNetworks/pull/88 
* Enhancement to use format UUID for the NetworkProfileId and to add a human readable name, consistent with other DN APIs. 
  * by tlohmar in https://github.com/camaraproject/DedicatedNetworks/pull/83

## dedicated-network 0.2.0-alpha.1

**dedicated-network 0.2.0-alpha.1 is an alpha of the version 0.2.0 of the Dedicated Network API.**

- API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r2.1/code/API_definitions/dedicated-network.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r2.1/code/API_definitions/dedicated-network.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/DedicatedNetworks/blob/r2.1/code/API_definitions/dedicated-network.yaml)

### Added

* Allowing the API Consumer to assign an own `name` to a dedicated network resource, which is returned when the network is read or listed.
  * by @hubertp-ericsson in https://github.com/camaraproject/DedicatedNetworks/pull/97
* A new API is added which provides information about the geographical areas where consistent service coverage according to one or more network profiles is supported. 
  * by @hubertp-ericsson in https://github.com/camaraproject/DedicatedNetworks/pull/87

### Changed

* Enhancement to use format UUID for the NetworkProfileId and to add a human readable name, consistent with other DN APIs. 
  * by tlohmar in https://github.com/camaraproject/DedicatedNetworks/pull/83

## dedicated-network-areas 0.1.0-alpha.1

**dedicated-network-areas 0.1.0-alpha.1 is an alpha of version 0.1.0 of the Dedicated Network Areas API.**

- API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r2.1/code/API_definitions/dedicated-network-areas.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r2.1/code/API_definitions/dedicated-network-areas.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/DedicatedNetworks/blob/r2.1/code/API_definitions/dedicated-network-areas.yaml)

### Added

* A new API is added which provides information about the geographical areas where consistent service coverage according to one or more network profiles is supported. 
  * by in https://github.com/camaraproject/DedicatedNetworks/pull/87

**Full Changelog**: https://github.com/camaraproject/DedicatedNetworks/compare/r1.2...r2.1

