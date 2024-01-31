// The operation_Id value in the dependencies table was not unique and was returning multiple records from the dependencies table.
requests 
| join kind=leftouter dependencies on operation_Id
| where timestamp > ago(1d)
| project-rename ClientId = customDimensions1 
| summarize Count=sum(itemCount) by ClientId = iif(string_size(tostring(customDimensions1["Request-x-deere-monitoring-cid"])) == 0, strcat("Unknown with Status Code ", resultCode), tostring(customDimensions1["Request-x-deere-monitoring-cid"]))
 
// Joining on id from the requests table to the operation_ParentId in the dependencies table seems to be returning a single record (or 0 if a match doesn't exist)
requests
| join kind=leftouter dependencies on $left.id == $right.operation_ParentId
| where timestamp > ago(1d)
| summarize Count=sum(itemCount) by ClientId = iif(string_size(tostring(customDimensions1["Request-x-deere-monitoring-cid"])) == 0, strcat("Unknown with Status Code ", resultCode), tostring(customDimensions1["Request-x-deere-monitoring-cid"]))