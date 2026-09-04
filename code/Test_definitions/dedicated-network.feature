Feature: CAMARA Dedicated Network API, vwip - Networks API Operations
  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  #
  # Testing assets:
  # * Valid network profile ID
  # * Valid QoS profile name
  # * Valid service time window
  # * Valid service area ID (UUID of a pre-provisioned area)
  # * Valid notification URL (sink)
  # * At least one existing dedicated network
  # * Valid network name (for name filter testing)
  # * At least two existing dedicated networks (for pagination testing)
  #
  # References to OAS spec schemas refer to schemas specified in dedicated-network.yaml

  Background: Common networks setup
    Given an environment at "apiRoot"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  # Success scenarios for GET /networks

  @dedicated_network_listNetworks_01_success_all_first_page
  Scenario: List first page of all dedicated networks
    Given the resource "/dedicated-network/vwip/networks"
    When the request "listNetworks" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/NetworkInfosPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/NetworkInfo"

  @dedicated_network_listNetworks_02_success_filtered_by_name
  Scenario: List first page of dedicated networks filtered by name
    Given the resource "/dedicated-network/vwip/networks"
    And the query parameter "name" is set to a valid network name
    When the request "listNetworks" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/NetworkInfosPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/NetworkInfo"
    And each item in the response array has property "$.name" equal to the query parameter "name"

  @dedicated_network_listNetworks_03_success_pagination
  Scenario: List a specific page of dedicated networks with an explicit page size
    Given there are at least 2 dedicated networks
    And the resource "/dedicated-network/vwip/networks"
    And the query parameter "perPage" is set to 1
    And the query parameter "page" is set to 2
    When the request "listNetworks" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "X-Total-Count" exists and is the total number of dedicated networks
    And the response header "X-Total-Pages" exists and is the total number of pages
    And the response header "Link" exists
    And the response body complies with the OAS schema at "/components/schemas/NetworkInfosPage"
    And the response property "$.items" is an array with exactly 1 item
    And the response property "$.pagination.page" is equal to the query parameter "page"
    And the response property "$.pagination.perPage" is equal to the query parameter "perPage"
    And the response property "$.pagination.totalCount" has the same value as the response header "X-Total-Count"
    And the response property "$.pagination.totalPages" has the same value as the response header "X-Total-Pages"

  # Success scenarios for POST /networks

  @dedicated_network_createNetwork_01_success_basic
  Scenario: Create a dedicated network (basic success)
    Given the resource "/dedicated-network/vwip/networks"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateNetwork"
    And the request body property "$.networkProfileId" is set to a valid network profile ID
    And the request body property "$.serviceTime" is set to a valid service time window
    And the request body property "$.serviceAreaId" is set to a valid service area ID
    And the request body property "$.serviceTime.start" is set to a value in the future
    When the request "createNetwork" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Location" exists and contains a URL with the created network ID
    And the response body complies with the OAS schema at "/components/schemas/NetworkInfo"
    And the response property "$.id" exists and is a valid UUID
    And the response property "$.status" is "REQUESTED" or "RESERVED"

  @dedicated_network_createNetwork_02_success_echo
  Scenario: Create a dedicated network (response echoes request fields)
    Given the resource "/dedicated-network/vwip/networks"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateNetwork"
    And the request body property "$.networkProfileId" is set to a valid network profile ID
    And the request body property "$.serviceTime" is set to a valid service time window
    And the request body property "$.serviceAreaId" is set to a valid service area ID
    And the request body property "$.sink" is set to a valid notification URL
    And the request body property "$.sinkCredential.credentialType" is set to "ACCESSTOKEN"
    And the request body property "$.sinkCredential.accessToken" is set to a valid access token
    And the request body property "$.sinkCredential.accessTokenExpiresUtc" is set to a valid expiration time in the future
    And the request body property "$.sinkCredential.accessTokenType" is set to "bearer"
    When the request "createNetwork" is sent
    Then the response status code is 201
    And the response property "$.networkProfileId" has the same value as in the request body
    And the response property "$.serviceTime" has the same value as in the request body
    And the response property "$.serviceAreaId" has the same value as in the request body
    And the response property "$.sink" has the same value as in the request body

  @dedicated_network_createNetwork_03_success_with_qos_profile_name
  Scenario: Create a dedicated network with a QoS profile name instead of a network profile ID
    Given the resource "/dedicated-network/vwip/networks"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateNetwork"
    # CreateNetwork requires oneOf networkProfileId / qosProfileName
    And the request body property "$.networkProfileId" is not included
    And the request body property "$.qosProfileName" is set to a valid QoS profile name
    And the request body property "$.serviceTime" is set to a valid service time window
    And the request body property "$.serviceAreaId" is set to a valid service area ID
    And the request body property "$.serviceTime.start" is set to a value in the future
    When the request "createNetwork" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Location" exists and contains a URL with the created network ID
    And the response body complies with the OAS schema at "/components/schemas/NetworkInfo"
    And the response property "$.id" exists and is a valid UUID
    And the response property "$.qosProfileName" has the same value as in the request body
    And the response property "$.status" is "REQUESTED" or "RESERVED"

  @dedicated_network_createNetwork_04_success_with_name
  Scenario: Create a dedicated network with the optional name property
    Given the resource "/dedicated-network/vwip/networks"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateNetwork"
    And the request body property "$.name" is set to a valid network name
    And the request body property "$.networkProfileId" is set to a valid network profile ID
    And the request body property "$.serviceTime" is set to a valid service time window
    And the request body property "$.serviceAreaId" is set to a valid service area ID
    And the request body property "$.serviceTime.start" is set to a value in the future
    When the request "createNetwork" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/NetworkInfo"
    And the response property "$.name" has the same value as in the request body

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
