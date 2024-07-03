-- entrelacs v0.5c
-- params
-- presets
-- pas les modifiers & ranges
-- nouvelle indexation
-- !! vraie last version
-- every : silence si 1 nest-sq
-- BUG
-- every dernier pas zone saute ix


s = require 'sequins'
music = require 'musicutil'
g = grid.connect() -- à mettre avant rotation sinon ne fonctionne pas

-- manual grid rotation (from Metrix)
function grid:led(x, y, val)
    _norns.grid_set_led(self.dev, y, 9 - x, val)
end

--VARIABLES--
idx = 1
alt = false
xenutil = {}
scale = 1
mode = 1
mode_names = {'MACRO','ECHELLES','WSYN'}
stepsize = 1
e1 = 1
e2 = 1
e3 = 1
e4 = 1
edit_ch = 1
item_nbr = 1
optid = 'wsyn_curve'
item_nbr2 = 1
optid2 = 'wsyn_curve2'
optid3 = 'jf_run'
optid4 = 'v_oct_mute'
item_nbrcnl1 = 1
item_nbrcnl4 = 1
input1 = 0
input2 = 0
solofond = false
mutevoct4 = false
selec_fond = 1
selec_mute = 1
randrift4 = 0
randrift_jf = 0
--**--

--TABLES--

optid_tbl = {
    'wsyn_curve',
    'wsyn_ramp',
    'wsyn_fm_index',
    'wsyn_fm_env',
    'wsyn_fm_ratio_num',
    'wsyn_fm_ratio_den',
    'wsyn_lpg_time',
    'wsyn_lpg_symmetry',
    'wsyn_patch_this',
    'wsyn_patch_that',
}

optid_tbl2 = {
    'wsyn_curve2',
    'wsyn_ramp2',
    'wsyn_fm_index2',
    'wsyn_fm_env2',
    'wsyn_fm_ratio_num2',
    'wsyn_fm_ratio_den2',
    'wsyn_lpg_time2',
    'wsyn_lpg_symmetry2',
    'wsyn_patch_this2',
    'wsyn_patch_that2',
}

optid_tblcnl1 = {
    'jf_run',
    'randrift_jf',
    'octaveRings',
    'solofond',
    'randrift_rgs'
}

optid_tblcnl4 = {
    'v_oct_mute',
    'randrift4'
}

-- [SCALES]
-- 7 notes max
-- fixer nbr de caractères max pour 'name' -> 16 max -- 193.55 1.9355
xenutil.SCALES = {
{name = "Derives Minor 31", intervals = {0, 1.9355, 3.0968, 5.0323, 6.9677, 8.1290, 10.0645}, interv_name = {'R','M2','m3','P4','P5','m6','m7'}}, -- 7 éléments
{name = "Harm Minor 31", intervals = {0, 1.9355, 3.0968, 5.0323, 6.9677, 8.1290, 10.8387}, interv_name = {'R','M2','m3','P4','P5','m6','M7'}}, -- 7 éléments
{name = "Harm Major 31", intervals = {0, 1.9355, 3.8710, 5.0323, 6.9677, 8.9032, 10.8387}, interv_name = {'R','M2','M3','P4','P5','M6','M7'}}, -- 7 éléments
{name = "Chroma Thirds", intervals = {0, 2.7097, 3.0968, 3.4839, 3.8710, 4.2581, 6.9677}, interv_name = {'R','d3','m3','n3','M3','U3','P5'}}, -- 7
{name = "Chroma Sixths", intervals = {0, 3.8710, 6.9677, 7.7419, 8.1290, 8.9032, 9.2903}, interv_name = {'R','M3','P5','d6','m6','M6','U6'}}, -- 7
{name = "Chroma Sevnth", intervals = {0, 3.8710, 6.9677, 9.6774, 10.0645, 10.8387, 11.2258}, interv_name = {'R','M3','P5','d7','m7','M7','U7'}}, -- 7
}

char_seq1 =
        s{
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1}
        }
char_seq2 =
        s{
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1}
        }
char_seq3 =
        s{
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1}
        }
char_seq4 =
        s{
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1},
            s{1,1,1,1,1,1,1,1}
        }

--**--

--HELPER FUNCTIONS--

function loopseq()

    if char_seq1.ix >= range[8].x2 then -- besoin de comparer >= car ix peut être supérieur avec modifier 'step' par ex
        char_seq1:select(range[8].x1)
    end
    if char_seq2.ix >= range[16].x2 then -- besoin de comparer >= car ix peut être supérieur avec modifier 'step' par ex
        char_seq2:select(range[16].x1)
    end
    if char_seq3.ix >= range[32].x2 then -- besoin de comparer >= car ix peut être supérieur avec modifier 'step' par ex
        char_seq3:select(range[32].x1)
    end
    if char_seq4.ix >= range[64].x2 then -- besoin de comparer >= car ix peut être supérieur avec modifier 'step' par ex
        char_seq4:select(range[64].x1)
    end

end

-- fonctions pour récupérer valeurs des sequins
function sequins_peek(v)
    while s.is_sequins(v) do v = v:peek() end -- s.is_sequins(v) retourner true ou false - char_seq1[i]:peek
    return v
end  

-- pour accéder au sequins dans la table (canal) choisie 
function peek(stack) -- reçoit 'char_seq[1]' et retourne char_seq[1][#char_seq[1]]
    return stack[#stack] -- return char_seq[1][1] ou char_seq[2][1] - un seul élément car un seul sequins dans la table char_seq[1]
end

function every1(e1) -- besoin de créer une fonction pour modifier 'every' avec une variable pour ensuite la changer avec encoder
    -- cf study 4 : "every" est une méthode appliquée à la fonction 'seq' dans librairie sequins
    return char_seq1:every(e1)
end

function every1nst(e1) -- envoi au nested-sequins choisi par 'idx'
    return char_seq1[idx]:every(e1)
end

function every2(e2) -- envoi au sequins principal (canal 2)
    return char_seq2:every(e2)
end

function every2nst(e2) -- envoi au nested-sequins choisi par 'idx'
    return char_seq2[idx]:every(e2)
end

function every3(e3) -- envoi au sequins principal (canal 3)
    return char_seq3:every(e3)
end

function every3nst(e3) -- envoi au nested-sequins choisi par 'idx'
    return char_seq3[idx]:every(e3)
end

function every4(e4) -- envoi au sequins principal (canal 3)
    return char_seq4:every(e4)
end

function every4nst(e4) -- envoi au nested-sequins choisi par 'idx'
    return char_seq4[idx]:every(e4)
end

function update_solofond() -- pour changer état de solofond via une fonction en ayant un params — intéressant pour développer fonctions plus complexes dans l'avenir
    if params:string('solofond') == 'off' then
        solofond = false
    elseif params:string('solofond') == 'on' then
        solofond = true
    end
end

function update_mutevoct4() -- pour changer état de mutevoct4 via une fonction en ayant un params — intéressant pour développer fonctions plus complexes dans l'avenir
    if params:string('v_oct_mute') == 'off' then
        mutevoct4 = false
    elseif params:string('v_oct_mute') == 'on' then
        mutevoct4 = true
    end
end

--**--

--PARAMS--

-- from "less-concept"
function wsyn_add_params() -- 
    params:add_group("w/syn1",12)
    params:add {
        type = "option",
        id = "wsyn_ar_mode",
        name = "AR mode",
        options = {"off", "on"},
        default = 2,
        action = function(val) 
        crow.send("ii.wsyn[1].ar_mode(".. (val-1) ..")")
        end
    }
    params:add {
        type = "control",
        id = "wsyn_velocity",
        name = "Velocity",
        controlspec = controlspec.new(0, 5, "lin", 0, 2, "v"),
        action = function(val) 
        pset_wsyn_vel = val -- pour récupérer valeurs si preset
        end
    }
    params:add {
        type = "control",
        id = "wsyn_curve",
        name = "Curve",
        controlspec = controlspec.new(-5, 5, "lin", 0.01, 5, "v",0.001),
        action = function(val) 
        crow.send("ii.wsyn[1].curve(" .. val .. ")") 
        pset_wsyn_curve = val
        end
    }
    params:add {
        type = "control",
        id = "wsyn_ramp",
        name = "Ramp",
        controlspec = controlspec.new(-5, 5, "lin", 0.01, 0, "v",0.001),
        action = function(val) 
        crow.send("ii.wsyn[1].ramp(" .. val .. ")") 
        pset_wsyn_ramp = val
        end
    }
    params:add {
        type = "control",
        id = "wsyn_fm_index",
        name = "FM index",
        controlspec = controlspec.new(-5, 5, "lin", 0.01, 0, "v",0.001),
        action = function(val) 
        crow.send("ii.wsyn[1].fm_index(" .. val .. ")") 
        pset_wsyn_fm_index = val
        end
    }
    params:add {
        type = "control",
        id = "wsyn_fm_env",
        name = "FM env",
        controlspec = controlspec.new(-5, 5, "lin", 0.01, 0, "v",0.001),
        action = function(val) 
        crow.send("ii.wsyn[1].fm_env(" .. val .. ")") 
        pset_wsyn_fm_env = val
        end
    }
    params:add {
        type = "control",
        id = "wsyn_fm_ratio_num",
        name = "FM ratio numerator",
        controlspec = controlspec.new(1, 20, "lin", 1, 2),
        action = function(val) 
        crow.send("ii.wsyn[1].fm_ratio(" .. val .. "," .. params:get("wsyn_fm_ratio_den") .. ")") 
        pset_wsyn_fm_ratio_num = val
        end
    }

    params:add {
        type = "control",
        id = "wsyn_fm_ratio_den",
        name = "FM ratio denominator",
        controlspec = controlspec.new(1, 20, "lin", 1, 1),
        action = function(val) 
        crow.send("ii.wsyn[1].fm_ratio(" .. params:get("wsyn_fm_ratio_num") .. "," .. val .. ")") 
        pset_wsyn_fm_ratio_den = val
        end
    }
    params:add {
        type = "control",
        id = "wsyn_lpg_time",
        name = "LPG time",
        controlspec = controlspec.new(-5, 5, "lin", 0.01, -2.3, "v",0.001),
        action = function(val) 
        crow.send("ii.wsyn[1].lpg_time(" .. val .. ")") 
        pset_wsyn_lpg_time = val
        end
    }
    params:add {
        type = "control",
        id = "wsyn_lpg_symmetry",
        name = "LPG symmetry",
        controlspec = controlspec.new(-5, 5, "lin", 0.01, -4.9, "v",0.001),
        action = function(val) 
        crow.send("ii.wsyn[1].lpg_symmetry(" .. val .. ")") 
        pset_wsyn_lpg_symmetry = val
        end
    }
    params:add{
        type = 'option',
        id = 'wsyn_patch_this',
        name = 'patch this',
        options = {
          'ramp', 'curve', 'fm env', 'fm index', 'lpg_time', 'lpg_symmetry', 'gate',
          'pitch', 'fm num ratio', 'fm denum ratio',
        },
        default = 1,
        action = function(val)
          crow.send("ii.wsyn[1].patch(1 ," .. val .. ")")
        end
    }
    params:add{
        type = 'option',
        id = 'wsyn_patch_that',
        name = 'patch that',
        options = {
            'ramp', 'curve', 'fm env', 'fm index', 'lpg time', 'lpg symmetry', 'gate',
            'pitch', 'fm num ratio', 'fm denum ratio',
        },
        default = 2,
        action = function(val)
            crow.send("ii.wsyn[1].patch(2 ," .. val .. ")")
        end
    }
end

function wsyn2_add_params() -- 
    params:add_group("w/syn2",12)
    params:add {
        type = "option",
        id = "wsyn_ar_mode2",
        name = "AR mode",
        options = {"off", "on"},
        default = 2,
        action = function(val) 
        crow.send("ii.wsyn[2].ar_mode(".. (val-1) ..")")
        end
    }
    params:add {
        type = "control",
        id = "wsyn_velocity2",
        name = "Velocity",
        controlspec = controlspec.new(0, 5, "lin", 0, 2, "v"),
        action = function(val) 
        pset_wsyn_vel = val -- pour récupérer valeurs si preset
        end
    }
    params:add {
        type = "control",
        id = "wsyn_curve2",
        name = "Curve",
        controlspec = controlspec.new(-5, 5, "lin", 0.01, 5, "v",0.001),
        action = function(val) 
        crow.send("ii.wsyn[2].curve(" .. val .. ")") 
        pset_wsyn_curve = val
        end
    }
    params:add {
        type = "control",
        id = "wsyn_ramp2",
        name = "Ramp",
        controlspec = controlspec.new(-5, 5, "lin", 0.01, 0, "v",0.001),
        action = function(val) 
        crow.send("ii.wsyn[2].ramp(" .. val .. ")") 
        pset_wsyn_ramp = val
        end
    }
    params:add {
        type = "control",
        id = "wsyn_fm_index2",
        name = "FM index",
        controlspec = controlspec.new(-5, 5, "lin", 0.01, 0, "v",0.001),
        action = function(val) 
        crow.send("ii.wsyn[2].fm_index(" .. val .. ")") 
        pset_wsyn_fm_index = val
        end
    }
    params:add {
        type = "control",
        id = "wsyn_fm_env2",
        name = "FM env",
        controlspec = controlspec.new(-5, 5, "lin", 0.01, 0, "v",0.001),
        action = function(val) 
        crow.send("ii.wsyn[2].fm_env(" .. val .. ")") 
        pset_wsyn_fm_env = val
        end
    }
    params:add {
        type = "control",
        id = "wsyn_fm_ratio_num2",
        name = "FM ratio numerator",
        controlspec = controlspec.new(1, 20, "lin", 1, 2),
        action = function(val) 
        crow.send("ii.wsyn[2].fm_ratio(" .. val .. "," .. params:get("wsyn_fm_ratio_den") .. ")") 
        pset_wsyn_fm_ratio_num = val
        end
    }

    params:add {
        type = "control",
        id = "wsyn_fm_ratio_den2",
        name = "FM ratio denominator",
        controlspec = controlspec.new(1, 20, "lin", 1, 1),
        action = function(val) 
        crow.send("ii.wsyn[2].fm_ratio(" .. params:get("wsyn_fm_ratio_num") .. "," .. val .. ")") 
        pset_wsyn_fm_ratio_den = val
        end
    }
    params:add {
        type = "control",
        id = "wsyn_lpg_time2",
        name = "LPG time",
        controlspec = controlspec.new(-5, 5, "lin", 0.01, -2.3, "v",0.001),
        action = function(val) 
        crow.send("ii.wsyn[2].lpg_time(" .. val .. ")") 
        pset_wsyn_lpg_time = val
        end
    }
    params:add {
        type = "control",
        id = "wsyn_lpg_symmetry2",
        name = "LPG symmetry",
        controlspec = controlspec.new(-5, 5, "lin", 0.01, -4.9, "v",0.001),
        action = function(val) 
        crow.send("ii.wsyn[2].lpg_symmetry(" .. val .. ")") 
        pset_wsyn_lpg_symmetry = val
        end
    }
    params:add{
        type = 'option',
        id = 'wsyn_patch_this2',
        name = 'patch this',
        options = {
          'ramp', 'curve', 'fm env', 'fm index', 'lpg_time', 'lpg_symmetry', 'gate',
          'pitch', 'fm num ratio', 'fm denum ratio',
        },
        default = 1,
        action = function(val)
          crow.send("ii.wsyn[2].patch(1 ," .. val .. ")")
        end
    }
    params:add{
        type = 'option',
        id = 'wsyn_patch_that2',
        name = 'patch that',
        options = {
            'ramp', 'curve', 'fm env', 'fm index', 'lpg time', 'lpg symmetry', 'gate',
            'pitch', 'fm num ratio', 'fm denum ratio',
        },
        default = 2,
        action = function(val)
            crow.send("ii.wsyn[2].patch(2 ," .. val .. ")")
        end
    }
end

function jf_add_params()
    params:add_group("JF",1)
    params:add {
        type = 'control',
        id = 'jf_run',
        name = 'Run',
        controlspec = controlspec.new(-5, 5, "lin", 0.01, 5, 'v', 0.001), -- min,max,scale,step,default,units,quantum,wrap
        action = function(val)
            crow.send("ii.jf.run(" .. val .. ")") 
        end
    }  
end

function start_params()
    params:add_group("macro",3)
    params:add {
        type = 'control',
        id = 'cents',
        name = 'cents',
        controlspec = controlspec.new(-1, 1, "lin", 0.01, 0, '', 0.001, false), -- min,max,scale,step,default,units,quantum,wrap
    }  
    params:add {
        type = 'control',
        id = 'semitone',
        name = 'semitone',
        controlspec = controlspec.new(-12, 12, "lin", 1, math.random(-12,12), ''),
    }  

    params:add {
        type = 'number',
        id = 'scale',
        name = 'scale',
        min = 1,
        max = #xenutil.SCALES,
        default = 1
    }  

    params:add_group("cnl1",4)
    params:add {
        type = 'number',
        id = 'octave1',
        name = 'octave1',
        min = -3,
        max = 3,
        default = 0
    } 
    params:add {
        type = 'number',
        id = 'octaveRings',
        name = 'octaveRings',
        min = -3,
        max = 3,
        default = 0
    } 
    params:add {
        type = 'option',
        id = 'solofond',
        name = 'solofond',
        options = {'off','on'},
        default = 1, -- base 1 ATTENTION : 1 = index 1 de la table
        action = function()
            update_solofond()
        end
    } 
    params:add {
        type = 'control',
        id = 'randrift_jf',
        name = 'randrift_jf',
        controlspec = controlspec.new(0, 0.50, "lin", 0.001, 0, '', 0.01, false)
    }
    params:add {
        type = 'control',
        id = 'randrift_rgs',
        name = 'randrift_rgs',
        controlspec = controlspec.new(0, 0.50, "lin", 0.001, 0, '', 0.01, false)
    }
    
    params:add_group("canal1",64)
    for i = 1, 8 do
        for j = 1, 8 do
            params:add{
                type = "number", 
                id= ("cnl1_data_"..i..j), 
                name = ("pas "..i..j), 
                min=1, 
                max=7,
                default = char_seq1[i][j],
                action = function(x)
                    char_seq1[i][j] = x 
                    grid_redraw()
                end 
            }
        end
    end

    params:add_group("cnl2",1)
    params:add {
        type = 'number',
        id = 'octave2',
        name = 'octave2',
        min = -3,
        max = 3,
        default = 0
    } 
    
    params:add_group("canal2",64)
    for i = 1, 8 do
        for j = 1, 8 do
            params:add{
                type = "number", 
                id= ("cnl2_data_"..i..j), 
                name = ("pas "..i..j), 
                min=1, 
                max=7,
                default = char_seq2[i][j],
                action = function(x)
                    char_seq2[i][j] = x 
                    grid_redraw()
                end 
            }
        end
    end

    params:add_group("cnl3",1)
    params:add {
        type = 'number',
        id = 'octave3',
        name = 'octave3',
        min = -3,
        max = 3,
        default = 0
    } 
    
    params:add_group("canal3",64)
    for i = 1, 8 do
        for j = 1, 8 do
            params:add{
                type = "number", 
                id= ("cnl3_data_"..i..j), 
                name = ("pas "..i..j), 
                min=1, 
                max=7,
                default = char_seq3[i][j],
                action = function(x)
                    char_seq3[i][j] = x 
                    grid_redraw()
                end 
            }
        end
    end

    params:add_group("cnl4",2)
    params:add {
        type = 'number',
        id = 'octave4',
        name = 'octave4',
        min = -3,
        max = 3,
        default = 0
    }
    params:add {
        type = 'option',
        id = 'v_oct_mute',
        name = 'v_oct_mute',
        options = {'off','on'},
        default = 1, -- base 1 ATTENTION : 1 = index 1 de la table
        action = function()
            update_mutevoct4()
        end
    }  
    params:add {
        type = 'control',
        id = 'randrift4',
        name = 'randrift4',
        controlspec = controlspec.new(0, 0.50, "lin", 0.001, 0, '', 0.01, false) -- min,max,scale,step,default,units,quantum,wrap
    }
    -- 0.05 = 5 cents (je dois /12 après pour le v/8)
    -- math.random() * (randrift4val - -randrift4val) + -randrift4val
    
    params:add_group("canal4",64)
    for i = 1, 8 do
        for j = 1, 8 do
            params:add{
                type = "number", 
                id= ("cnl4_data_"..i..j), 
                name = ("pas "..i..j), 
                min=1, 
                max=7,
                default = char_seq4[i][j],
                action = function(x)
                    char_seq4[i][j] = x 
                    grid_redraw()
                end 
            }
        end
    end

end

-- from awake
set_seq_data = function(which, sequin, step, val)
    params:set(which.."_data_"..sequin..step, val)
end

--**--

function init()

    -- defaut nested-sequins
    x = 1

    -- suivi des boutons pour zone de pas canal 1 et 2
    range = {[8] = {x1 = 1, x2 = 1, held = 0}, [16] = {x1 = 1, x2 = 1, held = 0}, [32] = {x1 = 1, x2 = 1, held = 0}, [64] =  {x1 = 1, x2 = 1, held = 0}}

    -- tables pour stocker modifier 'step' par nested-sequins de chaque canal
    nested_step = {}
    for i = 1,8 do
        nested_step[i] = 1
    end

    nested_step2 = {}
    for i = 1,8 do
        nested_step2[i] = 1
    end

    nested_step3 = {}
    for i = 1,8 do
        nested_step3[i] = 1
    end

    nested_step4 = {}
    for i = 1,8 do
        nested_step4[i] = 1
    end

    -- tables pour stocker modifier 'every' par nested-sequins de chaque canal
    nested_every = {}
    for i = 1,8 do
        nested_every[i] = 1
    end

    nested_every2 = {}
    for i = 1,8 do
        nested_every2[i] = 1
    end
    
    nested_every3 = {}
    for i = 1,8 do
        nested_every3[i] = 1
    end

    nested_every4 = {}
    for i = 1,8 do
        nested_every4[i] = 1
    end

    --**--

    poll_clock_id = clock.run(getters)
    --rand_clock_id = clock.run(rand_drift)
    --poll_clock_id2 = clock.run(getters2)
    start_params()
    jf_add_params()
    wsyn_add_params()
    wsyn2_add_params()
    params:bang()
    params:default()
    crow.send("ii.wsyn[1].ar_mode(1)")
    crow.send("ii.wsyn[2].ar_mode(1)")
    --crow.ii.crow.send("ii.address = 2")
    crow.ii.jf.mode(1)
    crow.ii.jf.run_mode(1)
    crow.ii.jf.transpose(0)
    
    crow.input[1].change = play_jf
    crow.input[1].mode("change", 2, 0.25, "rising")
    crow.input[2].change = play_wsyn
    crow.input[2].mode("change", 2, 0.25, "rising")
    grid_redraw()
end

-- crow.ii.jf.vtrigger( 0, 5 ) -- Trigger *channel* with velocity set by *level*

function getters()
    while true do
        clock.sleep(0.01)
        crow.ii.crow.get('input', 1)
        crow.ii.crow.get('input', 2)
    end
end

crow.ii.crow.event = function(e, value)
    if e.name == 'input'  then
        if e.arg == 1 then
            input1 = value
            if input1 > 4 then
                play_wsyn2()
            end
        elseif e.arg == 2 then
            input2 = value
            if input2 > 4 then
                play_out1()
            end
        end
    end
end

--[[ function rand_drift()
    while true do
        clock.sleep(0.01)
        randrift4 = math.random() * (params:get('randrift4') - -params:get('randrift4')) + -params:get('randrift4')
        crow.output[2].volts = (randrift4/12)
    end
end
 ]]

-- VOIX --
function play_jf(state1)

    ss1 = xenutil.SCALES[params:get("scale")].intervals[char_seq1()]
    type1 = type(ss1)
    randrift_jf = math.random() * (params:get('randrift_jf') - -params:get('randrift_jf')) + -params:get('randrift_jf')
    randrift_rgs = math.random() * (params:get('randrift_rgs') - -params:get('randrift_rgs')) + -params:get('randrift_rgs')

    -- permet d'utiliser modifier 'every' sur un seul nested-sequins sans avoir de bug imprimé dans la console
    if type1 == 'number' and solofond == false then -- vérifie si 'ss1' retourne bien un nombre -> le sequins retourne une valeur
        notejf = (ss1/12) + params:get("octave1") + (params:get("semitone")/12) + (params:get("cents")/12)
        crow.ii.jf.play_note(notejf + (randrift_jf/12), 5)
        crow.output[1].volts = notejf + params:get("octaveRings") + (randrift_rgs/12)
    elseif type1 == 'number' and solofond == true then
        notejf = (ss1/12) + params:get("octave1") + (params:get("semitone")/12) + (params:get("cents")/12)
        crow.ii.jf.play_note(notejf + (randrift_jf/12), 5)
        crow.output[1].volts = params:get("octave1") + (params:get("semitone")/12) + (params:get("cents")/12) + params:get("octaveRings") + (randrift_rgs/12) -- Rings joue la note fondamentale uniquement
    elseif type1 == "nil" then -- si 'ss1' ne retourne rien -> JF ne joue rien / Rings joue la fondamentale (si je ne veux pas le jouer -> essayer d'envoyer un CV extrême qui ne ne sort pas de signal ?)
        crow.ii.jf.play_note(0, 0)
        crow.output[1].volts = params:get("octave1") + (params:get("semitone")/12) + (params:get("cents")/12) + params:get("octaveRings")
    end

    --crow.ii.jf.play_note(notejf, 5)
    grid_redraw(state1)
    --print(char_seq1.ix)
    redraw()
    loopseq()
end

function play_wsyn(s)

    ss2 = xenutil.SCALES[params:get("scale")].intervals[char_seq2()]
    type2 = type(ss2)

    -- permet d'utiliser modifier 'every' sur un seul nested-sequins sans avoir de bug imprimé dans la console
    if type2 == 'number' then -- vérifie si 'ss1' retourne bien un nombre -> le sequins retourne une valeur
        notewsyn = (ss2/12) + params:get("octave2") + (params:get("semitone")/12) + (params:get("cents")/12)
        crow.ii.wsyn[1].play_note(notewsyn, 5)
    elseif type2 == "nil" then -- si 'ss1' ne retourne rien -> JF ne joue rien
        crow.ii.wsyn[1].play_note(0, 0)
    end

    grid_redraw()
    --print(char_seq[2][1].ix)
    --print(char_seq[2][1][1].ix)
    redraw()
    loopseq()
end

function play_wsyn2(s)

    ss3 = xenutil.SCALES[params:get("scale")].intervals[char_seq3()]
    type3 = type(ss3)

    -- permet d'utiliser modifier 'every' sur un seul nested-sequins sans avoir de bug imprimé dans la console
    if type3 == 'number' then -- vérifie si 'ss1' retourne bien un nombre -> le sequins retourne une valeur
        notewsyn2 = (ss3/12) + params:get("octave3") + (params:get("semitone")/12) + (params:get("cents")/12)
        crow.ii.wsyn[2].play_note(notewsyn2, 5)
    elseif type3 == "nil" then -- si 'ss1' ne retourne rien -> JF ne joue rien
        crow.ii.wsyn[2].play_note(0, 0)
    end

    grid_redraw()
    --print(char_seq[2][1].ix)
    --print(char_seq[2][1][1].ix)
    redraw()
    loopseq()
end

function play_out1(s) -- canal 4 voix Beads

    ss4 = xenutil.SCALES[params:get("scale")].intervals[char_seq4()]
    type4 = type(ss4)
    randrift4 = math.random() * (params:get('randrift4') - -params:get('randrift4')) + -params:get('randrift4')

    -- permet d'utiliser modifier 'every' sur un seul nested-sequins sans avoir de bug imprimé dans la console
    if type4 == 'number' and mutevoct4 == false then -- vérifie si 'ss1' retourne bien un nombre -> le sequins retourne une valeur
        note_out1 = (ss4/12) + params:get("octave4") + (params:get("cents")/12) + (randrift4/12) -- pas besoin de mettre 'semitone' le signal à l'entrée est déjà transposé
        crow.output[2].volts = note_out1
    elseif type4 == 'number' and mutevoct4 == true then
        crow.output[2].volts = params:get("octave4") + (params:get("cents")/12) + (randrift4/12)
    elseif type4 == "nil" then -- si 'ss4' ne retourne rien -> 0v à la sortie de crow mais trig vers Rings fonctionne (trouver une autre méthode ?)
        crow.output[2].volts = params:get("octave4") + (params:get("cents")/12)
    end

    grid_redraw()
    --print(char_seq[2][1].ix)
    --print(char_seq[2][1][1].ix)
    redraw()
    loopseq()
end

--**--

function key(n, z)
 
    if n == 1 then 
        alt = z == 1 

    elseif mode >= 1 then
        if n == 2 and z == 1 then
            if not alt==true then -- TODO : si alt == true je pourrai changer fonctions K2 et K3 ?
                -- toggle channel
                if edit_ch == 1 then
                    edit_ch = 2
                else 
                    edit_ch = 1
                end
            end
        elseif n == 3 and z == 1 then
            if not alt==true then -- TODO : si alt == true je pourrai changer fonctions K2 et K3 ?
                -- toggle channel
                if edit_ch == 3 then
                    edit_ch = 4
                else 
                    edit_ch = 3
                end
            end
        end
    end

    grid_redraw()
    redraw()
end

function enc(n, d)

    if n == 1 then 
        mode = util.clamp(mode+d,1,3)        
    
    -- macro
    elseif mode == 1 then 

        if edit_ch >= 1 then
            if n == 2 then
                if alt==false then -- réglage demi-ton global
                    --params:delta("semitone", d)
                    params:delta("scale",d)
                else -- modifier 'step' pour sequins principal (canal 1)
                    local seq1 = peek(char_seq[1]) -- char_seq[1][1]:step(1)
                    zone_range = range[8].x2 - range[8].x1
                    local stepsize = util.clamp(seq1.n + d, -zone_range, zone_range) -- prend en compte taille du sequins pour step min/max
                    seq1:step(stepsize)
                end
            elseif n == 3 then
                if alt==false then -- réglage cents global
                    params:delta("semitone", d)
                else -- TODO : cents
                    --cents = util.clamp(cents + d * 0.01, -0.99,0.99)
                end
            end
        end

    -- edition nested-sequins choisi
    elseif mode == 2 then
        if edit_ch == 1 then 
            if n == 2 then
                if alt==false then -- choix gamme (vue nom)
                    --params:delta("scale",d)
                else -- choix gamme (vue intervalles)
                    --params:delta("scale",d)
                end
            elseif n == 3 then
                if alt==false then -- octave
                    params:delta("octave1",d)
                    --octave1 = util.clamp(octave1 + d*1,-3,3)
                else -- TOCHANGE : ???
                    --cents = util.clamp(cents + d * 0.01, -0.99,0.99)
                end
            end
        elseif edit_ch == 2 then
            if n == 2 then
                if alt==false then -- choix gamme
                    --params:delta("scale",d)
                else -- choix gamme (vue intervalles)
                    --params:delta("scale",d)
                end
            elseif n == 3 then
                if alt==false then -- octave
                    params:delta("octave2",d)
                else -- TOCHANGE : ???
                    --cents = util.clamp(cents + d * 0.1, -10.0,10.0)
                end
            end
        elseif edit_ch == 3 then
            if n == 2 then
                if alt==false then -- choix gamme
                    --params:delta("scale",d)
                else -- choix gamme (vue intervalles)
                    --params:delta("scale",d)
                end
            elseif n == 3 then
                if alt==false then -- octave
                    params:delta("octave3",d)
                else -- TOCHANGE : ???
                    --cents = util.clamp(cents + d * 0.1, -10.0,10.0)
                end
            end
        elseif edit_ch == 4 then
            if n == 2 then
                if alt==false then -- choix gamme
                    --params:delta("scale",d)
                else -- choix gamme (vue intervalles)
                    --params:delta("scale",d)
                end
            elseif n == 3 then
                if alt==false then -- octave
                    params:delta("octave4",d)
                else -- TOCHANGE : ???
                    --cents = util.clamp(cents + d * 0.1, -10.0,10.0)
                end
            end
        end
    -- options/canal
    elseif mode == 3 then
        if edit_ch == 1 then -- JF + Rings
            if n == 2 then
                item_nbrcnl1 = util.clamp(item_nbrcnl1 + d, 1, #optid_tblcnl1)
                optid3 = optid_tblcnl1[item_nbrcnl1]
            elseif n == 3 then
                if optid3 == 'jf_run' then
                    params:delta("jf_run",d)
                elseif optid3 == 'octaveRings' then
                    params:delta('octaveRings',d)
                elseif optid3 == 'solofond' then
                    selec_fond = util.clamp(selec_fond + d, 1, 2)
                    params:set('solofond', selec_fond)
                elseif optid3 == 'randrift_jf' then
                    params:delta('randrift_jf',d)
                elseif optid3 == 'randrift_rgs' then
                    params:delta('randrift_rgs',d)
                end
            end
        elseif edit_ch == 2 then -- w/syn1
            if n == 2 then
                item_nbr = util.clamp(item_nbr+d,1,#optid_tbl)
                optid = optid_tbl[item_nbr]
            elseif n == 3 then
                if optid == 'wsyn_curve' then
                    params:delta("wsyn_curve",d)
                elseif optid == 'wsyn_ramp' then
                    params:delta("wsyn_ramp",d)
                elseif optid == 'wsyn_fm_index' then
                    params:delta("wsyn_fm_index",d)
                elseif optid == 'wsyn_fm_env' then
                    params:delta("wsyn_fm_env",d)
                elseif optid == 'wsyn_fm_ratio_num' then
                    params:delta("wsyn_fm_ratio_num",d)
                elseif optid == 'wsyn_fm_ratio_den' then
                    params:delta("wsyn_fm_ratio_den",d)
                elseif optid == 'wsyn_lpg_time' then
                    params:delta("wsyn_lpg_time",d)
                elseif optid == 'wsyn_lpg_symmetry' then
                    params:delta("wsyn_lpg_symmetry",d)
                elseif optid == 'wsyn_patch_this' then
                    params:delta("wsyn_patch_this",d)
                elseif optid == 'wsyn_patch_that' then
                    params:delta("wsyn_patch_that",d)
                end
            end
        elseif edit_ch == 3 then -- w/syn2
            if n == 2 then
                item_nbr2 = util.clamp(item_nbr2+d,1,#optid_tbl2)
                optid2 = optid_tbl2[item_nbr2]
            elseif n == 3 then
                if optid2 == 'wsyn_curve2' then
                    params:delta("wsyn_curve2",d)
                elseif optid2 == 'wsyn_ramp2' then
                    params:delta("wsyn_ramp2",d)
                elseif optid2 == 'wsyn_fm_index2' then
                    params:delta("wsyn_fm_index2",d)
                elseif optid2 == 'wsyn_fm_env2' then
                    params:delta("wsyn_fm_env2",d)
                elseif optid2 == 'wsyn_fm_ratio_num2' then
                    params:delta("wsyn_fm_ratio_num2",d)
                elseif optid2 == 'wsyn_fm_ratio_den2' then
                    params:delta("wsyn_fm_ratio_den2",d)
                elseif optid2 == 'wsyn_lpg_time2' then
                    params:delta("wsyn_lpg_time2",d)
                elseif optid2 == 'wsyn_lpg_symmetry2' then
                    params:delta("wsyn_lpg_symmetry2",d)
                elseif optid2 == 'wsyn_patch_this2' then
                    params:delta("wsyn_patch_this2",d)
                elseif optid2 == 'wsyn_patch_that2' then
                    params:delta("wsyn_patch_that2",d)
                end
            end
        elseif edit_ch == 4 then -- Beads
            if n == 2 then
                item_nbrcnl4 = util.clamp(item_nbrcnl4 + d, 1, #optid_tblcnl4)
                optid4 = optid_tblcnl4[item_nbrcnl4]
            elseif n == 3 then
                if optid4 == 'v_oct_mute' then
                    selec_mute = util.clamp(selec_mute + d, 1, 2)
                    params:set('v_oct_mute', selec_mute)
                elseif optid4 == 'randrift4' then
                    params:delta('randrift4', d)
                end
            end
        end
    end
    
    redraw()
end

g.key = function(x,y,z)

    -- manual grid rotation
    local tempX, tempY = x, y
    x = 9 - tempY
    y = tempX

    -- canal 1
    if edit_ch == 1 then

        if z == 1 then

            if y >= 2 and y <= 8 then
                set_seq_data("cnl1", idx, x, y-1) --> "cnl1_data_3_2" — pour canal 1 sequin 3 pas 2
            
            -- zone de pas
            elseif y == 9 then 
                range[8].held = range[8].held + 1 -- tracks how many keys are down
                local difference = range[8].x2 - range[8].x1
                
                if range[8].held == 1 then -- if there's one key down... -- permet de décaler la loop sur le même nombre de pas
                    range[8].x1 = x
                    range[8].x2 = x
                    char_seq1:select(range[8].x1)
                    if difference > 0 then -- and if there's a range...
                        if x + difference <= 8 then -- and if the new start point can accommodate the range...
                            range[8].x2 = x + difference -- set the range's start point to the selected key
                        else
                            range[8].x2 = (x + difference) % 8
                        end
                    end
                elseif range[8].held == 2 then -- if there's two keys down...
                    range[8].x2 = x -- set a range endpoint
                    char_seq1:select(range[8].x1)
                end

                if range[8].x2 < range[8].x1 then -- if our second press is before our first...
                    range[8].x2 = range[8].x1 -- destroy the range.
                end

                 -- pour init every qd loop > 0 ou si un seul pas de sélectionné
                 -- permet aussi choix auto de idx avec premier pas de la boucle pour edition/affichage sur grid
                if range[8].x2 - range[8].x1 == 0 then
                    idx = range[8].x1
                    e1 = nested_every[idx]
                    every1(e1)
                    every1nst(1)
                elseif range[8].x2 - range[8].x1 > 0 then 
                    every1(1) -- envoi 1 au sequins principal pour éviter que ce soit la mauvaise valeur de e1
                    idx = range[8].x1
                    for x = 1,8 do -- récupère valeurs de every pour chaque nested-sequins
                        e1 = nested_every[x] -- envoi valeur de e1 stocké dans index sélectionné de la table nested_every et du sequins principal (synchro entre les deux tables)
                        char_seq1[x]:every(e1)
                    end
                end

            -- choix du nested-sequins
            elseif y == 1 then
                idx = x
            -- modifiers : step
            elseif y == 10 then
                --local seq_stack = char_seq[1] -- char_seq[1][1][1]:times(2)
                --local nstseq1 = peek(seq_stack)[idx]
                local nstseq1 = char_seq1[idx]
                nested_step[idx] = x
                nstseq1:step(nested_step[idx])
            -- modifiers : every
            elseif y == 11 then

                if range[8].x2 - range[8].x1 == 0 then
                    nested_every[idx] = x
                    e1 = nested_every[idx]
                    every1(e1)
                elseif range[8].x2 - range[8].x1 > 0 then 
                    nested_every[idx] = x
                    e1 = nested_every[idx]
                    every1nst(e1)
                end
            end 
        elseif z == 0 then 
            if y == 9 then -- A NE OUBLIER SI CHANGEMENT DE PLACE SUR GRID
                range[8].held = range[8].held - 1 -- reduce the held count by 1.
            end
        end
    end

    -- canal 2
    if edit_ch == 2 then

        if z == 1 then

            if y >= 2 and y <= 8 then
                set_seq_data("cnl2", idx, x, y-1) --> "cnl1_data_3_2" — pour canal 2 sequin 3 pas 2

                --local seq_stack = char_seq[2]
                --intervindx2[idx][x] = y
                --peek(seq_stack)[idx][x] = xenutil.SCALES[scale].intervals[y-1] -- en réalité -> char_seq[1][1][idx][x] = xenutil.SCALES[mode].intervals[y]
                -- envoi note (y) à index (x) de chaque nested sequins à leur index (idx) de sequin principal (via x) 
            
            -- zone de pas
            elseif y == 9 then 
                range[16].held = range[16].held + 1 -- tracks how many keys are down
                local difference = range[16].x2 - range[16].x1

                if range[16].held == 1 then -- if there's one key down... -- permet de décaler la loop sur le même nombre de pas
                    range[16].x1 = x
                    range[16].x2 = x
                    char_seq2:select(range[16].x1)
                    --reset2(x)
                    if difference > 0 then -- and if there's a range...
                        if x + difference <= 8 then -- and if the new start point can accommodate the range...
                            range[16].x2 = x + difference -- set the range's start point to the selected key
                        else
                            range[16].x2 = (x + difference) % 8
                        end
                    end
                elseif range[16].held == 2 then -- if there's two keys down...
                    range[16].x2 = x -- set a range endpoint
                    char_seq2:select(range[8].x1)
                end

                if range[16].x2 < range[16].x1 then -- if our second press is before our first...
                    range[16].x2 = range[16].x1 -- destroy the range.
                end

                 -- pour init every qd loop > 0 ou si un seul pas de sélectionné
                 -- permet aussi choix auto de idx avec premier pas de la boucle pour edition/affichage sur grid
                if range[16].x2 - range[16].x1 == 0 then
                        idx = range[16].x1
                        e2 = nested_every2[idx]
                        every2(e2)
                        every2nst(1)
                elseif range[16].x2 - range[16].x1 > 0 then 
                    every2(1) -- envoi 1 au sequins principal pour éviter que ce soit la mauvaise valeur de e1
                    idx = range[16].x1
                    for x = 1,8 do -- récupère valeurs de every pour chaque nested-sequins
                        e2 = nested_every2[x] -- envoi valeur de e1 stocké dans index sélectionné de la table nested_every et du sequins principal (synchro entre les deux tables)
                        char_seq2[x]:every(e2)
                    end
                end

            -- choix du nested-sequins
            elseif y == 1 then
                idx = x
            -- modifier : step par nested-sequins
            elseif y == 10 then
                local nstseq2 = char_seq2[idx]
                nested_step2[idx] = x
                nstseq2:step(nested_step2[idx])
            elseif y == 11 then

                if range[16].x2 - range[16].x1 == 0 then
                    nested_every2[idx] = x
                    e2 = nested_every2[idx]
                    every2(e2)
                elseif range[16].x2 - range[16].x1 > 0 then 
                    nested_every2[idx] = x
                    e2 = nested_every2[idx]
                    every2nst(e2)
                end
            end 

        elseif z == 0 then 
            if y == 9 then
                range[16].held = range[16].held - 1 -- reduce the held count by 1.
            end
        end
    end

    if edit_ch == 3 then

        if z == 1 then

            if y >= 2 and y <= 8 then
                set_seq_data("cnl3", idx, x, y-1) --> "cnl1_data_3_2" — pour canal 2 sequin 3 pas 2
                
                --local seq_stack = char_seq[3]
                --intervindx3[idx][x] = y
                --peek(seq_stack)[idx][x] = xenutil.SCALES[scale].intervals[y-1] -- en réalité -> char_seq[1][1][idx][x] = xenutil.SCALES[mode].intervals[y]
                -- envoi note (y) à index (x) de chaque nested sequins à leur index (idx) de sequin principal (via x) 
            
            -- zone de pas
            elseif y == 9 then 
                range[32].held = range[32].held + 1 -- tracks how many keys are down
                local difference = range[32].x2 - range[32].x1

                if range[32].held == 1 then -- if there's one key down... -- permet de décaler la loop sur le même nombre de pas
                    range[32].x1 = x
                    range[32].x2 = x
                    char_seq3:select(range[32].x1)
                    if difference > 0 then -- and if there's a range...
                        if x + difference <= 8 then -- and if the new start point can accommodate the range...
                            range[32].x2 = x + difference -- set the range's start point to the selected key
                        else
                            range[32].x2 = (x + difference) % 8
                        end
                    end
                elseif range[32].held == 2 then -- if there's two keys down...
                    range[32].x2 = x -- set a range endpoint
                    char_seq3:select(range[32].x1)
                end

                if range[32].x2 < range[32].x1 then -- if our second press is before our first...
                    range[32].x2 = range[32].x1 -- destroy the range.
                end

                 -- pour init every qd loop > 0 ou si un seul pas de sélectionné
                 -- permet aussi choix auto de idx avec premier pas de la boucle pour edition/affichage sur grid
                if range[32].x2 - range[32].x1 == 0 then
                    idx = range[32].x1
                    e3 = nested_every3[idx]
                    every3(e3)
                    every3nst(1)
                elseif range[32].x2 - range[32].x1 > 0 then 
                    every3(1) -- envoi 1 au sequins principal pour éviter que ce soit la mauvaise valeur de e1
                    idx = range[32].x1
                    for x = 1,8 do -- récupère valeurs de every pour chaque nested-sequins
                        e3 = nested_every3[x] -- envoi valeur de e1 stocké dans index sélectionné de la table nested_every et du sequins principal (synchro entre les deux tables)
                        char_seq3[x]:every(e3)
                    end
                end

            -- choix du nested-sequins
            elseif y == 1 then
                idx = x
            -- modifier : step par nested-sequins
            elseif y == 10 then
                local nstseq3 = char_seq3[idx]
                nested_step3[idx] = x
                nstseq3:step(nested_step3[idx])
            elseif y == 11 then

                if range[32].x2 - range[32].x1 == 0 then
                    nested_every3[idx] = x
                    e3 = nested_every3[idx]
                    every3(e3)
                elseif range[32].x2 - range[32].x1 > 0 then 
                    nested_every3[idx] = x
                    e3 = nested_every3[idx]
                    every3nst(e3)
                end
            end 

        elseif z == 0 then 
            if y == 9 then
                range[32].held = range[32].held - 1 -- reduce the held count by 1.
            end
        end
    end

    if edit_ch == 4 then

        if z == 1 then

            if y >= 2 and y <= 8 then
                set_seq_data("cnl4", idx, x, y-1) --> "cnl1_data_3_2" — pour canal 2 sequin 3 pas 2
                
                --local seq_stack = char_seq[3]
                --intervindx3[idx][x] = y
                --peek(seq_stack)[idx][x] = xenutil.SCALES[scale].intervals[y-1] -- en réalité -> char_seq[1][1][idx][x] = xenutil.SCALES[mode].intervals[y]
                -- envoi note (y) à index (x) de chaque nested sequins à leur index (idx) de sequin principal (via x) 
            
            -- zone de pas
            elseif y == 9 then 
                range[64].held = range[64].held + 1 -- tracks how many keys are down
                local difference = range[64].x2 - range[64].x1

                if range[64].held == 1 then -- if there's one key down... -- permet de décaler la loop sur le même nombre de pas
                    range[64].x1 = x
                    range[64].x2 = x
                    char_seq4:select(range[64].x1)
                    if difference > 0 then -- and if there's a range...
                        if x + difference <= 8 then -- and if the new start point can accommodate the range...
                            range[64].x2 = x + difference -- set the range's start point to the selected key
                        else
                            range[64].x2 = (x + difference) % 8
                        end
                    end
                elseif range[64].held == 2 then -- if there's two keys down...
                    range[64].x2 = x -- set a range endpoint
                    char_seq4:select(range[64].x1)
                end

                if range[64].x2 < range[64].x1 then -- if our second press is before our first...
                    range[64].x2 = range[64].x1 -- destroy the range.
                end

                 -- pour init every qd loop > 0 ou si un seul pas de sélectionné
                 -- permet aussi choix auto de idx avec premier pas de la boucle pour edition/affichage sur grid
                if range[64].x2 - range[64].x1 == 0 then
                    idx = range[64].x1
                    e4 = nested_every3[idx]
                    every4(e4)
                    every4nst(1)
                elseif range[64].x2 - range[64].x1 > 0 then 
                    every4(1) -- envoi 1 au sequins principal pour éviter que ce soit la mauvaise valeur de e1
                    idx = range[64].x1
                    for x = 1,8 do -- récupère valeurs de every pour chaque nested-sequins
                        e4 = nested_every4[x] -- envoi valeur de e1 stocké dans index sélectionné de la table nested_every et du sequins principal (synchro entre les deux tables)
                        char_seq4[x]:every(e4)
                    end
                end

            -- choix du nested-sequins
            elseif y == 1 then
                idx = x
            -- modifier : step par nested-sequins
            elseif y == 10 then
                local nstseq4 = char_seq4[idx]
                nested_step4[idx] = x
                nstseq4:step(nested_step4[idx])
            elseif y == 11 then

                if range[64].x2 - range[64].x1 == 0 then
                    nested_every4[idx] = x
                    e4 = nested_every4[idx]
                    every4(e4)
                elseif range[64].x2 - range[64].x1 > 0 then 
                    nested_every4[idx] = x
                    e4 = nested_every4[idx]
                    every4nst(e4)
                end
            end 

        elseif z == 0 then 
            if y == 9 then
                range[64].held = range[64].held - 1 -- reduce the held count by 1.
            end
        end
    end

    --print(x,y,z)

    grid_redraw() -- redraw the grid LEDs
    redraw()
    --screen_dirty = true
end

function grid_redraw(state1)
    g:all(0) -- turn all LEDs off

    if edit_ch == 1 then
        local seq1 = char_seq1
        local seq1nst = char_seq1[idx]
        for i = 1, 8 do g:led(i, char_seq1[idx][i] + 1, i == seq1nst.ix and 15 or 7) end -- affichage séquences de notes
        for i = 1, 8 do g:led(i, 1, i == idx and 15 or 2) end -- affichage nested-sequins choisi
        for x = range[8].x1, range[8].x2 do g:led(x, 9, x == seq1.ix and 15 or 7) end -- affichage zones de séquence et position sequins principal
        for i = 1, 8 do g:led(i, 10, i == nested_step[idx] and 15 or (1*i)) end -- affichage modifier step
        for i = 1, 8 do g:led(i, 11, i == nested_every[idx] and 15 or (1*i)) end -- affichage modifier every

    end

    if edit_ch == 2 then
        local seq2 = char_seq2
        local seq2nst = char_seq2[idx]
        for i = 1, 8 do g:led(i, char_seq2[idx][i] + 1, i == seq2nst.ix and 15 or 7) end -- affichage séquences de notes
        for i = 1, 8 do g:led(i,1, i == idx and 15 or 2) end -- affichage nested-sequins choisi
        for x = range[16].x1, range[16].x2 do g:led(x, 9, x == seq2.ix and 15 or 7) end -- affichage zones de séquence et position sequins principal
        for i = 1, 8 do g:led(i, 10, i == nested_step2[idx] and 15 or (1*i)) end
        for i = 1, 8 do g:led(i, 11, i == nested_every2[idx] and 15 or (1*i)) end 
    end
    
    if edit_ch == 3 then
        local seq3 = char_seq3
        local seq3nst = char_seq3[idx]
        for i = 1, 8 do g:led(i, char_seq3[idx][i] + 1, i == seq3nst.ix and 15 or 7) end -- affichage séquences de notes
        for i = 1, 8 do g:led(i,1, i == idx and 15 or 2) end -- affichage nested-sequins choisi
        for x = range[32].x1, range[32].x2 do g:led(x, 9, x == seq3.ix and 15 or 7) end -- affichage zones de séquence et position sequins principal
        for i = 1, 8 do g:led(i, 10, i == nested_step3[idx] and 15 or (1*i)) end
        for i = 1, 8 do g:led(i, 11, i == nested_every3[idx] and 15 or (1*i)) end 
    end
    
    if edit_ch == 4 then
        local seq4 = char_seq4
        local seq4nst = char_seq4[idx]
        for i = 1, 8 do g:led(i, char_seq4[idx][i] + 1, i == seq4nst.ix and 15 or 7) end -- affichage séquences de notes
        for i = 1, 8 do g:led(i,1, i == idx and 15 or 2) end -- affichage nested-sequins choisi
        for x = range[64].x1, range[64].x2 do g:led(x, 9, x == seq4.ix and 15 or 7) end -- affichage zones de séquence et position sequins principal
        for i = 1, 8 do g:led(i, 10, i == nested_step4[idx] and 15 or (1*i)) end
        for i = 1, 8 do g:led(i, 11, i == nested_every4[idx] and 15 or (1*i)) end 
    end

    g:refresh()
end

function redraw()

    if _menu.mode then return end

screen.clear()
screen.aa(1)
screen.font_face(1)
screen.font_size(8) 

    -- affiche canal sélectionné
    for i=1,4 do
        screen.level(edit_ch == i and 15 or 5)
        screen.move(((128/4)*(i-1)), 64)
        screen.line_rel(30, 0)
        screen.line_cap("butt") 
        screen.line_width(1)
        screen.stroke()
    end

    -- affiche page menu sélectionnée
    for i=1,3 do
        screen.level(mode == i and 15 or 5)
        screen.move(((128/3)*(i-1)), 0)
        screen.line_rel(40, 0)
        screen.line_cap("butt") 
        screen.line_width(1)
        screen.stroke()
    end
    

    if mode == 1 then

        local seq1 = char_seq1
        for i=1,seq1.length do
            screen.level(seq1.ix == i and 15 or 1)
            screen.move(16*(i-1),20)
            local v = xenutil.SCALES[scale].interv_name[char_seq1[i]:peek()] -- peek pour afficher valeur en cours de chaque sequins
            screen.text(v)
        end

        local seq2 = char_seq2
        for i=1,seq2.length do
            screen.level(seq2.ix == i and 15 or 1)
            screen.move(16*(i-1), 28)
            local v = xenutil.SCALES[scale].interv_name[char_seq2[i]:peek()] -- peek pour afficher valeur en cours de chaque sequins
            screen.text(v)
        end

        local seq3 = char_seq3
        for i=1,seq3.length do
            screen.level(seq3.ix == i and 15 or 1)
            screen.move(16*(i-1), 36)
            local v = xenutil.SCALES[scale].interv_name[char_seq3[i]:peek()] -- peek pour afficher valeur en cours de chaque sequins
            screen.text(v)
        end

        local seq4 = char_seq4
        for i=1,seq4.length do
            screen.level(seq4.ix == i and 15 or 1)
            screen.move(16*(i-1), 44)
            local v = xenutil.SCALES[scale].interv_name[char_seq4[i]:peek()] -- peek pour afficher valeur en cours de chaque sequins
            screen.text(v)
        end

        screen.level(15)
        screen.move(128,60)
        screen.text_right(alt == false and "demi-ton " .. params:get("semitone") or "") -- CHANGE : demi-ton à droite de l'écran


        -- affiche la gamme sélectionnée (vue nom/vue intervalles)
        if not alt == true then
            screen.level(15)
            screen.move(0, 60)
            screen.text(xenutil.SCALES[params:get("scale")].name)
        else
            for i=1,#xenutil.SCALES[params:get("scale")].interv_name do 
                screen.level(15)
                screen.move(14*(i-1), 60)
                screen.text(xenutil.SCALES[params:get("scale")].interv_name[i])
            end
        end
            
        --[[ screen.level(15)
        screen.move(128,60)
        screen.text_right(alt == false and "cents " .. math.floor(params:get("cents")*100) or "") -- *100 pour afficher nombre entier en cents - floor pour nbr entier ]]
        

    elseif mode == 2 then

        -- affiche barre sous nested-sequins sélectionné
        screen.level(15)
        screen.move(16*(idx-1), 22)
        screen.line_width(1)
        screen.line_rel(8, 0)
        screen.stroke()

        -- octave / demi-ton

        if edit_ch == 1 then
            screen.level(15)
            screen.move(128,60)
            screen.text_right(alt == false and "octave " .. params:get("octave1") or "")
        elseif edit_ch == 2 then
            screen.level(15)
            screen.move(128,60)
            screen.text_right(alt == false and "octave " .. params:get("octave2") or "")
        elseif edit_ch == 3 then
            screen.level(15)
            screen.move(128,60)
            screen.text_right(alt == false and "octave " .. params:get("octave3") or "")
        elseif edit_ch == 4 then
            screen.level(15)
            screen.move(128,60)
            screen.text_right(alt == false and "octave " .. params:get("octave4") or "")
        end

        -- affiche les sequins principaux seulement pour sequin macro sélectionné

        if edit_ch == 1 then

            --local seq1 = char_seq1
            for i=1,char_seq1.length do
                screen.level(char_seq1.ix == i and 15 or 1)
                screen.move(16*(i-1),20)
                local v = xenutil.SCALES[params:get("scale")].interv_name[char_seq1[i]:peek()] -- peek pour afficher valeur en cours de chaque sequins
                screen.text(v)
            end

        end

        if edit_ch == 2 then
            for i=1,char_seq2.length do
                screen.level(char_seq2.ix == i and 15 or 1)
                screen.move(16*(i-1), 20)
                local v = xenutil.SCALES[params:get("scale")].interv_name[char_seq2[i]:peek()] -- peek pour afficher valeur en cours de chaque sequins
                screen.text(v)
            end
        end

        if edit_ch == 3 then
            for i=1,char_seq3.length do
                screen.level(char_seq3.ix == i and 15 or 1)
                screen.move(16*(i-1), 20)
                local v = xenutil.SCALES[params:get("scale")].interv_name[char_seq3[i]:peek()] -- peek pour afficher valeur en cours de chaque sequins
                screen.text(v)
            end
        end

        if edit_ch == 4 then
            for i=1,char_seq4.length do
                screen.level(char_seq4.ix == i and 15 or 1)
                screen.move(16*(i-1), 20)
                local v = xenutil.SCALES[params:get("scale")].interv_name[char_seq4[i]:peek()] -- peek pour afficher valeur en cours de chaque sequins
                screen.text(v)
            end
        end

        -- affiche nested-sequins sélectionné 
        if edit_ch == 1 then
            local seq1nst = char_seq1[idx]
            for i=1,seq1nst.length do
                screen.level(seq1nst.ix == i and 15 or 1)
                screen.move(16*(i-1), 36)
                local v = xenutil.SCALES[params:get("scale")].interv_name[char_seq1[idx][i]] -- pas besoin de peek() on affiche le contenu de toute la table pour chercher le nom correspondant
                screen.text(v)
            end
        end

        if edit_ch == 2 then
            local seq2nst = char_seq2[idx]
            for i=1,seq2nst.length do
                screen.level(seq2nst.ix == i and 15 or 1)
                screen.move(16*(i-1), 36)
                local v = xenutil.SCALES[params:get("scale")].interv_name[char_seq2[idx][i]]
                screen.text(v)
            end
        end

        if edit_ch == 3 then
            local seq3nst = char_seq3[idx]
            for i=1,seq3nst.length do
                screen.level(seq3nst.ix == i and 15 or 1)
                screen.move(16*(i-1), 36)
                local v = xenutil.SCALES[params:get("scale")].interv_name[char_seq3[idx][i]]
                screen.text(v)
            end
        end

        if edit_ch == 4 then
            local seq4nst = char_seq4[idx]
            for i=1,seq4nst.length do
                screen.level(seq4nst.ix == i and 15 or 1)
                screen.move(16*(i-1), 36)
                local v = xenutil.SCALES[params:get("scale")].interv_name[char_seq4[idx][i]]
                screen.text(v)
            end
        end

    elseif mode == 3 then --w/syn params menu

        if edit_ch == 1 then
            screen.level(optid3 == 'jf_run' and 15 or 1)
            screen.move(0,10)
            screen.text("JF run")
            screen.move(45,10)
            screen.text(params:get('jf_run'))

            screen.level(optid3 == 'randrift_jf' and 15 or 1)
            screen.move(0,20)
            screen.text('Rand pitch')
            screen.move(45,20)
            screen.text((params:get('randrift_jf') * 100))

            screen.level(optid3 == 'octaveRings' and 15 or 1)
            screen.move(65,10)
            screen.text("Rings oct")
            screen.move(110,10)
            screen.text(params:get('octaveRings'))

            screen.level(optid3 == 'solofond' and 15 or 1)
            screen.move(65,20)
            screen.text("Solo fond")
            screen.move(110,20)
            screen.text(params:string('solofond'))

            screen.level(optid3 == 'randrift_rgs' and 15 or 1)
            screen.move(65,30)
            screen.text('Rand pitch')
            screen.move(110,30)
            screen.text((params:get('randrift_rgs') * 100))


        end


        if edit_ch == 2 then
            screen.level(optid == 'wsyn_curve' and 15 or 1)
            screen.move(0,10)
            screen.text("curve")
            screen.move(45,10)
            screen.text(params:get('wsyn_curve'))

            screen.level(optid == 'wsyn_ramp' and 15 or 1)
            screen.move(0,20)
            screen.text("ramp")
            screen.move(45,20)
            screen.text(params:get('wsyn_ramp'))

            screen.level(optid == 'wsyn_fm_index' and 15 or 1)
            screen.move(0,30)
            screen.text("fm index")
            screen.move(45,30)
            screen.text(params:get('wsyn_fm_index'))

            screen.level(optid == 'wsyn_fm_env' and 15 or 1)
            screen.move(0,40)
            screen.text("env")
            screen.move(45,40)
            screen.text(params:get('wsyn_fm_env'))

            screen.level(optid == 'wsyn_fm_ratio_num' and 15 or 1)
            screen.move(0,50)
            screen.text("ratio num")
            screen.move(45,50)
            screen.text(params:get('wsyn_fm_ratio_num'))

            screen.level(optid == 'wsyn_fm_ratio_den' and 15 or 1)
            screen.move(0,60)
            screen.text("ratio den")
            screen.move(45,60)
            screen.text(params:get('wsyn_fm_ratio_den'))

            screen.level(optid == 'wsyn_lpg_time' and 15 or 1)
            screen.move(65,10)
            screen.text("lpg time")
            screen.move(105,10)
            screen.text(params:get('wsyn_lpg_time'))

            screen.level(optid == 'wsyn_lpg_symmetry' and 15 or 1)
            screen.move(65,20)
            screen.text("lpg sym")
            screen.move(105,20)
            screen.text(params:get('wsyn_lpg_symmetry'))

            screen.level(optid == 'wsyn_patch_this' and 15 or 1)
            screen.move(65,30)
            screen.text("this")
            screen.move(90,30)
            screen.text(params:string('wsyn_patch_this'))

            screen.level(optid == 'wsyn_patch_that' and 15 or 1)
            screen.move(65,40)
            screen.text("that")
            screen.move(90,40)
            screen.text(params:string('wsyn_patch_that'))
        end

        if edit_ch == 3 then
            screen.level(optid2 == 'wsyn_curve2' and 15 or 1)
            screen.move(0,10)
            screen.text("curve")
            screen.move(45,10)
            screen.text(params:get('wsyn_curve2'))

            screen.level(optid2 == 'wsyn_ramp2' and 15 or 1)
            screen.move(0,20)
            screen.text("ramp")
            screen.move(45,20)
            screen.text(params:get('wsyn_ramp2'))

            screen.level(optid2 == 'wsyn_fm_index2' and 15 or 1)
            screen.move(0,30)
            screen.text("fm index")
            screen.move(45,30)
            screen.text(params:get('wsyn_fm_index2'))

            screen.level(optid2 == 'wsyn_fm_env2' and 15 or 1)
            screen.move(0,40)
            screen.text("env")
            screen.move(45,40)
            screen.text(params:get('wsyn_fm_env2'))

            screen.level(optid2 == 'wsyn_fm_ratio_num2' and 15 or 1)
            screen.move(0,50)
            screen.text("ratio num")
            screen.move(45,50)
            screen.text(params:get('wsyn_fm_ratio_num2'))

            screen.level(optid2 == 'wsyn_fm_ratio_den2' and 15 or 1)
            screen.move(0,60)
            screen.text("ratio den")
            screen.move(45,60)
            screen.text(params:get('wsyn_fm_ratio_den2'))

            screen.level(optid2 == 'wsyn_lpg_time2' and 15 or 1)
            screen.move(65,10)
            screen.text("lpg time")
            screen.move(105,10)
            screen.text(params:get('wsyn_lpg_time2'))

            screen.level(optid2 == 'wsyn_lpg_symmetry2' and 15 or 1)
            screen.move(65,20)
            screen.text("lpg sym")
            screen.move(105,20)
            screen.text(params:get('wsyn_lpg_symmetry2'))

            screen.level(optid2 == 'wsyn_patch_this2' and 15 or 1)
            screen.move(65,30)
            screen.text("this")
            screen.move(90,30)
            screen.text(params:string('wsyn_patch_this2'))

            screen.level(optid2 == 'wsyn_patch_that2' and 15 or 1)
            screen.move(65,40)
            screen.text("that")
            screen.move(90,40)
            screen.text(params:string('wsyn_patch_that2'))
        end

        if edit_ch == 4 then
            screen.level(optid4 == 'v_oct_mute' and 15 or 1)
            screen.move(0,10)
            screen.text('Mute 8ve')
            screen.move(45,10)
            screen.text(params:string('v_oct_mute'))

            screen.level(optid4 == 'randrift4' and 15 or 1)
            screen.move(0,20)
            screen.text('Rand pitch')
            screen.move(45,20)
            screen.text((params:get('randrift4') * 100))
        end

    end
    screen.update()
end

function cleanup()
    -- restore default rotation on script clear (from Metrix)
    function grid:led(x, y, val)
      _norns.grid_set_led(self.dev, x, y, val)
    end

    clock.cancel(poll_clock_id) -- melt our clock vie the id we noted
    --clock.cancel(poll_clock_id2) -- melt our clock vie the id we noted
    
end
