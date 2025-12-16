<a href="https://github.com/camaraproject/DedicatedNetworks/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/camaraproject/DedicatedNetworks?style=plastic"></a>
<a href="https://github.com/camaraproject/DedicatedNetworks/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/camaraproject/DedicatedNetworks?style=plastic"></a>
<a href="https://github.com/camaraproject/DedicatedNetworks/pulls" title="Open Pull Requests"><img src="https://img.shields.io/github/issues-pr/camaraproject/DedicatedNetworks?style=plastic"></a>
<a href="https://github.com/camaraproject/DedicatedNetworks/graphs/contributors" title="Contributors"><img src="https://img.shields.io/github/contributors/camaraproject/DedicatedNetworks?style=plastic"></a>
<a href="https://github.com/camaraproject/DedicatedNetworks" title="Repo Size"><img src="https://img.shields.io/github/repo-size/camaraproject/DedicatedNetworks?style=plastic"></a>
<a href="https://github.com/camaraproject/DedicatedNetworks/blob/main/LICENSE" title="License"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg?style=plastic"></a>
<a href="https://github.com/camaraproject/DedicatedNetworks/releases/latest" title="Latest Release"><img src="https://img.shields.io/github/release/camaraproject/DedicatedNetworks?style=plastic"></a>
<a href="https://github.com/camaraproject/Governance/blob/main/ProjectStructureAndRoles.md" title="Sandbox API Repository"><img src="https://img.shields.io/badge/Sandbox%20API%20Repository-yellow?style=plastic"></a>

# DedicatedNetworks

Sandbox API Repository to describe, develop, document, and test the DedicatedNetworks Service API(s) within the Sub Project [Connectivity Quality Management](https://lf-camaraproject.atlassian.net/wiki/x/hAClB).

* API Repository [wiki page](https://lf-camaraproject.atlassian.net/wiki/x/XIArAQ)

* API Repository [wiki page](https://lf-camaraproject.atlassian.net/wiki/x/OICGAQ)

For background on Dedicated Networks concepts and workflows, see the [General Description](documentation/API_documentation/DedicatedNetworks_GeneralDescription.md).

## Scope

* Service APIs for DedicatedNetworks (see [APIBacklog.md](https://github.com/camaraproject/APIBacklog/blob/main/documentation/APIbacklog.md))
* The API provides the API Consumer with the ability to:
  * request/modify/delete a (logical) Dedicated Network for API consumers.
  * A Dedicated Network offers
    * specific connectivity performance (e.g. speed/ latency)
    * during a specific time duration (e.g. one hour) and
    * at specific locations (e.g. the area of a festival)
  * A Dedicated Network may be ensured by an SLA.
  * API consumers are able to manage access to this dedicated network for specific devices.
* Describe, develop, document, and test the APIs
* Started: October 2024

<!-- CAMARA:RELEASE-INFO:START -->
<!-- The following section is automatically maintained by the CAMARA project-administration tooling: https://github.com/camaraproject/project-administration -->

## Release Information

> [!NOTE]
> Please be aware that the project will have frequent updates to the main branch. There are no compatibility guarantees associated with code in any branch, including main, until a new release is created. For example, changes may be reverted before a release is created. **For best results, use the latest available release**.

* **NEW**: The latest public release is [r1.2](https://github.com/camaraproject/DedicatedNetworks/releases/tag/r1.2) (Fall25), with the following API versions:
  * **dedicated-network-accesses v0.1.0**
  [[YAML]](https://github.com/camaraproject/DedicatedNetworks/blob/r1.2/code/API_definitions/dedicated-network-accesses.yaml)
  [[ReDoc]](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.2/code/API_definitions/dedicated-network-accesses.yaml&nocors)
  [[Swagger]](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.2/code/API_definitions/dedicated-network-accesses.yaml)
  * **dedicated-network-profiles v0.1.0**
  [[YAML]](https://github.com/camaraproject/DedicatedNetworks/blob/r1.2/code/API_definitions/dedicated-network-profiles.yaml)
  [[ReDoc]](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.2/code/API_definitions/dedicated-network-profiles.yaml&nocors)
  [[Swagger]](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.2/code/API_definitions/dedicated-network-profiles.yaml)
  * **dedicated-network v0.1.0**
  [[YAML]](https://github.com/camaraproject/DedicatedNetworks/blob/r1.2/code/API_definitions/dedicated-network.yaml)
  [[ReDoc]](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.2/code/API_definitions/dedicated-network.yaml&nocors)
  [[Swagger]](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/DedicatedNetworks/r1.2/code/API_definitions/dedicated-network.yaml)
* The latest public release is always available here: https://github.com/camaraproject/DedicatedNetworks/releases/latest
* Other releases of this repository are available in https://github.com/camaraproject/DedicatedNetworks/releases
* For changes see [CHANGELOG.md](https://github.com/camaraproject/DedicatedNetworks/blob/main/CHANGELOG.md)

_The above section is automatically synchronized by CAMARA project-administration._
<!-- CAMARA:RELEASE-INFO:END -->

## Contributing
* Meetings are held virtually
    * Schedule: bi-weekly, Mondays, 10 AM CET (09:00 UTC). For date/time of the next meeting, see previous meeting minutes
    * [Registration / Join](https://zoom-lfx.platform.linuxfoundation.org/meeting/94505909302?password=67b9a175-154f-4fe1-986d-0b825227a95b)
    * Minutes: Access [meeting minutes](https://lf-camaraproject.atlassian.net/l/cp/S3hQ1AFG)
* Mailing List
    * Subscribe / Unsubscribe to the mailing list of this Sub Project <https://lists.camaraproject.org/g/sp-cqm>.
    * A message to the community of this Sub Project can be sent using sp-cqm@lists.camaraproject.org.
