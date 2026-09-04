Feature: CAMARA Dedicated Network API, vwip - Areas API Operations
  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  #
  # Testing assets:
  # * At least one existing area
  # * Valid area name (for byName filter testing)
  # * Valid network profile ID (for byNetworkProfileId filter testing)
  # * Valid QoS profile name (for byQosProfileName filter testing)
  # * Valid coordinates (latitude, longitude for atLocation filter testing)
  # * A non-existent UUID (for 404 error testing)
  # * A malformed UUID (for 400 error testing)
  #
  # References to OAS spec schemas refer to schemas specified in dedicated-network-areas.yaml

  Background: Common areas setup
    Given an environment at "apiRoot"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  # Success scenarios for POST /retrieve-service-areas

  @dedicated_network_areas_retrieveNetworkServiceAreas_01_success_all_first_page
  Scenario: Retrieve first page of all service areas (basic success)
    Given the resource "/dedicated-network-areas/vwip/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveServiceAreasRequest"
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/ServiceAreasPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/ServiceArea"

  @dedicated_network_areas_retrieveNetworkServiceAreas_02_success_filtered_by_atLocation_first_page
  Scenario: List first page of areas filtered by atLocation
    Given the resource "/dedicated-network-areas/vwip/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveServiceAreasRequest"
    And the request body property "$.atLocation" is set to valid coordinates
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/ServiceAreasPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/ServiceArea"
    And each item in the response array has property "$.area" whose geometry contains the coordinates specified in "$.atLocation"

  @dedicated_network_areas_retrieveNetworkServiceAreas_03_success_filtered_by_overlappingArea_first_page
  Scenario: List first page of areas filtered by overlappingArea
    Given the resource "/dedicated-network-areas/vwip/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveServiceAreasRequest"
    And the request body property "$.overlappingArea" is set to a valid area
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/ServiceAreasPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/ServiceArea"
    And each item in the response array has property "$.area" whose geometry overlaps the area specified in "$.overlappingArea"

  @dedicated_network_areas_retrieveNetworkServiceAreas_04_success_filtered_by_coveringArea_first_page
  Scenario: List first page of areas filtered by coveringArea
    Given the resource "/dedicated-network-areas/vwip/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveServiceAreasRequest"
    And the request body property "$.coveringArea" is set to a valid area
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/ServiceAreasPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/ServiceArea"
    And each item in the response array has property "$.area" whose geometry fully covers the area specified in "$.coveringArea"

  @dedicated_network_areas_retrieveNetworkServiceAreas_05_success_filtered_by_byName_first_page
  Scenario: List first page of areas filtered by byName
    Given the resource "/dedicated-network-areas/vwip/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveServiceAreasRequest"
    And the request body property "$.byName" is set to a valid area name
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/ServiceAreasPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/ServiceArea"
    And each item in the response array has property "$.name" equal to the value specified in "$.byName"

  @dedicated_network_areas_retrieveNetworkServiceAreas_06_success_filtered_by_byNetworkProfileId_first_page
  Scenario: List first page of areas filtered by byNetworkProfileId
    Given the resource "/dedicated-network-areas/vwip/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveServiceAreasRequest"
    And the request body property "$.byNetworkProfileId" is set to a valid network profile ID
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/ServiceAreasPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/ServiceArea"
    And each item in the response array has property "$.networkProfiles" containing the value specified in "$.byNetworkProfileId"

  @dedicated_network_areas_retrieveNetworkServiceAreas_07_success_filtered_by_byQosProfileName_first_page
  Scenario: List first page of areas filtered by byQosProfileName
    Given the resource "/dedicated-network-areas/vwip/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveServiceAreasRequest"
    And the request body property "$.byQosProfileName" is set to a valid QoS profile name
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/ServiceAreasPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/ServiceArea"
    And each item in the response array has property "$.qosProfiles" containing the value specified in "$.byQosProfileName"

  # Success scenarios for GET /areas/{areaId}

  @dedicated_network_areas_readNetworkServiceArea_01_success
  Scenario: Get details of a specific service area
    Given the resource "/dedicated-network-areas/vwip/areas/{areaId}"
    And the path parameter "areaId" is set to a valid service area ID
    When the request "readNetworkServiceArea" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/ServiceArea"
    And the response property "$.id" is equal to the path parameter "areaId"


############################ Error Scenarios - retrieveNetworkServiceAreas #############################################




  # Syntax Error scenarios

  @dedicated_network_areas_retrieveNetworkServiceAreas_400.01_schema_not_compliant
  Scenario: Invalid Argument. Generic Syntax Exception
    Given the request body is included but is not compliant with the schema at "#/components/schemas/RetrieveServiceAreasRequest"
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_areas_retrieveNetworkServiceAreas_400.02_no_request_body
  Scenario: Missing request body
    Given the request body is not included
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_areas_retrieveNetworkServiceAreas_400.06_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_areas_retrieveNetworkServiceAreas_400.07_invalid_coordinates
  Scenario: Retrieve service areas with invalid coordinates
    Given the resource "/dedicated-network-areas/vwip/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "#/components/schemas/RetrieveServiceAreasRequest"
    And the request body property "$.atLocation.latitude" is set to "999"
    And the request body property "$.atLocation.longitude" is set to "7.10066"
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.code" is "OUT_OF_RANGE"

  @dedicated_network_areas_retrieveNetworkServiceAreas_400.09_out_of_range_pagination
  Scenario Outline: Error response for out of range pagination parameters
    Given the resource "/dedicated-network-areas/vwip/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "#/components/schemas/RetrieveServiceAreasRequest"
    And the query parameter "<query_parameter>" is set to "<invalid_value>"
    When the request "retrieveNetworkServiceAreas" is sent
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

  @dedicated_network_areas_retrieveNetworkServiceAreas_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_areas_retrieveNetworkServiceAreas_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_areas_retrieveNetworkServiceAreas_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  # Generic 403 errors

  @dedicated_network_areas_retrieveNetworkServiceAreas_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "dedicated-network-areas:areas:read"
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

############################ Error Scenarios - readNetworkServiceArea #############################################


  # Syntax Error scenarios

  @dedicated_network_areas_readNetworkServiceArea_400.06_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "readNetworkServiceArea" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_areas_readNetworkServiceArea_400.08_invalid_uuid
  Scenario: Read service area with invalid UUID
    Given the resource "/dedicated-network-areas/vwip/areas/{areaId}"
    And the path parameter "areaId" is set to an invalid UUID
    When the request "readNetworkServiceArea" is sent
    Then the response status code is 400
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.code" is "INVALID_ARGUMENT"

  # Service Error scenarios

  ## Authentication/Authorization errors

    # Generic 401 errors

  @dedicated_network_areas_readNetworkServiceArea_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "readNetworkServiceArea" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_areas_readNetworkServiceArea_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "readNetworkServiceArea" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_areas_readNetworkServiceArea_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "readNetworkServiceArea" is sent
    Then the response status code is 401
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  # Generic 403 errors

  @dedicated_network_areas_readNetworkServiceArea_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "dedicated-network-areas:areas:read"
    When the request "readNetworkServiceArea" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @dedicated_network_areas_readNetworkServiceArea_403.02_api_client_token_mismatch
  Scenario: "areaId" not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    # here: eligibility
    Given the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access/manage the "areaId"
    When the request "readNetworkServiceArea" is sent
    Then the response status code is 403
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Generic 404 Errors

  @dedicated_network_areas_readNetworkServiceArea_404.01_not_found
  Scenario: non-existing "{areaId}"
    Given the resource "/dedicated-network-areas/vwip/areas/{areaId}"
    And the path parameter "areaId" is set to a random UUID
    When the request "readNetworkServiceArea" is sent
    Then the response status code is 404
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text

