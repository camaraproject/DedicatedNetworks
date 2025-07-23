Feature: CAMARA Dedicated Network API, wip - Network Accesses API Operations
    # Input to be provided by the implementation to the tester
    #
    # Implementation indications:
    # * apiRoot: API root of the server URL
    #
    # Testing assets:
    # * At least one existing dedicated network
    # * Valid device identifier (phoneNumber or networkAccessIdentifier)
    # * At least one existing network access
    #
    # References to OAS spec schemas refer to schemas specified in dedicated-network-accesses.yaml

    Background: Common accesses setup
        Given an environment at "apiRoot"
        And the header "Authorization" is set to a valid access token
        And the header "x-correlator" is set to a string value

    # Success scenarios for GET /accesses

    @dedicated_network_accesses_listNetworkAccesses_01_success_all
    Scenario: List all network accesses
        Given the resource "/dedicated-network-accesses/vwip/accesses"
        When the request "listNetworkAccesses" is sent
        Then the response status code is 200
        And the response header "Content-Type" is "application/json"
        And the response header "x-correlator" has the same value as the request header "x-correlator"
        And the response body is an array where each item complies with the OAS schema at "/components/schemas/NetworkAccessInfo"

    @dedicated_network_accesses_listNetworkAccesses_02_success_filtered_by_network
    Scenario: List network accesses filtered by network ID
        Given an existing dedicated network
        And the resource "/dedicated-network-accesses/vwip/accesses"
        And the query parameter "networkId" is set to the ID of the existing network
        When the request "listNetworkAccesses" is sent
        Then the response status code is 200
        And the response header "Content-Type" is "application/json"
        And the response header "x-correlator" has the same value as the request header "x-correlator"
        And the response body is an array where each item complies with the OAS schema at "/components/schemas/NetworkAccessInfo"
        And each item in the response array has property "networkId" equal to the query parameter "networkId"

    @dedicated_network_accesses_listNetworkAccesses_03_success_filtered_by_device
    Scenario: List network accesses filtered by device
        Given a valid device identifier
        And the resource "/dedicated-network-accesses/vwip/accesses"
        And the header "x-device" is set to a RFC 8941 structured field value representing the Device schema (#/components/schemas/Device) (e.g., 'phonenumber="+123456789"')
        When the request "listNetworkAccesses" is sent
        Then the response status code is 200
        And the response header "Content-Type" is "application/json"
        And the response header "x-correlator" has the same value as the request header "x-correlator"
        And the response body is an array where each item complies with the OAS schema at "/components/schemas/NetworkAccessInfo"
        And each item in the response array has property "device" containing the device identifier information that corresponds to the device specified in the "x-device" header

    # Success scenarios for POST /accesses

    @dedicated_network_accesses_createNetworkAccess_01_success
    Scenario: Create a network access with valid parameters
        Given an existing dedicated network
        And the resource "/dedicated-network-accesses/vwip/accesses"
        And the header "Content-Type" is set to "application/json"
        And the header "x-device" is set to a RFC 8941 structured field value representing the Device schema (#/components/schemas/Device) (e.g., 'phonenumber="+123456789"')
        And the request body is set to a request body compliant with the schema at "/components/schemas/CreateNetworkAccess"
        And the request body property "$.networkId" is set to the ID of the existing network
        When the request "createNetworkAccess" is sent
        Then the response status code is 201
        And the response header "Content-Type" is "application/json"
        And the response header "x-correlator" has the same value as the request header "x-correlator"
        And the response header "Location" exists and contains a URL with the created access ID
        And the response body complies with the OAS schema at "/components/schemas/NetworkAccessInfo"
        And the response property "$.networkId" has the same value as in the request body
        And the response property "$.device" contains the same device identifier information as provided in the "x-device" header
        And the response property "$.id" exists and is a valid UUID

    # Success scenarios for GET /accesses/{accessId}

    @dedicated_network_accesses_readNetworkAccess_01_success
    Scenario: Get details of a specific network access
        Given an existing network access
        And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
        And the path parameter "accessId" is set to the ID of the existing access
        When the request "readNetworkAccess" is sent
        Then the response status code is 200
        And the response header "Content-Type" is "application/json"
        And the response header "x-correlator" has the same value as the request header "x-correlator"
        And the response body complies with the OAS schema at "/components/schemas/NetworkAccessInfo"
        And the response property "$.id" is equal to the path parameter "accessId"

    # Success scenarios for DELETE /accesses/{accessId}

    @dedicated_network_accesses_deleteNetworkAccess_01_success
    Scenario: Delete a network access
        Given an existing network access
        And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
        And the path parameter "accessId" is set to the ID of the existing access
        When the request "deleteNetworkAccess" is sent
        Then the response status code is 204
        And the response header "x-correlator" has the same value as the request header "x-correlator"