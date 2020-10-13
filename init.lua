 -- luacheck: globals rhyn minetest shout
local thismod = minetest.get_current_modname()
local tm = thismod
--local parentmod = "rhyn"
local genera = {"mosa"}

rhyn.f.gust = function(pos,mag,tex,h)
    local tex = tex
local dir,mag,bas,nope = {x = 0, y = 1, z = 0}, mag or 1, {x = 0, y = 1, z = 0},{x = 0, y = 0, z = 0}
minetest.add_particlespawner({
    amount = 1,
    time = 1,
    minpos = {x=pos.x-0.01, y=pos.y+0.3, z=pos.z-0.01},
    maxpos = {x=pos.x+0.01, y=pos.y+0.3, z=pos.z+0.01},
    minvel = nope,
    maxvel = nope,
    minacc = nope,
    maxacc = nope,
    minexptime = 2,
    maxexptime = 2,
    minsize = 2,
    maxsize = 2,

    collisiondetection = false,
    collision_removal = false,
    vertical = true,
    texture = tex,
    animation = {
        type = "vertical_frames",
        aspect_w = 4,
        aspect_h = 4,
        length = 0.5},
        {
            type = "sheet_2d",
            frames_w = 1,
            frames_h = h,
            frame_length = 1,
        },
    glow = 12
})
return true
end

local dowse = function(pos)
    local nearbyobjs,nodename = minetest.get_objects_inside_radius(pos,3),minetest.get_node(pos).name
    local m = tonumber(string.sub(nodename,string.len(nodename))) < 3
    shout(m)
   return #nearbyobjs > 0 and m and minetest.get_meta(pos):set_int("rhyn_gi", 100)
end

for g = 1, #genera do
rhyn.modules[tm] = {genera = {genera[g]}}

local def = {
    parentmod = tm,
    visual = "mesh",
    genus = genera[g],
    root_dim = 2,
    health_max = 10,
    growth_interval = 100,
    substrates = {["nc_terrain:sand"] = 6},
    growth_factor = {names = {"nc_fire:ash"},values = {8}},
    survival_factor = {names = {"group:igniter"}, values = {-9}},
    spore_dis_rad = 3,
    condition_factor = {},
    catchments = {base = 1, ext = 2},
    structure = {{tm..":mosa_mat_1"},{tm..":mosa_mat_2"},{tm..":mosa_mat_3"},{"air"}},
    stage = stage,
    traits = {growth_opt = false, pt2condition = false},
    acts = {
       on_tick = function(...)
            local val = rhyn.f.selectify(...)
            local pos,genus = val[1], val[2]
            
            if(not rhyn.f.is_rooted(pos,genera[g]))then return rhyn.rn(pos) end
            rhyn.f.alter_health(pos,-rhyn.f.spot_check(pos,"group:igniter"))
            
            local function incr()
            rhyn.f.growth_tick(pos,genus)
            dowse(pos)
            end
            incr()
          end,
        on_propagate = function(...)
            local val = rhyn.f.selectify(...)
            local pos,genus = val[1], val[2]
            --rhyn.f.pollen(pos,{x = 0, y = 1, z = 0},8,"drum_pollen.png",10)
        end,
        on_die = function(...)
        shout("nah")
        end
    }
}

rhyn.f.register_emulsion(def)


    local k = genera[g]
    local v = def
    for n = 1, 3 do
            local name = k.."_mat_"..n
            local ndef = {
                genus = k,
                name = tm..":"..name,
                description = k,
                paramtype = "light",
                sunlight_propagates = true,
                drawtype = "plantlike",
                waving = 2,
                tiles = {"sisa.png"},
                groups = {planty = 1, rhyn_plant = 1, stack_as_node = 1},
                light_source = n*4,
                on_construct = function(pos)
                local meta = minetest.get_meta(pos)
                meta:set_int("rhyn_gl",n)
                meta:set_int("rhyn_ci",1)
                meta:set_int("rhyn_h",v.health_max)
                end,
                on_punch = function(pos,node,puncher)
                    local m = minetest.get_meta(pos)
                    shout("GROWTH: "..m:get_int("rhyn_gi"))
                    shout("CONDITION: "..m:get_int("rhyn_ci"))
                    shout("HEALTH: "..rhyn.f.check_health(pos))
                    --nodecore.item_eject(pos, {name = tm..":"..k.."_mat_4"}, math.random(30), 1, vel)
                    shout(nodecore.witness(pos))
                    return
                end
            }
            rhyn.f.rnode(ndef)
        end
        rhyn.f.assign_soils_alt(genera[g])
end
