# Changelog Dedicated Networks

# r1.2
## Release Notes

This release contains the definition and documentation of
* dedicated-network v0.1.0
* dedicated-network-accesses v0.1.0
* dedicated-network-profiles v0.1.0

The API definition(s) are based on
* Commonalities v0.6.0
* Identity and Consent Management v0.4.0

## Key updates

* Aligning QoS Profile with QualityOnDemand
  * Introduces a new QosProfileName DataType into the Profiles API aligning the definition with QualityOnDemand
    * by @tlohmar in https://github.com/camaraproject/DedicatedNetworks/pull/59
  * Documentation (info section in Profiles & Accesses API and general documentation) is extended to clarify that the reuse the QualityOnDemand QOS Profiles concept
    * by @tlohmar in https://github.com/camaraproject/DedicatedNetworks/pull/54

* Aligning Device object with Commonalities
  * Introducing all the common supported identifiers to align with the object definition
  * Extending the general documentation with a motivation for supporting MSISDNs as device identifier.
  * Adding a recommendation for not supporting IP addresses as device identifier.
  * by @tlohmar in https://github.com/camaraproject/DedicatedNetworks/pull/55

* Clarification that an Access resource can only be created once the referred Network is created. When the referred Network is in TERMINATED state, creation of Access resources is not possible anymore for the given Network by @tlohmar in https://github.com/camaraproject/DedicatedNetworks/pull/53

* Adding 3GPP Release information to DedicatedNetworks_GeneralDescription.md by @tlohmar in https://github.com/camaraproject/DedicatedNetworks/pull/51

## dedicated-network v0.1.0

**dedicated-network v0.1.0 is the initial public release of version 0.1.0 of the Dedicated Network API.**

- dedicated-network v0.1.0 API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.2/code/API_definitions/dedicated-network.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.2/code/API_definitions/dedicated-network.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/DedicatedNetworks/blob/r1.2/code/API_definitions/dedicated-network.yaml)

## dedicated-network-accesses v0.1.0

**dedicated-network-accesses v0.1.0 is the initial public release of version 0.1.0 of the Dedicated Network Accesses API.**

- dedicated-network-accesses v0.1.0 API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.2/code/API_definitions/dedicated-network-accesses.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.2/code/API_definitions/dedicated-network-accesses.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/DedicatedNetworks/blob/r1.2/code/API_definitions/dedicated-network-accesses.yaml)

### Changed

* Aligning Device object with Commonalities by @tlohmar in https://github.com/camaraproject/DedicatedNetworks/pull/55

## dedicated-network-profiles v0.1.0

**dedicated-network-profiles v0.1.0 is the initial public release of version 0.1.0 of the Dedicated Network Profiles API.**

- dedicated-network-profiles v0.1.0 API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.2/code/API_definitions/dedicated-network-profiles.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.2/code/API_definitions/dedicated-network-profiles.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/DedicatedNetworks/blob/r1.2/code/API_definitions/dedicated-network-profiles.yaml)

### Added

* Introduces a new QosProfileName DataType into the Profiles API aligning the definition with QualityOnDemand by @tlohmar in https://github.com/camaraproject/DedicatedNetworks/pull/59

**Full Changelog**: https://github.com/camaraproject/DedicatedNetworks/commits/r1.2




# r1.1

## Release Notes

This release contains the definition and documentation of
* dedicated-network v0.1.0-rc.1
* dedicated-network-accesses v0.1.0-rc.1
* dedicated-network-profiles v0.1.0-rc.1

The API definition(s) are based on
* Commonalities v0.6.0-rc.1
* Identity and Consent Management v0.4.0-rc.1

## dedicated-network v0.1.0-rc.1

**dedicated-network v0.1.0-rc.1 is the first release-candidate version for v0.1.0 of the Dedicated Network API.**

- dedicated-network v0.1.0-rc.1 API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.1/code/API_definitions/dedicated-network.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.1/code/API_definitions/dedicated-network.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/DedicatedNetworks/blob/r1.1/code/API_definitions/dedicated-network.yaml)


## dedicated-network-accesses v0.1.0-rc.1

**dedicated-network-accesses v0.1.0-rc.1 is the first release-candidate version for v0.1.0 of the Dedicated Network Accesses API.**

- dedicated-network-accesses v0.1.0-rc.1 API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.1/code/API_definitions/dedicated-network-accesses.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.1/code/API_definitions/dedicated-network-accesses.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/DedicatedNetworks/blob/r1.1/code/API_definitions/dedicated-network-accesses.yaml)


## dedicated-network-profiles v0.1.0-rc.1

**dedicated-network-profiles v0.1.0-rc.1 is the first release-candidate version for v0.1.0 of the Dedicated Network Profiles API.**

- dedicated-network-profiles v0.1.0-rc.1 API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.1/code/API_definitions/dedicated-network-profiles.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.1/code/API_definitions/dedicated-network-profiles.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/DedicatedNetworks/blob/r1.1/code/API_definitions/dedicated-network-profiles.yaml)


**Full Changelog**: https://github.com/camaraproject/DedicatedNetworks/commits/r1.1
