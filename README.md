# Simulador-de-Arenas
Simulador da evolução de rating em arenas soloqueue no servidor WoW-Brasil.

--------- ############### O que está acontecendo hoje? ############### ---------

Descrição do problema:

Atualmente, no sistema de soloqueue do servidor é possível inflar seu rating de forma artificial, exploitando uma "falha" do projeto na formação dos times, considerando que o sistema de cálculo de rating ganho ou perdido por partida foi pensado em um sistema diferente de matchmaking.

O exploit se resume a escolher propositadamente cair contra times com MMR muito maior que o seu rating atual, o que é impossível nas arenas 2v2 ou 3v3, como mostrarei:

Nas arenas 2v2 ou 3v3, a fila funciona da seguinte forma: ao entrar na fila, vamos supor que com 1900 de mmr, o sistema vai procurar times com mmr próximo ao seu, algo entre 1800 mmr e 2000 mmr, após alguns segundos sem encontrar um time nesse intervalo, o sistema vai aumentar a tolerância e procurar equipes entre 1700 e 2100 mmr, e assim sucessivamente até chegar em um limite, e caso não encontre nenhum time em 10 minutos, dentro desse limite, o sistema libera para que você jogue contra qualquer outro time da fila, portanto é inviável para esse player de 1900 de mmr tentar cair de forma proposital contra um time de por exemplo 3000 de mmr, pois quem escolhe seu adversário é o servidor.

Por esse funcionamento, chamamos de "fila" por uma questão de conveniência, pois na verdade é um sistema de registros e casamentos, como um booking de ofertas em bolsa de valores, ou o tinder, o foco é em encontrar dois registros compativeis, independente de quanto tempo eles estão inscritos ali.

Nas arenas soloqueue, a fila funciona de fato como uma fila, pois assim que existem 6 players registrados, o sistema pega esses players e forma dois times, tentando equilibrar o MMR para que fiquem o mais parelho possível.

Entendendo esse funcionamento, um player pode entrar na fila em um momento calculado para ser alocado propositadamente em uma partida com jogadores de mmr muito mais alto que o seu, de forma que aquele mesmo player com 1900 mmr pode cair 100 vezes seguidas contra times proximos de 3000 mmr, pois aqui o matchmaking não é feito pelo servidor, e sim pelos próprios players, essa ação é chamada de "snipe" ou "snipar" e é muito fácil de executar, basta dar inspect em uma luta com players nessa faixa de mmr e joinar assim que a partida terminar, ou alguns pouquissimos segundos antes, dessa forma quando esses players entrarem na fila, você estará no meio deles e será um dos 6 jogadores da próxima arena.

Qual o problema disso?

O MMR do seu adversário influencia de forma MUITO forte o rating que você vai ganhar ou perder na arena, usando aquele player com 1900 de mmr como exemplo novamente, vamos supor que ele tenha também 1900 de rating:

Contra times de 1900 de mmr, ele ganharia e perderia 12 de rating por partida.

Contra times de 1700 de mmr, ele ganharia 8 e perderia -16.

Contra times de 2100 de mmr, ele ganharia 17 e perderia -8.

Contra times de 2500 de mmr, ele ganharia 22 e perderia -2.

Agora, contra times de 3000 de mmr, ele ganharia 24 e perderia 0, sim, 0!

Portanto, veja que se ele pode escolher contra quem quer cair, não há nenhuma vantagem escolher jogar contra times low, pois jogando contra times altos seu rating vai subir de forma garantida, independente do desempenho desse player, não é mais uma questão de "será que sou capaz de chegar a X rating?" e passa a ser uma questão de tempo para alcançar a marca desejada.

Há um outro agravante, pois num cenário de arenas 2v2 ou 3v3 é extremamente improvável que um time de 1900 mmr vença um time de 3000 de mmr, se essas forem suas capacidades reais, porém no soloqueue a possibilidade de vitória é muito maior, pois você pode cair com outros 2 players com mmr e capacidade muito elevadas e vencer, ou o sistema criar uma luta injusta no sentido de composição dos times, portanto o peso individual da habilidade de cada player no soloqueue é consideravelmente menor do que nos outros modos de arena.

Dessa forma é possível visualizar players com rating muito alto, como 2500 por exemplo, e score extremamente negativo, tendo vencido 30-40% das arenas disputadas, isso é completamente anti natural ao sistema de arenas, para comprovar basta procurar os rankings atuais de arena na blizzard, em qualquer versão, ou em servidores privados com comunidade pvp ativa, como o warmane, e ficará claro que ver player com winrate negativo no topo não é o comum.

Como solucionar isso?

A opção mais óbvia seria transformar a fila do soloqueue em um sistema de casamento de lutas pelo mmr, como o 2v2 e 3v3, porém isso iria de encontro com a principal vantagem do soloqueue: a sua disponibilidade e agilidade.
Hoje um player que logue e tenha vontade de fazer arena soloq, vai estar dentro de uma arena em menos de 30 segundos, pois o sistema foca em criar lutas o quanto antes, em vez de lutas equilibradas, e eu acho que esse é de fato o melhor caminho, é inegável o sucesso que vem fazendo no servidor.

A outra opção seria alterar o sistema de pontuação das partidas, para evitar o abuso, ou limitar o beneficio recebido ao abusar do sistema, tendo a preocupação de que essas alterações atinjam os seguintes objetivos: mantenha o sistema bastante parecido com o atual para quem não abusa da fila, não prejudique players que usem de forma limitada esse abuso apenas para evitar cair contra times com mmr muito abaixo do seu nível (o que no 2v2 e 3v3 seria tão improvável quanto o oposto).

Minha proposta é criar um "cap" para a diferença de MMR entre o player e seus adversários, mas não na formação da luta, e sim no cálculo da pontuação.

Eu optei por realizar a inclusão desse ajuste no cálculo da probabilidade de vitória, em vez de alterar diretamente a pontuação.

Basicamente se criariam tetos para o mmr adversário, tetos subjetivos, os quais proponho que tenham 3 fases:

1 - para jogadores com menos do que 2000 de rating, o sistema vai limitar o mmr de seus adversários em no máximo 2000, e no mínimo sendo (seu rating - 400).

2 - para jogadores entre 2000 e 2200 de rating, o limite máximo vai ser de 2200 e o mínimo de (rating - 500).

3 - acima de 2200, o limite máximo vai ser o seu próprio rating, e o mínimo vai ser (rating - 600 ou 1700, o que for menor).

Assim, quanto mais próximo de 2000 o player estiver, maior vai ficando a dificuldade, pois a quantia máxima de rating ganho por partida vai ficar menor, enquanto que a quantidade máxima perdida fica estável.

Passando dessa fase, se repete com o objetivo dos 2200 rating, e por fim ao chegar na fase final, a dificuldade de subir o rating aumenta e se mantém no mesmo nível independente do rating alcançado.

Motivação dos valores: 2000 é um objetivo comum a todos os players, pois fornece a shoulder e achiev, 2200 segue o mesmo pensamento, fornecendo a arma tier 2 e achiev, e a partir de 2200 os players concorrem por competitividade, não há um objetivo comum a todos, alguns querem ir até 2300 para pegar a tabard, outros querem chegar a 2500 pois é um número alto, outros querem a barreira mental dos 3000, outros querem chegar no rank 10, no rank 1, em fim, é muito individual, mas o que há de comum é a competitividade.

Para poder comparar se a idéia teria resultados positivos e o que mudaria em relação ao sistema atual, eu construi esse simulador, e a conclusão é:

~ Para quem joina aleatoriamente, sem se importar com nada disso, continuaria tendo basicamente o mesmo resultado, e quem faz snipe teria uma diminuição entre a diferença de jogar contra times da sua faixa de rating e times muito maiores.

~ Para joagdores bons ( 66% + de vitórias) que fazem snipe, o rating médio alcançado seria praticamente o mesmo, porém levaria um pouco mais de tempo para chegar nesse rating (são os players que vencem com frequência os outros, em qualquer modelo vão ficar no topo).

~ Para jogadores medianos (próximo de 50% de vitórias) que fazem snipe, o rating médio alcançado teria uma redução porém esse player ainda alcançaria ratings bons, capaz de comprar T2 e tabard (se esse player vence metade dos times que possuem mmr de t2 e tabard, ele merece chegar nesse ponto também).

~ Para Jogadores ruins (~ 40% de vitória) que fazem snipe, o rating médio alcançado teria uma queda consideravel, e alcançar a shoulder e a t2 para esses players seria um desafio bem maior que é hoje (está dentro da lógica de que é mais dificil pra ele do que para um player mediano, mas ainda é possível).

~ Para jogadores muito ruins (~ 33% de vitória) que fazem snipe, o rating médio alcançado tem uma queda brusca, dificultando de forma muito grande o ganho de rating.



--------- ############### Como funciona o simulador? ############### ---------


A execução realiza a simulação de um número definido de arenas, utilizando o sistema de números pseudo aleatórios, RNG, para formar o time inimigo e o resultado, com base nos parametros fornecidos, e então calcula quanto de rating o player teria ganho em cada arena, tanto no modelo atual do servidor quanto no modelo que eu proponho.


Para simular os cenários, eu considerei 4 opções: normal, snipe na mesma faixa de mmr, snipe em times levemente acima do seu rating e snipe em times muito acima do seu rating.

Precisei criar uma definição para esses cenários que é o seguinte:

normal = joina aleatoriamente, sem se importar com quem será o adversário.

snipe na mesma faixa = tenta cair em arenas em que os times estarão entre 150 mmr abaixo ou acima do seu rating.

snipe em times levemente acima do seu rating = tenta cair em arenas com mmr entre 100 e 300 acima do seu rating.

snipe em times muito acima do seu rating = tenta cair em arenas com mmr entre 400 e 600 acima do seu rating.


Criei uma taxa de sucesso do snipe, pois é possível que falhe em algum momento e o player caia em uma arena diferente da que ele imaginava, como padrão coloquei essa taxa em 96%, a versão mais recente do addon da minha guild grava um histórico de arenas disputadas, neste histórico consta o mmr dos adversários e ele pode ser inspectado por outros usuários, eu dei inspect no histórico de um jogador que eu sei que faz o snipe, e das últimas 100 arenas, apenas 4 tinham mmr baixo, portanto vou utilizar 96% como padrão.

Para o cenário "normal" eu utilizei uma distribuição do mmr dos possíveis adversários que é baseada em uma estimativa totalmente subjetiva da minha parte, por não ter acesso às informações sobre mmr dos players do servidor.


Os resultados apresentados são:

rating potencial máximo = rating máximo atingido durante toda a série simulada.

rating médio estabilizado = rating médio da última metade da série.

partidas necessárias para atingir cada objetivo (shoulder, t1, t2 etc)

partidas necessárias para ultrapassar o rating do rank 1


Limitações conhecidas do simulador:

1 - a distribuição do mmr adversário para quem joina aleatoriamente é uma estimativa, pode não coincidir com os números reais do servidor.

2 - o modelo de simulação considera que os players vão ser fiéis ao cenário escolhido para snipe, e no mundo real um player pode começar a série com uma idéia de snipe e mudar de estratégia no meio da série.

3 - o rating do rank 1 é fixo, e no mundo real ele pode ir aumentando com o tempo, é complicado implementar esse aumento no modelo pois acabaria convergindo para algo semelhante a um wintrade (o rank 1 jogando milhares de partidas contra o rank 2).


Como utilizar?

Basta copiar o código contido no arquivo simulador.lua para qualquer compilador e executar, no inicio do arquivo há instruções para alterar os parametros da simulação.

Cuidado ao utilizar compiladores online, pois a maioria possui um limite de processamento e caso opte por colocar muitas partidas simuladas e muitas seeds, pode dar timeout.

Dependendo do compilador utilizado também pode haver falhas na consistência da randomseed, depende da implementação do sistema de RNG naquele compilador.

O compilador de lua do replit.com conseguiu rodar sem problemas execuções com 20 milhões de arenas simuladas, e não possui qualquer bug em questão da randomseed, mantendo a sequência de rng intacta entre os cenários.



Killax
