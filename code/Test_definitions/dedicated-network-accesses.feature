Feature: CAMARA Dedicated Network API, vwip - Network Accesses API Operations
  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  #
  # Testing assets:
  # * At least one existing dedicated network
  # * Valid device identifier (phoneNumber)
  # * At least one existing access group
  # * At least one existing network access
  # * At least one existing network access with status GRANTED
  # * Two existing network accesses (for a batch delete where every access is deleted)
  # * A well-formed UUID that is not an existing access id, for exercising a per-access NOT_FOUND
  #   outcome inside a 207 batch
  # * A valid device identifier with an existing access
  # * A valid device identifier with no existing accesses associated
  # * A device already admitted to an access group, for exercising a per-device ALREADY_EXISTS
  #   outcome inside a 207 batch
  #
  # References to OAS spec schemas refer to schemas specified in dedicated-network-accesses.yaml

  Background: Common accesses setup
    Given an environment at "apiRoot"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  # Success scenarios for GET /access-groups

  @dedicated_network_accesses_listAccessGroups_01_success_all_first_page
  Scenario: List first page of all access groups
    Given the resource "/dedicated-network-accesses/vwip/access-groups"
    When the request "listAccessGroups" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "X-Total-Count" exists
    And the response header "X-Total-Pages" exists
    And the response header "Link" exists
    And the response body complies with the OAS schema at "/components/schemas/AccessGroupInfosPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessGroupInfo"

  @dedicated_network_accesses_listAccessGroups_02_success_filtered_by_network_first_page
  Scenario: List first page of access groups filtered by network ID
    Given an existing access group
    And the resource "/dedicated-network-accesses/vwip/access-groups"
    And the query parameter "networkId" is set to the network ID of the existing access group
    When the request "listAccessGroups" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "X-Total-Count" exists
    And the response header "X-Total-Pages" exists
    And the response header "Link" exists
    And the response body complies with the OAS schema at "/components/schemas/AccessGroupInfosPage"
    And the response property "$.items" is a non-empty array
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessGroupInfo"
    And each item in the response array has property "networkId" equal to the query parameter "networkId"

  # Success scenarios for POST /access-groups

  @dedicated_network_accesses_createAccessGroup_01_success_no_devices
  Scenario: Create an access group with no devices
    Given an existing dedicated network
    And the resource "/dedicated-network-accesses/vwip/access-groups"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessGroupRequest"
    And the request body property "$.networkId" is set to the ID of the existing network
    When the request "createAccessGroup" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Location" exists and contains a URL with the created access group ID
    And the response body complies with the OAS schema at "/components/schemas/AccessGroupInfo"
    And the response property "$.networkId" has the same value as in the request body
    And the response property "$.id" exists and is a valid UUID

  @dedicated_network_accesses_createAccessGroup_02_success_with_devices_all_admitted
  Scenario: Create an access group with devices, all admitted
    Given an existing dedicated network
    And the resource "/dedicated-network-accesses/vwip/access-groups"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessGroupRequest"
    And the request body property "$.networkId" is set to the ID of the existing network
    And the request body property "$.devices" array contains one or more (up to 100) valid device objects
    When the request "createAccessGroup" is sent
    Then the response status code is 207
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Location" exists and contains a URL with the created access group ID
    And the response body complies with the OAS schema at "/components/schemas/CreateAccessGroupPartialSuccess"
    And the response property "$.networkId" has the same value as in the request body
    And the response property "$.id" exists and is a valid UUID
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/CreateAccessesResult"
    And the response property "$.summary.requested" is equal to the number of devices in the request body
    And the response property "$.summary.succeeded" is equal to the response property "$.summary.requested"
    And the response property "$.summary.failed" is equal to 0

  @dedicated_network_accesses_createAccessGroup_03_success_with_devices_partially_admitted
  Scenario: Create an access group with devices, one admitted and one rejected
    Given an existing dedicated network
    And a valid device identifier
    And the resource "/dedicated-network-accesses/vwip/access-groups"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessGroupRequest"
    And the request body property "$.networkId" is set to the ID of the existing network
    And the request body property "$.devices" array contains the valid device identifier twice
    When the request "createAccessGroup" is sent
    Then the response status code is 207
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Location" exists and contains a URL with the created access group ID
    And the response body complies with the OAS schema at "/components/schemas/CreateAccessGroupPartialSuccess"
    And the response property "$.id" exists and is a valid UUID
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/CreateAccessesResult"
    And the response property "$.summary.requested" is equal to 2
    And the response property "$.summary.succeeded" is equal to 1
    And the response property "$.summary.failed" is equal to 1

  # Success scenarios for GET /access-groups/{accessGroupId}

  @dedicated_network_accesses_getAccessGroup_01_success
  Scenario: Get details of a specific access group
    Given an existing access group
    And the resource "/dedicated-network-accesses/vwip/access-groups/{accessGroupId}"
    And the path parameter "accessGroupId" is set to the ID of the existing access group
    When the request "getAccessGroup" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessGroupInfo"
    And the response property "$.id" is equal to the path parameter "accessGroupId"

  # Success scenarios for DELETE /access-groups/{accessGroupId}

  @dedicated_network_accesses_deleteAccessGroup_01_success
  Scenario: Delete an access group
    Given an existing access group
    And the resource "/dedicated-network-accesses/vwip/access-groups/{accessGroupId}"
    And the path parameter "accessGroupId" is set to the ID of the existing access group
    When the request "deleteAccessGroup" is sent
    Then the response status code is 204
    And the response header "x-correlator" has the same value as the request header "x-correlator"

  # Success scenarios for GET /accesses

  @dedicated_network_accesses_listAccesses_01_success_all_first_page
  Scenario: List first page of all network accesses
    Given the resource "/dedicated-network-accesses/vwip/accesses"
    When the request "listAccesses" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "X-Total-Count" exists
    And the response header "X-Total-Pages" exists
    And the response header "Link" exists
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
    And the response header "X-Total-Count" exists
    And the response header "X-Total-Pages" exists
    And the response header "Link" exists
    And the response body complies with the OAS schema at "/components/schemas/AccessInfosPage"
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessInfo"
    And each item in the response array has property "networkId" equal to the query parameter "networkId"

  @dedicated_network_accesses_listAccesses_03_success_filtered_by_access_group_first_page
  Scenario: List first page of network accesses filtered by access group ID
    Given an existing access group
    And an existing network access
    And the resource "/dedicated-network-accesses/vwip/accesses"
    And the query parameter "accessGroupId" is set to the ID of the existing access group
    When the request "listAccesses" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "X-Total-Count" exists
    And the response header "X-Total-Pages" exists
    And the response header "Link" exists
    And the response body complies with the OAS schema at "/components/schemas/AccessInfosPage"
    And the response property "$.items" is a non-empty array
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessInfo"
    And each item in the response array has property "accessGroupId" equal to the query parameter "accessGroupId"

  @dedicated_network_accesses_listAccesses_04_success_filtered_by_status_first_page
  Scenario: List first page of network accesses filtered by status
    Given an existing network access with status GRANTED
    And the resource "/dedicated-network-accesses/vwip/accesses"
    And the query parameter "status" is set to "GRANTED"
    When the request "listAccesses" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "X-Total-Count" exists
    And the response header "X-Total-Pages" exists
    And the response header "Link" exists
    And the response body complies with the OAS schema at "/components/schemas/AccessInfosPage"
    And the response property "$.items" is a non-empty array
    And the response property "$.items" is an array where each item complies with the OAS schema at "/components/schemas/AccessInfo"
    And each item in the response array has property "status" equal to the query parameter "status"

  # Success scenarios for POST /accesses

  @dedicated_network_accesses_createAccess_01_success
  Scenario: Create an access for a device
    Given an existing access group
    And a valid device identifier
    And the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the request body property "$.accessGroupId" is set to the ID of the existing access group
    And the request body property "$.device" is set to the valid device identifier
    When the request "createAccess" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Location" exists and contains a URL with the created access ID
    And the response body complies with the OAS schema at "/components/schemas/AccessInfo"
    And the response property "$.accessGroupId" has the same value as in the request body
    And the response property "$.id" exists and is a valid UUID
    And the response property "$.device" exists and complies with the OAS schema at "/components/schemas/DeviceResponse"

  @dedicated_network_accesses_createAccess_02_success_three_legged
  Scenario: Create an access for the device identified by a three-legged access token
    Given an existing access group
    And the header "Authorization" is set to a valid 3-legged access token for a specific device
    And the resource "/dedicated-network-accesses/vwip/accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessRequest"
    And the request body property "$.accessGroupId" is set to the ID of the existing access group
    When the request "createAccess" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response header "Location" exists and contains a URL with the created access ID
    And the response body complies with the OAS schema at "/components/schemas/AccessInfo"
    And the response property "$.accessGroupId" has the same value as in the request body
    And the response property "$.id" exists and is a valid UUID
    And the response property "$.device" exists and complies with the OAS schema at "/components/schemas/DeviceResponse"

  # Success scenarios for GET /accesses/{accessId}

  @dedicated_network_accesses_getAccess_01_success
  Scenario: Get details of a specific network access
    Given an existing access group
    And an existing network access
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of the existing access
    When the request "getAccess" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/AccessInfo"
    And the response property "$.id" is equal to the path parameter "accessId"

  # Success scenarios for DELETE /accesses/{accessId}

  @dedicated_network_accesses_deleteAccess_01_success
  Scenario: Delete a network access
    Given an existing access group
    And an existing network access
    And the resource "/dedicated-network-accesses/vwip/accesses/{accessId}"
    And the path parameter "accessId" is set to the ID of the existing access
    When the request "deleteAccess" is sent
    Then the response status code is 204
    And the response header "x-correlator" has the same value as the request header "x-correlator"

  # Success scenarios for POST /batch-create-accesses

  @dedicated_network_accesses_createAccesses_01_success_all_admitted
  Scenario: Create accesses for multiple devices, all admitted
    Given an existing access group
    And the resource "/dedicated-network-accesses/vwip/batch-create-accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessesRequest"
    And the request body property "$.accessGroupId" is set to the ID of the existing access group
    And the request body property "$.devices" array contains one or more (up to 100) valid device objects
    When the request "createAccesses" is sent
    Then the response status code is 207
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/CreateAccessesResults"
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/CreateAccessesResult"
    And the response property "$.summary.requested" is equal to the number of devices in the request body
    And the response property "$.summary.succeeded" is equal to the response property "$.summary.requested"
    And the response property "$.summary.failed" is equal to 0

  @dedicated_network_accesses_createAccesses_02_success_partially_admitted
  Scenario: Create accesses for multiple devices, one admitted and one rejected
    Given an existing access group
    And a device already admitted to the access group
    And a valid device identifier
    And the resource "/dedicated-network-accesses/vwip/batch-create-accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/CreateAccessesRequest"
    And the request body property "$.accessGroupId" is set to the ID of the existing access group
    And the request body property "$.devices" array contains the device already admitted to the access group and the valid device identifier
    When the request "createAccesses" is sent
    Then the response status code is 207
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/CreateAccessesResults"
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/CreateAccessesResult"
    And the response property "$.summary.requested" is equal to 2
    And the response property "$.summary.succeeded" is equal to 1
    And the response property "$.summary.failed" is equal to 1

  # Success scenarios for POST /batch-delete-accesses

  @dedicated_network_accesses_deleteAccesses_01_success_all_deleted
  Scenario: Delete multiple accesses, all deleted
    Given two existing network accesses
    And the resource "/dedicated-network-accesses/vwip/batch-delete-accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/DeleteAccessesRequest"
    And the request body property "$.accessIds" is set to the IDs of the two existing accesses
    When the request "deleteAccesses" is sent
    Then the response status code is 207
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/DeleteAccessesResults"
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/BatchDeleteAccessResult"
    And the response property "$.summary.requested" is equal to 2
    And the response property "$.summary.succeeded" is equal to the response property "$.summary.requested"
    And the response property "$.summary.failed" is equal to 0

  @dedicated_network_accesses_deleteAccesses_02_success_partially_deleted
  Scenario: Delete multiple accesses, one deleted and one not found
    Given an existing network access
    And a well-formed UUID that is not an existing access id
    And the resource "/dedicated-network-accesses/vwip/batch-delete-accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/DeleteAccessesRequest"
    And the request body property "$.accessIds" array contains the ID of the existing access and the well-formed UUID that is not an existing access id
    When the request "deleteAccesses" is sent
    Then the response status code is 207
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/DeleteAccessesResults"
    And the response property "$.results" is an array where each item complies with the OAS schema at "/components/schemas/BatchDeleteAccessResult"
    And the response property "$.summary.requested" is equal to 2
    And the response property "$.summary.succeeded" is equal to 1
    And the response property "$.summary.failed" is equal to 1

  # Success scenarios for POST /retrieve-accesses

  @dedicated_network_accesses_retrieveAccessesByDevice_01_success_two_legged
  Scenario: Retrieve accesses for a device using a two-legged token and a device object
    Given a valid device identifier with an existing access
    And the resource "/dedicated-network-accesses/vwip/retrieve-accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveAccessesRequest"
    And the request body property "$.device" is set to the valid device identifier
    When the request "retrieveAccessesByDevice" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body is a non-empty array of items compliant with the OAS schema at "/components/schemas/AccessInfo"

  @dedicated_network_accesses_retrieveAccessesByDevice_02_success_three_legged
  Scenario: Retrieve accesses for the device identified by a three-legged access token
    Given a valid device identifier with an existing access
    And the header "Authorization" is set to a valid 3-legged access token for a specific device
    And the resource "/dedicated-network-accesses/vwip/retrieve-accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveAccessesRequest"
    When the request "retrieveAccessesByDevice" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body is a non-empty array of items compliant with the OAS schema at "/components/schemas/AccessInfo"

  @dedicated_network_accesses_retrieveAccessesByDevice_03_success_no_match
  Scenario: Retrieve accesses for a device with no existing accesses
    Given a valid device identifier with no existing accesses associated
    And the resource "/dedicated-network-accesses/vwip/retrieve-accesses"
    And the header "Content-Type" is set to "application/json"
    And the request body is set to a request body compliant with the schema at "/components/schemas/RetrieveAccessesRequest"
    And the request body property "$.device" is set to the valid device identifier
    When the request "retrieveAccessesByDevice" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has the same value as the request header "x-correlator"
    And the response body is []
