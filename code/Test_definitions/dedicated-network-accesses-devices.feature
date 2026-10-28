Feature: CAMARA Dedicated Network API, vwip - Network Accesses API, Multiple-Device Operations
  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  #
  # Testing assets:
  # * At least one existing dedicated network
  # * At least one existing network access to a dedicated network in TERMINATED state, including at least one device (for incompatible state testing)
  # * Valid device identifier (phoneNumber)
  # * At least one existing network access, including at least two devices (also used for pagination testing)
  # * Means to have another operation modifying the devices of an access in progress (for ABORTED testing)
  # * Valid three-legged access token (for testing that three-legged access tokens are rejected)
  # * Valid access token emitted to a different API client (for access ownership testing)
  #
  # All scenarios use a two-legged access token unless stated otherwise. The operations in this
  # feature only support two-legged access tokens.
  #
  # References to OAS spec schemas refer to schemas specified in dedicated-network-accesses.yaml

  Background: Common accesses setup
    Given an environment at "apiRoot"
    And the header "Authorization" is set to a valid two-legged access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

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
    And each item in the response array has property "$.addedAt" that satisfies the "<time_filter>" condition against the query parameter "<time_filter>"

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
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/AddDeviceErrorResult"
    And each item in the response property "$.results" has property "$.device" that contains a single device identifier that was included in a device object of the request body property "$.devices"

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
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/RemoveDeviceErrorResult"
    And each item in the response property "$.results" has property "$.accessDeviceId" equal to one of the random access device IDs in the request body property "$.accessDeviceIds"

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

  @dedicated_network_accesses_listAccessDevices_403.02_three_legged_token_not_supported
  Scenario: List access devices with a three-legged access token
    # This operation only supports two-legged access tokens. A three-legged access token
    # does not carry the required scope, so authorization fails
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" is set to a valid three-legged access token
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

  @dedicated_network_accesses_listAccessDevices_404.02_api_client_token_mismatch
  Scenario: List devices of an access not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{accessId}"
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

  @dedicated_network_accesses_addDevicesToAccess_403.02_three_legged_token_not_supported
  Scenario: Add devices to access with a three-legged access token
    # This operation only supports two-legged access tokens. A three-legged access token
    # does not carry the required scope, so authorization fails
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/add"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/AddDevicesRequest"
    And the header "Authorization" is set to a valid three-legged access token
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

  @dedicated_network_accesses_addDevicesToAccess_404.02_api_client_token_mismatch
  Scenario: Add devices to an access not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/add"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/AddDevicesRequest"
    And the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{accessId}"
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
    And the response body complies with the OAS schema at "/components/schemas/AddDevicesNoneProcessed"
    And the response property "$.status" is 422
    And the response property "$.code" is "DEDICATED_NETWORK_ACCESSES.NO_VALID_DEVICE"
    And the response property "$.message" contains a user friendly text
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/AddDeviceErrorResult"
    And each item in the response property "$.results" has property "$.device" that contains a single device identifier that was included in a device object of the request body property "$.devices"

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

  @dedicated_network_accesses_removeDevicesFromAccess_403.02_three_legged_token_not_supported
  Scenario: Remove devices from access with a three-legged access token
    # This operation only supports two-legged access tokens. A three-legged access token
    # does not carry the required scope, so authorization fails
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/remove"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RemoveDevicesRequest"
    And the header "Authorization" is set to a valid three-legged access token
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

  @dedicated_network_accesses_removeDevicesFromAccess_404.02_api_client_token_mismatch
  Scenario: Remove devices from an access not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/remove"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RemoveDevicesRequest"
    And the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{accessId}"
    When the request "removeDevicesFromAccess" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
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
    And the response body complies with the OAS schema at "/components/schemas/RemoveDevicesNoneProcessed"
    And the response property "$.status" is 422
    And the response property "$.code" is "DEDICATED_NETWORK_ACCESSES.NO_VALID_DEVICE"
    And the response property "$.message" contains a user friendly text
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/RemoveDeviceErrorResult"
    And each item in the response property "$.results" has property "$.accessDeviceId" equal to one of the random access device IDs in the request body property "$.accessDeviceIds"
