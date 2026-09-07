Feature: CAMARA Dedicated Network API, vwip - Networks API Operations
  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  #
  # Testing assets:
  # * Valid network profile ID
  # * Valid service time window
  # * Valid service area ID (UUID of a pre-provisioned area)
  # * Valid notification URL (sink)
  # * At least one existing dedicated network
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

############################ Error Scenarios - listNetworks #############################################

  # Syntax Error scenarios

  @dedicated_network_listNetworks_400.06_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "listNetworks" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_listNetworks_400.07_out_of_range_pagination
  Scenario Outline: Error response for out of range pagination parameters
    Given the resource "/dedicated-network/vwip/networks"
    And the query parameter "<query_parameter>" is set to "<invalid_value>"
    When the request "listNetworks" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "OUT_OF_RANGE"
    And the response property "$.message" contains a user friendly text

    Examples:
      | query_parameter | invalid_value |
      | page            | 0             |
      | perPage         | 0             |
      | perPage         | 101           |

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_listNetworks_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "listNetworks" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_listNetworks_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "listNetworks" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_listNetworks_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "listNetworks" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  # Generic 403 errors

  @dedicated_network_listNetworks_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "dedicated-network:networks:read"
    When the request "listNetworks" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

############################ Error Scenarios - createNetwork #############################################

  # Syntax Error scenarios

  @dedicated_network_createNetwork_400.01_schema_not_compliant
  Scenario: Invalid Argument. Generic Syntax Exception
    Given the request body is included but is not compliant with the schema at "#/components/schemas/CreateNetwork"
    When the request "createNetwork" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_createNetwork_400.02_no_request_body
  Scenario: Missing request body
    Given the request body is not included
    When the request "createNetwork" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_createNetwork_400.03_empty_request_body
  # CreateNetwork has required properties (serviceTime, serviceAreaId, oneOf networkProfileId/qosProfileName)
  Scenario: Empty object as request body
    Given the request body is set to {}
    When the request "createNetwork" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_createNetwork_400.04_empty_property
  Scenario Outline: Error response for empty property in request body
    Given the request body property "<required_property>" is set to {}
    When the request "createNetwork" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | required_property |
      | $.serviceTime     |

  @dedicated_network_createNetwork_400.05_missing_required_property
  Scenario Outline: Error response for missing required property in request body
    Given the request body property "<required_property>" is not included
    When the request "createNetwork" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | required_property |
      | $.serviceTime |
      | $.serviceAreaId |
      | oneOf networkProfileId or qosProfileName |

  @dedicated_network_createNetwork_400.06_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "createNetwork" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_createNetwork_400.07_invalid_sink_credential
  Scenario Outline: Invalid credential
    Given the request body property "$.sinkCredential.credentialType" is set to "<unsupported_credential_type>"
    When the request "createNetwork" is sent
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

  @dedicated_network_createNetwork_400.08_sink_credential_invalid_token
  Scenario: Invalid token
    Given the request body property "$.sinkCredential.accessTokenType" is set to a value other than "bearer"
    When the request "createNetwork" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_TOKEN" OR "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_createNetwork_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "createNetwork" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_createNetwork_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "createNetwork" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_createNetwork_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "createNetwork" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  # Generic 403 errors

  @dedicated_network_createNetwork_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "dedicated-network:networks:create"
    When the request "createNetwork" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 errors

  @dedicated_network_createNetwork_404.01_qosprofilename_not_found
  Scenario: Error response for non-existing QoS profile name
    Given the request body is set to a request body compliant with the schema at "#/components/schemas/CreateNetwork"
    And the request body property "$.serviceTime" is set to a valid service time window
    # CreateNetwork requires oneOf networkProfileId / qosProfileName
    And the request body property "$.networkProfileId" is not included
    And the request body property "$.qosProfileName" is set to a random Qos Profile name
    When the request "createNetwork" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "DEDICATED_NETWORK.QOS_PROFILE_NAME_NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_createNetwork_404.02_networkprofileid_not_found
  Scenario: Error response for non-existing network profile identifier
    Given the request body is set to a request body compliant with the schema at "#/components/schemas/CreateNetwork"
    And the request body property "$.serviceTime" is set to a valid service time window
    # CreateNetwork requires oneOf networkProfileId / qosProfileName
    And the request body property "$.qosProfileName" is not included
    And the request body property "$.networkProfileId" is set to a random network profile ID
    When the request "createNetwork" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "DEDICATED_NETWORK.NETWORK_PROFILE_IDENTIFIER_NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_createNetwork_404.03_serviceareaid_not_found
  Scenario: Error response for non-existing service area identifier
    Given the request body is set to a request body compliant with the schema at "#/components/schemas/CreateNetwork"
    And the request body property "$.serviceTime" is set to a valid service time window
    And the request body property "$.serviceAreaId" is set to a random service area ID
    When the request "createNetwork" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "DEDICATED_NETWORK.SERVICE_AREA_IDENTIFIER_NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  # Generic 422 errors

  @dedicated_network_createNetwork_422.01_out_of_range_service_time
  Scenario Outline: Error response for invalid service time values
    Given the request body is set to a request body compliant with the schema at "#/components/schemas/CreateNetwork"
    And the request body property "$.serviceTime.start" is set to "<start_value>"
    And the request body property "$.serviceTime.end" is set to "<end_value>"
    When the request "createNetwork" is sent
    Then the response status code is 422
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 422
    And the response property "$.code" is "DEDICATED_NETWORK.INCORRECT_SERVICE_TIME"
    And the response property "$.message" contains a user friendly text

    Examples:
      | start_value                  | end_value                    |
      | a valid future date-time     | a date-time before start     |

############################ Error Scenarios - readNetwork #############################################

  @dedicated_network_readNetwork_400.06_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "readNetwork" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_readNetwork_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "readNetwork" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_readNetwork_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "readNetwork" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_readNetwork_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "readNetwork" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  # Generic 403 errors

  @dedicated_network_readNetwork_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "dedicated-network:networks:read"
    When the request "readNetwork" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_readNetwork_403.02_api_client_token_mismatch
  Scenario: "{networkId}" not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{networkId}"
    When the request "readNetwork" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 Errors

  @dedicated_network_readNetwork_404.01_not_found
  Scenario: non-existing "{networkId}"
    Given the resource "/dedicated-network/vwip/networks/{networkId}"
    And the path parameter "networkId" is set to a random network ID
    When the request "readNetwork" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text



############################ Error Scenarios - deleteNetwork #############################################

  # Syntax Error scenarios

  @dedicated_network_deleteNetwork_400.06_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "deleteNetwork" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_deleteNetwork_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "deleteNetwork" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_deleteNetwork_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "deleteNetwork" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_deleteNetwork_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "deleteNetwork" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  # Generic 403 errors

  @dedicated_network_deleteNetwork_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "dedicated-network:networks:delete"
    When the request "deleteNetwork" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_deleteNetwork_403.02_api_client_token_mismatch
  Scenario: "{networkId}" not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{networkId}"
    When the request "deleteNetwork" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 Errors

  @dedicated_network_deleteNetwork_404.01_not_found
  Scenario: non-existing "{networkId}"
    Given the resource "/dedicated-network/vwip/networks/{networkId}"
    And the path parameter "networkId" is set to a random network ID
    When the request "deleteNetwork" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

