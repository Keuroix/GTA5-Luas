--Huge thanks to these people;
--Chris Lad <~~~ Especially Chris Lad for posting the basic "crate loop" back on, 15/08/2022 (https://cdn.discordapp.com/attachments/988008200257286154/1008603965874786394/MBMoneyFarm.lua)
--Andy
--Jesus_Is_Cap
--IcyPhoenix 
--Vsussy/Vsus/Ren.
--None of this lua would of been possible to do without ANY of these people. I personally thank them all.

util.keep_running()
util.require_natives(1663599433)

local startup_message = "Welcome to ilana-lua <3"
local shutdown_message = "Thank you for using ilana-lua <3"

local rp_mulitplier_global = memory.script_global(262145 + 1)
local player_property_offset_global = memory.script_global(2657921 + 1 + (players.user() * 463) + 321 + 7)

local script_version = "Release v3.1"
local changlog = "- Added utility functions\n- Cleaned up code\n- Updated for 1.68-3095"

local function check_web_access()
    if not async_http.have_access() then
        util.toast("This script needs access to the internet to get a needed library, please disable 'Disable Internet Access'")
        util.stop_script()
    end
end

local function check_version()
    local game_version_intended = "1.68-3095"
    local actual_game_version = menu.get_version().game

    if game_version_intended ~= actual_game_version then
        util.toast("Script outdated! Wait for an update.")
        util.stop_script()
    end
end

local function checks()
    check_version()
    check_web_access()
end

checks()

local http_pending = false

local function fetch_lib_file(base_url, url_specification, directory, file_name)

    local absolute_directory = filesystem.scripts_dir() .. directory
    local absolute_file_path = absolute_directory .. "/" .. file_name
    local relative_file_path = directory .. "/" .. file_name

    if not filesystem.exists(absolute_directory) then
        filesystem.mkdirs(absolute_directory)
    end

    local function on_http_success(result)

        local lib_download_err = select(2, load(result))
        if lib_download_err then
            util.toast(lib_download_err, TOAST_LOGGER | TOAST_ABOVE_MAP)
        end

        if not filesystem.exists(absolute_file_path) then
            lib_file, lib_file_error = io.open(absolute_file_path, "w+")

            if lib_file then
                lib_file:write(result)
                lib_file:flush()
                lib_file:close()
            else
                util.log("Library file error: " .. lib_file_error)
            end
        end
        http_pending = false
    end

    local function on_http_fail(result)
        util.log("Failed to get library from url...")
        http_pending = false
    end

    async_http.init(tostring(base_url), tostring(url_specification), on_http_success, on_http_fail)
    async_http.dispatch()
    while http_pending do
        util.yield()
    end

    while not filesystem.exists(absolute_file_path) do
        util.yield()
    end

    util.log("absolute_directory: " .. absolute_directory)
    util.log("absolute_file_path: " .. absolute_file_path)
    util.log("relative_file_path: " .. relative_file_path)

    util.require_no_lag(relative_file_path:gsub(".lua", ""))
end

---For getting if a fed command is a string or a reference.
---@param cmd string | userdata -- Feed a path or reference.
---@return string -- Returns a string of the command type, "path", "ref", or "invalid" if it was fed neither.
local function get_command_type(cmd)
    if type(cmd) == "string" then
        return "path"
    elseif type(cmd) == "userdata" then
        return "ref"
    else
        return "invalid"
    end
end

---For checking if a command is valid.
---@param cmd string | userdata -- Feed a path or reference.
---@return boolean -- Returns a boolean indicating if the command is valid.
local function is_command_valid(cmd)
    local cmd_type = get_command_type(cmd)
    if cmd_type == "path" then
        if menu.is_ref_valid(menu.ref_by_path(cmd)) then
            return true
        end
    elseif cmd_type == "ref" then
        if menu.is_ref_valid(cmd) then
            return true
        end
    elseif cmd_type == "invalid" then
        util.log("Not a valid command path or ref!")
        return false
    end
    return false
end

---For getting a command ref from another reference or a path.
---@param cmd string | userdata -- Feed a path or reference.
---@return any -- Returns a command reference from a path or another reference.
local function get_command_ref(cmd)
    local cmd_type = get_command_type(cmd)
    if is_command_valid(cmd) then
        if cmd_type == "path" then
            return menu.ref_by_path(cmd)
        else
            return cmd
        end
    end
end

---Triggers a command from a reference or a path.
---@param cmd string | userdata -- Feed a path or reference.
---@param ... any -- Feed optional argument to meny.trigger_command.
local function trigger_cmd(cmd, ...)
    local command = get_command_ref(cmd)
    menu.trigger_command(command, ...)
end

---For converting a simple boolean to be used with command triggering.
---@param boolean boolean --- The boolean to convert.
---@return string --- Returns string "on" for if boolean == true, returns "off" for if boolean == false.
local function convert_boolean_to_on_or_off(boolean)
    if boolean then
        return "on"
    end
    return "off"
end

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
    local_player_position = ENTITY.GET_ENTITY_COORDS(local_player_ped, false)
    local_player_vehicle = get_vehicle_ped_is_in(local_player_ped, false)
end)

fetch_lib_file("raw.githubusercontent.com", "/Kreeako/key_press_lib/main/key_press_lib.lua", "lib", "key_press_lib.lua")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Root variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Root Variables
local my_root = menu.my_root()
my_root:divider("ilana lua")
local log_root = my_root:list("Changelog", { "" }, "Changelog + Version.")
local credit_root = my_root:list("Credits", { "" }, "People who helped/supported.")
local crate_root = my_root:list("Crate Loops")
--#endregion Root Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Root Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Load Text
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Load Text
util.toast(startup_message)
util.on_stop(function()
    util.toast(shutdown_message)
end)
--#endregion Load Text
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Load Text
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Changelog + Version
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Changelog + Version
log_root:action("Changlog", { "" }, changlog, function()
    util.toast(changlog)
end)

log_root:divider("Script Version")
log_root:readonly(script_version)
--#endregion Changelog + Version
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Changelog + Version
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Credits
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Credits
credit_root:hyperlink("ChrisLad | Original script.", "https://cdn.discordapp.com/attachments/988008200257286154/1008603965874786394/MBMoneyFarm.lua", "Thank you, ChrisLad for uploading the script originally!")

local credits_table = {
    { name = "You", message = "Thank you, yes you, for using my shitty skidded script." },
    { name = "Vsussy/Vsus/Ren", message = "Huge thanks to Ren for making MB to begin with." },
    { name = "IcyPhoenix", message = "Huge thanks to Icy for making MB to begin with." },
    { name = "Andy", message = "Big thanks to Anwy for the help aswell as teaching me certain things." },
    { name = "Jesus_Is_Cap aka In Stand We Trust", message = "Thank you Jesus_is_cap for helping with coding + debugging!" },
    { name = "Ren/Rensomnja", message = "Thank you Ren (Rensomnja) for the motivation to work on this. (femboy ren)" },
    { name = "someoneIdfk", message = "Thank you SomeoneIdfk for helping/tips overall." },
    { name = "Zero Tsu", message = "Thank you Zero Tsu for helping me keep 'sane' during the DM bombs of confusion." },
}

for _, credit in pairs(credits_table) do
    credit_root:action(credit.name, { "" }, credit.message, function()
        util.toast(credit.message)
    end)
end
--#endregion Credits
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Credits
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Jerryscript Skidded Code
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Jerryscript Skidded Code
local get_int_pointer = memory.alloc_int()

local function get_mp_slot()
    return 'MP'.. util.get_char_slot() ..'_'
end

local function read_stat_integer(stat)
    STATS.STAT_GET_INT(util.joaat(get_mp_slot() .. stat), get_int_pointer, -1)
    return memory.read_int(get_int_pointer)
end
--#endregion Jerryscript Skidded Code
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Jerryscript Skidded Code
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Musiness Banager Cargo Loop
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Musiness Banager Cargo Loop

local function resupply()
    if util.is_session_started() and not util.is_session_transition_active() then
        STATS.SET_PACKED_STAT_BOOL_CODE(32359 + 0, true, util.get_char_slot())
        memory.write_int(player_property_offset_global, -1)
    end
end

---Teleports given entity to given postion.
---@param entity integer --- Feed entity handle you wish to teleport.
---@param position table | userdata --- The coordinates, in table or vector3 format you wish to teleport entity to.
local function teleport_entity(entity, position)
    ENTITY.SET_ENTITY_COORDS(entity, position[1] or position.x, position[2] or position.y, position[3] or position.z, true, false, false, false)
end

---Teleports you, the local player or your vehicle to the given position.
---@param position any
local function teleport_me(position)
    local tp_entity = local_player_ped
    if local_player_vehicle ~= nil then
        tp_entity = local_player_vehicle
    end
    teleport_entity(tp_entity, position)
end

local function tpfps()
	teleport_me({ -3992.89, -4428.77, -1255.82 })
end

local function kill_appsecuroserv()
    util.spoof_script("appsecuroserv", SCRIPT.TERMINATE_THIS_THREAD)
    PLAYER.SET_PLAYER_CONTROL(players.user(), true, 0)
    PAD.ENABLE_ALL_CONTROL_ACTIONS(0)

    local enable_controls = { 1, 2, 187, 188, 189, 190, 199, 200 }

    for _, action in ipairs(enable_controls) do
        PAD.ENABLE_CONTROL_ACTION(2, action, true)
    end
end
--#endregion Musiness Banager Cargo Loop
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Musiness Banager Cargo Loop
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Classic Sell Loop
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Classic Sell Loop
local money_root_cls = crate_root:list("Classic delayed MB cargo Loop")

money_root_cls:toggle_loop("Remove Transaction Pending Alert", { "nopend", "notransactionpending" }, "This does nothing but remove the lil notif thing", function()
    trigger_cmd('Online>Enhancements>Remove "Transaction Pending"')
end)

money_root_cls:divider("Made by Jesus_Is_Cap")

local speed = 2000
money_root_cls:slider("Sell Speed", { "selspd", "sellspeed", "sellspd" }, "Modify Sell Speed (in miliseconds)", 900, 4650, 2000, 25, function(speed_value)
    speed = speed_value
end)

local function sell()
    if util.is_session_started() and not util.is_session_transition_active() then
    	tpfps()
        menu.trigger_commands("sellacrate")
        util.yield(800)
    	kill_appsecuroserv()
    	util.yield(speed - 800)
    end
end

local crate_sell_loop_feature = money_root_cls:toggle_loop("Crate Sell Loop", {"sellloop"}, "Make sure to set a loop speed before enabling this.", function()
	sell()
    if read_stat_integer("CONTOTALFORWHOUSE0") <= 5 then
        util.yield()
        resupply()
	end
end)

money_root_cls:action("No RP", {}, "Click to enable/disable RP gain", function()
	menu.trigger_commands("NoRP")
end)

money_root_cls:divider("Miscellaneous")

money_root_cls:action("Kill Script", {}, "Use this to end the script without having to go back 10,000 times.", function()
	util.stop_script()
end)
--#endregion Classic Sell Loop
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Classic Sell Loop
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Superiority Loop
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Superiority Loop

---To optimize settings.
---@param status boolean --- For enabling or disabling.
local function optimize_settings_function(status)
    local enable_optimize_settings_table = {
        { command = "potatomode", value = "on" },
        { command = "nosky", value = "on" },
        { command = "lodscale", value = "0" },
        { command = "fovfponfoot", value = "0" },
        { command = "fovtponfoot", value = "0" },
    }

    local disable_optimize_settings_table = {
        { command = "potatomode", value = "off" },
        { command = "nosky", value = "off" },
        { command = "lodscale", value = "1" },
        { command = "fovfponfoot", value = "-5" },
        { command = "fovtponfoot 0", value = "-5" },
    }

    if status then
        for _, setting in pairs(enable_optimize_settings_table) do
            trigger_cmd(setting.command, setting.value)
        end
    else
        for _, setting in pairs(disable_optimize_settings_table) do
            trigger_cmd(setting.command, setting.value)
        end
    end
end

local money_root_sup = crate_root:list("Superiority Loop Options")

money_root_sup:divider("Made by Jesus_Is_Cap")

local optimize_settings = false
money_root_sup:toggle("Optimised Settings", {""}, "Will hopefully Maximise your TPS and FPS", function(status)
    optimize_settings = status
	if optimize_settings then
        optimize_settings_function(optimize_settings)
        GRAPHICS.TOGGLE_PAUSED_RENDERPHASES(optimize_settings)
    else
        optimize_settings_function(optimize_settings)
        GRAPHICS.TOGGLE_PAUSED_RENDERPHASES(optimize_settings)
	end
end)

---To disabled the RP multiplier, to not gain RP.
---@param status boolean --- To enable or disable RP.
local function disable_rp_multiplier(status)
    local default = memory.read_float(rp_mulitplier_global)

    if util.is_session_started() and not util.is_session_transition_active() then
        if status then
            util.draw_debug_text("RP Disabled")
            memory.write_float(rp_mulitplier_global, 0)
        end
    end

    memory.write_float(rp_mulitplier_global, default)
end

local no_rp_sup = false
local no_rp_sup_loop = false
money_root_sup:toggle("No RP", { "norpsup" }, "", function(status)
    no_rp_sup = status
    no_rp_sup_loop = no_rp_sup
    while no_rp_sup_loop do
        disable_rp_multiplier(no_rp_sup)
        util.yield()
    end
    disable_rp_multiplier(no_rp_sup)
end, false)

money_root_sup:action("Source Crates", { "sourcecrate" }, "Will source crates for Warehouse in slot 0.", function()
    resupply()
end)

local resupply_at_value = 10
money_root_sup:slider("Resupply at", {"rspat"}, "Select value to resupply warehouse when using the Superiority Loop.", 0, 108, 10, 1, function(value)
    resupply_at_value = value
end)

local SCV = 750
local HRD = 25
local function sellsuperior()
    if not NETWORK.NETWORK_IS_SCRIPT_ACTIVE("GB_CONTRABAND_SELL") then
    	tpfps()
        menu.trigger_commands("sellacrate")
        util.yield(SCV)
    	kill_appsecuroserv()
    	util.yield(HRD)
    end
end

local crate_sell_loop_sup_feature = money_root_sup:toggle_loop("Superiority Loop", {"sellloopsp"}, "The Superior Loop has been found, this will sell crates as fast as the game can KINDA", function()
	sellsuperior()
    if read_stat_integer("CONTOTALFORWHOUSE0") <= resupply_at_value then
	util.yield(0)
    resupply()
	end
end)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Stabilizers
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Stabilizers

local stabilizers = money_root_sup:list("Stabilizers", {}, "Stabilizers for the hard delays included in the sell function for the Superiority Loop.")

local RSTRTLP = 25000
stabilizers:slider("Loop Restart", {}, "Select how fast the loop should restart after switching sessions due to too many failed selling attempts (Usually happens when a Special Cargo Raid happens or some other shit) ", 5000, 30000, 25000, 1000, function(RSTRTLP_value)
    RSTRTLP = RSTRTLP_value
end)


stabilizers:slider("Kill SecuroServ App Stabilizer", {}, "Stabilizer to set hard delay in which the SecuroServ app will be killed after executing the sellcrate command", 400, 1000, 750, 25, function(SCV_value)
    SCV = SCV_value
end)


stabilizers:slider("Hard Loop Stabilizer", {}, "Stabilizer to set when the Loop will try to restart (Can't really find a better way to explain it) ", 0, 1000, 25, 25, function(HRD_value)
    HRD = HRD_value
end)
--#endregion Stabilizers
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Stabilizers
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
money_root_sup:divider("misc")

money_root_sup:action("Kill script", {}, "Use this to end the script without having to go back 10,000 times.", function()
	util.stop_script()
end)
--#endregion Superiority Loop
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Superiority Loop
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MB Cargo Loop
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region MB Cargo Loop
local function leave_session()
    trigger_cmd(crate_sell_loop_feature, "off")
	util.yield(500)
	trigger_cmd("Online>New Session>Create Solo Session")
	util.yield(25000)
	trigger_cmd(crate_sell_loop_feature, "on")
end

function leave_session_sup()
    trigger_cmd(crate_sell_loop_sup_feature, "off")
	util.yield(500)
	trigger_cmd("Online>New Session>Create Solo Session")
	util.yield(RSTRTLP)
	trigger_cmd(crate_sell_loop_sup_feature, "on")
end

local counter = 0
local counter_sup = 0
local function peepee()
    if menu.get_value(crate_sell_loop_feature) then
        local n = read_stat_integer("CONTOTALFORWHOUSE0")
        util.yield(speed)
        if n == read_stat_integer("CONTOTALFORWHOUSE0") then
            counter = counter + 1
            if counter >= 7 then
                leave_session()
                counter = 0
            end
        else
            counter = 0
        end
    end

    if menu.get_value(crate_sell_loop_sup_feature) then
        local n = read_stat_integer("CONTOTALFORWHOUSE0")
        util.yield(1800)
        if n == read_stat_integer("CONTOTALFORWHOUSE0") then
            counter_sup = counter_sup + 1
            if counter_sup >= 5 then
                leave_session_sup()
                counter_sup = 0
            end
        else
            counter_sup = 0
        end
    end
end


util.create_tick_handler(function()
    peepee()
end)

--#endregion MB Cargo Loop
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MB Cargo Loop
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local no_rp_crate = false
local no_rp_crate_loop = false
crate_root:toggle("No RP", { "norp" }, "", function(status)
    no_rp_crate = status
    no_rp_crate_loop = no_rp_crate
    while no_rp_crate_loop do
        disable_rp_multiplier(no_rp_crate)
        util.yield()
    end
    disable_rp_multiplier(no_rp_crate)
end, false)
