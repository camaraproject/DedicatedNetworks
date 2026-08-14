Feature: CAMARA Dedicated Network API, v0.1.0-rc.1 - Areas API Operations
  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  #
  # Testing assets:
  # * At least one existing area
  #
  # References to OAS spec schemas refer to schemas specified in dedicated-network-areas.yaml

  Background: Common areas setup
    Given an environment at "apiRoot"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  # Success scenarios for POST /retrieve-service-areas

  @dedicated_network_areas_retrieveNetworkServiceAreas_01_success_all_first_page
  Scenario: Retrieve first page of all service areas (basic success)
    Given the resource "/dedicated-network-areas/v0.1rc1/retrieve-service-areas"
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
    Given the resource "/dedicated-network-areas/v0.1rc1/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveServiceAreasRequest"
    And the request body property "$.atLocation" is set to valid coordinates
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/ServiceAreasPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/ServiceArea"

  @dedicated_network_areas_retrieveNetworkServiceAreas_03_success_filtered_by_overlappingArea_first_page
  Scenario: List first page of areas filtered by overlappingArea
    Given the resource "/dedicated-network-areas/v0.1rc1/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveServiceAreasRequest"
    And the request body property "$.overlappingArea" is set to a valid area
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/ServiceAreasPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/ServiceArea"

  @dedicated_network_areas_retrieveNetworkServiceAreas_04_success_filtered_by_coveringArea_first_page
  Scenario: List first page of areas filtered by coveringArea
    Given the resource "/dedicated-network-areas/v0.1rc1/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveServiceAreasRequest"
    And the request body property "$.coveringArea" is set to a valid area
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/ServiceAreasPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/ServiceArea"

  @dedicated_network_areas_retrieveNetworkServiceAreas_05_success_filtered_by_byName_first_page
  Scenario: List first page of areas filtered by byName
    Given the resource "/dedicated-network-areas/v0.1rc1/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveServiceAreasRequest"
    And the request body property "$.byName" is set to a valid area name
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/ServiceAreasPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/ServiceArea"

  @dedicated_network_areas_retrieveNetworkServiceAreas_06_success_filtered_by_byNetworkProfileId_first_page
  Scenario: List first page of areas filtered by byNetworkProfileId
    Given the resource "/dedicated-network-areas/v0.1rc1/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveServiceAreasRequest"
    And the request body property "$.byNetworkProfileId" is set to a valid network profile
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/ServiceAreasPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/ServiceArea"

  @dedicated_network_areas_retrieveNetworkServiceAreas_07_success_filtered_by_byQosProfileName_first_page
  Scenario: List first page of areas filtered by byQosProfileName
    Given the resource "/dedicated-network-areas/v0.1rc1/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveServiceAreasRequest"
    And the request body property "$.byQosProfileName" is set to a valid qos profile
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/ServiceAreasPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/ServiceArea"

  # Success scenarios for GET /areas/{areaId}

  @dedicated_network_areas_readNetworkServiceArea_01_success
  Scenario: Get details of a specific service area
    Given the resource "/dedicated-network-areas/v0.1rc1/areas/{areaId}"
    And the path parameter "areaId" is set to a valid service area ID
    When the request "readNetworkServiceArea" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/ServiceArea"
    And the response property "$.id" exists and is a valid UUID

  # Error scenarios

  @dedicated_network_areas_retrieveNetworkServiceAreas_08_error_invalid_coordinates
  Scenario: Retrieve service areas with invalid coordinates
    Given the resource "/dedicated-network-areas/v0.1rc1/retrieve-service-areas"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveServiceAreasRequest"
    And the request body property "$.atLocation.latitude" is set to "999"
    And the request body property "$.atLocation.longitude" is set to "7.10066"
    When the request "retrieveNetworkServiceAreas" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.code" is "OUT_OF_RANGE"

  @dedicated_network_areas_readNetworkServiceArea_02_error_invalid_uuid
  Scenario: Read service area with invalid UUID
    Given the resource "/dedicated-network-areas/v0.1rc1/areas/{areaId}"
    And the path parameter "areaId" is set to an invalid UUID
    When the request "readNetworkServiceArea" is sent
    Then the response status code is 400
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.code" is "INVALID_ARGUMENT"

  @dedicated_network_areas_readNetworkServiceArea_03_error_not_found
  Scenario: Read non-existent service area
    Given the resource "/dedicated-network-areas/v0.1rc1/areas/{areaId}"
    And the path parameter "areaId" is set to a non-existent UUID
    When the request "readNetworkServiceArea" is sent
    Then the response status code is 404
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response property "$.code" is "NOT_FOUND"