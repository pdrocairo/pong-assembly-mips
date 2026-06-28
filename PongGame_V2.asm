.data

##########################################
# CONFIG
##########################################

    .eqv DISPLAY_BASE       0x10040000
    .eqv DISPLAY_WIDTH      128
    .eqv DISPLAY_HEIGHT     64
    .eqv BYTES_PER_PIXEL    4
    .eqv ROW_SIZE           512
    .eqv TOTAL_PIXELS       8192

##########################################
# CONSTANTES
##########################################

    .eqv verde       0x00074217
    .eqv verdeClaro  0x0053a66a
    .eqv azul        0x00539EF0
    .eqv branco      0x00FFFFFF
    .eqv preto       0x00000000
    .eqv pele        0x00FF8DA1

    .eqv PADDLE_HEIGHT 8

    .eqv TECLA_W  0x77
    .eqv TECLA_D  0x64
    .eqv TECLA_I  0x69
    .eqv TECLA_J  0x6A
    .eqv TECLA_1  0x31
    .eqv TECLA_2  0x32

    .eqv SCENARIO_CLASSIC 0
    .eqv SCENARIO_MODERN  1

##########################################
# VARIAVEIS
##########################################

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

    velocidade_atual: .word 2
    frame_speed_counter: .word 0
    score_esq: .word 0
    score_dir: .word 0
    frame_counter: .word 0

    scenario_current: .word 0
    scenario_redraw:  .word 1

.text

##########################################
# MAIN
##########################################

##########################################
# main
#
# Entrada:
#   Nenhuma.
# Saida:
#   Nenhuma.
# Descricao:
#   Inicializa o display e executa o loop principal do jogo.
##########################################
main:
    jal RenderBackground
    jal RenderScenario
    jal RenderCrowd

game_loop:
    lw $t0, raquete_esq_y
    sw $t0, raquete_esq_y_prev
    lw $t0, raquete_dir_y
    sw $t0, raquete_dir_y_prev
    lw $t0, ball_x
    sw $t0, ball_x_prev
    lw $t0, ball_y
    sw $t0, ball_y_prev

    j ler_teclado

##########################################
# GRAPHICS
##########################################

##########################################
# GetPixelAddress
#
# Entrada:
#   $a0 = linha.
#   $a1 = coluna.
# Saida:
#   $v0 = endereco do pixel.
# Descricao:
#   Calcula DISPLAY_BASE + linha * ROW_SIZE + coluna * BYTES_PER_PIXEL.
##########################################
GetPixelAddress:
    li $t0, ROW_SIZE
    mult $a0, $t0
    mflo $t1
    li $t0, BYTES_PER_PIXEL
    mult $a1, $t0
    mflo $t2
    li $v0, DISPLAY_BASE
    add $v0, $v0, $t1
    add $v0, $v0, $t2
    jr $ra

##########################################
# DrawPixel
#
# Entrada:
#   $a0 = linha.
#   $a1 = coluna.
#   $a2 = cor.
# Saida:
#   Nenhuma.
# Descricao:
#   Desenha um pixel usando coordenadas de tela.
##########################################
DrawPixel:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a2, 0($sp)
    jal GetPixelAddress
    lw $a2, 0($sp)
    sw $a2, 0($v0)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

##########################################
# DrawHorizontalLine
#
# Entrada:
#   $a0 = linha.
#   $a1 = coluna inicial.
#   $a2 = tamanho.
#   $a3 = cor.
# Saida:
#   Nenhuma.
# Descricao:
#   Desenha uma linha horizontal reutilizando o tamanho do pixel.
##########################################
DrawHorizontalLine:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal GetPixelAddress
    move $t0, $v0
    move $t1, $a2
DrawHorizontalLine_loop:
    beq $t1, $zero, DrawHorizontalLine_end
    sw $a3, 0($t0)
    addi $t0, $t0, BYTES_PER_PIXEL
    addi $t1, $t1, -1
    j DrawHorizontalLine_loop
DrawHorizontalLine_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

##########################################
# DrawVerticalLine
#
# Entrada:
#   $a0 = linha inicial.
#   $a1 = coluna.
#   $a2 = tamanho.
#   $a3 = cor.
# Saida:
#   Nenhuma.
# Descricao:
#   Desenha uma linha vertical reutilizando o tamanho da linha do display.
##########################################
DrawVerticalLine:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal GetPixelAddress
    move $t0, $v0
    move $t1, $a2
DrawVerticalLine_loop:
    beq $t1, $zero, DrawVerticalLine_end
    sw $a3, 0($t0)
    addi $t0, $t0, ROW_SIZE
    addi $t1, $t1, -1
    j DrawVerticalLine_loop
DrawVerticalLine_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

##########################################
# DrawRectangle
#
# Entrada:
#   $a0 = linha inicial.
#   $a1 = coluna inicial.
#   $a2 = largura.
#   $a3 = altura.
#   $s0 = cor.
# Saida:
#   Nenhuma.
# Descricao:
#   Desenha um retangulo preenchido a partir de coordenadas.
##########################################
DrawRectangle:
    addi $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $s3, 8($sp)
    sw $s4, 4($sp)
    sw $s5, 0($sp)
    move $s1, $a0
    move $s2, $a1
    move $s3, $a2
    move $s4, $a3
    move $s5, $zero
DrawRectangle_loop:
    beq $s5, $s4, DrawRectangle_end
    add $a0, $s1, $s5
    move $a1, $s2
    move $a2, $s3
    move $a3, $s0
    jal DrawHorizontalLine
    addi $s5, $s5, 1
    j DrawRectangle_loop
DrawRectangle_end:
    lw $s5, 0($sp)
    lw $s4, 4($sp)
    lw $s3, 8($sp)
    lw $s2, 12($sp)
    lw $s1, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24
    jr $ra

##########################################
# FillScreen
#
# Entrada:
#   $a0 = cor.
# Saida:
#   Nenhuma.
# Descricao:
#   Preenche toda a area configurada do display.
##########################################
FillScreen:
    li $t0, DISPLAY_BASE
    move $t1, $a0
    li $t2, 0
    li $t3, TOTAL_PIXELS
FillScreen_loop:
    beq $t2, $t3, FillScreen_end
    sw $t1, 0($t0)
    addi $t0, $t0, BYTES_PER_PIXEL
    addi $t2, $t2, 1
    j FillScreen_loop
FillScreen_end:
    jr $ra

##########################################
# GetBackgroundColor
#
# Entrada:
#   Nenhuma.
# Saida:
#   $v0 = cor de fundo do cenario atual.
# Descricao:
#   Retorna verde no cenario classico e preto no cenario moderno.
##########################################
GetBackgroundColor:
    lw $t0, scenario_current
    li $t1, SCENARIO_MODERN
    beq $t0, $t1, GetBackgroundColor_modern
    li $v0, verde
    jr $ra
GetBackgroundColor_modern:
    li $v0, preto
    jr $ra

##########################################
# SCENARIOS
##########################################

##########################################
# DrawScenario
#
# Entrada:
#   Nenhuma.
# Saida:
#   Nenhuma.
# Descricao:
#   Seleciona e desenha o cenario ativo.
##########################################
DrawScenario:
    lw $t0, scenario_current
    li $t1, SCENARIO_MODERN
    beq $t0, $t1, DrawScenarioModern
    j DrawScenarioClassic

##########################################
# DrawScenarioClassic
#
# Entrada:
#   Nenhuma.
# Saida:
#   Nenhuma.
# Descricao:
#   Desenha o campo classico migrado do PongGame_V1.0.asm.
##########################################
DrawScenarioClassic:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $a0, 12
    li $a1, 10
    li $a2, 108
    li $a3, branco
    jal DrawHorizontalLine

    li $a0, 52
    li $a1, 10
    li $a2, 108
    li $a3, branco
    jal DrawHorizontalLine

    li $a0, 13
    li $a1, 10
    li $a2, 39
    li $a3, verdeClaro
    jal DrawVerticalLine

    li $a0, 13
    li $a1, 117
    li $a2, 39
    li $a3, verdeClaro
    jal DrawVerticalLine

    li $a0, 13
    li $a1, 64
    li $a2, 20
    li $a3, verdeClaro
    jal DrawDashedVerticalLine

    li $a0, 14
    li $a1, 65
    li $a2, 19
    li $a3, verdeClaro
    jal DrawDashedVerticalLine

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

##########################################
# DrawScenarioModern
#
# Entrada:
#   Nenhuma.
# Saida:
#   Nenhuma.
# Descricao:
#   Desenha o cenario moderno migrado do PONG.asm.
##########################################
DrawScenarioModern:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $a0, 8
    li $a1, 10
    li $a2, 108
    li $a3, branco
    jal DrawHorizontalLine

    li $a0, 53
    li $a1, 10
    li $a2, 108
    li $a3, branco
    jal DrawHorizontalLine

    li $a0, 9
    li $a1, 64
    li $a2, 22
    li $a3, branco
    jal DrawDashedVerticalLine

    li $a0, 9
    li $a1, 65
    li $a2, 22
    li $a3, branco
    jal DrawDashedVerticalLine

    li $a0, 9
    li $a1, 10
    li $a2, 44
    li $a3, branco
    jal DrawVerticalLine

    li $a0, 9
    li $a1, 117
    li $a2, 44
    li $a3, branco
    jal DrawVerticalLine

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

##########################################
# DrawDashedVerticalLine
#
# Entrada:
#   $a0 = linha inicial.
#   $a1 = coluna.
#   $a2 = quantidade de pixels.
#   $a3 = cor.
# Saida:
#   Nenhuma.
# Descricao:
#   Desenha uma linha vertical com espacamento de uma linha.
##########################################
DrawDashedVerticalLine:
    addi $sp, $sp, -28
    sw $ra, 24($sp)
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $s3, 8($sp)
    sw $s4, 4($sp)
    sw $s5, 0($sp)
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    li $s4, 0
DrawDashedVerticalLine_loop:
    beq $s4, $s2, DrawDashedVerticalLine_end
    sll $s5, $s4, 1
    add $a0, $s0, $s5
    move $a1, $s1
    move $a2, $s3
    jal DrawPixel
    addi $s4, $s4, 1
    j DrawDashedVerticalLine_loop
DrawDashedVerticalLine_end:
    lw $s5, 0($sp)
    lw $s4, 4($sp)
    lw $s3, 8($sp)
    lw $s2, 12($sp)
    lw $s1, 16($sp)
    lw $s0, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 28
    jr $ra

##########################################
# RENDER
##########################################

##########################################
# RenderBackground
#
# Entrada:
#   Nenhuma.
# Saida:
#   Nenhuma.
# Descricao:
#   Preenche o display com o fundo do cenario ativo.
##########################################
RenderBackground:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal GetBackgroundColor
    move $a0, $v0
    jal FillScreen
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

##########################################
# RenderScenario
#
# Entrada:
#   Nenhuma.
# Saida:
#   Nenhuma.
# Descricao:
#   Redesenha os elementos estaticos do cenario atual.
##########################################
RenderScenario:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal DrawScenario
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

##########################################
# RenderBall
#
# Entrada:
#   Nenhuma.
# Saida:
#   Nenhuma.
# Descricao:
#   Desenha a bola na posicao atual.
##########################################
RenderBall:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    lw $a1, ball_x
    lw $a0, ball_y
    li $a2, branco
    jal DrawPixel
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

##########################################
# RenderPaddles
#
# Entrada:
#   Nenhuma.
# Saida:
#   Nenhuma.
# Descricao:
#   Desenha as raquetes nas mesmas posicoes usadas pela logica original.
##########################################
RenderPaddles:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    lw $a0, raquete_esq_y
    li $a1, 12
    li $a2, 1
    li $a3, PADDLE_HEIGHT
    li $s0, branco
    jal DrawRectangle

    lw $a0, raquete_dir_y
    li $a1, 115
    li $a2, 1
    li $a3, PADDLE_HEIGHT
    li $s0, branco
    jal DrawRectangle

    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

##########################################
# RenderScore
#
# Entrada:
#   Nenhuma.
# Saida:
#   Nenhuma.
# Descricao:
#   Desenha o placar exatamente como o codigo original.
##########################################
RenderScore:
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)

    lw $s0, score_esq
    beq $s0, $zero, RenderScore_right
    li $s1, 0
    li $s2, 60
RenderScore_left_loop:
    beq $s1, $s0, RenderScore_right
    li $a0, 10
    move $a1, $s2
    li $a2, branco
    jal DrawPixel
    addi $s2, $s2, -2
    addi $s1, $s1, 1
    j RenderScore_left_loop

RenderScore_right:
    lw $s0, score_dir
    beq $s0, $zero, RenderScore_end
    li $s1, 0
    li $s2, 68
RenderScore_right_loop:
    beq $s1, $s0, RenderScore_end
    li $a0, 10
    move $a1, $s2
    li $a2, branco
    jal DrawPixel
    addi $s2, $s2, 2
    addi $s1, $s1, 1
    j RenderScore_right_loop

RenderScore_end:
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra

##########################################
# RenderCrowd
#
# Entrada:
#   Nenhuma.
# Saida:
#   Nenhuma.
# Descricao:
#   Seleciona a torcida correspondente ao cenario ativo.
##########################################
RenderCrowd:
    lw $t0, scenario_current
    li $t1, SCENARIO_MODERN
    beq $t0, $t1, DrawCrowdModern
    j DrawCrowdClassic

##########################################
# RenderFrame
#
# Entrada:
#   Nenhuma.
# Saida:
#   Nenhuma.
# Descricao:
#   Atualiza a parte visual do frame sem alterar a fisica do jogo.
##########################################
RenderFrame:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    lw $t0, scenario_redraw
    beq $t0, $zero, RenderFrame_keep_background
    jal RenderBackground
    li $t0, 0
    sw $t0, scenario_redraw
    j RenderFrame_static

RenderFrame_keep_background:
    jal ErasePreviousSprites

RenderFrame_static:
    jal RenderScenario
    jal RenderPaddles
    jal RenderBall
    jal RenderScore
    jal IncrementAnimationCounter
    jal RenderCrowd

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

##########################################
# ErasePreviousSprites
#
# Entrada:
#   Nenhuma.
# Saida:
#   Nenhuma.
# Descricao:
#   Apaga bola e raquetes antigas usando a cor de fundo do cenario.
##########################################
ErasePreviousSprites:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    jal GetBackgroundColor
    move $s0, $v0

    lw $a0, raquete_esq_y_prev
    li $a1, 12
    li $a2, 1
    li $a3, PADDLE_HEIGHT
    jal DrawRectangle

    lw $a0, raquete_dir_y_prev
    li $a1, 115
    li $a2, 1
    li $a3, PADDLE_HEIGHT
    jal DrawRectangle

    lw $a1, ball_x_prev
    lw $a0, ball_y_prev
    move $a2, $s0
    jal DrawPixel

    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

##########################################
# KEYBOARD
##########################################

##########################################
# ler_teclado
#
# Entrada:
#   Registradores de memoria do MARS Keyboard and Display MMIO.
# Saida:
#   Atualiza posicoes das raquetes ou o cenario atual.
# Descricao:
#   Mantem as teclas originais e adiciona 1/2 para alternar cenarios.
##########################################
ler_teclado:
    lui $t0, 0xFFFF

    lw  $t1, 0($t0)
    andi $t1, $t1, 1
    beq $t1, $zero, fis_bolinha

    lw  $t2, 4($t0)

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
    li $t3, TECLA_1
    beq $t2, $t3, set_scenario_classic
    li $t3, TECLA_2
    beq $t2, $t3, set_scenario_modern
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
    j fis_bolinha

set_scenario_classic:
    li $t4, SCENARIO_CLASSIC
    sw $t4, scenario_current
    li $t4, 1
    sw $t4, scenario_redraw
    j fis_bolinha

set_scenario_modern:
    li $t4, SCENARIO_MODERN
    sw $t4, scenario_current
    li $t4, 1
    sw $t4, scenario_redraw
    j fis_bolinha

##########################################
# PHYSICS
##########################################

##########################################
# fis_bolinha
#
# Entrada:
#   Variaveis de posicao, direcao, velocidade, raquetes e placar.
# Saida:
#   Atualiza a bola e o placar conforme a logica original.
# Descricao:
#   Preserva movimento, colisao, gols e reset da bola do PongGame_V1.0.asm.
##########################################
fis_bolinha:
    lw $t5, frame_speed_counter
    addi $t5, $t5, 1
    sw $t5, frame_speed_counter
    lw $t6, velocidade_atual
    blt $t5, $t6, render_fase
    li $t5, 0
    sw $t5, frame_speed_counter

    lw $t0, ball_x
    lw $t1, ball_dx
    add $t0, $t0, $t1
    sw $t0, ball_x

    lw $t2, ball_y
    lw $t3, ball_dy
    add $t2, $t2, $t3
    sw $t2, ball_y

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

render_fase:
    jal RenderFrame
    j final_frame

##########################################
# ANIMATION
##########################################

##########################################
# IncrementAnimationCounter
#
# Entrada:
#   frame_counter.
# Saida:
#   frame_counter atualizado.
# Descricao:
#   Mantem o ciclo original da animacao da torcida.
##########################################
IncrementAnimationCounter:
    lw $t5, frame_counter
    addi $t5, $t5, 1
    blt $t5, 30, IncrementAnimationCounter_store
    li $t5, 0
IncrementAnimationCounter_store:
    sw $t5, frame_counter
    jr $ra

##########################################
# DrawCrowdClassic
#
# Entrada:
#   frame_counter e cores do cenario classico.
# Saida:
#   Nenhuma.
# Descricao:
#   Desenha a torcida superior e inferior do cenario classico.
##########################################
DrawCrowdClassic:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $a0, 3
    li $a1, 18
    li $a2, 10
    li $a3, branco
    jal DrawAudienceLine

    li $a0, 57
    li $a1, 18
    li $a2, 10
    li $a3, branco
    jal DrawAudienceLine

    li $a0, verde
    jal DrawClassicCrowdArms

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

##########################################
# DrawCrowdModern
#
# Entrada:
#   frame_counter e cores do cenario moderno.
# Saida:
#   Nenhuma.
# Descricao:
#   Desenha a torcida inferior migrada do PONG.asm.
##########################################
DrawCrowdModern:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $a0, 57
    li $a1, 18
    li $a2, 10
    li $a3, branco
    jal DrawAudienceLine

    li $a0, preto
    jal DrawModernCrowdArms

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

##########################################
# DrawAudienceLine
#
# Entrada:
#   $a0 = linha inicial dos corpos.
#   $a1 = coluna inicial.
#   $a2 = quantidade de pessoas.
#   $a3 = cor dos corpos e pes.
# Saida:
#   Nenhuma.
# Descricao:
#   Desenha corpos verticais de 5 pixels e dois pes para cada pessoa.
##########################################
DrawAudienceLine:
    addi $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp)
    sw $s2, 16($sp)
    sw $s3, 12($sp)
    sw $s4, 8($sp)
    sw $s5, 4($sp)
    sw $s6, 0($sp)

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    li $s4, 0

DrawAudienceLine_loop:
    beq $s4, $s2, DrawAudienceLine_end
    li $t0, 10
    mult $s4, $t0
    mflo $s5
    add $s5, $s1, $s5

    move $a0, $s0
    move $a1, $s5
    li $a2, 5
    move $a3, $s3
    jal DrawVerticalLine

    addi $s6, $s0, 5
    move $a0, $s6
    addi $a1, $s5, -1
    move $a2, $s3
    jal DrawPixel

    move $a0, $s6
    addi $a1, $s5, 1
    move $a2, $s3
    jal DrawPixel

    addi $s4, $s4, 1
    j DrawAudienceLine_loop

DrawAudienceLine_end:
    lw $s6, 0($sp)
    lw $s5, 4($sp)
    lw $s4, 8($sp)
    lw $s3, 12($sp)
    lw $s2, 16($sp)
    lw $s1, 20($sp)
    lw $s0, 24($sp)
    lw $ra, 28($sp)
    addi $sp, $sp, 32
    jr $ra

##########################################
# DrawClassicCrowdArms
#
# Entrada:
#   $a0 = cor de fundo do cenario.
# Saida:
#   Nenhuma.
# Descricao:
#   Alterna os bracos da torcida classica sem usar enderecos absolutos.
##########################################
DrawClassicCrowdArms:
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)

    move $s0, $a0
    lw $t5, frame_counter
    blt $t5, 15, DrawClassicCrowdArms_state1
    move $s1, $s0
    li $s2, pele
    j DrawClassicCrowdArms_paint
DrawClassicCrowdArms_state1:
    li $s1, pele
    move $s2, $s0

DrawClassicCrowdArms_paint:
    li $a0, 60
    li $a1, 17
    li $a2, 10
    move $a3, $s1
    jal DrawArmLine
    li $a0, 59
    li $a1, 19
    li $a2, 10
    move $a3, $s1
    jal DrawArmLine
    li $a0, 6
    li $a1, 17
    li $a2, 10
    move $a3, $s1
    jal DrawArmLine
    li $a0, 5
    li $a1, 19
    li $a2, 10
    move $a3, $s1
    jal DrawArmLine

    li $a0, 59
    li $a1, 17
    li $a2, 10
    move $a3, $s2
    jal DrawArmLine
    li $a0, 60
    li $a1, 19
    li $a2, 10
    move $a3, $s2
    jal DrawArmLine
    li $a0, 5
    li $a1, 17
    li $a2, 10
    move $a3, $s2
    jal DrawArmLine
    li $a0, 6
    li $a1, 19
    li $a2, 10
    move $a3, $s2
    jal DrawArmLine

    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra

##########################################
# DrawModernCrowdArms
#
# Entrada:
#   $a0 = cor de fundo do cenario.
# Saida:
#   Nenhuma.
# Descricao:
#   Alterna os bracos da torcida moderna migrada do PONG.asm.
##########################################
DrawModernCrowdArms:
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)

    move $s0, $a0
    lw $t5, frame_counter
    blt $t5, 15, DrawModernCrowdArms_state1
    move $s1, $s0
    li $s2, pele
    j DrawModernCrowdArms_paint
DrawModernCrowdArms_state1:
    li $s1, pele
    move $s2, $s0

DrawModernCrowdArms_paint:
    li $a0, 60
    li $a1, 17
    li $a2, 10
    move $a3, $s1
    jal DrawArmLine
    li $a0, 59
    li $a1, 19
    li $a2, 10
    move $a3, $s1
    jal DrawArmLine
    li $a0, 59
    li $a1, 17
    li $a2, 10
    move $a3, $s2
    jal DrawArmLine
    li $a0, 60
    li $a1, 19
    li $a2, 10
    move $a3, $s2
    jal DrawArmLine

    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra

##########################################
# DrawArmLine
#
# Entrada:
#   $a0 = linha.
#   $a1 = coluna inicial.
#   $a2 = quantidade de pixels.
#   $a3 = cor.
# Saida:
#   Nenhuma.
# Descricao:
#   Desenha pixels espacados por 10 colunas para animar bracos.
##########################################
DrawArmLine:
    addi $sp, $sp, -28
    sw $ra, 24($sp)
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $s3, 8($sp)
    sw $s4, 4($sp)
    sw $s5, 0($sp)

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    li $s4, 0
DrawArmLine_loop:
    beq $s4, $s2, DrawArmLine_end
    li $t0, 10
    mult $s4, $t0
    mflo $s5
    add $a1, $s1, $s5
    move $a0, $s0
    move $a2, $s3
    jal DrawPixel
    addi $s4, $s4, 1
    j DrawArmLine_loop
DrawArmLine_end:
    lw $s5, 0($sp)
    lw $s4, 4($sp)
    lw $s3, 8($sp)
    lw $s2, 12($sp)
    lw $s1, 16($sp)
    lw $s0, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 28
    jr $ra

##########################################
# UTILS
##########################################

##########################################
# final_frame
#
# Entrada:
#   Nenhuma.
# Saida:
#   Nenhuma.
# Descricao:
#   Mantem o mesmo atraso do jogo original antes do proximo frame.
##########################################
final_frame:
    li $t8, 40000
delay_loop:
    addi $t8, $t8, -1
    bne $t8, $zero, delay_loop

    j game_loop
