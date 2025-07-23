Feature: CAMARA Dedicated Network API, wip - Networks API Operations
    # Input to be provided by the implementation to the tester
    #
    # Implementation indications:
    # * apiRoot: API root of the server URL
    #
    # Testing assets:
    # * Valid network profile ID
    # * Valid service time window
    # * At least one existing dedicated network
    #
    # References to OAS spec schemas refer to schemas specified in dedicated-network.yaml

    Background: Common networks setup
        Given an environment at "apiRoot"
        And the header "Authorization" is set to a valid access token
        And the header "x-correlator" is set to a string value

    # Success scenarios for GET /networks

    @dedicated_network_listNetworks_01_success
    Scenario: List all dedicated networks
        Given the resource "/dedicated-network/vwip/networks"
        When the request "listNetworks" is sent
        Then the response status code is 200
        And the response header "Content-Type" is "application/json"
        And the response header "x-correlator" has the same value as the request header "x-correlator"
        And the response body is an array where each item complies with the OAS schema at "/components/schemas/NetworkInfo"

    # Success scenarios for POST /networks

    @dedicated_network_createNetwork_01_success
    Scenario: Create a dedicated network with valid parameters
        Given the resource "/dedicated-network/vwip/networks"
        And the header "Content-Type" is set to "application/json"
        And the request body is set to a request body compliant with the schema at "/components/schemas/CreateNetwork"
        And the request body property "$.profileId" is set to a valid network profile ID
        And the request body property "$.serviceTime" is set to a valid service time window
        And the request body property "$.serviceArea.areaType" is set to "AREANAME"
        And the request body property "$.serviceArea.areaName" is set to a valid area name
        And the request body property "$.sink" is set to a valid notification URL
        And the request body property "$.sinkCredential.credentialType" is set to "ACCESSTOKEN"
        When the request "createNetwork" is sent
        Then the response status code is 201
        And the response header "Content-Type" is "application/json"
        And the response header "x-correlator" has the same value as the request header "x-correlator"
        And the response header "Location" exists and contains a URL with the created network ID
        And the response body complies with the OAS schema at "/components/schemas/NetworkInfo"
        And the response property "$.profileId" has the same value as in the request body
        And the response property "$.serviceTime" has the same value as in the request body
        And the response property "$.serviceArea" has the same value as in the request body
        And the response property "$.sink" exists only if provided in the request body and with the same value
        And the response property "$.id" exists and is a valid UUID
        And the response property "$.status" is "REQUESTED"

    # Success scenarios for GET /networks/{networkId}

    @dedicated_network_readNetwork_01_success
    Scenario: Get details of a specific network
        Given an existing dedicated network
        And the resource "/dedicated-network/vwip/networks/{networkId}"
        And the path parameter "networkId" is set to the ID of the existing network
        When the request "readNetwork" is sent
        Then the response status code is 200
        And the response header "Content-Type" is "application/json"
        And the response header "x-correlator" has the same value as the request header "x-correlator"
        And the response body complies with the OAS schema at "/components/schemas/NetworkInfo"
        And the response property "$.id" is equal to the path parameter "networkId"

    # Success scenarios for DELETE /networks/{networkId}

    @dedicated_network_deleteNetwork_01_success
    Scenario: Delete a dedicated network
        Given an existing dedicated network
        And the resource "/dedicated-network/vwip/networks/{networkId}"
        And the path parameter "networkId" is set to the ID of the existing network
        When the request "deleteNetwork" is sent
        Then the response status code is 204
        And the response header "x-correlator" has the same value as the request header "x-correlator"