-- PoucaveAlert: Détecte et annonce qui bouge pendant Shackle (Mephist)
-- Et annonce les mauvais dispels dans le raid
-- Compatible WoW 1.12 (Turtle WoW)

PoucaveAlert = {}
PoucaveAlert.trackedPlayers = {}
PoucaveAlert.checkInterval = 0.1 -- Vérification toutes les 0.1 secondes
PoucaveAlert.scanInterval = 0.5 -- Scanner les debuffs toutes les 0.5 secondes
PoucaveAlert.initialized = false
PoucaveAlert.testMode = false -- Mode test pour simuler le debuff Shackle

-- Noms possibles du sort Shackle (à adapter selon le serveur)
PoucaveAlert.shackleNames = {
    "Shackle of the Legion",
    "shackle of the legion",
    "Shackle",
    "shackle",
    "Shackles", 
    "shackles",
    "Chaînes de la Légion",
    "chaînes de la légion",
    "Chaînes",
    "chaînes",
    "Chains",
    "chains",
}
-- Stats de session
PoucaveAlert.stats = {
    shackleCount = 0,
    movementAlerts = 0,
    dispelAlerts = 0,
    forbiddenDispels = 0,
}
-- Anti-spam: timestamp de la dernière alerte par joueur
PoucaveAlert.lastAlertTime = {}

-- Liste des sorts à NE PAS DISPEL (très dangereux!)
PoucaveAlert.forbiddenDispels = {
    -- Gnarlmoon
    ["Moon-Tainted"] = { boss = "Gnarlmoon", type = "Magie", danger = "Mécanique" },
    ["Lunar Blessing"] = { boss = "Gnarlmoon", type = "Magie", danger = "Mécanique" },
    
    -- Incantagos
    ["Leyfire"] = { boss = "Incantagos", type = "Magie", danger = "Mécanique" },
    ["Ley Infusion"] = { boss = "Incantagos", type = "Magie", danger = "Mécanique" },
    ["Ley Imbalance"] = { boss = "Incantagos", type = "Magie", danger = "Mécanique" },
    ["Arcane Flux"] = { boss = "Incantagos", type = "Magie", danger = "Mécanique" },
    
    -- Anomalus
    ["Arcane Bomb"] = { boss = "Anomalus", type = "Magie", danger = "💀 EXPLOSION INSTANT WIPE!" },
    ["Arcane Feedback"] = { boss = "Anomalus", type = "Magie", danger = "Mécanique" },
    
    -- Medivh
    ["Doom of Medivh"] = { boss = "Medivh", type = "Malédiction", danger = "Mécanique" },
    ["Frost Rune"] = { boss = "Medivh", type = "Magie", danger = "Mécanique" },
    ["Arcane Freeze"] = { boss = "Medivh", type = "Magie", danger = "Mécanique" },
    ["Shadow Rift"] = { boss = "Medivh", type = "Autre", danger = "Mécanique" },
    ["Void Echo"] = { boss = "Medivh", type = "Magie", danger = "Mécanique" },
    
    -- Chess Event
    ["Pawn Control"] = { boss = "Chess", type = "Autre", danger = "⛔ NE JAMAIS DISPEL!" },
    ["Knight Control"] = { boss = "Chess", type = "Autre", danger = "⛔ NE JAMAIS DISPEL!" },
    ["Bishop Control"] = { boss = "Chess", type = "Autre", danger = "⛔ NE JAMAIS DISPEL!" },
    ["Queen Control"] = { boss = "Chess", type = "Autre", danger = "⛔ NE JAMAIS DISPEL!" },
    ["King Control"] = { boss = "Chess", type = "Autre", danger = "⛔ NE JAMAIS DISPEL!" },
    ["Dark Enchantment"] = { boss = "Chess", type = "Magie", danger = "Mécanique" },
    ["Shadow Empowerment"] = { boss = "Chess", type = "Magie", danger = "Mécanique" },
    
    -- Sanv Tasdal
    ["Phase Shifted"] = { boss = "Sanv Tasdal", type = "Magie", danger = "💀 TRÈS DANGEREUX!" },
    ["Rift Aura"] = { boss = "Sanv Tasdal", type = "Autre", danger = "Mécanique" },
    ["Rift Saturation"] = { boss = "Sanv Tasdal", type = "Autre", danger = "Mécanique" },
    ["Rift Echo"] = { boss = "Sanv Tasdal", type = "Autre", danger = "Mécanique" },
    ["Hatred Fragment"] = { boss = "Sanv Tasdal", type = "Magie", danger = "Mécanique" },
    ["Hatred Residue"] = { boss = "Sanv Tasdal", type = "Magie", danger = "Mécanique" },
    
    -- Krull
    ["Shadow Infusion"] = { boss = "Krull", type = "Magie", danger = "Mécanique" },
    ["Fel Enrage"] = { boss = "Krull", type = "Magie", danger = "Mécanique" },
    ["Echoing Pain"] = { boss = "Krull", type = "Magie", danger = "Mécanique" },
    ["Mana Detonation"] = { boss = "Krull", type = "Magie", danger = "💀 EXPLOSION SI DISPEL!" },
    
    -- Mephistroth
    ["Burning Hatred"] = { boss = "Mephistroth", type = "Magie", danger = "Mécanique" },
    ["Shackle of the Legion"] = { boss = "Mephistroth", type = "Magie", danger = "⚠️ Ne pas dispel!" },
    ["Soul Torment"] = { boss = "Mephistroth", type = "Magie", danger = "Mécanique" },
}

-- Table de blagues WoW
PoucaveAlert.jokes = {
    "Pourquoi les Mages ne peuvent pas faire de blagues? Parce qu'elles sont trop explosives!",
    "Qu'est-ce qu'un Chevalier de la Mort dit au bar? Je vais prendre un... verre de sang!",
    "Comment appelle-t-on un Druide qui perd ses formes? Un sans-forme!",
    "Pourquoi les Shamans sont jamais tristes? Parce qu'ils contrôlent l'élémentaire!",
    "Qu'est-ce qu'un Paladin et un prêtre ont en commun? Ils prient tous les deux... mais le Paladin prie en frappant!",
    "Pourquoi les Voleurs vont toujours en prison? Parce qu'ils sont trop... transparents!",
    "Comment un Chasseur compte ses victimes? 1... 2... PEW PEW PEW!",
    "Qu'est-ce qu'un Guerrier dit après un wipe? Je pense que je n'ai pas CHARGÉ assez!",
    "Pourquoi les Démonistes ne gagnent jamais au poker? Ils vendent toujours leur âme!",
    "Qu'est-ce qu'un Moine et un café ont en commun? Ils sont TOUS LES DEUX énergisants!",
    "Comment tu sais qu'un Druide a mangé trop? Quand il se transforme en Baleine!",
    "Pourquoi les Arcanistes rêvent-ils en nombre? Parce qu'ils calculent tout!",
    "Qu'est-ce qu'un Rôdeur qui a oublié son arc dit? Je suis totalement... désarmé!",
    "Pourquoi les Guerriers ne lisent jamais? Parce que les mots ont trop de DÉGÂTS!",
    "Qu'est-ce qu'un Sorcier dit en prison? Enfin un sort de CONTRÔLE qui fonctionne!",
}

-- Configuration par défaut
local defaults = {
    enabled = true,
    announceChannel = "RAID_WARNING", -- RAID_WARNING, RAID, PARTY, SAY
    soundAlert = true,
    debugMode = false,
    autoScan = true, -- Scanner automatiquement les debuffs du raid
    announceDispels = true, -- Annoncer les dispels dans le raid
}

-- Fonction pour obtenir une valeur de config avec fallback
local function GetConfig(key)
    if PoucaveAlertDB and PoucaveAlertDB[key] ~= nil then
        return PoucaveAlertDB[key]
    end
    return defaults[key]
end

-- Fonction pour définir une valeur de config
local function SetConfig(key, value)
    if not PoucaveAlertDB then
        PoucaveAlertDB = {}
    end
    PoucaveAlertDB[key] = value
end

-- Initialisation
function PoucaveAlert:OnLoad(frame)
    if not frame then return end
    
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
    frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")
    frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE")
    frame:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
    frame:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY")
    frame:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
    
    -- Événements pour détecter les dispels/decurse
    frame:RegisterEvent("CHAT_MSG_SPELL_BREAK_AURA")
    frame:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
    frame:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY")
    frame:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
    
    -- Événements pour détecter les messages !blague
    frame:RegisterEvent("CHAT_MSG_PARTY")
    frame:RegisterEvent("CHAT_MSG_RAID")
    frame:RegisterEvent("CHAT_MSG_GUILD")
    
    self.initialized = true
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert|r v1.1 chargé. /pa pour les commandes.")
end

-- Helper: Vérifier si un unitId existe et est valide
local function IsValidUnitId(unitId)
    return UnitExists(unitId) and UnitName(unitId) ~= nil
end

-- Helper: Comparer les noms de sort sans casse
local function SpellMatches(spellName, searchName)
    if not spellName or not searchName then return false end
    return string.find(string.lower(spellName), string.lower(searchName), 1, true) ~= nil
end

-- Helper: Anti-spam (max 1 alerte par joueur par 2 secondes)
local function CanAlert(playerName)
    local now = GetTime()
    if PoucaveAlert.lastAlertTime[playerName] and (now - PoucaveAlert.lastAlertTime[playerName]) < 2 then
        return false
    end
    PoucaveAlert.lastAlertTime[playerName] = now
    return true
end

-- Helper: Récupérer une blague aléatoire
local function GetRandomJoke()
    local jokeCount = table.getn(PoucaveAlert.jokes)
    local randomIndex = math.random(1, jokeCount)
    return PoucaveAlert.jokes[randomIndex]
end

-- Initialisation des variables sauvegardées (appelée au login)
function PoucaveAlert:Initialize()
    if not PoucaveAlertDB then
        PoucaveAlertDB = {}
    end
    
    for k, v in pairs(defaults) do
        if PoucaveAlertDB[k] == nil then
            PoucaveAlertDB[k] = v
        end
    end
    
    self.initialized = true
end

-- Détection du debuff Shackle
function PoucaveAlert:CheckShackleDebuff(msg)
    -- Mode debug: afficher tous les messages
    if GetConfig("debugMode") then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8800[DEBUG SHACKLE]|r " .. msg)
    end
    
    -- Patterns pour détecter Shackle dans les messages de combat
    local patterns = {
        "(.+) is afflicted by Shackle of the Legion",
        "(.+) subit les effets de Chaînes de la Légion",
        "(.+) is afflicted by Shackle",
        "(.+) subit les effets de Chaînes",
        "You are afflicted by Shackle",
        "Vous subissez les effets de Chaînes",
    }
    
    for _, pattern in ipairs(patterns) do
        local _, _, playerName = string.find(msg, pattern)
        if playerName then
            if playerName == "You" or playerName == "Vous" then
                playerName = UnitName("player")
            end
            
            if playerName then
                self:AddTrackedPlayer(playerName)
                if GetConfig("debugMode") then
                    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert:|r " .. playerName .. " a Shackle")
                end
            end
            return true
        end
    end
    return false
end

-- Détection de la fin du debuff
function PoucaveAlert:CheckShackleRemoved(msg)
    local patterns = {
        "Shackle of the Legion fades from (.+)",
        "Chaînes de la Légion on (.+) s'estompe",
        "Shackle fades from (.+)",
        "Chaînes on (.+) fades",
        "Shackle fades from you",
        "Chaînes s'estompe",
    }
    
    for _, pattern in ipairs(patterns) do
        local _, _, playerName = string.find(msg, pattern)
        if playerName then
            if playerName == "you" or playerName == "vous" then
                playerName = UnitName("player")
            end
            
            if playerName then
                self:RemoveTrackedPlayer(playerName)
                if GetConfig("debugMode") then
                    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert:|r " .. playerName .. " n'a plus Shackle")
                end
            end
            return true
        end
    end
    return false
end

-- Ajouter un joueur à surveiller
function PoucaveAlert:AddTrackedPlayer(name)
    if not self.trackedPlayers[name] then
        local x, y = 0, 0
        local unitId = nil
        
        -- Trouver le unitId correspondant au nom
        if UnitName("player") == name then
            unitId = "player"
        else
            -- Chercher dans le raid
            for i = 1, GetNumRaidMembers() do
                if UnitName("raid"..i) == name then
                    unitId = "raid"..i
                    break
                end
            end
            
            -- Chercher dans le groupe si pas trouvé dans le raid
            if not unitId then
                for i = 1, GetNumPartyMembers() do
                    if UnitName("party"..i) == name then
                        unitId = "party"..i
                        break
                    end
                end
            end
        end
        
        -- Obtenir la position avec le bon unitId
        if unitId then
            x, y = GetPlayerMapPosition(unitId)
        end
        
        self.trackedPlayers[name] = {
            lastX = x or 0,
            lastY = y or 0,
            startTime = GetTime(),
            warningGiven = false,
            isTest = self.testMode, -- Marquer si c'est un test
        }
    end
end

-- Détecter et annoncer les dispels/decurse
function PoucaveAlert:CheckDispel(msg)
    if not GetConfig("announceDispels") then return end
    
    -- Mode debug: afficher tous les messages
    if GetConfig("debugMode") then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF00FF[DEBUG DISPEL]|r " .. msg)
    end
    
    local patterns = {
        -- Dispel Magic / Remove Curse patterns (EN)
        "(.+)'s (.+) is removed%.",
        "Your (.+) removes (.+) from (.+)%.",
        "(.+)'s (.+) removes (.+) from (.+)%.",
        "(.+) is removed from (.+)%.",
        
        -- Versions françaises possibles
        "(.+) est retiré de (.+)%.",
        "Votre (.+) retire (.+) de (.+)%.",
        "(.+) de (.+) est retiré%.",
    }
    
    -- Pattern 1: "Player's Spell is removed." (DISPEL ACTIF)
    local _, _, target, spell = string.find(msg, "^(.+)'s (.+) is removed%.$")
    if target and spell then
        self:AnnounceDispel("Dispeller", spell, target)
        return true
    end
    
    -- Pattern 2: "Spell fades from Player." (expire naturellement - PAS un dispel)
    local _, _, spell2, target2 = string.find(msg, "^(.+) fades from (.+)%.$")
    if spell2 and target2 then
        -- Ne rien faire, c'est juste l'expiration naturelle
        if GetConfig("debugMode") then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF888888[Fade naturel]|r " .. spell2 .. " sur " .. target2)
        end
        return false
    end
    
    -- Pattern 3: "Your Dispel Magic removes X from Y."
    local _, _, dispelSpell, removedSpell, target3 = string.find(msg, "^Your (.+) removes (.+) from (.+)%.$")
    if dispelSpell and removedSpell and target3 then
        local caster = UnitName("player")
        self:AnnounceDispel(caster, removedSpell, target3)
        return true
    end
    
    -- Pattern 4: "Caster's Dispel Magic removes X from Y."
    local _, _, caster, dispelSpell2, removedSpell2, target4 = string.find(msg, "^(.+)'s (.+) removes (.+) from (.+)%.$")
    if caster and dispelSpell2 and removedSpell2 and target4 then
        self:AnnounceDispel(caster, removedSpell2, target4)
        return true
    end
    
    return false
end

-- Annoncer un dispel dans le raid
function PoucaveAlert:AnnounceDispel(caster, spell, target)
    if not spell or spell == "" then return end
    
    -- Vérifier si c'est un sort interdit (case-insensitive)
    local isForbidden = false
    local dangerInfo = nil
    
    for forbiddenSpell, info in pairs(self.forbiddenDispels) do
        if SpellMatches(spell, forbiddenSpell) then
            isForbidden = true
            dangerInfo = info
            break
        end
    end
    
    local message
    if isForbidden and dangerInfo then
        self.stats.forbiddenDispels = self.stats.forbiddenDispels + 1
        -- Annonce spéciale pour les dispels interdits
        if target then
            message = string.format("⚠️⚠️⚠️ %s a DISPEL [%s] (%s) de %s — %s: %s ⚠️⚠️⚠️", 
                caster, spell, dangerInfo.type, target, dangerInfo.boss, dangerInfo.danger)
        else
            message = string.format("⚠️⚠️⚠️ %s a DISPEL [%s] (%s) — %s: %s ⚠️⚠️⚠️", 
                caster, spell, dangerInfo.type, dangerInfo.boss, dangerInfo.danger)
        end
        
        -- Son d'alerte pour les mauvais dispels
        PlaySound("RaidWarning")
        
        -- Afficher en rouge dans le chat local aussi
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000" .. message .. "|r")
        RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo["RAID_WARNING"])
        
    else
        self.stats.dispelAlerts = self.stats.dispelAlerts + 1
        -- Annonce normale pour les autres dispels
        if target then
            message = string.format("%s a dispel [%s] de %s", caster, spell, target)
        else
            message = string.format("%s a dispel [%s]", caster, spell)
        end
    end
    
    if GetNumRaidMembers() > 0 then
        SendChatMessage(message, "RAID")
    elseif GetNumPartyMembers() > 0 then
        SendChatMessage(message, "PARTY")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[Dispel]|r " .. message)
    end
    
    if GetConfig("debugMode") then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[Dispel]|r " .. message)
    end
end

-- Retirer un joueur de la surveillance
function PoucaveAlert:RemoveTrackedPlayer(name)
    self.trackedPlayers[name] = nil
end

-- Scanner les debuffs du raid pour détecter Shackle
function PoucaveAlert:ScanRaidDebuffs()
    if not GetConfig("autoScan") then return end
    
    local numRaidMembers = GetNumRaidMembers()
    if numRaidMembers == 0 then
        numRaidMembers = GetNumPartyMembers()
    end
    
    -- Scanner le joueur
    self:CheckUnitDebuffs("player")
    
    -- Scanner le raid
    for i = 1, GetNumRaidMembers() do
        self:CheckUnitDebuffs("raid"..i)
    end
    
    -- Scanner le groupe si pas en raid
    for i = 1, GetNumPartyMembers() do
        self:CheckUnitDebuffs("party"..i)
    end
    
    -- Retirer les joueurs qui n'ont plus le debuff
    for playerName, _ in pairs(self.trackedPlayers) do
        local hasDebuff = false
        
        -- Vérifier si le joueur a toujours Shackle
        if UnitName("player") == playerName then
            hasDebuff = self:UnitHasShackle("player")
        else
            for i = 1, GetNumRaidMembers() do
                if UnitName("raid"..i) == playerName then
                    hasDebuff = self:UnitHasShackle("raid"..i)
                    break
                end
            end
            
            if not hasDebuff then
                for i = 1, GetNumPartyMembers() do
                    if UnitName("party"..i) == playerName then
                        hasDebuff = self:UnitHasShackle("party"..i)
                        break
                    end
                end
            end
        end
        
        if not hasDebuff then
            if GetConfig("debugMode") then
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert:|r " .. playerName .. " n'a plus Shackle (scan)")
            end
            self:RemoveTrackedPlayer(playerName)
        end
    end
end

-- Vérifier si une unité a le debuff Shackle
function PoucaveAlert:UnitHasShackle(unitId)
    if not IsValidUnitId(unitId) then return false end
    
    for i = 1, 16 do -- Maximum 16 debuffs en vanilla
        local debuffName = UnitDebuff(unitId, i)
        if not debuffName then break end
        
        -- Vérifier si c'est un des noms de Shackle (insensible à la casse)
        for _, shackleName in ipairs(self.shackleNames) do
            if SpellMatches(debuffName, shackleName) then
                return true
            end
        end
    end
    return false
end

-- Vérifier les debuffs d'une unité
function PoucaveAlert:CheckUnitDebuffs(unitId)
    if not UnitExists(unitId) then return end
    
    local playerName = UnitName(unitId)
    if not playerName then return end
    
    local hasShackle = self:UnitHasShackle(unitId)
    
    if hasShackle and not self.trackedPlayers[playerName] then
        -- Joueur a Shackle et n'est pas encore surveillé
        self:AddTrackedPlayer(playerName)
        if GetConfig("debugMode") then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert:|r " .. playerName .. " a Shackle (scan)")
        end
    end
end

-- Vérifier si un joueur a bougé
function PoucaveAlert:CheckMovement()
    if not GetConfig("enabled") then return end
    
    for playerName, data in pairs(self.trackedPlayers) do
        local currentX, currentY
        
        -- Essayer d'obtenir la position actuelle
        if UnitName("player") == playerName then
            currentX, currentY = GetPlayerMapPosition("player")
        else
            -- Chercher dans le raid
            for i = 1, GetNumRaidMembers() do
                local unitId = "raid" .. i
                if UnitName(unitId) == playerName then
                    currentX, currentY = GetPlayerMapPosition(unitId)
                    break
                end
            end
            
            -- Chercher dans le groupe
            if not currentX then
                for i = 1, GetNumPartyMembers() do
                    local unitId = "party" .. i
                    if UnitName(unitId) == playerName then
                        currentX, currentY = GetPlayerMapPosition(unitId)
                        break
                    end
                end
            end
        end
        
        if currentX and currentY and (currentX > 0 or currentY > 0) then
            -- Calculer la distance déplacée
            local deltaX = currentX - data.lastX
            local deltaY = currentY - data.lastY
            local distance = math.sqrt(deltaX * deltaX + deltaY * deltaY)
            
            -- Seuil de mouvement (ajuster selon les besoins)
            -- Sur la carte, 0.001 représente environ 1 yard
            if distance > 0.0005 and not data.warningGiven then
                -- En mode test, annoncer localement, sinon annoncer normalement
                if data.isTest then
                    DEFAULT_CHAT_FRAME:AddMessage("[TEST] " .. playerName .. " a bougé de " .. string.format("%.4f", distance) .. " - ALERTE déclenchée!")
                end
                self:AnnounceMovement(playerName)
                data.warningGiven = true
                
                if GetConfig("soundAlert") then
                    PlaySound("RaidWarning")
                end
            elseif distance > 0 and data.isTest and GetConfig("debugMode") then
                -- En mode test debug, afficher même les petits mouvements
                DEFAULT_CHAT_FRAME:AddMessage("[TEST DEBUG] Distance: " .. string.format("%.6f", distance) .. " (seuil: 0.0005)")
            end
            
            -- Mettre à jour la position
            data.lastX = currentX
            data.lastY = currentY
        end
    end
end

-- Annoncer dans le chat
function PoucaveAlert:AnnounceMovement(playerName)
    if not CanAlert(playerName) then return end -- Anti-spam
    
    self.stats.movementAlerts = self.stats.movementAlerts + 1
    local message = playerName .. " BOUGE PENDANT SHACKLE! ⚠️"
    local channel = GetConfig("announceChannel")
    
    if channel == "RAID_WARNING" and (IsRaidLeader() or IsRaidOfficer()) then
        SendChatMessage(message, "RAID_WARNING")
    elseif channel == "RAID" and GetNumRaidMembers() > 0 then
        SendChatMessage(message, "RAID")
    elseif channel == "PARTY" and GetNumPartyMembers() > 0 then
        SendChatMessage(message, "PARTY")
    else
        -- Fallback sur le chat par défaut
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000PoucaveAlert:|r " .. message)
        RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo["RAID_WARNING"])
    end
    
    if GetConfig("debugMode") then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[ALERT]|r " .. message)
    end
end

-- Gestionnaire d'événements
function PoucaveAlert:OnEvent(event, arg1)
    if event == "PLAYER_ENTERING_WORLD" then
        self:Initialize()
        
    elseif event == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE" or
           event == "CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE" or
           event == "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE" then
        self:CheckShackleDebuff(arg1)
        
    elseif event == "CHAT_MSG_SPELL_AURA_GONE_SELF" or
           event == "CHAT_MSG_SPELL_AURA_GONE_PARTY" or
           event == "CHAT_MSG_SPELL_AURA_GONE_OTHER" then
        self:CheckShackleRemoved(arg1)
        self:CheckDispel(arg1)  -- Les dispels apparaissent aussi dans AURA_GONE
        
    elseif event == "CHAT_MSG_SPELL_BREAK_AURA" then
        self:CheckDispel(arg1)
        
    elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_RAID" or event == "CHAT_MSG_GUILD" then
        -- Détecte les messages contenant !blague
        if arg1 and string.find(arg1, "!blague") then
            local joke = GetRandomJoke()
            -- Annoncer en RAID prioritairement, sinon PARTY
            if GetNumRaidMembers() > 0 then
                SendChatMessage(joke, "RAID")
            elseif GetNumPartyMembers() > 0 then
                SendChatMessage(joke, "PARTY")
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Blague]|r " .. joke)
            end
        end
    end
end

-- Frame pour les mises à jour régulières
local updateFrame = CreateFrame("Frame", "PoucaveAlertFrame")

updateFrame:SetScript("OnEvent", function()
    PoucaveAlert:OnEvent(event, arg1)
end)

-- Initialiser l'addon
PoucaveAlert:OnLoad(updateFrame)

local timeSinceLastCheck = 0
local timeSinceLastScan = 0

updateFrame:SetScript("OnUpdate", function()
    timeSinceLastCheck = timeSinceLastCheck + arg1
    timeSinceLastScan = timeSinceLastScan + arg1
    
    -- Vérifier les mouvements
    if timeSinceLastCheck >= PoucaveAlert.checkInterval then
        PoucaveAlert:CheckMovement()
        timeSinceLastCheck = 0
    end
    
    -- Scanner les debuffs du raid
    if timeSinceLastScan >= PoucaveAlert.scanInterval then
        PoucaveAlert:ScanRaidDebuffs()
        timeSinceLastScan = 0
    end
end)

-- Commandes slash
SLASH_POUCAVEALERT1 = "/poucavealert"
SLASH_POUCAVEALERT2 = "/poucave"
SLASH_POUCAVEALERT3 = "/pa"

SlashCmdList["POUCAVEALERT"] = function(msg)
    local cmd = string.lower(msg)
    
    if cmd == "on" or cmd == "enable" then
        SetConfig("enabled", true)
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert:|r Activé")
        
    elseif cmd == "off" or cmd == "disable" then
        SetConfig("enabled", false)
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert:|r Désactivé")
        
    elseif cmd == "debug" then
        SetConfig("debugMode", not GetConfig("debugMode"))
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert:|r Mode debug " .. (GetConfig("debugMode") and "activé" or "désactivé"))
        
    elseif cmd == "sound" then
        SetConfig("soundAlert", not GetConfig("soundAlert"))
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert:|r Alertes sonores " .. (GetConfig("soundAlert") and "activées" or "désactivées"))
        
    elseif cmd == "scan" then
        SetConfig("autoScan", not GetConfig("autoScan"))
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert:|r Scan automatique " .. (GetConfig("autoScan") and "activé" or "désactivé"))
        
    elseif cmd == "dispel" then
        SetConfig("announceDispels", not GetConfig("announceDispels"))
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert:|r Annonce des dispels " .. (GetConfig("announceDispels") and "activée" or "désactivée"))
        
    elseif cmd == "test" then
        local playerName = UnitName("player")
        PoucaveAlert:AddTrackedPlayer(playerName)
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert:|r Test - Vous êtes maintenant surveillé. Bougez!")
        
    elseif cmd == "testmove" then
        local playerName = UnitName("player")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8800[MODE TEST]|r Préparation du test Shackle...")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8800[MODE TEST]|r 🚶 BOUGEZ dans 3 secondes!")
        
        -- Compte à rebours
        local countdown = 3
        local countdownFrame = CreateFrame("Frame")
        countdownFrame.timeLeft = countdown
        countdownFrame:SetScript("OnUpdate", function()
            this.timeLeft = this.timeLeft - arg1
            
            local secondsLeft = math.ceil(this.timeLeft)
            if secondsLeft <= 3 and secondsLeft > 0 and secondsLeft ~= this.lastAnnounce then
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00" .. secondsLeft .. "...|r")
                PlaySound("igQuestListComplete")
                this.lastAnnounce = secondsLeft
            end
            
            if this.timeLeft <= 0 then
                -- Activer la surveillance
                PoucaveAlert.testMode = true
                PoucaveAlert:AddTrackedPlayer(playerName)
                PoucaveAlert.testMode = false
                
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[GO!]|r Simulation Shackle ACTIVE! Bougez maintenant!")
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8800[MODE TEST]|r (Activez /pa debug pour voir les détails)")
                if GetConfig("soundAlert") then
                    PlaySound("RaidWarning")
                end
                
                this:SetScript("OnUpdate", nil)
            end
        end)
        
    elseif cmd == "reset" then
        PoucaveAlert.trackedPlayers = {}
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert:|r Liste de surveillance réinitialisée")
        
    elseif cmd == "list" or cmd == "forbidden" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert:|r Sorts à NE PAS DISPEL:")
        local bossList = {}
        for spell, info in pairs(PoucaveAlert.forbiddenDispels) do
            if not bossList[info.boss] then
                bossList[info.boss] = {}
            end
            table.insert(bossList[info.boss], {name = spell, type = info.type})
        end
        for boss, spells in pairs(bossList) do
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFAA00" .. boss .. ":|r")
            for _, spellInfo in ipairs(spells) do
                local typeColor = spellInfo.type == "Magie" and "|cFF8888FF" or (spellInfo.type == "Malédiction" and "|cFF88FF88" or "|cFFFF8888")
                DEFAULT_CHAT_FRAME:AddMessage("  - " .. spellInfo.name .. " " .. typeColor .. "(" .. spellInfo.type .. ")|r")
            end
        end
        
    elseif cmd == "status" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert:|r Status:")
        DEFAULT_CHAT_FRAME:AddMessage("  Activé: " .. (GetConfig("enabled") and "Oui" or "Non"))
        DEFAULT_CHAT_FRAME:AddMessage("  Canal: " .. GetConfig("announceChannel"))
        DEFAULT_CHAT_FRAME:AddMessage("  Son: " .. (GetConfig("soundAlert") and "Oui" or "Non"))
        DEFAULT_CHAT_FRAME:AddMessage("  Scan auto: " .. (GetConfig("autoScan") and "Oui" or "Non"))
        DEFAULT_CHAT_FRAME:AddMessage("  Annonce dispels: " .. (GetConfig("announceDispels") and "Oui" or "Non"))
        DEFAULT_CHAT_FRAME:AddMessage("  Debug: " .. (GetConfig("debugMode") and "Oui" or "Non"))
        local count = 0
        for name in pairs(PoucaveAlert.trackedPlayers) do 
            count = count + 1
            if GetConfig("debugMode") then
                DEFAULT_CHAT_FRAME:AddMessage("    - " .. name)
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage("  Joueurs surveillés: " .. count)
        
    elseif cmd == "stats" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert:|r Statistiques:")
        DEFAULT_CHAT_FRAME:AddMessage("  Shackles détectés: " .. PoucaveAlert.stats.shackleCount)
        DEFAULT_CHAT_FRAME:AddMessage("  Alertes mouvement: " .. PoucaveAlert.stats.movementAlerts)
        DEFAULT_CHAT_FRAME:AddMessage("  Dispels normaux: " .. PoucaveAlert.stats.dispelAlerts)
        DEFAULT_CHAT_FRAME:AddMessage("  Dispels interdits: " .. PoucaveAlert.stats.forbiddenDispels)
        DEFAULT_CHAT_FRAME:AddMessage("  /pa reset stats pour réinitialiser")
        
    elseif cmd == "blague" or cmd == "joke" then
        local joke = GetRandomJoke()
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Blague WoW]|r " .. joke)
        
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00PoucaveAlert|r - Commandes:")
        DEFAULT_CHAT_FRAME:AddMessage("  /pa on|off - Activer/désactiver")
        DEFAULT_CHAT_FRAME:AddMessage("  /pa debug - Toggle mode debug")
        DEFAULT_CHAT_FRAME:AddMessage("  /pa sound - Toggle alertes sonores")
        DEFAULT_CHAT_FRAME:AddMessage("  /pa scan - Toggle scan automatique")
        DEFAULT_CHAT_FRAME:AddMessage("  /pa dispel - Toggle annonce des dispels")
        DEFAULT_CHAT_FRAME:AddMessage("  /pa list - Voir les sorts interdits")
        DEFAULT_CHAT_FRAME:AddMessage("  /pa test - Tester la détection")
        DEFAULT_CHAT_FRAME:AddMessage("  /pa testmove - SIMULER Shackle et tester les mouvements")
        DEFAULT_CHAT_FRAME:AddMessage("  /pa reset - Réinitialiser la surveillance")
        DEFAULT_CHAT_FRAME:AddMessage("  /pa status - Voir le statut")
        DEFAULT_CHAT_FRAME:AddMessage("  /pa stats - Voir les statistiques")
        DEFAULT_CHAT_FRAME:AddMessage("  /pa blague - Raconter une blague WoW")
    end
end

