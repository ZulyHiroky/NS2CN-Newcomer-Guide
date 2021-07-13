local Plugin = Plugin

---- Client Start ----
function Plugin.RecTierInfo_Perm(m)
  Plugin.perm = m["perm"]
end
Client.HookNetworkMessage(Plugin.kMsgPermName, Plugin.RecTierInfo_Perm)

function Plugin.RecTierInfo_Data(message)
  for player in string.gmatch(message.p, '([^|]+)') do
    local values = Plugin.Split(player, ',');

    if (#values >= 12) then -- Sanity check
      local id = values[1];
      local time_played = tonumber(values[2]);
      local commander_time = tonumber(values[3]);
      local marine_playtime = tonumber(values[4]);
      local alien_playtime = tonumber(values[5]);
      local familyInfo = tonumber(values[6]);
      local sph = tonumber(values[7]);
      local sph_marine = tonumber(values[8]);
      local sph_alien = tonumber(values[9]);

      local skill_offset = tonumber(values[10]);
      local comm_skill = tonumber(values[11]);
      local comm_skill_offset = tonumber(values[12]);
      local comm_adagrad_sum = tonumber(values[13]);

      local country = values[14];
      local bans = tonumber(values[15]);
      local smurfsStr = values[16];
      local vpn = tonumber(values[17]);
      local accuracy_marine = tonumber(values[18]);
      local accuracy_alien = tonumber(values[19]);
      local kdr_marine = tonumber(values[20]);
      local kdr_alien = tonumber(values[21]);
      local isAdmin = tonumber(values[22]);
      local smurfs;
      
      -- Smurf data
      if (smurfsStr ~= nil and smurfsStr ~= ' ') then
        smurfs = {};
        for smurf in string.gmatch(smurfsStr, '([^;]+)') do
          local values = Plugin.Split(smurf, ':');
          if (#values >= 4) then -- Sanity check
            table.insert(smurfs, {
              alias = string.FromBase64(values[1]),
              skill = tonumber(values[2]),
              sph = tonumber(values[3]),
              bans = tonumber(values[4]),
              sph_marine = tonumber(values[5]),
              sph_alien = tonumber(values[6])
            });
          end
        end
      end
      
      -- Player data
      Plugin.player[id] = {
        time_played = time_played,
        commander_time = commander_time,
        familyInfo = familyInfo,
        sph = sph,
        sph_marine = sph_marine,
        sph_alien = sph_alien,
        marine_playtime = marine_playtime,
        alien_playtime = alien_playtime,
        skill_offset = skill_offset,
        comm_skill = comm_skill,
        comm_skill_offset = comm_skill_offset,
        comm_adagrad_sum = comm_adagrad_sum,
        country = country,
        bans = bans,
        smurfs = smurfs,
        vpn = vpn,
        accuracy_marine = accuracy_marine,
        accuracy_alien = accuracy_alien,
        kdr_marine = kdr_marine,
        kdr_alien = kdr_alien,
        isAdmin = isAdmin
      };
    end
  end
end
Client.HookNetworkMessage(Plugin.kMsgDataName, Plugin.RecTierInfo_Data)

function Plugin.RecTierInfo_LastRound(message)
  Shared.ConsoleCommand("cl_lastround " .. message.round_id);
end
Client.HookNetworkMessage(Plugin.kMsgLastRoundName, Plugin.RecTierInfo_LastRound)
---- End Client -----
