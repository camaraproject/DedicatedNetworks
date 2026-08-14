Feature: CAMARA Dedicated Network API, v0.2.0-rc.1 - Network Accesses API Operations
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
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  # Success scenarios for GET /accesses

  @dedicated_network_accesses_listAccesses_01_success_all_first_page
  Scenario: List first page of all network accesses
    Given the resource "/dedicated-network-accesses/v0.2rc1/accesses"
    When the request "listAccesses" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessInfosPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessInfo"

  @dedicated_network_accesses_listAccesses_02_success_filtered_by_network_first_page
  Scenario: List first page of network accesses filtered by network ID
    Given an existing dedicated network
    And the resource "/dedicated-network-accesses/v0.2rc1/accesses"
    And the query parameter "networkId" is set to the ID of the existing network
    When the request "listAccesses" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessInfosPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessInfo"
    And each item in the response array has property "networkId" equal to the query parameter "networkId"

  @dedicated_network_accesses_listAccesses_03_success_filtered_by_device_first_page
  Scenario: List first page of network accesses filtered by device
    Given a valid device identifier
    And the resource "/dedicated-network-accesses/v0.2rc1/accesses"
    And the header "x-device" is set to a RFC 8941 structured field value representing the Device schema (#/components/schemas/Device) (e.g., 'phonenumber="+123456789"')
    When the request "listAccesses" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessInfosPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessInfo"
    And each item in the response array has property "device" containing the device identifier information that corresponds to the device specified in the "x-device" header

  # Success scenarios for POST /accesses

  @dedicated_network_accesses_createAccess_01_success
  Scenario: Create a network access with valid parameters
    Given an existing dedicated network
    And the resource "/dedicated-network-accesses/v0.2rc1/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the request body property "$.networkId" is set to the ID of the existing network
    And the request body property "$.devices" array contains one or more (up to 100) valid device objects
    When the request "createAccess" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Location" exists and contains a URL with the created access ID
    And the response body complies with the OAS schema at "/components/schemas/AccessInfo"
    And the response property "$.networkId" has the same value as in the request body
    And the response property "$.id" exists and is a valid UUID
    And the response property "$.stats" exists and complies with the OAS schema at "/components/schemas/AccessStats"

  # Success scenarios for GET /accesses/{accessId}

  @dedicated_network_accesses_readAccess_01_success
  Scenario: Get details of a specific network access
    Given an existing dedicated network
    And an existing network access
    And the resource "/dedicated-network-accesses/v0.2rc1/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of the existing access
    When the request "readAccess" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessInfo"
    And the response property "$.id" is equal to the path parameter "accessId"
    And the response property "$.stats" complies with the OAS schema at "/components/schemas/AccessStats"

  # Success scenarios for DELETE /accesses/{accessId}

  @dedicated_network_accesses_deleteAccess_01_success
  Scenario: Delete a network access
    Given an existing dedicated network
    And an existing network access
    And the resource "/dedicated-network-accesses/v0.2rc1/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of the existing access
    When the request "deleteAccess" is sent
    Then the response status code is 204
    And the response header "x-correlator" has the same value as the request header "x-correlator"

  # Success scenarios for GET /accesses/{accessId}/devices

  @dedicated_network_accesses_listDevices_01_success_all_first_page
  Scenario: List first page of all devices of a specific network access
    Given an existing dedicated network
    And an existing network access
    And the resource "/dedicated-network-accesses/v0.2rc1/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of the existing access
    When the request "listDevices" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessDevicesPage"
    And the response property "$.items" complies with the OAS schema at "/components/schemas/AccessDevices"

  # Success scenarios for POST /accesses/{accessId}/devices/add

  @dedicated_network_accesses_addDevicesToAccess_01_success
  Scenario: Add a device to an existing network access
    Given an existing dedicated network
    And an existing network access
    And the resource "/dedicated-network-accesses/v0.2rc1/accesses/{accessId}/devices/add"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/AddDevicesRequest"
    And the request body array contains one or more (up to 100) valid device objects
    When the request "addDevicesToAccess" is sent
    Then the response status code is 201
    And the response body complies with the OAS schema at "/components/schemas/AddDevicesSuccess"

  # Success scenarios for POST /accesses/{accessId}/devices/remove

  @dedicated_network_accesses_removeDevicesFromAccess_01_success
  Scenario: Remove a device from an existing network access
    Given an existing dedicated network
    And an existing network access
    And the resource "/dedicated-network-accesses/v0.2rc1/accesses/{accessId}/devices/remove"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RemoveDevicesRequest"
    And the request body array contains one or more (up to 100) valid device objects
    When the request "removeDevicesFromAccess" is sent
    Then the response status code is 204
