Feature: CAMARA Dedicated Network API, wip - Network Profiles API Operations
    # Input to be provided by the implementation to the tester
    #
    # Implementation indications:
    # * apiRoot: API root of the server URL
    #
    # Testing assets:
    # * At least one existing network profile
    #
    # References to OAS spec schemas refer to schemas specified in dedicated-network-profiles.yaml

    Background: Common profiles setup
        Given an environment at "apiRoot"
        And the header "Authorization" is set to a valid access token
        And the header "x-correlator" is set to a string value

    # Success scenarios for GET /profiles

    @dedicated_network_profiles_readNetworkProfiles_01_success
    Scenario: List all available network profiles
        Given the resource "/dedicated-network-profiles/vwip/profiles"
        When the request "readNetworkProfiles" is sent
        Then the response status code is 200
        And the response header "Content-Type" is "application/json"
        And the response header "x-correlator" has the same value as the request header "x-correlator"
        And the response body is an array where each item complies with the OAS schema at "/components/schemas/NetworkProfile"
        And each item in the response array has properties "id", "maxNumberOfDevices", "aggregatedUlThroughput", "aggregatedDlThroughput", "qosProfiles", "defaultQosProfile"

    # Success scenarios for GET /profiles/{profileId}

    @dedicated_network_profiles_readNetworkProfile_01_success
    Scenario: Get details of a specific network profile
        Given an existing network profile
        And the resource "/dedicated-network-profiles/vwip/profiles/{profileId}"
        And the path parameter "profileId" is set to the ID of the existing profile
        When the request "readNetworkProfile" is sent
        Then the response status code is 200
        And the response header "Content-Type" is "application/json"
        And the response header "x-correlator" has the same value as the request header "x-correlator"
        And the response body complies with the OAS schema at "/components/schemas/NetworkProfile"
        And the response property "$.id" is equal to the path parameter "profileId"
        And the response property "$.maxNumberOfDevices" exists and is a positive integer
        And the response property "$.aggregatedUlThroughput.value" exists and is a positive integer
        And the response property "$.aggregatedUlThroughput.unit" exists and is one of "bps", "kbps", "Mbps", "Gbps", "Tbps"
        And the response property "$.aggregatedDlThroughput.value" exists and is a positive integer
        And the response property "$.aggregatedDlThroughput.unit" exists and is one of "bps", "kbps", "Mbps", "Gbps", "Tbps"
        And the response property "$.qosProfiles" exists and is a non-empty array
        And the response property "$.defaultQosProfile" exists and is included in "$.qosProfiles"