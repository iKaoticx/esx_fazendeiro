ESX = nil
local PlayersTransforming  = {}
local PlayersSelling       = {}
local PlayersHarvesting = {}
local milho = 1
local feijao = 1
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.MaxInService ~= -1 then
	TriggerEvent('esx_service:activateService', 'farmer', Config.MaxInService)
end

TriggerEvent('esx_phone:registerNumber', 'farmer', _U('farmer_client'), true, true)
TriggerEvent('esx_society:registerSociety', 'farmer', 'Farmer', 'society_farmer', 'society_farmer', 'society_farmer', {type = 'private'})
local function Harvest(source, zone)
	if PlayersHarvesting[source] == true then

		local xPlayer  = ESX.GetPlayerFromId(source)
		if zone == "GrainFarm" then
			local itemQuantity = xPlayer.getInventoryItem('grain').count
			if itemQuantity >= 50 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_place'))
				return
			else
				SetTimeout(1800, function()
					xPlayer.addInventoryItem('grain', 1)
					Harvest(source, zone)
				end)
			end
		end
	end
end

RegisterServerEvent('esx_farmerjob:startHarvest')
AddEventHandler('esx_farmerjob:startHarvest', function(zone)
	local _source = source
  	
	if PlayersHarvesting[_source] == false then
		TriggerClientEvent('esx:showNotification', _source, '~r~Não tente abusar de glitches~w~')
		PlayersHarvesting[_source]=false
	else
		PlayersHarvesting[_source]=true
		TriggerClientEvent('esx:showNotification', _source, _U('grain_taken'))  
		Harvest(_source,zone)
	end
end)


RegisterServerEvent('esx_farmerjob:stopHarvest')
AddEventHandler('esx_farmerjob:stopHarvest', function()
	local _source = source
	
	if PlayersHarvesting[_source] == true then
		PlayersHarvesting[_source]=false
		TriggerClientEvent('esx:showNotification', _source, 'Você saiu da zona de ~r~colheita')
	else
		TriggerClientEvent('esx:showNotification', _source, 'Você pode colher ~g~grãos')
		PlayersHarvesting[_source]=true
	end
end)


local function Transform(source, zone)

	if PlayersTransforming[source] == true then

		local xPlayer  = ESX.GetPlayerFromId(source)
		if zone == "TraitementMilho" then
			local itemQuantity = xPlayer.getInventoryItem('grain').count
			
			if itemQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_grain'))
				return
			else
				local rand = math.random(0,100)
				if (rand >= 98) then
					SetTimeout(1800, function()
						xPlayer.removeInventoryItem('grain', 1)
						xPlayer.addInventoryItem('milho', 1)
						TriggerClientEvent('esx:showNotification', source, _U('milho'))
						Transform(source, zone)
					end)
				else
					SetTimeout(1800, function()
						xPlayer.removeInventoryItem('grain', 1)
						xPlayer.addInventoryItem('milho', 1)
				
						Transform(source, zone)
					end)
				end
			end
		elseif zone == "TraitementFeijao" then
			local itemQuantity = xPlayer.getInventoryItem('grain').count
			if itemQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_grain'))
				return
			else
				SetTimeout(1800, function()
					xPlayer.removeInventoryItem('grain', 1)
					xPlayer.addInventoryItem('feijao', 1)
		  
					Transform(source, zone)	  
				end)
			end
		end
	end	
end

RegisterServerEvent('esx_farmerjob:startTransform')
AddEventHandler('esx_farmerjob:startTransform', function(zone)
	local _source = source
  	
	if PlayersTransforming[_source] == false then
		TriggerClientEvent('esx:showNotification', _source, '~r~Não tente abusar de glitches ~w~')
		PlayersTransforming[_source]=false
	else
		PlayersTransforming[_source]=true
		TriggerClientEvent('esx:showNotification', _source, _U('transforming_in_progress')) 
		Transform(_source,zone)
	end
end)

RegisterServerEvent('esx_farmerjob:stopTransform')
AddEventHandler('esx_farmerjob:stopTransform', function()

	local _source = source
	
	if PlayersTransforming[_source] == true then
		PlayersTransforming[_source]=false
		TriggerClientEvent('esx:showNotification', _source, 'Você saiu da zona de ~r~processamento')
		
	else
		TriggerClientEvent('esx:showNotification', _source, 'Você pode processar seus ~g~grãos')
		PlayersTransforming[_source]=true
		
	end
end)

local function Sell(source, zone)

	if PlayersSelling[source] == true then
		local xPlayer  = ESX.GetPlayerFromId(source)
		
		if zone == 'SellFarm' then
			if xPlayer.getInventoryItem('milho').count <= 0 then
				milho = 0
			else
				milho = 1
			end
			
			if xPlayer.getInventoryItem('feijao').count <= 0 then
				feijao = 0
			else
				feijao = 1
			end
		
			if milho == 0 and feijao == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('no_product_sale'))
				return
			elseif xPlayer.getInventoryItem('milho').count <= 0 and feijao == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('no_milho_sale'))
				milho = 0
				return
			elseif xPlayer.getInventoryItem('feijao').count <= 0 and milho == 0then
				TriggerClientEvent('esx:showNotification', source, _U('no_feijao_sale'))
				feijao = 0
				return
			else
				if (feijao == 1) then
					SetTimeout(1100, function()
						local money = math.random(100,300)
						xPlayer.removeInventoryItem('feijao', 1)
						local societyAccount = nil

						TriggerEvent('esx_addonaccount:getSharedAccount', 'society_farm', function(account)
							societyAccount = account
						end)
						if societyAccount ~= nil then
							societyAccount.addMoney(money)
							TriggerClientEvent('esx:showNotification', xPlayer.source, _U('comp_earned') .. money)
						end
						Sell(source,zone)
					end)
				elseif (milho == 1) then
					SetTimeout(1100, function()
						local money = math.random(150,350)
						xPlayer.removeInventoryItem('milho', 1)
						local societyAccount = nil

						TriggerEvent('esx_addonaccount:getSharedAccount', 'society_farm', function(account)
							societyAccount = account
						end)
						if societyAccount ~= nil then
							societyAccount.addMoney(money)
							TriggerClientEvent('esx:showNotification', xPlayer.source, _U('comp_earned') .. money)
						end
						Sell(source,zone)
					end)
				end
				
			end
		end
	end
end

RegisterServerEvent('esx_farmerjob:startSell')
AddEventHandler('esx_farmerjob:startSell', function(zone)

	local _source = source
	
	if PlayersSelling[_source] == false then
		TriggerClientEvent('esx:showNotification', _source, '~r~Não tente abusar de glitches ~w~')
		PlayersSelling[_source]=false
	else
		PlayersSelling[_source]=true
		TriggerClientEvent('esx:showNotification', _source, _U('sale_in_prog'))
		Sell(_source, zone)
	end

end)

RegisterServerEvent('esx_farmerjob:stopSell')
AddEventHandler('esx_farmerjob:stopSell', function()

	local _source = source
	
	if PlayersSelling[_source] == true then
		PlayersSelling[_source]=false
		TriggerClientEvent('esx:showNotification', _source, 'Você saiu da zona de ~r~venda')
		
	else
		TriggerClientEvent('esx:showNotification', _source, 'Você pode vender seus ~g~grãos')
		PlayersSelling[_source]=true
	end

end)

RegisterServerEvent('esx_farmerjob:getStockItem')
AddEventHandler('esx_farmerjob:getStockItem', function(itemName, count)

	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_farmer', function(inventory)

		local item = inventory.getItem(itemName)

		if item.count >= count then
			inventory.removeItem(itemName, count)
			xPlayer.addInventoryItem(itemName, count)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end

		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn') .. count .. ' ' .. item.label)

	end)

end)

ESX.RegisterServerCallback('esx_farmerjob:getStockItems', function(source, cb)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_farmer', function(inventory)
		cb(inventory.items)
	end)

end)

RegisterServerEvent('esx_farmerjob:putStockItems')
AddEventHandler('esx_farmerjob:putStockItems', function(itemName, count)

	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_farmer', function(inventory)

		local item = inventory.getItem(itemName)

		if item.count >= 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end

		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('added') .. count .. ' ' .. item.label)

	end)
end)

ESX.RegisterServerCallback('esx_farmerjob:getPlayerInventory', function(source, cb)

	local xPlayer    = ESX.GetPlayerFromId(source)
	local items      = xPlayer.inventory

	cb({
		items      = items
	})

end)