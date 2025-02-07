# API Design Considerations

## Introduction
The API design considerations are derived from the API [usage scenarios](UsageScenarios.md). The aim of the API is to hide telco specific complexity, while offering the needed capabilities. There may be different realization of the needed network capabilities, e.g. using shared network slices or even exclusive network slices.

## General Considerations
The API should allow combination with other CAMARA APIs, such as QOD, Connectivity Insights / Monitoring, etc.
The API should follow the CAMARA commonalities guidelines and (potentially) align with other API designs. For example, QOD offers an endpoint for discovery of profiles and another endpoint for activation/deactivation of profiles.

The Dedicated Network API focuses on 
 - reservation of network connectivity resources (e.g. Throughput) potentially with an SLA, for dedicated use by a defined set of devices
 - Selection of (prepared) network capabilities
 - Enable discovery of supported network capabilities/resources (e.g. existing slices to connect to)
 - Controlling access for devices, i.e. which devices may benefit from the reserved resources & capabilities

Reservation of resources should allow for time and location (service area) limits. The dedicated network should support multiple states, i.e. *requested*, *reserved*, *activated* and *terminated*. An HTTP resource represents the needed resources of a dedicated network. The status of the HTTP resource is independent of the status of the representing dedicated network.

- Reserved resources are only usable when the dedicated network is in *activated* state.
- A dedicated network in *reserved* state is committed by the Network Provider. The targeted resources of the dedicated network instance are free to be used by other users or for other purposes, while the network is in *reserved* state. 
- A dedicated network in *requested* state is not (yet) committed by the Network Provider.  
- A dedicated network in *terminated* state cannot be modified anymore and should be deleted. If not deleted the representing HTTP resource (URL) may disappear after some time.

The Network Provider should control the state transition from *requested* state to either *reserved*, *activated* or *terminated* state. The state transition from *reserved* to *activated* is triggered by the reservation start time. The state transition from *activated* to either *reserved* or *terminated* is triggered by the reservation end time. The API consumer should get notified upon state-transitions. 

Note: Functionality to trigger state transition from *activated* back to *reserved* state is not in scope of the initial API, but mentioned for completeness.

There can be different form of resources and capabilities: 
 - It is essential for many use-cases to reserve connectivity capacity, e.g. expressed in aggregated throughput
 - Several use cases require usage of different network capabilities, like for providing Quality on Demand (QOD) or connectivity monitoring, etc.  
To align with other APIs, the reservable resources and capabilities can be summarized in *network profiles*, which can be discovered separately. This would also allow to prepare the underlying network for different usages. 

## Controlling access for devices 
Devices can be added or removed to the dedicated network. Reserved resources & capabilities are only accessible for added devices. Note, devices have only access to the resources / capabilities while the dedicated network is in *activated* state.    
Devices can be identified using the CAMARA devices object, specifically using the format of the phone number or the network access identifier (NAI).

## Considerations for QOD API usage
The dedicated network API should allow usage of the QOD API for On-Demand creation/ deletion of QOS Sessions. The Dedicated Network API should allow for pre-selecting a set of QOS profiles, which should be usable within the dedicated network. When the dedicated network is in *activated* state, an API invoker may use the QOD API for selecting the pre-selected QOS profiles.
Devices, which have access to the dedicated network, will use one of the pre-selected QOS profiles as default.  

## Considerations for Monitoring
There are several potential relevant CAMARA APIs for monitoring, e.g. Connectivity Insights, Connectivity Insights Subscriptions, Session Insights, Device Status, Device Quality Indication, …

## Assumptions for API usage
There are several pre-steps outside of the Dedicated Network API scope. These are for example
  - API consumer on-boarding, specifically obtaining API access credentials.
  - information about other API features.
