local an, ns = ...

local frame=CreateFrame("Frame");-- 
frame:RegisterEvent("GROUP_FORMED");
frame:RegisterEvent("GROUP_ROSTER_UPDATE");

frame:SetScript("OnEvent",function(self,event,msg,author)
  addon = ns.an.addon
  if not UnitIsGroupLeader("player") or addon.db.profile.guildInvites ~= true then
    return
  end
  if event=="GROUP_FORMED" then
    if not IsInRaid() then
      ConvertToRaid();
      ns.an.inviteGuild();
    end
    if lootmethod ~= "master" then
      SetLootMethod("master", GetUnitName("player"));
    end
    if GetLootThreshold() ~= 4 then
      hg__wait(2, lootThresholdDelay);
    end
  end
  if event=="GROUP_ROSTER_UPDATE" then
    local numTotal = (GetNumGroupMembers());
    local realmName = GetRealmName()
    if numTotal > 1 and not IsInRaid() then
      ConvertToRaid()
      ns.an.inviteGuild();
    end
    for i=1,numTotal do
      name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
      if name == nil then
        return
      end
      local playerName = name .. "-" .. realmName
      local rankName = ns.an.memberRanks[playerName]
      guildName, guildRankName, guildRankIndex = GetGuildInfo(playerName)
      if rank < 1 and UnitIsGroupLeader("player") and (rankName == "Officer" or rankName == "Officer alt") then
        PromoteToAssistant(name);
      end
    end
  end
end);

local waitTable = {};
local waitFrame = nil;

function hg__wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{...}});
  return true;
end

function lootThresholdDelay() 
  SetLootThreshold(4);
end
