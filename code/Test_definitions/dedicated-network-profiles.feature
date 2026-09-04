Feature: CAMARA Dedicated Network API, vwip - Network Profiles API Operations
  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  #
  # Testing assets:
  # * At least one existing network profile
  # * Valid network profile name (for name filter testing)
  # * At least two existing network profiles (for pagination testing)
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

  @dedicated_network_profiles_readNetworkProfiles_02_success_filtered_by_name
  Scenario: List first page of network profiles filtered by name
    Given the resource "/dedicated-network-profiles/vwip/profiles"
    And the query parameter "name" is set to a valid network profile name
    When the request "readNetworkProfiles" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/NetworkProfilesPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/NetworkProfile"
    And each item in the response array has property "$.name" equal to the query parameter "name"

  @dedicated_network_profiles_readNetworkProfiles_03_success_pagination
  Scenario: List a specific page of network profiles with an explicit page size
    Given there are at least 2 network profiles
    And the resource "/dedicated-network-profiles/vwip/profiles"
    And the query parameter "perPage" is set to 1
    And the query parameter "page" is set to 2
    When the request "readNetworkProfiles" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "X-Total-Count" exists and is the total number of network profiles
    And the response header "X-Total-Pages" exists and is the total number of pages
    And the response header "Link" exists
    And the response body complies with the OAS schema at "/components/schemas/NetworkProfilesPage"
    And the response property "$.items" is an array with exactly 1 item
    And the response property "$.pagination.page" is equal to the query parameter "page"
    And the response property "$.pagination.perPage" is equal to the query parameter "perPage"
    And the response property "$.pagination.totalCount" has the same value as the response header "X-Total-Count"
    And the response property "$.pagination.totalPages" has the same value as the response header "X-Total-Pages"

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
