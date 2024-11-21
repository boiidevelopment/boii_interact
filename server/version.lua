-- Import utility library
utils = exports.boii_utils:get_utils()

--- Version check options
--- @field resource_name: The name of the resource to check, you can set a value here or use the current resource.
--- @field url_path: The path to your json file.
--- @field callback: Callback to invoking resource version check details *optional*
local opts = {
    resource_name = 'boii_interact',
    url_path = 'boiidevelopment/fivem_resource_versions/main/versions.json',
}
utils.version.check(opts)