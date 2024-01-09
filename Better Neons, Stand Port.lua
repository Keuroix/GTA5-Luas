--huge credits to sk1d for the lua originally and letting me move it to stand.
--huge thanks to kreeako for neatening the code too.



util.require_natives("3095a")

local labels = {
    welcome_mesage = "Welcome to better neons... the Stand port.",
    divider_name =   "Vehicle Options",

    neon_delay_slider =                   { feature = "Neon Delay",                      command = { "neonspeed" },                                      helptext = "For setting the delay of your neons changing."                             },
    brake_neon_toggle =                   { feature = "Brake Neons",                     command = { "neonbrake" },                                      helptext = "Makes the brake lights neon."                                              },
    police_neon_toggle =                  { feature = "Police Neons",                    command = { "policeneons" },                                    helptext = "Will make vehicles neon lights flashing in police colors."                 },
    reactive_neon_toggle =                { feature = "Reactive Neons",                  command = { "reactiveneons" },                                  helptext = "Will make vehicles neon lights react to your driving."                     },
    chasing_neon_toggle =                 { feature = "Chasing Neons",                   command = { "chasingneons" },                                   helptext = "Will make vehicles neon lights chase your car."                            },
    circle_neon_counterclockwise_toggle = { feature = "Circle Neons Counterclockwise",   command = { "circleneonsleft", "circleneonscounterclockwise" }, helptext = "Will make vehicles neon lights go left around the car (counterclockwise)." },
    circle_neon_clockwise_toggle =        { feature = "Circle Neons Clockwise",          command = { "circleneonsright", "circleneonsclockwise" },       helptext = "Will make vehicles neon lights go right around the car (clockwise)."       },
    following_neon_toggle =               { feature = "Following Neons",                 command = { "followingneons" },                                 helptext = "Will make vehicles neon lights follow your car."                           },
    random_neon_toggle =                  { feature = "Random Neons",                    command = { "randomneons" },                                    helptext = "Will make one vehicle neon light flash in random order and color."         },
    random_neon_v2_toggle =               { feature = "Random Neons V2",                 command = { "randomneons2" },                                   helptext = "Will make vehicles neon lights flash in random order and color."           },
}

util.toast(labels.welcome_mesage)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility Functions & Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Utility Functions & Variables
local neon = {
    left = 0,
    right = 1,
    front = 2,
    back = 3
}

---For getting the vehicle a ped is in.
---@param ped integer --- Give a ped handle.
---@param include_last_vehicle boolean --- If you want to include the last vehicle the ped was in.
---@return integer | nil --- Returns a vehicle handle or nil if one could not be found.
local function get_vehicle_ped_is_in(ped, include_last_vehicle)
    if include_last_vehicle or PED.IS_PED_IN_ANY_VEHICLE(ped) then
        return PED.GET_VEHICLE_PED_IS_IN(ped, false)
    end
    return nil
end

util.create_tick_handler(function()
    local_player_ped = players.user_ped()
    local_player_vehicle = get_vehicle_ped_is_in(local_player_ped, false)
end)

---For enabling or disabling neons.
---@param status boolean -- True will enable, false will disable.
local function enable_all_neons(status)
    if local_player_vehicle then
        for i = 0, 3 do
            VEHICLE.SET_VEHICLE_NEON_ENABLED(local_player_vehicle, i, status)
        end
    end
end

---For enabling or disabling specific neons.
---@param status boolean -- True will enable, false will disable.
---@param neon_int integer -- The light you want to change the status of.
local function enable_neons(status, neon_int)
    if local_player_vehicle then
        for i = 0, 3 do
            VEHICLE.SET_VEHICLE_NEON_ENABLED(local_player_vehicle, neon_int, status)
        end
    end
end

---For setting the neon light color on your vehicle.
---@param color table -- Can be table with just numbers, or specificly a color table. Examples: { 255, 0, 255 } | { r = 255, g = 0, b = 255 } | { red = 255, green = 0, blue = 255 }
local function set_neon_color(color)
    if local_player_vehicle then
        VEHICLE.SET_VEHICLE_NEON_COLOUR(local_player_vehicle, color[1] or color.r or color.red, color[2] or color.g or color.green, color[3] or color.b or color.blue)
    end
end

local colors = {
    red = { r = 255, g = 0, b = 0 },
    blue = { r = 0, g = 0, b = 255 },
    white = { r = 255, g = 255, b = 255 },
    amber = { r = 255, g = 126, b = 0 }
}

---For checking if a control is pressed.
---@param control integer -- The control value to check.
local function check_control_pressed(control)
    return PAD.IS_CONTROL_PRESSED(2, control)
end

local controls = {
    brake = 72,
    reverse = 72,
    forward = 71,
    left = 63,
    right = 64
}

---For coverting various things into a boolean.
---@param to_convert any -- The data you would like to convert to a boolean.
---@return boolean | nil -- Returns your data converted to a boolean, or nil if it could not be converted (i.e. if you gave it anything other than a boolean/number/string).
local function toboolean(to_convert)
    local data_type = type(to_convert)

    if data_type == "boolean" then
        return to_convert
    elseif data_type == "number" then
        if to_convert ~= 0 then
            return true
        end
    elseif data_type == "string" then
        if to_convert == "true" or to_convert == "True" or to_convert == "TRUE" or to_convert == "on" or to_convert == "ON" then
            return true
        end

        if to_convert == "false" or to_convert == "False" or  to_convert == "FALSE" or  to_convert == "off" or  to_convert == "OFF" then
            return false
        end
    elseif (data_type == "nil") or data_type == ("table" or data_type == "function") or (data_type == "thread") or (data_type == "userdata") then
        util.toast("toboolean could not convert " .. data_type .. " :?")
        return nil
    end
    return false
end

local random_booleans = {}
---For populating the table random_booleans with randome booleans, to reset table do this: random_booleans = {}
---@param number_of_bools any
local function get_random_booleans(number_of_bools)
    for i = 0, number_of_bools - 1 do
        local random = toboolean(math.random(0, 1))
        random_booleans[#random_booleans + 1] = random
    end
end

---When a feature is disabled, it disables all neons.
local function on_disable()
    util.yield(100)
    enable_all_neons(false)
end
--#endregion Utility Functions & Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility Functions & Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Feature Functions & Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Feature Functions & Variables
local neon_delay = 100

---The function for "Brake Neons" feature.
local function brake_neons_feature_function()
    enable_all_neons(false)

    if check_control_pressed(controls.brake) then
        set_neon_color(colors.red)
        enable_neons(true, neon.back)
    end
end

---The function for "Police Neons" feature.
local function police_neons_feature_function()
    enable_all_neons(false)

    set_neon_color(colors.red)
    enable_all_neons(true)
    util.yield(150)

    enable_all_neons(false)
    util.yield(50)

    set_neon_color(colors.blue)
    enable_all_neons(true)
    util.yield(125)

    enable_all_neons(false)
    util.yield(50)

    set_neon_color(colors.blue)
    enable_all_neons(true)
    util.yield(125)

    enable_all_neons(false)
    util.yield(50)
end

---The function for "Reactive Neons" feature.
local function reactive_neons_feature_function()
    enable_all_neons(false)

    if check_control_pressed(controls.brake) then
        set_neon_color(colors.red)
        enable_neons(true, neon.back)
    elseif check_control_pressed(controls.forward) then
        set_neon_color(colors.white)
        enable_neons(true, neon.front)
    elseif check_control_pressed(controls.left) then
        set_neon_color(colors.amber)
        enable_neons(true, neon.left)
    elseif check_control_pressed(controls.right) then
        set_neon_color(colors.amber)
        enable_neons(true, neon.right)
    end
end

---The function for "Chasing Neons" feature.
local function chasing_neons_feature_function()
    enable_all_neons(false)
    set_neon_color(colors.white)
    enable_neons(true, neon.back)
    util.yield(neon_delay)

    enable_all_neons(false)
    enable_neons(true, neon.left)
    enable_neons(true, neon.right)
    util.yield(neon_delay)

    enable_all_neons(false)
    enable_neons(true, neon.front)
    util.yield(neon_delay)
end

---The function for "Circle Neons Counterclockwise" feature.
local function circle_neons_counterclockwise_feature_function()
    enable_all_neons(false)
    set_neon_color(colors.white)
    enable_neons(true, neon.right)
    util.yield(neon_delay)

    enable_all_neons(false)
    enable_neons(true, neon.front)
    util.yield(neon_delay)

    enable_all_neons(false)
    enable_neons(true, neon.left)
    util.yield(neon_delay)

    enable_all_neons(false)
    enable_neons(true, neon.back)
    util.yield(neon_delay)
end

---The function for "Circle Neons Clockwise" feature.
local function circle_neons_clockwise_feature_function()
    enable_all_neons(false)
    set_neon_color(colors.white)
    enable_neons(true, neon.right)
    util.yield(neon_delay)

    enable_all_neons(false)
    enable_neons(true, neon.back)
    util.yield(neon_delay)

    enable_all_neons(false)
    enable_neons(true, neon.left)
    util.yield(neon_delay)

    enable_all_neons(false)
    enable_neons(true, neon.front)
    util.yield(neon_delay)
end

---The function for "Following Neons" feature.
local function following_neons_feature_function()
    enable_all_neons(false)
    set_neon_color(colors.white)
    enable_neons(true, neon.front)
    util.yield(neon_delay)

    enable_all_neons(false)
    enable_neons(true, neon.left)
    enable_neons(true, neon.right)
    util.yield(neon_delay)

    enable_all_neons(false)
    enable_neons(true, neon.back)
    util.yield(neon_delay)
end

---The function for "Random Neons" feature.
local function random_neons_feature_function()
    enable_all_neons(false)

    local random = math.random(0, 3)
    local color = { r = math.random(0, 255), g = math.random(0, 255), b = math.random(0, 255) }

    set_neon_color(color)
    enable_neons(true, random)
    util.yield(neon_delay)
end

---The function for "Random Neons V2" feature.
local function random_neons_v2_feature_function()
    enable_all_neons(false)

    get_random_booleans(4)
    local random_color = { r = math.random(0, 255), g = math.random(0, 255), b = math.random(0, 255) }

    set_neon_color(random_color)
    for index, bool in ipairs(random_booleans) do
        enable_neons(bool, index - 1)
    end

    random_booleans = {}

    util.yield(neon_delay)
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Root Setup
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Root Setup
local my_root = menu.my_root()
--#endregion Root Setup
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Root Setup
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Feature Setup
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Feature Setup

my_root:divider(labels.divider_name)

my_root:slider(labels.neon_delay_slider.feature, labels.neon_delay_slider.command, labels.neon_delay_slider.helptext, 1, 2147483647, neon_delay, 1, function(int) neon_delay = int end)

local toggle_feature_info = {
    { name = labels.brake_neon_toggle.feature,                   command = labels.brake_neon_toggle.command,                    helptext = labels.brake_neon_toggle.helptext,                   func = brake_neons_feature_function                   },
    { name = labels.police_neon_toggle.feature,                  command = labels.police_neon_toggle.command,                   helptext = labels.police_neon_toggle.helptext,                  func = police_neons_feature_function                  },
    { name = labels.reactive_neon_toggle.feature,                command = labels.reactive_neon_toggle.command,                 helptext = labels.reactive_neon_toggle.helptext,                func = reactive_neons_feature_function                },
    { name = labels.chasing_neon_toggle.feature,                 command = labels.chasing_neon_toggle.command,                  helptext = labels.chasing_neon_toggle.helptext,                 func = chasing_neons_feature_function                 },
    { name = labels.circle_neon_counterclockwise_toggle.feature, command = labels.circle_neon_counterclockwise_toggle.command,  helptext = labels.circle_neon_counterclockwise_toggle.helptext, func = circle_neons_counterclockwise_feature_function },
    { name = labels.circle_neon_clockwise_toggle.feature,        command = labels.circle_neon_clockwise_toggle.command,         helptext = labels.circle_neon_clockwise_toggle.helptext,        func = circle_neons_clockwise_feature_function        },
    { name = labels.following_neon_toggle.feature,               command = labels.following_neon_toggle.command,                helptext = labels.following_neon_toggle.helptext,               func = following_neons_feature_function               },
    { name = labels.random_neon_toggle.feature,                  command = labels.random_neon_toggle.command,                   helptext = labels.random_neon_toggle.helptext,                  func = random_neons_feature_function                  },
    { name = labels.random_neon_v2_toggle.feature,               command = labels.random_neon_v2_toggle.command,                helptext = labels.random_neon_v2_toggle.helptext,               func = random_neons_v2_feature_function               },
}

for _, feature in ipairs(toggle_feature_info) do
    my_root:toggle_loop(feature.name, feature.command, feature.helptext, function()
        feature.func()
    end, function()
        on_disable()
    end)
end
--#endregion Feature Setup
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Feature Setup
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
