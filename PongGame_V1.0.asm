.data  

   #CONSTANTES DE CORES E TELA
   .eqv verde       0x00074217     
   .eqv verdeClaro  0x0053a66a 
   .eqv branco      0x00FFFFFF 
   .eqv preto       0x00000000     
   .eqv pele        0x00FF8DA1
   
   .eqv inicio_tela 0x10040000
   .eqv pixels      8192 

   #CONSTANTES DO JOGO E TECLADO

   .eqv PADDLE_HEIGHT 8
   .eqv TECLA_W  0x77  # Esq Cima
   .eqv TECLA_D  0x64  # Esq Baixo
   .eqv TECLA_I  0x69  # Dir Cima
   .eqv TECLA_J  0x6A  # Dir Baixo

   #VARIÁVEIS DE POSIÇÃO (Atuais e Anteriores)
   raquete_esq_y:      .word 25
   raquete_esq_y_prev: .word 25
   raquete_dir_y:      .word 25
   raquete_dir_y_prev: .word 25
   
   ball_x:       .word 64
   ball_x_prev:  .word 64
   ball_y:       .word 32
   ball_y_prev:  .word 32
   
   ball_dx: .word 1       
   ball_dy: .word 1       
   
   #CONTROLE DE VELOCIDADE E PLACAR
   velocidade_atual: .word 2
   frame_speed_counter: .word 0
   score_esq: .word 0
   score_dir: .word 0
   frame_counter: .word 0

.text
main:

    # ==========================================
    # PINTANDO O FUNDO VERDE (Inicia o campo)
    # ==========================================
    li $8, inicio_tela
    li $9, verde
    li $10, 0
    li $11, pixels
for_fundo:
    beq $10, $11, dadosLimiteSuperior
    sw $9, 0($8)
    addi $8, $8, 4
    addi $10, $10, 1
    j for_fundo
    
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    # PINTANDO LIMITES E CENÁRIO ESTÁTICO
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
dadosLimiteSuperior:
    li $6, branco
    li $5, 0
    li $15, 108
    li $8, 0x10041828      
pintarLimiteSuperior:
    beq $5, $15, dadosLimiteInferior
    sw $6, 0($8)
    addi $8, $8, 4            
    addi $5, $5, 1
    j pintarLimiteSuperior
    
dadosLimiteInferior:
    li $6, branco
    li $5, 0
    li $15, 108   
    li $8, 0x10046828
pintarLimiteInferior:
    beq $5, $15, dadosLimiteEsquerdo
    sw $6, 0($8)
    addi $8, $8, 4
    addi $5, $5, 1
    j pintarLimiteInferior
    
dadosLimiteEsquerdo:
    li $6, verdeClaro
    li $5, 0
    li $15, 39
    li $8, 0x10041A28
pintarLimiteEsquerdo:
    beq $5, $15, dadosLimiteDireito
    sw $6, 0($8)
    addi $8, $8, 512
    addi $5, $5, 1
    j pintarLimiteEsquerdo
    
dadosLimiteDireito:
    li $6, verdeClaro
    li $5, 0
    li $15, 39
    li $8, 0x10041BD4
pintarLimiteDireito:
    beq $5, $15, dadosRede1
    sw $6, 0($8)
    addi $8, $8, 512
    addi $5, $5, 1
    j pintarLimiteDireito
    
dadosRede1:
    li $6, verdeClaro
    li $5, 0
    li $15, 20
    li $8, 0x10041B00
pintarRede1:
    beq $5, $15, dadosRede2
    sw $6, 0($8)
    addi $8, $8, 1024
    addi $5, $5, 1
    j pintarRede1
    
dadosRede2:
    li $6, verdeClaro
    li $5, 0
    li $15, 19
    li $8, 0x10041D04
pintarRede2:
    beq $5, $15, dados_stick
    sw $6, 0($8)
    addi $8, $8, 1024
    addi $5, $5, 1
    j pintarRede2
    
dados_stick:
    li $6, branco
    li $14, 0x10040648
    li $15, 10
    li $16, 0
for_sticks:
    beq $16, $15, dados_pes
    li $5, 0
    move $8, $14
for_linhas:
    beq $5, 5, proxima_coluna
    sw $6, 0($8)
    addi $8, $8, 512
    addi $5, $5, 1
    j for_linhas
proxima_coluna:
    addi $14, $14, 40
    addi $16, $16, 1
    j for_sticks
    
dados_pes:
    li $14, 0x10041044 
    li $17, 0x1004104C 
    li $6, branco
    li $15, 10
    li $16, 0
for_pes:
    beq $16, $15, dados_stick2
    sw $6, 0($14)
    sw $6, 0($17)
    addi $16, $16, 1
    addi $14, $14, 40
    addi $17, $17, 40
    j for_pes
    
dados_stick2:
    li $6, branco
    li $14, 0x10047248
    li $15, 10
    li $16, 0
for_sticks2:
    beq $16, $15, dados_pes2
    li $5, 0
    move $8, $14
for_linhas2:
    beq $5, 5, proxima_coluna2
    sw $6, 0($8)
    addi $8, $8, 512
    addi $5, $5, 1
    j for_linhas2
proxima_coluna2:
    addi $14, $14, 40
    addi $16, $16, 1
    j for_sticks2
    
dados_pes2:
    li $14, 0x10047C44 
    li $17, 0x10047C4C 
    li $6, branco
    li $15, 10
    li $16, 0
for_pes2:
    beq $16, $15, game_loop
    sw $6, 0($14)
    sw $6, 0($17)
    addi $16, $16, 1
    addi $14, $14, 40
    addi $17, $17, 40
    j for_pes2

#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                     # GAME LOOP PRINCIPAL
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
game_loop:

    #SALVAR POSIÇÕES ANTERIORES
    
    lw $t0, raquete_esq_y
    sw $t0, raquete_esq_y_prev
    lw $t0, raquete_dir_y
    sw $t0, raquete_dir_y_prev
    lw $t0, ball_x
    sw $t0, ball_x_prev
    lw $t0, ball_y
    sw $t0, ball_y_prev

    #LER TECLADO
    
ler_teclado:
    lui $t0, 0xFFFF               
    
    lw  $t1, 0($t0)                 
    andi $t1, $t1, 1              
    beq $t1, $0, fis_bolinha     
    
    lw  $t2, 4($t0)                 

    # Instruções vazias para forçar o simulador MARS a perceber 
    # a limpeza da memória antes de seguir, respeitando o "Delay" da janela.
    nop
    nop
    nop
    nop
    nop

processa_tecla:
    li $t3, TECLA_W
    beq $t2, $t3, move_w
    li $t3, TECLA_D
    beq $t2, $t3, move_d
    li $t3, TECLA_I
    beq $t2, $t3, move_i
    li $t3, TECLA_J
    beq $t2, $t3, move_j
    j fis_bolinha           

move_w:
    lw $t4, raquete_esq_y
    ble $t4, 13, fis_bolinha 
    addi $t4, $t4, -1
    sw $t4, raquete_esq_y
    j fis_bolinha
move_d:
    lw $t4, raquete_esq_y
    bge $t4, 44, fis_bolinha 
    addi $t4, $t4, 1
    sw $t4, raquete_esq_y
    j fis_bolinha
move_i:
    lw $t4, raquete_dir_y
    ble $t4, 13, fis_bolinha 
    addi $t4, $t4, -1
    sw $t4, raquete_dir_y
    j fis_bolinha
move_j:
    lw $t4, raquete_dir_y
    bge $t4, 44, fis_bolinha 
    addi $t4, $t4, 1
    sw $t4, raquete_dir_y

    #FÍSICA E COLISÕES DA BOLINHA

fis_bolinha:
    lw $t5, frame_speed_counter
    addi $t5, $t5, 1
    sw $t5, frame_speed_counter
    lw $t6, velocidade_atual
    blt $t5, $t6, render_fase 
    li $t5, 0
    sw $t5, frame_speed_counter

    # Movimento Base
    lw $t0, ball_x
    lw $t1, ball_dx
    add $t0, $t0, $t1       
    sw $t0, ball_x

    lw $t2, ball_y
    lw $t3, ball_dy
    add $t2, $t2, $t3       
    sw $t2, ball_y

    # Colisão Segura Teto/Chão
    ble $t2, 13, bateu_teto
    bge $t2, 51, bateu_chao
    j check_raquetes

bateu_teto:
    li $t2, 14              
    sw $t2, ball_y
    li $t3, 1
    sw $t3, ball_dy
    j check_raquetes

bateu_chao:
    li $t2, 50              
    sw $t2, ball_y
    li $t3, -1
    sw $t3, ball_dy

check_raquetes:
    lw $t0, ball_x
    lw $t2, ball_y
    ble $t0, 13, check_hit_esq
    bge $t0, 114, check_hit_dir
    j checar_gols

check_hit_esq:
    lw $t4, raquete_esq_y
    addi $t5, $t4, 8
    blt $t2, $t4, checar_gols
    bgt $t2, $t5, checar_gols
    li $t0, 14              
    sw $t0, ball_x
    li $t1, 1
    sw $t1, ball_dx
    j checar_gols

check_hit_dir:
    lw $t4, raquete_dir_y
    addi $t5, $t4, 8
    blt $t2, $t4, checar_gols
    bgt $t2, $t5, checar_gols
    li $t0, 113             
    sw $t0, ball_x
    li $t1, -1
    sw $t1, ball_dx

checar_gols:
    lw $t0, ball_x
    ble $t0, 10, gol_dir
    bge $t0, 117, gol_esq
    j render_fase

gol_dir:
    lw $t6, score_dir
    addi $t6, $t6, 1
    sw $t6, score_dir
    j reseta_bola
gol_esq:
    lw $t6, score_esq
    addi $t6, $t6, 1
    sw $t6, score_esq
reseta_bola:
    li $t0, 64
    sw $t0, ball_x
    li $t2, 32
    sw $t2, ball_y
    lw $t1, ball_dx
    neg $t1, $t1
    sw $t1, ball_dx

    #RENDERIZAÇÃO
    
render_fase:
    #APAGAR TUDO QUE ERA ANTIGO
    li $t9, verde                 
    
    lw $t0, raquete_esq_y_prev         
    sll $t1, $t0, 9               
    li $t2, inicio_tela
    add $t2, $t2, $t1             
    addi $t2, $t2, 48             
    li $t3, 0                     
erase_esq:
    beq $t3, PADDLE_HEIGHT, erase_dir_setup
    sw $t9, 0($t2)
    addi $t2, $t2, 512            
    addi $t3, $t3, 1
    j erase_esq

erase_dir_setup:
    lw $t0, raquete_dir_y_prev         
    sll $t1, $t0, 9               
    li $t2, inicio_tela
    add $t2, $t2, $t1             
    addi $t2, $t2, 460            
    li $t3, 0                     
erase_dir:
    beq $t3, PADDLE_HEIGHT, erase_bolinha
    sw $t9, 0($t2)
    addi $t2, $t2, 512
    addi $t3, $t3, 1
    j erase_dir

erase_bolinha:
    lw $t0, ball_x_prev
    sll $t0, $t0, 2
    lw $t1, ball_y_prev
    sll $t1, $t1, 9
    li $t2, inicio_tela
    add $t2, $t2, $t0
    add $t2, $t2, $t1
    sw $t9, 0($t2)         

    #RESTAURAR CENÁRIO INTERNO
    li $t9, verdeClaro
    
    li $t5, 0
    li $t8, 0x10041A28
r_linha_esq:
    beq $t5, 39, r_linha_dir
    sw $t9, 0($t8)
    addi $t8, $t8, 512
    addi $t5, $t5, 1
    j r_linha_esq
    
r_linha_dir:
    li $t5, 0
    li $t8, 0x10041BD4
r_linha_dir_loop:
    beq $t5, 39, r_rede1
    sw $t9, 0($t8)
    addi $t8, $t8, 512
    addi $t5, $t5, 1
    j r_linha_dir_loop

r_rede1:
    li $t5, 0
    li $t8, 0x10041B00
r_rede1_loop:
    beq $t5, 20, r_rede2
    sw $t9, 0($t8)
    addi $t8, $t8, 1024
    addi $t5, $t5, 1
    j r_rede1_loop

r_rede2:
    li $t5, 0
    li $t8, 0x10041D04
r_rede2_loop:
    beq $t5, 19, draw_ativos
    sw $t9, 0($t8)
    addi $t8, $t8, 1024
    addi $t5, $t5, 1
    j r_rede2_loop

    #DESENHAR ATUAIS 
draw_ativos:
    li $t9, branco                
    
    lw $t0, raquete_esq_y         
    sll $t1, $t0, 9               
    li $t2, inicio_tela
    add $t2, $t2, $t1             
    addi $t2, $t2, 48             
    li $t3, 0                     
draw_esq:
    beq $t3, PADDLE_HEIGHT, draw_dir_setup 
    sw $t9, 0($t2)
    addi $t2, $t2, 512            
    addi $t3, $t3, 1
    j draw_esq

draw_dir_setup:
    lw $t0, raquete_dir_y         
    sll $t1, $t0, 9               
    li $t2, inicio_tela
    add $t2, $t2, $t1             
    addi $t2, $t2, 460            
    li $t3, 0                     
draw_dir:
    beq $t3, PADDLE_HEIGHT, draw_bolinha
    sw $t9, 0($t2)
    addi $t2, $t2, 512
    addi $t3, $t3, 1
    j draw_dir

draw_bolinha:
    lw $t0, ball_x
    sll $t0, $t0, 2
    lw $t1, ball_y
    sll $t1, $t1, 9
    li $t2, inicio_tela
    add $t2, $t2, $t0
    add $t2, $t2, $t1
    sw $t9, 0($t2)         

    #PLACAR E TORCIDA
draw_placar:
    lw $t0, score_esq
    beq $t0, 0, draw_placar_dir
    li $t1, 0           
    li $t2, 60          
loop_score_esq:
    beq $t1, $t0, draw_placar_dir
    sll $t3, $t2, 2     
    li $t4, 5120        
    li $t5, inicio_tela
    add $t5, $t5, $t3
    add $t5, $t5, $t4
    sw $t9, 0($t5)
    addi $t2, $t2, -2   
    addi $t1, $t1, 1
    j loop_score_esq

draw_placar_dir:
    lw $t0, score_dir
    beq $t0, 0, gerenciar_animacao
    li $t1, 0
    li $t2, 68          
loop_score_dir:
    beq $t1, $t0, gerenciar_animacao
    sll $t3, $t2, 2
    li $t4, 5120
    li $t5, inicio_tela
    add $t5, $t5, $t3
    add $t5, $t5, $t4
    sw $t9, 0($t5)
    addi $t2, $t2, 2    
    addi $t1, $t1, 1
    j loop_score_dir

gerenciar_animacao:
    lw $t5, frame_counter
    addi $t5, $t5, 1
    blt $t5, 30, continua_animacao
    li $t5, 0
continua_animacao:
    sw $t5, frame_counter

    li $a0, 0x10047844
    li $a1, 0x1004764C
    li $a2, 0x10040C44
    li $a3, 0x10040A4C
    li $t0, 0x10047644
    li $t1, 0x1004784C
    li $t2, 0x10040A44
    li $t3, 0x10040C4C

    blt $t5, 15, animacao_estado_1
    li $v1, verde   
    li $s2, pele    
    j loop_pinta_torcida
animacao_estado_1:
    li $v1, pele    
    li $s2, verde   
loop_pinta_torcida:
    li $t4, 0       
anim_for:
    beq $t4, 10, final_frame
    sw $v1, 0($a0)
    sw $v1, 0($a1)
    sw $v1, 0($a2)
    sw $v1, 0($a3)
    sw $s2, 0($t0)
    sw $s2, 0($t1)
    sw $s2, 0($t2)
    sw $s2, 0($t3)
    addi $a0, $a0, 40
    addi $a1, $a1, 40
    addi $a2, $a2, 40
    addi $a3, $a3, 40
    addi $t0, $t0, 40
    addi $t1, $t1, 40
    addi $t2, $t2, 40
    addi $t3, $t3, 40
    addi $t4, $t4, 1
    j anim_for

    # DELAY E RETORNO

final_frame:
    li $t8, 40000
delay_loop:
    addi $t8, $t8, -1
    bne $t8, $0, delay_loop

    j game_loop