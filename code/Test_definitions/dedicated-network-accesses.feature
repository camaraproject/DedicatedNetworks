Feature: CAMARA Dedicated Network API, v0.2.0-rc.2 - Network Accesses API Operations
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
  # * At least one existing network access, including at least one device
  # * At least two existing network accesses (for pagination testing)
  # * Valid access name (for name filter testing)
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

  # Success scenarios for GET /accesses

  @dedicated_network_accesses_listAccesses_01_success_all_first_page
  Scenario: List first page of all network accesses
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
    When the request "listAccesses" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessInfosPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessInfo"

  @dedicated_network_accesses_listAccesses_02_success_filtered_by_network_first_page
  Scenario: List first page of network accesses filtered by network ID
    Given an existing dedicated network
    And the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    And the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    And the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    And the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    And the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    And the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    And the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    And the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/AddDeviceErrorResult"
    And each item in the response property "$.results" has property "$.device" that contains a single device identifier that was included in a device object of the request body property "$.devices"

  # Success scenarios for GET /accesses/{accessId}

  @dedicated_network_accesses_readAccess_01_success
  Scenario: Get details of a specific network access
    Given an existing dedicated network
    And an existing network access
    And the resource "/dedicated-network-accesses/v0.2rc2/accesses/{accessId}"
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
    And the resource "/dedicated-network-accesses/v0.2rc2/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of the existing access
    When the request "deleteAccess" is sent
    Then the response status code is 204
    And the response header "x-correlator" has the same value as the request header "x-correlator"

############################ Error Scenarios - listAccesses #############################################

  # Syntax Error scenarios

  @dedicated_network_accesses_listAccesses_400.06_invalid_x-correlator
  Scenario: List accesses with invalid x-correlator header
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
    And the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "listAccesses" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_listAccesses_400.07_invalid_pagination
  Scenario Outline: List accesses with invalid pagination parameters
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
    And the header "Authorization" is set to an access token that does not include scope "dedicated-network-accesses:accesses:read"
    When the request "listAccesses" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_listAccesses_403.02_three_legged_token_not_supported
  Scenario: List accesses with a three-legged access token
    # This operation only supports two-legged access tokens. A three-legged access token
    # does not carry the required scope, so authorization fails
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
    And the header "Authorization" is set to a valid three-legged access token
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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

  @dedicated_network_accesses_createAccess_400.09_invalid_sink
  Scenario: Create access with a sink not valid for the specified protocol
    Given an existing dedicated network
    And the resource "/dedicated-network-accesses/v0.2rc2/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the request body property "$.networkId" is set to the ID of the existing network
    And the request body property "$.sink" is set to a URL that is not valid for the specified protocol (e.g. a URL not using HTTPS)
    When the request "createAccess" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_SINK"
    And the response property "$.message" contains a user friendly text

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_accesses_createAccess_401.01_unauthenticated
  Scenario Outline: Create access with missing, expired or invalid access token
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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

  @dedicated_network_accesses_createAccess_403.02_three_legged_token_not_supported
  Scenario: Create access with a three-legged access token
    # This operation only supports two-legged access tokens. A three-legged access token
    # does not carry the required scope, so authorization fails
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the header "Authorization" is set to a valid three-legged access token
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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
    And the resource "/dedicated-network-accesses/v0.2rc2/accesses"
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

  @dedicated_network_accesses_createAccess_422.01_no_valid_device
  Scenario: Error response when none of the devices can be added on access creation
    Given an existing dedicated network
    And the resource "/dedicated-network-accesses/v0.2rc2/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the request body property "$.networkId" is set to the ID of the existing network
    And the request body property "$.devices" array contains only device objects that cannot be added (e.g. devices with unsupported identifiers)
    When the request "createAccess" is sent
    Then the response status code is 422
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response body complies with the OAS schema at "/components/schemas/AddDevicesNoneProcessed"
    And the response property "$.status" is 422
    And the response property "$.code" is "DEDICATED_NETWORK_ACCESSES.NO_VALID_DEVICE"
    And the response property "$.message" contains a user friendly text
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/AddDeviceErrorResult"
    And each item in the response property "$.results" has property "$.device" that contains a single device identifier that was included in a device object of the request body property "$.devices"
    And no access is created

############################ Error Scenarios - readAccess #############################################

  # Syntax Error scenarios

  @dedicated_network_accesses_readAccess_400.06_invalid_x-correlator
  Scenario: Read access with invalid x-correlator header
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses/{accessId}"
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses/{accessId}"
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" is set to an access token that does not include scope "dedicated-network-accesses:accesses:read"
    When the request "readAccess" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_readAccess_403.02_three_legged_token_not_supported
  Scenario: Read access with a three-legged access token
    # This operation only supports two-legged access tokens. A three-legged access token
    # does not carry the required scope, so authorization fails
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" is set to a valid three-legged access token
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses/{accessId}"
    And the path parameter "accessId" is set to a random access ID
    When the request "readAccess" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_readAccess_404.02_api_client_token_mismatch
  Scenario: Read access not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{accessId}"
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses/{accessId}"
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses/{accessId}"
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" is set to an access token that does not include scope "dedicated-network-accesses:accesses:delete"
    When the request "deleteAccess" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_deleteAccess_403.02_three_legged_token_not_supported
  Scenario: Delete access with a three-legged access token
    # This operation only supports two-legged access tokens. A three-legged access token
    # does not carry the required scope, so authorization fails
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" is set to a valid three-legged access token
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
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses/{accessId}"
    And the path parameter "accessId" is set to a random access ID
    When the request "deleteAccess" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_deleteAccess_404.02_api_client_token_mismatch
  Scenario: Delete access not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the resource "/dedicated-network-accesses/v0.2rc2/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{accessId}"
    When the request "deleteAccess" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text
