Feature: CAMARA Dedicated Network API, vwip - Network Profiles API Operations
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
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  # Success scenarios for GET /profiles

  @dedicated_network_profiles_readNetworkProfiles_01_success_all_first_page
  Scenario: List first page of all available network profiles
    Given the resource "/dedicated-network-profiles/vwip/profiles"
    When the request "readNetworkProfiles" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/NetworkProfilesPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/NetworkProfile"
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
    And the response property "$.qosProfiles" exists and is a non-empty array
    And the response property "$.defaultQosProfile" exists and is included in "$.qosProfiles"

    ############################ Error Scenarios - readNetworkProfiles #############################################

  # Syntax Error scenarios

  @dedicated_network_profiles_readNetworkProfiles_400.06_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "readNetworkProfiles" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_profiles_readNetworkProfiles_400.07_out_of_range_pagination
  Scenario Outline: Error response for out of range pagination parameters
    Given the resource "/dedicated-network-profiles/vwip/profiles"
    And the query parameter "<query_parameter>" is set to "<invalid_value>"
    When the request "readNetworkProfiles" is sent
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

  @dedicated_network_profiles_readNetworkProfiles_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "readNetworkProfiles" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_profiles_readNetworkProfiles_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "readNetworkProfiles" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_profiles_readNetworkProfiles_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "readNetworkProfiles" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  # Generic 403 errors

  @dedicated_network_profiles_readNetworkProfiles_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "dedicated-network-profiles:profiles:read"
    When the request "readNetworkProfiles" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

    ############################ Error Scenarios readNetworkProfile #############################################

  # Syntax Error scenarios

  @dedicated_network_profiles_readNetworkProfile_400.06_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "readNetworkProfile" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_profiles_readNetworkProfile_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "readNetworkProfile" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_profiles_readNetworkProfile_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "readNetworkProfile" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_profiles_readNetworkProfile_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "readNetworkProfile" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  # Generic 403 errors

  @dedicated_network_profiles_readNetworkProfile_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "dedicated-network-profiles:profiles:read"
    When the request "readNetworkProfile" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_profiles_readNetworkProfile_403.02_api_client_token_mismatch
  Scenario: "{profileId}" not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "{profileId}"
    When the request "readNetworkProfile" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 Errors

  @dedicated_network_profiles_readNetworkProfile_404.01_identifier_not_found
  Scenario: non-existing "{profileId}"
    Given the resource "/dedicated-network-profiles/vwip/profiles/{profileId}"
    And the path parameter "profileId" is set to a random UUID
    When the request "readNetworkProfile" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "IDENTIFIER_NOT_FOUND"
    And the response property "$.message" contains a user friendly text
