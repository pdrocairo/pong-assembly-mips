.data  
   #VARIAVEIS FIXAS
   
   .eqv verde 0x00074217     
   .eqv verdeClaro 0x0053a66a 
   .eqv branco 0x00FFFFFF 
   .eqv preto 0x00000000     
   .eqv inicio_tela 0x10010000
   .eqv pixels 8192 
   .eqv ultima_linha 0x10017E00

#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

.text

main:

#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	#PINTANDO O FUNDO VERDE

	li $8, inicio_tela
	li $9, verde
	li $10, 0
	li $11, pixels
	
for:
	beq $10, $11, dadosLimiteSuperior
	sw $9, 0($8)
	
	addi $8, $8, 4
	addi $10, $10, 1
	
	j for
	
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	#PINTANDO LIMITES SUPERIOR E INFERIOR
	
dadosLimiteSuperior:
	li $6, branco
	li $5, 0
	li $15, 108
	li $8, 0x10011828      
	
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
	li $8, 0x10016828
	
pintarLimiteInferior:
	beq $5, $15, dadosLimiteEsquerdo
	
	sw $6, 0($8)
	addi $8, $8, 4
	addi $5, $5, 1
	
	j pintarLimiteInferior
	
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	#PINTANDO LIMITES ESQUERDO E DIREITO
	
dadosLimiteEsquerdo:
	li $6, verdeClaro
	li $5, 0
	li $15, 39
	li $8, 0x10011A28
	
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
	li $8, 0x10011BD4
	
pintarLimiteDireito:
	beq $5, $15, dadosRede1
	
	sw $6, 0($8)
	addi $8, $8, 512
	addi $5, $5, 1
	
	j pintarLimiteDireito
	
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	#PINTANDO A REDE

dadosRede1:
	li $6, verdeClaro
	li $5, 0
	li $15, 20
	li $8, 0x10011B00
	
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
	li $8, 0x10011D04
	
pintarRede2:
	beq $5, $15, dados_stick
	
	sw $6, 0($8)
	addi $8, $8, 1024
	addi $5, $5, 1
	
	j pintarRede2
	
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	#PINTANDO TORCIDA SUPERIOR
	
	#CORPO TORCEDOR

dados_stick:
    li $6, branco
    li $14, 0x10010648
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
    
    #PES DO TORCEDOR
    
dados_pes:
    li $14, 0x10011044 #pe inicial esquerdo
    li $17, 0x1001104C #pe inicial direito
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
    
    
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	#PINTANDO TORCIDA INFERIOR
	
	#CORPO TORCEDOR
	
dados_stick2:
    li $6, branco
    li $14, 0x10017248
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
    
    #PES DO TORCEDOR

dados_pes2:
    li $14, 0x10017C44 #pe inicial esquerdo
    li $17, 0x10017C4C #pe inicial direito
    li $6, branco
    li $15, 10
    li $16, 0

for_pes2:
    beq $16, $15, loop_animacao
    sw $6, 0($14)
    sw $6, 0($17)

    addi $16, $16, 1
    addi $14, $14, 40
    addi $17, $17, 40
    j for_pes2
    
loop_animacao:
    li $6, 0x00FFFF00
    li $7, verde
    li $15, 10
    li $16, 0
    li $14, 0x10017844
    li $17, 0x1001764C
    li $18, 0x10010C44
    li $19, 0x10010A4C

desenha_braco_esq:
    beq $16, $15, delay1
    sw $6, 0($14)
    sw $6, 0($17)
    sw $6, 0($18)
    sw $6, 0($19)
    addi $16, $16, 1
    addi $14, $14, 40
    addi $17, $17, 40
    addi $18, $18, 40
    addi $19, $19, 40
    j desenha_braco_esq

delay1:
    li $25, 300000
delay1_loop:
    beq $25, $0, apaga_ini1
    addi $25, $25, -1
    j delay1_loop

apaga_ini1:
    li $15, 10
    li $16, 0
    li $14, 0x10017844
    li $17, 0x1001764C
    li $18, 0x10010C44
    li $19, 0x10010A4C

apaga_braco_esq:
    beq $16, $15, dados_bracos_dir
    sw $7, 0($14)
    sw $7, 0($17)
    sw $7, 0($18)
    sw $7, 0($19)
    addi $16, $16, 1
    addi $14, $14, 40
    addi $17, $17, 40
    addi $18, $18, 40
    addi $19, $19, 40
    j apaga_braco_esq

dados_bracos_dir:
    li $15, 10
    li $16, 0
    li $14, 0x10017644
    li $17, 0x1001784C
    li $18, 0x10010A44
    li $19, 0x10010C4C

desenha_braco_dir:
    beq $16, $15, delay2
    sw $6, 0($14)
    sw $6, 0($17)
    sw $6, 0($18)
    sw $6, 0($19)
    addi $16, $16, 1
    addi $14, $14, 40
    addi $17, $17, 40
    addi $18, $18, 40
    addi $19, $19, 40
    j desenha_braco_dir

delay2:
    li $25, 300000
delay2_loop:
    beq $25, $0, apaga_ini2
    addi $25, $25, -1
    j delay2_loop

apaga_ini2:
    li $15, 10
    li $16, 0
    li $14, 0x10017644
    li $17, 0x1001784C
    li $18, 0x10010A44
    li $19, 0x10010C4C

apaga_braco_dir:
    beq $16, $15, loop_animacao
    sw $7, 0($14)
    sw $7, 0($17)
    sw $7, 0($18)
    sw $7, 0($19)
    addi $16, $16, 1
    addi $14, $14, 40
    addi $17, $17, 40
    addi $18, $18, 40
    addi $19, $19, 40
    j apaga_braco_dir
	
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	
fim:
	j fim