# Usage Scenarios of the Dedicated Networks API

## Introduction

The API was motivated by a number of use cases and usage scenarios during the API presentation ([pdf](https://github.com/camaraproject/APIBacklog/blob/main/documentation/SupportingDocuments/DedicatedNetworks%C2%A0API%C2%A0Introduction.pdf)). A short description is provided in the following.

## Media Production

A Media Producer needs a stable connectivity performance for a camera crew with two or more cameras for capturing the live video footage of a press briefing event. Although multiple cameras are actively used during the production, only a single live video stream is produced. The different cameras are positioned to capture different aspects of the press briefing, for example, one camera is capturing all speakers (pan view) and another camera is capturing individual speakers (head and shoulder). The program director selects the camera (called “Live Camera”), which is feeding the outgoing live video stream. For the selection, the video stream of each camera is shown at a production gallery to the production director.

Each camera should get the needed connectivity performance (in terms of throughput) during the press briefing event. Standby Cameras (cameras, which are only streaming the video to the production gallery) can have a lower quality and lower QOS. The live camera (camera, which is currently feeding the outgoing video stream) should have a higher quality and higher QOS. The used QOS profile is changed dynamically for each camera.

The media producer is planning the video production of the press briefing before the press briefing event. It should be assumed that the media producer is already an API customer of the Network Provider and has access to the Dedicated Network API. The Network is prepared with the needed configurations, like QOS Profile configurations.

The media producer decides on the used cameras before the press briefing. It should be assumed that the media producer has access to a pool of cameras, including video encoding and transmission equipment, and only a subset of cameras are used within a certain production event. Each camera is equipped with a matching SIM for the Network Provider. The media producer permits devices (SIMs), which should get access to the capabilities provided by the Dedicated Network.

## Festival

The festival organizer is interested in obtaining a dedicated network from a public network provider to connect multiple devices for “running” a festival. Thus, the dedicated network is not intended for the festival audience/visitors. The stable connectivity performance provided by the dedicated network is needed for operating credit card readers (festival payment system) and for the CCTV (security) cameras. The quality of the CCTV cameras can be switched between “matrix view” (low quality for each camera) and “single view” (high quality for the single camera). An according QOS profile is selected as needed.

The festival organizer is planning the festival, e.g., how many credit card readers & CCTV cameras are needed. The festival organizer knows, “where” (location) and “when” (time) the festival will be and is interested in getting a dedicated network for enabling the festival.

It should be assumed that the festival organizer is already an API customer of the Network Provider and has access to the Dedicated Network API. Each device is equipped with a matching SIM for the Network Provider. It should be assumed that the festival organizer has more devices/SIMs and only uses a subset of these devices. The festival organizer permits devices (SIMs), which should get access to the capabilities provided by the Dedicated Network.

## Enterprise

A dedicated network is used to connect devices (e.g., Laptops) of employees to corporate services. Different connectivity quality (QOS Profiles) is needed, e.g., during a video conference/virtual meeting. During a virtual meeting, one or more meeting participants may decide to switch on the video camera in addition to the audio streams, to improve the meeting quality.

The Enterprise wants secure access to its corporate services and is planning the needed capacity. The devices are managed by the enterprise IT organization. It should be assumed that the enterprise is already an API customer of the Network Provider, which offers the Dedicated Network API. Each device is equipped with a matching SIM for the Network Provider. The enterprise permits only its own devices (SIMs) to get access to the capabilities provided by the Dedicated Network.
