---------------------------------------------------------------------------
---[ data-final-fixes.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Contenedor de este archivo ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Inicio del MOD ]---
---------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de la referencia
    This_MOD.setting_mod()

    --- Obtener los elementos
    This_MOD.get_elements()

    --- Modificar los elementos
    for iKey, spaces in pairs(This_MOD.to_be_processed) do
        for jKey, space in pairs(spaces) do
            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Marcar como procesado
            This_MOD.processed[iKey] = This_MOD.processed[iKey] or {}
            This_MOD.processed[iKey][jKey] = true

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Crear los elementos
            This_MOD.create_item(space)
            This_MOD.create_entity(space)
            This_MOD.create_recipe(space)
            This_MOD.create_tech(space)

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Valores de la referencia ]---
---------------------------------------------------------------------------

function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validar si se cargó antes
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if This_MOD.processed then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en todos los MODs
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los elementos que el MOD modoficó o modificará
    This_MOD.to_be_processed = {}
    This_MOD.processed = {}

    --- Cargar la configuración
    This_MOD.setting = GMOD.setting[This_MOD.id]

    --- Indicador del mod
    This_MOD.indicator = {
        icon = data.raw["simple-entity"]["parameter-1"].icons[1].icon,
        icon_size = 64,
        scale = 0.25,
        shift = { 8, -8 }
    }

    This_MOD.indicator_tech = GMOD.copy(This_MOD.indicator)
    This_MOD.indicator_tech.shift = { 25, -25 }
    This_MOD.indicator_tech.scale = 1

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Tipos a afectar
    This_MOD.types = {
        -- ["transport-belt"] = true,
        ["splitter"] = true
    }

    --- Entidad de referencia
    This_MOD.lane_splitter = data.raw["lane-splitter"]["lane-splitter"]

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Funciones locales ]---
---------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función para analizar cada entidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function valide(item, entity)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar el item
        if not item then return end

        --- Validar el tipo
        if not This_MOD.types[entity.type] then return end

        --- Validar si ya fue procesado
        if
            This_MOD.processed[entity.type] and
            This_MOD.processed[entity.type][item.name]
        then
            return
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores para el proceso
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Space = {}
        Space.item = item
        Space.entity = entity

        Space.recipe = GMOD.recipes[Space.item.name]
        Space.tech = GMOD.get_technology(Space.recipe)
        Space.recipe = Space.recipe and Space.recipe[1] or nil

        Space.prefix =
            GMOD.name ..
            (GMOD.get_id_and_name(entity.name) or { ids = "-" }).ids ..
            This_MOD.id .. "-" .. entity.name

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Guardar la información
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.to_be_processed[entity.type] = This_MOD.to_be_processed[entity.type] or {}
        This_MOD.to_be_processed[entity.type][entity.name] = Space

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Buscar las entidades a afectar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for item_name, entity in pairs(GMOD.entities) do
        valide(GMOD.items[item_name], entity)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Item = GMOD.copy(space.item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Item.name = space.prefix

    Item.localised_name = GMOD.copy(space.entity.localised_name)

    local Order = tonumber(Item.order) + 1
    Item.order = GMOD.pad_left_zeros(#Item.order, Order)

    table.insert(Item.icons, This_MOD.indicator)

    Item.place_result = Item.name

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_entity(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.entity then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Entity = GMOD.copy(space.entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Entity.name = space.prefix

    Entity.type = This_MOD.lane_splitter.type

    Entity.factoriopedia_simulation = nil

    for _, propiety in pairs({
        "collision_box",
        "selection_box",
        "fast_replaceable_group"
    }) do
        Entity[propiety] = This_MOD.lane_splitter[propiety]
    end

    for _, propiety in pairs({ "structure", "structure_patch" }) do
        for key, newTable in pairs(Entity[propiety]) do
            local oldTable = This_MOD.lane_splitter[propiety][key]
            newTable.shift = oldTable.shift
            newTable.scale = oldTable.scale
        end
    end

    Entity.minable.results = { {
        type = "item",
        name = Entity.name,
        amount = 1
    } }

    local function next_upgrade()
        if not Entity.next_upgrade then
            return
        end
        for _, values in pairs({
            This_MOD.to_be_processed,
            This_MOD.processed
        }) do
            for _, value in pairs(values) do
                if value[Entity.next_upgrade] then
                    local That_MOD =
                        GMOD.get_id_and_name(Entity.next_upgrade) or
                        { ids = "-", name = space.entity.next_upgrade }

                    return
                        GMOD.name .. That_MOD.ids ..
                        This_MOD.id .. "-" ..
                        That_MOD.name
                end
            end
        end
    end

    Entity.next_upgrade = next_upgrade()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Agregar los indicadores del mod
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Entity.icons = GMOD.copy(space.item.icons)
    table.insert(Entity.icons, This_MOD.indicator)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_recipe(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.recipe then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Recipe = GMOD.copy(space.recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Recipe.name = space.prefix

    Recipe.main_product = nil
    Recipe.maximum_productivity = 1000000

    Recipe.icons = GMOD.copy(space.item.icons)
    table.insert(Recipe.icons, This_MOD.indicator)

    local Order = tonumber(Recipe.order) + 1
    Recipe.order = GMOD.pad_left_zeros(#Recipe.order, Order)

    local function validate(ingredient)
        for _, values in pairs({
            This_MOD.to_be_processed,
            This_MOD.processed
        }) do
            for _, value in pairs(values) do
                if value[ingredient.name] then
                    local That_MOD =
                        GMOD.get_id_and_name(ingredient.name) or
                        { ids = "-", name = ingredient.name }

                    return
                        GMOD.name .. That_MOD.ids ..
                        This_MOD.id .. "-" ..
                        That_MOD.name
                end
            end
        end
        return ingredient.name
    end

    for _, ingredient in pairs(Recipe.ingredients) do
        ingredient.name = validate(ingredient)
    end

    Recipe.results = { {
        type = "item",
        name = Recipe.name,
        amount = 1
    } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_tech(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.tech then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Tech = GMOD.copy(space.tech)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Tech.name = space.prefix .. "-tech"

    Tech.icons = GMOD.copy(space.item.icons)
    table.insert(Tech.icons, This_MOD.indicator_tech)

    Tech.localised_name = GMOD.copy(space.entity.localised_name)
    Tech.localised_description = { "" }

    Tech.prerequisites = { space.tech.name }

    Tech.effects = { {
        type = "unlock-recipe",
        recipe = space.prefix
    } }

    if Tech.research_trigger then
        Tech.research_trigger = {
            type = "craft-item",
            item = space.item.name,
            count = 1
        }
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Tech)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------
-- GMOD.var_dump(This_MOD)
-- ERROR()
