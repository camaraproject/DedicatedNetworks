Feature: CAMARA Dedicated Network API, vwip - Network Accesses API Operations
  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  #
  # Testing assets:
  # * At least one existing dedicated network
  # * At least one existing dedicated network in TERMINATED state (for incompatible state testing)
  # * Valid device identifier (phoneNumber)
  # * Valid notification URL (sink)
  # * At least one existing network access, including at least two devices
  # * At least two existing network accesses (for pagination testing)
  # * Valid access name (for name filter testing)
  #
  # References to OAS spec schemas refer to schemas specified in dedicated-network-accesses.yaml

  Background: Common accesses setup
    Given an environment at "apiRoot"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  # Success scenarios for GET /accesses

  @dedicated_network_accesses_listAccesses_01_success_all_first_page
  Scenario: List first page of all network accesses
    Given the resource "/dedicated-network-accesses/vwip/accesses"
    When the request "listAccesses" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessInfosPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessInfo"

  @dedicated_network_accesses_listAccesses_02_success_filtered_by_network_first_page
  Scenario: List first page of network accesses filtered by network ID
    Given an existing dedicated network
    And the resource "/dedicated-network-accesses/vwip/accesses"
    And the query parameter "networkId" is set to the ID of the existing network
    When the request "listAccesses" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessInfosPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessInfo"
    And each item in the response array has property "networkId" equal to the query parameter "networkId"

  @dedicated_network_accesses_listAccesses_03_success_filtered_by_device_first_page
  Scenario: List first page of network accesses filtered by access device ID
    Given an existing network access including at least one device
    And the resource "/dedicated-network-accesses/vwip/accesses"
    And the query parameter "accessDeviceId" is set to the ID of a device included in the existing access
    When the request "listAccesses" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessInfosPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessInfo"
    And the response property "$.items" contains an item with property "id" equal to the ID of the existing access

  @dedicated_network_accesses_listAccesses_04_success_filtered_by_name
  Scenario: List first page of network accesses filtered by name
    Given the resource "/dedicated-network-accesses/vwip/accesses"
    And the query parameter "name" is set to a valid access name
    When the request "listAccesses" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessInfosPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessInfo"
    And each item in the response array has property "$.name" equal to the query parameter "name"

  @dedicated_network_accesses_listAccesses_05_success_pagination
  Scenario: List a specific page of network accesses with an explicit page size
    Given there are at least 2 network accesses
    And the resource "/dedicated-network-accesses/vwip/accesses"
    And the query parameter "perPage" is set to 1
    And the query parameter "page" is set to 2
    When the request "listAccesses" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "X-Total-Count" exists and is the total number of network accesses
    And the response header "X-Total-Pages" exists and is the total number of pages
    And the response header "Link" exists
    And the response body complies with the OAS schema at "/components/schemas/AccessInfosPage"
    And the response property "$.items" is an array with exactly 1 item
    And the response property "$.pagination.page" is equal to the query parameter "page"
    And the response property "$.pagination.perPage" is equal to the query parameter "perPage"
    And the response property "$.pagination.totalCount" has the same value as the response header "X-Total-Count"
    And the response property "$.pagination.totalPages" has the same value as the response header "X-Total-Pages"

  # Success scenarios for POST /accesses

  @dedicated_network_accesses_createAccess_01_success
  Scenario: Create a network access with valid parameters
    Given an existing dedicated network
    And the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the request body property "$.networkId" is set to the ID of the existing network
    And the request body property "$.devices" array contains one or more (up to 100) valid device objects
    When the request "createAccess" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Location" exists and contains a URL with the created access ID
    And the response body complies with the OAS schema at "/components/schemas/CreateAccessSuccess"
    And the response property "$.networkId" has the same value as in the request body
    And the response property "$.id" exists and is a valid UUID
    And the response property "$.stats" exists and complies with the OAS schema at "/components/schemas/AccessStats"

  @dedicated_network_accesses_createAccess_02_success_echo_sink
  Scenario: Create a network access with sink (response echoes sink)
    Given an existing dedicated network
    And the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the request body property "$.networkId" is set to the ID of the existing network
    And the request body property "$.sink" is set to a valid notification URL
    And the request body property "$.sinkCredential.credentialType" is set to "ACCESSTOKEN"
    And the request body property "$.sinkCredential.accessToken" is set to a valid access token
    And the request body property "$.sinkCredential.accessTokenExpiresUtc" is set to a valid expiration time in the future
    And the request body property "$.sinkCredential.accessTokenType" is set to "bearer"
    When the request "createAccess" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/CreateAccessSuccess"
    And the response property "$.sink" has the same value as in the request body

  @dedicated_network_accesses_createAccess_03_success_without_devices
  Scenario: Create a network access without devices
    Given an existing dedicated network
    And the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the request body property "$.networkId" is set to the ID of the existing network
    And the request body property "$.devices" is not included
    When the request "createAccess" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Location" exists and contains a URL with the created access ID
    And the response body complies with the OAS schema at "/components/schemas/CreateAccessSuccess"
    And the response property "$.addedAccessDevices" does not exist
    And the response property "$.stats.totalDevices" is 0

  @dedicated_network_accesses_createAccess_04_success_with_name_and_qos_profiles
  Scenario: Create a network access with name and QoS profiles (response echoes them)
    Given an existing dedicated network
    And the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the request body property "$.networkId" is set to the ID of the existing network
    And the request body property "$.name" is set to a valid access name
    And the request body property "$.qosProfiles" is set to a subset of the QoS profiles of the existing network
    And the request body property "$.defaultQosProfile" is set to one of the QoS profiles in "$.qosProfiles"
    When the request "createAccess" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/CreateAccessSuccess"
    And the response property "$.name" has the same value as in the request body
    And the response property "$.qosProfiles" has the same value as in the request body
    And the response property "$.defaultQosProfile" has the same value as in the request body

  @dedicated_network_accesses_createAccess_05_partial_success
  Scenario: Create a network access where only some of the devices can be added
    Given an existing dedicated network
    And the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the request body property "$.networkId" is set to the ID of the existing network
    And the request body property "$.devices" array contains at least one valid device object and at least one device object that cannot be added (e.g. a duplicate of another device in the request)
    When the request "createAccess" is sent
    Then the response status code is 207
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Location" exists and contains a URL with the created access ID
    And the response body complies with the OAS schema at "/components/schemas/CreateAccessPartialSuccess"
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/ErrorResultForDevice"

  # Success scenarios for GET /accesses/{accessId}

  @dedicated_network_accesses_readAccess_01_success
  Scenario: Get details of a specific network access
    Given an existing dedicated network
    And an existing network access
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
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
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of the existing access
    When the request "deleteAccess" is sent
    Then the response status code is 204
    And the response header "x-correlator" has the same value as the request header "x-correlator"

  # Success scenarios for GET /accesses/{accessId}/devices

  @dedicated_network_accesses_listAccessDevices_01_success_all_first_page
  Scenario: List first page of all devices of a specific network access
    Given an existing dedicated network
    And an existing network access
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of the existing access
    When the request "listAccessDevices" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessDevicesPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessDevice"

  @dedicated_network_accesses_listAccessDevices_02_success_filtered_by_device_status
  Scenario Outline: List first page of devices of a network access filtered by device status
    Given an existing network access
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of the existing access
    And the query parameter "deviceStatus" is set to "<device_status>"
    When the request "listAccessDevices" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessDevicesPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessDevice"
    And each item in the response array has property "$.status" equal to "<device_status>"

    Examples:
      | device_status |
      | REQUESTED     |
      | GRANTED       |
      | DENIED        |

  @dedicated_network_accesses_listAccessDevices_03_success_filtered_by_added_time
  Scenario Outline: List first page of devices of a network access filtered by the time they were added
    Given an existing network access
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of the existing access
    And the query parameter "<time_filter>" is set to a valid RFC 3339 date-time with time zone
    When the request "listAccessDevices" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessDevicesPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessDevice"
    # NOTE: The time filter is applied server-side. The AccessDevice schema does not expose the time
    # a device was added, so the filter result cannot be directly verified from the response body.

    Examples:
      | time_filter |
      | addedAt.gte |
      | addedAt.gt  |
      | addedAt.lte |
      | addedAt.lt  |

  @dedicated_network_accesses_listAccessDevices_04_success_pagination
  Scenario: List a specific page of devices of a network access with an explicit page size
    Given an existing network access including at least two devices
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of the existing access
    And the query parameter "perPage" is set to 1
    And the query parameter "page" is set to 2
    When the request "listAccessDevices" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "X-Total-Count" exists and is the total number of devices of the access
    And the response header "X-Total-Pages" exists and is the total number of pages
    And the response header "Link" exists
    And the response body complies with the OAS schema at "/components/schemas/AccessDevicesPage"
    And the response property "$.items" is an array with exactly 1 item
    And the response property "$.pagination.page" is equal to the query parameter "page"
    And the response property "$.pagination.perPage" is equal to the query parameter "perPage"
    And the response property "$.pagination.totalCount" has the same value as the response header "X-Total-Count"
    And the response property "$.pagination.totalPages" has the same value as the response header "X-Total-Pages"

  # Success scenarios for POST /accesses/{accessId}/devices/add

  @dedicated_network_accesses_addDevicesToAccess_01_success
  Scenario: Add a device to an existing network access
    Given an existing dedicated network
    And an existing network access
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/add"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/AddDevicesRequest"
    And the request body property "$.devices" array contains one or more (up to 100) valid device objects
    When the request "addDevicesToAccess" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AddDevicesSuccess"

  @dedicated_network_accesses_addDevicesToAccess_02_partial_success
  Scenario: Add devices to an existing network access where only some of the devices can be added
    Given an existing network access
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/add"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/AddDevicesRequest"
    And the request body property "$.devices" array contains at least one valid device object and at least one device object that cannot be added (e.g. a duplicate of another device in the request)
    When the request "addDevicesToAccess" is sent
    Then the response status code is 207
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AddDevicesPartialSuccess"
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/ErrorResultForDevice"

  # Success scenarios for POST /accesses/{accessId}/devices/remove

  @dedicated_network_accesses_removeDevicesFromAccess_01_success
  Scenario: Remove a device from an existing network access
    Given an existing dedicated network
    And an existing network access including at least one device
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/remove"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RemoveDevicesRequest"
    And the request body property "$.accessDeviceIds" array contains one or more (up to 100) IDs of devices included in the existing access
    When the request "removeDevicesFromAccess" is sent
    Then the response status code is 204
    And the response header "x-correlator" has the same value as the request header "x-correlator"

  @dedicated_network_accesses_removeDevicesFromAccess_02_partial_success
  Scenario: Remove devices from an existing network access where only some of the devices can be removed
    Given an existing network access including at least one device
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/remove"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RemoveDevicesRequest"
    And the request body property "$.accessDeviceIds" array contains at least one ID of a device included in the existing access and at least one random access device ID
    When the request "removeDevicesFromAccess" is sent
    Then the response status code is 207
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/RemoveDevicesPartialSuccess"
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/ErrorResultForDevice"

  # Success scenarios for GET /accesses/{accessId}/devices/{accessDeviceId}

  @dedicated_network_accesses_readAccessDevice_01_success
  Scenario: Get details of a specific device of a network access
    Given an existing network access including at least one device
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of the existing access
    And the path parameter "accessDeviceId" is set to the ID of a device included in the existing access
    When the request "readAccessDevice" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessDevice"
    And the response property "$.deviceId" is equal to the path parameter "accessDeviceId"

  # Success scenarios for DELETE /accesses/{accessId}/devices/{accessDeviceId}

  @dedicated_network_accesses_deleteAccessDevice_01_success
  Scenario: Delete a specific device from a network access
    Given an existing network access including at least one device
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of the existing access
    And the path parameter "accessDeviceId" is set to the ID of a device included in the existing access
    When the request "deleteAccessDevice" is sent
    Then the response status code is 204
    And the response header "x-correlator" has the same value as the request header "x-correlator"

############################ Error Scenarios - listAccesses #############################################

  # Syntax Error scenarios

  @dedicated_network_accesses_listAccesses_400.06_invalid_x-correlator
  Scenario: List accesses with invalid x-correlator header
    Given the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "listAccesses" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_listAccesses_400.07_invalid_pagination
  Scenario Outline: List accesses with invalid pagination parameters
    Given the resource "/dedicated-network-accesses/vwip/accesses"
    And the query parameter "<query_parameter>" is set to "<invalid_value>"
    When the request "listAccesses" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | query_parameter | invalid_value |
      | page            | 0             |
      | perPage         | 0             |
      | perPage         | 101           |

  @dedicated_network_accesses_listAccesses_400.08_invalid_filter
  Scenario Outline: List accesses with invalid filter parameters
    Given the resource "/dedicated-network-accesses/vwip/accesses"
    And the query parameter "<query_parameter>" is set to "<invalid_value>"
    When the request "listAccesses" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | query_parameter | invalid_value |
      | networkId       | not-a-uuid    |
      | accessDeviceId  | not-a-uuid    |

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_accesses_listAccesses_401.01_unauthenticated
  Scenario Outline: List accesses with missing, expired or invalid access token
    Given the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Authorization" <authorization_header>
    When the request "listAccesses" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

    Examples:
      | authorization_header              |
      | is not sent                       |
      | is set to an expired access token |
      | is set to an invalid access token |

  # Generic 403 errors

  @dedicated_network_accesses_listAccesses_403.01_missing_access_token_scope
  Scenario: List accesses with missing access token scope
    Given the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Authorization" is set to an access token that does not include scope "dedicated-network-accesses:accesses:read"
    When the request "listAccesses" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

############################ Error Scenarios - createAccess #############################################

  # Syntax Error scenarios

  @dedicated_network_accesses_createAccess_400.01_invalid_request_body
  Scenario Outline: Create access with invalid request body
    Given the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is <invalid_request_body>
    When the request "createAccess" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | invalid_request_body                                                                                                      |
      | included but is not compliant with the schema at "/components/schemas/CreateAccessRequest"                                |
      | not included                                                                                                              |
      | set to {}                                                                                                                 |
      | compliant with the schema at "/components/schemas/CreateAccessRequest" except that property "$.networkId" is not included |

  @dedicated_network_accesses_createAccess_400.06_invalid_x-correlator
  Scenario: Create access with invalid x-correlator header
    Given the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "createAccess" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_createAccess_400.07_invalid_sink_credential
  Scenario Outline: Invalid credential
    Given the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the request body property "$.sinkCredential.credentialType" is set to "<unsupported_credential_type>"
    When the request "createAccess" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_CREDENTIAL"
    And the response property "$.message" contains a user friendly text

    Examples:
      | unsupported_credential_type |
      | PLAIN                       |
      | REFRESHTOKEN                |

  @dedicated_network_accesses_createAccess_400.08_sink_credential_invalid_token
  Scenario: Invalid token
    Given the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the request body property "$.sinkCredential.accessTokenType" is set to a value other than "bearer"
    When the request "createAccess" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_TOKEN" OR "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_accesses_createAccess_401.01_unauthenticated
  Scenario Outline: Create access with missing, expired or invalid access token
    Given the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the header "Authorization" <authorization_header>
    When the request "createAccess" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

    Examples:
      | authorization_header              |
      | is not sent                       |
      | is set to an expired access token |
      | is set to an invalid access token |

  # Generic 403 errors

  @dedicated_network_accesses_createAccess_403.01_missing_access_token_scope
  Scenario: Create access with missing access token scope
    Given the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the header "Authorization" is set to an access token that does not include scope "dedicated-network-accesses:accesses:create"
    When the request "createAccess" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 errors

  @dedicated_network_accesses_createAccess_404.01_networkid_not_found
  Scenario: Error response for non-existing network identifier
    Given the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the request body property "$.networkId" is set to a random network ID
    When the request "createAccess" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "DEDICATED_NETWORK_ACCESSES.NETWORK_IDENTIFIER_NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  # Generic 409 errors

  @dedicated_network_accesses_createAccess_409.01_network_incompatible_state
  Scenario: Error response for creating an access to a network in an incompatible state
    Given an existing dedicated network in "TERMINATED" state
    And the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the request body property "$.networkId" is set to the ID of the existing network
    When the request "createAccess" is sent
    Then the response status code is 409
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 409
    And the response property "$.code" is "INCOMPATIBLE_STATE"
    And the response property "$.message" contains a user friendly text

  # Generic 422 errors

  @dedicated_network_accesses_createAccess_422.01_service_not_applicable
  Scenario: Error response for a request the service is not applicable to
    # The condition for which the service is not applicable is implementation specific
    Given an existing dedicated network
    And the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the request body property "$.networkId" is set to the ID of the existing network
    And the request body is set such that the service is not applicable for the requested access
    When the request "createAccess" is sent
    Then the response status code is 422
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 422
    And the response property "$.code" is "SERVICE_NOT_APPLICABLE"
    And the response property "$.message" contains a user friendly text

############################ Error Scenarios - readAccess #############################################

  # Syntax Error scenarios

  @dedicated_network_accesses_readAccess_400.06_invalid_x-correlator
  Scenario: Read access with invalid x-correlator header
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "readAccess" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_accesses_readAccess_401.01_unauthenticated
  Scenario Outline: Read access with missing, expired or invalid access token
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" <authorization_header>
    When the request "readAccess" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

    Examples:
      | authorization_header              |
      | is not sent                       |
      | is set to an expired access token |
      | is set to an invalid access token |

  # Generic 403 errors

  @dedicated_network_accesses_readAccess_403.01_missing_access_token_scope
  Scenario: Read access with missing access token scope
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" is set to an access token that does not include scope "dedicated-network-accesses:accesses:read"
    When the request "readAccess" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_readAccess_403.02_api_client_token_mismatch
  Scenario: Read access not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{accessId}"
    When the request "readAccess" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 errors

  @dedicated_network_accesses_readAccess_404.01_not_found
  Scenario: Read access with non-existing accessId
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
    And the path parameter "accessId" is set to a random access ID
    When the request "readAccess" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

############################ Error Scenarios - deleteAccess #############################################

  # Syntax Error scenarios

  @dedicated_network_accesses_deleteAccess_400.06_invalid_x-correlator
  Scenario: Delete access with invalid x-correlator header
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "deleteAccess" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_accesses_deleteAccess_401.01_unauthenticated
  Scenario Outline: Delete access with missing, expired or invalid access token
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" <authorization_header>
    When the request "deleteAccess" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

    Examples:
      | authorization_header              |
      | is not sent                       |
      | is set to an expired access token |
      | is set to an invalid access token |

  # Generic 403 errors

  @dedicated_network_accesses_deleteAccess_403.01_missing_access_token_scope
  Scenario: Delete access with missing access token scope
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" is set to an access token that does not include scope "dedicated-network-accesses:accesses:delete"
    When the request "deleteAccess" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_deleteAccess_403.02_api_client_token_mismatch
  Scenario: Delete access not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{accessId}"
    When the request "deleteAccess" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 errors

  @dedicated_network_accesses_deleteAccess_404.01_not_found
  Scenario: Delete access with non-existing accessId
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
    And the path parameter "accessId" is set to a random access ID
    When the request "deleteAccess" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

############################ Error Scenarios - listAccessDevices #############################################

  # Syntax Error scenarios

  @dedicated_network_accesses_listAccessDevices_400.06_invalid_x-correlator
  Scenario: List access devices with invalid x-correlator header
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "listAccessDevices" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_listAccessDevices_400.07_invalid_pagination
  Scenario Outline: List access devices with invalid pagination parameters
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the query parameter "<query_parameter>" is set to "<invalid_value>"
    When the request "listAccessDevices" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | query_parameter | invalid_value |
      | page            | 0             |
      | perPage         | 0             |
      | perPage         | 101           |

  @dedicated_network_accesses_listAccessDevices_400.08_invalid_filter
  Scenario Outline: List access devices with invalid filter parameters
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the query parameter "<query_parameter>" is set to "<invalid_value>"
    When the request "listAccessDevices" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | query_parameter | invalid_value     |
      | deviceStatus    | UNKNOWN           |
      | addedAt.gte     | not-a-date-time   |
      | addedAt.gt      | not-a-date-time   |
      | addedAt.lte     | not-a-date-time   |
      | addedAt.lt      | not-a-date-time   |

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_accesses_listAccessDevices_401.01_unauthenticated
  Scenario Outline: List access devices with missing, expired or invalid access token
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" <authorization_header>
    When the request "listAccessDevices" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

    Examples:
      | authorization_header              |
      | is not sent                       |
      | is set to an expired access token |
      | is set to an invalid access token |

  # Generic 403 errors

  @dedicated_network_accesses_listAccessDevices_403.01_missing_access_token_scope
  Scenario: List access devices with missing access token scope
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" is set to an access token that does not include scope "dedicated-network-accesses:devices:read"
    When the request "listAccessDevices" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_listAccessDevices_403.02_api_client_token_mismatch
  Scenario: List devices of an access not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{accessId}"
    When the request "listAccessDevices" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 errors

  @dedicated_network_accesses_listAccessDevices_404.01_not_found
  Scenario: List devices of a non-existing access
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to a random access ID
    When the request "listAccessDevices" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

############################ Error Scenarios - addDevicesToAccess #############################################

  # Syntax Error scenarios

  @dedicated_network_accesses_addDevicesToAccess_400.01_invalid_request_body
  Scenario Outline: Add devices to access with invalid request body
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/add"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is <invalid_request_body>
    When the request "addDevicesToAccess" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | invalid_request_body                                                                     |
      | included but is not compliant with the schema at "/components/schemas/AddDevicesRequest" |
      | not included                                                                             |
      | set to {}                                                                                |
      | set to {"devices": []}                                                                   |

  @dedicated_network_accesses_addDevicesToAccess_400.06_invalid_x-correlator
  Scenario: Add devices to access with invalid x-correlator header
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/add"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/AddDevicesRequest"
    And the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "addDevicesToAccess" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_accesses_addDevicesToAccess_401.01_unauthenticated
  Scenario Outline: Add devices to access with missing, expired or invalid access token
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/add"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/AddDevicesRequest"
    And the header "Authorization" <authorization_header>
    When the request "addDevicesToAccess" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

    Examples:
      | authorization_header              |
      | is not sent                       |
      | is set to an expired access token |
      | is set to an invalid access token |

  # Generic 403 errors

  @dedicated_network_accesses_addDevicesToAccess_403.01_missing_access_token_scope
  Scenario: Add devices to access with missing access token scope
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/add"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/AddDevicesRequest"
    And the header "Authorization" is set to an access token that does not include scope "dedicated-network-accesses:devices:add"
    When the request "addDevicesToAccess" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_addDevicesToAccess_403.02_api_client_token_mismatch
  Scenario: Add devices to an access not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/add"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/AddDevicesRequest"
    And the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{accessId}"
    When the request "addDevicesToAccess" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 errors

  @dedicated_network_accesses_addDevicesToAccess_404.01_not_found
  Scenario: Add devices to a non-existing access
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/add"
    And the path parameter "accessId" is set to a random access ID
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/AddDevicesRequest"
    When the request "addDevicesToAccess" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  # Generic 409 errors

  @dedicated_network_accesses_addDevicesToAccess_409.01_aborted
  Scenario: Error response for adding devices concurrently with another operation on the same access
    # To test this, another operation modifying the devices of the access has to be in progress
    Given an existing network access
    And another operation modifying the devices of the existing access is in progress
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/add"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/AddDevicesRequest"
    When the request "addDevicesToAccess" is sent
    Then the response status code is 409
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 409
    And the response property "$.code" is "ABORTED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_addDevicesToAccess_409.02_incompatible_state
  Scenario: Error response for adding devices to an access of a network in an incompatible state
    Given an existing network access to a dedicated network in "TERMINATED" state
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/add"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/AddDevicesRequest"
    When the request "addDevicesToAccess" is sent
    Then the response status code is 409
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 409
    And the response property "$.code" is "INCOMPATIBLE_STATE"
    And the response property "$.message" contains a user friendly text

  # Generic 422 errors

  @dedicated_network_accesses_addDevicesToAccess_422.01_no_valid_device
  Scenario: Error response when none of the devices can be added
    Given an existing network access including at least one device
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/add"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/AddDevicesRequest"
    And the request body property "$.devices" array contains only device objects that cannot be added (e.g. devices already included in the existing access)
    When the request "addDevicesToAccess" is sent
    Then the response status code is 422
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response body complies with the OAS schema at "/components/schemas/ErrorResults"
    And the response property "$.status" is 422
    And the response property "$.code" is "DEDICATED_NETWORK_ACCESSES.NO_VALID_DEVICE"
    And the response property "$.message" contains a user friendly text
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/ErrorResultForDevice"

############################ Error Scenarios - removeDevicesFromAccess #############################################

  # Syntax Error scenarios

  @dedicated_network_accesses_removeDevicesFromAccess_400.01_invalid_request_body
  Scenario Outline: Remove devices from access with invalid request body
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/remove"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is <invalid_request_body>
    When the request "removeDevicesFromAccess" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | invalid_request_body                                                                        |
      | included but is not compliant with the schema at "/components/schemas/RemoveDevicesRequest" |
      | not included                                                                                |
      | set to {}                                                                                   |
      | set to {"accessDeviceIds": []}                                                              |

  @dedicated_network_accesses_removeDevicesFromAccess_400.06_invalid_x-correlator
  Scenario: Remove devices from access with invalid x-correlator header
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/remove"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RemoveDevicesRequest"
    And the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "removeDevicesFromAccess" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_accesses_removeDevicesFromAccess_401.01_unauthenticated
  Scenario Outline: Remove devices from access with missing, expired or invalid access token
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/remove"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RemoveDevicesRequest"
    And the header "Authorization" <authorization_header>
    When the request "removeDevicesFromAccess" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

    Examples:
      | authorization_header              |
      | is not sent                       |
      | is set to an expired access token |
      | is set to an invalid access token |

  # Generic 403 errors

  @dedicated_network_accesses_removeDevicesFromAccess_403.01_missing_access_token_scope
  Scenario: Remove devices from access with missing access token scope
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/remove"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RemoveDevicesRequest"
    And the header "Authorization" is set to an access token that does not include scope "dedicated-network-accesses:devices:remove"
    When the request "removeDevicesFromAccess" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_removeDevicesFromAccess_403.02_api_client_token_mismatch
  Scenario: Remove devices from an access not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/remove"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RemoveDevicesRequest"
    And the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{accessId}"
    When the request "removeDevicesFromAccess" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 errors

  @dedicated_network_accesses_removeDevicesFromAccess_404.01_not_found
  Scenario: Remove devices from a non-existing access
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/remove"
    And the path parameter "accessId" is set to a random access ID
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RemoveDevicesRequest"
    When the request "removeDevicesFromAccess" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  # Generic 409 errors

  @dedicated_network_accesses_removeDevicesFromAccess_409.01_aborted
  Scenario: Error response for removing devices concurrently with another operation on the same access
    # To test this, another operation modifying the devices of the access has to be in progress
    Given an existing network access including at least one device
    And another operation modifying the devices of the existing access is in progress
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/remove"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.accessDeviceIds" array contains IDs of devices included in the existing access
    When the request "removeDevicesFromAccess" is sent
    Then the response status code is 409
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 409
    And the response property "$.code" is "ABORTED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_removeDevicesFromAccess_409.02_incompatible_state
  Scenario: Error response for removing devices from an access of a network in an incompatible state
    Given an existing network access to a dedicated network in "TERMINATED" state, including at least one device
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/remove"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.accessDeviceIds" array contains IDs of devices included in the existing access
    When the request "removeDevicesFromAccess" is sent
    Then the response status code is 409
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 409
    And the response property "$.code" is "INCOMPATIBLE_STATE"
    And the response property "$.message" contains a user friendly text

  # Generic 422 errors

  @dedicated_network_accesses_removeDevicesFromAccess_422.01_no_valid_device
  Scenario: Error response when none of the devices can be removed
    Given an existing network access
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/remove"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.accessDeviceIds" array contains only random access device IDs
    When the request "removeDevicesFromAccess" is sent
    Then the response status code is 422
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response body complies with the OAS schema at "/components/schemas/ErrorResults"
    And the response property "$.status" is 422
    And the response property "$.code" is "DEDICATED_NETWORK_ACCESSES.NO_VALID_DEVICE"
    And the response property "$.message" contains a user friendly text
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/ErrorResultForDevice"

############################ Error Scenarios - readAccessDevice #############################################

  # Syntax Error scenarios

  @dedicated_network_accesses_readAccessDevice_400.06_invalid_x-correlator
  Scenario: Read access device with invalid x-correlator header
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the path parameter "accessDeviceId" is set to the ID of a device included in the existing access
    And the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "readAccessDevice" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_accesses_readAccessDevice_401.01_unauthenticated
  Scenario Outline: Read access device with missing, expired or invalid access token
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the path parameter "accessDeviceId" is set to the ID of a device included in the existing access
    And the header "Authorization" <authorization_header>
    When the request "readAccessDevice" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

    Examples:
      | authorization_header              |
      | is not sent                       |
      | is set to an expired access token |
      | is set to an invalid access token |

  # Generic 403 errors

  @dedicated_network_accesses_readAccessDevice_403.01_missing_access_token_scope
  Scenario: Read access device with missing access token scope
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the path parameter "accessDeviceId" is set to the ID of a device included in the existing access
    And the header "Authorization" is set to an access token that does not include scope "dedicated-network-accesses:device:read"
    When the request "readAccessDevice" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_readAccessDevice_403.02_api_client_token_mismatch
  Scenario: Read a device of an access not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the path parameter "accessDeviceId" is set to the ID of a device included in the existing access
    And the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{accessId}"
    When the request "readAccessDevice" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 errors

  @dedicated_network_accesses_readAccessDevice_404.01_access_not_found
  Scenario: Read a device of a non-existing access
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to a random access ID
    And the path parameter "accessDeviceId" is set to a random access device ID
    When the request "readAccessDevice" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_readAccessDevice_404.02_access_device_not_found
  Scenario: Read a non-existing device of an existing access
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the path parameter "accessDeviceId" is set to a random access device ID
    When the request "readAccessDevice" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

############################ Error Scenarios - deleteAccessDevice #############################################

  # Syntax Error scenarios

  @dedicated_network_accesses_deleteAccessDevice_400.06_invalid_x-correlator
  Scenario: Delete access device with invalid x-correlator header
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the path parameter "accessDeviceId" is set to the ID of a device included in the existing access
    And the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "deleteAccessDevice" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_accesses_deleteAccessDevice_401.01_unauthenticated
  Scenario Outline: Delete access device with missing, expired or invalid access token
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the path parameter "accessDeviceId" is set to the ID of a device included in the existing access
    And the header "Authorization" <authorization_header>
    When the request "deleteAccessDevice" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

    Examples:
      | authorization_header              |
      | is not sent                       |
      | is set to an expired access token |
      | is set to an invalid access token |

  # Generic 403 errors

  @dedicated_network_accesses_deleteAccessDevice_403.01_missing_access_token_scope
  Scenario: Delete access device with missing access token scope
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the path parameter "accessDeviceId" is set to the ID of a device included in the existing access
    And the header "Authorization" is set to an access token that does not include scope "dedicated-network-accesses:device:delete"
    When the request "deleteAccessDevice" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_deleteAccessDevice_403.02_api_client_token_mismatch
  Scenario: Delete a device of an access not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the path parameter "accessDeviceId" is set to the ID of a device included in the existing access
    And the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{accessId}"
    When the request "deleteAccessDevice" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 errors

  @dedicated_network_accesses_deleteAccessDevice_404.01_access_not_found
  Scenario: Delete a device of a non-existing access
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to a random access ID
    And the path parameter "accessDeviceId" is set to a random access device ID
    When the request "deleteAccessDevice" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_deleteAccessDevice_404.02_access_device_not_found
  Scenario: Delete a non-existing device of an existing access
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the path parameter "accessDeviceId" is set to a random access device ID
    When the request "deleteAccessDevice" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text
