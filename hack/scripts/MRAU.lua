
--@enable = true
--@module = true

local eventful = require('plugins.eventful')
local dwarfmode = require('gui.dwarfmode')
local persist = require('persist-table')
local json = require('json')
local dialog = require('gui.dialogs')
local gui = require('gui')
local widgets = require('gui.widgets')
local to_pen = dfhack.pen.parse

enabled = enabled or false
function isEnabled()
    return enabled
end

-- (function definitions...)

if dfhack_flags.enable then
    if dfhack_flags.enable_state then
        start()
        enabled = true
    else
        stop()
        enabled = false
    end
end


local GLOBAL_KEY = 'MRAU'

dfhack.onStateChange[GLOBAL_KEY] = function(sc)
    if sc ~= SC_MAP_LOADED or df.global.gamemode ~= df.game_mode.DWARF then
        if reports ~= nil then persist.GlobalTable.reports = json.encode(reports) turnOffEvents() end
        
        return
    end
    --if not GAMEON then goto ENDOFSCRIPT end
    if persist.GlobalTable.reports then reports = json.decode(persist.GlobalTable.reports) else reports = {} end
    view = view and view:raise() or CPScreen{}:show()
end





--[[
Maxar's reports and units 1.1

Colors:
COLOR_RESET = -1
COLOR_BLACK = 0
COLOR_BLUE = 1
COLOR_GREEN = 2
COLOR_CYAN = 3
COLOR_RED = 4
COLOR_MAGENTA = 5
COLOR_BROWN = 6
COLOR_GREY = 7
COLOR_DARKGREY = 8
COLOR_LIGHTBLUE = 9
COLOR_LIGHTGREEN = 10
COLOR_LIGHTCYAN = 11
COLOR_LIGHTRED = 12
COLOR_LIGHTMAGENTA = 13
COLOR_YELLOW = 14
COLOR_WHITE = 15

SKILL_RATING_CATEGORY = {
  [0] = COLOR_GREY,
  [1] = COLOR_CYAN,
  [2] = COLOR_CYAN,
  [3] = COLOR_LIGHTBLUE,
  [4] = COLOR_LIGHTGREEN,
  [5] = COLOR_LIGHTGREEN,
  [6] = COLOR_LIGHTGREEN,
  [7] = COLOR_LIGHTGREEN,
  [8] = COLOR_GREEN,
  [9] = COLOR_GREEN,
  [10] = COLOR_GREEN,
  [11] = COLOR_GREEN,
  [12] = COLOR_BROWN,
  [13] = COLOR_BROWN,
  [14] = COLOR_BROWN,
  [15] = COLOR_LIGHTRED
  }

It's subjective and can vary depending on the game and its design, but a possible color scheme for skill levels in a game could be:

Not: COLOR_GREY
Novice: COLOR_GREEN
Adequate: COLOR_YELLOW
Competent: COLOR_LIGHTRED
Skilled: COLOR_RED
Proficient: COLOR_MAGENTA
Talented: COLOR_LIGHTMAGENTA
Adept




dfhack.screen.findGraphicsTile(pagename,x,y)
dfhack.screen.paintTile
gui/quickfort
gui/blueprint

UI STRUCTURE
CPScreen:ZScreen {

    icon:Panel {
    Label
    Label
    Label
  }

  MRAU_UI {
    ReportsMain:Label onClickReports 
    Label => onClickUnits()
    Label => onClickLock()
    Label => onClickSize()
    Label => onClickQuit()
    Label <= ''
    ReportsPanel:Panel {

      Panel {
        Combat:Label <= "[COMBAT]", => onClickCombat
        widgets.Label <= [CANCELATION], => onClickCancelation
        Sparring:Label <= [SPARRING], => onClickSparring 
        Important:Label => onClickImportant
        Other:Label => onClickOther
        Label <= ''
        ReportsList:Panel => render_reports
      }

      UnitSubPanels:Panel{
        UnitsPanel:Panel {
          CitizensButton:Label <= '[CITIZENS]', => onClickCitizens()
          VisitorsButton:Label <= ' VISITORS ', => onClickVisitors()
          EnemiesButton:Label <= ' ENEMIES ', => onClickEnemies()
          AnimalsButton:Label <= ' ANIMALS ', => onClickAnimals()
          Label <= ''
          UnitSubPanels:Panel{
            UnitsDetail:Panel{
              NameLabel:Label <= 'Name ,proffesion, gender', => NameClicked()
              BasicInfoLabel:Label <= 'Injured, Noble and Squad'
              GoalInfoLabel:Label <= 'job, health, military, isnoble'
              Label <= ''
              Label <= 'Appearance:'
              AppearanceContent:WrappedLabel
              Label <= SEPARATOR_HOR_LIGHT
              Label <= 'Felt:'
              ThoughtsContent:WrappedLabel
              Label <= SEPARATOR_HOR_LIGHT
              Label <= 'Skills:'
              SkillsContent:WrappedLabel
              Label <= SEPARATOR_HOR_LIGHT
            }
            UnitsList:Panel{
              Label <= 'Search:'
              SearchField:EditField
              ListOfUnits:List => onSelectedUnit()
            }
          }
        }
      }
    }
  }
}

--]]



--SOME GLOBAL TABLES
------------------------------------------------------------------------


local EVENTS_COLORS = {
  [104] = COLOR_YELLOW, --cancelation
  [256] = COLOR_GREEN,
  [301] = COLOR_LIGHTGREEN,
  [15] = COLOR_LIGHTRED,  --The NAME1 strikes at the NAME2 but the shot is deftly parried by the ­iron claymore­!
  [14] = COLOR_LIGHTRED,  --The NAME1 strikes at the NAME2 but the shot is blocked!
  [11] = COLOR_LIGHTRED,  --The NAME jumps away!
  [38] = COLOR_RED,       --The NAME1 stabs the NAME2 in the left foot with his Neuwoot Xeno Kefiht and the severed part sails off in an arc!
  [12] = COLOR_LIGHTRED,  --The NAME misses the Swordmaster!
  [8] = COLOR_LIGHTRED,
  [16] = COLOR_LIGHTRED,  --The NAME1 collides with the NAME2!
  [18] = COLOR_RED,
  [132] = COLOR_DARKGREY, --The NAME stands up.
  [123] = COLOR_DARKGREY, --The NAME is no longer stunned.
  [20] = COLOR_LIGHTRED,
  [666] = COLOR_BROWN,
  [177] = COLOR_DARKGREY, --NAME: I was attacked by the dead.  This is truly horrifying.
  [118] = COLOR_LIGHTRED,
  [43] = COLOR_LIGHTRED,
  [111] = COLOR_LIGHTRED,
  [39] = COLOR_RED,       --A tendon in the left false ribs has been torn!
  [41] = COLOR_DARKGREY,
  [9] = COLOR_DARKGREY,   --The NAME1 looks surprised by the ferocity of The NAME2 onslaught!
  [17] = COLOR_LIGHTRED,  --The NAME is knocked over and tumbles backward!
  [21] = COLOR_LIGHTRED,  --They tangle together and fall over!
  [10] = COLOR_DARKGREY,   --The NAME1 scrambles away from The flying PROJECTAL!
  [115] = COLOR_LIGHTRED,  --The NAME slams into an obstacle!
  [48] = COLOR_RED, --Forgotten beast extract is injected into the the giant cave toad's giant cave toad blood!
  [289] = COLOR_LIGHTMAGENTA, --MARIAGE
  [242] = COLOR_LIGHTGREEN, --Traders unloading
  [237] = COLOR_DARKGREY, --Proffesion change
  [106] = COLOR_MAGENTA, --DEATH
  [246] = COLOR_YELLOW, --Traders leaving
  [181] = COLOR_LIGHTMAGENTA, --Slipped into depression or Stambling obviusly
  [236] = COLOR_DARKGREY, --Proffesion change
  [263] = COLOR_LIGHTBLUE, --Mandate end
  [275] = COLOR_BLUE, --Mandate NEW!!
  [283] = COLOR_DARKGREY, --Proffesion change
  [67] = COLOR_GREEN, --Caravan arrived
  [81] = COLOR_LIGHTGREEN, --High treasurer arrived
  [244] = COLOR_RED, --wagons cant acces so bypassed
  [34] = COLOR_DARKGREY, --breaks grip of
  [45] = COLOR_LIGHTMAGENTA, --knocked unconscious
  [47] = COLOR_LIGHTMAGENTA, --gives in to pain
  [85] = COLOR_LIGHTMAGENTA, --withdraws from society
  [91] = COLOR_LIGHTMAGENTA, --claimed workshop
  [1000] = COLOR_BROWN, --CUSTOM REPORT sparing
  [86] = COLOR_MAGENTA, -- CREATED ARTIFACT
  [183] = COLOR_RED, --TANTRUM
  [126] = COLOR_DARKGREY, -- release grip
  [125] = COLOR_LIGHTMAGENTA, --gives in to pain
  [171] = COLOR_LIGHTBLUE, --Calmed down from tantrum
  [270] = COLOR_DARKGREY, --Workorder done.
  [87] = COLOR_LIGHTBLUE, --Named something
  [282] = COLOR_DARKGREY, --Proffesion change
  [341] = COLOR_LIGHTRED, --Diplomat left unhappy
  [262] = COLOR_GREEN, -- coocked masterpiece
  [294] = COLOR_LIGHTBLUE, --is started raining
  [299] = COLOR_GREEN, --Season change?
  [292] = COLOR_LIGHTBLUE, -- stopped raining
  [60] = COLOR_RED,--snacher
  [88] = COLOR_BLUE,--grown attached
  [239] = COLOR_GREEN,--gains possesion
  [6] = COLOR_DARKGREY,--pulls
  [313] = COLOR_LIGHTRED, --toppled something
  [79] = COLOR_GREEN, --diplomat arrived (diffrent race?)
  [117] = COLOR_YELLOW, --vomit
  [278] = COLOR_BLUE, --grwon to become proffesion
  [119] = COLOR_LIGHTBLUE,--regains concusines
  [107] = COLOR_MAGENTA, --found dead :C
  [150] = COLOR_RED, --DEAD WALK SCARY!!!
  [69] = COLOR_GREEN, --migrants arrived !
  [133] = COLOR_BLUE, --martial trance
  [19] = COLOR_LIGHTRED, --is knocked over
  [2] = COLOR_MAGENTA, --deep cavern underground
  [272] = COLOR_DARKGREY, --there is nothing to catch
  [5] = COLOR_GREY, --struck economic stone
  [4] = COLOR_DARKGREY, --struck stone
  [268] = COLOR_YELLOW, --construction suspended
  [29] = COLOR_LIGHTRED, --throws by bodypart
  [145] = COLOR_YELLOW, --somthing stealing something, animal? idk
  [28] = COLOR_LIGHTRED, --takes him down!
  [40] = COLOR_MAGENTA, --ENRAGE!!!
}

local EVENT_CATEGORY = {
  COMBAT = 1,
  SPARRING = 2,
  NEUTRAL = 3,
  IMPORTANT = 4
}

local EVENTS_TYPES = { --uses EVENT_CATEGORY
  [104] = EVENT_CATEGORY.NEUTRAL,
  [256] = EVENT_CATEGORY.NEUTRAL,
  [301] = EVENT_CATEGORY.NEUTRAL,
  [15] = EVENT_CATEGORY.COMBAT,  --The NAME1 strikes at the NAME2 but the shot is deftly parried by the ­iron claymore­!
  [14] = EVENT_CATEGORY.COMBAT,  --The NAME1 strikes at the NAME2 but the shot is blocked!
  [11] = EVENT_CATEGORY.COMBAT,  --The NAME jumps away!
  [38] = EVENT_CATEGORY.COMBAT,       --The NAME1 stabs the NAME2 in the left foot with his Neuwoot Xeno Kefiht and the severed part sails off in an arc!
  [12] = EVENT_CATEGORY.COMBAT,  --The NAME misses the Swordmaster!
  [8] = EVENT_CATEGORY.COMBAT,
  [16] = EVENT_CATEGORY.COMBAT,  --The NAME1 collides with the NAME2!
  [18] = EVENT_CATEGORY.COMBAT,
  [132] = EVENT_CATEGORY.COMBAT, --The NAME stands up.
  [123] = EVENT_CATEGORY.COMBAT, --The NAME is no longer stunned.
  [20] = EVENT_CATEGORY.COMBAT,
  [666] = EVENT_CATEGORY.NEUTRAL,
  [177] = EVENT_CATEGORY.COMBAT, --NAME: I was attacked by the dead.  This is truly horrifying.
  [118] = EVENT_CATEGORY.COMBAT,
  [43] = EVENT_CATEGORY.COMBAT,
  [111] = EVENT_CATEGORY.COMBAT,
  [39] = EVENT_CATEGORY.COMBAT,       --A tendon in the left false ribs has been torn!
  [41] = EVENT_CATEGORY.COMBAT, --lodged in wound
  [9] = EVENT_CATEGORY.COMBAT,   --The NAME1 looks surprised by the ferocity of The NAME2 onslaught!
  [17] = EVENT_CATEGORY.COMBAT,  --The NAME is knocked over and tumbles backward!
  [21] = EVENT_CATEGORY.COMBAT,  --They tangle together and fall over!
  [10] = EVENT_CATEGORY.COMBAT,   --The NAME1 scrambles away from The flying PROJECTAL!
  [115] = EVENT_CATEGORY.COMBAT,  --The NAME slams into an obstacle!
  [48] = EVENT_CATEGORY.COMBAT,
  [289] = EVENT_CATEGORY.IMPORTANT, --MARIAGE
  [242] = EVENT_CATEGORY.NEUTRAL, --Traders unloading
  [237] = EVENT_CATEGORY.NEUTRAL, --Proffesion change
  [106] = EVENT_CATEGORY.IMPORTANT, --DEATH
  [246] = EVENT_CATEGORY.NEUTRAL, --Traders leaving
  [181] = EVENT_CATEGORY.IMPORTANT, --Slipped into depression
  [236] = EVENT_CATEGORY.NEUTRAL, --Proffesion change
  [263] = EVENT_CATEGORY.NEUTRAL, --Mandate end
  [275] = EVENT_CATEGORY.IMPORTANT, --Mandate NEW!!
  [283] = EVENT_CATEGORY.NEUTRAL, --Proffesion change
  [67] = EVENT_CATEGORY.IMPORTANT, --Caravan arrived
  [81] = EVENT_CATEGORY.IMPORTANT, --High treasurer arrived
  [244] = EVENT_CATEGORY.IMPORTANT, --wagons cant acces so bypassed
  [34] = EVENT_CATEGORY.COMBAT, --breaks grip of
  [45] = EVENT_CATEGORY.COMBAT, --knocked unconscious
  [47] = EVENT_CATEGORY.COMBAT, --gives in to pain
  [85] = EVENT_CATEGORY.IMPORTANT, --withdraws from society
  [91] = EVENT_CATEGORY.IMPORTANT, --claimed workshop
  [1000] = EVENT_CATEGORY.SPARRING, --CUSTOM REPORT sparing
  [86] = EVENT_CATEGORY.IMPORTANT, -- CREATED ARTIFACT
  [183] = EVENT_CATEGORY.IMPORTANT, --TANTRUM
  [126] = EVENT_CATEGORY.COMBAT, -- release grip
  [125] = EVENT_CATEGORY.COMBAT, --gives in to pain
  [171] = EVENT_CATEGORY.COMBAT, --Calmed down from tantrum also exited marial trance
  [270] = EVENT_CATEGORY.NEUTRAL, --Workorder done.
  [87] = EVENT_CATEGORY.NEUTRAL, --Named something
  [282] = EVENT_CATEGORY.NEUTRAL, --Proffesion change
  [341] = EVENT_CATEGORY.IMPORTANT, --Diplomat left unhappy
  [262] = EVENT_CATEGORY.NEUTRAL, -- coocked masterpiece
  [294] = EVENT_CATEGORY.NEUTRAL, --is started raining
  [299] = EVENT_CATEGORY.IMPORTANT, --Season change?
  [292] = EVENT_CATEGORY.NEUTRAL, -- stopped raining
  [60] = EVENT_CATEGORY.IMPORTANT,--snacher
  [88] = EVENT_CATEGORY.IMPORTANT,--grown attached
  [239] = EVENT_CATEGORY.COMBAT,--gains possesion
  [6] = EVENT_CATEGORY.COMBAT, --pulls on the embedded weapon
  [313] = EVENT_CATEGORY.NEUTRAL, --toppled something
  [79] = EVENT_CATEGORY.NEUTRAL,  --diplomat arrived (diffrent race?)
  [117] = EVENT_CATEGORY.NEUTRAL, --vomit
  [278] = EVENT_CATEGORY.IMPORTANT, --grwon to become proffesion
  [119] = EVENT_CATEGORY.COMBAT,--regains concusines
  [107] = EVENT_CATEGORY.IMPORTANT, --found dead :C
  [150] = EVENT_CATEGORY.IMPORTANT, --DEAD WALK SCARY!!!
  [69] = EVENT_CATEGORY.IMPORTANT,
  [133] = EVENT_CATEGORY.COMBAT, --martial trance
  [19] = EVENT_CATEGORY.COMBAT, --is knocked over
  [2] = EVENT_CATEGORY.IMPORTANT, --deep cavern underground
  [272] = EVENT_CATEGORY.NEUTRAL, --there is nothing to catch
  [5] = EVENT_CATEGORY.NEUTRAL, --struck economic stone
  [4] = EVENT_CATEGORY.NEUTRAL,--struck stone
  [268] = EVENT_CATEGORY.NEUTRAL, --construction suspended
  [29] = EVENT_CATEGORY.COMBAT, --throws by bodypart
  [145] = EVENT_CATEGORY.NEUTRA, --somthing stealing something, animal? idk
  [28] = EVENT_CATEGORY.COMBAT, --takes him down!
  [40] = EVENT_CATEGORY.COMBAT, --ENRAGE!!!
}

THOUGHTS_WITH_HISTID = {
  [1] = "Argument",
  [2] = "NewRomance",
  [3] = "MadeFriend",
}

SKILL_RATING_CATEGORY = {
  [0] = "Not",
  [1] = "Novice",
  [2] = "Adequate",
  [3] = "Competent",
  [4] = "Skilled",
  [5] = "Proficient",
  [6] = "Talented",
  [7] = "Adept",
  [8] = "Expert",
  [9] = "Professional",
  [10] = "Accomplished",
  [11] = "Great",
  [12] = "Master",
  [13] = "High Master",
  [14] = "Grand Master",
  [15] = "Legendary"
  }

  SKILL_RATING_CATEGORY_COLOR = {
    [0] = COLOR_DARKGREY,
    [1] = COLOR_DARKGREY,
    [2] = COLOR_GREY,
    [3] = COLOR_CYAN,
    [4] = COLOR_LIGHTGREEN,
    [5] = COLOR_LIGHTGREEN,
    [6] = COLOR_LIGHTGREEN,
    [7] = COLOR_LIGHTGREEN,
    [8] = COLOR_GREEN,
    [9] = COLOR_GREEN,
    [10] = COLOR_GREEN,
    [11] = COLOR_GREEN,
    [12] = COLOR_BROWN,
    [13] = COLOR_BROWN,
    [14] = COLOR_BROWN,
    [15] = COLOR_LIGHTRED
    }
  GENDER_TEXT = {
    [-1] = "",
    [0] = "\12",
    [1] = "\11"
  }
--------------------------------------------------------------------
--FUNCTIONS
------------------------------------------------------------------------

--"AS TEXT" FUNCTIONS
------------------------------------------------------------------------
function toPenHTML(color,text_inside)
  if color ~= nil then
    return '<pen c="' ..color ..'">' ..text_inside .."</pen>"
  else return text_inside end
end

function getChecksAsText(checks) --[1] = AnimalCheck, [2] = CitizensCheck, [3] = VisitorsCheck, [4] = EnemiesCheck , [5] = HiddenCheck
  local text = "\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196"
  if checks[2] then text = text .."\196C" end
  if checks[3] then text = text .."\196V" end
  if checks[4] then text = text .."\196D" end
  if checks[1] then text = text .."\196A" end
  if checks[5] then text = text .."\196H" end
  return text
end

function getJobAsText(unit)
  if unit == nil then return "none" end
  if unit.job == nil then return "none" end
  if unit.job.current_job == nil then return "none" end

  return dfhack.job.getName(unit.job.current_job)
end

function getEmotionsAsText(unit,how_many)
  --EMOTIONS
  if #unit.status.souls <= 0 then return "No soul - no emotions :c" end --check
  how_many = how_many or 20
  emotion_text = ""
  emotions = getThoughts(unit)
  for id,item in ipairs(emotions) do
      if id > how_many then break end --check
      if item.emotion == "NOTHING" then how_many = how_many + 1 goto continue end --FELLINS check, it will not show thoughts that emotion is anything

      local felt = ""
      local cuz = " because "

      if item.fromMemory then --check memory
          cuz = " because remembered "
      end
      if item.strenght > 50 then --check strenght
          felt = ">Intense "
      end

      if isThoughtHistID(item.thought) then
        item.subthought = "with " ..getUnitName(getUnitByHistId(item.subthought)) --name of a guy
      elseif string.upper(item.subthought) ~= item.subthought and type(myVar) == 'item.subthought' then
        item.subthought = getFormatedThought(item.subthought)
      else
        item.subthought = string.lower(item.subthought)
      end

      emotionColor = getEmotionColor(item.emotion)
      emotion_text = emotion_text ..toPenHTML(emotionColor,felt ..string.lower(item.emotion)) ..cuz ..getFormatedThought(item.thought) .." " ..item.subthought .."\n"
      ::continue::
  end

  return emotion_text
end

function getSkillAsText(value)--uses SKILL_RATING_CATEGORY written by chatgpt, prat of prompt:make a function that takes skill value in number and returns skill in text following is list of numbers and what skills they represent [list from wiki same formatting]
  if value >= 15 then
    return toPenHTML(SKILL_RATING_CATEGORY_COLOR[15],SKILL_RATING_CATEGORY[15])
  else
    return toPenHTML(SKILL_RATING_CATEGORY_COLOR[value],SKILL_RATING_CATEGORY[value])
  end
end--i modified it to seperate table from function with chat gpt prompt: THATS LUA <code>function ... end</code> Make it into global table SKILL_RATING_CATEGORY and check only if its higher or equal to 15.

function getLaborsAsText(laborID)
  laborText = df.job_skill.attrs[laborID].caption_noun
  if laborText ~= nil then
    return laborText
  else
    return ""
  end
end

function getSkillsAsText(unit,how_many)
  if #unit.status.souls <= 0 then return "No soul - no skills :c" end --check
  how_many = how_many or 20
  skill_text = ""
  skills = unit.status.souls[0].skills

  skillsSorted = {} -- sorting skills based on rating
  for _,skill in ipairs(skills) do
    if skill.id ~= nil and skill.rating ~= nil then
      table.insert( skillsSorted, {id = skill.id, rating = skill.rating} )
    end
  end
  table.sort(skillsSorted, function(a, b) return a.rating > b.rating end)

  for id,skill in pairs(skillsSorted) do
      if id > how_many then break end --check
      
      skill_text = skill_text ..getSkillAsText(skill.rating) .." " ..getLaborsAsText(skill.id) .."\n"
  end

  return skill_text
end

--"IS" FUNCTIONS
------------------------------------------------------------------------

function isReportCombat(type) --uses EVENT_CATEGORY, EVENTS_TYPES
  if EVENTS_TYPES[type] == EVENT_CATEGORY.COMBAT then
    return true
  else
    return false
  end
end

function isTextNotEmpty(text) --checks does input has only spaces generated witch chatgpt
  if string.match(text, "^%s*$") then
      -- string is only spaces or empty
      return false --false when empty
  else
    return true --true when has characters another than spaces
  end
end

function isCombat(combats)
  for _,combat in pairs(combats) do
    if combat then 
      return true 
    end
  end
  return false
end

function isThoughtHistID(thought) --uses THOUGHTS_WITH_HISTID
  if thought == nil then return false end
  for _,thoughtType in pairs(THOUGHTS_WITH_HISTID) do
    if thoughtType == thought then return true end
  end
  return false
end

--GET FUNCTIONS
------------------------------------------------------------------------

function getReportColor(type) --uses EVENTS_COLORS
  if EVENTS_COLORS[type] ~= nil then
    return EVENTS_COLORS[type]
  else
    return COLOR_WHITE --not found
  end
end

function getEmotionColor(emotion)
  return df.emotion_type.attrs[emotion].color
end

function getFormatedTime(value)
  if value < 10 then
    return "0" ..value
  else
    return value
  end
end

function getCurTime()
  cur_tick = df.global.cur_year_tick
  seconds = math.floor((cur_tick / (1/72)) % 60)
  minutes = math.floor((cur_tick / (5/6)) % 60)
  hours = math.floor((cur_tick / 50) % 24)
  days = math.floor((cur_tick / 1200) % 28)
  months = math.floor((cur_tick / 33600) % 12)
  year = df.global.cur_year
  --return getFormatedTime(hours) ..":" ..getFormatedTime(minutes) .."]\196\196\196[" ..getFormatedTime(days + 1) .."." ..getFormatedTime(months + 1) .."." ..year
  return {
    hours = hours,
    minutes = minutes,
    days = days + 1,
    months = months + 1,
    years = year + 1,
    tick = cur_tick
  }
end

function getHowLongAgo(time)
  currentTick = df.global.cur_year_tick
  howLongAgo = currentTick - time.tick
  seconds = math.floor((howLongAgo / (1/72)) % 60)
  minutes = math.floor((howLongAgo / (5/6)) % 60)
  hours = math.floor((howLongAgo / 50) % 24)
  days = math.floor((howLongAgo / 1200) % 28)
  months = math.floor((howLongAgo / 33600) % 12)
  year = df.global.cur_year

  return {
    hours = hours,
    minutes = minutes,
    days = days,
    months = months,
    years = year,
    tick = currentTick
  }
end

function getUnitByHistId(id) --SPRAWDZONE DZIALA
  local hf = df.historical_figure.find(id)
  if hf then
    return df.unit.find(hf.unit_id)
  end
end

function getUnitByPos(pos)
    units = {}
    for _,unit in ipairs(df.global.world.units.active) do
      if unit.pos.x == pos.x and unit.pos.y == pos.y and unit.pos.z == pos.z then
        table.insert( units, unit )
      end
    end
    return units
end

function getUnitSquad(unit) --SPRAWDZONE DZIALA
  for _, squad in ipairs(df.global.world.squads.all) do
    if leader_assignment ~= nil then leader = getUnitByHistId(leader_assignment) else goto continue end --thats for optimalization
    if not dfhack.units.isOwnGroup(leader) then goto skip end
    ::continue::
    for i, position in ipairs(squad.positions) do
      if position.occupant == unit.hist_figure_id then
          return squad
      end
      if i > 10 then break end
    end
    ::skip::
  end
  return false
end

function getUnitsOnMap()
  --get map position and add it to filters check so only units that are on map are listed
end

function getUnitName(unit,debug)
  local name = ""
  
  debug = debug or false
  if unit == nil then return "" end
  if not dfhack.units.isAlive(unit) then name = "Dead " end
  
  if unit.name.has_name == true then
    name = dfhack.TranslateName(dfhack.units.getVisibleName(unit))
  else
    name = dfhack.units.getCasteProfessionName(unit.race,unit.caste,unit.profession)
  end
  
  if debug then
    name = name .." [" ..unit.id .."]"
    name = name .." H[" ..unit.hist_figure_id .."]"
  end
  return name
end

function getTextFirstToUpperCase(text)
  return (text:gsub("^%l", string.upper))
end

function getUnitNobleText(unit)
  noblePositions = dfhack.units.getNoblePositions(unit)
  if noblePositions == nil then return "" end

  for _,position in ipairs(noblePositions) do
    if position.position.name[0] ~= nil then return getTextFirstToUpperCase(position.position.name[0]) end
  end

  return ""
end

function getUnitByReport(report_id) --i know... a lot nesting, i wrote it before i learned a thing and now im too lazy to denest it and kinda scared cuz i dont want to break anything xD
  units = {}
  local combats = {}
  proc_of_check = 0.90
  for _,unit in ipairs(df.global.world.units.active) do
    if unit.reports.log ~= nil then
      log = unit.reports.log
      combat = nil
      
      spar = false
      if log.Sparring ~= nil and #log.Sparring > 0 then
        for i = math.floor(#log.Sparring-1 * proc_of_check), #log.Sparring-1 do
          
          if i ~= -1 and unit.reports.log.Sparring[i] ~= nil then
            if unit.reports.log.Sparring[i] == report_id then
              spar = true
              combat = false
              break
            end
          end
        end
      end

      comb = false
      if log.Combat ~= nil and #log.Combat > 0 then
        for i = math.floor(#log.Combat-1 * proc_of_check), #log.Combat-1 do
          if i ~= -1 and unit.reports.log.Combat[i] ~= nil then 
            if unit.reports.log.Combat[i] == report_id then
              comb = true
              combat = true
              break
            end
          end
        end
      end

      if (spar or comb) then
        table.insert( combats, combat )
        table.insert( units, unit )
      end
    end
  end
  return units, combats
end

function hasAllTags(tags, item) --chat gpt
    for _, tag in pairs(tags) do
        if not item[tag] then
            return false
        end
    end
    return true
end

function getTagsAsTable(Citizens, Visitors, Enemies, Animals)
  tags = {[1] = Animals, [2] = Citizens, [3] = Visitors, [4] = Enemies , [5] = false}
  local count = 0
  for _, value in pairs(tags) do
      if value == true then
          count = count + 1
      end
  end
  return tags, count
end

function getUnitChecksAsTable(unit)
  CitizensCheck = dfhack.units.isCitizen(unit)
  VisitorsCheck = dfhack.units.isVisiting(unit)
  EnemiesCheck = dfhack.units.isInvader(unit) or dfhack.units.isDanger(unit)
  AnimalCheck = dfhack.units.isAnimal(unit)
  if AnimalCheck then CitizensCheck = dfhack.units.isFortControlled(unit) end
  HiddenCheck = not dfhack.units.isVisible(unit) or dfhack.units.isHidden(unit) or dfhack.units.isDead(unit)

  return {[1] = AnimalCheck, [2] = CitizensCheck, [3] = VisitorsCheck, [4] = EnemiesCheck , [5] = HiddenCheck}
end

function isUnitValidForList(unitChecks,selectedTags,numbersOfTagsSelected) --numbersOfTagsSelected its for optimalization, i could make selectedTags and numbersOfTagsSelected global but i want to contain everything.

  local valid = true
  local tagsCounter = 0

  for i=1,#unitChecks do
    if unitChecks[i] == true and selectedTags[i] == false then valid = false end
    if unitChecks[i] == true then tagsCounter = tagsCounter + 1 end
  end
  if tagsCounter == numbersOfTagsSelected then
    return valid
  else
    return false
  end
end

function getAllUnitsForList(Citizens,Visitors,Enemies,Animals,Search)
  choices = {}
  --printall({Citizens,Visitors,Enemies,Animal,Search})
  
  --MYDEBUG (its runs once when units are preesed)
  local selectedTags, numbersOfTagsSelected = getTagsAsTable(Citizens, Visitors, Enemies, Animals)
  


  for _,unit in ipairs(df.global.world.units.active) do
      if unit == nil then goto skip end
      unitChecks = getUnitChecksAsTable(unit)

      if not isUnitValidForList(unitChecks,selectedTags,numbersOfTagsSelected) then goto skip end
      if unitChecks.Hidden then goto skip end

      local name = getUnitName(unit)

      local squad = getUnitSquad(unit)
      if squad == false then squad = "" else squad = dfhack.TranslateName(squad.name,true) end
      
      local noble = getUnitNobleText(unit)

      local proffesion = {text = dfhack.units.getProfessionName(unit), color = dfhack.units.getProfessionColor(unit)}
      if squad ~= "" then squad = " in " ..squad end 
      local filters = getChecksAsText(unitChecks)
      
      if isTextNotEmpty(Search) then
        if not string.find(dfhack.TranslateName(unit.name), Search) then goto skip end
      end
      

      health = getHealthStatus(unit)
      if health.isInjured then 
        injury = " " ..health.injuredText
      else
        injury = ""
      end

      if getJobAsText(unit) ~= "none" then
        goal = "Goal: " ..getJobAsText(unit)
      else
        goal = ""
      end

      local stress_level = dfhack.units.getStressCategory(unit) or 0
      local stress_icon = " \2 "
      if stress_level == 3 then stress_icon = " \1 " end
      choice = {
        caption = unit.id,
        text = {
          {text = stress_icon, pen = getUnitStressColor(unit)}, name .." "  ,{text = injury, pen = health.injuredPen} ,"\n " 
          ..GENDER_TEXT[unit.sex].."  ",{text = proffesion.text, pen = proffesion.color} ,{text = squad, pen = COLOR_BLUE} ,"\n" 
          .."    "..goal .."\n" 
          ..filters ..SEPARATOR_HOR_LIGHT
        }
      }

      table.insert( choices, choice )

      ::skip::
  end
  return choices
end

STRESS_COLORS = {
  [0] = COLOR_RED,--red
  [1] = COLOR_LIGHRED,--orange
  [2] = COLOR_YELLOW, --yellow
  [3] = COLOR_GREY, --grey
  [4] = COLOR_CYAN, 
  [5] = COLOR_LIGHTGREEN,
  [6] = COLOR_GREEN,
}

STRESS_TEXT = {
  [0] = "Extremely Stressed", --high stress
  [1] = "Highly Stressed",
  [2] = "Anxious",
  [3] = "Neutral",  --neutral
  [4] = "Content", 
  [5] = "Joyful",
  [6] = "Blissfully Happy", --super happy
}
function getUnitStressColor(unit)
  if unit == nil then return nil end

  local stress_level = dfhack.units.getStressCategory(unit)
  return STRESS_COLORS[stress_level]
end

function getReportById(id)
  for _,report in ipairs(df.global.world.status.reports) do
    if report.id == id then
      return report
    end
  end
end

function getScreenSize()--thats for cameraGoToPos(pos)
  return { x = df.global.world.viewport.max_x, y = df.global.world.viewport.max_y}
end

function getSyndromeType(type)
  return df.global.world.raws.syndromes.all[type]
end

function getInjuryText(unit)
  if unit.health ~= nil then
    if unit.health.flags.needs_recovery then
      return "Seriously injured"
    elseif unit.health.flags.needs_healthcare then
      return "Injured"
    end
  end
  return ""
end

function getHealthStatus(unit)
  health = {
    visionText = "",
    breathingText = "",
    injuredText = "",
    immobilizeText = "",
    visionPen = COLOR_GREY,
    breathingPen = COLOR_GREY,
    injuredPen = COLOR_GREY,
    immobilizePen = COLOR_GREY,
    isInjured = false,
  }
  if unit.health ~= nil then
    if unit.health.flags.needs_recovery then
      health.injuredText = "Seriously injured"
      health.injuredPen = COLOR_RED
      health.isInjured = true
    elseif unit.health.flags.needs_healthcare then
      health.injuredText = "Injured"
      health.injuredPen = COLOR_LIGHTRED
      health.isInjured = true
    else
      health.injuredText = "Healthy"
      health.injuredPen = COLOR_GREEN
    end
  end

  if unit.flags2.vision_missing then
    health.visionText = "Vision lost"
    health.visionPen = COLOR_RED
  elseif unit.flags2.vision_damaged then
    health.visionText = "Vision impaired"
    health.visionPen = COLOR_LIGHTRED
  else
    health.visionText = "Vision good"
    health.visionPen = COLOR_GREEN
  end

  if unit.flags2.breathing_problem then
    health.breathingText = "Breathing problem"
    health.breathingPen = COLOR_LIGHTRED
  else
    health.breathingText = "Breathing good"
    health.breathingPen = COLOR_GREEN
  end
  return health
end

function getHealthAsText(unit)
  local body = unit.body
  local health = getHealthStatus(unit)
  --local bloodProcent = math.floor((body.blood_count / body.blood_max) * 100)
  --printall(wounds[1])
  return toPenHTML(health.injuredPen,health.injuredText) .."\n" ..toPenHTML(health.breathingPen,health.breathingText) .."\n" ..toPenHTML(health.visionPen,health.visionText)
end

function getSubThought(thought,subthought) --sliczne
  if thought == df.unit_thought_type.TeachSkill or thought == df.unit_thought_type.MasterSkill or thought == df.unit_thought_type.ImproveSkill or thought == df.unit_thought_type.LearnSkill then
    return df.job_skill[subthought]
  elseif thought == df.unit_thought_type.NeedsUnfulfilled then
    return df.need_type[subthought]
  elseif thought == df.unit_thought_type.SatisfiedAtWork  then
    return df.job_type[subthought]
  elseif thought == df.unit_thought_type.AdmireBuilding or thought == df.unit_thought_type.AdmireArrangedBuilding then
    return df.building_type[subthought]
  elseif thought == df.unit_thought_type.DiscussOthersProblems or thought == df.unit_thought_type.Talked or thought == df.unit_thought_type.IntellectualDiscussion or thought == df.unit_thought_type.DiscussProblems then
    return df.unit_relationship_type[subthought]
  elseif thought == df.unit_thought_type.Syndrome then
    return getSyndromeType(subthought).syn_name
  elseif thought == df.unit_thought_type.Prayer then
    return dfhack.TranslateName(df.historical_figure.find(subthought).name,true)
  elseif thought == df.unit_thought_type.SawDeadBody then --to trzeba poprawic
    --creature = df.historical_figure.find(subthought) --df.creature_raw.find(creature.race)
    return "CORPSE"--df.creature_raw.find(creature.race).creature_id
  else
    return subthought
  end
end

function getThoughts(unit) --sliczne
  list = {}
  for id,item in ipairs(unit.status.souls[0].personality.emotions) do
    if item.year ~= df.global.cur_year then goto continue end --Only show emotions from current year
    
    if df.emotion_type[item.type] == nil then emotion = "NONE" else
        emotion = df.emotion_type[item.type]
    end

    if item.type == df.emotion_type.ANYTHING then
        emotion = "NOTHING"
    end

    subthought = ""
    if item.subthought ~= -1 and item.subthought ~= nil and getSubThought(item.thought,item.subthought) ~= nil then
        subthought = getSubThought(item.thought,item.subthought)
    end
    
    --composing
    local final = {
        id = id,
        year = item.year,
        tick = item.year_tick,
        emotion = emotion,
        thought = df.unit_thought_type[item.thought],
        subthought = subthought,
        fromMemory = item.flags.remembered_reflected_on,
        strenght = item.strength
    }

    table.insert(list,final)
    ::continue::
  end
  
  table.sort(list, function(a, b)
    return a.tick > b.tick
  end)
  return list
end

function getFormatedThought(thought)
  local formattedStr = string.sub(thought, 1, 1)
  for i = 2, #thought do
    local char = string.sub(thought, i, i)
    if string.match(char, "%u") then
      formattedStr = formattedStr .. " " .. char
    else
      formattedStr = formattedStr .. char
    end
  end
  return string.lower(formattedStr)
end --written by chatgpt with tiny naming modification prompt: LUA \n string is LuaIsFun \n make a function that put spaces between high case letter but not first and then lowers full string

function getTextWithColors(text,width,default_pen)--written by chatgpt, i changed only one thing
  local result = {}
  local default_pen = default_pen or 15
  local current_index = 1
  local pattern = "<pen c=%\"(%d+)%\">(.-)</pen>"
  while true do
      local start_index, end_index, color, extracted_text = text:find(pattern, current_index)
      if not start_index then
          -- append remaining text with default pen
          for _, textResult in ipairs(getTextFormattedNewline(text:sub(current_index),default_pen)) do
            table.insert(result, textResult)
          end

          break
      end
      -- append text before current match with default pen
      local textWithNoNewline, countOfNewlines = text:sub(current_index, start_index-1):gsub("\n", "")
      table.insert(result, {text = textWithNoNewline, pen = default_pen})
      if countOfNewlines > 0 then
        table.insert(result, '\n')
      end
      -- append current match with extracted color
      local textWithNoNewline, countOfNewlines = extracted_text:gsub("\n", "")
      table.insert(result, {text = textWithNoNewline, pen = tonumber(color)})
      if countOfNewlines > 0 then
        table.insert(result, '\n')
      end
      current_index = end_index + 1
  end
  if width == nil then
    return result
  else
    return wrapText(width,result)
  end
end

function getTextFormattedNewline(text,pen)-- i know that all of this is complicated for no reason, but it works ok? im tired of bugfixing this parsing functions no joke. also i think my lung hurts idk its very anoying to the point of crying q.q
  local parts = {}
  for match in text:gmatch("([^\n]*)\n?") do
      table.insert(parts, {text=match, pen=pen})
      table.insert(parts,'\n')
  end
  return parts
end

function wrapText(width, result) --written by chatgpt but i had to fix a lot of issues.
  local output = {}
  local line = ""
  local lineLen = 0
  local currentPen = 15
  local coloredPen = 15
  for o, res in ipairs(result) do
      if type(res) == "table" then
          local words = res.text:split(" ")
          for i, word in ipairs(words) do
              if res.pen ~= 15 then
                  coloredPen = res.pen
                  output[#output+1] = {text=line, pen=currentPen}
                  output[#output+1] = {text=word .." ", pen=coloredPen}
                  lineLen = #line + #word + 1
                  line = ""
              elseif lineLen + #word > width then
                  currentPen = res.pen
                  output[#output+1] = {text=line, pen=currentPen}
                  output[#output+1] = '\n'
                  line = word .. " "
                  lineLen = #word + 1
              else
                  line = line .. word .. " "
                  lineLen = lineLen + #word + 1
              end
          end
          currentPen = res.pen
      elseif type(res) == "string" then
          if line ~= "" then
              output[#output+1] = line
              line = ""
              lineLen = 0
          end
          output[#output+1] = res
      end
  end
  if line ~= "" then
      output[#output+1] = {text=line, pen=currentPen}
  end
  return output
end

function cameraGoToPos(pos)
  scr_size = getScreenSize()
  p = { x = math.floor(pos.x - scr_size.x / 2) , y = math.floor(pos.y - scr_size.y / 2), z = pos.z}

  df.global.window_x = p.x
  df.global.window_y = p.y
  df.global.window_z = p.z

  dwarfmode.setCursorPos(pos)
  cursorPos = pos
end

--REPORT
----------------------------------------------------------------------

function eventsEnableAll(enable,freq)
    text = "Events:"
    for id, event_type in pairs(eventful.eventType) do
      if event_type ~= 16 and event_type ~= 0 then
        if enable then
            eventful.enableEvent(event_type,freq)
            text = text .. event_type ..","
        else
            eventful.enableEvent(event_type,1000000000)
        end
      end
    end
  end

function unitsToTable(units) --sliczne
  unitsList = {}
  if units[1] == nil then return unitsList end --check

  for i,u in ipairs(units) do
      if #u.status.souls <= 0 then break end --check

      how_many = 1
      emotion_text = ""
      emotions = getThoughts(u)
      for id,item in ipairs(emotions) do
          if id > how_many then break end --check
          if item.emotion == "NOTHING" then how_many = how_many + 1 goto continue end --FELLINS check

          local felt = "felt "
          local cuz = " because "

          if item.fromMemory then --check memory
              cuz = " because remembered "
          end
          if item.strenght > 50 then --check strenght
              felt = "felt strongly "
          end
          
          emotion_text = emotion_text ..felt ..string.lower(item.emotion) ..cuz ..item.thought .." " ..item.subthought
          ::continue::
      end

      dname = ""
      if dfhack.units.isDead(u) then --dead check
          dname = dname .."Dead "
      elseif dfhack.units.isUndead(u) then --Undead check
          dname = dname .."Undead "
      end


      if not u.name.has_name then --Name check
          dname = dname ..dfhack.units.getCasteProfessionName(u.race,u.caste,u.profession)
      else
          dname = dname ..dfhack.TranslateName(u.name)
      end

      
      table.insert( unitsList, {name = dname, emotion = emotion_text, id = u.id, citizen = dfhack.units.isCitizen(u)} )
  end
  return unitsList
end

function onReport(report_id) --uses EVENTS_COLORS, EVENT_CATEGORY, EVENTS_TYPES
    local report = getReportById(report_id)
    local units, combats = getUnitByReport(report_id)
    if units[1] == nil then
      units = getUnitByPos(report.pos)
    end

    if combats[1] == nil and (EVENTS_COLORS[report.type] == COLOR_LIGHTRED or EVENTS_COLORS[report.type] == COLOR_RED) then
        return
    end

    for _,c in ipairs(combats) do
        if c == false then
            return
        end
    end

    if combats[1] == false then
      isSparing = true
    end


    r = {
      time = getCurTime(),
      type = report.type,
      text = report.text,
      pos = {x = report.pos.x, y = report.pos.y, z = report.pos.z},
      units = unitsToTable(units)
    }
    if not isCombat(combats) and EVENTS_TYPES[report.type] == EVENT_CATEGORY.COMBAT then r.type = 1000 end
    scroll_Pos_GLOBAL = 0 --PRZEWIJA DO DOLU PRZY NOWYM RAPORCIE
    table.insert( reports, r )
    --dfhack.gui.writeToGamelog() THIS U CAN USE TO WRITRE INTO GAMELOG.TXT

end


function turnOnEvents()
  eventsEnableAll(true,1)
  eventful.onReport.gamelog = onReport
end

function turnOffEvents()
  eventsEnableAll(false,1)
  eventful.onReport.gamelog = nil
end

turnOnEvents()--thats just for turning events on


-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--UI
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--REPORTS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ReportsPanel = defclass(ReportsPanel, widgets.Panel)
ReportsPanel.ATTRS {
  focus_path='ReportsPanel',
  frame_title="Maxar's reports and units ui",
  drag_anchors={frame=true, body=false},
  frame={},
}

function ReportsPanel:init(info)
    self:addviews{
        widgets.Panel{
          frame={t=0, l=0},
          auto_height = true,
          auto_width = true,
          subviews={
            widgets.Label{
                view_id='Combat',
                visible = true,
                frame={t=0, l=0},
                auto_width = true,
                text_pen = to_pen(COLOR_LIGHTGREEN),
                text_hpen = to_pen(COLOR_GREEN),
                text={
                    {text=' COMBAT '},
                },
                on_click = self:callback('onClickCombat')
              },
              widgets.Label{
                view_id='Cancelation',
                visible = true,
                frame={t=0, l=14},
                auto_width = true,
                text_pen = to_pen(COLOR_LIGHTGREEN),
                text_hpen = to_pen(COLOR_GREEN),
                text={
                    {text=' CANCELATION '},
                },
                on_click = self:callback('onClickCancelation')
              },
              widgets.Label{
                view_id='Sparring',
                visible = true,
                frame={t=0, l=34},
                auto_width = true,
                text_pen = to_pen(COLOR_LIGHTGREEN),
                text_hpen = to_pen(COLOR_GREEN),
                text={
                    {text=' SPARRING '},
                },
                on_click = self:callback('onClickSparring')
              },
              widgets.Label{
                view_id='Important',
                visible = true,
                frame={t=0, l=50},
                auto_width = true,
                text_pen = to_pen(COLOR_LIGHTGREEN),
                text_hpen = to_pen(COLOR_GREEN),
                text={
                    {text=' IMPORTANT '},
                },
                on_click = self:callback('onClickImportant')
              },
              widgets.Label{
                view_id='Other',
                visible = true,
                frame={t=0, l=70},
                auto_width = true,
                text_pen = to_pen(COLOR_LIGHTGREEN),
                text_hpen = to_pen(COLOR_GREEN),
                text={
                    {text=' OTHER '},
                },
                on_click = self:callback('onClickOther')
              },
              widgets.Label{
                visible = true,
                frame={t=1, l=0},
                auto_width = true,
                text={
                    {text=''},
                },
              },
              widgets.Panel{
                view_id='ReportsList',
                on_render=self:callback('render_reports'),
                visible = true,
                frame={t=2, l=0},
                auto_height = true,
                auto_width = true,
              },
          }
      }
    }
end

function ReportsPanel:onInput(keys)
  x, y = self.parent_view:getMousePos()
  --printall(self.parent_view.parent_view.subviews.turnOnEvents)
  if y ~= nil and y > 3 and keys._MOUSE_L_DOWN then --tutaj jest ktore klawisze sa blokowane
    local pos
    if self.subviews.ReportsList.frame.t ~= nil then y = y - self.subviews.ReportsList.frame.t end --poprawka na t paneli id:ReportsList
    if positions_GLOBAL[y] ~= nil then pos = positions_GLOBAL[y] end  
    if units_ids_GLOBAL[y] ~= nil then if df.unit.find(units_ids_GLOBAL[y]) ~= nil then pos = df.unit.find(units_ids_GLOBAL[y]).pos selectedUnitOutsideTheList = units_ids_GLOBAL[y] selectChange = true end end
    if pos ~= nil and pos.x > -1000 and keys._MOUSE_L_DOWN then cameraGoToPos(pos) end

    return true
  end

  if y ~= nil and y > 3 and (keys.CONTEXT_SCROLL_UP or keys.CONTEXT_SCROLL_DOWN) then
    if keys.CONTEXT_SCROLL_UP then scroll_Pos_GLOBAL = scroll_Pos_GLOBAL + 2  end
    if keys.CONTEXT_SCROLL_DOWN and scroll_Pos_GLOBAL > 1 then scroll_Pos_GLOBAL = scroll_Pos_GLOBAL - 2 end
    return true
  end


  --print(scroll_Pos_GLOBAL)
  
  return ReportsPanel.super.onInput(self, keys) --GO BACK HERE
end

--SUB TABS
doesCombat = true
function ReportsPanel:onClickCombat()
  
  if doesCombat then 
    doesCombat = false 
    self.subviews.Combat.text_pen = to_pen(COLOR_GREY)
    self.subviews.Combat.text_hpen = to_pen(COLOR_LIGHTGREEN)
    
  else 
    doesCombat = true
    self.subviews.Combat.text_pen = to_pen(COLOR_LIGHTGREEN)
    self.subviews.Combat.text_hpen = to_pen(COLOR_GREEN)
  end
end

doesCancelation = true
function ReportsPanel:onClickCancelation()
  
  if doesCancelation then 
    doesCancelation = false 
    self.subviews.Cancelation.text_pen = to_pen(COLOR_GREY)
    self.subviews.Cancelation.text_hpen = to_pen(COLOR_LIGHTGREEN)
  else 
    doesCancelation = true
    self.subviews.Cancelation.text_pen = to_pen(COLOR_LIGHTGREEN)
    self.subviews.Cancelation.text_hpen = to_pen(COLOR_GREEN)
  end
end

doesSparring = true
function ReportsPanel:onClickSparring()
  
  if doesSparring then 
    doesSparring = false 
    self.subviews.Sparring.text_pen = to_pen(COLOR_GREY)
    self.subviews.Sparring.text_hpen = to_pen(COLOR_LIGHTGREEN)
  else 
    doesSparring = true
    self.subviews.Sparring.text_pen = to_pen(COLOR_LIGHTGREEN)
    self.subviews.Sparring.text_hpen = to_pen(COLOR_GREEN)
  end
end

doesImportant = true
function ReportsPanel:onClickImportant()
  if doesImportant then 
    doesImportant = false 
    self.subviews.Important.text_pen = to_pen(COLOR_GREY)
    self.subviews.Important.text_hpen = to_pen(COLOR_LIGHTGREEN)
  else 
    doesImportant = true
    self.subviews.Important.text_pen = to_pen(COLOR_LIGHTGREEN)
    self.subviews.Important.text_hpen = to_pen(COLOR_GREEN)
  end
end

doesOther = true
function ReportsPanel:onClickOther()
  if doesOther then 
    doesOther = false 
    self.subviews.Other.text_pen = to_pen(COLOR_GREY)
    self.subviews.Other.text_hpen = to_pen(COLOR_LIGHTGREEN)
  else 
    doesOther = true
    self.subviews.Other.text_pen = to_pen(COLOR_LIGHTGREEN)
    self.subviews.Other.text_hpen = to_pen(COLOR_GREEN)
  end
end

--REPORT LIST
------------------------------------------------------------------------------------------------------------------------------------------------------

units_ids_GLOBAL = {}
positions_GLOBAL = {}
scroll_Pos_GLOBAL = 0
SEPARATOR_HOR_LIGHT = "\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196"
function ReportsPanel:render_reports(dc) --uses EVENT_CATEGORY, EVENTS_TYPES yea thats huge ass function and i could probably break it into small pices but im too lazy xD
  local start = self.frame_body.height - 3
  --FORMATING
  blocks = {}
  for i,report in pairs(reports) do
    lines = {}
    units_ids = {}

    local how_long_ago_time = getHowLongAgo(report.time)
    local how_long_ago_text = {months = "",days = "", hours = ""}
    local ago = ""
    if how_long_ago_time.months ~= 0 then how_long_ago_text.months = tostring(how_long_ago_time.months) .."\196months" end
    if how_long_ago_time.days ~= 0 then how_long_ago_text.days = tostring(how_long_ago_time.days) .."\196days" end
    if how_long_ago_time.hours ~= 0 then how_long_ago_text.hours = tostring(how_long_ago_time.hours) .."\196hours" end
    if how_long_ago_time.months == 0 and how_long_ago_time.days == 0 and how_long_ago_time.hours == 0 then 
      ago = "now"
    else
      ago = "\196ago"
    end
    lines[1] = {text = "\196" ..how_long_ago_text.months .."\196" ..how_long_ago_text.days .."\196" ..how_long_ago_text.hours ..ago .."\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196[" ..getFormatedTime(report.time.hours) ..":" ..getFormatedTime(report.time.minutes) .."]\196\196\196[" ..getFormatedTime(report.time.days) .."." ..getFormatedTime(report.time.months) .."." ..report.time.years .."]\196" .."[" ..report.type .."]"..SEPARATOR_HOR_LIGHT,
    color = COLOR_WHITE}

    lines[2] = {text = " "..report.text, color = getReportColor(report.type)}
    lcount = 3
    for o,unit in pairs(report.units) do
      if unit.name == "" then goto skip end

      if unit.citizen then--JAK CITIZEN TO INNY KOLOR
        lines[lcount] = {text = "  "..unit.name .." " ..unit.emotion, color = COLOR_LIGHTGREEN}
      else
        lines[lcount] = {text = "  "..unit.name .." " ..unit.emotion, color = COLOR_GREY}
      end

      units_ids[lcount] = unit.id
      lcount = lcount + 1
      ::skip::
    end
    lines[lcount] = {text = "", color = COLOR_GREY}
    
    local block = {
      report = report,
      lines = lines,
      units_ids = units_ids
    }
    table.insert( blocks, block )
  end

  

  --DISPLAYING
  space = 0
  galaxy = 0
  startLine = self.frame.t
  units_ids_GLOBAL = {} --ZEROWANIE
  positions_GLOBAL = {} --ZEROWANIE
  for i,block in pairs(blocks) do
    if isReportCombat(block.report.type) and not doesCombat then goto typeSkip1 end--skipowanie walki
    if block.report.type == 104 and not doesCancelation then goto typeSkip1 end--skipowanie CANCELATION s
    if block.report.type == 1000 and not doesSparring then goto typeSkip1 end --skipowanie sparringu
    if EVENTS_TYPES[block.report.type] == EVENT_CATEGORY.IMPORTANT and not doesImportant then goto typeSkip1 end --skipowanie important

    if block.report.type ~= 104 and not isReportCombat(block.report.type) and block.report.type ~= 1000 and EVENTS_TYPES[block.report.type] ~= EVENT_CATEGORY.IMPORTANT and not doesOther then goto typeSkip1 end--skipowanie wszystkiego innego

    galaxy = galaxy + #block.lines
    ::typeSkip1::
  end
  galaxy = start - galaxy + scroll_Pos_GLOBAL
  for i,block in pairs(blocks) do
    if isReportCombat(block.report.type) and not doesCombat then goto typeSkip2 end --skipowanie walki
    if block.report.type == 104 and not doesCancelation then goto typeSkip2 end --skipowanie CANCELATION s
    if block.report.type == 1000 and not doesSparring then goto typeSkip2 end --skipowanie sparringu
    if EVENTS_TYPES[block.report.type] == EVENT_CATEGORY.IMPORTANT and not doesImportant then goto typeSkip2 end --skipowanie important

    if block.report.type ~= 104 and not isReportCombat(block.report.type) and block.report.type ~= 1000 and EVENTS_TYPES[block.report.type] ~= EVENT_CATEGORY.IMPORTANT and not doesOther then goto typeSkip2 end --skipowanie wszystkiego innego

    for o,line in pairs(block.lines) do
      y = space + o
      dc:seek(0, y + galaxy):pen(to_pen{fg=line.color, bg=COLOR_BLACK})
      dc:advance(self.text_offset):string(line.text)--"i:" ..i .." o:" ..o .." y:" ..y .." "..
      if block.units_ids[o] ~= nil then units_ids_GLOBAL[y + galaxy + startLine] = block.units_ids[o] end --Do klikania w jednoskte
      if o == 2 and block.report.pos ~= nil then positions_GLOBAL[y + galaxy + startLine] = block.report.pos end
    end
    space = space + #block.lines
    ::typeSkip2::
  end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--UNITS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UnitsPanel = defclass(UnitsPanel, widgets.Panel)
UnitsPanel.ATTRS {
  focus_path='UnitsPanel',
  drag_anchors={frame=true, body=false},
  frame={},
  autoarrange_subviews = true,
}

function UnitsPanel:init(info)
    self:addviews{
        widgets.Panel{
          frame={t=0, l=0},
          auto_height = true,
          auto_width = true,
          subviews={
            widgets.Label{
                view_id='CitizensButton',
                visible = true,
                frame={t=0, l=0},
                auto_width = true,
                text_pen = to_pen(COLOR_LIGHTGREEN),
                text_hpen = to_pen(COLOR_GREEN),
                text={
                    {text=' CITIZENS '},
                },
                on_click = self:callback('onClickCitizens')
              },
              widgets.Label{
                view_id='VisitorsButton',
                visible = true,
                frame={t=0, l=14},
                auto_width = true,
                text_pen = to_pen(COLOR_GREY),
                text_hpen = to_pen(COLOR_LIGHTGREEN),
                text={
                    {text=' VISITORS '},
                },
                on_click = self:callback('onClickVisitors')
              },
              widgets.Label{
                view_id='EnemiesButton',
                visible = true,
                frame={t=0, l=28},
                auto_width = true,
                text_pen = to_pen(COLOR_GREY),
                text_hpen = to_pen(COLOR_LIGHTGREEN),
                text={
                    {text=' DANGERS '},
                },
                on_click = self:callback('onClickEnemies')
              },
              widgets.Label{
                view_id='AnimalsButton',
                visible = true,
                frame={t=0, l=42},
                auto_width = true,
                text_pen = to_pen(COLOR_GREY),
                text_hpen = to_pen(COLOR_LIGHTGREEN),
                text={
                    {text=' ANIMALS '},
                },
                on_click = self:callback('onClickAnimals')
              },
              widgets.Label{
                visible = true,
                frame={t=1, l=0},
                auto_width = true,
                text_pen = to_pen(COLOR_GREY),
                text_hpen = to_pen(COLOR_LIGHTGREEN),
                text={
                    {text=''},
                },
              },
              widgets.Panel{
                view_id='UnitSubPanels',
                visible = true,
                frame={t=2, l=0},
              },
          }
      }
    }

    self.subviews.UnitSubPanels:addviews{
      UnitsDetail{view_id='UnitsDetail',frame={r = 41}},--change name to joffrey
      UnitsList{view_id='UnitsList',frame={w = 40, r = 0}},
    }
    --self.subviews.UnitSubPanels.subviews.UnitsDetail.frame.w
    
end

function UnitsPanel:onRenderFrame(dc, rect)
  paint_vertical_border(dc, {t = 3, r = 40, b = -1},nil,{Split = {top = dfhack.pen.parse{tile=921, ch=204, fg=COLOR_GREY, bg=COLOR_BLACK}}})
end

function UnitsPanel:onInput(keys)
  --x, y = self.parent_view:getMousePos()-- scroll block add settings
  --if y ~= nil and (keys.CONTEXT_SCROLL_DOWN or keys.CONTEXT_SCROLL_UP) then return true end

  return UnitsPanel.super.onInput(self, keys)
end

--SUB TABS
doesUpdateList = true

doesCitizens = true
function UnitsPanel:onClickCitizens()
  doesUpdateList = true
  if doesCitizens then 
    doesCitizens = false 
    self.subviews.CitizensButton.text_pen = to_pen(COLOR_GREY)
    self.subviews.CitizensButton.text_hpen = to_pen(COLOR_LIGHTGREEN)
  else 
    doesCitizens = true
    self.subviews.CitizensButton.text_pen = to_pen(COLOR_LIGHTGREEN)
    self.subviews.CitizensButton.text_hpen = to_pen(COLOR_GREEN)
  end
end

doesVisitors = false
function UnitsPanel:onClickVisitors()
  doesUpdateList = true
  if doesVisitors then 
    doesVisitors = false 
    self.subviews.VisitorsButton.text_pen = to_pen(COLOR_GREY)
    self.subviews.VisitorsButton.text_hpen = to_pen(COLOR_LIGHTGREEN)
  else 
    doesVisitors = true
    self.subviews.VisitorsButton.text_pen = to_pen(COLOR_LIGHTGREEN)
    self.subviews.VisitorsButton.text_hpen = to_pen(COLOR_GREEN)
  end
end

doesEnemies = false
function UnitsPanel:onClickEnemies()
  doesUpdateList = true
  if doesEnemies then 
    doesEnemies = false 
    self.subviews.EnemiesButton.text_pen = to_pen(COLOR_GREY)
    self.subviews.EnemiesButton.text_hpen = to_pen(COLOR_LIGHTGREEN)
  else 
    doesEnemies = true
    self.subviews.EnemiesButton.text_pen = to_pen(COLOR_LIGHTGREEN)
    self.subviews.EnemiesButton.text_hpen = to_pen(COLOR_GREEN)
  end
end

doesAnimals = false
function UnitsPanel:onClickAnimals()
  doesUpdateList = true
  if doesAnimals then 
    doesAnimals = false 
    self.subviews.AnimalsButton.text_pen = to_pen(COLOR_GREY)
    self.subviews.AnimalsButton.text_hpen = to_pen(COLOR_LIGHTGREEN)
  else 
    doesAnimals = true
    self.subviews.AnimalsButton.text_pen = to_pen(COLOR_LIGHTGREEN)
    self.subviews.AnimalsButton.text_hpen = to_pen(COLOR_GREEN)
  end
end

--UNIT DETAIL
--------------------------------------------------------------------------------------------
UnitsDetail = defclass(UnitsDetail, widgets.Panel)
UnitsDetail.ATTRS {
  focus_path='UnitsDetail',
  drag_anchors={frame=false, body=false},
  autoarrange_subviews = true
}

function UnitsDetail:init(info)
    self:addviews{
      widgets.Label{
        view_id='NameLabel',
        visible = true,
        frame={t=0, l=0},
        text={
            {text='Name ,proffesion, gender'},--Name ,proffesion, gender
        },
        on_click = self:callback('NameClicked')
      },
      widgets.Label{
        view_id='BasicInfoLabel',
        visible = true,
        frame={t=1, l=0},
        text={
            {text='Injured, Noble and Squad'},
        },
        --on_render = self:callback('render_unitdet')
      },
      widgets.Label{
        view_id='GoalInfoLabel',
        visible = true,
        frame={t=1, l=0},
        text={
            {text='job, health, military, isnoble'},
        },
        on_click = self:callback('GoalClicked')
        --on_render = self:callback('render_unitdet')
      },
      widgets.Label{
        visible = true,
        frame={t=14, r=1, w = 6},
        text={
            {text='follow'},
        },
        on_click = self:callback('FollowClicked')
      },
      widgets.Label{
        visible = true,
        frame={t=3, l=0},
        text={
            {text="Felt:"},
        },
      },
      widgets.Label{
        view_id='ThoughtsContent',
        visible = true,
        auto_height = false,
        frame={t=4, l=1, h = 15},
      },
      widgets.Label{
        visible = true,
        frame={t=38, l=0},
        text={
            {text=SEPARATOR_HOR_LIGHT},
        },
      },
      widgets.Label{
        visible = true,
        frame={t=39, l=0},
        text={
            {text="Skills:"},
        },
      },
      widgets.Label{
        view_id='SkillsContent',
        visible = true,
        auto_height = false,
        frame={t=40, l=1, h = 15},
      },
      widgets.Label{
        visible = true,
        frame={t=38, l=0},
        text={
            {text=SEPARATOR_HOR_LIGHT},
        },
      },
      widgets.Label{
        visible = true,
        frame={t=39, l=0},
        text={
            {text="Health:"},
        },
      },
      widgets.Label{
        view_id='HealthContent',
        visible = true,
        auto_height = false,
        frame={t=40, l=1, h = 3},
        text_to_wrap="",
      },
      widgets.Label{
        visible = true,
        frame={t=2, l=0},
        text={
            {text=SEPARATOR_HOR_LIGHT},
        },
      },
      widgets.Label{
        visible = true,
        frame={t=15, l=0},
        text={
            {text="Appearance:"},
        },
      },
      widgets.Label{
        view_id='AppearanceContent',
        visible = true,
        auto_height = false,
        frame={t=0, l=1,},
        text=getTextWithColors("Unfortunately, it is currently not possible to script\nthe appearance menu within the current state of DFHack.\nThis limitation is a result of technical constraints \nwithin the software and may be subject to change \nin future updates.\n",
        nil,COLOR_GREY)
      },
      
    }

    
end
FOLLOWUNIT = nil
function UnitsDetail:FollowClicked()
  local unit = df.unit.find(selectedUnitInList)
  if unit == nil then return end

  FOLLOWUNIT = unit
end

selectedUnitInList = 0
selectedUnitOutsideTheList = 0
--BACKTOREPORTS = false --for detection if unit in reports was clicked and then u can right click to go back to reports
function UnitsDetail:NameClicked()
  local unit = df.unit.find(selectedUnitInList)
  if unit == nil then return end
  cameraGoToPos(unit.pos)
end

function UnitsDetail:GoalClicked()
  local unit = df.unit.find(selectedUnitInList)
  if unit.job.current_job == nil then return end
  cameraGoToPos(unit.job.current_job.pos)
end

function getFortressUnits() --SPRAWDZONE DZIALA
  local unitList = {}
  for _,unit in ipairs(df.global.world.units.active) do
    if dfhack.units.isCitizen(unit) then
        table.insert( unitList, unit )
    end
  end
  return unitList
end

local selectChange = true
function UnitsDetail:onRenderFrame(dc)

  if FOLLOWUNIT ~= nil then
    cameraGoToPos(FOLLOWUNIT.pos)
  end

  --autorefresh
  if not selectChange then
    local time = df.global.cur_year_tick
    if time % 600 == 0 then
      selectChange = true
    end
  end

  
  paint_horizontal_border(dc, {t = 3, l = -1, r = 40},nil,{Split = {right = dfhack.pen.parse{tile=918, ch=204, fg=COLOR_GREY, bg=COLOR_BLACK}}})

  if not selectChange then return end
  selectChange = false

  if selectedUnitOutsideTheList ~= 0 then
    selectedUnitInList =  selectedUnitOutsideTheList
    selectedUnitOutsideTheList = 0
  end

  local unit = df.unit.find(selectedUnitInList)
  if unit == nil then return end
  --print("---------------------------------------------|")

  --print(getHealthToText(unit))
  local prof = getTextWithColors(dfhack.units.getProfessionName(unit),nil,dfhack.units.getProfessionColor(unit))[1]
  self.subviews.NameLabel:setText({getUnitName(unit,false) .." " ..GENDER_TEXT[unit.sex] .." ",prof})
  self.subviews.BasicInfoLabel:setText({{text = STRESS_TEXT[dfhack.units.getStressCategory(unit)], pen = getUnitStressColor(unit)}})
  --printall({text = STRESS_TEXT[dfhack.units.getStressCategory(unit)], pen = getUnitStressColor(unit)})
  self.subviews.GoalInfoLabel:setText("Current goal: " ..getJobAsText(unit))
  self.subviews.SkillsContent:setText(getTextWithColors(getSkillsAsText(unit)))
  --printall(getEmotionsAsText(unit,how_many))
  self.subviews.ThoughtsContent:setText(getTextWithColors(getEmotionsAsText(unit,20)))
  

  self.subviews.HealthContent:setText(getTextWithColors(getHealthAsText(unit)))
  self:updateLayout()

end


--UNIT LIST
----------------------------------------------------------------------------------------------
UnitsList = defclass(UnitsList, widgets.Panel)
UnitsList.ATTRS {
  focus_path='UnitsList',
  drag_anchors={frame=false, body=false},
  autoarrange_subviews = false,
}

function UnitsList:init(info)
    self:addviews{
      widgets.EditField{
        view_id='SearchField',
        visible = true,
        frame={t=0, l=0},
        label_text = "Search:",
        text= "",
        text_pen = to_pen{fg=15, bg=0},
        frame_background = to_pen{ch='\250', fg=COLOR_DARKGRAY, bg=0},
      },
      widgets.Label{
        view_id='updateLabel',
        visible = true,
        frame={t=2, r=1, w=7},
        text= "refresh",
        on_click= self:callback('onClickUpdate')
      },
      widgets.List{
        view_id='ListOfUnits',
        visible = true,
        text_pen = to_pen(COLOR_CYAN),
        cursor_pen = to_pen(COLOR_WHITE),
        row_height = 4,
        frame={t=3, l=0},
        on_select = self:callback('onSelectedUnit')
      }
    }
end

--local tickUnitsList = 0
--function UnitsList:postComputeFrame() --auto update
--  if tickUnitsList % 1 then
--    choices = getAllUnitsForList(doesCitizens,doesVisitors,doesEnemies)
--    self.subviews.ListOfUnits:setChoices(choices,1)
--  end
--  tickUnitsList = tickUnitsList + 1
--end

function UnitsList:onInput(keys)
  
  if keys._MOUSE_L_DOWN then
    x, y = self.parent_view.subviews.SearchField:getMousePos() -- focus on search
    if y ~= nil then 
      self.parent_view.subviews.SearchField:setFocus(true)
      self.parent_view.subviews.SearchField.frame_background = to_pen{ch='\250', fg=COLOR_DARKGRAY, bg=0}
      self.parent_view.subviews.SearchField.text_pen = to_pen{fg=15, bg=0}
    else
      self.parent_view.subviews.SearchField:setFocus(false)
      self.parent_view.subviews.SearchField.frame_background = to_pen{ch=' ', fg=COLOR_DARKGRAY, bg=0}
      self.parent_view.subviews.SearchField.text_pen = to_pen{fg=15, bg=0}
    end
  end

  
  
  
  if keys.SELECT then
    doesUpdateList = true
  end

  if UnitsList.super.onInput(self, keys) then return true end
end

function UnitsList:onRenderFrame(dc, rect) --auto update
  paint_horizontal_border(dc, {t = 2, l = -1, r = -1},rect,{Split = {left = dfhack.pen.parse{tile=919, ch=204, fg=COLOR_GREY, bg=COLOR_BLACK}}})

  if doesUpdateList then
    choices = getAllUnitsForList(doesCitizens,doesVisitors,doesEnemies,doesAnimals,self.parent_view.subviews.SearchField.text)
    self.parent_view.subviews.ListOfUnits:setChoices(choices,1)
    doesUpdateList = false
  end
end

function UnitsList:onSelectedUnit(idx, option)
  if option == nil then return end
  selectedUnitInList = tonumber(option.caption)
  selectChange = true
end

function UnitsList:onClickUpdate()
  doesUpdateList = true
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--MAIN UI
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FRAME_STYLE = {
  frame_pen = to_pen{ ch=206, fg=COLOR_LIGHTGREEN, bg=COLOR_BLACK },
  t_frame_pen = to_pen{ tile=902, ch=205, fg=COLOR_GREY, bg=COLOR_BLACK },
  l_frame_pen = to_pen{ tile=908, ch=186, fg=COLOR_GREY, bg=COLOR_BLACK },
  b_frame_pen = to_pen{ tile=916, ch=205, fg=COLOR_GREY, bg=COLOR_BLACK },
  r_frame_pen = to_pen{ tile=910, ch=186, fg=COLOR_GREY, bg=COLOR_BLACK },
  lt_frame_pen = to_pen{ tile=901, ch=201, fg=COLOR_GREY, bg=COLOR_BLACK },
  lb_frame_pen = to_pen{ tile=915, ch=200, fg=COLOR_GREY, bg=COLOR_BLACK },
  rt_frame_pen = to_pen{ tile=903, ch=187, fg=COLOR_GREY, bg=COLOR_BLACK },
  rb_frame_pen = to_pen{ tile=917, ch=188, fg=COLOR_GREY, bg=COLOR_BLACK },
}

MRAU_UI = defclass(MRAU_UI, widgets.Window)
MRAU_UI.ATTRS {
  focus_path='MRAU_UI',
  frame_title="Maxar's reports and units ui",
  frame_style= FRAME_STYLE,
  frame_inset = 0,
  drag_anchors={frame=true, body=false},
  frame={w=100, h=60},
  resizable = true,
  resize_min={w = 80, h = 10},
  view_id='MainWindow',
}

function MRAU_UI:init(info)
    self:addviews{
        widgets.Label{
            view_id='ReportsMain',
            frame={t=0, l=0},
            auto_width = true,
            text_pen = to_pen(COLOR_LIGHTGREEN),
            text_hpen = to_pen(COLOR_GREEN),
            text={
                {text=' REPORTS '},
            },
            on_click = self:callback('onClickReports')
        },
        widgets.Label{
          view_id='UnitsMain',
          frame={t=0, l=14},
          auto_width = true,
          text_pen = to_pen(COLOR_GREY),
          text_hpen = to_pen(COLOR_LIGHTGREEN),
          text={
              {text=' UNITS '},
          },
          on_click = self:callback('onClickUnits')
        },
        widgets.Label{
          view_id='LockMain',
          frame={t=0, r=9},
          auto_width = true,
          text_pen = to_pen(COLOR_GREY),
          text_hpen = to_pen(COLOR_LIGHTGREEN),
          text={
              {text='[l]'},
          },
          on_click = self:callback('onClickLock')
      },
        widgets.Label{
            view_id='SizeMain',
            frame={t=0, r=6},
            auto_width = true,
            text_pen = to_pen(COLOR_GREY),
            text_hpen = to_pen(COLOR_LIGHTGREEN),
            text={
                {text='[^]'},
            },
            on_click = self:callback('onClickSize')
        },
        widgets.Label{
            frame={t=0, r=0},
            auto_width = true,
            text_pen = to_pen(COLOR_GREY),
            text_hpen = to_pen(COLOR_LIGHTGREEN),
            text={
                {text='[X]'},
            },
            on_click = self:callback('onClickQuit')
        },
        widgets.Label{
          visible = true,
          frame={t=1, l=0},
          auto_width = true,
          text_pen = to_pen(COLOR_GREY),
          text_hpen = to_pen(COLOR_LIGHTGREEN),
          text={
              {text = ''},
          }
        },
        ReportsPanel{
          view_id='ReportsPanel',
          frame={t=2, r=0},
          visible = true,
        },
        UnitsPanel{
          view_id='UnitsPanel',
          frame={t=2, r=0},
          visible = false,
        },
    }
end


--MAIN TABS
function MRAU_UI:onClickReports()
  self.subviews.ReportsPanel.visible = true
  self.subviews.UnitsPanel.visible = false

  self.subviews.ReportsMain.text_pen = to_pen(COLOR_LIGHTGREEN)
  self.subviews.ReportsMain.text_hpen = to_pen(COLOR_GREEN)

  self.subviews.UnitsMain.text_pen = to_pen(COLOR_GREY)
  self.subviews.UnitsMain.text_hpen = to_pen(COLOR_LIGHTGREEN)
end
function MRAU_UI:onClickUnits()
  self.subviews.ReportsPanel.visible = false
  self.subviews.UnitsPanel.visible = true
  selectChange = true
  self.subviews.ReportsMain.text_pen = to_pen(COLOR_GREY)
  self.subviews.ReportsMain.text_hpen = to_pen(COLOR_LIGHTGREEN)

  self.subviews.UnitsMain.text_pen = to_pen(COLOR_LIGHTGREEN)
  self.subviews.UnitsMain.text_hpen = to_pen(COLOR_GREEN)
end

doesSizeMain = false
function MRAU_UI:onClickSize()
  if doesSizeMain then
    self.frame.h = 60
    self.subviews.SizeMain:setText("[^]")
    self.subviews.SizeMain.text_pen = to_pen(COLOR_GREY)
    self.subviews.SizeMain.text_hpen = to_pen(COLOR_LIGHTGREEN)
    self:updateLayout()
    doesSizeMain = false
  else
    self.frame.h = 17
    self.subviews.SizeMain:setText("[V]")
    self.subviews.SizeMain.text_pen = to_pen(COLOR_LIGHTGREEN)
    self.subviews.SizeMain.text_hpen = to_pen(COLOR_GREEN)
    self:updateLayout()
    doesSizeMain = true
  end
end

doesLockMain = false
function MRAU_UI:onClickLock()
  if doesLockMain then
    self.subviews.LockMain:setText("[l]")
    self.subviews.LockMain.text_pen = to_pen(COLOR_GREY)
    self.subviews.LockMain.text_hpen = to_pen(COLOR_LIGHTGREEN)
    doesLockMain = false
  else
    self.subviews.LockMain:setText("[L]")
    self.subviews.LockMain.text_pen = to_pen(COLOR_LIGHTGREEN)
    self.subviews.LockMain.text_hpen = to_pen(COLOR_GREEN)
    doesLockMain = true
  end
end
--function MRAU_UI:onClickMinimalize()
--  CPScreen:Minimalize(keys)
--end

function MRAU_UI:onRenderFrame(dc, rect)
  MRAU_UI.super.onRenderFrame(self, dc, rect)
    if not self.frame_style then return end
    local locked = nil
    if self.lockable then
        locked = self.parent_view and self.parent_view.locked
    end
    local inactive = self.parent_view and self.parent_view.isOnTop
            and not self.parent_view:isOnTop()
    gui.paint_frame(dc, rect, self.frame_style, self.frame_title,
            self.lockable, locked, inactive)
    if self.kbd_get_pos then
        local pos = self.kbd_get_pos()
        local pen = to_pen{fg=COLOR_GREEN, bg=COLOR_BLACK}
        dc:seek(pos.x, pos.y):pen(pen):char(string.char(0xDB))
    end
    if self.drag_offset and not self.kbd_get_pos
            and df.global.enabler.mouse_lbut == 0 then
        Panel_end_drag(self, nil, true)
    end
    
  paint_horizontal_border(rect, {t = 2})
  paint_horizontal_border(rect, {t = 4})
  
end

function MRAU_UI:onClickQuit()
  WINDOWSIZE_GLOBAL = {h = self.parent_view.subviews.MainWindow.frame.h, w =self.parent_view.subviews.MainWindow.frame.w}
  self.parent_view.subviews.MainWindow.frame.h = 0
  self.parent_view.subviews.MainWindow.frame.w = 0
  self:updateLayout()
  self.parent_view.subviews.MainWindow.visible = false 
  --if reports then persist.GlobalTable.reports = json.encode(reports) end
  --turnOffEvents()
  --self.parent_view:dismiss()
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CURSOR - make a cursor that highlights where is unit leftup 120 ,42 downright 123 ,45
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--MAIN SCREEN
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CPScreen = defclass(CPScreen, gui.ZScreen)
CPScreen.ATTRS {
    focus_path='MRAU_UI',
}

function CPScreen:init()
    self:addviews{
        MRAU_UI{ --MAIN WINDOW
      },
      widgets.Panel{
          view_id='icon',
          frame={b = 0, l = 32, w = 4, h = 3},
          
          frame_background = to_pen{fg=COLOR_MAGENTA, bg=COLOR_MAGENTA},
          resizable = false,
          lockable = false,
          --frame_style=gui.BOUNDARY_FRAME,
      }
    }

    self.subviews.icon:addviews{
      widgets.Label{
        view_id='iconTOP',
        visible = true,
        --text_pen = COLOR_
        frame={t=0, l=0, w=4},
        text="\218\196\196\191",
      },
      widgets.Label{
        view_id='iconMID',
        visible = true,
        frame={t=1, l=0, w=4},
        text="\179M\2\179",
      },
      widgets.Label{
        view_id='iconBOT',
        visible = true,
        frame={t=2, l=0, w=4},
        text="\192\196\196\217",
      }
    }
end

WINDOWSIZE_GLOBAL = {}
function CPScreen:Minimalize(keys)
  if keys == nil then
    keys = {_MOUSE_L_DOWN = true,_MOUSE_R_DOWN = false}
    return ture
  end
  
  x, y = self.subviews.icon:getMousePos()

  if y ~= nil and keys._MOUSE_L_DOWN then --tutaj jest ktore klawisze sa blokowane
    if not self.subviews.MainWindow.visible then
      self.subviews.MainWindow.frame.h = WINDOWSIZE_GLOBAL.h
      self.subviews.MainWindow.frame.w = WINDOWSIZE_GLOBAL.w
      self:updateLayout()
      self.subviews.MainWindow.visible = true
      

    else
      WINDOWSIZE_GLOBAL = {h = self.subviews.MainWindow.frame.h, w =self.subviews.MainWindow.frame.w}
      self.subviews.MainWindow.frame.h = 0
      self.subviews.MainWindow.frame.w = 0
      self:updateLayout()
      self.subviews.MainWindow.visible = false
      
    end
    return true
  end

  if keys._MOUSE_R_DOWN or keys.LEAVESCREEN then
    FOLLOWUNIT = nil
      if y ~= nil then --pozwala wylaczyc jak na ikonie
        return true--CPScreen.super.onInput(self, keys) 

      elseif doesLockMain then
        cursorPos = nil --wylacza kursor
        return true --blokuje chowanie panelu jak lock jest wlaczony

      elseif self.subviews.MainWindow.visible then --Chowa panel
        cursorPos = nil
        WINDOWSIZE_GLOBAL = {h = self.subviews.MainWindow.frame.h, w =self.subviews.MainWindow.frame.w}
        self.subviews.MainWindow.frame.h = 0
        self.subviews.MainWindow.frame.w = 0
        self:updateLayout()
        self.subviews.MainWindow.visible = false 
        return true--blokuje wylaczanie skrypru jak nie na ikoniesetText

      else
        return true

      end
  end

  return self.super.onInput(self, keys)
end

function CPScreen:onInput(keys)
   
  --printall(self.subviews.icon)
  --printall(self.subviews.UnitSubPanels.subviews.SearchField)
  

  if self.subviews.MainWindow.visible then
    self.subviews.icon.subviews.iconTOP.text_pen = to_pen(COLOR_WHITE)
    self.subviews.icon.subviews.iconMID.text_pen = to_pen(COLOR_WHITE)
    self.subviews.icon.subviews.iconBOT.text_pen = to_pen(COLOR_WHITE)

   self.subviews.icon.subviews.iconTOP:setText("\218\196\196\191")
   self.subviews.icon.subviews.iconMID:setText("\179M\2\179")
   self.subviews.icon.subviews.iconBOT:setText("\192\196\196\217")
  else
    self.subviews.icon.subviews.iconTOP.text_pen = to_pen(COLOR_GREY)
    self.subviews.icon.subviews.iconMID.text_pen = to_pen(COLOR_GREY)
    self.subviews.icon.subviews.iconBOT.text_pen = to_pen(COLOR_GREY)

    self.subviews.icon.subviews.iconTOP:setText("\218\196\196\191")
    self.subviews.icon.subviews.iconMID:setText("\179m\1\179")
    self.subviews.icon.subviews.iconBOT:setText("\192\196\196\217")
  end

  self.subviews.icon:updateLayout()
  --self:updateLayout()

  return self:Minimalize(keys)
end


function CPScreen:onDismiss()
    if reports then persist.GlobalTable.reports = json.encode(reports) end
    turnOffEvents()
    view = nil
end

local BOX_PEN = to_pen{ch='X', fg=COLOR_GREEN,tile=dfhack.screen.findGraphicsTile('CURSORS', 0, 0)}
cursorPos = nil --for displaying unit position.
function CPScreen:onRenderFrame(dc, rect)
    local function get_overlay_pen(pos)
      if cursorPos ~= nil then
        if cursorPos.x == pos.x and cursorPos.y == pos.y and cursorPos.z == pos.z then
          return BOX_PEN
        end
      end
    end
    dwarfmode.renderMapOverlay(get_overlay_pen, self.overlay_bounds)
end



--DRAWING FUNCTIONS
--------------------------------------------------------------------------------------------------------

BORDER_PENS = {
  Split = {
    left = dfhack.pen.parse{tile=913, ch=204, fg=COLOR_GREY, bg=COLOR_BLACK},
    right = dfhack.pen.parse{tile=914, ch=185, fg=COLOR_GREY, bg=COLOR_BLACK},
    top = dfhack.pen.parse{tile=911, ch=203, fg=COLOR_GREY, bg=COLOR_BLACK},
    bottom = dfhack.pen.parse{tile=912, ch=202, fg=COLOR_GREY, bg=COLOR_BLACK}
  },
  
  Inside = {
    vertical = dfhack.pen.parse{tile=905, ch=179, fg=COLOR_GREY, bg=COLOR_BLACK},
    horizontal = dfhack.pen.parse{tile=906, ch=196, fg=COLOR_GREY, bg=COLOR_BLACK}
  }
}

function completePen(penForCompliting)
  penForCompliting = penForCompliting or BORDER_PENS
  penForCompliting.Split = penForCompliting.Split or BORDER_PENS.Split
  penForCompliting.Inside = penForCompliting.Inside or BORDER_PENS.Inside

  penForCompliting.Split.left = penForCompliting.Split.left or BORDER_PENS.Split.left
  penForCompliting.Split.right = penForCompliting.Split.right or BORDER_PENS.Split.right
  penForCompliting.Split.top = penForCompliting.Split.top or BORDER_PENS.Split.top
  penForCompliting.Split.bottom = penForCompliting.Split.bottom or BORDER_PENS.Split.bottom

  penForCompliting.Inside.vertical = penForCompliting.Inside.vertical or BORDER_PENS.Inside.vertical
  penForCompliting.Inside.horizontal = penForCompliting.Inside.horizontal or BORDER_PENS.Inside.horizontal

  return penForCompliting
end
-- paint autocomplete panel border
function paint_vertical_border(dc,spaces,rect,pens) --dc or rect it depends is it subview or turnOnEvents panel
  if rect == nil then rect = {x1 = 0,x2 = 0,y1 = 0,y2 = 0} end
  if pens == nil then pens = BORDER_PENS end

  pens = completePen(pens)

  spaces.t = spaces.t or 0
  spaces.r = spaces.r or 0
  spaces.b = spaces.b or 0
  spaces.l = spaces.l or 0

  local x = dc.x2
  if spaces.r ~= 0 then x = dc.x2 - (spaces.r) end
  if spaces.l ~= 0 then x = dc.x2 + (spaces.l) end
  

  local y1, y2 = dc.y1, dc.y2

  for y=y1 + spaces.t + 1,y2 - spaces.b - 1 do
      dfhack.screen.paintTile(pens.Inside.vertical, x, y)
  end

  dfhack.screen.paintTile(pens.Split.top , x, y1 + spaces.t)
  dfhack.screen.paintTile(pens.Split.bottom, x, y2 - spaces.b)
end

-- paint border between edit area and help area
function paint_horizontal_border(dc,spaces,rect,pens) --dc or rect it depends is it subview or turnOnEvents panel
  if rect == nil then rect = {x1 = 0,x2 = 0,y1 = 0,y2 = 0} end
  if pens == nil then pens = BORDER_PENS end
  pens = completePen(pens)

  spaces.t = spaces.t or 0
  spaces.r = spaces.r or 0
  spaces.b = spaces.b or 0
  spaces.l = spaces.l or 0

  local y = dc.y1
  if spaces.t ~= 0 then y = dc.y1 + (spaces.t) end
  if spaces.b ~= 0 then y = dc.y1 - (spaces.b) end

  local x1, x2 = dc.x1, dc.x2

  for x=x1 + spaces.l + 1 + rect.x1,x2 - spaces.r - 1 do
      dfhack.screen.paintTile(pens.Inside.horizontal, x, y)
  end

  dfhack.screen.paintTile(pens.Split.left, x1 + spaces.l + rect.x1, y)
  dfhack.screen.paintTile(pens.Split.right, x2 - spaces.r, y)
end

--function getAppropriateCornerTile(x,y)
--
--end

::ENDOFSCRIPT::
