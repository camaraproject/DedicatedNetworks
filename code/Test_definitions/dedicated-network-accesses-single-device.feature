Feature: CAMARA Dedicated Network API, vwip - Network Accesses API, Single-Device Operations
  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  # * List of device identifier types which are not supported, if any (for UNSUPPORTED_IDENTIFIER testing)
  #
  # Testing assets:
  # * Valid device identifier (phoneNumber) of a device not included in the existing access
  # * At least one existing network access, including at least one device
  # * At least one existing network access whose number of devices has reached the maxNumberOfDevices of its network profile (for quota testing)
  # * A device object for which the service is not applicable, if any
  # * Valid three-legged access token whose subject is a device not included in the existing access (for adding the device)
  # * Valid three-legged access token whose subject is a device included in the existing access and added with that token, with at least one other device in the same access (for read, delete and invalid token context testing)
  # * Valid access token emitted to a different API client (for access ownership testing)
  #
  # Unless stated otherwise, scenarios use a two-legged access token. The operations in this
  # feature support both two-legged and three-legged access tokens.
  #
  # References to OAS spec schemas refer to schemas specified in dedicated-network-accesses.yaml

  Background: Common accesses setup
    Given an environment at "apiRoot"
    And the header "Authorization" is set to a valid two-legged access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  # Success scenarios for POST /accesses/{accessId}/devices

  @dedicated_network_accesses_addDeviceToAccess_01_success
  Scenario: Add a single device identified by a device object to an existing network access
    Given an existing network access
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.device" is set to a valid device object for a device not included in the existing access
    When the request "addDeviceToAccess" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Location" exists and contains a URL with the created access device ID
    And the response body complies with the OAS schema at "/components/schemas/AccessDevice"
    And the response property "$.device" has the same value as in the request body
    And the response property "$.status" is "REQUESTED"
    And the response property "$.addedAt" exists

  @dedicated_network_accesses_addDeviceToAccess_02_success_three_legged
  Scenario: Add the device identified by a three-legged access token to an existing network access
    Given an existing network access
    And the header "Authorization" is set to a valid three-legged access token whose subject is a device not included in the existing access
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to {}
    When the request "addDeviceToAccess" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Location" exists and contains a URL with the created access device ID
    And the response body complies with the OAS schema at "/components/schemas/AccessDevice"
    And the response property "$.device" does not exist
    And the response property "$.status" is "REQUESTED"
    And the response property "$.addedAt" exists

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
    And the response property "$.accessDeviceId" is equal to the path parameter "accessDeviceId"

  @dedicated_network_accesses_readAccessDevice_02_success_three_legged
  Scenario: Get details of the device of a network access identified by a three-legged access token
    Given an existing network access including the device that is the subject of a valid three-legged access token, added with that three-legged access token
    And the header "Authorization" is set to that three-legged access token
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of the existing access
    And the path parameter "accessDeviceId" is set to the ID of the device that is the subject of the access token
    When the request "readAccessDevice" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessDevice"
    And the response property "$.accessDeviceId" is equal to the path parameter "accessDeviceId"
    And the response property "$.device" does not exist

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

  @dedicated_network_accesses_deleteAccessDevice_02_success_three_legged
  Scenario: Delete the device identified by a three-legged access token from a network access
    Given an existing network access including the device that is the subject of a valid three-legged access token
    And the header "Authorization" is set to that three-legged access token
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of the existing access
    And the path parameter "accessDeviceId" is set to the ID of the device that is the subject of the access token
    When the request "deleteAccessDevice" is sent
    Then the response status code is 204
    And the response header "x-correlator" has the same value as the request header "x-correlator"

############################ Error Scenarios - addDeviceToAccess #############################################

  # Syntax Error scenarios

  @dedicated_network_accesses_addDeviceToAccess_400.01_invalid_request_body
  Scenario Outline: Add a single device to access with invalid request body
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is <invalid_request_body>
    When the request "addDeviceToAccess" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | invalid_request_body                                                                    |
      | included but is not compliant with the schema at "/components/schemas/AddDeviceRequest" |
      | not included                                                                            |

  @dedicated_network_accesses_addDeviceToAccess_400.06_invalid_x-correlator
  Scenario: Add a single device to access with invalid x-correlator header
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.device" is set to a valid device object for a device not included in the existing access
    And the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "addDeviceToAccess" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_accesses_addDeviceToAccess_401.01_unauthenticated
  Scenario Outline: Add a single device to access with missing, expired or invalid access token
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.device" is set to a valid device object for a device not included in the existing access
    And the header "Authorization" <authorization_header>
    When the request "addDeviceToAccess" is sent
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

  @dedicated_network_accesses_addDeviceToAccess_403.01_missing_access_token_scope
  Scenario: Add a single device to access with missing access token scope
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.device" is set to a valid device object for a device not included in the existing access
    And the header "Authorization" is set to an access token that does not include scope "dedicated-network-accesses:device:create"
    When the request "addDeviceToAccess" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 errors

  @dedicated_network_accesses_addDeviceToAccess_404.01_not_found
  Scenario: Add a single device to a non-existing access
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to a random access ID
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.device" is set to a valid device object for a device not included in the existing access
    When the request "addDeviceToAccess" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_addDeviceToAccess_404.02_api_client_token_mismatch
  Scenario: Add a single device to an access not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.device" is set to a valid device object for a device not included in the existing access
    And the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{accessId}"
    When the request "addDeviceToAccess" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_addDeviceToAccess_404.03_identifier_not_found
  Scenario: Add a single device whose device object cannot be matched to a device
    Given an existing network access
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.device" is set to a syntactically valid device object that cannot be matched to any device
    When the request "addDeviceToAccess" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "IDENTIFIER_NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  # Generic 409 errors

  @dedicated_network_accesses_addDeviceToAccess_409.01_already_exists
  Scenario: Add a single device that is already included in the access
    Given an existing network access including at least one device
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.device" is set to the device object of a device included in the existing access
    When the request "addDeviceToAccess" is sent
    Then the response status code is 409
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 409
    And the response property "$.code" is "ALREADY_EXISTS"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_addDeviceToAccess_409.02_already_exists_three_legged
  Scenario: Add the device identified by a three-legged access token when it is already included in the access
    Given an existing network access including the device that is the subject of a valid three-legged access token
    And the header "Authorization" is set to that three-legged access token
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to {}
    When the request "addDeviceToAccess" is sent
    Then the response status code is 409
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 409
    And the response property "$.code" is "ALREADY_EXISTS"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_addDeviceToAccess_409.03_incompatible_state
  Scenario: Add a single device to an access of a network in an incompatible state
    Given an existing network access to a dedicated network in "TERMINATED" state
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.device" is set to the device object of a device not included in the existing access
    When the request "addDeviceToAccess" is sent
    Then the response status code is 409
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 409
    And the response property "$.code" is "INCOMPATIBLE_STATE"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_addDeviceToAccess_409.04_aborted
  Scenario: Add a single device concurrently with another operation on the same access
    # To test this, another operation modifying the devices of the access has to be in progress
    Given an existing network access
    And another operation modifying the devices of the existing access is in progress
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.device" is set to the device object of a device not included in the existing access
    When the request "addDeviceToAccess" is sent
    Then the response status code is 409
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 409
    And the response property "$.code" is "ABORTED"
    And the response property "$.message" contains a user friendly text

  # Generic 422 errors

  @dedicated_network_accesses_addDeviceToAccess_422.01_missing_identifier
  Scenario: Add a single device with a two-legged access token and without device object
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body is set to {}
    When the request "addDeviceToAccess" is sent
    Then the response status code is 422
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 422
    And the response property "$.code" is "MISSING_IDENTIFIER"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_addDeviceToAccess_422.02_unnecessary_identifier
  Scenario: Add a single device with a three-legged access token and a device object
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Authorization" is set to a valid three-legged access token whose subject is a device
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.device" is set to a valid device object
    When the request "addDeviceToAccess" is sent
    Then the response status code is 422
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 422
    And the response property "$.code" is "UNNECESSARY_IDENTIFIER"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_addDeviceToAccess_422.03_unsupported_identifier
  Scenario: Add a single device identified by an unsupported device identifier
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.device" is set to a device object with only identifiers that are not supported by the implementation
    When the request "addDeviceToAccess" is sent
    Then the response status code is 422
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 422
    And the response property "$.code" is "UNSUPPORTED_IDENTIFIER"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_accesses_addDeviceToAccess_422.04_service_not_applicable
  Scenario: Add a single device for which the service is not applicable
    # The condition for which the service is not applicable is implementation specific
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of an existing access
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.device" is set to a valid device object for which the service is not applicable
    When the request "addDeviceToAccess" is sent
    Then the response status code is 422
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 422
    And the response property "$.code" is "SERVICE_NOT_APPLICABLE"
    And the response property "$.message" contains a user friendly text

  # Generic 429 errors

  @dedicated_network_accesses_addDeviceToAccess_429.01_quota_exceeded
  Scenario: Add a single device to an access exceeding the maximum number of allowed devices
    # The maximum number of devices is defined by maxNumberOfDevices in the network profile of the dedicated network
    Given an existing network access whose number of devices has reached the maximum number of devices allowed by the network profile
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices"
    And the path parameter "accessId" is set to the ID of the existing access
    And the header "Content-Type" is set to "application/json"
    And the request body property "$.device" is set to a valid device object for a device not included in the existing access
    When the request "addDeviceToAccess" is sent
    Then the response status code is 429
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 429
    And the response property "$.code" is "QUOTA_EXCEEDED"
    And the response property "$.message" contains a user friendly text

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

  @dedicated_network_accesses_readAccessDevice_403.02_invalid_token_context
  Scenario: Read a device of another subject with a three-legged access token
    Given an existing network access including at least one device that is not the subject of a valid three-legged access token
    And the header "Authorization" is set to that three-legged access token
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of the existing access
    And the path parameter "accessDeviceId" is set to the ID of a device included in the existing access that is not the subject of the access token
    When the request "readAccessDevice" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "INVALID_TOKEN_CONTEXT"
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

  @dedicated_network_accesses_readAccessDevice_404.03_api_client_token_mismatch
  Scenario: Read a device of an access not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the path parameter "accessDeviceId" is set to the ID of a device included in the existing access
    And the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{accessId}"
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

  @dedicated_network_accesses_deleteAccessDevice_403.02_invalid_token_context
  Scenario: Delete a device of another subject with a three-legged access token
    Given an existing network access including at least one device that is not the subject of a valid three-legged access token
    And the header "Authorization" is set to that three-legged access token
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of the existing access
    And the path parameter "accessDeviceId" is set to the ID of a device included in the existing access that is not the subject of the access token
    When the request "deleteAccessDevice" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "INVALID_TOKEN_CONTEXT"
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

  @dedicated_network_accesses_deleteAccessDevice_404.03_api_client_token_mismatch
  Scenario: Delete a device of an access not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the resource "/dedicated-network-accesses/vwip/accesses/{accessId}/devices/{accessDeviceId}"
    And the path parameter "accessId" is set to the ID of an existing access
    And the path parameter "accessDeviceId" is set to the ID of a device included in the existing access
    And the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{accessId}"
    When the request "deleteAccessDevice" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text
