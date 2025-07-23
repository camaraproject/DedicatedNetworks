<a href="https://github.com/camaraproject/DedicatedNetworks/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/camaraproject/DedicatedNetworks?style=plastic"></a>
<a href="https://github.com/camaraproject/DedicatedNetworks/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/camaraproject/DedicatedNetworks?style=plastic"></a>
<a href="https://github.com/camaraproject/DedicatedNetworks/pulls" title="Open Pull Requests"><img src="https://img.shields.io/github/issues-pr/camaraproject/DedicatedNetworks?style=plastic"></a>
<a href="https://github.com/camaraproject/DedicatedNetworks/graphs/contributors" title="Contributors"><img src="https://img.shields.io/github/contributors/camaraproject/DedicatedNetworks?style=plastic"></a>
<a href="https://github.com/camaraproject/DedicatedNetworks" title="Repo Size"><img src="https://img.shields.io/github/repo-size/camaraproject/DedicatedNetworks?style=plastic"></a>
<a href="https://github.com/camaraproject/DedicatedNetworks/blob/main/LICENSE" title="License"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg?style=plastic"></a>
<a href="https://github.com/camaraproject/DedicatedNetworks/releases/latest" title="Latest Release"><img src="https://img.shields.io/github/release/camaraproject/DedicatedNetworks?style=plastic"></a>
<a href="https://github.com/camaraproject/Governance/blob/main/ProjectStructureAndRoles.md" title="Sandbox API Repository"><img src="https://img.shields.io/badge/Sandbox%20API%20Repository-yellow?style=plastic"></a>

# DedicatedNetworks

Sandbox API Repository to describe, develop, document, and test the DedicatedNetworks Service API(s). The repository does not yet belong to a CAMARA Sub Project.

* API Repository [wiki page](https://lf-camaraproject.atlassian.net/wiki/x/XIArAQ)

## Scope

* Service APIs for DedicatedNetworks (see [APIBacklog.md](https://github.com/camaraproject/APIBacklog/blob/main/documentation/APIbacklog.md))
* The API provides the customer with the ability to:
  * request/modify/delete a (logical) Dedicated Network for API consumers.
  * A Dedicated Network offers
    * specific connectivity performance (e.g. speed/ latency)
    * during a specific time duration (e.g. one hour) and
    * at specific locations (e.g. the area of a festival)
  * A Dedicated Network may be ensured by an SLA.
  * API consumers are able to manage access to this dedicated network for specific devices.
* Describe, develop, document, and test the APIs
* Started: October 2024

## Release Information

**Version Control Notice:** This project undergoes active development with frequent updates to the main branch. No backward compatibility is guaranteed for any code in development branches, including main, until an official release is published. Code changes, including potential reversions, may occur between commits. We recommend using the latest official release version.



**The first pre-release is [r1.1](https://github.com/camaraproject/DedicatedNetworks/releases/tag/r1.1), with the API versions listed below**

To facilitate understanding of these APIs, please consult the [General Description](https://github.com/camaraproject/DedicatedNetworks/blob/r1.1/documentation/API_documentation/DedicatedNetworks_GeneralDescription.md) for essential concepts and workflows prior to examining the technical specifications.

* **dedicated-network v0.1.0-rc.1 (release candidate)**
  [[YAML]](https://github.com/camaraproject/DedicatedNetworks/blob/r1.1/code/API_definitions/dedicated-network.yaml)
  [[View it on ReDoc]](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.1/code/API_definitions/dedicated-network.yaml&nocors)
  [[View it on Swagger Editor]](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.1/code/API_definitions/dedicated-network.yaml)

* **dedicated-network-profiles v0.1.0-rc.1 (release candidate)**
  [[YAML]](https://github.com/camaraproject/DedicatedNetworks/blob/r1.1/code/API_definitions/dedicated-network-profiles.yaml)
  [[View it on ReDoc]](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.1/code/API_definitions/dedicated-network-profiles.yaml&nocors)
  [[View it on Swagger Editor]](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.1/code/API_definitions/dedicated-network-profiles.yaml)

* **dedicated-network-accesses v0.1.0-rc.1 (release candidate)**
  [[YAML]](https://github.com/camaraproject/DedicatedNetworks/blob/r1.1/code/API_definitions/dedicated-network-accesses.yaml)
  [[View it on ReDoc]](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.1/code/API_definitions/dedicated-network-accesses.yaml&nocors)
  [[View it on Swagger Editor]](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.1/code/API_definitions/dedicated-network-accesses.yaml)

Previous releases and pre-releases are available here: https://github.com/camaraproject/DedicatedNetworks/releases

For changes see the [CHANGELOG.md](https://github.com/camaraproject/DedicatedNetworks/blob/main/CHANGELOG.md)

## Contributing
* Meetings are held virtually
    * Schedule: bi-weekly, Mondays, 10 AM CEST (08:00 UTC). For date/time of the next meeting, see previous meeting minutes
    * [Registration / Join](https://zoom-lfx.platform.linuxfoundation.org/meeting/94505909302?password=67b9a175-154f-4fe1-986d-0b825227a95b)
    * Minutes: Access [meeting minutes](https://lf-camaraproject.atlassian.net/l/cp/S3hQ1AFG)
* Mailing List
    * Subscribe / Unsubscribe to the mailing list of this Sub Project <https://lists.camaraproject.org/g/sp-dedicated-networks>.
    * A message to the community of this Sub Project can be sent using sp-dedicated-networks@lists.camaraproject.org.
