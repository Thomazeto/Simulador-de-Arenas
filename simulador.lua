
--  PARÂMETROS DA SIMULAÇÃO:
local winrate = 0.50 -- 0 a 1 ou fracional
local num_partidas = 500000 -- número par
local tx_snipe = 0.96 -- 0 a 1 ou fracional // default: 0.96
local rating_minimo_snipe = 2200 -- número // default: 2200
local rating_rank1 = 3600 -- número
--[[
      Instruções:
winrate = taxa de vitórias do player simulado, 0.5 ou 5/10 funcionam da mesma forma.
num_partidas = quantidade de partidas a serem simuladas por cenário e modelo, utilize números pares para facilitar o cálculo de médias.
tx_snipe = taxa de sucesso da tentativa de snipe, 0.5 ou 5/10 funcionam da mesma forma.
rating_minimo_snipe = indicação do rating minimo que o usuário que tenta snipe (qualquer cenário) está disposto a enfrentar, 
  essa variavel altera principalmente a velocidade com que o rating sobe no inicio.
rating_rank1 = serve como o limite do maior mmr inimigo que o player simulado pode enfrentar, 
  afinal não tem como enfrentar alguém acima do rank 1 (ou rank 2, se o player simulado o ultrapassar).
]]

--  OPÇÕES DA SIMULAÇÃO:
local seeds = {8487681234287, 165468721358, 34567862637125, 4678661001, 656478841512}
local quantidade_seeds = 3 -- 1 a #seeds
local simular_sem_snipe = true -- boolean
local simular_evitar_lows = true -- boolean
local simular_snipe = true -- boolean
local simular_snipe_forte = true -- boolean
local simular_modelo_atal = true -- boolean
local simular_modelo_proposto = true -- boolean
local mostrar_evolucao = true -- boolean
--[[
      Instruções:
seeds = tabela com as seeds fixas utilizadas pelo simulador, não há necessidade em alterar, mas as seeds podem ser alteradas ou novas podem ser adicionadas
quantidade_seeds = quantidade de seeds a serem utilizadas na simulação
simular_sem_snipe = simula o player joinando aleatoriamente
simular_evitar_lows = simula o player dando snipe em times com 150 de mmr a mais ou a menos que seu rating
simular_snipe = simula o player dando snipe em times com 100 a 300 de mmr a mais que seu rating
simular_snipe_forte = simula o player dando snipe em times com 400 a 600 de mmr acima do seu rating
simular_modelo_atal = simula o cenário utilizando o cálculo atual do servidor
simular_modelo_proposto = simula o cenário utilizando a minha proposta
mostrar_evolucao = mostra as partidas necessárias para se chegar aos pontos de interesse, como shoulder e arma
]]

--[[ 
  OBS: para printar o log das arenas no terminal, observe as anotações na linha 210
]]


-- CÓDIGO:

-- checa o resultado da arena simulada
local function checar_vitoria()
  return (math.random() <= winrate) and true or false
end

-- simula um time adversário
local function criar_adversario(rating_atual, modo)
  local rng = math.random()
  local mmr_min, mmr_max

  if modo == "SNIPE_FORTE" then
    if rng <= tx_snipe then -- checa se conseguiu dar o snipe
      -- vai joinar se tiver um time com no minimo 400 de mmr acima do seu rating
      mmr_min = math.max(rating_atual + 400, rating_minimo_snipe)
      mmr_max = mmr_min + 200
    else
      -- snipe falhou, caiu contra algum time de mmr menor
      mmr_min, mmr_max = 1400, 2000
    end
  elseif modo == "SNIPE" then
    if rng <= tx_snipe then
      -- vai joinar se tiver um time com no minimo 100 de mmr acima do seu rating
      mmr_min = math.max(rating_atual + 100, rating_minimo_snipe)
      mmr_max = mmr_min + 200
    else
      -- snipe falhou
      mmr_min, mmr_max = 1400, 2000
    end
  elseif modo == "EVITAR_LOW" then
    if rng <= tx_snipe then
      -- aceita joinar contra times que possuam até 150 mmr a menos que seu rating
      mmr_min = math.max(rating_atual - 150, rating_minimo_snipe)
      mmr_max = mmr_min + 300
    else
      -- snipe falhou
      mmr_min, mmr_max = 1400, 2000
    end
  elseif modo == "NORMAL" then
    -- modo livre, pode cair contra qualquer mmr, com a seguinte distribuição:
    if rng <= 0.04 then
      mmr_min, mmr_max =  1300, 1400 -- 4%
    elseif rng <= 0.10 then
      mmr_min, mmr_max =  1400, 1500 -- 6%
    elseif rng <= 0.30 then
      mmr_min, mmr_max =  1500, 1600 -- 20%
    elseif rng <= 0.47 then
      mmr_min, mmr_max =  1600, 1700 -- 17%
    elseif rng <= 0.62 then 
      mmr_min, mmr_max =  1700, 1800 -- 15%
    elseif rng <= 0.72 then 
      mmr_min, mmr_max =  1800, 1900 -- 10%
    elseif rng <= 0.82 then 
      mmr_min, mmr_max =  1900, 2000 -- 10%
    elseif rng <= 0.88 then
      mmr_min, mmr_max =  2000, 2100 -- 6%
    elseif rng <= 0.92 then 
      mmr_min, mmr_max =  2100, 2200 -- 4%
    elseif rng <= 0.95 then 
      mmr_min, mmr_max =  2200, 2300 -- 3%
    elseif rng <= 0.98 then 
      mmr_min, mmr_max =  2300, 2500 -- 3%
    elseif rng <= 0.995 then
      mmr_min, mmr_max =  2500, 2800 -- 1.5%
    else
      mmr_min, mmr_max =  2800, rating_rank1 -- 0.5%
    end
  end

  if mmr_max > rating_rank1 then mmr_max = rating_rank1 end -- não tem como existir um adversário com mais rating que o rank 1
  if mmr_min > mmr_max then mmr_min = mmr_max - 200 end -- para caso tenhamos diminuido o mmr máximo devido ao cap do rank1

  return mmr_min, mmr_max
end

-- calcula a probabilidade de um time vencer o outro
local function calcular_chance(mmr_oponente, meu_rating, modelo_proposto)
  -- solução proposta
  if modelo_proposto and meu_rating >= 1300 then
    local cap_max, cap_min = 0, 0

    if meu_rating >= 2200 then 
      cap_max, cap_min = meu_rating, math.max(1700, meu_rating - 600)
    elseif meu_rating >= 2000 then 
      cap_max, cap_min = 2200, meu_rating - 500
    else
      cap_max, cap_min = 2000, meu_rating - 400
    end

    if mmr_oponente > meu_rating then mmr_oponente = math.min(mmr_oponente, cap_max) end
    if mmr_oponente < meu_rating then mmr_oponente = math.max(mmr_oponente, cap_min) end
  end

  -- retirado do repositorio do trinitycore
  return 1 / (1 + math.exp(math.log(10) * (mmr_oponente - meu_rating) / 650))
end

-- calcula a quantidade de rating ganho ou perdido na arena
-- lógica retirada do repositorio do trinitycore
local function calcular_mod(meu_rating, mmr_oponente, vitoria, modelo_proposto)
  local chance = calcular_chance(mmr_oponente, meu_rating, modelo_proposto)
  local mod = 0

  if vitoria then
    if meu_rating < 1300 then
      if meu_rating < 1000 then
        mod = 48 * (1 - chance)
      else
        mod = (24 + (24 * (1300 - meu_rating) / 300)) * (1 - chance)
      end
    else
      mod = 24 * (1 - chance)
    end
  else
    mod = 24 * (0 - chance)
  end

  return math.ceil(mod)
end

-- simula um cenário
local function simular(seed, modelo_proposto, modo)

  -- seed fixa para não haver distorções no comparativo
  math.randomseed(seed)

  -- variaveis para monitoramento
  local rating_atual = 0
  local soma_metade_final = 0 -- para calcular o rating médio
  local partida_ratmax = 0 -- partida na qual alcançou o rating maximo
  local partida_rank1 -- partida na qual ultrapassou o rating do rank 1
  local rating_maximo, vitorias = 0, 0 -- estatisticas
  local partidas1800, partidas2000, partidas2200, partidas2300, partidas2600
  local partidas3000, partidas3400, partidas3800, partidas4000, partidas4100

  for i = 1, num_partidas do
    local vitoria = checar_vitoria()
    local mmr_oponente = math.random(criar_adversario(rating_atual, modo))
    if vitoria then vitorias = vitorias + 1 end

    local mod = calcular_mod(rating_atual, mmr_oponente, vitoria, modelo_proposto)
    rating_atual = rating_atual + mod
    if rating_atual < 0 then rating_atual = 0 end
    if not partida_rank1 and rating_atual > rating_rank1 then partida_rank1 = i end
    if rating_atual > rating_maximo then 
      rating_maximo = rating_atual 
      partida_ratmax = i
    end
    if mostrar_evolucao then
      if not partidas1800 and rating_atual >= 1800 then partidas1800 = i end
      if not partidas2000 and rating_atual >= 2000 then partidas2000 = i end
      if not partidas2200 and rating_atual >= 2200 then partidas2200 = i end
      if not partidas2300 and rating_atual >= 2300 then partidas2300 = i end
      if not partidas2600 and rating_atual >= 2600 then partidas2600 = i end
      if not partidas3000 and rating_atual >= 3000 then partidas3000 = i end
      if not partidas3400 and rating_atual >= 3400 then partidas3400 = i end
      if not partidas3800 and rating_atual >= 3800 then partidas3800 = i end
      if not partidas4000 and rating_atual >= 4000 then partidas4000 = i end
      if not partidas4100 and rating_atual >= 4100 then partidas4100 = i end
    end
    if i >= (num_partidas / 2) then soma_metade_final = soma_metade_final + rating_atual end

    -- mostrar o log de arenas no terminal
    -- com o log ativo, é melhor utilizar chamada unica da simulação em vez de varias chamadas para comparativo
    --if i % X == 0 then -- mostra uma arena a cada X
    --if i <= X then  -- mostra até a arena X ou a partir da X (>=)
    --  print("Arena " .. i .. ": MMR Oponente = ".. mmr_oponente .." - " .. (vitoria and "Vitoria" or "Derrota") .." (".. mod .. ") - Novo Rating: ".. rating_atual)
    --end
  end

  print("\n" .. (modelo_proposto and "Modelo Proposto" or "Modelo Atual") .. "\nWinrate: " .. (vitorias / num_partidas * 100) .."%")
  if mostrar_evolucao then
    if partidas1800 then print("Comprou arma T1 após " .. partidas1800 .. " partidas") end
    if partidas2000 then print("Comprou shoulder após " .. partidas2000 .. " partidas") end
    if partidas2200 then print("Comprou arma T2 após " .. partidas2200 .. " partidas") end
    if partidas2300 then print("Comprou tabard após " .. partidas2300 .. " partidas") end
    if partidas2600 then print("Chegou em 2600 após " .. partidas2600 .. " partidas") end
    if partidas3000 then print("Chegou em 3000 após " .. partidas3000 .. " partidas") end
    if partidas3400 then print("Chegou em 3400 após " .. partidas3400 .. " partidas") end
    if partidas3800 then print("Chegou em 3800 após " .. partidas3800 .. " partidas") end
    if partidas4000 then print("Chegou em 4000 após " .. partidas4000 .. " partidas") end
    if partidas4100 then print("Chegou em 4100 após " .. partidas4100 .. " partidas") end
    if partida_rank1 then print("Passou o rating do rank 1 após " .. partida_rank1 .. " partidas") end
 end
  print("Rating potencial máximo: " .. rating_maximo .." (atingido na partida n.º " .. partida_ratmax ..")")
  print("Rating médio estabilizado: " .. math.ceil(soma_metade_final / (num_partidas / 2)))
end

-- cabeçalho com os parametros da simulação
if quantidade_seeds >= 1 then
  print("### RESULTADO DA SIMULAÇÃO ###\n--- Partidas: " .. num_partidas .." - Winrate informado: " .. winrate * 100 .. "%")
  if simular_snipe or simular_evitar_lows then 
    print("--- Taxa de sucesso do snipe/dodge: " ..(tx_snipe * 100) .. "%")
    print("--- Rating mínimo para dar snipe: " .. rating_minimo_snipe)
  end
  print("--- Rating do player no rank 1: " .. rating_rank1)
end

local seeds_simuladas = 0
-- gerencia as simulações conforme os parametros definidos
for i = 1, #seeds do
  if seeds_simuladas == quantidade_seeds then return end
  seeds_simuladas = seeds_simuladas + 1

  print("\n--------------- Seed " .. i .." (" .. seeds[i] .. ") ---------------")

  if simular_sem_snipe then
    print("\n>> joinando aleatoriamente:")
    if simular_modelo_atal then
      simular(seeds[i], false, "NORMAL")
    end
    if simular_modelo_proposto then
      simular(seeds[i], true, "NORMAL")
    end
  end

  if simular_evitar_lows then
    print("\n>> tentando cair sempre com times próximos do seu rating:")
    if simular_modelo_atal then
      simular(seeds[i], false, "EVITAR_LOW")
    end
    if simular_modelo_proposto then
      simular(seeds[i], true, "EVITAR_LOW")
    end
  end

  if simular_snipe then
    print("\n>> tentando dar snipe para cair contra times ligeiramente acima do seu rating:")
    if simular_modelo_atal then
      simular(seeds[i], false, "SNIPE")
    end
    if simular_modelo_proposto then
      simular(seeds[i], true, "SNIPE")
    end
  end

  if simular_snipe_forte then
    print("\n>> tentando dar snipe em times MUITO acima do seu rating:")
    if simular_modelo_atal then
      simular(seeds[i], false, "SNIPE_FORTE")
    end
    if simular_modelo_proposto then
      simular(seeds[i], true, "SNIPE_FORTE")
    end
  end
end
