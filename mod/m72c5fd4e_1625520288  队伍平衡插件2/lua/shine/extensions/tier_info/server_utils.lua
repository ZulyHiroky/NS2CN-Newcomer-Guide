local Plugin = Plugin

Script.Load("lua/shine/extensions/tier_info/crypt/salsa20.lua")

-- Compares whether keys exist in one table from the other
function Plugin.TableKeyDiff(table1, table2)
  for k, v in pairs(table1) do
    if k ~= "__Version" and table2[k] == nil then return true end
  end
  for k, v in pairs(table2) do
    if k ~= "__Version" and table1[k] == nil then return true end
  end
  
  return false
end

-- Merges another table, while removing keys which no longer exist. Enabling config file updates.
function Plugin.TableBaseCopy(base, migrate)
  local new = table.Copy(base)
  
  for k, v in pairs(migrate) do
    if base[k] ~= nil then
      new[k] = migrate[k]
    end
  end
  
  return new
end

function Plugin.Encrypt(str)
  return string.ToBase64(Plugin.salsa20.encrypt({112,41,138,59,2,227,189,32,17,136,229,28,98,193,240,112,243,164,70,170,2,89,118,140,158,108,73,201,83,73,143,245}, {214,99,234,53,159,86,232,213}, str, 20))
end