% O Script é dividido por seções para cálculos das constantes de erro estático
% e obtenção do compensador. 

### % Indica onde deve ser colocado os valores solicitados pela questão 
    % ou funções de transferência

% HÁ COMANDOS QUESTÃO EM FORMA DE COMENTÁRIO, RETIRE % PARA RODA OU COPIE E
% COLE NA JANELA DE COMANDO QUANDO NECESSÁRIO

%%

%CONSTANTES DE ERRO ESTÁTICO

%%

%SEÇÃO 1

%Kp (POSIÇÃO)

clear;
syms s;
g = ###; %%%função transferência%%%
Kp = ###; %%%Kp requisitado%%%
limite = limit(g, s, 0) 
K=Kp/limite 

%%

%SEÇÃO 2

%Kv (VELOCIDADE)
clear;
syms s;
g = ###; %%%função transferência%%%
Kv = ###; %%%Kv requisitado%%%
limite = limit(s*g, s, 0) 
K=Kv/limite 


%%

%SEÇÃO 3

%Ka ACELERACAO
clear;
syms s;
g = ###; %%%função transferência%%%
Ka = ###; %%%Ka requisitado%%%
limite = limit(s*s*g, s, 0) 
K=Ka/limite 

%%

%SEÇÃO 4

%COMPENSADOR DE AVANÇO

%PRIMEIRO VERIFICAR SE O SISTEMA JÁ SUPRE PARA UM K QUE RESULTE NO ERRO
%ESTÁTICO SOLICITADO

%SEGUNDO VERIFICAR SE CUMPRE OS REQUISITOS COM BODE

clear; 
K = ###; %%%ganho obtido anteriormente%%%
s=tf('s'); 
g = ###; %%%função transferência%%%
%bode(K*g);
%figure;
[MG, MF] = margin(K*g);
fprintf('Margem de Ganho: %.2f dB\n', 20*log10(MG))
fprintf('Margem de Fase: %.2f graus\n', MF)

%TERCEIRO OBTER VALOR DE ALPHA

syms a
MFd = ###; %%%margem de fase requisitada%%%
MS = ###; %%%margem de segurança, geralmente de 5 a 12 graus%%% 
eq = (1-a)/(1+a) == sind(MFd - MF + MS); %define a equação
sol = solve(eq, a); %resolve a equação para a variável definida
alpha = double(sol) %mostra o resultado com duas casas decimais

%QUARTO OBTER FREQ DE CRUZAMENTO

[mag, phase, w] = bode(K*g); %obter dados de Bode
mag_db = 20*log10(squeeze(mag)); %converte valores em db
ganho_Wc = 20*log10(sqrt(alpha))  % Ganho que você quer encontrar
Wc = interp1(mag_db, w, ganho_Wc) % Encontrar a frequência

%QUINTO OBTER FREQ DE CORTE DO COMPENSADOR

zero = Wc*sqrt(alpha)
polo = zero/alpha

%SEXTO OBTER COMPENSADOR E TESTAR

Kc=K/alpha
Gc=Kc*(s+zero)/(s+polo);
%bode(Gc*g);
%figure;
[MG, MF] = margin(Gc*g);
fprintf('Margem de Ganho: %.2f dB\n', 20*log10(MG))
fprintf('Margem de Fase: %.2f graus\n', MF)

%VERIFICANDO DESEMPENHO PARA ENTRADA DEGRAU

% D = stepinfo(feedback(g,1))

%%%quando necessário verificar resposta ao degrau%%%
Dc = stepinfo(feedback(Gc*g,1))
Dk = stepinfo(feedback(K*g,1))  

step(feedback(Gc*g,1),feedback(K*g,1)); 
legend('Sist. compensado','Sist. sem compensar');

%%

%SEÇÃO 5

%COMPENSADOR DE ATRASO

%PRIMEIRO VERIFICAR SE O SISTEMA JÁ SUPRE PARA UM K QUE RESULTE NO ERRO
%ESTÁTICO SOLICITADO

%SEGUNDO VERIFICAR SE CUMPRE OS REQUISITOS COM BODE

clear; 
K = ###; %%%ganho obtido anteriormente, nas primeiras seções%%%
s=tf('s'); 
g = ###; %%%função transferência%%%
%bode(K*g);
%figure;
[MG, MF] = margin(K*g);
fprintf('Margem de Ganho: %.2f dB\n', 20*log10(MG))
fprintf('Margem de Fase: %.2f graus\n', MF)

%TERCEIRO OBTER FREQ DE CRUZAMENTO
%clear;
MFd = ###; %%%margem de fase requisitada%%%
MS = ###; %%%margem de seguranca geralmente de 5 a 12 graus%%%
[mag, phase, w] = bode(K*g); %obter dados de Bode
fase = squeeze(phase); %fase em graus
w_vec = squeeze(w); %frequência em rad/s
fase_c = -180 + MFd + MS %fase da freq 
Wc = interp1(fase, w_vec, fase_c)  %encontrar a frequência
mag_db = 20*log10(squeeze(mag)); %ganho em db
ganho_db = interp1(w_vec, mag_db, Wc) %obter o ganho da nova Wc

%QUARTO OBTER BETA P/ ZEROS E POLOS
beta = 10^(ganho_db/20)
zero = Wc/10
polo = zero/beta

%SEXTO OBTER COMPENSADOR E TESTAR
Kc=K/beta
Gc=Kc*(s+zero)/(s+polo);
%bode(Gc*g);
%figure;
[MG, MF] = margin(Gc*g);
fprintf('Margem de Ganho: %.2f dB\n', 20*log10(MG))
fprintf('Margem de Fase: %.2f graus\n', MF)

%VERIFICANDO DESEMPENHO PARA ENTRADA DEGRAU
% D = stepinfo(feedback(g,1))
%Dc = stepinfo(feedback(Gc*g,1))
%Dk = stepinfo(feedback(K*g,1)) 

% step(feedback(Gc*g,1),feedback(K*g,1)); 
% legend('Sist. compensado','Sist. sem compensar');
%figure;
%step(feedback(K*g,1));
step(feedback(Gc*g,1))

%%

%SEÇÃO 6

%EXTRAS

%ERROS ESTATICOS

%POR TIPO DE ENTRADA
%STEP = Amplitude/s e_ss=A/(1+Kp) 
%RAMP = A/(s^2) e_ss=A/Kv
%PARAB = A/(s^3) e_ss=A/Ka

%RESPOSTA A RAMPA UNITÁRIA

sys2=feedback(Gc*g,1); 
step(1/s,sys2/s); 
legend('Rampa unitária','Sistema compensado'); 

% Limitar eixos
xlim([0 1]);  % Ajuste o valor máximo conforme necessário
ylim([0 1]);  % Ajuste conforme sua resposta

figure; 
step(1/(s*(1+Gc*g))); %Para verificar valor do erro estacionário

%%

%SEÇÃO 7

%OBTER GANHO A PARTIR DA RESPOSTA EM FREQUENCIA PARA UM SOBRESSINAL
%REQUISITADO

%PRIMEIRO OBTER O ANGULO NECESSARIO PARA O REQUISITO

clear;
K = 1
Mp= ### %%%requisito sobressinal%%%
C=-log(Mp/100)/(sqrt((pi^2)+(log(Mp/100))^2)) %coeficiente de amortecimento
% se 0<C<0.6 o angulo gamma desejado = C*100
gamma = rad2deg(atan((2*C)/(sqrt(sqrt(1+(4*C^4))-2*C^2))))

%SEGUNDO OBTER INFORMACOES DA FT
s=tf('s');
g = ###;%%%funcao de transferencia%%%
[MG, MF] = margin(g); %margens da FT
fprintf('Margem de Ganho: %.2f dB\n', 20*log10(MG))
fprintf('Margem de Fase: %.2f graus\n', MF)

%TERCEIRO OBTER O GANHO NECESSÁRIO PARA DESLOCAR A RESPSOTA EM FREQ

MS = ### %%%margem de segurança para aumentar sobressinal%%%%
%valor 0 quando nao precisar
[mag, phase, w] = bode(K*g); %obter dados de Bode
fase = squeeze(phase); %fase em graus
w_vec = squeeze(w); %frequência em rad/s
fase_c = -180 + gamma - MS %fase da nova freq de cruzamento
Wc = interp1(fase, w_vec, fase_c)  %encontra a freq de cruzamento nova
mag_db = 20*log10(squeeze(mag)); %ganho em db
ganho_db = interp1(w_vec, mag_db, Wc) %obter o ganho da nova Wc

%QUARTO OBTER O K E VERIFICAR AS EXIGENCIAS
K=10^(-ganho_db/20) %mudar sinal do ganho, queremos subir o grafico
stepinfo(feedback(g,1))
stepinfo(feedback(K*g,1))
step(feedback(g,1),feedback(K*g,1)); 
legend('Sist. sem compensado','Sist. compensado');

%%

%EXEMPLO

%SEÇÃO 8

%COMPENSADOR DE AVANÇO

%PRIMEIRO VERIFICAR SE O SISTEMA JÁ SUPRE PARA UM K QUE RESULTE NO ERRO
%ESTÁTICO SOLICITADO

%SEGUNDO VERIFICAR SE CUMPRE OS REQUISITOS COM BODE

clear; 
K = 50; %%%ganho obtido anteriormente%%%
s=tf('s'); 
g = 1000/(s*(s+5)*(s+200)); %%%função transferência%%%
%bode(K*g);
%figure;
[MG, MF] = margin(K*g);
fprintf('Margem de Ganho: %.2f dB\n', 20*log10(MG))
fprintf('Margem de Fase: %.2f graus\n', MF)

%TERCEIRO OBTER VALOR DE ALPHA

syms a
MFd = 60; %%%margem de fase requisitada%%%
MS = 12; %%%margem de segurança, geralmente de 5 a 12 graus%%% 
eq = (1-a)/(1+a) == sind(MFd - MF + MS); %define a equação
sol = solve(eq, a); %resolve a equação para a variável definida
alpha = double(sol) %mostra o resultado com duas casas decimais

%QUARTO OBTER FREQ DE CRUZAMENTO

[mag, phase, w] = bode(K*g); %obter dados de Bode
mag_db = 20*log10(squeeze(mag)); %converte valores em db
ganho_Wc = 20*log10(sqrt(alpha))  % Ganho que você quer encontrar
Wc = interp1(mag_db, w, ganho_Wc) % Encontrar a frequência

%QUINTO OBTER FREQ DE CORTE DO COMPENSADOR

zero = Wc*sqrt(alpha)
polo = zero/alpha

%SEXTO OBTER COMPENSADOR E TESTAR

Kc=K/alpha
Gc=Kc*(s+zero)/(s+polo);
%bode(Gc*g);
%figure;
[MG, MF] = margin(Gc*g);
fprintf('Margem de Ganho: %.2f dB\n', 20*log10(MG))
fprintf('Margem de Fase: %.2f graus\n', MF)

%VERIFICANDO DESEMPENHO PARA ENTRADA DEGRAU

% D = stepinfo(feedback(g,1))

%%%quando necessário verificar resposta ao degrau%%%
Dc = stepinfo(feedback(Gc*g,1))
Dk = stepinfo(feedback(K*g,1))  

step(feedback(Gc*g,1),feedback(K*g,1)); 
legend('Sist. compensado','Sist. sem compensar');

%RESPOSTA À RAMPA UNITÁRIA

figure; 
sys2=feedback(Gc*g,1);
step(1/s,sys2/s);
title('RESPOSTA À RAMPA UNITÁRIA');
legend('Rampa unitária','Sistema compensado');

% Limitar eixos

xlim([0 1]);  % Ajuste o valor máximo conforme necessário
ylim([0 1]);  % Ajuste conforme sua resposta

figure; 

step(1/(s*(1+Gc*g))); %Para verificar valor do erro estacionário
